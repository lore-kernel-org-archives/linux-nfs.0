From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Subject: [PATCH -v2] pnfs: unlock lo_lock spinlock before calling specific
 layoutdriver's setup_layoutcommit() operation
Date: Tue, 25 May 2010 16:51:26 +0800
Message-ID: <20100525085119.GA7998@vmware>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [221.122.61.232] ([221.122.61.232]:35583 "EHLO mx.bwstor.com.cn"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752114Ab0EYIwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 04:52:10 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So in blocklayoutdriver, we can use GFP_KERNEL to do memory
allocation in bl_setup_layoutcommit().

Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
---
 fs/nfs/pnfs.c |   63 ++++++++++++++++++++++++++------------------------------
 1 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d4e4ba9..bbd1548 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2075,15 +2075,23 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
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
+
+	data->is_sync = sync;
+	data->cred = nfsi->lo_cred;
+	data->args.inode = inode;
 	data->args.fh = NFS_FH(data->args.inode);
 	data->args.layout_type = nfss->pnfs_curr_ld->id;
+	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
 
 	/* TODO: Need to determine the correct values */
 	data->args.time_modify_changed = 0;
@@ -2098,19 +2106,21 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
+	/* Clear layoutcommit properties in the inode so
+	 * new lc info can be generated
+	 */
+	nfsi->pnfs_write_begin_pos = 0;
+	nfsi->pnfs_write_end_pos = 0;
+	nfsi->lo_cred = NULL;
+
+	spin_unlock(&nfsi->lo_lock);
+
 	/* Call layout driver to set the arguments.
 	 */
-	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit) {
+	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
 		result = nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit(
 				&nfsi->layout, &data->args);
-		if (result)
-			goto out;
-	}
-	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
-	data->res.fattr = &data->fattr;
-	nfs_fattr_init(&data->fattr);
 
-out:
 	dprintk("%s End Status %d\n", __func__, result);
 	return result;
 }
@@ -2133,39 +2143,24 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!layoutcommit_needed(nfsi))
-		goto out_unlock;
-
-	data->args.inode = inode;
-	data->cred = nfsi->lo_cred;
-
-	/* Set up layout commit args*/
-	status = pnfs_layoutcommit_setup(data, sync);
-
-	/* Clear layoutcommit properties in the inode so
-	 * new lc info can be generated
-	 */
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
-	nfsi->lo_cred = NULL;
+	if (!layoutcommit_needed(nfsi)) {
+		spin_unlock(&nfsi->lo_lock);
+		goto out_free;
+	}
 
+	/* Set up layout commit args */
+	status = pnfs_layoutcommit_setup(inode, data, sync);
 	if (status) {
 		/* The layout driver failed to setup the layoutcommit */
 		put_rpccred(data->cred);
-		goto out_unlock;
+		goto out_free;
 	}
-
-	/* release lock on pnfs layoutcommit attrs */
-	spin_unlock(&nfsi->lo_lock);
-
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

