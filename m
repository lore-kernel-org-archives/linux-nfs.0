From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 02/10] pnfs-submit: split get_layout and grab_current_layout
Date: Mon, 14 Jun 2010 21:46:07 -0400
Message-ID: <1276566375-24566-3-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52270 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932217Ab0FOO3G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:06 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 3C4C818163
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-2-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split get_layout (inc refcount) and grab_current_layout (find layout and inc refcount)
functionality and rename appropriately.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   37 ++++++++++++++++++++++---------------
 1 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 937b84a..924e6fd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -320,20 +320,27 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
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
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 	struct nfs_client *clp;
@@ -366,7 +373,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->lo_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
-	put_current_layout(lo);
+	put_layout(lo);
 	spin_unlock(&nfsi->lo_lock);
 	wake_up_all(&nfsi->lo_waitq);
 }
@@ -382,10 +389,10 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	};
 
 	spin_lock(&nfsi->lo_lock);
-	lo = get_current_layout(nfsi);
+	lo = grab_current_layout(nfsi);
 	if (lo) {
 		pnfs_free_layout(lo, &range);
-		put_current_layout(lo);
+		put_layout(lo);
 	}
 	spin_unlock(&nfsi->lo_lock);
 }
@@ -555,7 +562,7 @@ pnfs_layout_from_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 *    arg->length: all ones
 */
 static int
-get_layout(struct inode *ino,
+send_layoutget(struct inode *ino,
 	   struct nfs_open_context *ctx,
 	   struct nfs4_pnfs_layout_segment *range,
 	   struct pnfs_layout_segment **lsegpp,
@@ -755,9 +762,9 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 
 	if (type == RETURN_FILE) {
 		spin_lock(&nfsi->lo_lock);
-		lo = get_current_layout(nfsi);
+		lo = grab_current_layout(nfsi);
 		if (lo && !has_layout_to_return(lo, &arg)) {
-			put_current_layout(lo);
+			put_layout(lo);
 			lo = NULL;
 		}
 		if (!lo) {
@@ -775,7 +782,7 @@ _pnfs_return_layout(struct inode *ino, struct nfs4_pnfs_layout_segment *range,
 			if (stateid) { /* callback */
 				status = -EAGAIN;
 				spin_lock(&nfsi->lo_lock);
-				put_current_layout(lo);
+				put_layout(lo);
 				spin_unlock(&nfsi->lo_lock);
 				goto out;
 			}
@@ -933,7 +940,7 @@ get_lock_alloc_layout(struct inode *ino)
 	dprintk("%s Begin\n", __func__);
 
 	spin_lock(&nfsi->lo_lock);
-	while ((lo = get_current_layout(nfsi)) == NULL) {
+	while ((lo = grab_current_layout(nfsi)) == NULL) {
 		spin_unlock(&nfsi->lo_lock);
 		/* Compete against other threads on who's doing the allocation,
 		 * wait until bit is cleared if we lost this race.
@@ -1114,7 +1121,7 @@ _pnfs_update_layout(struct inode *ino,
 	/* Lose lock, but not reference, match this with pnfs_layout_release */
 	spin_unlock(&nfsi->lo_lock);
 
-	get_layout(ino, ctx, &arg, lsegpp, lo);
+	send_layoutget(ino, ctx, &arg, lsegpp, lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout.pnfs_layout_state, lseg);
@@ -1122,7 +1129,7 @@ out:
 out_put:
 	if (lsegpp)
 		*lsegpp = lseg;
-	put_current_layout(lo);
+	put_layout(lo);
 	spin_unlock(&nfsi->lo_lock);
 	goto out;
 }
@@ -1340,10 +1347,10 @@ pnfs_getboundary(struct inode *inode)
 
 	nfsi = NFS_I(inode);
 	spin_lock(&nfsi->lo_lock);
-	lo = get_current_layout(nfsi);;
+	lo = grab_current_layout(nfsi);;
 	if (lo) {
 		stripe_size = policy_ops->get_stripesize(lo);
-		put_current_layout(lo);
+		put_layout(lo);
 	}
 	spin_unlock(&nfsi->lo_lock);
 out:
-- 
1.6.6.1

