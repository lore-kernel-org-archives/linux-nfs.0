From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: [RFC][PATCH] pnfs: unlock lo_lock spinlock before calling specific
 layoutdriver's setup_layoutcommit() operation.
Date: Thu, 20 May 2010 18:25:19 +0800
Message-ID: <20100520102507.GA31886@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:33113 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751614Ab0ETKZe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:25:34 -0400
Received: from vmware ([221.122.61.226])
	(authenticated bits=0)
	by mx.bwstor.com.cn (8.13.8/8.13.8) with ESMTP id o4KAPP91006829
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 18:25:31 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So in blocklayoutdriver, we can use GFP_KERNEL to do memory
allocation in bl_setup_layoutcommit().

Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
---
 fs/nfs/pnfs.c |   42 +++++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index aedda1e..8474731 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2073,15 +2073,23 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
  * Set up the argument/result storage required for the RPC call.
  */
 static int
-pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
+pnfs_layoutcommit_setup(struct inode *inode,
+			struct pnfs_layoutcommit_data *data, int sync)
 {
-	struct nfs_inode *nfsi = NFS_I(data->args.inode);
-	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int result = 0;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
+	data->is_sync = sync;
+	data->cred  = nfsi->layoutcommit_ctx->cred;
+	data->ctx = nfsi->layoutcommit_ctx;
+	data->args.inode = inode;
 	data->args.fh = NFS_FH(data->args.inode);
 	data->args.layout_type = nfss->pnfs_curr_ld->id;
+	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
 
 	/* TODO: Need to determine the correct values */
 	data->args.time_modify_changed = 0;
@@ -2095,6 +2103,7 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
 					i_size_read(&nfsi->vfs_inode) - 1);
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
+	spin_unlock(&nfsi->lo_lock);
 
 	/* Call layout driver to set the arguments.
 	 */
@@ -2104,10 +2113,6 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
 		if (result)
 			goto out;
 	}
-	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
-	data->res.fattr = &data->fattr;
-	nfs_fattr_init(&data->fattr);
-
 out:
 	dprintk("%s End Status %d\n", __func__, result);
 	return result;
@@ -2131,36 +2136,31 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!nfsi->layoutcommit_ctx)
-		goto out_unlock;
-
-	data->args.inode = inode;
-	data->cred  = nfsi->layoutcommit_ctx->cred;
-	data->ctx = nfsi->layoutcommit_ctx;
+	if (!nfsi->layoutcommit_ctx) {
+		spin_unlock(&nfsi->lo_lock);
+		goto out_free;
+	}
 
-	/* Set up layout commit args*/
-	status = pnfs_layoutcommit_setup(data, sync);
+	/* Set up layout commit args */
+	status = pnfs_layoutcommit_setup(inode, data, sync);
 	if (status)
-		goto out_unlock;
+		goto out_free;
 
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
+	spin_lock(&nfsi->lo_lock);
 	nfsi->pnfs_write_begin_pos = 0;
 	nfsi->pnfs_write_end_pos = 0;
 	nfsi->layoutcommit_ctx = NULL;
-
-	/* release lock on pnfs layoutcommit attrs */
 	spin_unlock(&nfsi->lo_lock);
 
-	data->is_sync = sync;
 	status = pnfs4_proc_layoutcommit(data);
 out:
 	dprintk("%s end (err:%d)\n", __func__, status);
 	return status;
-out_unlock:
+out_free:
 	pnfs_layoutcommit_free(data);
-	spin_unlock(&nfsi->lo_lock);
 	goto out;
 }
 
-- 
1.6.3.3

