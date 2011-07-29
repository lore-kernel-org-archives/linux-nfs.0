Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:43345 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815Ab1G2Py4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 11:54:56 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v5 07/27] NFS41: save layoutcommit cred in layout header init
Date: Fri, 29 Jul 2011 11:54:32 -0400
Message-Id: <1311954892-22038-8-git-send-email-rees@umich.edu>
In-Reply-To: <1311954892-22038-1-git-send-email-rees@umich.edu>
References: <1311954892-22038-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

No need to save it at every pnfs_set_layoutcommit.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e2c1eb4..3a47f7c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -201,6 +201,7 @@ static void
 pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(lo->plh_inode)->pnfs_curr_ld;
+	put_rpccred(lo->plh_lc_cred);
 	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
 }
 
@@ -828,7 +829,9 @@ out:
 }
 
 static struct pnfs_layout_hdr *
-alloc_init_layout_hdr(struct inode *ino, gfp_t gfp_flags)
+alloc_init_layout_hdr(struct inode *ino,
+		      struct nfs_open_context *ctx,
+		      gfp_t gfp_flags)
 {
 	struct pnfs_layout_hdr *lo;
 
@@ -840,11 +843,14 @@ alloc_init_layout_hdr(struct inode *ino, gfp_t gfp_flags)
 	INIT_LIST_HEAD(&lo->plh_segs);
 	INIT_LIST_HEAD(&lo->plh_bulk_recall);
 	lo->plh_inode = ino;
+	lo->plh_lc_cred = get_rpccred(ctx->state->owner->so_cred);
 	return lo;
 }
 
 static struct pnfs_layout_hdr *
-pnfs_find_alloc_layout(struct inode *ino, gfp_t gfp_flags)
+pnfs_find_alloc_layout(struct inode *ino,
+		       struct nfs_open_context *ctx,
+		       gfp_t gfp_flags)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct pnfs_layout_hdr *new = NULL;
@@ -859,7 +865,7 @@ pnfs_find_alloc_layout(struct inode *ino, gfp_t gfp_flags)
 			return nfsi->layout;
 	}
 	spin_unlock(&ino->i_lock);
-	new = alloc_init_layout_hdr(ino, gfp_flags);
+	new = alloc_init_layout_hdr(ino, ctx, gfp_flags);
 	spin_lock(&ino->i_lock);
 
 	if (likely(nfsi->layout == NULL))	/* Won the race? */
@@ -952,7 +958,7 @@ pnfs_update_layout(struct inode *ino,
 	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
 		return NULL;
 	spin_lock(&ino->i_lock);
-	lo = pnfs_find_alloc_layout(ino, gfp_flags);
+	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
 	if (lo == NULL) {
 		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
 		goto out_unlock;
@@ -1385,8 +1391,6 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		mark_as_dirty = true;
-		nfsi->layout->plh_lc_cred =
-			get_rpccred(wdata->args.context->state->owner->so_cred);
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
@@ -1420,7 +1424,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct rpc_cred *cred;
 	loff_t end_pos;
 	int status = 0;
 
@@ -1448,16 +1451,14 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	pnfs_list_write_lseg(inode, &data->lseg_list);
 
 	end_pos = nfsi->layout->plh_lwb;
-	cred = nfsi->layout->plh_lc_cred;
 	nfsi->layout->plh_lwb = 0;
-	nfsi->layout->plh_lc_cred = NULL;
 
 	memcpy(&data->args.stateid.data, nfsi->layout->plh_stateid.data,
 		sizeof(nfsi->layout->plh_stateid.data));
 	spin_unlock(&inode->i_lock);
 
 	data->args.inode = inode;
-	data->cred = cred;
+	data->cred = get_rpccred(nfsi->layout->plh_lc_cred);
 	nfs_fattr_init(&data->fattr);
 	data->args.bitmask = NFS_SERVER(inode)->cache_consistency_bitmask;
 	data->res.fattr = &data->fattr;
-- 
1.7.4.1

