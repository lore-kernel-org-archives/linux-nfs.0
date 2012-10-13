Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35389 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752987Ab2JMBqD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 21:46:03 -0400
Received: by mail-wi0-f172.google.com with SMTP id hq12so53999wib.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Oct 2012 18:46:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121013013613.GA11272@umich.edu>
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
 <20121013013613.GA11272@umich.edu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 13 Oct 2012 10:45:40 +0900
Message-ID: <CA+55aFzQWw-rv76VX2=2MpFf3-ZMFtzVcps-PQsXO6cOG+4tBg@mail.gmail.com>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
To: Jim Rees <rees@umich.edu>
Cc: Larry McVoy <lm@bitmover.com>, Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 13, 2012 at 10:36 AM, Jim Rees <rees@umich.edu> wrote:
>
> I install kernels on Ubuntu every day of the week and twice on Sundays, and
> never jump through their silly hoops.  The only magic is making the
> initramfs, if you use one.
>
> make install modules_install
> update-initramfs -c -k 3.6.1 (or whatever)
> update-grub

This magic is what the distro "/usr/sbin/installkernel" script is
supposed to do, which the kernel Makefile does for the "install"
target.

So the "make install" *should* have done the grub and initramfs
update. Ubuntu screwed up (probably because Debian did).

I wish they'd just fix it.  The whole reason the kernel does that
/usr/sbin/installkernel thing is so that distributions can do whatever
magic it is they want to do for themselves.

              Linus
