From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: inconsistent mount attributes (ro/rw), RHEL5 / Netapp
Date: Mon, 14 May 2007 12:06:14 -0400
Message-ID: <1179158774.6474.18.camel@heimdal.trondhjem.org>
References: <4627B3DD.5050409@amd.com>
	<1177007479.6623.14.camel@heimdal.trondhjem.org>
	<4627D303.8060009@amd.com>
	<1177020662.6628.30.camel@heimdal.trondhjem.org>
	<4627EBFC.2090704@amd.com>
	<462CFC92.2080201@amd.com> <463B97E6.4030009@amd.com>
	<1178314889.6533.19.camel@heimdal.trondhjem.org>
	<1178379473.4559.24.camel@raven.themaw.net>
	<1178385472.6561.43.camel@heimdal.trondhjem.org>
	<20070514131743.GG31764@petra.dvoda.cz>
	<1179149048.6858.5.camel@heimdal.trondhjem.org>
	<1179153555.3811.57.camel@raven.themaw.net>
	<1179157631.6474.8.camel@heimdal.trondhjem.org>
	<46488696.9080009@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Ian Kent <raven@themaw.net>
To: Paul Krizak <paul.krizak@amd.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hnd3z-0007CQ-Vw
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:06:20 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hnd42-0001LA-JM
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 09:06:22 -0700
In-Reply-To: <46488696.9080009@amd.com>
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

On Mon, 2007-05-14 at 10:56 -0500, Paul Krizak wrote:
> > We might then be able to add an '--unshared-cache' option (any
>  > suggestions for a better name?) to mount in order to allow those people
>  > who fully understand the consequences to override, and hence to mount
>  > the same filesystem with different mount options, but no sharing of the
>  > page cache with the original filesystem.
> 
> I can assure you that AMD systems engineering would *much* prefer having 
> the VFS stack fixed such that we don't need to do something like this.
> 
> It would be much better to make the kernel understand that it *can* 
> mount the same NFS filesystem twice, once read-only and again 
> read-write, with the appropriate cache coherency, rather than force us 
> to run in a potentially dangerous configuration that might lead to data 
> corruption.
> 
> I agree with Ian that the VFS changes need to take priority.  The only 
> change I see that needs to be made to mount is that it needs to spit out 
> a warning (or fail completely) if the requested options cannot be satisfied.

I agree that the read-only flag need to be fixed at the VFS level. I
wasn't talking about that.

I'm talking about people who want to force different security flavours
on different paths for the same filesystem, or who want to set different
rsize/wsize, attribute timeouts etc. There are applications that might
benefit from that, and that do not care about sharing caches (either
because they know that there are no cross-linked files, or because they
are using a locking system that can deal with the cache consistency
issue).

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
