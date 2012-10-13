Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:50421 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947Ab2JMCIn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Oct 2012 22:08:43 -0400
Message-ID: <5078CD16.6030201@panasas.com>
Date: Fri, 12 Oct 2012 19:08:22 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        Larry McVoy <lm@bitmover.com>, Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
References: <20121012211701.GA8301@bitmover.com> <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com> <20121013002100.GB23247@bitmover.com> <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com> <20121013013613.GA11272@umich.edu>
In-Reply-To: <20121013013613.GA11272@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/12/2012 06:36 PM, Jim Rees wrote:
> Linus Torvalds wrote:
> 
>   Doing a kernel compile really isn't that bad. The only nasty piece is
>   getting the kernel configuration right, but you can just use the
>   distro config. It's much too big and contains everything, but it will
>   work, and gets you as similar a kernel as possible. Of course, Ubuntu
>   has made installing your own kernel stupidly complicated (you have to
>   build a package and install it using the package manager), but while
>   it's an annoying extra step or two (compared to just doing a "make
>   modules_install install"), it's not rocket surgery.
> 
> I install kernels on Ubuntu every day of the week and twice on Sundays, and
> never jump through their silly hoops.  The only magic is making the
> initramfs, if you use one.
> 
> make install modules_install
> update-initramfs -c -k 3.6.1 (or whatever)

I thought "make install" is suppose to call a distro specific
driver script to do exactly that initramfs thing.

Some good sole should just fix it up on Broken ubuntu. I would
but I don't use ubuntu I use Fedora.

Just "which installkernel" usually /sbin/installkernel and fix
in there, I think.

> update-grub

And that too, it's a new grub2 thing, right

Cheers
Boaz
