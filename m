From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: [NFS] NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 09:20:06 -0700
Message-ID: <92cbf19b0709210920p3647788dl11d8c4e0cee1f70f@mail.gmail.com>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	 <1190335423.6763.180.camel@heimdal.trondhjem.org>
	 <92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
	 <1190384005.6680.20.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761178AbXIUQUZ@vger.kernel.org>
In-Reply-To: <1190384005.6680.20.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Thanks.

I was using flock (BSD locking) and I think the problem should be
solved if I move my application to use POSIX locks.

And any option to avoid processes waiting indefinitely to free pages
from NFS requests waiting on unresponsive NFS server?

Thanks
--Chakri

On 9/21/07, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2007-09-20 at 20:12 -0700, Chakri n wrote:
> > Thanks Trond, for clarifying this for me.
> >
> > I have seen similar behavior when a remote NFS server is not
> > available. Many processes wait end up waiting in nfs_release_page. So,
> > what will happen if the remote server is not available,
> > nfs_release_page cannot free the memory since it waits on rpc request
> > to complete, which never completes and processes wait in there for
> > ever?
> >
> > And unfortunately in my case, I cannot use "mount --bind". I want to
> > use the same file system from two different nodes, and I want file &
> > record locking to be consistent. The only way to make sure locking is
> > consistent is to use loopback NFS on 1 host and NFS mount the same
> > file system on other nodes, so that NFS server ensures file & record
> > locking to be consistent. Is there any alternative to this?
> >
> > Is it possible or any efforts to integrate ext3 or other local file
> > systems locking & network file system locking, so that user can use
> > "mount --bind" on local host and NFS mount on remote nodes, but file &
> > record locking will be consistent between both the nodes?
>
> Could you be a bit more specific? Is the problem that your application
> is using BSD locks (flock()) instead of POSIX locks?
>
> Cheers
>    Trond
>
