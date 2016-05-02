Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35595 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbcEBQYX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 12:24:23 -0400
MIME-Version: 1.0
In-Reply-To: <20160502102016.17936.qmail@ns.horizon.com>
References: <alpine.DEB.2.11.1605020908080.3692@nanos>
	<20160502102016.17936.qmail@ns.horizon.com>
Date: Mon, 2 May 2016 09:24:21 -0700
Message-ID: <CA+55aFx2O-ptJa2Xt4mYUbO-b0z9XSf-wEw97Gyj1h3porFC_g@mail.gmail.com>
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
From: Linus Torvalds <torvalds@linux-foundation.org>
To: George Spelvin <linux@horizon.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Bruce Fields <bfields@fieldses.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Rik van Riel <riel@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 2, 2016 at 3:20 AM, George Spelvin <linux@horizon.com> wrote:
>
> After a careful scan through the kernel code, no caller asks any of
> those four for  more than 32 bits of hash result, except that the
> latter two need 64 bits from hash_long() if BITS_PER_LONG == 64.

Ugh. I hate this patch.

I really think that we should *not* convuse those two odd svcauth.h
users with the whole hash_32/64 thing.

I think  hash_str/hash_mem should be moved to lib/hash.c, and they
just shouldn't use "hash_long()" at all, except at the verty end (they
currently have a very odd way of doing "every <n> bytes _and_ at the
end".

In particular, the hashing in the *middle* is very different from the
hashing at the end.

At the end, you need to make sure the lower bits get spread out
particularly to the upper bits, since you're going to shift things
down.

But in the middle, you just want to spread the bits out (and in
particular, destroy any byte-per-byte patterns that it build it in
between).

Quite frankly, I think those functions should just use something like
the FNV hash (or Jenkins hash), and then maybe use "hash_long()" at
the *end* to shift the result down to "bits".

I don't want to make our <linux/hash.h> odder just because of two
entirely broken users.

That said, I actually think hash_str() should be killed entirely.
Better just use what we use for pathnames: full_name_hash() (which
gets a pointer and length) and hash_name (which gets the string).

Those functions do the "word-at-a-time" optimization, and they should
do a good enough job. If they aren't, we should fix them, because they
are a hell of a lot more important than anything that the svcauth code
does.

                Linus
