From: andros@netapp.com
Subject: [PATCH 1/1] SQUASHME pnfs-submit: replace layoutcommit_ctx with rpc_cred
Date: Mon, 24 May 2010 14:28:46 -0400
Message-ID: <1274725726-19981-2-git-send-email-andros@netapp.com>
References: <1274725726-19981-1-git-send-email-andros@netapp.com>
Cc: bharrosh@panasas.com, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43968 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab0EXS2t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 14:28:49 -0400
In-Reply-To: <1274725726-19981-1-git-send-email-andros@netapp.com>
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
index 7fd33d9..2b8e8e6 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1110,7 +1110,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/*
 	 * file needs layout commit, server attributes may be stale
 	 */
-	if (nfsi->layoutcommit_ctx && nfsi->change_attr >= fattr->change_attr) {
+	if (do_layoutcommit(nfsi) && nfsi->change_attr >= fattr->change_attr) {
 		dprintk("NFS: %s: layoutcommit is needed for file %s/%ld\n",
 			__func__, inode->i_sb->s_id, inode->i_ino);
 		return 0;
@@ -1331,7 +1331,7 @@ static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 	nfsi->pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
-	nfsi->layoutcommit_ctx = NULL;
+	nfsi->lo_cred = NULL;
 	nfsi->pnfs_write_begin_pos = 0;
 	nfsi->pnfs_write_end_pos = 0;
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d145de1..bf03fde 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -589,7 +589,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 #ifdef CONFIG_NFS_V4_1
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
-		if (nfsi->layoutcommit_ctx)
+		if (do_layoutcommit(nfsi))
 			pnfs_layoutcommit_inode(state->inode, wait);
 		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
 			struct nfs4_pnfs_layout_segment range;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 20285bc..ee530c8 100644
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
+	if (has_layout(nfsi) && !do_layoutcommit(nfsi)) {
+		nfsi->lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
-		dprintk("%s: Set layoutcommit_ctx=%p\n", __func__,
-			nfsi->layoutcommit_ctx);
+		dprintk("%s: Set layoutcommit\n", __func__);
 		return;
 	}
 	spin_unlock(&nfsi->lo_lock);
@@ -755,7 +753,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 				!pnfs_return_layout_barrier(nfsi, &arg));
 		}
 
-		if (nfsi->layoutcommit_ctx) {
+		if (do_layoutcommit(nfsi)) {
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				dprintk("%s: layoutcommit failed, status=%d. "
@@ -1910,16 +1908,9 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
 
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
@@ -1929,9 +1920,7 @@ pnfs_layoutcommit_done(struct pnfs_layoutcommit_data *data)
 							&nfsi->layout,
 							&data->args,
 							data->status);
-
-	/* release the open_context acquired in pnfs_writeback_done */
-	put_nfs_open_context(data->ctx);
+	put_rpccred(data->cred);
 }
 
 /*
@@ -1995,24 +1984,27 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!nfsi->layoutcommit_ctx)
+	if (!do_layoutcommit(nfsi))
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
index a4c95a0..2c1918e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1490,7 +1490,7 @@ static int nfs_commit_inode(struct inode *inode, int how)
 					nfs_wait_bit_killable,
 					TASK_KILLABLE);
 #ifdef CONFIG_NFS_V4_1
-		if (may_wait && NFS_I(inode)->layoutcommit_ctx) {
+		if (may_wait && do_layoutcommit(NFS_I(inode))) {
 			error = pnfs_layoutcommit_inode(inode, 1);
 			if (error < 0)
 				return error;
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 4d47b48..c9ef43e 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -80,6 +80,12 @@ has_layout(struct nfs_inode *nfsi)
 	return nfsi->layout.ld_data != NULL;
 }
 
+static inline bool
+do_layoutcommit(struct nfs_inode *nfsi)
+{
+	return nfsi->lo_cred != NULL;
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 struct pnfs_layout_segment {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 98a8dc0..478b00c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -203,11 +203,10 @@ struct nfs_inode {
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
index a0bf341..154b04e 100644
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
1.6.2.5

