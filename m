From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 2/8] pnfs-submit: clean locking infrastructure
Date: Wed,  5 May 2010 10:00:52 -0700
Message-ID: <1273078858-1923-3-git-send-email-batsakis@netapp.com>
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
 <1273078858-1923-2-git-send-email-batsakis@netapp.com>
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab0FGF10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 01:27:26 -0400
In-Reply-To: <1273078858-1923-2-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(also minor cleanup of pnfs_free_layout())

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/pnfs.c |   73 ++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 47 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f32dbbb..a4031b4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -60,6 +60,8 @@ static int pnfs_initialized;
 static void pnfs_free_layout(struct pnfs_layout_type *lo,
 			     struct nfs4_pnfs_layout_segment *range);
 static enum pnfs_try_status pnfs_commit(struct nfs_write_data *data, int sync);
+static inline void lock_current_layout(struct nfs_inode *nfsi);
+static inline void unlock_current_layout(struct nfs_inode *nfsi);
 
 /* Locking:
  *
@@ -152,15 +154,15 @@ void
 pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
 {
 	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	if (has_layout(nfsi) && !layoutcommit_needed(nfsi)) {
 		nfsi->layout.lo_cred = get_rpccred(ctx->state->owner->so_cred);
 		nfsi->change_attr++;
-		spin_unlock(&nfsi->lo_lock);
+		unlock_current_layout(nfsi);
 		dprintk("%s: Set layoutcommit\n", __func__);
 		return;
 	}
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 }
 
 /* Update last_write_offset for layoutcommit.
@@ -173,7 +175,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 {
 	loff_t end_pos;
 
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	if (offset < nfsi->layout.pnfs_write_begin_pos)
 		nfsi->layout.pnfs_write_begin_pos = offset;
 	end_pos = offset + extent - 1; /* I'm being inclusive */
@@ -185,7 +187,7 @@ pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
 		(unsigned long) offset ,
 		(unsigned long) nfsi->layout.pnfs_write_begin_pos,
 		(unsigned long) nfsi->layout.pnfs_write_end_pos);
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 }
 
 /* Unitialize a mountpoint in a layout driver */
@@ -313,6 +315,17 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
 
+static inline void lock_current_layout(struct nfs_inode *nfsi)
+{
+	spin_lock(&nfsi->lo_lock);
+}
+
+static inline void unlock_current_layout(struct nfs_inode *nfsi)
+{
+	BUG_ON_UNLOCKED_LO((&nfsi->layout));
+	spin_unlock(&nfsi->lo_lock);
+}
+
 /*
  * get and lock nfsi->layout
  */
@@ -321,10 +334,10 @@ get_lock_current_layout(struct nfs_inode *nfsi)
 {
 	struct pnfs_layout_type *lo;
 
+	lock_current_layout(nfsi);
 	lo = &nfsi->layout;
-	spin_lock(&nfsi->lo_lock);
 	if (!lo->ld_data) {
-		spin_unlock(&nfsi->lo_lock);
+		unlock_current_layout(nfsi);
 		return NULL;
 	}
 
@@ -344,7 +357,12 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
 	BUG_ON_UNLOCKED_LO(lo);
 	BUG_ON(lo->refcount <= 0);
 
-	if (--lo->refcount == 0 && list_empty(&lo->segs)) {
+	lo->refcount--;
+
+	if (lo->refcount > 0)
+		goto out;
+
+	if (list_empty(&lo->segs)) {
 		struct layoutdriver_io_operations *io_ops =
 			PNFS_LD_IO_OPS(lo);
 
@@ -358,7 +376,8 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
 		list_del_init(&nfsi->lo_inodes);
 		spin_unlock(&clp->cl_lock);
 	}
-	spin_unlock(&nfsi->lo_lock);
+out:
+	unlock_current_layout(nfsi);
 }
 
 void
@@ -367,7 +386,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo, atomic_t *count,
 {
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	if (range)
 		pnfs_free_layout(lo, range);
 	atomic_dec(count);
@@ -386,6 +405,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	};
 
 	lo = get_lock_current_layout(nfsi);
+	if (!lo)
+		return;
 	pnfs_free_layout(lo, &range);
 	put_unlock_current_layout(lo);
 }
@@ -663,7 +684,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	struct pnfs_layout_segment *lseg;
 	bool ret = false;
 
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	list_for_each_entry (lseg, &nfsi->layout.segs, fi_list) {
 		if (!should_free_lseg(lseg, range))
 			continue;
@@ -677,7 +698,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	}
 	if (atomic_read(&nfsi->layout.lgetcount))
 		ret = true;
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 
 	dprintk("%s:Return %d\n", __func__, ret);
 	return ret;
@@ -759,7 +780,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 		/* unlock w/o put rebalanced by eventual call to
 		 * pnfs_layout_release
 		 */
-		spin_unlock(&nfsi->lo_lock);
+		unlock_current_layout(nfsi);
 
 		if (pnfs_return_layout_barrier(nfsi, &arg)) {
 			dprintk("%s: waiting\n", __func__);
@@ -900,7 +921,7 @@ static int pnfs_wait_schedule(void *word)
  *
  * Note: If successful, nfsi->lo_lock is taken and the caller
  * must put and unlock current_layout by using put_unlock_current_layout()
- * when the returned layout is released.
+ * directly or pnfs_layout_release() when the returned layout is released.
  */
 static struct pnfs_layout_type *
 get_lock_alloc_layout(struct inode *ino)
@@ -935,7 +956,7 @@ get_lock_alloc_layout(struct inode *ino)
 			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 
 			/* must grab the layout lock before the client lock */
-			spin_lock(&nfsi->lo_lock);
+			lock_current_layout(nfsi);
 
 			spin_lock(&clp->cl_lock);
 			if (list_empty(&nfsi->lo_inodes))
@@ -1051,10 +1072,10 @@ void drain_layoutreturns(struct pnfs_layout_type *lo)
 	while (atomic_read(&lo->lretcount)) {
 		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 
-		spin_unlock(&nfsi->lo_lock);
+		unlock_current_layout(nfsi);
 		dprintk("%s: waiting\n", __func__);
 		wait_event(nfsi->lo_waitq, (atomic_read(&lo->lretcount) == 0));
-		spin_lock(&nfsi->lo_lock);
+		lock_current_layout(nfsi);
 	}
 }
 
@@ -1093,13 +1114,13 @@ pnfs_update_layout(struct inode *ino,
 	/* Check to see if the layout for the given range already exists */
 	lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
 	if (lseg && !lseg->valid) {
-		spin_unlock(&nfsi->lo_lock);
+		unlock_current_layout(nfsi);
 		if (take_ref)
 			put_lseg(lseg);
 		for (;;) {
 			prepare_to_wait(&nfsi->lo_waitq, &__wait,
 					TASK_KILLABLE);
-			spin_lock(&nfsi->lo_lock);
+			lock_current_layout(nfsi);
 			lseg = pnfs_has_layout(lo, &arg, take_ref, !take_ref);
 			if (!lseg || lseg->valid)
 				break;
@@ -1112,7 +1133,7 @@ pnfs_update_layout(struct inode *ino,
 				result = -ERESTARTSYS;
 				break;
 			}
-			spin_unlock(&nfsi->lo_lock);
+			unlock_current_layout(nfsi);
 			schedule();
 		}
 		finish_wait(&nfsi->lo_waitq, &__wait);
@@ -1149,7 +1170,7 @@ pnfs_update_layout(struct inode *ino,
 	/* Matching dec is done in .rpc_release (on non-error paths) */
 	atomic_inc(&lo->lgetcount);
 	/* Lose lock, but not reference, match this with pnfs_layout_release */
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 
 	result = get_layout(ino, ctx, &arg, lsegpp, lo);
 out:
@@ -1299,7 +1320,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 		*lgp->lsegpp = lseg;
 	}
 
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	pnfs_insert_layout(lo, lseg);
 
 	if (res->return_on_close) {
@@ -1310,7 +1331,7 @@ pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp)
 
 	/* Done processing layoutget. Set the layout stateid */
 	pnfs_set_layout_stateid(lo, &res->stateid);
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 out:
 	return status;
 }
@@ -2140,9 +2161,9 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	if (!data)
 		return -ENOMEM;
 
-	spin_lock(&nfsi->lo_lock);
+	lock_current_layout(nfsi);
 	if (!layoutcommit_needed(nfsi)) {
-		spin_unlock(&nfsi->lo_lock);
+		lock_current_layout(nfsi);
 		goto out_free;
 	}
 
@@ -2157,7 +2178,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout.lo_cred = NULL;
 	pnfs_get_layout_stateid(&data->args.stateid, &nfsi->layout);
 
-	spin_unlock(&nfsi->lo_lock);
+	unlock_current_layout(nfsi);
 
 	/* Set up layout commit args */
 	status = pnfs_layoutcommit_setup(inode, data, write_begin_pos,
-- 
1.6.2.5

