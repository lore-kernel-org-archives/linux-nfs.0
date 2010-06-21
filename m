From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 2/3] pnfs-submit: split get_layout and grab_current_layout
Date: Mon, 21 Jun 2010 09:16:36 -0400
Message-ID: <1277126197-2546-3-git-send-email-iisaman@netapp.com>
References: <1277126197-2546-1-git-send-email-iisaman@netapp.com>
 <1277126197-2546-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12633 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932305Ab0FUNQx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jun 2010 09:16:53 -0400
Received: from localhost.localdomain (pl03676a.hq.netapp.com [10.58.60.107] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5LDGedw022922
	for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 06:16:42 -0700 (PDT)
In-Reply-To: <1277126197-2546-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split get_layout (inc refcount) and grab_current_layout (find layout and inc refcount)
functionality and rename appropriately.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ed4c72e..49093a0 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -313,20 +313,27 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 #define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
 #endif /* CONFIG_SMP */
 
+static inline void
+get_layout(struct pnfs_layout_type *lo)
+{
+	BUG_ON_UNLOCKED_LO(lo);
+	lo->refcount++;
+}
+
 static inline struct pnfs_layout_type *
-get_current_layout(struct nfs_inode *nfsi)
+grab_current_layout(struct nfs_inode *nfsi)
 {
 	struct pnfs_layout_type *lo = &nfsi->layout;
 
 	BUG_ON_UNLOCKED_LO(lo);
 	if (!lo->ld_data)
 		return NULL;
-	lo->refcount++;
+	get_layout(lo);
 	return lo;
 }
 
 static inline void
-put_current_layout(struct pnfs_layout_type *lo)
+put_layout(struct pnfs_layout_type *lo)
 {
 	struct inode *inode = PNFS_INODE(lo);
 	struct nfs_client *clp;
@@ -359,7 +366,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
-	put_current_layout(lo);
+	put_layout(lo);
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
@@ -375,10 +382,10 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	};
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	lo = get_current_layout(nfsi);
+	lo = grab_current_layout(nfsi);
 	if (lo) {
 		pnfs_free_layout(lo, &range);
-		put_current_layout(lo);
+		put_layout(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
@@ -548,7 +555,7 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 *    arg->length: all ones
 */
 static int
-get_layout(struct inode *ino,
+send_layoutget(struct inode *ino,
 	   struct nfs_open_context *ctx,
 	   struct nfs4_pnfs_layout_segment *range,
 	   struct pnfs_layout_segment **lsegpp,
@@ -744,9 +751,9 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	if (type == RETURN_FILE) {
 		spin_lock(&ino->i_lock);
-		lo = get_current_layout(nfsi);
+		lo = grab_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
-			put_current_layout(lo);
+			put_layout(lo);
 			lo = NULL;
 		}
 		if (!lo) {
@@ -764,7 +771,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			if (stateid) { /* callback */
 				status = -EAGAIN;
 				spin_lock(&ino->i_lock);
-				put_current_layout(lo);
+				put_layout(lo);
 				spin_unlock(&ino->i_lock);
 				goto out;
 			}
@@ -921,7 +928,7 @@ get_lock_alloc_layout(struct inode *ino)
 	dprintk("%s Begin\n", __func__);
 
 	spin_lock(&ino->i_lock);
-	while ((lo = get_current_layout(nfsi)) == NULL) {
+	while ((lo = grab_current_layout(nfsi)) == NULL) {
 		spin_unlock(&ino->i_lock);
 		/* Compete against other threads on who's doing the allocation,
 		 * wait until bit is cleared if we lost this race.
@@ -1102,7 +1109,7 @@ _pnfs_update_layout(struct inode *ino,
 	/* Lose lock, but not reference, match this with pnfs_layout_release */
 	spin_unlock(&ino->i_lock);
 
-	get_layout(ino, ctx, &arg, lsegpp, lo);
+	send_layoutget(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout.pnfs_layout_state, lseg);
@@ -1110,7 +1117,7 @@ out:
 out_put:
 	if (lsegpp)
 		*lsegpp = lseg;
-	put_current_layout(lo);
+	put_layout(lo);
 	spin_unlock(&ino->i_lock);
 	goto out;
 }
@@ -1328,10 +1335,10 @@ pnfs_getboundary(struct inode *inode)
 
 	nfsi = NFS_I(inode);
 	spin_lock(&inode->i_lock);
-	lo = get_current_layout(nfsi);;
+	lo = grab_current_layout(nfsi);;
 	if (lo) {
 		stripe_size = policy_ops->get_stripesize(lo);
-		put_current_layout(lo);
+		put_layout(lo);
 	}
 	spin_unlock(&inode->i_lock);
 out:
-- 
1.6.6.1

