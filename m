From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS - Missing unlock_kernel() in lookup path
Date: Mon, 01 Aug 2005 14:00:37 -0400
Message-ID: <42EE6345.90505@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060500020500080802050202"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dzeak-0006hd-K2
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 11:00:46 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dzeak-0001PO-FF
	for nfs@lists.sourceforge.net; Mon, 01 Aug 2005 11:00:46 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------060500020500080802050202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hey Trond,

I was backport some patches and noticed that nfs_atomic_lookup()
seems to be missing an unlock_kernel()... I would think that
nfs_atomic_lookup() should unlock_kernel() when nfs_revalidate_inode()
fails... true?

steved.


--------------060500020500080802050202
Content-Type: text/x-patch;
 name="linux-2.6.12.3-nfs-missing-lock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.12.3-nfs-missing-lock.patch"

Added missing unlock_kernel() to NFS lookup patch.

Signed-off-by: Steve Dickson <steved@redhat.com>
-----------------------------------------------
--- linux-2.6.12.3/fs/nfs/dir.c.orig	2005-07-15 17:18:57.000000000 -0400
+++ linux-2.6.12.3/fs/nfs/dir.c	2005-08-01 13:46:19.000000000 -0400
@@ -835,6 +835,7 @@ static struct dentry *nfs_atomic_lookup(
 	error = nfs_revalidate_inode(NFS_SERVER(dir), dir);
 	if (error < 0) {
 		res = ERR_PTR(error);
+		unlock_kernel();
 		goto out;
 	}
 

--------------060500020500080802050202--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
