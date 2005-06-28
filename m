From: Shantanu Goel <sgoel01@yahoo.com>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Tue, 28 Jun 2005 15:43:56 -0700 (PDT)
Message-ID: <20050628224356.7785.qmail@web30713.mail.mud.yahoo.com>
References: <1118117543.13667.28.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-1425830808-1119998636=:7746"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnOoF-0005tQ-4z
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 15:44:03 -0700
Received: from web30713.mail.mud.yahoo.com ([68.142.201.251])
	by sc8-sf-mx2-new.sourceforge.net with smtp (Exim 4.44)
	id 1DnOoE-0008ID-9x
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 15:44:03 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1118117543.13667.28.camel@lade.trondhjem.org>
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

--0-1425830808-1119998636=:7746
Content-Type: text/plain; charset=iso-8859-1
Content-Id: 
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Trond,

Attached is the long delayed revised version of the
writeback smoothing patch this time against
2.6.12-mm2.  I have omitted the commit w/range and
mmap writeback from this one.  If this one is deemed
acceptable for inclusion I'll post the other 2 later.=20
The commit w/range really should be restored as it
makes quite a difference against Solaris NFS servers
with regular disks.  I observed a difference of 2-3
MB/s under sustained writes.  It makes no difference
with the Linux NFS server since it ignores the range.

I tested this version by reducing memory to 32M but
iozone OOM'ed.  However, I observed the same behaviour
with the unpatched client.  If I reduce dirty_ratio to
20 from 40 (the default), iozone completes without a
problem on both versions.  I noticed the slab cache
gets as big as the page cache and the VM fails to take
that in account.  In summary, the behaviour is at
least as good as that of the stock client in this
case.

Thanks,
Shantanu


	=09
____________________________________________________=20
Yahoo! Sports=20
Rekindle the Rivalries. Sign up for Fantasy Football=20
http://football.fantasysports.yahoo.com
--0-1425830808-1119998636=:7746
Content-Type: text/x-patch; name="nfs-writeback.patch"
Content-Description: 2449169141-nfs-writeback.patch
Content-Disposition: inline; filename="nfs-writeback.patch"

--- .orig/fs/nfs/inode.c	2005-06-28 18:24:45.000000000 -0400
+++ nfs-writeback/fs/nfs/inode.c	2005-06-26 19:38:16.000000000 -0400
@@ -58,7 +58,6 @@
 
 static struct inode *nfs_alloc_inode(struct super_block *sb);
 static void nfs_destroy_inode(struct inode *);
-static int nfs_write_inode(struct inode *,int);
 static void nfs_delete_inode(struct inode *);
 static void nfs_clear_inode(struct inode *);
 static void nfs_umount_begin(struct super_block *);
@@ -71,7 +70,6 @@
 static struct super_operations nfs_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.delete_inode	= nfs_delete_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs_clear_inode,
@@ -129,18 +127,6 @@
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
@@ -1565,7 +1551,6 @@
 static struct super_operations nfs4_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
-	.write_inode	= nfs_write_inode,
 	.delete_inode	= nfs_delete_inode,
 	.statfs		= nfs_statfs,
 	.clear_inode	= nfs4_clear_inode,
--- .orig/fs/nfs/pagelist.c	2005-06-28 18:24:45.000000000 -0400
+++ nfs-writeback/fs/nfs/pagelist.c	2005-06-27 06:15:59.000000000 -0400
@@ -126,19 +126,6 @@
 }
 
 /**
- * nfs_clear_page_writeback - Unlock request and wake up sleepers
- */
-void nfs_clear_page_writeback(struct nfs_page *req)
-{
-	struct nfs_inode *nfsi = NFS_I(req->wb_context->dentry->d_inode);
-
-	spin_lock(&nfsi->req_lock);
-	radix_tree_tag_clear(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_WRITEBACK);
-	spin_unlock(&nfsi->req_lock);
-	nfs_unlock_request(req);
-}
-
-/**
  * nfs_clear_request - Free up all resources allocated to the request
  * @req:
  *
@@ -277,7 +264,7 @@
  */
 int
 nfs_scan_lock_dirty(struct nfs_inode *nfsi, struct list_head *dst,
-	      unsigned long idx_start, unsigned int npages)
+	      unsigned long idx_start, unsigned int npages, unsigned int max)
 {
 	struct nfs_page *pgvec[NFS_SCAN_MAXENTRIES];
 	struct nfs_page *req;
@@ -310,6 +297,8 @@
 				nfs_list_remove_request(req);
 				nfs_list_add_request(req, dst);
 				res++;
+				if (max && res >= max)
+					goto out;
 			}
 		}
 	}
--- .orig/fs/nfs/write.c	2005-06-28 18:24:45.000000000 -0400
+++ nfs-writeback/fs/nfs/write.c	2005-06-28 18:02:47.000000000 -0400
@@ -78,16 +78,74 @@
 					    unsigned int, unsigned int);
 static void nfs_writeback_done_partial(struct nfs_write_data *, int);
 static void nfs_writeback_done_full(struct nfs_write_data *, int);
-static int nfs_wait_on_write_congestion(struct address_space *, int);
 static int nfs_wait_on_requests(struct inode *, unsigned long, unsigned int);
 static int nfs_flush_inode(struct inode *inode, unsigned long idx_start,
-			   unsigned int npages, int how);
+			   unsigned int npages, int how, unsigned int max);
+static int __nfs_flush_inode(struct inode *inode, unsigned long idx_start,
+			     unsigned int npages, int how, unsigned int max);
+#if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static int nfs_commit_inode(struct inode *, int);
+static int __nfs_commit_inode(struct inode *, int);
+#else
+static inline int
+nfs_commit_inode(struct inode *inode, int how)
+{
+	return 0;
+}
+
+static inline int
+__nfs_commit_inode(struct inode *inode, int how)
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
+static inline int nfs_should_commit(struct nfs_inode *nfsi, long nr)
+{
+	return nfsi->ncommit >= nr || (nfsi->ncommit > 0 && nfsi->ncommit == nfsi->npages);
+}
+
+static inline unsigned int nfs_wbpages(struct nfs_inode *nfsi)
+{
+	return nfsi->npages - nfsi->ndirty - nfsi->ncommit;
+}
+
+static inline unsigned int nfs_write_chunk(struct inode *inode, long todo)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	unsigned int wpages = NFS_SERVER(inode)->wpages;
+	unsigned int avail = nfs_write_throttle - nfs_wbpages(nfsi);
+
+	if (todo > avail)
+		todo = avail;
+	if (todo < wpages)
+		return wpages;
+	return ((todo + wpages - 1) / wpages) * wpages;
+}
+
+static void nfs_wait_on_write_congestion(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	DEFINE_WAIT(wait);
+
+	might_sleep();
+
+	prepare_to_wait(&nfs_write_congestion, &wait, TASK_INTERRUPTIBLE);
+	spin_lock(&nfsi->req_lock);
+	if (nfs_wbpages(nfsi) > 0) {
+		spin_unlock(&nfsi->req_lock);
+		io_schedule();
+	} else
+		spin_unlock(&nfsi->req_lock);
+	finish_wait(&nfs_write_congestion, &wait);
+}
 
 static inline struct nfs_write_data *nfs_commit_alloc(void)
 {
@@ -305,7 +363,7 @@
 		if (err >= 0) {
 			err = 0;
 			if (wbc->for_reclaim)
-				nfs_flush_inode(inode, 0, 0, FLUSH_STABLE);
+				nfs_flush_inode(inode, 0, 0, FLUSH_STABLE, 0);
 		}
 	} else {
 		err = nfs_writepage_sync(ctx, inode, page, 0,
@@ -325,44 +383,123 @@
 	return err; 
 }
 
-/*
- * Note: causes nfs_update_request() to block on the assumption
- * 	 that the writeback is generated due to memory pressure.
- */
+static inline int nfs_congested(struct nfs_inode *nfsi, long todo)
+{
+	unsigned int wbpages = nfs_wbpages(nfsi);
+
+	if (wbpages >= nfs_write_throttle)
+		return 1;
+	if (nfsi->ncommit > 0 && nfsi->ncommit + wbpages >= todo)
+		return 1;
+	return 0;
+}
+
 int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
 	struct inode *inode = mapping->host;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	long nr = wbc->nr_to_write;
+	long commit_thresh = nr;
+	int how = wb_priority(wbc);
 	int err;
 
-	err = generic_writepages(mapping, wbc);
-	if (err)
-		return err;
-	while (test_and_set_bit(BDI_write_congested, &bdi->state) != 0) {
-		if (wbc->nonblocking)
-			return 0;
-		nfs_wait_on_write_congestion(mapping, 0);
+	for (;;) {
+		spin_lock(&nfsi->req_lock);
+		if (nfs_should_commit(nfsi, commit_thresh)) {
+			err = __nfs_commit_inode(inode, how);
+		} else if (!nfs_congested(nfsi, commit_thresh)) {
+			long n = nr;
+
+			if (nfsi->ncommit > 0)
+				n -= nfsi->ncommit + nfs_wbpages(nfsi);
+			err = __nfs_flush_inode(inode, 0, 0, how, nfs_write_chunk(inode, n));
+		} else {
+			spin_unlock(&nfsi->req_lock);
+			if (wbc->nonblocking) {
+				wbc->encountered_congestion = 1;
+				break;
+			}
+			nfs_wait_on_write_congestion(inode);
+			continue;
+		}
+		if (err > 0) {
+			if ((nr -= err) <= 0)
+				break;
+			continue;
+		}
+		if (err < 0)
+			return err;
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
 	if (!wbc->nonblocking && wbc->sync_mode == WB_SYNC_ALL) {
 		err = nfs_wait_on_requests(inode, 0, 0);
+		if (err >= 0)
+			err = nfs_commit_inode(inode, how);
 		if (err < 0)
-			goto out;
+			return err;
+		nr -= err;
 	}
-	err = nfs_commit_inode(inode, wb_priority(wbc));
-	if (err > 0) {
-		wbc->nr_to_write -= err;
-		err = 0;
+	wbc->nr_to_write = nr;
+	return 0;
+}
+
+static int nfs_clear_page_writeback(struct nfs_page *req)
+{
+	struct inode *inode = req->wb_context->dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_page *p;
+
+	if (!radix_tree_gang_lookup_tag(&nfsi->nfs_page_tree, (void **)&p,
+					req->wb_index, 1, NFS_PAGE_TAG_WRITEBACK))
+		return 0;
+	if (p != req)
+		return 0;
+	radix_tree_tag_clear(&nfsi->nfs_page_tree, req->wb_index, NFS_PAGE_TAG_WRITEBACK);
+	return 1;
+}
+
+/*
+ * Add a request to the inode's dirty list.
+ */
+static void
+__nfs_mark_request_dirty(struct nfs_page *req)
+{
+	struct inode *inode = req->wb_context->dentry->d_inode;
+	struct nfs_inode *nfsi = NFS_I(inode);
+	int wb;
+
+	wb = nfs_clear_page_writeback(req);
+	radix_tree_tag_set(&nfsi->nfs_page_tree,
+			req->wb_index, NFS_PAGE_TAG_DIRTY);
+	nfs_list_add_request(req, &nfsi->dirty);
+	nfsi->ndirty++;
+	spin_unlock(&nfsi->req_lock);
+	inc_page_state(nr_dirty);
+	mark_inode_dirty(inode);
+	if (wb) {
+		nfs_unlock_request(req);
+		wake_up_all(&nfs_write_congestion);
 	}
-out:
-	clear_bit(BDI_write_congested, &bdi->state);
-	wake_up_all(&nfs_write_congestion);
-	return err;
 }
 
+static void
+nfs_mark_request_dirty(struct nfs_page *req)
+{
+	struct inode *inode = req->wb_context->dentry->d_inode;
+
+	spin_lock(&NFS_I(inode)->req_lock);
+	__nfs_mark_request_dirty(req);
+}
+	
 /*
  * Insert a write request into an inode
  */
@@ -383,6 +520,7 @@
 	}
 	nfsi->npages++;
 	atomic_inc(&req->wb_count);
+	__nfs_mark_request_dirty(req);
 	return 0;
 }
 
@@ -393,10 +531,12 @@
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int wb;
 
 	BUG_ON (!NFS_WBACK_BUSY(req));
 
 	spin_lock(&nfsi->req_lock);
+	wb = nfs_clear_page_writeback(req);
 	radix_tree_delete(&nfsi->nfs_page_tree, req->wb_index);
 	nfsi->npages--;
 	if (!nfsi->npages) {
@@ -407,6 +547,10 @@
 		spin_unlock(&nfsi->req_lock);
 	nfs_clear_request(req);
 	nfs_release_request(req);
+	if (wb) {
+		nfs_unlock_request(req);
+		wake_up_all(&nfs_write_congestion);
+	}
 }
 
 /*
@@ -437,25 +581,6 @@
 }
 
 /*
- * Add a request to the inode's dirty list.
- */
-static void
-nfs_mark_request_dirty(struct nfs_page *req)
-{
-	struct inode *inode = req->wb_context->dentry->d_inode;
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	spin_lock(&nfsi->req_lock);
-	radix_tree_tag_set(&nfsi->nfs_page_tree,
-			req->wb_index, NFS_PAGE_TAG_DIRTY);
-	nfs_list_add_request(req, &nfsi->dirty);
-	nfsi->ndirty++;
-	spin_unlock(&nfsi->req_lock);
-	inc_page_state(nr_dirty);
-	mark_inode_dirty(inode);
-}
-
-/*
  * Check if a request is dirty
  */
 static inline int
@@ -474,13 +599,21 @@
 {
 	struct inode *inode = req->wb_context->dentry->d_inode;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	int wb;
+
+	BUG_ON(!NFS_WBACK_BUSY(req));
 
 	spin_lock(&nfsi->req_lock);
+	wb = nfs_clear_page_writeback(req);
 	nfs_list_add_request(req, &nfsi->commit);
 	nfsi->ncommit++;
 	spin_unlock(&nfsi->req_lock);
 	inc_page_state(nr_unstable);
 	mark_inode_dirty(inode);
+	if (wb) {
+		nfs_unlock_request(req);
+		wake_up_all(&nfs_write_congestion);
+	}
 }
 #endif
 
@@ -536,13 +669,13 @@
  * The requests are *not* checked to ensure that they form a contiguous set.
  */
 static int
-nfs_scan_dirty(struct inode *inode, struct list_head *dst, unsigned long idx_start, unsigned int npages)
+nfs_scan_dirty(struct inode *inode, struct list_head *dst, unsigned long idx_start, unsigned int npages, unsigned int max)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int res = 0;
 
 	if (nfsi->ndirty != 0) {
-		res = nfs_scan_lock_dirty(nfsi, dst, idx_start, npages);
+		res = nfs_scan_lock_dirty(nfsi, dst, idx_start, npages, max);
 		nfsi->ndirty -= res;
 		sub_page_state(nr_dirty,res);
 		if ((nfsi->ndirty == 0) != list_empty(&nfsi->dirty))
@@ -578,39 +711,6 @@
 }
 #endif
 
-static int nfs_wait_on_write_congestion(struct address_space *mapping, int intr)
-{
-	struct backing_dev_info *bdi = mapping->backing_dev_info;
-	DEFINE_WAIT(wait);
-	int ret = 0;
-
-	might_sleep();
-
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
-				schedule();
-		}
-		rpc_clnt_sigunmask(clnt, &oldset);
-	} else {
-		prepare_to_wait(&nfs_write_congestion, &wait, TASK_UNINTERRUPTIBLE);
-		if (bdi_write_congested(bdi))
-			schedule();
-	}
-	finish_wait(&nfs_write_congestion, &wait);
-	return ret;
-}
-
-
 /*
  * Try to update any existing write request, or create one if there is none.
  * In order to match, the request's credentials must match those of
@@ -622,15 +722,12 @@
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
@@ -662,8 +759,6 @@
 				nfs_unlock_request(new);
 				return ERR_PTR(error);
 			}
-			spin_unlock(&nfsi->req_lock);
-			nfs_mark_request_dirty(new);
 			return new;
 		}
 		spin_unlock(&nfsi->req_lock);
@@ -812,23 +907,23 @@
 
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 	if (!PageError(req->wb_page)) {
-		if (NFS_NEED_RESCHED(req)) {
+		int need_resched = test_and_clear_bit(PG_NEED_RESCHED, &req->wb_flags);
+		int need_commit = test_and_clear_bit(PG_NEED_COMMIT, &req->wb_flags);
+
+		if (need_resched) {
 			nfs_mark_request_dirty(req);
-			goto out;
-		} else if (NFS_NEED_COMMIT(req)) {
+			return;
+		}
+		if (need_commit) {
 			nfs_mark_request_commit(req);
-			goto out;
+			return;
 		}
+	} else {
+		nfs_clear_commit(req);
+		nfs_clear_reschedule(req);
 	}
-	nfs_inode_remove_request(req);
-
-out:
-	nfs_clear_commit(req);
-	nfs_clear_reschedule(req);
-#else
-	nfs_inode_remove_request(req);
 #endif
-	nfs_clear_page_writeback(req);
+	nfs_inode_remove_request(req);
 }
 
 static inline int flush_task_priority(int how)
@@ -959,7 +1054,6 @@
 		nfs_writedata_free(data);
 	}
 	nfs_mark_request_dirty(req);
-	nfs_clear_page_writeback(req);
 	return -ENOMEM;
 }
 
@@ -1009,7 +1103,6 @@
 		struct nfs_page *req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_dirty(req);
-		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
 }
@@ -1036,7 +1129,6 @@
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_dirty(req);
-		nfs_clear_page_writeback(req);
 	}
 	return error;
 }
@@ -1111,7 +1203,7 @@
 			end_page_writeback(page);
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", status);
-			goto next;
+			continue;
 		}
 		end_page_writeback(page);
 
@@ -1119,7 +1211,7 @@
 		if (data->args.stable != NFS_UNSTABLE || data->verf.committed == NFS_FILE_SYNC) {
 			nfs_inode_remove_request(req);
 			dprintk(" OK\n");
-			goto next;
+			continue;
 		}
 		memcpy(&req->wb_verf, &data->verf, sizeof(req->wb_verf));
 		nfs_mark_request_commit(req);
@@ -1127,8 +1219,6 @@
 #else
 		nfs_inode_remove_request(req);
 #endif
-	next:
-		nfs_clear_page_writeback(req);
 	}
 }
 
@@ -1273,7 +1363,6 @@
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_mark_request_commit(req);
-		nfs_clear_page_writeback(req);
 	}
 	return -ENOMEM;
 }
@@ -1319,23 +1408,21 @@
 		dprintk(" mismatch\n");
 		nfs_mark_request_dirty(req);
 	next:
-		nfs_clear_page_writeback(req);
 		res++;
 	}
 	sub_page_state(nr_unstable,res);
 }
 #endif
 
-static int nfs_flush_inode(struct inode *inode, unsigned long idx_start,
-			   unsigned int npages, int how)
+static int __nfs_flush_inode(struct inode *inode, unsigned long idx_start,
+			     unsigned int npages, int how, unsigned int max)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	LIST_HEAD(head);
 	int			res,
 				error = 0;
 
-	spin_lock(&nfsi->req_lock);
-	res = nfs_scan_dirty(inode, &head, idx_start, npages);
+	res = nfs_scan_dirty(inode, &head, idx_start, npages, max);
 	spin_unlock(&nfsi->req_lock);
 	if (res) {
 		struct nfs_server *server = NFS_SERVER(inode);
@@ -1352,15 +1439,21 @@
 	return res;
 }
 
+static int nfs_flush_inode(struct inode *inode, unsigned long idx_start,
+			   unsigned int npages, int how, unsigned int max)
+{
+	spin_lock(&NFS_I(inode)->req_lock);
+	return __nfs_flush_inode(inode, idx_start, npages, how, max);
+}
+
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
-int nfs_commit_inode(struct inode *inode, int how)
+static int __nfs_commit_inode(struct inode *inode, int how)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	LIST_HEAD(head);
 	int			res,
 				error = 0;
 
-	spin_lock(&nfsi->req_lock);
 	res = nfs_scan_commit(inode, &head, 0, 0);
 	spin_unlock(&nfsi->req_lock);
 	if (res) {
@@ -1370,11 +1463,18 @@
 	}
 	return res;
 }
+
+static int nfs_commit_inode(struct inode *inode, int how)
+{
+	spin_lock(&NFS_I(inode)->req_lock);
+	return __nfs_commit_inode(inode, how);
+}
 #endif
 
 int nfs_sync_inode(struct inode *inode, unsigned long idx_start,
 		  unsigned int npages, int how)
 {
+	struct nfs_inode *nfsi = NFS_I(inode);
 	int	error,
 		wait;
 
@@ -1382,21 +1482,36 @@
 	how &= ~FLUSH_WAIT;
 
 	do {
-		error = 0;
-		if (wait)
+		for (;;) {
+			spin_lock(&nfsi->req_lock);
+			if (nfs_wbpages(nfsi) < nfs_write_throttle)
+				break;
+			spin_unlock(&nfsi->req_lock);
+			if (!wait)
+				return 0;
+			nfs_wait_on_write_congestion(inode);
+		}
+		error = __nfs_flush_inode(inode, idx_start, npages, how, nfs_write_chunk(inode, LONG_MAX));
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
 
+static inline unsigned long si2pages(struct sysinfo *si, unsigned long mem)
+{
+	if (si->mem_unit >= PAGE_CACHE_SIZE)
+		return mem / (si->mem_unit >> PAGE_CACHE_SHIFT);
+	return mem * (PAGE_CACHE_SIZE / si->mem_unit);
+}
+
 int nfs_init_writepagecache(void)
 {
+	struct sysinfo si;
+	unsigned long total, low;
+
 	nfs_wdata_cachep = kmem_cache_create("nfs_write_data",
 					     sizeof(struct nfs_write_data),
 					     0, SLAB_HWCACHE_ALIGN,
@@ -1418,6 +1533,15 @@
 	if (nfs_commit_mempool == NULL)
 		return -ENOMEM;
 
+	/*
+	 * Limit writeback to 1% of memory or
+	 * 5% of lowmem whichever is smaller.
+	 */
+	si_meminfo(&si);
+	total = si2pages(&si, si.totalram);
+	low = si2pages(&si, si.totalram - si.totalhigh);
+	nfs_write_throttle = min(total / 100, low / 20);
+
 	return 0;
 }
 
--- .orig/include/linux/nfs_fs.h	2005-06-28 18:24:46.000000000 -0400
+++ nfs-writeback/include/linux/nfs_fs.h	2005-06-26 19:38:17.000000000 -0400
@@ -394,15 +394,6 @@
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
--- .orig/include/linux/nfs_page.h	2005-06-28 18:24:46.000000000 -0400
+++ nfs-writeback/include/linux/nfs_page.h	2005-06-27 06:16:06.000000000 -0400
@@ -62,7 +62,7 @@
 
 
 extern  int nfs_scan_lock_dirty(struct nfs_inode *nfsi, struct list_head *dst,
-				unsigned long idx_start, unsigned int npages);
+				unsigned long idx_start, unsigned int npages, unsigned int max);
 extern	int nfs_scan_list(struct list_head *, struct list_head *,
 			  unsigned long, unsigned int);
 extern	int nfs_coalesce_requests(struct list_head *, struct list_head *,
@@ -70,7 +70,6 @@
 extern  int nfs_wait_on_request(struct nfs_page *);
 extern	void nfs_unlock_request(struct nfs_page *req);
 extern  int nfs_set_page_writeback_locked(struct nfs_page *req);
-extern  void nfs_clear_page_writeback(struct nfs_page *req);
 
 
 /*

--0-1425830808-1119998636=:7746--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
