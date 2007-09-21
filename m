From: "Chakri n" <chakriin5@gmail.com>
Subject: Re: [NFS] NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 11:06:13 -0700
Message-ID: <92cbf19b0709211106n12b1b4ecxc0d415aa097d21b2@mail.gmail.com>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	 <1190335423.6763.180.camel@heimdal.trondhjem.org>
	 <92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
	 <1190384005.6680.20.camel@heimdal.trondhjem.org>
	 <92cbf19b0709210920p3647788dl11d8c4e0cee1f70f@mail.gmail.com>
	 <1190391881.6680.73.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761617AbXIUSG0@vger.kernel.org>
In-Reply-To: <1190391881.6680.73.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Isn't this a strict requirement from client side, asking to guarantee
that a server stays up all the time?

I have seen many cases, where people go and directly change IP of
their NFS filers or servers worrying least about the clients using
them.

Can we get around with some sort of congestion logic?

Thanks
--Chakri

On 9/21/07, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Fri, 2007-09-21 at 09:20 -0700, Chakri n wrote:
> > Thanks.
> >
> > I was using flock (BSD locking) and I think the problem should be
> > solved if I move my application to use POSIX locks.
>
> Yup.
>
> > And any option to avoid processes waiting indefinitely to free pages
> > from NFS requests waiting on unresponsive NFS server?
>
> The only solution I know of is to use soft mounts, but that brings
> another set of problems:
>      1. most applications don't know how to recover safely from an EIO
>         error.
>      2. You lose data.
>
> Cheers
>   Trond
>
