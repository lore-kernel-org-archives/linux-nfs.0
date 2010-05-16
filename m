From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 10/22] pnfs_submit: expose pnfs_update_layout, put_lseg, and get_lseg functions
Date: Sat, 15 May 2010 21:23:01 -0400
Message-ID: <1273972993-15369-11-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
 <1273972993-15369-10-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754668Ab0ETKai (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:38 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQc0022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:38 -0700 (PDT)
In-Reply-To: <1273972993-15369-10-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These will be used in the generic code.  Set so they will compile away to
nothing if CONFIG_NFS_V4_1 not set.

This requires kref_put to be under lock.  See rule 3 of Documentation/kref.txt

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   48 ++++++++++++++++++++++++++++++++++--------------
 fs/nfs/pnfs.h |   44 +++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 77 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 055f040..d1693a4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -405,7 +405,25 @@ destroy_lseg(struct kref *kref)
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
@@ -418,7 +436,9 @@ put_lseg(struct pnfs_layout_segment *lseg)
 		atomic_read(&lseg->kref.refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
 	nfsi = PNFS_NFS_INODE(lseg->layout);
+	spin_lock(&nfsi->lo_lock);
 	kref_put(&lseg->kref, destroy_lseg);
+	spin_unlock(&nfsi->lo_lock);
 	if (do_wake_up)
 		wake_up(&nfsi->lo_waitq);
 }
@@ -640,7 +660,7 @@ pnfs_free_layout(struct pnfs_layout_type *lo,
 			lseg, lseg->range.iomode, lseg->range.offset,
 			lseg->range.length);
 		list_del(&lseg->fi_list);
-		put_lseg(lseg);
+		put_lseg_locked(lseg);
 	}
 
 	dprintk("%s:Return\n", __func__);
@@ -1000,7 +1020,7 @@ pnfs_has_layout(struct pnfs_layout_type *lo,
 		    (lseg->valid || !only_valid)) {
 			ret = lseg;
 			if (take_ref)
-				kref_get(&ret->kref);
+				get_lseg(ret);
 			break;
 		}
 		if (cmp_layout(range, &lseg->range) > 0)
@@ -1033,7 +1053,7 @@ void drain_layoutreturns(struct pnfs_layout_type *lo)
  * returned to the caller.
  */
 int
-pnfs_update_layout(struct inode *ino,
+_pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
 		   u64 count,
 		   loff_t pos,
@@ -1062,9 +1082,9 @@ pnfs_update_layout(struct inode *ino,
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
 	if (lseg && !lseg->valid) {
-		spin_unlock(&nfsi->lo_lock);
 		if (take_ref)
-			put_lseg(lseg);
+			put_lseg_locked(lseg);
+		spin_unlock(&nfsi->lo_lock);
 		for (;;) {
 			prepare_to_wait(&nfsi->lo_waitq, &__wait,
 					TASK_KILLABLE);
@@ -1075,7 +1095,7 @@ pnfs_update_layout(struct inode *ino,
 			dprintk("%s: invalid lseg %p ref %d\n", __func__,
 				lseg, atomic_read(&lseg->kref.refcount)-1);
 			if (take_ref)
-				put_lseg(lseg);
+				put_lseg_locked(lseg);
 			if (signal_pending(current)) {
 				lseg = NULL;
 				result = -ERESTARTSYS;
@@ -1262,7 +1282,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 	init_lseg(lo, lseg);
 	lseg->range = res->lseg;
 	if (lgp->lsegpp) {
-		kref_get(&lseg->kref);
+		get_lseg(lseg);
 		*lgp->lsegpp = lseg;
 	}
 
@@ -1380,7 +1400,7 @@ pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 	readahead_range(inode, pages, &loff, &count);
 
 	if (count > 0) {
-		status = pnfs_update_layout(inode, ctx, count,
+		status = _pnfs_update_layout(inode, ctx, count,
 						loff, IOMODE_READ, NULL);
 		dprintk("%s virt update returned %d\n", __func__, status);
 		if (status != 0)
@@ -1438,7 +1458,7 @@ pnfs_update_layout_commit(struct inode *inode,
 	if (start == 0 && count == 0)
 		count = NFS4_MAX_UINT64;
 
-	status = pnfs_update_layout(inode, nfs_page->wb_context,
+	status = _pnfs_update_layout(inode, nfs_page->wb_context,
 				count,
 				start,
 				IOMODE_RW,
@@ -1538,7 +1558,7 @@ pnfs_file_write(struct file *filp, const char __user *buf, size_t count,
 		goto out;
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    context,
 				    count,
 				    *pos,
@@ -1580,7 +1600,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 		args->offset);
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    args->context,
 				    args->count,
 				    args->offset,
@@ -1681,7 +1701,7 @@ pnfs_readpages(struct nfs_read_data *rdata)
 		args->offset);
 
 	/* Retrieve and set layout if not allready cached */
-	status = pnfs_update_layout(inode,
+	status = _pnfs_update_layout(inode,
 				    args->context,
 				    args->count,
 				    args->offset,
@@ -1845,7 +1865,7 @@ pnfs_commit(struct nfs_write_data *data, int sync)
 	   new one.  If it was recalled we better commit the data first
 	   before returning it, otherwise the data needs to be rewritten,
 	   either with a new layout or to the MDS */
-	result = pnfs_update_layout(data->inode,
+	result = _pnfs_update_layout(data->inode,
 				    NULL,
 				    count,
 				    first->wb_offset,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5e9b06b..242abf5 100644
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
 
@@ -80,6 +81,12 @@ static inline int lo_fail_bit(u32 iomode)
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
@@ -169,6 +176,23 @@ static inline int pnfs_return_layout(struct inode *ino,
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
@@ -189,6 +213,24 @@ static inline int pnfs_use_rpc(struct nfs_server *nfss)
 
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

