From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 01/10] pnfs-submit: separate locking from get and put of layout
Date: Mon, 14 Jun 2010 21:46:06 -0400
Message-ID: <1276566375-24566-2-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52269 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab0FOO3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:05 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 3985418162
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is needed by next patch that changes refcounting

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   63 +++++++++++++++++++++++++++++---------------------------
 1 files changed, 33 insertions(+), 30 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3f7f50a..937b84a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -320,30 +320,20 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
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
-	spin_lock(&nfsi->lo_lock);
-	if (!lo->ld_data) {
-		spin_unlock(&nfsi->lo_lock);
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
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 	struct nfs_client *clp;
@@ -365,7 +355,6 @@ put_unlock_current_layout(struct pnfs_layout_type *lo)
 		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
 	}
-	spin_unlock(&nfsi->lo_lock);
 }
 
 void
@@ -377,7 +366,8 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->lo_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
-	put_unlock_current_layout(lo);
+	put_current_layout(lo);
+	spin_unlock(&nfsi->lo_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
 
@@ -391,9 +381,13 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		.length = NFS4_MAX_UINT64,
 	};
 
-	lo = get_lock_current_layout(nfsi);
-	pnfs_free_layout(lo, &range);
-	put_unlock_current_layout(lo);
+	spin_lock(&nfsi->lo_lock);
+	lo = get_current_layout(nfsi);
+	if (lo) {
+		pnfs_free_layout(lo, &range);
+		put_current_layout(lo);
+	}
+	spin_unlock(&nfsi->lo_lock);
 }
 
 static inline void
@@ -760,12 +754,14 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 	arg.length = NFS4_MAX_UINT64;
 
 	if (type == RETURN_FILE) {
-		lo = get_lock_current_layout(nfsi);
+		spin_lock(&nfsi->lo_lock);
+		lo = get_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
-			put_unlock_current_layout(lo);
+			put_current_layout(lo);
 			lo = NULL;
 		}
 		if (!lo) {
+			spin_unlock(&nfsi->lo_lock);
 			dprintk("%s: no layout segments to return\n", __func__);
 			goto out;
 		}
@@ -779,7 +775,8 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			if (stateid) { /* callback */
 				status = -EAGAIN;
 				spin_lock(&nfsi->lo_lock);
-				put_unlock_current_layout(lo);
+				put_current_layout(lo);
+				spin_unlock(&nfsi->lo_lock);
 				goto out;
 			}
 			dprintk("%s: waiting\n", __func__);
@@ -924,8 +921,7 @@ static int pnfs_wait_schedule(void *word)
  * get, possibly allocate, and lock current_layout
  *
  * Note: If successful, nfsi->lo_lock is taken and the caller
- * must put and unlock current_layout by using put_unlock_current_layout()
- * when the returned layout is released.
+ * must put and unlock current_layout when the returned layout is released.
  */
 static struct pnfs_layout_type *
 get_lock_alloc_layout(struct inode *ino)
@@ -936,7 +932,9 @@ get_lock_alloc_layout(struct inode *ino)
 
 	dprintk("%s Begin\n", __func__);
 
-	while ((lo = get_lock_current_layout(nfsi)) == NULL) {
+	spin_lock(&nfsi->lo_lock);
+	while ((lo = get_current_layout(nfsi)) == NULL) {
+		spin_unlock(&nfsi->lo_lock);
 		/* Compete against other threads on who's doing the allocation,
 		 * wait until bit is cleared if we lost this race.
 		 */
@@ -952,8 +950,10 @@ get_lock_alloc_layout(struct inode *ino)
 		/* Was current_layout already allocated while we slept?
 		 * If so, retry get_lock'ing it. Otherwise, allocate it.
 		 */
-		if (nfsi->layout.ld_data)
+		if (nfsi->layout.ld_data) {
+			spin_lock(&nfsi->lo_lock);
 			continue;
+		}
 
 		lo = alloc_init_layout(ino);
 		if (lo) {
@@ -1122,7 +1122,8 @@ out:
 out_put:
 	if (lsegpp)
 		*lsegpp = lseg;
-	put_unlock_current_layout(lo);
+	put_current_layout(lo);
+	spin_unlock(&nfsi->lo_lock);
 	goto out;
 }
 
@@ -1338,11 +1339,13 @@ pnfs_getboundary(struct inode *inode)
 		goto out;
 
 	nfsi = NFS_I(inode);
-	lo = get_lock_current_layout(nfsi);;
+	spin_lock(&nfsi->lo_lock);
+	lo = get_current_layout(nfsi);;
 	if (lo) {
 		stripe_size = policy_ops->get_stripesize(lo);
-		put_unlock_current_layout(lo);
+		put_current_layout(lo);
 	}
+	spin_unlock(&nfsi->lo_lock);
 out:
 	return stripe_size;
 }
-- 
1.6.6.1

