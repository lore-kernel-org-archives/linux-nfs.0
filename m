Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:44035 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755061AbcEBU0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 16:26:39 -0400
Date: 2 May 2016 16:26:37 -0400
Message-ID: <20160502202637.13861.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, torvalds@linux-foundation.org
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
Cc: bfields@fieldses.org, eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        riel@redhat.com, tglx@linutronix.de
In-Reply-To: <CA+55aFx2O-ptJa2Xt4mYUbO-b0z9XSf-wEw97Gyj1h3porFC_g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus wrote:
> I really think that we should *not* convuse those two odd svcauth.h
> users with the whole hash_32/64 thing.
>
> I think  hash_str/hash_mem should be moved to lib/hash.c, and they
> just shouldn't use "hash_long()" at all, except at the very end (they
> currently have a very odd way of doing "every <n> bytes _and_ at the
> end".

Moving them is fine.  I have no problem with that, except that I agree
that merging them with the fs/namei.c hashes would be even better.

But the hash_long it not odd at all.  They're using it as the mix function
between adding words.  Like hash_name() uses "hash = (hash + a) * 9".

So it's

	x = (first 8 bytes of string)
	x = __hash64(x);
	x ^= (next 8 bytes of string)
	x = __hash64(x);
	... repeat ...
	x ^= (last 1..8 bytes of string)
	return __hash64(x);

It's a quite reasonable mix function.  One multiply (4 cycles or so) per
8 bytes.  It's definitely swamped by the byte-at-a-time string loading.

(The one peculiar thing is that the "last 1..8 bytes of string" is, due
to the way it's shiften into an accumulator, actually the last 8 bytes,
which may include some previously-hashed bytes.  But that has nothing
to do with the mixing.)


But... the fundamental reason I didn't was that this is late -rc.
I'm trying to fix a *bug* tglx found, not add risk and delay with a much
more ambitious patch series.

This is a related but separate issue that can be addressed separately.

> In particular, the hashing in the *middle* is very different from the
> hashing at the end.
>
> At the end, you need to make sure the lower bits get spread out
> particularly to the upper bits, since you're going to shift things
> down.
>
> But in the middle, you just want to spread the bits out (and in
> particular, destroy any byte-per-byte patterns that it build it in
> between).

Yes, in the middle you have a full width hash to spread the bits among,
while at the end you have to "concentrate" the hash value in a few bits.
The latter is a more difficult task and might be slower.

But there's nothing really *wrong* with using the same mix operation
both places if it's both good enough and fast enough.

In particualr, if you're loading the string a word at a time, you need
a much better mixing function than if you're processing it byte at a time.

> Quite frankly, I think those functions should just use something like
> the FNV hash (or Jenkins hash), and then maybe use "hash_long()" at
> the *end* to shift the result down to "bits".

It *is* the FNV hash!  More specifically, FNV-1a done a word at a time;
doing it byte at a time like most implementations would result in 8
times as many multiplies and be slower.

The only difference is the exact multiplier.  The published FNV-1
uses a low-bit-weight multiplier.  Since this is being done a word
at a time, I think the stronger multiplier is worth it.

Jenkins hash is (if you have a HW multiplier) slower.  Better mixing,
so adding a multiply at the end would be redundant.

> I don't want to make our <linux/hash.h> odder just because of two
> entirely broken users.

> That said, I actually think hash_str() should be killed entirely.
> Better just use what we use for pathnames: full_name_hash() (which
> gets a pointer and length) and hash_name (which gets the string).

I was thinking the exact same thing.  Repeated grepping over the kernel
tree for "hash_*" functions showed me just how many there are in various
places, and combining some would be a good idea.

For example, partial_name_hash() is still used in many places
even if the word-at-a-time code is used in namei.c.

> Those functions do the "word-at-a-time" optimization, and they should
> do a good enough job. If they aren't, we should fix them, because they
> are a hell of a lot more important than anything that the svcauth code
> does.

Okay, let me list the problems...

1) hash_name() stops at a slash or a nul.  hash_str() only looks
   for a nul.  Should I add a third variant?  Should that go in fs/namei,
   or should the whole pole be moved elsewhere?

2) Some places need the length *and* the hash.  Calling strlen() and then
   full_name_hash() somewhat defeats the purpose of word-at-a-time access.
   hash_name returns both jammed into a 64-bit word.  Is that a good
   interface in general?

   Myself, I think the length should be computed at copy_from_user()
   time and I'd like to look at each such call site and understand why
   it *doesn't* have the length ready.  But that's a lot of work.

3) They do particularly crappy mixing.  See that "RFC PATCH 4/2" I posted
   that because I couldn't stand how bad it was.

   If you don't have word at a time, the partial_name_hash() is decent,
   but the word-at-a-time mixes by multiplying by 9.  So the hashes
   of the strings "1.......0" and "0.......9" are identical. 

   (I assume this was chosen as the best available one-instruction (LEA)
   mix operation due to an obsessive interest in speed in the dcache.)

   More crappy mixing is the final folding.  On a 64-bit machine, the
   high and low 32 bits are just XORed together.  So the hashes of
   "deadbeef" and "beefdead" are identical.

   I agree we should be very careful of the mixing function, since it's
   the only thing limiting loop cycle time.  The has_zero hackery has a
   cricital path about 6 cycles long, but they're independent per loop
   and a sufficiently aggressive OOO machine could pipeline them.

   (If you have a particular cycle count budget in mind, I can come up with
   something.)

4) They don't do a final mix.  Again, obsessive interest in speed when
   you're storing the whole 32 bits and comparing that.  For applications
   that use only a few bits of hash index and need the entropy
   "concentrated", should this be done outside?

Basicaly, I can understand why someone might prefer a stronger hash
for less speed-critical applications.


I agree that we should ideally have just two string hash functions for
general kernel use (plus any imposed by ecternal standards like file
systems or ELF).

One is the dcache hash, for applications where collision DoS attacks are
not expected and is optimized strongly for speed.

A second, something like SipHash, for applcations which require
sollision resistance against malicious attackers.

But achieving that ideal is a project of significant size.
There are a lot of corner cases to worry about.
