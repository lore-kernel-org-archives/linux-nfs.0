From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 5/8] pnfs_post_submit: Restore "pnfs: pnfs_do_flush"
Date: Sun,  2 May 2010 21:00:46 -0400
Message-ID: <1272848449-19170-6-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
 <1272848449-19170-2-git-send-email-iisaman@netapp.com>
 <1272848449-19170-3-git-send-email-iisaman@netapp.com>
 <1272848449-19170-4-git-send-email-iisaman@netapp.com>
 <1272848449-19170-5-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31966 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759123Ab0EEDH7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:59 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cgb024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:42 -0700 (PDT)
In-Reply-To: <1272848449-19170-5-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

pnfs: pnfs_do_flush

Adds a hook into the "check if request needs flushed" routines.
This will be needed to allow driver the ability to prevent comingling
of layout driver handled requests and fallback nfs requests.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfs: prevent offset overflow in _pnfs_do_flush]
[pnfs: pnfs_has_layout take_ref parameter should be bool]
[pnfs: clean up put_unlock_current_layout's interface]
[pnfs: introduce lseg valid bit]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c             |   14 ++++++-
 fs/nfs/pnfs.c             |   95 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   58 +++++++++++++++++++++++++++
 fs/nfs/write.c            |    6 ++-
 include/linux/nfs4_pnfs.h |   12 ++++++
 5 files changed, 181 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 3ec9abb..38bc81f 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -433,8 +433,7 @@ start:
 
 	ret = nfs_flush_incompatible(file, page);
 	if (ret) {
-		unlock_page(page);
-		page_cache_release(page);
+		goto out_err;
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
@@ -442,8 +441,18 @@ start:
 		page_cache_release(page);
 		if (!ret)
 			goto start;
+	} else {
+		ret = pnfs_write_begin(file, page, pos, len, fsdata);
+		if (ret)
+			goto out_err;
 	}
 	return ret;
+
+ out_err:
+	unlock_page(page);
+	page_cache_release(page);
+	*pagep = NULL;
+	return ret;
 }
 
 static int nfs_write_end(struct file *file, struct address_space *mapping,
@@ -482,6 +491,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 	unlock_page(page);
 	page_cache_release(page);
+	pnfs_write_end_cleanup(fsdata);
 
 	if (status < 0)
 		return status;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7289593..ce6ca4b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1009,6 +1009,30 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 	return ret;
 }
 
+static struct pnfs_layout_segment *
+pnfs_find_get_lseg(struct inode *inode,
+		   loff_t pos,
+		   size_t count,
+		   enum pnfs_iomode iomode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_type *lo;
+	struct nfs4_pnfs_layout_segment range;
+
+	dprintk("%s:Begin\n", __func__);
+	lo = get_lock_current_layout(nfsi);
+	if (!lo)
+		return NULL;
+	range.iomode = iomode;
+	range.offset = pos;
+	range.length = count;
+	lseg = pnfs_has_layout(lo, &range, true, true);
+	put_unlock_current_layout(lo);
+	dprintk("%s:Return lseg %p", __func__, lseg);
+	return lseg;
+}
+
 /* Called with spin lock held */
 void drain_layoutreturns(struct pnfs_layout_type *lo)
 {
@@ -1898,6 +1922,69 @@ _pnfs_try_to_read_data(struct nfs_read_data *data,
 	}
 }
 
+/*
+ * This gives the layout driver an opportunity to read in page "around"
+ * the data to be written.  It returns 0 on success, otherwise an error code
+ * which will either be passed up to user, or ignored if
+ * some previous part of write succeeded.
+ * Note the range [pos, pos+len-1] is entirely within the page.
+ */
+int _pnfs_write_begin(struct inode *inode, struct page *page,
+		      loff_t pos, unsigned len, struct pnfs_fsdata **fsdata)
+{
+	struct pnfs_layout_segment *lseg;
+	int status = 0;
+
+	dprintk("--> %s: pos=%llu len=%u\n",
+		__func__, (unsigned long long)pos, len);
+	status = pnfs_update_layout(inode,
+				    NULL,
+				    len,
+				    pos,
+				    IOMODE_RW,
+				    &lseg);
+	if (status)
+		goto out;
+	*fsdata = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
+	if (!*fsdata) {
+		status = -ENOMEM;
+		goto out_put;
+	}
+	status = NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->write_begin(
+						lseg, page, pos, len, *fsdata);
+	if (!status) {
+		(*fsdata)->lseg = lseg;
+		goto out;
+	}
+	kfree(*fsdata);
+	*fsdata = NULL;
+out_put:
+	put_lseg(lseg);
+out:
+	dprintk("<-- %s: status=%d\n", __func__, status);
+	return status;
+}
+
+/* Given an nfs request, determine if it should be flushed before proceeding.
+ * It should default to returning False, returning True only if there is a
+ * specific reason to flush.
+ */
+int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
+		   struct pnfs_fsdata *fsdata)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	struct pnfs_layout_segment *lseg;
+	loff_t pos = ((loff_t)req->wb_index << PAGE_CACHE_SHIFT) + req->wb_offset;
+	int status = 0;
+
+	lseg = pnfs_find_get_lseg(inode, pos, req->wb_bytes, IOMODE_RW);
+	/* Note that lseg==NULL may be useful info for do_flush */
+	status = nfss->pnfs_curr_ld->ld_policy_ops->do_flush(lseg, req,
+							     fsdata);
+	put_lseg(lseg);
+	return status;
+}
+
 enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
@@ -2158,6 +2245,14 @@ out_unlock:
 	goto out;
 }
 
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
+{
+	if (fsdata) {
+		put_lseg(fsdata->lseg);
+		kfree(fsdata);
+	}
+}
+
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2d8cf4f..8d37dfb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,6 +64,7 @@ enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *, struct nfs_open_context *, struct list_head *, size_t *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, size_t *wsize);
 void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
+void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
@@ -72,6 +73,11 @@ void pnfs_layout_release(struct pnfs_layout_type *, atomic_t *,
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
+int _pnfs_write_begin(struct inode *inode, struct page *page,
+		      loff_t pos, unsigned len,
+		      struct pnfs_fsdata **fsdata);
+int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
+		   struct pnfs_fsdata *fsdata);
 void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 			  size_t count, loff_t loff, int iswrite,
 			  size_t *rwsize, size_t *remaining);
@@ -157,6 +163,43 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return ret;
 }
 
+static inline int pnfs_write_begin(struct file *filp, struct page *page,
+				   loff_t pos, unsigned len, void **fsdata)
+{
+	struct inode *inode = filp->f_dentry->d_inode;
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int status = 0;
+
+	*fsdata = NULL;
+	if (PNFS_EXISTS_LDIO_OP(nfss, write_begin))
+		status = _pnfs_write_begin(inode, page, pos, len,
+					   (struct pnfs_fsdata **) fsdata);
+	return status;
+}
+
+/* req may not be locked, so we have to be prepared for req->wb_page being
+ * set to NULL at any time.
+ */
+static inline int pnfs_do_flush(struct nfs_page *req, void *fsdata)
+{
+	struct page *page = req->wb_page;
+	struct inode *inode;
+
+	if (!page)
+		return 1;
+	inode = page->mapping->host;
+
+	if (PNFS_EXISTS_LDPOLICY_OP(NFS_SERVER(inode), do_flush))
+		return _pnfs_do_flush(inode, req, fsdata);
+	else
+		return 0;
+}
+
+static inline void pnfs_write_end_cleanup(void *fsdata)
+{
+	pnfs_free_fsdata(fsdata);
+}
+
 static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 	clear_bit(PG_USE_PNFS, &req->wb_flags);
@@ -232,6 +275,21 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
+static inline int pnfs_do_flush(struct nfs_page *req, void *fsdata)
+{
+	return 0;
+}
+
+static inline int pnfs_write_begin(struct file *filp, struct page *page,
+				   loff_t pos, unsigned len, void **fsdata)
+{
+	return 0;
+}
+
+static inline void pnfs_write_end_cleanup(void *fsdata)
+{
+}
+
 static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c97a3ab..9aa9dae 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -596,7 +596,8 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * have flushed out requests having wrong owners.
 		 */
 		if (offset > rqend
-		    || end < req->wb_offset)
+		    || end < req->wb_offset
+		    || pnfs_do_flush(req, NULL))
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -699,7 +700,8 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx;
+		do_flush = req->wb_page != page || req->wb_context != ctx ||
+			   pnfs_do_flush(req, NULL);
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d4da067..1ba0590 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -37,6 +37,11 @@ struct pnfs_mount_type {
 	void *mountid;
 };
 
+struct pnfs_fsdata {
+	int ok_to_use_pnfs;
+	struct pnfs_layout_segment *lseg;
+};
+
 #if defined(CONFIG_NFS_V4_1)
 
 static inline struct nfs_inode *
@@ -134,6 +139,9 @@ struct layoutdriver_io_operations {
 			   struct page **pages, unsigned int pgbase,
 			   unsigned nr_pages, loff_t offset, size_t count,
 			   int sync, struct nfs_write_data *nfs_data);
+	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
+			    loff_t pos, unsigned count,
+			    struct pnfs_fsdata *fsdata);
 
 	/* Consistency ops */
 	/* 2 problems:
@@ -196,6 +204,10 @@ struct layoutdriver_policy_operations {
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
+	/* Test for pre-write request flushing */
+	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req,
+			struct pnfs_fsdata *fsdata);
+
 	/* Retreive the block size of the file system.  If gather_across_stripes == 1,
 	 * then the file system will gather requests into the block size.
 	 * TODO: Where will the layout driver get this info?  It is hard coded in PVFS2.
-- 
1.6.6.1

