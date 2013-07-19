Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36298 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479Ab3GSOhx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Jul 2013 10:37:53 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130718213126.12710.qmail@science.horizon.com>
References: <20130718213126.12710.qmail@science.horizon.com>
To: "George Spelvin" <linux@horizon.com>
Cc: dhowells@redhat.com, joe@perches.com, keyrings@linux-nfs.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org
Subject: Re: [PATCH] Assoc_array: Drop leaf-type concept
Date: Fri, 19 Jul 2013 15:37:41 +0100
Message-ID: <6877.1374244661@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

George Spelvin <linux@horizon.com> wrote:

> Looks cleaner.

Thanks!

> The larger issues that bother me:
> 
> 1) The fact that the abstract daya type "index key" provides access to
>    a byte string "index key" is a bit confusing.  I'd describe it as
>    follows:  (Based on my current understanding.)
> 
> 
>    Each object has an associated "index key" that is used for lookup.
>    The index key is a string of bits which is stored "inside" the object,
>    however all access to it is done through method functions, so it is
>    not necessary to explicitly store it anywhere.
> 
>    For example, it is possible to have the leading portion of the
>    index_key be a hash of the remainder.
> 
>    Index keys may be variable-length, but must be self-delimiting.
>    Specifically, two different index keys must differ at some bit position
>    before the end of the shorter of the two.

This is a reasonable summary - but there's no requirement for the index key to
be a string of bits in its native form.  It's just that it must be presented to
my routines as a bit string.  It doesn't even need to be stored inside the
object - though I did note you quoted that.  Maybe "associated with"?

>    Some index key methods take an isolated "const void *index_key"
>    argument, while others take an object pointer.

Indeed.  Sometimes I have an explicit index key available (look up, for
example) and sometimes I only have the object available (determining whether a
key I'm inserting matches a key I already have when debating shortcut
creation).

The reason assoc_array_insert() takes an explicit index key _and_ an object
(which provides an implicit index key) is that it permits me to use
assoc_array_walk() - which only wants the the explicit index key.

> 2) The code does not look 32-bit safe.  In particular, keyring_get_key_chunk
>    assumes the hash is BITS_PER_LONG long, but keyring_diff_objects 
>    assumes it's 8*8 bits...

Good point.  Fixed.

> 3) I presume you looked at wider tries like Judy arrays and found that
>    a fan-out of 16 was better?

I have not looked at Judy arrays, but I have looked at the other stuff Linux
has available and some stuff beyond that.

To select the algorithm, I started off with a list of criteria:

 (1) It must not be necessary to modify an object to be able to include it in
     the container.  That means no list_head, rb_node or similar emplacement
     within the object.

 (2) Can't use nodes > PAGE_SIZE.  Preferably they'd be much smaller.

 (3) Having lots of blocks that have one object pointer and two or three
     metadata pointers is bad.  I'd prefer a much higher object-to-meta pointer
     ratio.

 (4) All algorithms must be non-recursive functions as stack space is at a
     premium.  Also can't rely on being able to allocate extra space during R/O
     accesses.

 (5) Must be possible for RCU R/O accesses to be concurrent with modification.

 (6) Reading must be non-sleeping (so no use of a semaphore for reading).

 (7) Concurrent modification is not a requirement.

 (8) Needs to be primarily optimised for direct walking to a node by index key.

 (9) Needs reasonable iteration performance too.

(10) Modifications shouldn't have to replace a lot of internal blocks.

I think the biggest pain is actually the non-recursive algorithm criterion.

I have actually used this container before for a disk-based tree.


Anyway, with regards to the size of the fan out, I wanted a compromise between
having slack available so as not to get too deep a tree too quickly whilst not
have too much slack space - after all, kernel memory is not easily reclaimable.

However, the biggest factor was that I decided to grab the index key a chunk at
a time.  The logical choice for chunk size was register size (ie. unsigned
long) and ideally there would be no wastage in the chunk I got back.  This
means a fan out that divides exactly in to 2^32 and 2^64.  From that point of
view, the choices are 2^(N^2).  A fan out of 16 seems nice as it's a nibble or
one hex digit.

Another factor was that I wanted, if possible, to have keyring objects to
cluster together to make iterating over them easier (and I know when to stop
iterating over them because the rest of the objects are just keys), but still
have them fan out to make them easier to look up directly.  The direct lookup
is of lesser importance because keyrings tend not to point to many other
keyrings.

> 4) There are 3/7 unused bytes in an assoc_array_node, after parent_slot.
>    Would it be worth storing 16/48 bits of index key and 3/4 bits of
>    number of levels to skip per assoc_array_node?
>    Since parent_slot is actually only 4 bits, you could store 4 bits
>    of nubmer of levels and 56 bits (up to 14 levels, plus the one
>    from the famout) of index key.
> 
>    With 32-way fanout, you could fit 5 bits of parent index, 25/55 bits of
>    index key, and encode the number of levels to skip (0-5/11) more carefully.

You mean merge some shortcut representation into a node?  Maybe.  It gets
messy, though, if the parent of such a node gets folded into *its* parent and
leaves the "skip+node" out of range of the index key storage that it has.  Now
you have to replace the "skip node" too (or insert a shortcut).  Multiply by
the fanout...

Actually, I'd rather store the index key nibble for each object I have a
pointer too.  That would take up another word sadly (16 * log2(16)), but would
improve insertion and searching a bit.

> 5) The big question: Why not use a hash table?  That's what people
>    usually expect when you say "associative array".  It would be simpler
>    and faster.

What I've implemented *is* in essence a series of nested hash tables;-)

But, in answer, no, it wouldn't necessarily be faster, but yes, it would mostly
be simpler[*].  The hash table approach would also be less memory efficient
generally - though one can construct datasets that would be horribly
inefficient for both algorithms - and much less efficient for mine.

[*] Until it comes to expanding or collapsing the hash table.  How do you work
    out how much to expand it or contract it by to get a good spread of
    objects?

A hash table would not be able to grow beyond PAGE_SIZE practically[**] - so a
maximum of 512 buckets on most 64-bit systems (assuming no other per-bucket
metadata for things like occupancy counts).  However, I'm looking at a case
with a need to store ~36000 keys in a keyring - so on the order of 70 keys per
hash bucket.  Assuming a perfect distribution, my array would require about
2500 nodes in a tree four levels deep and the maximum number of
index-key-to-object comparisons you'd have to make would be 16.

[**] order>0 allocations are to be avoided where possible, but it would be
     possible to stitch multiple pages together with a higher level pointer
     block - which adds complexity.

In a hash table the hash function is much more critical as it's only applied
once and you may not have control over variety of data you're going to be asked
to hash.  Also, in the keyrings case, you cannot link the objects (keys)
directly into the hash table, so each object would need to be represented by a
linkage block.

Further, once you've got a few objects into a hash table, a traditional hash
table is actually slower and less efficient because the object pointers are
spread over more cachelines.

I will grant you, though, that hash table look up, iteration, insertion and
deletion are all simpler - the last two _provided_ you do not need to resize
the hash table.

But I won't grant you that a hash table would necessarily be faster for the
given amount of metadata memory used.

>    RCU-safe resizeable hash tables are tricky, but a solved problem,

Conceptually, that's not too hard - provided you are willing to accept a
complete replacement of the entire metadata tree.  You have to do that so as
not to destabilise iteration and lookup when items jump to a different bucket.
Remember: modification shalt not block iteration or lookup.

>    There are universal hashing techniques for preventing hash collision
>    attacks.  

I'm not too worried about attacks.  If someone really wants to attack, you
can't really stop them.  The main difficulty with hashing is that you might
have no control over the data you're hashing.  The upside is that there's no
reason you have to only use one hashing function.  In my case, hashing
functions could be per-keytype for example.

David
