Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hygieia.santi-shop.eu ([78.46.175.2]:39975 "EHLO
	hygieia.santi-shop.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932593AbbBDVwf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 16:52:35 -0500
Date: Wed, 4 Feb 2015 22:52:30 +0100
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [Patch] sunrpc: NULL utsname dereference on NFS umount during
 namespace cleanup
Message-ID: <20150204225230.2cc2749d@uranus>
In-Reply-To: <CAHQdGtT8OKR2hbZzpTOAYbtW1V7J0cSctxVfYq8QqobLcvGyhQ@mail.gmail.com>
References: <20150125220604.090121ae@neptune.home>
	<CAHQdGtSNmera4P6ocFGbLhjmESB8oV9zKE_x_zTm=5qUg7e7Ug@mail.gmail.com>
	<1422661761.21259.5.camel@primarydata.com>
	<20150204180833.4d4a22cf@neptune.home>
	<CAHQdGtT8OKR2hbZzpTOAYbtW1V7J0cSctxVfYq8QqobLcvGyhQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Feb 2015 14:06:48 Trond Myklebust wrote:
> On Wed, Feb 4, 2015 at 12:08 PM, Bruno Prémont wrote:
> > On Fri, 30 January 2015 Trond Myklebust wrote:
> > > On Sun, 2015-01-25 at 16:55 -0500, Trond Myklebust wrote:
> > > > On Sun, Jan 25, 2015 at 4:06 PM, Bruno Prémont wrote:
> > > > > On a system running home-brown container (mntns, utsns,
> > > > > pidns, netns) with NFS mount-point bind-mounted into the
> > > > > container I hit the following trace if nfs filesystem is
> > > > > first umount()ed in init ns and then later umounted from
> > > > > container when the container exists.
> > > > >
> > > > > <snip trace>
> > > >
> > > > We should rather change rpcb_create() to pass the nodename from
> > > > the parent. The point is that the rpc_clnt->cl_nodename is used
> > > > in various different contexts (for instance in the AUTH_SYS
> > > > credential) where it isn't always appropriate to have it set to
> > > > an empty string.
> > >
> > > I was rather hoping that Bruno would fix up his patch and resend,
> > > but since other reports of the same bug are now surfacing...
> > > Please could you all check if something like the following patch
> > > fixes it.
> >
> > This patch works for me, so
> >   Tested-by: Bruno Prémont <bonbons@linux-vserver.org>
> >
> > Now I get just the following complaint in dmesg on shutdown:
> >   [ 1940.173201] lockd: cannot unmonitor nfs.home
> >                                          ^^^^^^^^  name of NFS
> > server
> >
> > This complaint did not happen with my "empty string" name
> > patch.
> 
> Are there any clues from rpc.statd in your syslog that might help to
> explain the error?

I would say there is no more running rpc.statd at that time.

My shutdown process looks about as follows (it's not necessarily the
optimal ordering):

- umount nfs mountpoints from root mntns
- stop nfsclient
- stop rpc.statd
- stop rpcbind
- stop containers (with bind-mounted nfs mountpoints from root mntns
    that get implicitly umounted on mntns release)

Bruno
