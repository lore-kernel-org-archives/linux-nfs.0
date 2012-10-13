Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:57390 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940Ab2JMBg3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Oct 2012 21:36:29 -0400
Date: Fri, 12 Oct 2012 21:36:14 -0400
From: Jim Rees <rees@umich.edu>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Larry McVoy <lm@bitmover.com>, Bruce Fields <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121013013613.GA11272@umich.edu>
References: <20121012211701.GA8301@bitmover.com>
 <CA+55aFymSQYnutQgv0B2yXHL00hHs-3UZZGEXVik18QUdPTgyg@mail.gmail.com>
 <20121013002100.GB23247@bitmover.com>
 <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFwKn+rp4qTk3dLgN8n=M-Aw1GYYpOfevDJaJhnK-U5VOg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Linus Torvalds wrote:

  Doing a kernel compile really isn't that bad. The only nasty piece is
  getting the kernel configuration right, but you can just use the
  distro config. It's much too big and contains everything, but it will
  work, and gets you as similar a kernel as possible. Of course, Ubuntu
  has made installing your own kernel stupidly complicated (you have to
  build a package and install it using the package manager), but while
  it's an annoying extra step or two (compared to just doing a "make
  modules_install install"), it's not rocket surgery.

I install kernels on Ubuntu every day of the week and twice on Sundays, and
never jump through their silly hoops.  The only magic is making the
initramfs, if you use one.

make install modules_install
update-initramfs -c -k 3.6.1 (or whatever)
update-grub
