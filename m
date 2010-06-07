From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 1/8] pnfs-submit: clean struct nfs_inode
Date: Mon,  7 Jun 2010 14:11:46 -0700
Message-ID: <1275945113-3436-2-git-send-email-batsakis@netapp.com>
References: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54324 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753289Ab0FGVLZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 17:11:25 -0400
In-Reply-To: <1275945113-3436-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

by moving layout specific fields from nfs_inode to struct pnfs_layout_type

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/inode.c            |    8 +++---
 fs/nfs/pnfs.c             |   55 ++++++++++++++++++++++++--------------------
 include/linux/nfs4_pnfs.h |    2 +-
 include/linux/nfs_fs.h    |   22 +++++++++---------
 4 files changed, 46 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b33d1a1..d43f2c5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1366,12 +1366,12 @@ void nfs4_clear_inode(struct inode *inode)
 static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
 {
 #ifdef CONFIG_NFS_V4_1
-	nfsi->pnfs_layout_state = 0;
+	nfsi->layout.pnfs_layout_state = 0;
 	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
 	nfsi->layout.roc_iomode = 0;
-	nfsi->lo_cred = NULL;
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
+	nfsi->layout.lo_cred = NULL;
+	nfsi->layout.pnfs_write_begin_pos = 0;
+	nfsi->layout.pnfs_write_end_pos = 0;
 #endif /* CONFIG_NFS_V4_1 */
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8cc4412..8620f68 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -154,7 +154,7 @@ pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
 	spin_lock(&nfsi->lo_lock);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
-		nfsi->lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		nfsi->change_attr++;
 		spin_unlock(&nfsi->lo_lock);
 		dprintk("%s: Set layoutcommit\n", __func__);
@@ -174,17 +174,17 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
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
 
@@ -915,7 +915,8 @@ get_lock_alloc_layout(struct inode *ino)
 		 * wait until bit is cleared if we lost this race.
 		 */
 		res = wait_on_bit_lock(
-			&nfsi->pnfs_layout_state, NFS_INO_LAYOUT_ALLOC,
+			&nfsi->layout.pnfs_layout_state,
+			NFS_INO_LAYOUT_ALLOC,
 			pnfs_wait_schedule, TASK_KILLABLE);
 		if (res) {
 			lo = ERR_PTR(res);
@@ -943,8 +944,10 @@ get_lock_alloc_layout(struct inode *ino)
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
 
@@ -1104,13 +1107,13 @@ pnfs_update_layout(struct inode *ino,
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
@@ -1126,7 +1129,8 @@ pnfs_update_layout(struct inode *ino,
 	result = get_layout(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end (err:%d) state 0x%lx lseg %p\n",
-			__func__, result, nfsi->pnfs_layout_state, lseg);
+			__func__, result, nfsi->layout.pnfs_layout_state,
+		lseg);
 	return result;
 out_put:
 	if (lsegpp)
@@ -1231,13 +1235,14 @@ pnfs_get_layout_done(struct nfs4_pnfs_layoutget *lgp, int rpc_status)
 
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
 
@@ -2009,12 +2014,12 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	/* Clear layoutcommit properties in the inode so
 	 * new lc info can be generated
 	 */
-	write_begin_pos = nfsi->pnfs_write_begin_pos;
-	write_end_pos = nfsi->pnfs_write_end_pos;
-	data->cred = nfsi->lo_cred;
-	nfsi->pnfs_write_begin_pos = 0;
-	nfsi->pnfs_write_end_pos = 0;
-	nfsi->lo_cred = NULL;
+	write_begin_pos = nfsi->layout.pnfs_write_begin_pos;
+	write_end_pos = nfsi->layout.pnfs_write_end_pos;
+	data->cred = nfsi->layout.lo_cred;
+	nfsi->layout.pnfs_write_begin_pos = 0;
+	nfsi->layout.pnfs_write_end_pos = 0;
+	nfsi->layout.lo_cred = NULL;
 	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
 
 	spin_unlock(&nfsi->lo_lock);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 84d2e95..53626d4 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -83,7 +83,7 @@ has_layout(struct nfs_inode *nfsi)
 static inline bool
 layoutcommit_needed(struct nfs_inode *nfsi)
 {
-	return nfsi->lo_cred != NULL;
+	return nfsi->layout.lo_cred != NULL;
 }
 
 #endif /* CONFIG_NFS_V4_1 */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 2762b2c..45846c5 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -106,6 +106,17 @@ struct pnfs_layout_type {
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
 	void *ld_data;			/* layout driver private data */
+	unsigned long pnfs_layout_state;
+	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
+	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
+	#define NFS_INO_LAYOUT_ALLOC     2      /* bit lock for layout allocation */
+	time_t pnfs_layout_suspend;
+	struct rpc_cred         *lo_cred; /* layoutcommit credential */
+	/* DH: These vars keep track of the maximum write range
+	 * so the values can be used for layoutcommit.
+	 */
+	loff_t                  pnfs_write_begin_pos;
+	loff_t                  pnfs_write_end_pos;
 };
 
 /*
@@ -198,20 +209,9 @@ struct nfs_inode {
 	/* Inodes having layouts */
 	struct list_head	lo_inodes;
 
-	unsigned long pnfs_layout_state;
-#define NFS_INO_RO_LAYOUT_FAILED 0 	/* get ro layout failed stop trying */
-#define NFS_INO_RW_LAYOUT_FAILED 1 	/* get rw layout failed stop trying */
-#define NFS_INO_LAYOUT_ALLOC     2	/* bit lock for layout allocation */
-	time_t pnfs_layout_suspend;
-	struct rpc_cred		*lo_cred; /* layoutcommit credential */
 	wait_queue_head_t lo_waitq;
 	spinlock_t lo_lock;
 	struct pnfs_layout_type layout;
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

