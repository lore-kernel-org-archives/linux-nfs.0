Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:35937 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180AbcEBVTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 17:19:40 -0400
MIME-Version: 1.0
In-Reply-To: <20160502202637.13861.qmail@ns.horizon.com>
References: <CA+55aFx2O-ptJa2Xt4mYUbO-b0z9XSf-wEw97Gyj1h3porFC_g@mail.gmail.com>
	<20160502202637.13861.qmail@ns.horizon.com>
Date: Mon, 2 May 2016 14:19:39 -0700
Message-ID: <CA+55aFx441ZBAj6DUXVqEOzBjh9v32F1r2rD-PF2BRpA92fFkg@mail.gmail.com>
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
From: Linus Torvalds <torvalds@linux-foundation.org>
To: George Spelvin <linux@horizon.com>
Cc: Bruce Fields <bfields@fieldses.org>, Eric Dumazet <eric.dumazet@gmail.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 2, 2016 at 1:26 PM, George Spelvin <linux@horizon.com> wrote:
>
> But the hash_long it not odd at all.  They're using it as the mix function
> between adding words.  Like hash_name() uses "hash = (hash + a) * 9".

Right. But there is no reason to think that that should be the same
thing as the final hash.

In fact, there are many reasons to think it should *not*.

The final hash is different.

It's duifferent not just because it wants to concentrate the bits at
the highb end (which the middle hash does not), but it's different
exactly because the whole calling convention is different: the final
hash returns a "small" value (in your version an "u32"), while the
hash in the middle very much does not.

So thinking that they are somehow related is wrong. It screws up
hash.h, and incorrectly conflates this middle hash_mix() thing with
the final has_32/64() thing.

> It's a quite reasonable mix function.  One multiply (4 cycles or so) per
> 8 bytes.  It's definitely swamped by the byte-at-a-time string loading.

.. but it's not. Exactly because of the above.

Make it be a "hash_mix()" function. Make it use the multiply, by all
means. Same multiplier, even. BUT IT IS STILL NOT THE SAME FUNCTION,
for the above reason. One wants to return "u32", the other does not.

Really.

> But... the fundamental reason I didn't was that this is late -rc.
> I'm trying to fix a *bug* tglx found, not add risk and delay with a much
> more ambitious patch series.

Oh, this late in the rc we're not doing _any_ of this. I sent out my
suggested "late in the rc and for stable" patch that fixes the
practical problem we have, that has nothing to do with cleaning things
up.

> It *is* the FNV hash!  More specifically, FNV-1a done a word at a time;
> doing it byte at a time like most implementations would result in 8
> times as many multiplies and be slower.

I refuse to call that shit "word at a time".

It's "byte at a time with a slow conditional that will screw up your
branch predictor and a multiply in the middle".

A compiler might be able to turn it into some disgusting unrolled
thing that avoids some of the problems, but at no point is that a good
thing.

I seriously think that it would be

 (a) more readable

 (b) have a better mix function

if it was just kept as a byte-at-a-time thing entirely with the
per-byte mixing thing done better than just "shift by 8 bits".

And then at the end you could do a single hash_long().

That horrible svc thing needs to go.

It's alll pretty moot, since we have a reasonable version that
actually does do work-at-a-time.

That can be improved too, I'm sure, but that svcauth garbage should
just be thrown out.

> The only difference is the exact multiplier.  The published FNV-1
> uses a low-bit-weight multiplier.  Since this is being done a word
> at a time, I think the stronger multiplier is worth it.

.. Considering that the "word-at-a-time" is likely *slower* than doing
it a byte-at-a-time the way it has been encoded, I'm not in the least
convinced.

> For example, partial_name_hash() is still used in many places
> even if the word-at-a-time code is used in namei.c.

Those places aren't actually all that performance-critical. They
really don't matter.


> Okay, let me list the problems...
>
> 1) hash_name() stops at a slash or a nul.  hash_str() only looks
>    for a nul.  Should I add a third variant?  Should that go in fs/namei,
>    or should the whole pole be moved elsewhere?

We'll never get rid of "hash_name()", it not only has that '/' case,
it's also inlined for a reason. You'd copy it without the magic for
'/' and turn that into str_hash() for others to use.

full_name_hash() can presumably be used pretty much as-is as mem_hash().

> 2) Some places need the length *and* the hash.  Calling strlen() and then
>    full_name_hash() somewhat defeats the purpose of word-at-a-time access.
>    hash_name returns both jammed into a 64-bit word.  Is that a good
>    interface in general?

Hmm. We actually have that exact case in the dentry code and
hash_name(), except we handle it by doing that "hashlen" thing that
contains both the length and the hash in one 64-bit thing.

Maybe we could expose that kind of interface, even if it's pretty ugly.

>    Myself, I think the length should be computed at copy_from_user()
>    time and I'd like to look at each such call site and understand why
>    it *doesn't* have the length ready.  But that's a lot of work.

If it's copied from user space, we already do have the length.

You do realize that pathnames are different from pretty much every
other case in the kernel? There's a reason pathnames have their own
logic. The string length is very different from the component length,
and it turns out that component length and hash is generally critical.

> 3) They do particularly crappy mixing.  See that "RFC PATCH 4/2" I posted
>    that because I couldn't stand how bad it was.
>
>    If you don't have word at a time, the partial_name_hash() is decent,
>    but the word-at-a-time mixes by multiplying by 9.  So the hashes
>    of the strings "1.......0" and "0.......9" are identical.
>
>    (I assume this was chosen as the best available one-instruction (LEA)
>    mix operation due to an obsessive interest in speed in the dcache.)

The thing is, a lot of people tend to optimize performance (and
behavior) for large strings.

For path components, the most common lengths are less than a single
8-byte word! That "mixing" function almost doesn't matter, because the
case that matters the most (by far) are strings that fit in one or
_maybe_ two words.

Yes, things are slowly moving towards longer pathnames, but even with
long filenames, most component names are the directory entries that
still tend to be shorter. We still have the old 3-letter ones close to
the root, of course, but the statistics are still pretty heavily
skewed to <15 characters especially if you look at directory names.

So for pathnames, the mixing in the middle has tended to not be
_nearly_ as important as the final mix, for the simple reason that it
happens maybe once, often not at all.

>    More crappy mixing is the final folding.  On a 64-bit machine, the
>    high and low 32 bits are just XORed together.  So the hashes of
>    "deadbeef" and "beefdead" are identical.

Hmm? It uses "fold_hash()", which definitely doesn't do that.

Are you still looking at partial_name_hash() and friends? Don't. They
are garbage. They are used for things like case-insensitive
filesystems etc.

>    (If you have a particular cycle count budget in mind, I can come up with
>    something.)

The real issue I had in fs/namei.c is that link_path_walk() and
__d_lookup_rcu() are literally _the_ hottest functions in the kernel
under a few (common) loads, and for code generation things like
register pressure ends up mattering.

The reason that "hash_len" is a single 64-bit field rather than two
32-bit fields, for example, is that that way it takes on _register_
when we do the has lookup. Some of that code was tuned to inline - and
_not_ inline in particular patterns.

Now, some of that tuning may have bitrotted, of course, so I'm not
saying it's necessarily doing great now. But some of that code was
tuned to not need a stack frame etc.

> 4) They don't do a final mix.  Again, obsessive interest in speed when
>    you're storing the whole 32 bits and comparing that.  For applications
>    that use only a few bits of hash index and need the entropy
>    "concentrated", should this be done outside?

I think the caller should do it, yes. There's a difference between
"calculate a hash for a string" and "turn that hash into a hashtable
lookup".

               Linus
