Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38410 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953AbcEBVlL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 17:41:11 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFx441ZBAj6DUXVqEOzBjh9v32F1r2rD-PF2BRpA92fFkg@mail.gmail.com>
References: <CA+55aFx2O-ptJa2Xt4mYUbO-b0z9XSf-wEw97Gyj1h3porFC_g@mail.gmail.com>
	<20160502202637.13861.qmail@ns.horizon.com>
	<CA+55aFx441ZBAj6DUXVqEOzBjh9v32F1r2rD-PF2BRpA92fFkg@mail.gmail.com>
Date: Mon, 2 May 2016 14:41:10 -0700
Message-ID: <CA+55aFyZeDDgSisoLT8Hz49yw6xedOa-QLB8EUBCu-O-_HKZwg@mail.gmail.com>
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

On Mon, May 2, 2016 at 2:19 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The reason that "hash_len" is a single 64-bit field rather than two
> 32-bit fields, for example, is that that way it takes on _register_
> when we do the has lookup. Some of that code was tuned to inline - and
> _not_ inline in particular patterns.

Actually, I think the tuning for no stack frame etc was mostly for the
permission testing with the selinux AVC code.

The filename hashing does have some of it too - like making sure that
the call to ->d_hash() is in an unlikely path etc and doesn't pollute
the case that actually matters. But I don't think any of it is simple
enough to avoid a stack frame.

The hash_len thing did make the innermost hash lookup loop smaller,
which was noticeable at some point.

What I really wanted to do there was actually have a direct-mapped "L1
dentry hash cache", that didn't have a hash loop at all (it would fall
back to the slow case for that). I had a patch for that (which worked
*beautifully*, partly because it also moved the hot entries to that
hash cache and thus effectively moved the active entries to the head
of the queue), but I couldn't get the L1 cache update to be coherent
without locking, which killed the thing.

Anyway, I suspect that your mixing function changes should be fine.
That link_path_walk() is important, but a couple of shifts and xors
shouldn't kill it.

             Linus
