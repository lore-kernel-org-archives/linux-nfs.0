From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Implementing nfs in vfs
Date: Thu, 24 May 2007 09:54:37 -0400
Message-ID: <1180014877.6413.38.camel@heimdal.trondhjem.org>
References: <359369180705240404s2887d881uf591119b6397683d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Suraj Jacob <suraj.email@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HrDm5-0001Cx-3N
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:54:41 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX181JFYeaPff1pcJcbV26/aZi8dAuZuABAM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HrDm7-0005cq-Jh
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 06:54:44 -0700
In-Reply-To: <359369180705240404s2887d881uf591119b6397683d@mail.gmail.com>
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

On Thu, 2007-05-24 at 16:34 +0530, Suraj Jacob wrote:
> Hi,
> Please forgive me if this is a naive question or if it does not belong
> to this list.
> 
> All the nfs implementations that Ive seen are always on top of local
> filesystems. Why is it that there is no implementation that could
> bypass the local fs like ext2 and implement a vfs layer for nfs? or
> eliminate vfs too and write a server operating on raw disks(like some
> databases do for performance)? 

1) The NFS server _IS_ written to use the VFS. There are no calls
directly into the ext2/ext3/reiserfs/xfs filesystems.

2) The NFS protocol has filesystem semantics. If you want raw disk
semantics, then you should be using a different protocol (probably iSCSI
or FCP).

  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
