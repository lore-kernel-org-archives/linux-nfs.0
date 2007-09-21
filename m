From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 12:24:41 -0400
Message-ID: <1190391881.6680.73.camel@heimdal.trondhjem.org>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	 <1190335423.6763.180.camel@heimdal.trondhjem.org>
	 <92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
	 <1190384005.6680.20.camel@heimdal.trondhjem.org>
	 <92cbf19b0709210920p3647788dl11d8c4e0cee1f70f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Chakri n <chakriin5@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761311AbXIUQYx@vger.kernel.org>
In-Reply-To: <92cbf19b0709210920p3647788dl11d8c4e0cee1f70f@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2007-09-21 at 09:20 -0700, Chakri n wrote:
> Thanks.
> 
> I was using flock (BSD locking) and I think the problem should be
> solved if I move my application to use POSIX locks.

Yup.

> And any option to avoid processes waiting indefinitely to free pages
> from NFS requests waiting on unresponsive NFS server?

The only solution I know of is to use soft mounts, but that brings
another set of problems:
     1. most applications don't know how to recover safely from an EIO
        error.
     2. You lose data.

Cheers
  Trond
