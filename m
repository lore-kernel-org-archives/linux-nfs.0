Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41117 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751938Ab2HMSYn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 14:24:43 -0400
Date: Mon, 13 Aug 2012 14:24:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Pavel Emelianov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>,
        Alan Cox <alan@lxorguk.ukuu.org.uk>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "tim.c.chen@linux.intel.com" <tim.c.chen@linux.intel.com>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [RFC PATCH 0/2] net: connect to UNIX sockets from specified
 root
Message-ID: <20120813182431.GA4234@fieldses.org>
References: <20120810125701.7115.71612.stgit@localhost.localdomain>
 <50254FA6.3060806@zytor.com>
 <20120810192628.79a34d28@pyramind.ukuu.org.uk>
 <20120810191149.GA17985@fieldses.org>
 <20120810202818.06236f46@pyramind.ukuu.org.uk>
 <50259494.8060304@zytor.com>
 <5025FA5A.4090403@parallels.com>
 <50263ECC.4060501@parallels.com>
 <20120813164730.GB2497@fieldses.org>
 <50293BE9.3010408@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50293BE9.3010408@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 13, 2012 at 09:39:53PM +0400, Stanislav Kinsbursky wrote:
> 13.08.2012 20:47, J. Bruce Fields пишет:
> >On Sat, Aug 11, 2012 at 03:15:24PM +0400, Stanislav Kinsbursky wrote:
> >>11.08.2012 10:23, Pavel Emelyanov пишет:
> >>>On 08/11/2012 03:09 AM, H. Peter Anvin wrote:
> >>>>On 08/10/2012 12:28 PM, Alan Cox wrote:
> >>>>>Explicitly for Linux yes - this is not generally true of the AF_UNIX
> >>>>>socket domain and even the permissions aspect isn't guaranteed to be
> >>>>>supported on some BSD environments !
> >>>>Yes, but let's worry about what the Linux behavior should be.
> >>>>
> >>>>>The name is however just a proxy for the socket itself. You don't even
> >>>>>get a device node in the usual sense or the same inode in the file system
> >>>>>space.
> >>>>No, but it is looked up the same way any other inode is (the difference
> >>>>between FIFOs and sockets is that sockets have separate connections,
> >>>>which is also why open() on sockets would be nice.)
> >>>>
> >>>>However, there is a fundamental difference between AF_UNIX sockets and
> >>>>open(), and that is how the pathname is delivered.  It thus would make
> >>>>more sense to provide the openat()-like information in struct
> >>>>sockaddr_un, but that may be very hard to do in a sensible way.  In that
> >>>>sense it perhaps would be cleaner to be able to do an open[at]() on the
> >>>>socket node with O_PATH (perhaps there should be an O_SOCKET option,
> >>>>even?) and pass the resulting file descriptor to bind() or connect().
> >>>I vote for this (openat + O_WHATEVER on a unix socket) as well. It will
> >>>help us in checkpoint-restore, making handling of overmounted/unlinked
> >>>sockets much cleaner.
> >>I have to notice, that it's not enough and doesn't solve the issue.
> >>There should be some way how to connect/bind already existent unix
> >>socket (from kernel, at least), because socket can be created in
> >>user space.
> >>And this way (sock operation or whatever) have to provide an ability
> >>to lookup UNIX socket starting from specified root to support
> >>containers.
> >I don't understand--the rpcbind sockets are created by the kernel.  What
> >am I missing?
> 
> Kernel preform connect to rpcbind socket (i.e. user-space binds it),
> doesn't it?

I'm confused, possibly because there are three "sockets" here: the
client-side socket that's connected, the server-side socket that's
bound, and the common object that exists in the filesystem namespace.

Userland creates the server-side socket and binds to it.  All of that is
done in the context of the rpcbind process, so is created in rpcbind's
namespace.  That should be OK, right?

The client side socket is created and connected in
xs_local_setup_socket().

Making sure they both end up with the same thing is a matter of making
sure they lookup the same path in the same namespace.  The difficult
part of that is the in-kernel client-side socket connect, where we don't
have the right process context any more.

We currently set that up with __sock_create followed by
kernel_connect.

The proposal seems to be to instead do an openat followed by a
kernel_connect, and pass the path in the openat instead of the connect.

(Though in the kernel we won't be able to call openat, so we'll end up
doing something like nfsd does (calling lookup_one_len() and
dentry_open() by hand).)

Have I got all that right?

I don't know if that's better just calling into the unix socket code at
connect time as your patch does.  Maybe the answer depends on whether
it's a priority to make this functionality available to userspace.

--b.
