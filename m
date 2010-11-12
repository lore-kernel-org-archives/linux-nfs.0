Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17286 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756005Ab0KLItZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Nov 2010 03:49:25 -0500
Received: from localhost.localdomain (hess01-lxp.hq.netapp.com [10.58.60.52] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oAC8n7fL025967
	for <linux-nfs@vger.kernel.org>; Fri, 12 Nov 2010 00:49:14 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 11/22] pnfs-submit: remove _pnfs_can_return_lseg call from pnfs_clear_lseg_list
Date: Fri, 12 Nov 2010 03:48:33 -0500
Message-Id: <1289551724-18575-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Instead, have mark_invalid function that marks lseg invalid and
removes the reference that holds it in the list.  Now when io is finished,
the lseg will automatically be removed from the list.  This is
at the heart of many of the upcoming cb_layoutrecall changes.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |  130 +++++++++++++++++++++++++++++++++++----------------------
 1 files changed, 80 insertions(+), 50 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 120590b..1147eb3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -272,10 +272,42 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	lseg->layout = lo;
 }
 
+static void
+_put_lseg_common(struct pnfs_layout_segment *lseg)
+{
+	BUG_ON(lseg->valid == true);
+	list_del(&lseg->fi_list);
+	if (list_empty(&lseg->layout->segs)) {
+		struct nfs_client *clp;
+
+		clp = NFS_SERVER(lseg->layout->inode)->nfs_client;
+		spin_lock(&clp->cl_lock);
+		/* List does not take a reference, so no need for put here */
+		list_del_init(&lseg->layout->layouts);
+		spin_unlock(&clp->cl_lock);
+		pnfs_invalidate_layout_stateid(lseg->layout);
+	}
+	rpc_wake_up(&NFS_I(lseg->layout->inode)->lo_rpcwaitq);
+}
+
+/* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
+ * could sleep, so must be called outside of the lock.
+ */
+static void
+put_lseg_locked(struct pnfs_layout_segment *lseg,
+		struct list_head *tmp_list)
+{
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->pls_refcount), lseg->valid);
+	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+		_put_lseg_common(lseg);
+		list_add(&lseg->fi_list, tmp_list);
+	}
+}
+
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
-	bool do_wake_up;
 	struct inode *ino;
 
 	if (!lseg)
@@ -283,15 +315,14 @@ put_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->pls_refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
 	ino = lseg->layout->inode;
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
+		_put_lseg_common(lseg);
+		spin_unlock(&ino->i_lock);
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 		put_layout_hdr(ino);
 	}
-	if (do_wake_up)
-		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
@@ -314,10 +345,18 @@ should_free_lseg(struct pnfs_layout_range *lseg_range,
 		lseg_range->iomode == recall_range->iomode);
 }
 
-static bool
-_pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
+static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
+			      struct list_head *tmp_list)
 {
-	return atomic_read(&lseg->pls_refcount) == 1;
+	assert_spin_locked(&lseg->layout->inode->i_lock);
+	if (lseg->valid) {
+		lseg->valid = false;
+		/* Remove the reference keeping the lseg in the
+		 * list.  It will now be removed when all
+		 * outstanding io is finished.
+		 */
+		put_lseg_locked(lseg, tmp_list);
+	}
 }
 
 static void
@@ -330,42 +369,31 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		__func__, lo, range->offset, range->length, range->iomode);
 
 	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
-		if (!should_free_lseg(&lseg->range, range) ||
-		    !_pnfs_can_return_lseg(lseg))
-			continue;
-		dprintk("%s: freeing lseg %p iomode %d "
-			"offset %llu length %llu\n", __func__,
-			lseg, lseg->range.iomode, lseg->range.offset,
-			lseg->range.length);
-		list_move(&lseg->fi_list, tmp_list);
-	}
-	if (list_empty(&lo->segs)) {
-		struct nfs_client *clp;
-
-		clp = NFS_SERVER(lo->inode)->nfs_client;
-		spin_lock(&clp->cl_lock);
-		/* List does not take a reference, so no need for put here */
-		list_del_init(&lo->layouts);
-		spin_unlock(&clp->cl_lock);
-		pnfs_invalidate_layout_stateid(lo);
-	}
-
+	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list)
+		if (should_free_lseg(&lseg->range, range)) {
+			dprintk("%s: freeing lseg %p iomode %d "
+				"offset %llu length %llu\n", __func__,
+				lseg, lseg->range.iomode, lseg->range.offset,
+				lseg->range.length);
+			mark_lseg_invalid(lseg, tmp_list);
+		}
 	dprintk("%s:Return\n", __func__);
 }
 
 static void
-pnfs_free_lseg_list(struct list_head *tmp_list)
+pnfs_free_lseg_list(struct list_head *free_me)
 {
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg, *tmp;
+	struct inode *ino;
 
-	while (!list_empty(tmp_list)) {
-		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
-				fi_list);
-		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
-		list_del(&lseg->fi_list);
-		put_lseg(lseg);
+	list_for_each_entry_safe(lseg, tmp, free_me, fi_list) {
+		BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
+		ino = lseg->layout->inode;
+		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+		put_layout_hdr(ino);
 	}
+	INIT_LIST_HEAD(free_me);
 }
 
 void
@@ -530,6 +558,10 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 	return out;
 }
 
+/* Return true if there is layout based io in progress in the given range.
+ * Assumes range has already been marked invalid, and layout marked to
+ * prevent any new lseg from being inserted.
+ */
 bool
 pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			   struct pnfs_layout_range *range)
@@ -538,17 +570,11 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 	bool ret = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
-		if (!should_free_lseg(&lseg->range, range))
-			continue;
-		lseg->valid = false;
-		if (!_pnfs_can_return_lseg(lseg)) {
-			dprintk("%s: wait on lseg %p refcount %d\n",
-				__func__, lseg,
-				atomic_read(&lseg->pls_refcount));
+	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list)
+		if (should_free_lseg(&lseg->range, range)) {
 			ret = true;
+			break;
 		}
-	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	dprintk("%s:Return %d\n", __func__, ret);
 	return ret;
@@ -558,13 +584,11 @@ void
 pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
 {
 	struct pnfs_layout_hdr *lo;
-	LIST_HEAD(tmp_list);
 
 	if (lrp->args.return_type != RETURN_FILE)
 		return;
 	lo = NFS_I(lrp->args.inode)->layout;
 	spin_lock(&lrp->args.inode->i_lock);
-	pnfs_clear_lseg_list(lo, &tmp_list, &lrp->args.range);
 	lo->plh_block_lgets--;
 	if (!pnfs_layoutgets_blocked(lo))
 		rpc_wake_up(&NFS_I(lo->inode)->lo_rpcwaitq_stateid);
@@ -576,7 +600,6 @@ pnfs_layoutreturn_release(struct nfs4_layoutreturn *lrp)
 		pnfs_set_layout_stateid(lo, &lrp->res.stateid);
 	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&lrp->args.inode->i_lock);
-	pnfs_free_lseg_list(&tmp_list);
 }
 
 static int
@@ -630,7 +653,11 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 	arg.offset = 0;
 	arg.length = NFS4_MAX_UINT64;
 
+	/* probably should BUGON if type != RETURN_FILE */
 	if (type == RETURN_FILE) {
+		LIST_HEAD(tmp_list);
+		struct pnfs_layout_segment *lseg, *tmp;
+
 		spin_lock(&ino->i_lock);
 		lo = nfsi->layout;
 		if (lo && !has_layout_to_return(lo, &arg))
@@ -642,10 +669,13 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		}
 
 		lo->plh_block_lgets++;
+		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
+			if (should_free_lseg(&lseg->range, &arg))
+				mark_lseg_invalid(lseg, &tmp_list);
 		/* Reference matched in pnfs_layoutreturn_release */
 		get_layout_hdr_locked(lo);
-
 		spin_unlock(&ino->i_lock);
+		pnfs_free_lseg_list(&tmp_list);
 
 		if (layoutcommit_needed(nfsi)) {
 			if (stateid && !wait) { /* callback */
-- 
1.7.2.1

