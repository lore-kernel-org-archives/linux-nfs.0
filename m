From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS - Fix for Infinite loop during syncing
Date: Mon, 13 Dec 2004 19:14:36 -0500
Message-ID: <41BE306C.2020804@RedHat.com>
References: <41BDFA46.7070403@RedHat.com> <1102970704.15627.8.camel@lade.trondhjem.org> <41BE0789.8070001@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070904090905000702080602"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ce0Gb-0004cD-NA
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 16:10:13 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Ce0Gb-0007gz-01
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 16:10:13 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <41BE0789.8070001@RedHat.com>
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
--------------070904090905000702080602
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:

> Now that I think about it... probably makes sense to set NFS_INO_STALE in
> nfs_commit_done() as well... From my debugging, it just seems the 
> earlier we
> break the inode... the better....

I liked this idea some much that here is the patch for it... I really do 
think
the sooner we know an inode is broken... the better...

steved.

--------------070904090905000702080602
Content-Type: text/plain;
 name="linux-2.4.28-nfs-syncloop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.28-nfs-syncloop.patch"

--- linux-2.4.28/fs/nfs/write.c.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.28/fs/nfs/write.c	2004-12-13 19:04:23.000000000 -0500
@@ -1073,6 +1073,9 @@ nfs_writeback_done(struct rpc_task *task
 			SetPageError(page);
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
+			if (task->tk_status == -ESTALE)
+				NFS_FLAGS(inode) |= NFS_INO_STALE;
+
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
 			goto next;
@@ -1223,6 +1226,9 @@ nfs_commit_done(struct rpc_task *task)
 		if (task->tk_status < 0) {
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
+			if (task->tk_status == -ESTALE)
+				NFS_FLAGS(inode) |= NFS_INO_STALE;
+
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
 			goto next;

--------------070904090905000702080602--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
