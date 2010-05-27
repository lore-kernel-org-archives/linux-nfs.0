From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/5] pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit
Date: Thu, 27 May 2010 21:13:37 +0300
Message-ID: <1274984017-26591-1-git-send-email-bhalevy@panasas.com>
References: <4BFEB5D4.30608@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:14047 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934554Ab0E0SNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:13:39 -0400
In-Reply-To: <4BFEB5D4.30608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>

So in blocklayoutdriver, we can use GFP_KERNEL to do memory
allocation in bl_setup_layoutcommit().

The state protected by the lo_lock here is clear now, which is the
layout_commit's position and state. .i.e write_begin/end_pos,
nfsi->lo_cred, and the call to pnfs_get_layout_stateid.

Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   66 +++++++++++++++++++++++++++++---------------------------
 1 files changed, 34 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dafd66e..80dbb8e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2161,15 +2161,22 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
  * Set up the argument/result storage required for the RPC call.
  */
 static int
-pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
+pnfs_layoutcommit_setup(struct inode *inode,
+			struct pnfs_layoutcommit_data *data,
+			loff_t write_begin_pos, loff_t write_end_pos, int sync)
 {
-	struct nfs_inode *nfsi = NFS_I(data->args.inode);
-	struct nfs_server *nfss = NFS_SERVER(data->args.inode);
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_server *nfss = NFS_SERVER(inode);
 	int result = 0;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
-	data->args.fh = NFS_FH(data->args.inode);
+
+	data->is_sync = sync;
+	data->args.inode = inode;
+	data->args.fh = NFS_FH(inode);
 	data->args.layout_type = nfss->pnfs_curr_ld->id;
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
 
 	/* TODO: Need to determine the correct values */
 	data->args.time_modify_changed = 0;
@@ -2177,26 +2184,19 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
 	/* Set values from inode so it can be reset
 	 */
 	data->args.lseg.iomode = IOMODE_RW;
-	data->args.lseg.offset = nfsi->pnfs_write_begin_pos;
-	data->args.lseg.length = nfsi->pnfs_write_end_pos - nfsi->pnfs_write_begin_pos + 1;
-	data->args.lastbytewritten =  min(nfsi->pnfs_write_end_pos,
-					i_size_read(&nfsi->vfs_inode) - 1);
+	data->args.lseg.offset = write_begin_pos;
+	data->args.lseg.length = write_end_pos - write_begin_pos + 1;
+	data->args.lastbytewritten =  min(write_end_pos,
+					  i_size_read(inode) - 1);
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
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
@@ -2208,6 +2208,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 {
 	struct pnfs_layoutcommit_data *data;
 	struct nfs_inode *nfsi = NFS_I(inode);
+	loff_t write_begin_pos;
+	loff_t write_end_pos;
+
 	int status = 0;
 
 	dprintk("%s Begin (sync:%d)\n", __func__, sync);
@@ -2219,39 +2222,38 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
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
+	if (!layoutcommit_needed(nfsi)) {
+		spin_unlock(&nfsi->lo_lock);
+		goto out_free;
+	}
 
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
+	write_begin_pos = nfsi->pnfs_write_begin_pos;
+	write_end_pos = nfsi->pnfs_write_end_pos;
+	data->cred = nfsi->lo_cred;
 	nfsi->pnfs_write_begin_pos = 0;
 	nfsi->pnfs_write_end_pos = 0;
 	nfsi->lo_cred = NULL;
+	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
 
+	spin_unlock(&nfsi->lo_lock);
+
+	/* Set up layout commit args */
+	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
+					 write_end_pos, sync);
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
1.6.6.1

