Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:37636 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486Ab1GaAxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 20:53:06 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v7 03/26] pnfs: let layoutcommit handle a list of lseg
Date: Sat, 30 Jul 2011 20:52:33 -0400
Message-Id: <1312073576-11024-4-git-send-email-rees@umich.edu>
In-Reply-To: <1312073576-11024-1-git-send-email-rees@umich.edu>
References: <1312073576-11024-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <peng_tao@emc.com>

There can be multiple lseg per file, so layoutcommit should be
able to handle it.

[Needed in v3.0]
CC: Stable Tree <stable@kernel.org>
Signed-off-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/nfs4proc.c       |    8 +++++++-
 fs/nfs/pnfs.c           |   32 ++++++++++++++++----------------
 fs/nfs/pnfs.h           |    2 ++
 include/linux/nfs_xdr.h |    2 +-
 4 files changed, 26 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 079614d..efa6ae8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5912,9 +5912,15 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 static void nfs4_layoutcommit_release(void *calldata)
 {
 	struct nfs4_layoutcommit_data *data = calldata;
+	struct pnfs_layout_segment *lseg, *tmp;
 
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
index ab2cb04..a7e5f17 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -225,6 +225,7 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
+	INIT_LIST_HEAD(&lseg->pls_lc_list);
 	atomic_set(&lseg->pls_refcount, 1);
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
@@ -1356,16 +1357,17 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_readpages);
 
 /*
- * Currently there is only one (whole file) write lseg.
+ * There can be multiple RW segments.
  */
-static struct pnfs_layout_segment *pnfs_list_write_lseg(struct inode *inode)
+static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 {
-	struct pnfs_layout_segment *lseg, *rv = NULL;
+	struct pnfs_layout_segment *lseg;
 
-	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list)
-		if (lseg->pls_range.iomode == IOMODE_RW)
-			rv = lseg;
-	return rv;
+	list_for_each_entry(lseg, &NFS_I(inode)->layout->plh_segs, pls_list) {
+		if (lseg->pls_range.iomode == IOMODE_RW &&
+		    test_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+			list_add(&lseg->pls_lc_list, listp);
+	}
 }
 
 void
@@ -1377,12 +1379,14 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(wdata->lseg);
 		mark_as_dirty = true;
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		get_lseg(wdata->lseg);
+	}
 	if (end_pos > nfsi->layout->plh_lwb)
 		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
@@ -1409,7 +1413,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
 	loff_t end_pos;
 	int status = 0;
 
@@ -1426,17 +1429,15 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 		goto out;
 	}
 
+	INIT_LIST_HEAD(&data->lseg_list);
 	spin_lock(&inode->i_lock);
 	if (!test_and_clear_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		spin_unlock(&inode->i_lock);
 		kfree(data);
 		goto out;
 	}
-	/*
-	 * Currently only one (whole file) write lseg which is referenced
-	 * in pnfs_set_layoutcommit and will be found.
-	 */
-	lseg = pnfs_list_write_lseg(inode);
+
+	pnfs_list_write_lseg(inode, &data->lseg_list);
 
 	end_pos = nfsi->layout->plh_lwb;
 	nfsi->layout->plh_lwb = 0;
@@ -1446,7 +1447,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-	data->lseg = lseg;
 	data->cred = get_rpccred(nfsi->layout->plh_lc_cred);
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1f5cb47..b94f874 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -36,10 +36,12 @@
 enum {
 	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
 	NFS_LSEG_ROC,		/* roc bit received from server */
+	NFS_LSEG_LAYOUTCOMMIT,	/* layoutcommit bit set for layoutcommit */
 };
 
 struct pnfs_layout_segment {
 	struct list_head pls_list;
+	struct list_head pls_lc_list;
 	struct pnfs_layout_range pls_range;
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5b11595..feb3127 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -262,7 +262,7 @@ struct nfs4_layoutcommit_res {
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

