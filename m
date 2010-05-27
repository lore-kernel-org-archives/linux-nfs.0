From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/5] pnfs-submit: replace layoutcommit_ctx with rpc_cred
Date: Thu, 27 May 2010 21:13:25 +0300
Message-ID: <1274984005-26554-1-git-send-email-bhalevy@panasas.com>
References: <4BFEB5D4.30608@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:10472 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933992Ab0E0SN1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:13:27 -0400
In-Reply-To: <4BFEB5D4.30608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Taking a reference on the nfs_open_context to signal that a layoutcommit is
needed is problematic because the last reference to the context triggers a
close (nfs_release).  But, if the layout holds a reference on the
nfs_open_context, then close will not be triggered.

Since we only use the rpc credential from the layoutcommit_ctx, replace the
layoutcommit_ctx with the rpc_cred.

Hold a reference on the rpc_cred until the layoutcommit rpc returns.

If the layoutdriver fails to setup the layoutcommit, clear the layoutcommit
properties and put the credential.

Signed-off-by: Andy Adamson <andros@netapp.com>
Tested-by: Boaz Harrosh <bharrosh@panasas.com>
[s/do_layoutcommit/layoutcommit_needed/]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/inode.c            |    4 ++--
 fs/nfs/nfs4state.c        |    2 +-
 fs/nfs/pnfs.c             |   42 +++++++++++++++++-------------------------
 fs/nfs/write.c            |    2 +-
 include/linux/nfs4_pnfs.h |    6 ++++++
 include/linux/nfs_fs.h    |    3 +--
 include/linux/pnfs_xdr.h  |    1 -
 7 files changed, 28 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 8661036..15c60fc 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1178,7 +1178,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/*
 	 * file needs layout commit, server attributes may be stale
 	 */
-	if (nfsi->layoutcommit_ctx && nfsi->change_attr >= fattr->change_attr) {
+	if (layoutcommit_needed(nfsi) && nfsi->change_attr >= fattr->change_attr) {
 		dprintk("NFS: %s: layoutcommit is needed for file %s/%ld\n",
 			__func__, inode->i_sb->s_id, inode->i_ino);
 		return 0;
@@ -1399,7 +1399,7 @@ static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 	nfsi->pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
-	nfsi->layoutcommit_ctx = NULL;
+	nfsi->lo_cred = NULL;
 	nfsi->pnfs_write_begin_pos = 0;
 	nfsi->pnfs_write_end_pos = 0;
 #endif /* CONFIG_PNFS */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a415e9d..9116e45 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -589,7 +589,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 #ifdef CONFIG_PNFS
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
-		if (nfsi->layoutcommit_ctx)
+		if (layoutcommit_needed(nfsi))
 			pnfs_layoutcommit_inode(state->inode, wait);
 		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
 			struct nfs4_pnfs_layout_segment range;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 51a4a9c..dafd66e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -145,21 +145,19 @@ find_pnfs(u32 id, struct pnfs_module **module) {
 	return 0;
 }
 
-/* Set context to indicate we require a layoutcommit
+/* Set lo_cred to indicate we require a layoutcommit
  * If we don't even have a layout, we don't need to commit it.
  */
 void
 pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 {
-	dprintk("%s: has_layout=%d layoutcommit_ctx=%p ctx=%p\n", __func__,
-		has_layout(nfsi), nfsi->layoutcommit_ctx, ctx);
+	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
 	spin_lock(&nfsi->lo_lock);
-	if (has_layout(nfsi) && !nfsi->layoutcommit_ctx) {
-		nfsi->layoutcommit_ctx = get_nfs_open_context(ctx);
+	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
+		nfsi->lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
-		dprintk("%s: Set layoutcommit_ctx=%p\n", __func__,
-			nfsi->layoutcommit_ctx);
+		dprintk("%s: Set layoutcommit\n", __func__);
 		return;
 	}
 	spin_unlock(&nfsi->lo_lock);
@@ -761,7 +759,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 				!pnfs_return_layout_barrier(nfsi, &arg));
 		}
 
-		if (nfsi->layoutcommit_ctx) {
+		if (layoutcommit_needed(nfsi)) {
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				dprintk("%s: layoutcommit failed, status=%d. "
@@ -2144,16 +2142,9 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
 
 	dprintk("%s: (status %d)\n", __func__, data->status);
 
-	/* TODO: For now, set an error in the open context (just like
-	 * if a commit failed) We may want to do more, much more, like
-	 * replay all writes through the NFSv4
-	 * server, or something.
-	 */
-	if (data->status < 0) {
+	if (data->status < 0)
 		printk(KERN_ERR "%s, Layoutcommit Failed! = %d\n",
 		       __func__, data->status);
-		data->ctx->error = data->status;
-	}
 
 	/* TODO: Maybe we should avoid this by allowing the layout driver
 	 * to directly xdr its layout on the wire.
@@ -2163,9 +2154,7 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
 							&nfsi->layout,
 							&data->args,
 							data->status);
-
-	/* release the open_context acquired in pnfs_writeback_done */
-	put_nfs_open_context(data->ctx);
+	put_rpccred(data->cred);
 }
 
 /*
@@ -2230,24 +2219,27 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!nfsi->layoutcommit_ctx)
+	if (!layoutcommit_needed(nfsi))
 		goto out_unlock;
 
 	data->args.inode = inode;
-	data->cred  = nfsi->layoutcommit_ctx->cred;
-	data->ctx = nfsi->layoutcommit_ctx;
+	data->cred = nfsi->lo_cred;
 
 	/* Set up layout commit args*/
 	status = pnfs_layoutcommit_setup(data, sync);
-	if (status)
-		goto out_unlock;
 
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
 	nfsi->pnfs_write_begin_pos = 0;
 	nfsi->pnfs_write_end_pos = 0;
-	nfsi->layoutcommit_ctx = NULL;
+	nfsi->lo_cred = NULL;
+
+	if (status) {
+		/* The layout driver failed to setup the layoutcommit */
+		put_rpccred(data->cred);
+		goto out_unlock;
+	}
 
 	/* release lock on pnfs layoutcommit attrs */
 	spin_unlock(&nfsi->lo_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 4f01089..3a7679f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1555,7 +1555,7 @@ long nfs_sync_mapping_wait(struct address_space *mapping, struct writeback_contr
 	} while (ret >= 0);
 	spin_unlock(&inode->i_lock);
 #ifdef CONFIG_PNFS
-	if (how == 0 && ret == 0 && NFS_I(inode)->layoutcommit_ctx) {
+	if (how == 0 && ret == 0 && layoutcommit_needed(NFS_I(inode))) {
 		dprintk("%s calling layoutcommit\n", __func__);
 		ret = pnfs_layoutcommit_inode(inode, 1);
 	}
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index d997b69..514c6a3 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -100,6 +100,12 @@ has_layout(struct nfs_inode *nfsi)
 	return nfsi->layout.ld_data != NULL;
 }
 
+static inline bool
+layoutcommit_needed(struct nfs_inode *nfsi)
+{
+	return nfsi->lo_cred != NULL;
+}
+
 struct pnfs_layout_segment {
 	struct list_head fi_list;
 	struct nfs4_pnfs_layout_segment range;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index dd57a6a..aeb5e87 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -205,11 +205,10 @@ struct nfs_inode {
 #define NFS_INO_RW_LAYOUT_FAILED 1 	/* get rw layout failed stop trying */
 #define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
 	time_t pnfs_layout_suspend;
+	struct rpc_cred		*lo_cred; /* layoutcommit credential */
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
 	struct pnfs_layout_type layout;
-	/* use rpc_creds in this open_context to send LAYOUTCOMMIT to MDS */
-	struct nfs_open_context *layoutcommit_ctx;
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
 	 */
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 4f34aa8..ecfe5c2 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -86,7 +86,6 @@ struct pnfs_layoutcommit_data {
 	bool is_sync;
 	struct rpc_cred *cred;
 	struct nfs_fattr fattr;
-	struct nfs_open_context *ctx;
 	struct pnfs_layoutcommit_arg args;
 	struct pnfs_layoutcommit_res res;
 	int status;
-- 
1.6.6.1

