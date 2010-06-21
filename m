From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/3] pnfs-submit: separate locking from get and put of layout
Date: Mon, 21 Jun 2010 09:16:35 -0400
Message-ID: <1277126197-2546-2-git-send-email-iisaman@netapp.com>
References: <1277126197-2546-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932328Ab0FUNQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jun 2010 09:16:52 -0400
Received: from localhost.localdomain (pl03676a.hq.netapp.com [10.58.60.107] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5LDGedv022922
	for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 06:16:41 -0700 (PDT)
In-Reply-To: <1277126197-2546-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed by next patch that changes refcounting

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   59 +++++++++++++++++++++++++++++----------------------------
 1 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 025675b..ed4c72e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -313,30 +313,20 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
 
-/*
- * get and lock nfsi->layout
- */
 static inline struct pnfs_layout_type *
-get_lock_current_layout(struct nfs_inode *nfsi)
+get_current_layout(struct nfs_inode *nfsi)
 {
-	struct pnfs_layout_type *lo;
+	struct pnfs_layout_type *lo = &nfsi->layout;
 
-	lo = &nfsi->layout;
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	if (!lo->ld_data) {
-		spin_unlock(&nfsi->vfs_inode.i_lock);
+	BUG_ON_UNLOCKED_LO(lo);
+	if (!lo->ld_data)
 		return NULL;
-	}
-
 	lo->refcount++;
 	return lo;
 }
 
-/*
- * put and unlock nfs->layout
- */
 static inline void
-put_unlock_current_layout(struct pnfs_layout_type *lo)
+put_current_layout(struct pnfs_layout_type *lo)
 {
 	struct inode *inode = PNFS_INODE(lo);
 	struct nfs_client *clp;
@@ -358,7 +348,6 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
 		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	spin_unlock(&inode->i_lock);
 }
 
 void
@@ -370,7 +359,8 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
-	put_unlock_current_layout(lo);
+	put_current_layout(lo);
+	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
 
@@ -384,11 +374,13 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		.length = NFS4_MAX_UINT64,
 	};
 
-	lo = get_lock_current_layout(nfsi);
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	lo = get_current_layout(nfsi);
 	if (lo) {
 		pnfs_free_layout(lo, &range);
-		put_unlock_current_layout(lo);
+		put_current_layout(lo);
 	}
+	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
 
 static inline void
@@ -751,12 +743,14 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	arg.length = NFS4_MAX_UINT64;
 
 	if (type == RETURN_FILE) {
-		lo = get_lock_current_layout(nfsi);
+		spin_lock(&ino->i_lock);
+		lo = get_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
-			put_unlock_current_layout(lo);
+			put_current_layout(lo);
 			lo = NULL;
 		}
 		if (!lo) {
+			spin_unlock(&ino->i_lock);
 			dprintk("%s: no layout segments to return\n", __func__);
 			goto out;
 		}
@@ -770,7 +764,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			if (stateid) { /* callback */
 				status = -EAGAIN;
 				spin_lock(&ino->i_lock);
-				put_unlock_current_layout(lo);
+				put_current_layout(lo);
+				spin_unlock(&ino->i_lock);
 				goto out;
 			}
 			dprintk("%s: waiting\n", __func__);
@@ -914,8 +909,7 @@ static int pnfs_wait_schedule(void *word)
  * get, possibly allocate, and lock current_layout
  *
  * Note: If successful, ino->i_lock is taken and the caller
- * must put and unlock current_layout by using put_unlock_current_layout()
- * when the returned layout is released.
+ * must put and unlock current_layout when the returned layout is released.
  */
 static struct pnfs_layout_type *
 get_lock_alloc_layout(struct inode *ino)
@@ -926,7 +920,9 @@ get_lock_alloc_layout(struct inode *ino)
 
 	dprintk("%s Begin\n", __func__);
 
-	while ((lo = get_lock_current_layout(nfsi)) == NULL) {
+	spin_lock(&ino->i_lock);
+	while ((lo = get_current_layout(nfsi)) == NULL) {
+		spin_unlock(&ino->i_lock);
 		/* Compete against other threads on who's doing the allocation,
 		 * wait until bit is cleared if we lost this race.
 		 */
@@ -942,8 +938,10 @@ get_lock_alloc_layout(struct inode *ino)
 		/* Was current_layout already allocated while we slept?
 		 * If so, retry get_lock'ing it. Otherwise, allocate it.
 		 */
-		if (nfsi->layout.ld_data)
+		if (nfsi->layout.ld_data) {
+			spin_lock(&ino->i_lock);
 			continue;
+		}
 
 		lo = alloc_init_layout(ino);
 		if (lo) {
@@ -1112,7 +1110,8 @@ out:
 out_put:
 	if (lsegpp)
 		*lsegpp = lseg;
-	put_unlock_current_layout(lo);
+	put_current_layout(lo);
+	spin_unlock(&ino->i_lock);
 	goto out;
 }
 
@@ -1328,11 +1327,13 @@ pnfs_getboundary(struct inode *inode)
 		goto out;
 
 	nfsi = NFS_I(inode);
-	lo = get_lock_current_layout(nfsi);;
+	spin_lock(&inode->i_lock);
+	lo = get_current_layout(nfsi);;
 	if (lo) {
 		stripe_size = policy_ops->get_stripesize(lo);
-		put_unlock_current_layout(lo);
+		put_current_layout(lo);
 	}
+	spin_unlock(&inode->i_lock);
 out:
 	return stripe_size;
 }
-- 
1.6.6.1

