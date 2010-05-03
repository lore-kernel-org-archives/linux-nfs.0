From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 4/8] SQUASHME: pnfs_submit: Revert "pnfs: pnfs_do_flush"
Date: Sun,  2 May 2010 21:00:45 -0400
Message-ID: <1272848449-19170-5-git-send-email-iisaman@netapp.com>
References: <1272848449-19170-1-git-send-email-iisaman@netapp.com>
 <1272848449-19170-2-git-send-email-iisaman@netapp.com>
 <1272848449-19170-3-git-send-email-iisaman@netapp.com>
 <1272848449-19170-4-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758663Ab0EEDH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 May 2010 23:07:58 -0400
Received: from localhost.localdomain (makada1-lxp.hq.netapp.com [10.58.60.192] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4537cga024006
	for <linux-nfs@vger.kernel.org>; Tue, 4 May 2010 20:07:41 -0700 (PDT)
In-Reply-To: <1272848449-19170-4-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit f61a5fb1508434b904f9382ba9488d1be4e6ac79.

pnfs_write_begin, fsdata handling, and pnfs_do_flush are not used by
the layout driver.

Conflicts:

	fs/nfs/pnfs.c
	fs/nfs/pnfs.h

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c             |   14 +------
 fs/nfs/pnfs.c             |   95 ---------------------------------------------
 fs/nfs/pnfs.h             |   58 ---------------------------
 fs/nfs/write.c            |    6 +--
 include/linux/nfs4_pnfs.h |   12 ------
 5 files changed, 4 insertions(+), 181 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 38bc81f..3ec9abb 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -433,7 +433,8 @@ start:
 
 	ret = nfs_flush_incompatible(file, page);
 	if (ret) {
-		goto out_err;
+		unlock_page(page);
+		page_cache_release(page);
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
@@ -441,18 +442,8 @@ start:
 		page_cache_release(page);
 		if (!ret)
 			goto start;
-	} else {
-		ret = pnfs_write_begin(file, page, pos, len, fsdata);
-		if (ret)
-			goto out_err;
 	}
 	return ret;
-
- out_err:
-	unlock_page(page);
-	page_cache_release(page);
-	*pagep = NULL;
-	return ret;
 }
 
 static int nfs_write_end(struct file *file, struct address_space *mapping,
@@ -491,7 +482,6 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 	unlock_page(page);
 	page_cache_release(page);
-	pnfs_write_end_cleanup(fsdata);
 
 	if (status < 0)
 		return status;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ce6ca4b..7289593 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1009,30 +1009,6 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 	return ret;
 }
 
-static struct pnfs_layout_segment *
-pnfs_find_get_lseg(struct inode *inode,
-		   loff_t pos,
-		   size_t count,
-		   enum pnfs_iomode iomode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
-	struct pnfs_layout_type *lo;
-	struct nfs4_pnfs_layout_segment range;
-
-	dprintk("%s:Begin\n", __func__);
-	lo = get_lock_current_layout(nfsi);
-	if (!lo)
-		return NULL;
-	range.iomode = iomode;
-	range.offset = pos;
-	range.length = count;
-	lseg = pnfs_has_layout(lo, &range, true, true);
-	put_unlock_current_layout(lo);
-	dprintk("%s:Return lseg %p", __func__, lseg);
-	return lseg;
-}
-
 /* Called with spin lock held */
 void drain_layoutreturns(struct pnfs_layout_type *lo)
 {
@@ -1922,69 +1898,6 @@ _pnfs_try_to_read_data(struct nfs_read_data *data,
 	}
 }
 
-/*
- * This gives the layout driver an opportunity to read in page "around"
- * the data to be written.  It returns 0 on success, otherwise an error code
- * which will either be passed up to user, or ignored if
- * some previous part of write succeeded.
- * Note the range [pos, pos+len-1] is entirely within the page.
- */
-int _pnfs_write_begin(struct inode *inode, struct page *page,
-		      loff_t pos, unsigned len, struct pnfs_fsdata **fsdata)
-{
-	struct pnfs_layout_segment *lseg;
-	int status = 0;
-
-	dprintk("--> %s: pos=%llu len=%u\n",
-		__func__, (unsigned long long)pos, len);
-	status = pnfs_update_layout(inode,
-				    NULL,
-				    len,
-				    pos,
-				    IOMODE_RW,
-				    &lseg);
-	if (status)
-		goto out;
-	*fsdata = kzalloc(sizeof(struct pnfs_fsdata), GFP_KERNEL);
-	if (!*fsdata) {
-		status = -ENOMEM;
-		goto out_put;
-	}
-	status = NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->write_begin(
-						lseg, page, pos, len, *fsdata);
-	if (!status) {
-		(*fsdata)->lseg = lseg;
-		goto out;
-	}
-	kfree(*fsdata);
-	*fsdata = NULL;
-out_put:
-	put_lseg(lseg);
-out:
-	dprintk("<-- %s: status=%d\n", __func__, status);
-	return status;
-}
-
-/* Given an nfs request, determine if it should be flushed before proceeding.
- * It should default to returning False, returning True only if there is a
- * specific reason to flush.
- */
-int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
-		   struct pnfs_fsdata *fsdata)
-{
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	struct pnfs_layout_segment *lseg;
-	loff_t pos = ((loff_t)req->wb_index << PAGE_CACHE_SHIFT) + req->wb_offset;
-	int status = 0;
-
-	lseg = pnfs_find_get_lseg(inode, pos, req->wb_bytes, IOMODE_RW);
-	/* Note that lseg==NULL may be useful info for do_flush */
-	status = nfss->pnfs_curr_ld->ld_policy_ops->do_flush(lseg, req,
-							     fsdata);
-	put_lseg(lseg);
-	return status;
-}
-
 enum pnfs_try_status
 _pnfs_try_to_write_data(struct nfs_write_data *data,
 			const struct rpc_call_ops *call_ops, int how)
@@ -2245,14 +2158,6 @@ out_unlock:
 	goto out;
 }
 
-void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
-{
-	if (fsdata) {
-		put_lseg(fsdata->lseg);
-		kfree(fsdata);
-	}
-}
-
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 8d37dfb..2d8cf4f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -64,7 +64,6 @@ enum pnfs_try_status _pnfs_try_to_commit(struct nfs_write_data *,
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *, struct nfs_open_context *, struct list_head *, size_t *);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, size_t *wsize);
 void pnfs_update_layout_commit(struct inode *, struct list_head *, pgoff_t, unsigned int);
-void pnfs_free_fsdata(struct pnfs_fsdata *fsdata);
 ssize_t pnfs_file_write(struct file *, const char __user *, size_t, loff_t *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
@@ -73,11 +72,6 @@ void pnfs_layout_release(struct pnfs_layout_type *, atomic_t *,
 void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
-int _pnfs_write_begin(struct inode *inode, struct page *page,
-		      loff_t pos, unsigned len,
-		      struct pnfs_fsdata **fsdata);
-int _pnfs_do_flush(struct inode *inode, struct nfs_page *req,
-		   struct pnfs_fsdata *fsdata);
 void _pnfs_direct_init_io(struct inode *inode, struct nfs_open_context *ctx,
 			  size_t count, loff_t loff, int iswrite,
 			  size_t *rwsize, size_t *remaining);
@@ -163,43 +157,6 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return ret;
 }
 
-static inline int pnfs_write_begin(struct file *filp, struct page *page,
-				   loff_t pos, unsigned len, void **fsdata)
-{
-	struct inode *inode = filp->f_dentry->d_inode;
-	struct nfs_server *nfss = NFS_SERVER(inode);
-	int status = 0;
-
-	*fsdata = NULL;
-	if (PNFS_EXISTS_LDIO_OP(nfss, write_begin))
-		status = _pnfs_write_begin(inode, page, pos, len,
-					   (struct pnfs_fsdata **) fsdata);
-	return status;
-}
-
-/* req may not be locked, so we have to be prepared for req->wb_page being
- * set to NULL at any time.
- */
-static inline int pnfs_do_flush(struct nfs_page *req, void *fsdata)
-{
-	struct page *page = req->wb_page;
-	struct inode *inode;
-
-	if (!page)
-		return 1;
-	inode = page->mapping->host;
-
-	if (PNFS_EXISTS_LDPOLICY_OP(NFS_SERVER(inode), do_flush))
-		return _pnfs_do_flush(inode, req, fsdata);
-	else
-		return 0;
-}
-
-static inline void pnfs_write_end_cleanup(void *fsdata)
-{
-	pnfs_free_fsdata(fsdata);
-}
-
 static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 	clear_bit(PG_USE_PNFS, &req->wb_flags);
@@ -275,21 +232,6 @@ pnfs_try_to_commit(struct nfs_write_data *data,
 	return PNFS_NOT_ATTEMPTED;
 }
 
-static inline int pnfs_do_flush(struct nfs_page *req, void *fsdata)
-{
-	return 0;
-}
-
-static inline int pnfs_write_begin(struct file *filp, struct page *page,
-				   loff_t pos, unsigned len, void **fsdata)
-{
-	return 0;
-}
-
-static inline void pnfs_write_end_cleanup(void *fsdata)
-{
-}
-
 static inline void pnfs_redirty_request(struct nfs_page *req)
 {
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9aa9dae..c97a3ab 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -596,8 +596,7 @@ static struct nfs_page *nfs_try_to_update_request(struct inode *inode,
 		 * have flushed out requests having wrong owners.
 		 */
 		if (offset > rqend
-		    || end < req->wb_offset
-		    || pnfs_do_flush(req, NULL))
+		    || end < req->wb_offset)
 			goto out_flushme;
 
 		if (nfs_set_page_tag_locked(req))
@@ -700,8 +699,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 		req = nfs_page_find_request(page);
 		if (req == NULL)
 			return 0;
-		do_flush = req->wb_page != page || req->wb_context != ctx ||
-			   pnfs_do_flush(req, NULL);
+		do_flush = req->wb_page != page || req->wb_context != ctx;
 		nfs_release_request(req);
 		if (!do_flush)
 			return 0;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 1ba0590..d4da067 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -37,11 +37,6 @@ struct pnfs_mount_type {
 	void *mountid;
 };
 
-struct pnfs_fsdata {
-	int ok_to_use_pnfs;
-	struct pnfs_layout_segment *lseg;
-};
-
 #if defined(CONFIG_NFS_V4_1)
 
 static inline struct nfs_inode *
@@ -139,9 +134,6 @@ struct layoutdriver_io_operations {
 			   struct page **pages, unsigned int pgbase,
 			   unsigned nr_pages, loff_t offset, size_t count,
 			   int sync, struct nfs_write_data *nfs_data);
-	int (*write_begin) (struct pnfs_layout_segment *lseg, struct page *page,
-			    loff_t pos, unsigned count,
-			    struct pnfs_fsdata *fsdata);
 
 	/* Consistency ops */
 	/* 2 problems:
@@ -204,10 +196,6 @@ struct layoutdriver_policy_operations {
 	/* test for nfs page cache coalescing */
 	int (*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
 
-	/* Test for pre-write request flushing */
-	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req,
-			struct pnfs_fsdata *fsdata);
-
 	/* Retreive the block size of the file system.  If gather_across_stripes == 1,
 	 * then the file system will gather requests into the block size.
 	 * TODO: Where will the layout driver get this info?  It is hard coded in PVFS2.
-- 
1.6.6.1

