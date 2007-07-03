From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Unlocked pages flushed
Date: Mon, 02 Jul 2007 20:53:55 -0400
Message-ID: <1183424035.6479.27.camel@heimdal.trondhjem.org>
References: <loom.20070702T122224-68@post.gmane.org>
	<1183379648.6479.7.camel@heimdal.trondhjem.org>
	<loom.20070702T150607-90@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Rajat <sharma.rajat@hcl.in>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5Web-0005D1-D6
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 17:54:05 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/uMondhngp8t2ASGCiGcafK5zR1HGXf9I=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I5Wec-00009A-72
	for nfs@lists.sourceforge.net; Mon, 02 Jul 2007 17:54:06 -0700
In-Reply-To: <loom.20070702T150607-90@post.gmane.org>
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

On Mon, 2007-07-02 at 13:24 +0000, Rajat wrote:
> Yes I missed out on this. page lock is sleeping on bit. But then if ABBA 
> deadlock is not the case, why pages are being flushed unlocked? I mean is it 
> not required to lock these pages before flushing? In that case it should be 
> safe to place page_lock loop to wait on any pending work on these pages. 

The only VM requirement is that the pages be locked when you set the
PG_writeback flag. This is already the case in recent kernels.

Otherwise, NFS manages its own locking scheme on the nfs_page.

> Also there is one more spinlock in the scene, nfs_inode->req_lock and spinning 
> for this lock should not release BKL. I am assuming that lock ordering of BKL 
> and req_lock is maintained. 

Whenever necessary, the BKL is taken before we take the req_lock. There
are AFAIK no cases where we take the BKL while we are holding the
req_lock.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
