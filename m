Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29210 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758691Ab0J1TKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Oct 2010 15:10:06 -0400
Received: from localhost.localdomain (elee16240.hq.netapp.com [10.58.53.47] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9SJA27f000482
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 12:10:05 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] pnfs-submit: remove _pnfs_can_return_lseg call from pnfs_clear_lseg_list
Date: Thu, 28 Oct 2010 15:09:58 -0400
Message-Id: <1288293001-26289-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
References: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
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
 fs/nfs/nfs4xdr.c |    3 +-
 fs/nfs/pnfs.c    |  146 ++++++++++++++++++++++++++++++++++++------------------
 fs/nfs/pnfs.h    |    1 +
 3 files changed, 100 insertions(+), 50 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6d86633..c178946 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1904,8 +1904,7 @@ encode_layoutreturn(struct xdr_stream *xdr,
 		p = reserve_space(xdr, 16 + NFS4_STATEID_SIZE);
 		p = xdr_encode_hyper(p, args->range.offset);
 		p = xdr_encode_hyper(p, args->range.length);
-		pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout,
-					NULL);
+		pnfs_copy_layout_stateid(&stateid, NFS_I(args->inode)->layout);
 		p = xdr_encode_opaque_fixed(p, &stateid.data,
 					    NFS4_STATEID_SIZE);
 		p = reserve_space(xdr, 4);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 72997b1..c088cd4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -272,10 +272,36 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	lseg->layout = lo;
 }
 
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
+		struct inode *ino = lseg->layout->inode;
+
+		BUG_ON(lseg->valid == true);
+		list_move(&lseg->fi_list, tmp_list);
+		if (list_empty(&lseg->layout->segs)) {
+			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
+
+			spin_lock(&clp->cl_lock);
+			/* List does not take a reference, so no need for put here */
+			list_del_init(&lseg->layout->layouts);
+			spin_unlock(&clp->cl_lock);
+			pnfs_invalidate_layout_stateid(lseg->layout);
+		}
+		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
+	}
+}
+
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
-	bool do_wake_up;
 	struct inode *ino;
 
 	if (!lseg)
@@ -283,15 +309,25 @@ put_lseg(struct pnfs_layout_segment *lseg)
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
 		atomic_read(&lseg->pls_refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
 	ino = lseg->layout->inode;
-	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+	if (atomic_dec_and_lock(&lseg->pls_refcount, &ino->i_lock)) {
+		BUG_ON(lseg->valid == true);
+		list_del(&lseg->fi_list);
+		if (list_empty(&lseg->layout->segs)) {
+			struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
+
+			spin_lock(&clp->cl_lock);
+			/* List does not take a reference, so no need for put here */
+			list_del_init(&lseg->layout->layouts);
+			spin_unlock(&clp->cl_lock);
+			pnfs_invalidate_layout_stateid(lseg->layout);
+		}
+		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
+		spin_unlock(&ino->i_lock);
 		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
 		put_layout_hdr(ino);
 	}
-	if (do_wake_up)
-		rpc_wake_up(&NFS_I(ino)->lo_rpcwaitq);
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
@@ -314,10 +350,18 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 		lseg->range.iomode == range->iomode);
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
@@ -330,42 +374,36 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		__func__, lo, range->offset, range->length, range->iomode);
 
 	assert_spin_locked(&lo->inode->i_lock);
-	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
-		if (!should_free_lseg(lseg, range) ||
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
+		if (should_free_lseg(lseg, range)) {
+			dprintk("%s: freeing lseg %p iomode %d "
+				"offset %llu length %llu\n", __func__,
+				lseg, lseg->range.iomode, lseg->range.offset,
+				lseg->range.length);
+			mark_lseg_invalid(lseg, tmp_list);
+		}
 	dprintk("%s:Return\n", __func__);
 }
 
-static void
+static int
 pnfs_free_lseg_list(struct list_head *tmp_list)
 {
 	struct pnfs_layout_segment *lseg;
+	struct inode *ino;
+	int count = 0;
 
 	while (!list_empty(tmp_list)) {
+		count++;
 		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
 				fi_list);
-		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
+		BUG_ON(atomic_read(&lseg->pls_refcount) != 0);
+		ino = lseg->layout->inode;
 		list_del(&lseg->fi_list);
-		put_lseg(lseg);
+		NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+		/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+		put_layout_hdr(ino);
 	}
+	return count;
 }
 
 void
@@ -383,14 +421,10 @@ pnfs_layoutreturn_release(struct pnfs_layout_hdr *lo,
 			  struct pnfs_layout_range *range)
 {
 	struct nfs_inode *nfsi = NFS_I(lo->inode);
-	LIST_HEAD(tmp_list);
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	if (range)
-		pnfs_clear_lseg_list(lo, &tmp_list, range);
 	put_layout_hdr_locked(lo); /* Matched in _pnfs_return_layout */
 	spin_unlock(&nfsi->vfs_inode.i_lock);
-	pnfs_free_lseg_list(&tmp_list);
 }
 
 void
@@ -488,6 +522,17 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
 	dprintk("<-- %s\n", __func__);
 }
 
+/* Layoutreturn may use an invalid stateid, just copy what is there */
+void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
+{
+	int seq;
+
+	do {
+		seq = read_seqbegin(&lo->seqlock);
+		memcpy(dst->data, lo->stateid.data, sizeof(lo->stateid.data));
+	} while (read_seqretry(&lo->seqlock, seq));
+}
+
 void
 pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			struct nfs4_state *open_state)
@@ -571,25 +616,23 @@ has_layout_to_return(struct pnfs_layout_hdr *lo,
 	return out;
 }
 
+/* Return true if there is layout based io in progress in the given range.
+ * Assumes range has already been marked invalid, and layout marked to
+ * prevent any new lseg from being inserted.
+ */
 bool
 pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 			   struct pnfs_layout_range *range)
 {
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg, *tmp;
 	bool ret = false;
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	list_for_each_entry(lseg, &nfsi->layout->segs, fi_list) {
-		if (!should_free_lseg(lseg, range))
-			continue;
-		lseg->valid = false;
-		if (!_pnfs_can_return_lseg(lseg)) {
-			dprintk("%s: wait on lseg %p refcount %d\n",
-				__func__, lseg,
-				atomic_read(&lseg->pls_refcount));
+	list_for_each_entry_safe(lseg, tmp, &nfsi->layout->segs, fi_list)
+		if (should_free_lseg(lseg, range)) {
 			ret = true;
+			break;
 		}
-	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	dprintk("%s:Return %d\n", __func__, ret);
 	return ret;
@@ -644,7 +687,11 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
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
@@ -655,10 +702,13 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 			goto out;
 		}
 
+		list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
+			if (should_free_lseg(lseg, &arg))
+				mark_lseg_invalid(lseg, &tmp_list);
 		/* Reference matched in pnfs_layoutreturn_release */
 		get_layout_hdr_locked(lo);
-
 		spin_unlock(&ino->i_lock);
+		pnfs_free_lseg_list(&tmp_list);
 
 		if (layoutcommit_needed(nfsi)) {
 			if (stateid && !wait) { /* callback */
@@ -1178,7 +1228,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	nfsi->layout->write_end_pos = 0;
 	nfsi->layout->cred = NULL;
 	__clear_bit(NFS_LAYOUT_NEED_LCOMMIT, &nfsi->layout->state);
-	pnfs_get_layout_stateid(&data->args.stateid, nfsi->layout, NULL);
+	pnfs_copy_layout_stateid(&data->args.stateid, nfsi->layout);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
 	get_layout_hdr_locked(NFS_I(inode)->layout);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5e4c7cc..c06b510 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -208,6 +208,7 @@ void pnfs_layoutreturn_release(struct pnfs_layout_hdr *,
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout_hdr(struct inode *inode);
+void pnfs_copy_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
 void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 			     struct nfs4_state *open_state);
 
-- 
1.7.2.1

