Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:61407 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932771AbcECB7E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 21:59:04 -0400
Date: 2 May 2016 21:59:01 -0400
Message-ID: <20160503015901.2865.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, torvalds@linux-foundation.org
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
Cc: bfields@fieldses.org, eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        riel@redhat.com, tglx@linutronix.de
In-Reply-To: <CA+55aFx441ZBAj6DUXVqEOzBjh9v32F1r2rD-PF2BRpA92fFkg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Right. But there is no reason to think that that should be the same
> thing as the final hash.

Your logic is absolutely correct.  I agree with you.  The two operations
have different purposes, and should be thought of differently.

HOWEVER, if you can find one operation which is good enough to
serve both purposes, that's not evidence of incompetence.

I'm not saying hash_str is anything wonderful.  Just that it's not a
complete disaster.  (As a hash function.  Your comments about its
performance are addressed below.)

It's frankly a lot *better* than the hash computed by namei.c.
That one *is* perilously close to a complete disaster.


The main problem with the multiplicative hash (which describes both
hash_str() and hash_name()) is that input bits can only affect higher
state bits.  The lsbit of the 64-bit state is just the XOR of all the
input lsbits.  The lsbyte depends only on the lsbytes.

But that's not a disaster.  In hash_str(), we throw away the lsbits
at the end so their imperfect mixing doesn't matter.

What's bad is that the msbits of the inputs can only affect the
msbits of the hash.  The msbits of the inputs are just XORed together
into the msbit of the hash.  It's fundamentally impossible for
such a hash to detect any 2-bit change to the msbits of the input.

That said, you're right that most names aren't long enough (16 bytes on
little-endian) to *have* a second msbit to worry about.

> I refuse to call that shit "word at a time".
>
> It's "byte at a time with a slow conditional that will screw up your
> branch predictor and a multiply in the middle".

The *hashing* is word at a time.  The *fetching* is done byte at a time
and I agree that it doesn't qualify in any way at all.

But yeah, your point about the branch predictor penalty being worse than
the 7 saved multiplies is well taken.

Rule #1 of performane: Avoid lock contention at any cost.
Rule #2 of performane: Avoid cache misses unless it conflicts with #1.
(Rule 2a: Cache bouncing is a paritucularly permicious form of cache missing.)
(Rule 2b: Locking, even uncontended, tends to cause cache bouncing.)
Rule #3 of performance: Avoid unpredictable branches.

>> For example, partial_name_hash() is still used in many places
>> even if the word-at-a-time code is used in namei.c.

> Those places aren't actually all that performance-critical.  They
> really don't matter.

AFAICT, none of the string-hash functions outside of fs/ are
on particularly hot paths.  The goal is deleting redundant code.

> We'll never get rid of "hash_name()", it not only has that '/' case,
> it's also inlined for a reason. You'd copy it without the magic for
> '/' and turn that into str_hash() for others to use.
>
> full_name_hash() can presumably be used pretty much as-is as mem_hash().

That part is obvious. I was just caught between two unpleasant
possibiites:

- Placing a str_hash() helper function in the middle of fs/namei.c which
  nothing in fs/namei.c actually calls, or
- Copying it to some outside file and then having to keep the
  two in sync.

Thinking about the function comments on each, the first seems less
embarrasing to write.

> Maybe we could expose that kind of interface, even if it's pretty ugly.

Yeah, that's pretty much what I thought.  I just hoped you had some
brilliant idea for avoiding it.

> The thing is, a lot of people tend to optimize performance (and
> behavior) for large strings.
>
> For path components, the most common lengths are less than a single
> 8-byte word! That "mixing" function almost doesn't matter, because the
>  case that matters the most (by far) are strings that fit in one or
> _maybe_ two words.

I'll remember that next time I look up
.git/objects/69/466b786e99a0a2d86f0cb99e0f4bb61588d13c

:-)

But yes, it makes your point about pathname components.
The first three are all a single word.

I just worry with people having directories full of PHP state
cookies.

> Hmm? It uses "fold_hash()", which definitely doesn't do that.

Mea culpa; that's a side effect of repeately grepping the kernel.
There was a *different* hash folding function in some other source file
elsewhere that did that, and I got the two mixed up in my memory.

The word-at-a-time one does "hash_64(x)", which doesn't have that problem.

(Maybe it was the IP checksum folding?)

>>    (If you have a particular cycle count budget in mind, I can come up with
>>    something.)

> The real issue I had in fs/namei.c is that link_path_walk() and
> __d_lookup_rcu() are literally _the_ hottest functions in the kernel
> under a few (common) loads, and for code generation things like
> register pressure ends up mattering.
> 
> The reason that "hash_len" is a single 64-bit field rather than two
> 32-bit fields, for example, is that that way it takes on _register_
> when we do the has lookup. Some of that code was tuned to inline - and
> _not_ inline in particular patterns.
> 
> Now, some of that tuning may have bitrotted, of course, so I'm not
> saying it's necessarily doing great now. But some of that code was
> tuned to not need a stack frame etc.

Yes, and it's hard to make a general purpose helper out of code
that's tuned to piano wire tension like that.

I was thinking about very fast hash functions (2 or 3 cycles
per word), and the obvious solution is to use a second register.

As you pointed out above, the mixing function can take advantage of an
internal state which is larger than the final state, so the easy way to
minimize collisions without very expensive state mixing between words
is to give the bits more room to spread out.

I was playing with the idea of an ARX structure like the "Speck" block
cipher (https://en.wikipedia.org/wiki/Speck_%28cipher%29):

	h1 ^= a;
	h2 ^= h1; h1 = ROTL(h1, K);
	h1 += h2; h2 *= 9;

The "h2 *= 9" replaces "ROTL(h2, 3)" in Speck, achieves a little more
mixing, is one cycle on most machines, and is probably supported by
more functional units than a general barrel shift.

It's only one more cycle on the critical path than the current
"hash = (hash + a) * 9"... but it's one more register.


> I think the caller should do it, yes. There's a difference between
> "calculate a hash for a string" and "turn that hash into a hashtable
> lookup".

Makes sense, thanks.

Another thing worth doing is having a slightly less thorough folding
function than hash64(x, 32).  (x >> 32) + (uint32)x * CONSTANT does
just as well if you're keeping all 32 bits.

This is hasically the first half of my 32-bit hash_64().  Then if you
want less than 32 bits, you can do a second hash_32() on the result.

> Anyway, I suspect that your mixing function changes should be fine.
> That link_path_walk() is important, but a couple of shifts and xors
> shouldn't kill it.

Actually, that code
1) Uses an extra register for a shift temporary anyway, and
2) Has a 6-cycle critical path, which is pretty borderline.

The ARX code above seems like a more efficient use of two registers.

(It's also conveniently nonlinear, so if we want, feeding a salt into
h2 makes it less utterly trivial to force collisions.)

I'll play with that for a bit.  Thank you for mentioning those critical
functions; I'll check the x86 code generation for them to make sure it
doesn't get worse.



P.S. Here's a way to improve partial_name_hash on x86.
Compare the assembly for

unsigned long
pnh1(unsigned long c, unsigned long prevhash)
{
        return (prevhash + (c << 4) + (c >> 4)) * 11;
}

pnh1:
	movl    %eax, %ecx
        shrl    $4, %eax
        sall    $4, %ecx
        addl    %ecx, %eax
        addl    %eax, %edx
        leal    (%edx,%edx,4), %eax
        leal    (%edx,%eax,2), %eax
        ret

unsigned long
pnh2(unsigned long c, unsigned long prevhash)
{
        prevhash += c <<= 4;
        prevhash += c >> 8;
        return prevhash * 11;
}

pnh2:
        sall    $4, %eax
        addl    %eax, %edx
        shrl    $8, %eax
        addl    %eax, %edx
        leal    (%edx,%edx,4), %eax
        leal    (%edx,%eax,2), %eax
        ret

pnh1 doesn't know that "c" is really only 8 bits and so it doesn't need
to copy it to another register to compute the two shifted forms.
