From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 05/38: CLIENT: change CONFIG_NFS_V3 to CONFIG_NFS_V3 ||
 CONFIG_NFS_V4
Date: Tue, 13 Aug 2002 18:57:59 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131857300.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekbx-0000vv-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 15:58:02 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


In a number of places in the NFS client, I had to change

  #ifdef CONFIG_NFS_V3
     /* ... */
  #endif

to

  #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
     /* ... */
  #endif

This is a trivial patch which collects all changes of this type.

--- old/fs/nfs/flushd.c	Mon Jul 29 22:36:09 2002
+++ new/fs/nfs/flushd.c	Mon Jul 29 11:50:09 2002
@@ -171,7 +171,7 @@ nfs_flushd(struct rpc_task *task)
 			nfs_pagein_list(&head, server->rpages);
 			continue;
 		}
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (nfs_scan_lru_commit_timeout(server, &head)) {
 			spin_unlock(&nfs_wreq_lock);
 			nfs_commit_list(&head, FLUSH_AGING);
--- old/fs/nfs/pagelist.c	Mon Jul 29 22:36:09 2002
+++ new/fs/nfs/pagelist.c	Mon Jul 29 16:04:10 2002
@@ -458,7 +458,7 @@ nfs_try_to_free_pages(struct nfs_server
 			continue;
 		}

-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		/* Let's try to free up some completed NFSv3 unstable writes */
 		nfs_scan_lru_commit(server, &head);
 		if (!list_empty(&head)) {
--- old/fs/nfs/write.c	Mon Jul 29 22:36:09 2002
+++ new/fs/nfs/write.c	Mon Jul 29 22:34:26 2002
@@ -88,7 +88,7 @@ static struct nfs_page * nfs_update_requ
 					    unsigned int, unsigned int);
 static void	nfs_strategy(struct inode *inode);
 static void	nfs_writeback_done(struct rpc_task *);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void	nfs_commit_done(struct rpc_task *);
 #endif

@@ -414,7 +414,7 @@ nfs_dirty_request(struct nfs_page *req)
 	return !list_empty(&req->wb_list) && req->wb_list_head == &nfsi->dirty;
 }

-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
  */
@@ -554,7 +554,7 @@ nfs_scan_dirty(struct inode *inode, stru
 	return res;
 }

-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /**
  * nfs_scan_lru_commit_timeout - Scan LRU list for timed out commit requests
  * @server: NFS superblock data
@@ -749,7 +749,7 @@ nfs_strategy(struct inode *inode)

 	dirty  = NFS_I(inode)->ndirty;
 	wpages = NFS_SERVER(inode)->wpages;
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (NFS_PROTO(inode)->version == 2) {
 		if (dirty >= NFS_STRATEGY_PAGES * wpages)
 			nfs_flush_file(inode, NULL, 0, 0, 0);
@@ -1027,7 +1027,7 @@ nfs_writeback_done(struct rpc_task *task
 		 * an error. */
 		task->tk_status = -EIO;
 	}
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1077,7 +1077,7 @@ nfs_writeback_done(struct rpc_task *task
 			goto next;
 		}

-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (argp->stable != NFS_UNSTABLE || resp->verf->committed == NFS_FILE_SYNC) {
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
@@ -1096,7 +1096,7 @@ nfs_writeback_done(struct rpc_task *task
 }


-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Set up the argument/result storage required for the RPC call.
  */
@@ -1260,7 +1260,7 @@ int nfs_flush_file(struct inode *inode,
 	return res;
 }

-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 int nfs_commit_file(struct inode *inode, struct file *file, unsigned long idx_start,
 		    unsigned int npages, int how)
 {
@@ -1297,7 +1297,7 @@ int nfs_sync_file(struct inode *inode, s
 			error = nfs_wait_on_requests(inode, file, idx_start, npages);
 		if (error == 0)
 			error = nfs_flush_file(inode, file, idx_start, npages, how);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (error == 0)
 			error = nfs_commit_file(inode, file, idx_start, npages, how);
 #endif
--- old/include/linux/nfs_fs.h	Mon Jul 29 22:36:09 2002
+++ new/include/linux/nfs_fs.h	Mon Jul 29 22:37:00 2002
@@ -303,7 +303,7 @@ extern int  nfs_flush_file(struct inode
 extern int  nfs_flush_list(struct list_head *, int, int);
 extern int  nfs_scan_lru_dirty(struct nfs_server *, struct list_head *);
 extern int  nfs_scan_lru_dirty_timeout(struct nfs_server *, struct list_head *);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_file(struct inode *, struct file *, unsigned long, unsigned int, int);
 extern int  nfs_commit_list(struct list_head *, int);
 extern int  nfs_scan_lru_commit(struct nfs_server *, struct list_head *);



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
