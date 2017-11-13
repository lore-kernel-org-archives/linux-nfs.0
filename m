Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:38534 "EHLO
        mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdKMXa0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Nov 2017 18:30:26 -0500
MIME-Version: 1.0
In-Reply-To: <87efp1zsww.fsf_-_@rasmusvillemoes.dk>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com> <87efp1zsww.fsf_-_@rasmusvillemoes.dk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 13 Nov 2017 15:30:25 -0800
Message-ID: <CA+55aFz4qA2RhjW5KtD+=jnbW-9hoRGgDQ5N6DkQ5LCTkO5idA@mail.gmail.com>
Subject: Re: bit tweaks [was: Re: [nfsd4] potentially hardware breaking
 regression in 4.14-rc and 4.13.11]
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Patrick McLean <chutzpah@gentoo.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 13, 2017 at 2:59 PM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
>> Sadly, gcc makes a mess of it and actually generates code that looks
>> like the original C.[...]
>
> Actually, new enough gcc (7.1, I think) does contain a pattern that does
> this, but unfortunately only if one spells it
>
>   y |= (x & BIT) ? OTHER_BIT : 0;

Ahh, I should have recognized that, I think that's what we ended up
doing with the VM_READ -> PROT_READ translation in a few places,
exactly because gcc would then recognize it and do the much better
code generation.

> which is half-way to doing it by hand, I suppose.

Yeah, but it is at least acceptable, and the code is still legible C.
The alternatives of doing it _entirely_ by hand tend to be much worse
(ie you end up using a macro from hell that checks which of the two
bits are bigger and shifting in the right direction by using
multiplication or division).

So let's just rewrite that mnt_flags conversion that way, justr to get
gcc to generate the obvious code.

It's a bit sad how gcc didn't pick up on the original code, especially
since it had already done the much more complicated translation of
doing the if-conversion.

Thanks for pointing out the gcc pattern.

          Linus
