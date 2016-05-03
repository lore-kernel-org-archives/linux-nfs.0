Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34454 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbcECDBp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 23:01:45 -0400
MIME-Version: 1.0
In-Reply-To: <20160503015901.2865.qmail@ns.horizon.com>
References: <CA+55aFx441ZBAj6DUXVqEOzBjh9v32F1r2rD-PF2BRpA92fFkg@mail.gmail.com>
	<20160503015901.2865.qmail@ns.horizon.com>
Date: Mon, 2 May 2016 20:01:44 -0700
Message-ID: <CA+55aFxAiPXFjmDEUN-G2E+FyaXjh6uDjGLXL3nyrkSvf2wF+g@mail.gmail.com>
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

On Mon, May 2, 2016 at 6:59 PM, George Spelvin <linux@horizon.com> wrote:
>
> AFAICT, none of the string-hash functions outside of fs/ are
> on particularly hot paths.  The goal is deleting redundant code.

Yes, agreed.

>> We'll never get rid of "hash_name()", it not only has that '/' case,
>> it's also inlined for a reason. You'd copy it without the magic for
>> '/' and turn that into str_hash() for others to use.
>>
>> full_name_hash() can presumably be used pretty much as-is as mem_hash().
>
> That part is obvious. I was just caught between two unpleasant
> possibiites:
>
> - Placing a str_hash() helper function in the middle of fs/namei.c which
>   nothing in fs/namei.c actually calls, or
> - Copying it to some outside file and then having to keep the
>   two in sync.

So I don't think the "keep the two in sync" is necessarily all that problematic.

The word-at-a-time logic _used_ to be very specific to the name_hash()
code, but it got made generic enough over a few iterations that it's
actually a fairly reasonable pattern now.

So the code loop ends up being really not very complex:

        const struct word_at_a_time constants = WORD_AT_A_TIME_CONSTANTS;

        hash = a = 0;
        len = -sizeof(unsigned long);
        do {
                hash = (hash + a) * 9;
                len += sizeof(unsigned long);
                a = load_unaligned_zeropad(name+len);
                b = a ^ REPEAT_BYTE('/');
        } while (!(has_zero(a, &adata, &constants) | has_zero(b,
&bdata, &constants)));

and with your suggested "hash_mix()" function (may I suggest we just
make it take both the old hash and the new value as two separate
arguments, and it can choose how to mix them), there remains pretty
much nothing to keep in sync.

Yes, there's the tail part, but that ends up being pretty simple too.

The non-path-component case (so checking only for an ending NUL
character, not the '/') ends up being exactly the same, except all the
'b' logic goes away, so you end up with

        hash = a = 0;
        len = -sizeof(unsigned long);
        do {
                hash = hash_mix(hash, a);
                len += sizeof(unsigned long);
                a = load_unaligned_zeropad(name+len);
        } while (!has_zero(a, &adata, &constants));

which really seems to not be a pain. Very simple, in fact. There's
hardly any code left to keep in sync: any tweaking of the hash would
happen by tweaking the hash_mix()

The tail part would presumably be:

        adata = prep_zero_mask(a, adata, &constants);

        mask = create_zero_mask(adata | bdata);
        return hash_mix(hash, a & zero_bytemask(mask));

and you're done (or we could perhaps decide that the last mix is fine
just doing a single add? We will have mixed up all previous hash
values, so that last "hash_mix()" might just be a simple addition).

Yes, if we want to return some mix of the length and the hash, we'd
have to play those hashlen games, but I suspect the only case that
*really* cares deeply about that is the dentry hash case, and we'd
just keep it separate.

In other words, I think just the addition of your "hash_mix()" helper
is enough to abstract things out enough that there really is nothing
left but tying all those pieces together, and no maintenance burden
from having "two copies" of that tying-togetherness.

>> For path components, the most common lengths are less than a single
>> 8-byte word! That "mixing" function almost doesn't matter, because the
>>  case that matters the most (by far) are strings that fit in one or
>> _maybe_ two words.
>
> I'll remember that next time I look up
> .git/objects/69/466b786e99a0a2d86f0cb99e0f4bb61588d13c
>
> :-)

Yes, they happen, but when people have pathnames like that, your
hashing function generally isn't going to much matter.

Except you absolutely want to avoid 8-bit and 4-bit boundaries when
mixing. The "*9" we have now does that, we had a *11 in an earlier
incarnation (but that was coupled with shifting right too - I think
our old hash remains in the partial_name_hash())

I do agree that it's not a great hash mixing function, but I don't
think it's been particularly problematic either. I did run my whole
filesystem through the hash at some point just to verify, and the
statistics seemed fairly balanced.

But yes, I think your hash_mix() function is likely a noticeable
improvement from a hashing standpoint.  And while it may not be all
that noticeable for path components that are usually pretty short, if
we extend this code to be a generic string hash then the whole "three
characters is the most common component length" argument gores away ;)

> I was playing with the idea of an ARX structure like the "Speck" block
> cipher (https://en.wikipedia.org/wiki/Speck_%28cipher%29):
>
>         h1 ^= a;
>         h2 ^= h1; h1 = ROTL(h1, K);
>         h1 += h2; h2 *= 9;
>
> The "h2 *= 9" replaces "ROTL(h2, 3)" in Speck, achieves a little more
> mixing, is one cycle on most machines, and is probably supported by
> more functional units than a general barrel shift.
>
> It's only one more cycle on the critical path than the current
> "hash = (hash + a) * 9"... but it's one more register.

Try it.

I wouldn't worry too much about 32-bit x86 any more (we want ti to not
suck horribly, but it's not the primary target for anybody who cares
about best performance) any more. But x86-64 code generation is worth
looking at. The register pressure issue is still real, but it's not
quite as bad as the old 32-bit code.

The other main architectures that it would be good to verify are ok
are ARMv8 and powerpc.

> P.S. Here's a way to improve partial_name_hash on x86.
> Compare the assembly for
>
> unsigned long
> pnh1(unsigned long c, unsigned long prevhash)
> {
>         return (prevhash + (c << 4) + (c >> 4)) * 11;
> }
>
> pnh1:
>         movl    %eax, %ecx
>         shrl    $4, %eax
>         sall    $4, %ecx
>         addl    %ecx, %eax
>         addl    %eax, %edx
>         leal    (%edx,%edx,4), %eax
>         leal    (%edx,%eax,2), %eax
>         ret
>
> unsigned long
> pnh2(unsigned long c, unsigned long prevhash)
> {
>         prevhash += c <<= 4;
>         prevhash += c >> 8;
>         return prevhash * 11;
> }
>
> pnh2:
>         sall    $4, %eax
>         addl    %eax, %edx
>         shrl    $8, %eax
>         addl    %eax, %edx
>         leal    (%edx,%edx,4), %eax
>         leal    (%edx,%eax,2), %eax
>         ret
>
> pnh1 doesn't know that "c" is really only 8 bits and so it doesn't need
> to copy it to another register to compute the two shifted forms.

Well, if I cared about the partial_name_hash() (which I don't), I'd
suggest you just convince the compiler to generate

  rolb $4,%al

instead of two shifts, and just be done with it.

You might find that you end up with partial register write stalls,
though, so you might have to add a "movzbq %al,%rax" to get around
those.

In fact, it looks like you can get gcc to generate that code:

    unsigned long pnh3(unsigned char c, unsigned long prevhash)
    {
        c = (c << 4) | (c >> 4);
        return (prevhash + c)*11;
    }

generates

    pnh3:
        rolb $4, %dil
        movzbl %dil, %edi
        addq %rdi, %rsi
        leaq (%rsi,%rsi,4), %rax
        leaq (%rsi,%rax,2), %rax
        ret

which is one instruction less than your pnh2, but should perform even
better because I think "movzbl" ends up being done as a rename and
mask in the microarchitecture - without any actual ALU costs or added
latency.

But I suspect it can be a bit fragile to get gcc to actually generate
that rotate instruction. I could easily see that being inlined, and
than the pattern that turns into a rotate instruction gets perturbed
enough that gcc no longer generates the rot..

                  Linus
