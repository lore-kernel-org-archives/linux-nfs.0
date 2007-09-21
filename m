From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Fri, 21 Sep 2007 14:14:13 -0400
Message-ID: <1190398453.6690.12.camel@heimdal.trondhjem.org>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
	<1190335423.6763.180.camel@heimdal.trondhjem.org>
	<92cbf19b0709202012s375c6f54m588987b4bbf552bc@mail.gmail.com>
	<1190384005.6680.20.camel@heimdal.trondhjem.org>
	<92cbf19b0709210920p3647788dl11d8c4e0cee1f70f@mail.gmail.com>
	<1190391881.6680.73.camel@heimdal.trondhjem.org>
	<92cbf19b0709211106n12b1b4ecxc0d415aa097d21b2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Chakri n <chakriin5@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYn1D-0005cg-Kn
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 11:14:23 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IYn1G-0000xn-GO
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 11:14:28 -0700
In-Reply-To: <92cbf19b0709211106n12b1b4ecxc0d415aa097d21b2@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

No. The requirement for 'hard' mounts is not that the server be up all
the time. The server can go up and down as it pleases: the client can
happily recover from that.

The requirement is rather that nobody remove it permanently before the
application is done with it, and the partition is unmounted. That is
hardly unreasonable (it is the only way I know of to ensure data
integrity), and it is much less strict than the requirements for local
disks.

Trond

On Fri, 2007-09-21 at 11:06 -0700, Chakri n wrote:
> Isn't this a strict requirement from client side, asking to guarantee
> that a server stays up all the time?
> 
> I have seen many cases, where people go and directly change IP of
> their NFS filers or servers worrying least about the clients using
> them.
> 
> Can we get around with some sort of congestion logic?
> 
> Thanks
> --Chakri
> 
> On 9/21/07, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > On Fri, 2007-09-21 at 09:20 -0700, Chakri n wrote:
> > > Thanks.
> > >
> > > I was using flock (BSD locking) and I think the problem should be
> > > solved if I move my application to use POSIX locks.
> >
> > Yup.
> >
> > > And any option to avoid processes waiting indefinitely to free pages
> > > from NFS requests waiting on unresponsive NFS server?
> >
> > The only solution I know of is to use soft mounts, but that brings
> > another set of problems:
> >      1. most applications don't know how to recover safely from an EIO
> >         error.
> >      2. You lose data.
> >
> > Cheers
> >   Trond
> >

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
