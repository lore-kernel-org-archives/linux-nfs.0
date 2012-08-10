Return-Path: linux-nfs-owner@vger.kernel.org
Received: from terminus.zytor.com ([198.137.202.10]:54746 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754862Ab2HJXJy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Aug 2012 19:09:54 -0400
Message-ID: <50259494.8060304@zytor.com>
Date: Fri, 10 Aug 2012 16:09:08 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Trond.Myklebust@netapp.com, davem@davemloft.net,
        linux-nfs@vger.kernel.org, eric.dumazet@gmail.com, xemul@parallels.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, tim.c.chen@linux.intel.com, devel@openvz.org
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified root
References: <20120810125701.7115.71612.stgit@localhost.localdomain> <50254FA6.3060806@zytor.com> <20120810192628.79a34d28@pyramind.ukuu.org.uk> <20120810191149.GA17985@fieldses.org> <20120810202818.06236f46@pyramind.ukuu.org.uk>
In-Reply-To: <20120810202818.06236f46@pyramind.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2012 12:28 PM, Alan Cox wrote:
> Explicitly for Linux yes - this is not generally true of the AF_UNIX
> socket domain and even the permissions aspect isn't guaranteed to be
> supported on some BSD environments !

Yes, but let's worry about what the Linux behavior should be.

> The name is however just a proxy for the socket itself. You don't even
> get a device node in the usual sense or the same inode in the file system
> space.


No, but it is looked up the same way any other inode is (the difference
between FIFOs and sockets is that sockets have separate connections,
which is also why open() on sockets would be nice.)

However, there is a fundamental difference between AF_UNIX sockets and
open(), and that is how the pathname is delivered.  It thus would make
more sense to provide the openat()-like information in struct
sockaddr_un, but that may be very hard to do in a sensible way.  In that
sense it perhaps would be cleaner to be able to do an open[at]() on the
socket node with O_PATH (perhaps there should be an O_SOCKET option,
even?) and pass the resulting file descriptor to bind() or connect().

	-hpa



