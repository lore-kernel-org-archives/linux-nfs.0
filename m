From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 2/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 01:08:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.25957.505052.523038@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z3Sl-0004Ag-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 16:08:27 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

In a number of places in the NFS client, I had to change

  #ifdef CONFIG_NFS_V3
     /* ... */
  #endif

to

  #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
     /* ... */
  #endif

diff -u --recursive --new-file linux-2.5.41-nfsv4-E01/fs/nfs/flushd.c linux-2.5.41-nfsv4-E02/fs/nfs/flushd.c
--- linux-2.5.41-nfsv4-E01/fs/nfs/flushd.c	2002-02-26 16:56:28.000000000 -0500
+++ linux-2.5.41-nfsv4-E02/fs/nfs/flushd.c	2002-10-08 18:43:11.000000000 -0400
@@ -171,7 +171,7 @@
 			nfs_pagein_list(&head, server->rpages);
 			continue;
 		}
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (nfs_scan_lru_commit_timeout(server, &head)) {
 			spin_unlock(&nfs_wreq_lock);
 			nfs_commit_list(&head, FLUSH_AGING);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E01/fs/nfs/pagelist.c linux-2.5.41-nfsv4-E02/fs/nfs/pagelist.c
--- linux-2.5.41-nfsv4-E01/fs/nfs/pagelist.c	2002-10-08 18:42:48.000000000 -0400
+++ linux-2.5.41-nfsv4-E02/fs/nfs/pagelist.c	2002-10-08 18:43:11.000000000 -0400
@@ -507,7 +507,7 @@
 			continue;
 		}
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		/* Let's try to free up some completed NFSv3 unstable writes */
 		nfs_scan_lru_commit(server, &head);
 		if (!list_empty(&head)) {
diff -u --recursive --new-file linux-2.5.41-nfsv4-E01/fs/nfs/write.c linux-2.5.41-nfsv4-E02/fs/nfs/write.c
--- linux-2.5.41-nfsv4-E01/fs/nfs/write.c	2002-10-04 11:28:35.000000000 -0400
+++ linux-2.5.41-nfsv4-E02/fs/nfs/write.c	2002-10-08 18:43:11.000000000 -0400
@@ -88,7 +88,7 @@
 					    unsigned int, unsigned int);
 static void	nfs_strategy(struct inode *inode);
 static void	nfs_writeback_done(struct rpc_task *);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 static void	nfs_commit_done(struct rpc_task *);
 #endif
 
@@ -414,7 +414,7 @@
 	return !list_empty(&req->wb_list) && req->wb_list_head == &nfsi->dirty;
 }
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
  */
@@ -552,7 +552,7 @@
 	return res;
 }
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /**
  * nfs_scan_lru_commit_timeout - Scan LRU list for timed out commit requests
  * @server: NFS superblock data
@@ -747,7 +747,7 @@
 
 	dirty  = NFS_I(inode)->ndirty;
 	wpages = NFS_SERVER(inode)->wpages;
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (NFS_PROTO(inode)->version == 2) {
 		if (dirty >= NFS_STRATEGY_PAGES * wpages)
 			nfs_flush_file(inode, NULL, 0, 0, 0);
@@ -1032,7 +1032,7 @@
 		 * an error. */
 		task->tk_status = -EIO;
 	}
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1082,7 +1082,7 @@
 			goto next;
 		}
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (argp->stable != NFS_UNSTABLE || resp->verf->committed == NFS_FILE_SYNC) {
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
@@ -1101,7 +1101,7 @@
 }
 
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 /*
  * Set up the argument/result storage required for the RPC call.
  */
@@ -1265,7 +1265,7 @@
 	return res;
 }
 
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 int nfs_commit_file(struct inode *inode, struct file *file, unsigned long idx_start,
 		    unsigned int npages, int how)
 {
@@ -1302,7 +1302,7 @@
 			error = nfs_wait_on_requests(inode, file, idx_start, npages);
 		if (error == 0)
 			error = nfs_flush_file(inode, file, idx_start, npages, how);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (error == 0)
 			error = nfs_commit_file(inode, file, idx_start, npages, how);
 #endif
diff -u --recursive --new-file linux-2.5.41-nfsv4-E01/include/linux/nfs_fs.h linux-2.5.41-nfsv4-E02/include/linux/nfs_fs.h
--- linux-2.5.41-nfsv4-E01/include/linux/nfs_fs.h	2002-10-08 18:42:48.000000000 -0400
+++ linux-2.5.41-nfsv4-E02/include/linux/nfs_fs.h	2002-10-08 18:43:11.000000000 -0400
@@ -330,7 +330,7 @@
 extern int  nfs_flush_list(struct list_head *, int, int);
 extern int  nfs_scan_lru_dirty(struct nfs_server *, struct list_head *);
 extern int  nfs_scan_lru_dirty_timeout(struct nfs_server *, struct list_head *);
-#ifdef CONFIG_NFS_V3
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 extern int  nfs_commit_file(struct inode *, struct file *, unsigned long, unsigned int, int);
 extern int  nfs_commit_list(struct list_head *, int);
 extern int  nfs_scan_lru_commit(struct nfs_server *, struct list_head *);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
