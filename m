Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:40234 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668Ab1GUTee (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 15:34:34 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 04/25] NFS41: save layoutcommit cred after first successful layoutget
Date: Thu, 21 Jul 2011 15:34:04 -0400
Message-Id: <1311276865-29484-5-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-1-git-send-email-rees@umich.edu>
References: <1311276865-29484-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Peng Tao <bergwolf@gmail.com>

Save it in layout header instead of in every segment.

Signed-off-by: Peng Tao <peng_tao@emc.com>
---
 fs/nfs/pnfs.c |   12 ++++++------
 fs/nfs/pnfs.h |    1 -
 2 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dae19dd..fbebd2a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -211,6 +211,7 @@ destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 	dprintk("%s: freeing layout cache %p\n", __func__, lo);
 	BUG_ON(!list_empty(&lo->plh_layouts));
 	NFS_I(lo->plh_inode)->layout = NULL;
+	put_rpccred(lo->plh_lc_cred);
 	pnfs_free_layout_hdr(lo);
 }
 
@@ -1007,6 +1008,10 @@ pnfs_update_layout(struct inode *ino,
 		list_del_init(&lo->plh_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
+	if (first) {
+		lo->plh_lc_cred =
+			get_rpccred(ctx->state->owner->so_cred);
+	}
 	atomic_dec(&lo->plh_outstanding);
 	put_layout_hdr(lo);
 out:
@@ -1386,8 +1391,6 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (!test_and_set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags)) {
 		mark_as_dirty = true;
-		nfsi->layout->plh_lc_cred =
-			get_rpccred(wdata->args.context->state->owner->so_cred);
 		dprintk("%s: Set layoutcommit for inode %lu ",
 			__func__, wdata->inode->i_ino);
 	}
@@ -1421,7 +1424,6 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 {
 	struct nfs4_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct rpc_cred *cred;
 	loff_t end_pos;
 	int status = 0;
 
@@ -1449,16 +1451,14 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
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
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5f1b532..bddd8b9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -46,7 +46,6 @@ struct pnfs_layout_segment {
 	atomic_t pls_refcount;
 	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
-	struct rpc_cred	*pls_lc_cred; /* LAYOUTCOMMIT credential */
 };
 
 enum pnfs_try_status {
-- 
1.7.4.1

