Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:53775 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab1G0Sku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:40:50 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 03/25] NFS41: Let layoutcommit handle multiple segments
Date: Wed, 27 Jul 2011 14:40:26 -0400
Message-Id: <1311792048-12551-4-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Some layout drivers like block will have multiple segments.  Generic code
should be able to handle it.  Layoutcommit takes a list of segments and last
write offset is saved at inode level.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/nfs4proc.c       |    8 ++++++-
 fs/nfs/nfs4xdr.c        |    2 +-
 fs/nfs/pnfs.c           |   50 ++++++++++++++++++++++++----------------------
 fs/nfs/pnfs.h           |    5 +++-
 include/linux/nfs_xdr.h |    2 +-
 6 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be93a62..e8915d4 100644
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
index ebb6f1a..af32d3d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5960,9 +5960,15 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
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
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a82dd40..c149cbe 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1955,7 +1955,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
 	/* Only whole file layouts */
 	p = xdr_encode_hyper(p, 0); /* offset */
-	p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
+	p = xdr_encode_hyper(p, args->lastbytewritten + 1);	/* length */
 	*p++ = cpu_to_be32(0); /* reclaim */
 	p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
 	*p++ = cpu_to_be32(1); /* newoffset = TRUE */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8e72724..dae19dd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -236,6 +236,7 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
+	INIT_LIST_HEAD(&lseg->pls_lc_list);
 	atomic_set(&lseg->pls_refcount, 1);
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
@@ -1362,16 +1363,17 @@ pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc)
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
@@ -1383,17 +1385,21 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
-		/* references matched in nfs4_layoutcommit_release */
-		get_lseg(wdata->lseg);
-		wdata->lseg->pls_lc_cred =
-			get_rpccred(wdata->args.context->state->owner->so_cred);
 		mark_as_dirty = true;
+		nfsi->layout->plh_lc_cred =
+			get_rpccred(wdata->args.context->state->owner->so_cred);
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
-	if (end_pos > wdata->lseg->pls_end_pos)
-		wdata->lseg->pls_end_pos = end_pos;
+	if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &wdata->lseg->pls_flags)) {
+		/* references matched in nfs4_layoutcommit_release */
+		get_lseg(wdata->lseg);
+	}
+	if (end_pos > nfsi->layout->plh_lwb)
+		nfsi->layout->plh_lwb = end_pos;
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+	dprintk("%s: lseg %p end_pos %llu\n",
+		__func__, wdata->lseg, nfsi->layout->plh_lwb);
 
 	/* if pnfs_layoutcommit_inode() runs between inode locks, the next one
 	 * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
@@ -1415,7 +1421,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct pnfs_layout_segment *lseg;
 	struct rpc_cred *cred;
 	loff_t end_pos;
 	int status = 0;
@@ -1433,29 +1438,26 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
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
 
-	end_pos = lseg->pls_end_pos;
-	cred = lseg->pls_lc_cred;
-	lseg->pls_end_pos = 0;
-	lseg->pls_lc_cred = NULL;
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
index 23d8267..5f1b532 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -36,16 +36,17 @@
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
 	struct pnfs_layout_hdr *pls_layout;
 	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
-	loff_t pls_end_pos; /* LAYOUTCOMMIT write end */
 };
 
 enum pnfs_try_status {
@@ -128,6 +129,8 @@ struct pnfs_layout_hdr {
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	u32			plh_barrier; /* ignore lower seqids */
 	unsigned long		plh_flags;
+	loff_t			plh_lwb; /* last write byte for layoutcommit */
+	struct rpc_cred		*plh_lc_cred; /* layoutcommit cred */
 	struct inode		*plh_inode;
 };
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a07b682..21f333e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -273,7 +273,7 @@ struct nfs4_layoutcommit_res {
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

