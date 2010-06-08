From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 11/24] pnfs_submit: expose pnfs_update_layout, put_lseg, and get_lseg functions
Date: Tue,  8 Jun 2010 00:19:08 -0400
Message-ID: <1275970761-31806-12-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab0FHETr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:47 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQ2014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:32 -0700 (PDT)
In-Reply-To: <1275970761-31806-11-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These will be used in the generic code.  Set so they will compile away to
nothing if CONFIG_NFS_V4_1 not set.

This requires kref_put to be under lock.  See rule 3 of Documentation/kref.txt

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   45 ++++++++++++++++++++++++++++++++-------------
 fs/nfs/pnfs.h |   44 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 75 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 836cb0f..a74a4b6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -436,7 +436,25 @@ destroy_lseg(struct kref *kref)
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
-static inline void
+static void
+put_lseg_locked(struct pnfs_layout_segment *lseg)
+{
+	bool do_wake_up;
+	struct nfs_inode *nfsi;
+
+	if (!lseg)
+		return;
+
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->kref.refcount), lseg->valid);
+	do_wake_up = !lseg->valid;
+	nfsi = PNFS_NFS_INODE(lseg->layout);
+	kref_put(&lseg->kref, destroy_lseg);
+	if (do_wake_up)
+		wake_up(&nfsi->lo_waitq);
+}
+
+void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
@@ -449,7 +467,9 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		atomic_read(&lseg->kref.refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
 	nfsi = PNFS_NFS_INODE(lseg->layout);
+	lock_current_layout(nfsi);
 	kref_put(&lseg->kref, destroy_lseg);
+	unlock_current_layout(nfsi);
 	if (do_wake_up)
 		wake_up(&nfsi->lo_waitq);
 }
@@ -674,7 +694,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 			lseg, lseg->range.iomode, lseg->range.offset,
 			lseg->range.length);
 		list_del(&lseg->fi_list);
-		put_lseg(lseg);
+		put_lseg_locked(lseg);
 	}
 
 	dprintk("%s:Return\n", __func__);
@@ -1033,7 +1053,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 		    (lseg->valid || !only_valid)) {
 			ret = lseg;
 			if (take_ref)
-				kref_get(&ret->kref);
+				get_lseg(ret);
 			break;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
@@ -1053,7 +1073,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
  * returned to the caller.
  */
 int
-pnfs_update_layout(struct inode *ino,
+_pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   u64 count,
 		   loff_t pos,
@@ -1085,8 +1105,7 @@ pnfs_update_layout(struct inode *ino,
 	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
 	if (lseg && !lseg->valid) {
 		if (take_ref)
-			put_lseg(lseg);
-
+			put_lseg_locked(lseg);
 		/* someone is cleaning the layout */
 		lseg = NULL;
 		result = -EAGAIN;
@@ -1262,7 +1281,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 	init_lseg(lo, lseg);
 	lseg->range = res->lseg;
 	if (lgp->lsegpp) {
-		kref_get(&lseg->kref);
+		get_lseg(lseg);
 		*lgp->lsegpp = lseg;
 	}
 
@@ -1380,7 +1399,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	readahead_range(inode, pages, &loff, &count);
 
 	if (count > 0) {
-		status = pnfs_update_layout(inode, ctx, count,
+		status = _pnfs_update_layout(inode, ctx, count,
 						loff, IOMODE_READ, NULL);
 		dprintk("%s virt update returned %d\n", __func__, status);
 		if (status != 0)
@@ -1438,7 +1457,7 @@ pnfs_update_layout_commit(struct inode *inode,
 	if (start == 0 && count == 0)
 		count = NFS4_MAX_UINT64;
 
-	status = pnfs_update_layout(inode, nfs_page->wb_context,
+	status = _pnfs_update_layout(inode, nfs_page->wb_context,
 				count,
 				start,
 				IOMODE_RW,
@@ -1538,7 +1557,7 @@ pnfs_file_write(struct file *filp, const char __user *buf, size_t count,
 		goto out;
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    context,
 				    count,
 				    *pos,
@@ -1580,7 +1599,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		args->offset);
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    args->context,
 				    args->count,
 				    args->offset,
@@ -1681,7 +1700,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
 		args->offset);
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    args->context,
 				    args->count,
 				    args->offset,
@@ -1845,7 +1864,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	   new one.  If it was recalled we better commit the data first
 	   before returning it, otherwise the data needs to be rewritten,
 	   either with a new layout or to the MDS */
-	result = pnfs_update_layout(data->inode,
+	result = _pnfs_update_layout(data->inode,
 				    NULL,
 				    count,
 				    first->wb_offset,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 214d567..6326ed5 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -31,7 +31,8 @@ extern int pnfs4_proc_layoutreturn(struct nfs4_pnfs_layoutreturn *lrp, bool wait
 /* pnfs.c */
 extern const nfs4_stateid zero_stateid;
 
-int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+void put_lseg(struct pnfs_layout_segment *lseg);
+int _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 	u64 count, loff_t pos, enum pnfs_iomode access_type,
 	struct pnfs_layout_segment **lsegpp);
 
@@ -81,6 +82,12 @@ static inline int lo_fail_bit(u32 iomode)
 			 NFS_INO_RW_LAYOUT_FAILED : NFS_INO_RO_LAYOUT_FAILED;
 }
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+	if (lseg)
+		kref_get(&lseg->kref);
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
@@ -170,6 +177,23 @@ static inline int pnfs_return_layout(struct inode *ino,
 	return 0;
 }
 
+static inline int pnfs_update_layout(struct inode *ino,
+	struct nfs_open_context *ctx,
+	u64 count, loff_t pos, enum pnfs_iomode access_type,
+	struct pnfs_layout_segment **lsegpp)
+{
+	struct nfs_server *nfss = NFS_SERVER(ino);
+
+	if (pnfs_enabled_sb(nfss))
+		return _pnfs_update_layout(ino, ctx, count, pos,
+					   access_type, lsegpp);
+	else {
+		if (lsegpp)
+			*lsegpp = NULL;
+		return 0;
+	}
+}
+
 static inline int pnfs_get_write_status(struct nfs_write_data *data)
 {
 	return data->pdata.pnfs_error;
@@ -190,6 +214,24 @@ static inline int pnfs_use_rpc(struct nfs_server *nfss)
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
+static inline void put_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
+static inline int
+pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+	u64 count, loff_t pos, enum pnfs_iomode access_type,
+	struct pnfs_layout_segment **lsegpp)
+{
+	if (lsegpp)
+		*lsegpp = NULL;
+	return 0;
+}
+
 static inline enum pnfs_try_status
 pnfs_try_to_read_data(struct nfs_read_data *data,
 		      const struct rpc_call_ops *call_ops)
-- 
1.6.6.1

