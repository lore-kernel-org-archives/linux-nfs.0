From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/8] pnfs-submit: clean struct nfs_inode
Date: Mon, 17 May 2010 10:56:37 -0700
Message-ID: <1274119004-30213-2-git-send-email-batsakis@netapp.com>
References: <1274119004-30213-1-git-send-email-batsakis@netapp.com>
Cc: linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3595 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754773Ab0EQR4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 May 2010 13:56:51 -0400
In-Reply-To: <1274119004-30213-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by moving layout specific fields from nfs_inode to struct pnfs_layout_type

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/inode.c         |   11 ++++---
 fs/nfs/nfs4state.c     |    2 +-
 fs/nfs/pnfs.c          |   70 ++++++++++++++++++++++++++----------------------
 fs/nfs/write.c         |    3 +-
 include/linux/nfs_fs.h |   25 ++++++++---------
 5 files changed, 59 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 9b8b655..ab599be 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1110,7 +1110,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	/*
 	 * file needs layout commit, server attributes may be stale
 	 */
-	if (nfsi->layoutcommit_ctx && nfsi->change_attr >= fattr->change_attr) {
+	if (nfsi->layout.layoutcommit_ctx &&
+	    nfsi->change_attr >= fattr->change_attr) {
 		dprintk("NFS: %s: layoutcommit is needed for file %s/%ld\n",
 			__func__, inode->i_sb->s_id, inode->i_ino);
 		return 0;
@@ -1328,12 +1329,12 @@ void nfs4_clear_inode(struct inode *inode)
 static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	nfsi->pnfs_layout_state = 0;
+	nfsi->layout.pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
-	nfsi->layoutcommit_ctx = NULL;
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
+	nfsi->layout.layoutcommit_ctx = NULL;
+	nfsi->layout.pnfs_write_begin_pos = 0;
+	nfsi->layout.pnfs_write_end_pos = 0;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 15c8bc8..3765ca1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -589,7 +589,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state, fmode_t fm
 #ifdef CONFIG_NFS_V4_1
 		struct nfs_inode *nfsi = NFS_I(state->inode);
 
-		if (nfsi->layoutcommit_ctx)
+		if (nfsi->layout.ld_data && nfsi->layout.layoutcommit_ctx)
 			pnfs_layoutcommit_inode(state->inode, 0);
 		if (has_layout(nfsi) && nfsi->layout.roc_iomode) {
 			struct nfs4_pnfs_layout_segment range;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8df1610..b72c013 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -152,14 +152,14 @@ void
 pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 {
 	dprintk("%s: has_layout=%d layoutcommit_ctx=%p ctx=%p\n", __func__,
-		has_layout(nfsi), nfsi->layoutcommit_ctx, ctx);
+		has_layout(nfsi), nfsi->layout.layoutcommit_ctx, ctx);
 	spin_lock(&nfsi->lo_lock);
-	if (has_layout(nfsi) && !nfsi->layoutcommit_ctx) {
-		nfsi->layoutcommit_ctx = get_nfs_open_context(ctx);
+	if (has_layout(nfsi) && !nfsi->layout.layoutcommit_ctx) {
+		nfsi->layout.layoutcommit_ctx = get_nfs_open_context(ctx);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
 		dprintk("%s: Set layoutcommit_ctx=%p\n", __func__,
-			nfsi->layoutcommit_ctx);
+			nfsi->layout.layoutcommit_ctx);
 		return;
 	}
 	spin_unlock(&nfsi->lo_lock);
@@ -176,17 +176,17 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 	loff_t end_pos;
 
 	spin_lock(&nfsi->lo_lock);
-	if (offset < nfsi->pnfs_write_begin_pos)
-		nfsi->pnfs_write_begin_pos = offset;
+	if (offset < nfsi->layout.pnfs_write_begin_pos)
+		nfsi->layout.pnfs_write_begin_pos = offset;
 	end_pos = offset + extent - 1; /* I'm being inclusive */
-	if (end_pos > nfsi->pnfs_write_end_pos)
-		nfsi->pnfs_write_end_pos = end_pos;
+	if (end_pos > nfsi->layout.pnfs_write_end_pos)
+		nfsi->layout.pnfs_write_end_pos = end_pos;
 	dprintk("%s: Wrote %lu@%lu bpos %lu, epos: %lu\n",
 		__func__,
 		(unsigned long) extent,
 		(unsigned long) offset ,
-		(unsigned long) nfsi->pnfs_write_begin_pos,
-		(unsigned long) nfsi->pnfs_write_end_pos);
+		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
+		(unsigned long) nfsi->layout.pnfs_write_end_pos);
 	spin_unlock(&nfsi->lo_lock);
 }
 
@@ -726,7 +726,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		arg.length = ~0;
 	}
 	if (type == RETURN_FILE) {
-		if (nfsi->layoutcommit_ctx) {
+		if (nfsi->layout.layoutcommit_ctx) {
 			status = pnfs_layoutcommit_inode(ino, 1);
 			if (status) {
 				dprintk("%s: layoutcommit failed, status=%d. "
@@ -903,7 +903,8 @@ get_lock_alloc_layout(struct inode *ino)
 		 * wait until bit is cleared if we lost this race.
 		 */
 		res = wait_on_bit_lock(
-			&nfsi->pnfs_layout_state, NFS_INO_LAYOUT_ALLOC,
+			&nfsi->layout.pnfs_layout_state,
+			NFS_INO_LAYOUT_ALLOC,
 			pnfs_wait_schedule, TASK_KILLABLE);
 		if (res) {
 			lo = ERR_PTR(res);
@@ -931,8 +932,10 @@ get_lock_alloc_layout(struct inode *ino)
 			lo = ERR_PTR(-ENOMEM);
 
 		/* release the NFS_INO_LAYOUT_ALLOC bit and wake up waiters */
-		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC, &nfsi->pnfs_layout_state);
-		wake_up_bit(&nfsi->pnfs_layout_state, NFS_INO_LAYOUT_ALLOC);
+		clear_bit_unlock(NFS_INO_LAYOUT_ALLOC,
+				 &nfsi->layout.pnfs_layout_state);
+		wake_up_bit(&nfsi->layout.pnfs_layout_state,
+			    NFS_INO_LAYOUT_ALLOC);
 		break;
 	}
 
@@ -1116,13 +1119,13 @@ pnfs_update_layout(struct inode *ino,
 	}
 
 	/* if get layout already failed once goto out */
-	if (test_bit(lo_fail_bit(iomode), &nfsi->pnfs_layout_state)) {
-		if (unlikely(nfsi->pnfs_layout_suspend &&
-		    get_seconds() >= nfsi->pnfs_layout_suspend)) {
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout.pnfs_layout_state)) {
+		if (unlikely(nfsi->layout.pnfs_layout_suspend &&
+		    get_seconds() >= nfsi->layout.pnfs_layout_suspend)) {
 			dprintk("%s: layout_get resumed\n", __func__);
 			clear_bit(lo_fail_bit(iomode),
-				  &nfsi->pnfs_layout_state);
-			nfsi->pnfs_layout_suspend = 0;
+				  &nfsi->layout.pnfs_layout_state);
+			nfsi->layout.pnfs_layout_suspend = 0;
 		} else {
 			result = 1;
 			goto out_put;
@@ -1138,7 +1141,8 @@ pnfs_update_layout(struct inode *ino,
 	result = get_layout(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-			__func__, result, nfsi->pnfs_layout_state, lseg);
+			__func__, result, nfsi->layout.pnfs_layout_state,
+		lseg);
 	return result;
 out_put:
 	if (lsegpp)
@@ -1243,13 +1247,14 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 
 get_out:
 	/* remember that get layout failed and suspend trying */
-	nfsi->pnfs_layout_suspend = suspend;
-	set_bit(lo_fail_bit(lgp->args.lseg.iomode), &nfsi->pnfs_layout_state);
+	nfsi->layout.pnfs_layout_suspend = suspend;
+	set_bit(lo_fail_bit(lgp->args.lseg.iomode),
+		&nfsi->layout.pnfs_layout_state);
 	dprintk("%s: layout_get suspended until %ld\n",
 		__func__, suspend);
 out:
 	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-		__func__, lgp->status, nfsi->pnfs_layout_state, lseg);
+		__func__, lgp->status, nfsi->layout.pnfs_layout_state, lseg);
 	return;
 }
 
@@ -2166,9 +2171,10 @@ pnfs_layoutcommit_setup(struct pnfs_layoutcommit_data *data, int sync)
 	/* Set values from inode so it can be reset
 	 */
 	data->args.lseg.iomode = IOMODE_RW;
-	data->args.lseg.offset = nfsi->pnfs_write_begin_pos;
-	data->args.lseg.length = nfsi->pnfs_write_end_pos - nfsi->pnfs_write_begin_pos + 1;
-	data->args.lastbytewritten = nfsi->pnfs_write_end_pos;
+	data->args.lseg.offset = nfsi->layout.pnfs_write_begin_pos;
+	data->args.lseg.length = nfsi->layout.pnfs_write_end_pos -
+	  nfsi->layout.pnfs_write_begin_pos + 1;
+	data->args.lastbytewritten = nfsi->layout.pnfs_write_end_pos;
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
@@ -2207,12 +2213,12 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 		return -ENOMEM;
 
 	spin_lock(&nfsi->lo_lock);
-	if (!nfsi->layoutcommit_ctx)
+	if (!nfsi->layout.layoutcommit_ctx)
 		goto out_unlock;
 
 	data->args.inode = inode;
-	data->cred  = nfsi->layoutcommit_ctx->cred;
-	data->ctx = nfsi->layoutcommit_ctx;
+	data->cred  = nfsi->layout.layoutcommit_ctx->cred;
+	data->ctx = nfsi->layout.layoutcommit_ctx;
 
 	/* Set up layout commit args*/
 	status = pnfs_layoutcommit_setup(data, sync);
@@ -2222,9 +2228,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
-	nfsi->layoutcommit_ctx = NULL;
+	nfsi->layout.pnfs_write_begin_pos = 0;
+	nfsi->layout.pnfs_write_end_pos = 0;
+	nfsi->layout.layoutcommit_ctx = NULL;
 
 	/* release lock on pnfs layoutcommit attrs */
 	spin_unlock(&nfsi->lo_lock);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d058781..57bfc85 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1494,7 +1494,8 @@ static int nfs_commit_inode(struct inode *inode, int how)
 					nfs_wait_bit_killable,
 					TASK_KILLABLE);
 #ifdef CONFIG_NFS_V4_1
-		if (may_wait && NFS_I(inode)->layoutcommit_ctx) {
+		if (may_wait && NFS_I(inode)->layout.ld_data &&
+		    NFS_I(inode)->layout.layoutcommit_ctx) {
 			error = pnfs_layoutcommit_inode(inode, 1);
 			if (error < 0)
 				return error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 68b3b5c..5048b97 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -106,6 +106,18 @@ struct pnfs_layout_type {
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
 	void *ld_data;			/* layout driver private data */
+	unsigned long pnfs_layout_state;
+	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
+	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
+	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
+	time_t pnfs_layout_suspend;
+	/* use rpc_creds in this open_context to send LAYOUTCOMMIT to MDS */
+	struct nfs_open_context *layoutcommit_ctx;
+	/* DH: These vars keep track of the maximum write range
+	 * so the values can be used for layoutcommit.
+	 */
+	loff_t                  pnfs_write_begin_pos;
+	loff_t                  pnfs_write_end_pos;
 };
 
 /*
@@ -197,22 +209,9 @@ struct nfs_inode {
 #if defined(CONFIG_NFS_V4_1)
 	/* Inodes having layouts */
 	struct list_head	lo_inodes;
-
-	unsigned long pnfs_layout_state;
-#define NFS_INO_RO_LAYOUT_FAILED 0 	/* get ro layout failed stop trying */
-#define NFS_INO_RW_LAYOUT_FAILED 1 	/* get rw layout failed stop trying */
-#define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
-	time_t pnfs_layout_suspend;
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
 	struct pnfs_layout_type layout;
-	/* use rpc_creds in this open_context to send LAYOUTCOMMIT to MDS */
-	struct nfs_open_context *layoutcommit_ctx;
-	/* DH: These vars keep track of the maximum write range
-	 * so the values can be used for layoutcommit.
-	 */
-	loff_t			pnfs_write_begin_pos;
-	loff_t			pnfs_write_end_pos;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.6.2.5

