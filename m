Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:58388 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842Ab2JMBDS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 21:03:18 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so2853549wgb.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Oct 2012 18:03:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121013002100.GB23247@bitmover.com>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 13 Oct 2012 10:02:56 +0900
Message-ID: <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Larry McVoy <lm@bitmover.com>, Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 9:21 AM, Larry McVoy <lm@bitmover.com> wrote:
>
> Ahh, I've been away from the kernel too long.  I miss that delicate
> management touch.

"Delicate Management Touch" is my middle name.

> pics of the stack trace at http://www.mcvoy.com/lm/nfs-lock-crash

Ok, that's just the normal kind of random left-over oopses due to
subsequent problems of a BUG_ON(). Looks like the watchdog timer ends
up being unhappy, almost certainly simply because some core filesystem
spinlock not being released.

It used to be (a long long time ago) that we'd recover fairly
gracefully from BUG_ON()'s - back when the main shared lock we had was
the kernel lock, and we had a single per-process kernel lock counter.
So when we killed the process, we could clean that single lock up.

These days, if some process dies in random kernel code due to a
BUG_ON() or a wild pointer or similar, and we kill it, we are seldom
able to do so cleanly. So the best we can hope for is that it happened
in some context where it held no (important) locks. Which is rare. So
BUG_ON()'s are often fatal, and there are these kinds of downstream
problems where they get flushed off the screen by subsequent issues...

Ho humm. Google doesn't seem to be finding any similar bug-reports, so
unless Bruce or Trond go "Ahh, I know what it's about", I do think we
would want to get as much more info as possible.

Doing a kernel compile really isn't that bad. The only nasty piece is
getting the kernel configuration right, but you can just use the
distro config. It's much too big and contains everything, but it will
work, and gets you as similar a kernel as possible. Of course, Ubuntu
has made installing your own kernel stupidly complicated (you have to
build a package and install it using the package manager), but while
it's an annoying extra step or two (compared to just doing a "make
modules_install install"), it's not rocket surgery. There's a few help
pages for it:

    https://help.ubuntu.com/community/Kernel/Compile

being the first one.

                Linus
