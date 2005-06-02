From: Shantanu Goel <sgoel01@yahoo.com>
Subject: [PATCH] Smooth out NFS client writeback
Date: Wed, 1 Jun 2005 18:38:16 -0700 (PDT)
Message-ID: <20050602013816.79953.qmail@web30707.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-2033004553-1117676296=:20117"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DdefI-00021B-8e
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 18:38:32 -0700
Received: from web30707.mail.mud.yahoo.com ([68.142.200.140])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DdefH-0008TM-7P
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 18:38:32 -0700
To: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
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

--0-2033004553-1117676296=:20117
Content-Type: text/plain; charset=iso-8859-1
Content-Id: 
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

The current NFS client can cause a program to stall
for long periods of time because it flushes all dirty
pages at once.  The attached patch addresses this by
only writing back the amount requested by the VM
layer.  It also reduces the # commit requests by
waiting for some writeback to complete before issuing
a commit.  The patch also speeds up writebacks of
mmap'ed data by accumulating dirty pages but sending
commits earlier and omitting FLUSH_STABLE.

As part of the patch, I reinstated specifying the
commit range because I observed a marked speed up when
testing on a filesystem mounted from a Solaris 2.10
server.

The patch is against 2.6.12-rc5 w/NFS_ALL.

Thanks,
Shantanu

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20
--0-2033004553-1117676296=:20117
Content-Type: text/x-patch; name="nfs-writeback.patch"
Content-Description: 2449169141-nfs-writeback.patch
Content-Disposition: inline; filename="nfs-writeback.patch"

diff -ur -x '*~' 00-trond/fs/nfs/inode.c 01-nfs-writeback/fs/nfs/inode.c
--- 00-trond/fs/nfs/inode.c	2005-06-01 18:30:38.000000000 -0400
+++ 01-nfs-writeback/fs/nfs/inode.c	2005-06-01 18:31:00.000000000 -0400
@@ -60,7 +60,6 @@
 
 static struct inode *nfs_alloc_inode(struct super_block *sb);
 static void nfs_destroy_inode(struct inode *);
-static int nfs_write_inode(struct inode *,int);
 static void nfs_delete_inode(struct inode *);
 static void nfs_clear_inode(struct inode *);
 static void nfs_umount_begin(struct super_block *);
@@ -74,7 +73,6 @@
 static struct super_operations nfs_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.delete_inode	= nfs_delete_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
@@ -187,18 +185,6 @@
 	return nfs_fileid_to_ino_t(fattr->fileid);
 }
 
-static int
-nfs_write_inode(struct inode *inode, int sync)
-{
-	int flags = sync ? FLUSH_WAIT : 0;
-	int ret;
-
-	ret = nfs_commit_inode(inode, flags);
-	if (ret < 0)
-		return ret;
-	return 0;
-}
-
 static void
 nfs_delete_inode(struct inode * inode)
 {
@@ -1904,7 +1890,6 @@
 static struct super_operations nfs4_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.delete_inode	= nfs_delete_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs4_clear_inode,
diff -ur -x '*~' 00-trond/fs/nfs/pagelist.c 01-nfs-writeback/fs/nfs/pagelist.c
--- 00-trond/fs/nfs/pagelist.c	2005-06-01 18:30:38.000000000 -0400
+++ 01-nfs-writeback/fs/nfs/pagelist.c	2005-06-01 18:31:00.000000000 -0400
@@ -282,7 +282,8 @@
  */
 int
 nfs_scan_lock_dirty(struct nfs_inode *nfsi, struct list_head *dst,
-	      unsigned long idx_start, unsigned int npages)
+		    unsigned long idx_start, unsigned int npages,
+		    unsigned int max)
 {
 	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
 	struct nfs_page *req;
@@ -317,6 +318,8 @@
 				res++;
 			}
 		}
+		if (max > 0 && res >= max)
+			break;
 	}
 out:
 	return res;
diff -ur -x '*~' 00-trond/fs/nfs/write.c 01-nfs-writeback/fs/nfs/write.c
--- 00-trond/fs/nfs/write.c	2005-06-01 18:30:38.000000000 -0400
+++ 01-nfs-writeback/fs/nfs/write.c	2005-06-01 18:31:00.000000000 -0400
@@ -70,6 +70,9 @@
 #define MIN_POOL_WRITE		(32)
 #define MIN_POOL_COMMIT		(4)
 
+#define NFS_WRITE_CLUSTER	((256*1024) >> PAGE_CACHE_SHIFT)
+#define NFS_COMMIT_CLUSTER	((4*1024*1024) >> PAGE_CACHE_SHIFT)
+
 /*
  * Local function declarations
  */
@@ -79,16 +82,60 @@
 					    unsigned int, unsigned int);
 static void nfs_writeback_done_partial(struct nfs_write_data *, int);
 static void nfs_writeback_done_full(struct nfs_write_data *, int);
-static int nfs_wait_on_write_congestion(struct address_space *, int);
+static int nfs_wait_on_write_congestion(struct inode *, int);
 static int nfs_wait_on_requests(struct inode *, unsigned long, unsigned int);
 static int nfs_flush_inode(struct inode *inode, unsigned long idx_start,
-			   unsigned int npages, int how);
+			   unsigned int npages, int how, unsigned int max);
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static int nfs_commit_inode(struct inode *inode, int how);
+static int nfs_commit_check(struct inode *inode, int how, unsigned int thresh);
+#else
+static inline int nfs_commit_inode(struct inode *inode, int how)
+{
+	return 0;
+}
+
+static inline int nfs_commit_check(struct inode *inode, int how, unsigned int thresh)
+{
+	return 0;
+}
+#endif
 
 static kmem_cache_t *nfs_wdata_cachep;
 mempool_t *nfs_wdata_mempool;
 static mempool_t *nfs_commit_mempool;
 
 static DECLARE_WAIT_QUEUE_HEAD(nfs_write_congestion);
+static unsigned int nfs_write_throttle;
+
+static inline unsigned int min_wb(struct inode *inode)
+{
+	return max((unsigned int)NFS_WRITE_CLUSTER, NFS_SERVER(inode)->wpages);
+}
+
+static inline int is_congested(struct nfs_inode *nfsi)
+{
+	return (nfsi->npages - nfsi->ndirty - nfsi->ncommit) >= nfs_write_throttle;
+}
+
+static inline int mod_count(struct nfs_inode *nfsi, unsigned int *count, int x)
+{
+	int congested = is_congested(nfsi);
+
+	*count += x;
+	return congested && !is_congested(nfsi);
+}
+
+static int nfs_congested(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	int congested;
+
+	spin_lock(&nfsi->req_lock);
+	congested = is_congested(nfsi);
+	spin_unlock(&nfsi->req_lock);
+	return congested;
+}
 
 static inline struct nfs_write_data *nfs_commit_alloc(void)
 {
@@ -269,6 +316,7 @@
 	loff_t i_size = i_size_read(inode);
 	int inode_referenced = 0;
 	int priority = wb_priority(wbc);
+	int is_async;
 	int err;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGE);
@@ -284,6 +332,24 @@
 	if (igrab(inode) != 0)
 		inode_referenced = 1;
 	end_index = i_size >> PAGE_CACHE_SHIFT;
+	is_async = !IS_SYNC(inode) && inode_referenced;
+
+	/*
+	 * If we were called due to memory pressure, avoid
+	 * further pressure if there are many writebacks outstanding.
+	 */
+	if (wbc->for_reclaim && is_async) {
+		if (nfs_congested(inode)) {
+			if (wbc->nonblocking) {
+				err = 0;
+				redirty_page_for_writepage(wbc, page);
+				wbc->encountered_congestion = 1;
+				goto out;
+			}
+			nfs_wait_on_write_congestion(inode, 0);
+		}
+		nfs_commit_check(inode, priority, NFS_WRITE_CLUSTER);
+	}
 
 	/* Ensure we've flushed out any previous writes */
 	nfs_wb_page_priority(inode, page, priority);
@@ -305,12 +371,12 @@
 		goto out;
 	}
 	lock_kernel();
-	if (!IS_SYNC(inode) && inode_referenced) {
+	if (is_async) {
 		err = nfs_writepage_async(ctx, inode, page, 0, offset);
 		if (err >= 0) {
 			err = 0;
-			if (wbc->for_reclaim)
-				nfs_flush_inode(inode, 0, 0, FLUSH_STABLE);
+			if (wbc->for_reclaim && NFS_I(inode)->ndirty >= NFS_WRITE_CLUSTER)
+				nfs_flush_inode(inode, 0, 0, priority, min_wb(inode));
 		}
 	} else {
 		err = nfs_writepage_sync(ctx, inode, page, 0,
@@ -331,43 +397,77 @@
 }
 
 /*
- * Note: causes nfs_update_request() to block on the assumption
- * 	 that the writeback is generated due to memory pressure.
+ * Note: We make the assumption that pdflush()'s due to dirty
+ * thresholds are asynchronous so we can build up large commit lists
+ * during synchronous writes and still do the right thing when memory
+ * needs to be reclaimed.
  */
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	struct inode *inode = mapping->host;
-	int err;
+	long nr = wbc->nr_to_write;
+	int priority = wb_priority(wbc);
+	int nr_commit = 0;
+	int err, is_sync;
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
-	err = generic_writepages(mapping, wbc);
-	if (err)
-		return err;
-	while (test_and_set_bit(BDI_write_congested, &bdi->state) != 0) {
-		if (wbc->nonblocking)
-			return 0;
-		nfs_wait_on_write_congestion(mapping, 0);
+	is_sync = !wbc->nonblocking && wbc->sync_mode == WB_SYNC_ALL;
+
+	for (;;) {
+		if (nfs_congested(inode)) {
+			if (wbc->nonblocking) {
+				wbc->encountered_congestion = 1;
+				break;
+			}
+			nfs_wait_on_write_congestion(inode, 0);
+		}
+		if (!is_sync) {
+			err = nfs_commit_check(inode, priority, 0);
+			if (err < 0)
+				return err;
+			if (err > 0) {
+				nr_commit++;
+				nr -= err;
+				if (nr <= 0)
+					break;
+				continue;
+			}
+		}
+		err = nfs_flush_inode(inode, 0, 0, priority, min_wb(inode));
+		if (err < 0)
+			return err;
+		if (err > 0) {
+			nr -= err;
+			if (nr <= 0)
+				break;
+			continue;
+		}
+		if (wbc->nr_to_write > 0) {
+			long n = wbc->nr_to_write;
+
+			err = generic_writepages(mapping, wbc);
+			if (err)
+				return err;
+			if (n - wbc->nr_to_write > 0)
+				continue;
+		}
+		break;
 	}
-	err = nfs_flush_inode(inode, 0, 0, wb_priority(wbc));
-	if (err < 0)
-		goto out;
-	wbc->nr_to_write -= err;
-	if (!wbc->nonblocking && wbc->sync_mode == WB_SYNC_ALL) {
+	if (is_sync) {
 		err = nfs_wait_on_requests(inode, 0, 0);
 		if (err < 0)
-			goto out;
+			return err;
+		priority |= FLUSH_SYNC;
 	}
-	err = nfs_commit_inode(inode, wb_priority(wbc));
-	if (err > 0) {
-		wbc->nr_to_write -= err;
-		err = 0;
+	if (is_sync || (wbc->for_kupdate && !nr_commit)) {
+		err = nfs_commit_inode(inode, priority);
+		if (err < 0)
+			return err;
+		nr -= err;
 	}
-out:
-	clear_bit(BDI_write_congested, &bdi->state);
-	wake_up_all(&nfs_write_congestion);
-	return err;
+	wbc->nr_to_write = nr;
+	return 0;
 }
 
 /*
@@ -400,12 +500,13 @@
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int need_wakeup;
 
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&nfsi->req_lock);
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
-	nfsi->npages--;
+	need_wakeup = mod_count(nfsi, &nfsi->npages, -1);
 	if (!nfsi->npages) {
 		spin_unlock(&nfsi->req_lock);
 		nfs_end_data_update(inode);
@@ -414,6 +515,8 @@
 		spin_unlock(&nfsi->req_lock);
 	nfs_clear_request(req);
 	nfs_release_request(req);
+	if (need_wakeup)
+		wake_up_all(&nfs_write_congestion);
 }
 
 /*
@@ -451,15 +554,18 @@
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int need_wakeup;
 
 	spin_lock(&nfsi->req_lock);
 	radix_tree_tag_set(&nfsi->nfs_page_tree,
 			req->wb_index, NFS_PAGE_TAG_DIRTY);
 	nfs_list_add_request(req, &nfsi->dirty);
-	nfsi->ndirty++;
+	need_wakeup = mod_count(nfsi, &nfsi->ndirty, 1);
 	spin_unlock(&nfsi->req_lock);
 	inc_page_state(nr_dirty);
 	mark_inode_dirty(inode);
+	if (need_wakeup)
+		wake_up_all(&nfs_write_congestion);
 }
 
 /*
@@ -481,13 +587,16 @@
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int need_wakeup;
 
 	spin_lock(&nfsi->req_lock);
 	nfs_list_add_request(req, &nfsi->commit);
-	nfsi->ncommit++;
+	need_wakeup = mod_count(nfsi, &nfsi->ncommit, 1);
 	spin_unlock(&nfsi->req_lock);
 	inc_page_state(nr_unstable);
 	mark_inode_dirty(inode);
+	if (need_wakeup)
+		wake_up_all(&nfs_write_congestion);
 }
 #endif
 
@@ -543,13 +652,15 @@
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_dirty(struct inode *inode, struct list_head *dst, unsigned long idx_start, unsigned int npages)
+nfs_scan_dirty(struct inode *inode, struct list_head *dst,
+	       unsigned long idx_start, unsigned int npages,
+	       unsigned int max)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int res = 0;
 
 	if (nfsi->ndirty != 0) {
-		res = nfs_scan_lock_dirty(nfsi, dst, idx_start, npages);
+		res = nfs_scan_lock_dirty(nfsi, dst, idx_start, npages, max);
 		nfsi->ndirty -= res;
 		sub_page_state(nr_dirty,res);
 		if ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty))
@@ -585,35 +696,38 @@
 }
 #endif
 
-static int nfs_wait_on_write_congestion(struct address_space *mapping, int intr)
+static int nfs_wait_on_write_congestion(struct inode *inode, int intr)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	DEFINE_WAIT(wait);
 	int ret = 0;
+	int done = 0;
 
 	might_sleep();
 
-	if (!bdi_write_congested(bdi))
-		return 0;
-	if (intr) {
-		struct rpc_clnt *clnt = NFS_CLIENT(mapping->host);
-		sigset_t oldset;
-
-		rpc_clnt_sigmask(clnt, &oldset);
-		prepare_to_wait(&nfs_write_congestion, &wait, TASK_INTERRUPTIBLE);
-		if (bdi_write_congested(bdi)) {
-			if (signalled())
-				ret = -ERESTARTSYS;
-			else
+	do {
+		if (intr) {
+			struct rpc_clnt *clnt = NFS_CLIENT(inode);
+			sigset_t oldset;
+
+			rpc_clnt_sigmask(clnt, &oldset);
+			prepare_to_wait(&nfs_write_congestion, &wait, TASK_INTERRUPTIBLE);
+			if (nfs_congested(inode)) {
+				if (signalled())
+					ret = -ERESTARTSYS;
+				else
+					schedule();
+			} else
+				done = 1;
+			rpc_clnt_sigunmask(clnt, &oldset);
+		} else {
+			prepare_to_wait(&nfs_write_congestion, &wait, TASK_UNINTERRUPTIBLE);
+			if (nfs_congested(inode))
 				schedule();
+			else
+				done = 1;
 		}
-		rpc_clnt_sigunmask(clnt, &oldset);
-	} else {
-		prepare_to_wait(&nfs_write_congestion, &wait, TASK_UNINTERRUPTIBLE);
-		if (bdi_write_congested(bdi))
-			schedule();
-	}
-	finish_wait(&nfs_write_congestion, &wait);
+		finish_wait(&nfs_write_congestion, &wait);
+	} while (ret == 0 && !done);
 	return ret;
 }
 
@@ -629,15 +743,12 @@
 		struct inode *inode, struct page *page,
 		unsigned int offset, unsigned int bytes)
 {
-	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_page		*req, *new = NULL;
 	unsigned long		rqend, end;
 
 	end = offset + bytes;
 
-	if (nfs_wait_on_write_congestion(page->mapping, server->flags & NFS_MOUNT_INTR))
-		return ERR_PTR(-ERESTARTSYS);
 	for (;;) {
 		/* Loop over all inode entries and see if we find
 		 * A request for the page we wish to update
@@ -1228,24 +1339,36 @@
 		struct nfs_write_data *data, int how)
 {
 	struct rpc_task		*task = &data->task;
-	struct nfs_page		*first;
+	struct nfs_page		*first, *last;
 	struct inode		*inode;
+	loff_t			start, end, len;
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
 	list_splice_init(head, &data->pages);
 	first = nfs_list_entry(data->pages.next);
+	last = nfs_list_entry(data->pages.prev);
 	inode = first->wb_context->dentry->d_inode;
 
+	/*
+	 * Determine the offset range of requests in the COMMIT call.
+	 * We rely on the fact that data->pages is an ordered list...
+	 */
+	start = req_offset(first);
+	end = req_offset(last) + last->wb_bytes;
+	len = end - start;
+	/* If 'len' is not a 32-bit quantity, pass '0' in the COMMIT call */
+	if (end >= i_size_read(inode) || len < 0 || len > (~((u32)0) >> 1))
+		len = 0;
+
 	data->inode	  = inode;
 	data->cred	  = first->wb_context->cred;
 
 	data->args.fh     = NFS_FH(data->inode);
-	/* Note: we always request a commit of the entire inode */
-	data->args.offset = 0;
-	data->args.count  = 0;
-	data->res.count   = 0;
+	data->args.offset = start;
+	data->args.count  = len;
+	data->res.count   = len;
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	
@@ -1338,7 +1461,7 @@
 #endif
 
 static int nfs_flush_inode(struct inode *inode, unsigned long idx_start,
-			   unsigned int npages, int how)
+			   unsigned int npages, int how, unsigned int max)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	LIST_HEAD(head);
@@ -1346,7 +1469,7 @@
 				error = 0;
 
 	spin_lock(&nfsi->req_lock);
-	res = nfs_scan_dirty(inode, &head, idx_start, npages);
+	res = nfs_scan_dirty(inode, &head, idx_start, npages, max);
 	spin_unlock(&nfsi->req_lock);
 	if (res) {
 		struct nfs_server *server = NFS_SERVER(inode);
@@ -1364,14 +1487,13 @@
 }
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-int nfs_commit_inode(struct inode *inode, int how)
+static int nfs_commit_inode_locked(struct inode *inode, int how)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	LIST_HEAD(head);
 	int			res,
 				error = 0;
 
-	spin_lock(&nfsi->req_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
 	spin_unlock(&nfsi->req_lock);
 	if (res) {
@@ -1381,33 +1503,59 @@
 	}
 	return res;
 }
+
+static int nfs_commit_inode(struct inode *inode, int how)
+{
+	spin_lock(&NFS_I(inode)->req_lock);
+	return nfs_commit_inode_locked(inode, how);
+}
+
+static int nfs_commit_check(struct inode *inode, int how, unsigned int thresh)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	spin_lock(&nfsi->req_lock);
+	if (nfsi->npages > 0) {
+		if (thresh == 0)
+			thresh = NFS_COMMIT_CLUSTER;
+		if (thresh > nfsi->npages)
+			thresh = nfsi->npages;
+		if (nfsi->ncommit >= thresh)
+			return nfs_commit_inode_locked(inode, how);
+	}
+	spin_unlock(&nfsi->req_lock);
+	return 0;
+}
 #endif
 
 int nfs_sync_inode(struct inode *inode, unsigned long idx_start,
 		  unsigned int npages, int how)
 {
-	int	error,
+	int	error = 0,
 		wait;
 
 	wait = how & FLUSH_WAIT;
 	how &= ~FLUSH_WAIT;
 
 	do {
-		error = 0;
-		if (wait)
+		if (nfs_congested(inode)) {
+			if (!wait)
+				break;
+			nfs_wait_on_write_congestion(inode, 0);
+		}
+		error = nfs_flush_inode(inode, idx_start, npages, how, min_wb(inode));
+		if (error == 0 && wait)
 			error = nfs_wait_on_requests(inode, idx_start, npages);
 		if (error == 0)
-			error = nfs_flush_inode(inode, idx_start, npages, how);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-		if (error == 0)
 			error = nfs_commit_inode(inode, how);
-#endif
 	} while (error > 0);
 	return error;
 }
 
 int nfs_init_writepagecache(void)
 {
+	struct sysinfo si;
+
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1429,6 +1577,13 @@
 	if (nfs_commit_mempool == NULL)
 		return -ENOMEM;
 
+	si_meminfo(&si);
+	nfs_write_throttle = ((si.totalram / 100) * si.mem_unit) >> PAGE_CACHE_SHIFT;
+	if (nfs_write_throttle < NFS_WRITE_CLUSTER)
+		nfs_write_throttle = NFS_WRITE_CLUSTER;
+	if (nfs_write_throttle > NFS_COMMIT_CLUSTER)
+		nfs_write_throttle = NFS_COMMIT_CLUSTER;
+
 	return 0;
 }
 
diff -ur -x '*~' 00-trond/include/linux/nfs_fs.h 01-nfs-writeback/include/linux/nfs_fs.h
--- 00-trond/include/linux/nfs_fs.h	2005-06-01 18:30:38.000000000 -0400
+++ 01-nfs-writeback/include/linux/nfs_fs.h	2005-06-01 18:31:00.000000000 -0400
@@ -408,15 +408,6 @@
  * return value!)
  */
 extern int  nfs_sync_inode(struct inode *, unsigned long, unsigned int, int);
-#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-extern int  nfs_commit_inode(struct inode *, int);
-#else
-static inline int
-nfs_commit_inode(struct inode *inode, int how)
-{
-	return 0;
-}
-#endif
 
 static inline int
 nfs_have_writebacks(struct inode *inode)
diff -ur -x '*~' 00-trond/include/linux/nfs_page.h 01-nfs-writeback/include/linux/nfs_page.h
--- 00-trond/include/linux/nfs_page.h	2005-06-01 18:30:38.000000000 -0400
+++ 01-nfs-writeback/include/linux/nfs_page.h	2005-06-01 18:31:00.000000000 -0400
@@ -61,7 +61,7 @@
 
 
 extern  int nfs_scan_lock_dirty(struct nfs_inode *nfsi, struct list_head *dst,
-				unsigned long idx_start, unsigned int npages);
+				unsigned long idx_start, unsigned int npages, unsigned int max);
 extern	int nfs_scan_list(struct list_head *, struct list_head *,
 			  unsigned long, unsigned int);
 extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,

--0-2033004553-1117676296=:20117--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
