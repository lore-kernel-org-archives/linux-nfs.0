From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] NFS client doesn't flush dirty mmap'd pages during fsync/msync
Date: Wed, 14 Jan 2004 13:46:27 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSO.4.33.0401141300540.10050-100000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Agq3j-0000Px-TR
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 10:48:07 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Agq3j-0005vZ-31
	for nfs@lists.sourceforge.net; Wed, 14 Jan 2004 10:48:07 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

hi trond-

it has been observed via fsx testing with NFS O_DIRECT that fsync and
msync (and their relatives) do not flush dirty mmap'd pages in NFS files
to the server.  these pages are flushed later by other operations that
flush all dirty pages on a mount point.  this can result in file data
corruption because write ordering is compromised.

the nfs_writepage interface causes dirty mmap'd pages to be queued on an
NFS inode's dirty page queue.  these pages are queued with a NULL filp
because a filp is not available via the nfs_writepage interface.  when
nfs_fsync is invoked (either via fsync() or via msync()), it is looking
specifically for dirty pages associated with a given filp, so it skips the
dirty pages with a NULL filp.

this patch removes the check in nfs_scan_list for pages with a specific
filp.  this is a three line change -- the rest of the patch removes the
filp argument from a number of function declarations where it is no longer
needed.

patch is against 2.6.0, equivalent patch for 2.4 is already in your inbox.


diff -X /home/cel/src/linux/dont-diff -Naurp 04-async-read/fs/nfs/inode.c 05-msync/fs/nfs/inode.c
--- 04-async-read/fs/nfs/inode.c	2003-12-17 21:59:18.000000000 -0500
+++ 05-msync/fs/nfs/inode.c	2004-01-14 12:18:51.558979000 -0500
@@ -118,7 +118,7 @@ nfs_write_inode(struct inode *inode, int
 {
 	int flags = sync ? FLUSH_WAIT : 0;

-	nfs_commit_file(inode, NULL, 0, 0, flags);
+	nfs_commit_file(inode, 0, 0, flags);
 }

 static void
diff -X /home/cel/src/linux/dont-diff -Naurp 04-async-read/fs/nfs/pagelist.c 05-msync/fs/nfs/pagelist.c
--- 04-async-read/fs/nfs/pagelist.c	2004-01-14 12:14:56.485979000 -0500
+++ 05-msync/fs/nfs/pagelist.c	2004-01-14 12:18:51.654976000 -0500
@@ -247,7 +247,6 @@ nfs_coalesce_requests(struct list_head *
  * nfs_scan_list - Scan a list for matching requests
  * @head: One of the NFS inode request lists
  * @dst: Destination list
- * @file: if set, ensure we match requests from this file
  * @idx_start: lower bound of page->index to scan
  * @npages: idx_start + npages sets the upper bound to scan.
  *
@@ -259,7 +258,6 @@ nfs_coalesce_requests(struct list_head *
  */
 int
 nfs_scan_list(struct list_head *head, struct list_head *dst,
-	      struct file *file,
 	      unsigned long idx_start, unsigned int npages)
 {
 	struct list_head	*pos, *tmp;
@@ -277,9 +275,6 @@ nfs_scan_list(struct list_head *head, st

 		req = nfs_list_entry(pos);

-		if (file && req->wb_file != file)
-			continue;
-
 		if (req->wb_index < idx_start)
 			continue;
 		if (req->wb_index > idx_end)
diff -X /home/cel/src/linux/dont-diff -Naurp 04-async-read/fs/nfs/write.c 05-msync/fs/nfs/write.c
--- 04-async-read/fs/nfs/write.c	2003-12-17 21:59:16.000000000 -0500
+++ 05-msync/fs/nfs/write.c	2004-01-14 12:18:51.706976000 -0500
@@ -272,7 +272,7 @@ nfs_writepages(struct address_space *map
 	err = generic_writepages(mapping, wbc);
 	if (err)
 		goto out;
-	err = nfs_flush_file(inode, NULL, 0, 0, 0);
+	err = nfs_flush_file(inode, 0, 0, 0);
 	if (err < 0)
 		goto out;
 	if (wbc->sync_mode == WB_SYNC_HOLD)
@@ -280,7 +280,7 @@ nfs_writepages(struct address_space *map
 	if (is_sync && wbc->sync_mode == WB_SYNC_ALL) {
 		err = nfs_wb_all(inode);
 	} else
-		nfs_commit_file(inode, NULL, 0, 0, 0);
+		nfs_commit_file(inode, 0, 0, 0);
 out:
 	return err;
 }
@@ -450,7 +450,6 @@ nfs_wait_on_requests(struct inode *inode
  * nfs_scan_dirty - Scan an inode for dirty requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @file: if set, ensure we match requests from this file
  * @idx_start: lower bound of page->index to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
@@ -458,11 +457,12 @@ nfs_wait_on_requests(struct inode *inode
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_dirty(struct inode *inode, struct list_head *dst, struct file *file, unsigned long idx_start, unsigned int npages)
+nfs_scan_dirty(struct inode *inode, struct list_head *dst,
+	unsigned long idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int	res;
-	res = nfs_scan_list(&nfsi->dirty, dst, file, idx_start, npages);
+	res = nfs_scan_list(&nfsi->dirty, dst, idx_start, npages);
 	nfsi->ndirty -= res;
 	sub_page_state(nr_dirty,res);
 	if ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty))
@@ -475,7 +475,6 @@ nfs_scan_dirty(struct inode *inode, stru
  * nfs_scan_commit - Scan an inode for commit requests
  * @inode: NFS inode to scan
  * @dst: destination list
- * @file: if set, ensure we collect requests from this file only.
  * @idx_start: lower bound of page->index to scan.
  * @npages: idx_start + npages sets the upper bound to scan.
  *
@@ -483,11 +482,12 @@ nfs_scan_dirty(struct inode *inode, stru
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_commit(struct inode *inode, struct list_head *dst, struct file *file, unsigned long idx_start, unsigned int npages)
+nfs_scan_commit(struct inode *inode, struct list_head *dst,
+	unsigned long idx_start, unsigned int npages)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int	res;
-	res = nfs_scan_list(&nfsi->commit, dst, file, idx_start, npages);
+	res = nfs_scan_list(&nfsi->commit, dst, idx_start, npages);
 	nfsi->ncommit -= res;
 	if ((nfsi->ncommit == 0) != list_empty(&nfsi->commit))
 		printk(KERN_ERR "NFS: desynchronized value of nfs_i.ncommit.\n");
@@ -617,12 +617,12 @@ nfs_strategy(struct inode *inode)
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (NFS_PROTO(inode)->version == 2) {
 		if (dirty >= NFS_STRATEGY_PAGES * wpages)
-			nfs_flush_file(inode, NULL, 0, 0, 0);
+			nfs_flush_file(inode, 0, 0, 0);
 	} else if (dirty >= wpages)
-		nfs_flush_file(inode, NULL, 0, 0, 0);
+		nfs_flush_file(inode, 0, 0, 0);
 #else
 	if (dirty >= NFS_STRATEGY_PAGES * wpages)
-		nfs_flush_file(inode, NULL, 0, 0, 0);
+		nfs_flush_file(inode, 0, 0, 0);
 #endif
 }

@@ -1047,7 +1047,7 @@ nfs_commit_done(struct rpc_task *task)
 }
 #endif

-int nfs_flush_file(struct inode *inode, struct file *file, unsigned long idx_start,
+int nfs_flush_file(struct inode *inode, unsigned long idx_start,
 		   unsigned int npages, int how)
 {
 	LIST_HEAD(head);
@@ -1055,7 +1055,7 @@ int nfs_flush_file(struct inode *inode,
 				error = 0;

 	spin_lock(&nfs_wreq_lock);
-	res = nfs_scan_dirty(inode, &head, file, idx_start, npages);
+	res = nfs_scan_dirty(inode, &head, idx_start, npages);
 	spin_unlock(&nfs_wreq_lock);
 	if (res)
 		error = nfs_flush_list(&head, NFS_SERVER(inode)->wpages, how);
@@ -1065,7 +1065,7 @@ int nfs_flush_file(struct inode *inode,
 }

 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-int nfs_commit_file(struct inode *inode, struct file *file, unsigned long idx_start,
+int nfs_commit_file(struct inode *inode, unsigned long idx_start,
 		    unsigned int npages, int how)
 {
 	LIST_HEAD(head);
@@ -1073,7 +1073,7 @@ int nfs_commit_file(struct inode *inode,
 				error = 0;

 	spin_lock(&nfs_wreq_lock);
-	res = nfs_scan_commit(inode, &head, file, idx_start, npages);
+	res = nfs_scan_commit(inode, &head, idx_start, npages);
 	spin_unlock(&nfs_wreq_lock);
 	if (res)
 		error = nfs_commit_list(&head, how);
@@ -1100,10 +1100,10 @@ int nfs_sync_file(struct inode *inode, s
 		if (wait)
 			error = nfs_wait_on_requests(inode, file, idx_start, npages);
 		if (error == 0)
-			error = nfs_flush_file(inode, file, idx_start, npages, how);
+			error = nfs_flush_file(inode, idx_start, npages, how);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (error == 0)
-			error = nfs_commit_file(inode, file, idx_start, npages, how);
+			error = nfs_commit_file(inode, idx_start, npages, how);
 #endif
 	} while (error > 0);
 	return error;
diff -X /home/cel/src/linux/dont-diff -Naurp 04-async-read/include/linux/nfs_fs.h 05-msync/include/linux/nfs_fs.h
--- 04-async-read/include/linux/nfs_fs.h	2003-12-17 21:58:40.000000000 -0500
+++ 05-msync/include/linux/nfs_fs.h	2004-01-14 12:18:51.776976000 -0500
@@ -310,14 +310,14 @@ extern void nfs_commit_done(struct rpc_t
  * return value!)
  */
 extern int  nfs_sync_file(struct inode *, struct file *, unsigned long, unsigned int, int);
-extern int  nfs_flush_file(struct inode *, struct file *, unsigned long, unsigned int, int);
+extern int  nfs_flush_file(struct inode *, unsigned long, unsigned int, int);
 extern int  nfs_flush_list(struct list_head *, int, int);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-extern int  nfs_commit_file(struct inode *, struct file *, unsigned long, unsigned int, int);
+extern int  nfs_commit_file(struct inode *, unsigned long, unsigned int, int);
 extern int  nfs_commit_list(struct list_head *, int);
 #else
 static inline int
-nfs_commit_file(struct inode *inode, struct file *file, unsigned long offset,
+nfs_commit_file(struct inode *inode, unsigned long offset,
 		unsigned int len, int flags)
 {
 	return 0;
diff -X /home/cel/src/linux/dont-diff -Naurp 04-async-read/include/linux/nfs_page.h 05-msync/include/linux/nfs_page.h
--- 04-async-read/include/linux/nfs_page.h	2004-01-14 12:14:56.750976000 -0500
+++ 05-msync/include/linux/nfs_page.h	2004-01-14 12:18:52.058985000 -0500
@@ -55,7 +55,7 @@ extern	void nfs_release_request(struct n
 extern	void nfs_list_add_request(struct nfs_page *, struct list_head *);

 extern	int nfs_scan_list(struct list_head *, struct list_head *,
-			  struct file *, unsigned long, unsigned int);
+			  unsigned long, unsigned int);
 extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,
 				  unsigned int);
 extern  int nfs_wait_on_request(struct nfs_page *);

	- Chuck Lever
--
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
