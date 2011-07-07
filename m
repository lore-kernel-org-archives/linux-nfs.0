Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53334 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752746Ab1GGQ0P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2011 12:26:15 -0400
Message-Id: <6882cf3d981a46649b0c04316b566c8d7bd30584.1310055433.git.rees@umich.edu>
In-Reply-To: <cover.1310055433.git.rees@umich.edu>
References: <cover.1310055433.git.rees@umich.edu>
Subject: [PATCH 3/6] SQUASHME: pnfs: teach layoutcommit handle multiple segments
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Date: Thu,  7 Jul 2011 12:26:13 -0400
From: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

This rewrites commit 9658e7532d35faf0c09b8b34fd5808e5e58070ac in a way
more reasonable. Layoutcommit takes a list of segments and last write offset
is saved at inode level.

Signed-off-by: Peng Tao <peng_tao@gmail.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/nfs4proc.c       |    8 +++++-
 fs/nfs/pnfs.c           |   60 ++++++++++++++++++----------------------------
 fs/nfs/pnfs.h           |    4 ++-
 include/linux/nfs_xdr.h |    2 +-
 5 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index af9bf9e..6d7f937 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -170,7 +170,7 @@ filelayout_set_layoutcommit(struct nfs_write_data *wdata)
 
 	pnfs_set_layoutcommit(wdata);
 	dprintk("%s ionde %lu pls_end_pos %lu\n", __func__, wdata->inode->i_ino,
-		(unsigned long) wdata->lseg->pls_end_pos);
+		(unsigned long) NFS_I(wdata->inode)->layout->plh_lwb);
 }
 
 /*
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ace9d37..795033c5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5963,10 +5963,16 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
+	struct pnfs_layout_segment *lseg, *tmp;
 
 	pnfs_cleanup_layoutcommit(data->args.inode, data);
 	/* Matched by references in pnfs_set_layoutcommit */
-	put_lseg(data->lseg);
+	list_for_each_entry_safe(lseg, tmp, &data->lseg_list, pls_lc_list) {
+		list_del_init(&lseg->pls_lc_list);
+		if (test_and_clear_bit(NFS_LSEG_LAYOUTCOMMIT,
+				       &lseg->pls_flags))
+			put_lseg(lseg);
+	}
 	put_rpccred(data->cred);
 	kfree(data);
 }
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1fdc8f7..30a0394 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -240,6 +240,7 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
+	INIT_LIST_HEAD(&lseg->pls_lc_list);
 	atomic_set(&lseg->pls_refcount, 1);
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
@@ -1273,25 +1274,18 @@ pnfs_try_to_read_data(struct nfs_read_data *rdata,
 }
 
 /*
- * Currently there is only one (whole file) write lseg.
+ * There can be multiple RW segments.
  */
-static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
+static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 {
-	struct pnfs_layout_segment *lseg, *rv = NULL;
-	loff_t max_pos = 0;
+	struct pnfs_layout_segment *lseg;
 
 	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
-		if (lseg->pls_range.iomode == IOMODE_RW) {
-			if (max_pos < lseg->pls_end_pos)
-				max_pos = lseg->pls_end_pos;
-			if (test_and_clear_bit
-			    (NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
-				rv = lseg;
-		}
+		if (lseg->pls_range.iomode == IOMODE_RW &&
+		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags) &&
+		    list_empty(&lseg->pls_lc_list))
+			list_add(&lseg->pls_lc_list, listp);
 	}
-	rv->pls_end_pos = max_pos;
-
-	return rv;
 }
 
 void
@@ -1299,27 +1293,25 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 {
 	struct nfs_inode *nfsi = NFS_I(wdata->inode);
 	loff_t end_pos = wdata->mds_offset + wdata->res.count;
-	loff_t isize = i_size_read(wdata->inode);
 	bool mark_as_dirty = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(wdata->lseg);
-		set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags);
-		wdata->lseg->pls_lc_cred =
-			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
+		nfsi->layout->plh_lc_cred =
+			get_rpccred(wdata->args.context->state->owner->so_cred);
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
-	if (end_pos > isize)
-		end_pos = isize;
-	if (end_pos > wdata->lseg->pls_end_pos)
-		wdata->lseg->pls_end_pos = end_pos;
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		get_lseg(wdata->lseg);
+	}
+	if (end_pos > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	dprintk("%s: lseg %p end_pos %llu\n",
-		__func__, wdata->lseg, wdata->lseg->pls_end_pos);
+		__func__, wdata->lseg, nfsi->layout->plh_lwb);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -1351,7 +1343,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
 	struct rpc_cred *cred;
 	loff_t end_pos;
 	int status = 0;
@@ -1375,23 +1366,20 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		kfree(data);
 		goto out;
 	}
-	/*
-	 * Currently only one (whole file) write lseg which is referenced
-	 * in pnfs_set_layoutcommit and will be found.
-	 */
-	lseg = pnfs_list_write_lseg(inode);
 
-	end_pos = lseg->pls_end_pos;
-	cred = lseg->pls_lc_cred;
-	lseg->pls_end_pos = 0;
-	lseg->pls_lc_cred = NULL;
+	INIT_LIST_HEAD(&data->lseg_list);
+	pnfs_list_write_lseg(inode, &data->lseg_list);
+
+	end_pos = nfsi->layout->plh_lwb;
+	cred = nfsi->layout->plh_lc_cred;
+	nfsi->layout->plh_lwb = 0;
+	nfsi->layout->plh_lc_cred = NULL;
 
 	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
 		sizeof(nfsi->layout->plh_stateid.data));
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-	data->lseg = lseg;
 	data->cred = cred;
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index a0c856c..cfe332c 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -41,12 +41,12 @@ enum {
 
 struct pnfs_layout_segment {
 	struct list_head pls_list;
+	struct list_head pls_lc_list;
 	struct pnfs_layout_range pls_range;
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
 	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
-	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };
 
 enum pnfs_try_status {
@@ -132,6 +132,8 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
+	loff_t			plh_lwb; /* last write byte for layoutcommit */
+	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 065e941..27c12c7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -275,7 +275,7 @@ struct nfs4_layoutcommit_res {
 struct nfs4_layoutcommit_data {
 	struct rpc_task task;
 	struct nfs_fattr fattr;
-	struct pnfs_layout_segment *lseg;
+	struct list_head lseg_list;
 	struct rpc_cred *cred;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;
-- 
1.7.4.1

