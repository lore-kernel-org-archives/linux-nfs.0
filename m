Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35056 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759727AbcLAWTf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:35 -0500
Received: by mail-io0-f195.google.com with SMTP id h133so4680718ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:34 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/26] pNFS: Do not free layout segments that are marked for return
Date: Thu,  1 Dec 2016 17:19:05 -0500
Message-Id: <20161201221922.15657-10-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-9-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We may want to process and transmit layout stat information for the
layout segments that are being returned, so we should defer freeing
them until after the layoutreturn has completed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c | 15 +++--------
 fs/nfs/pnfs.c     | 74 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/pnfs.h     |  6 ++++-
 3 files changed, 73 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 917a6db5c84f..561b21e4a930 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8572,21 +8572,12 @@ static void nfs4_layoutreturn_release(void *calldata)
 {
 	struct nfs4_layoutreturn *lrp = calldata;
 	struct pnfs_layout_hdr *lo = lrp->args.layout;
-	LIST_HEAD(freeme);
 
 	dprintk("--> %s\n", __func__);
-	spin_lock(&lo->plh_inode->i_lock);
-	if (lrp->res.lrs_present) {
-		pnfs_mark_matching_lsegs_invalid(lo, &freeme,
-				&lrp->args.range,
-				be32_to_cpu(lrp->args.stateid.seqid));
-		pnfs_set_layout_stateid(lo, &lrp->res.stateid, true);
-	} else
-		pnfs_mark_layout_stateid_invalid(lo, &freeme);
-	pnfs_clear_layoutreturn_waitbit(lo);
-	spin_unlock(&lo->plh_inode->i_lock);
+	pnfs_layoutreturn_free_lsegs(lo, &lrp->args.range,
+			be32_to_cpu(lrp->args.stateid.seqid),
+			lrp->res.lrs_present ? &lrp->res.stateid : NULL);
 	nfs4_sequence_free_slot(&lrp->res.seq_res);
-	pnfs_free_lseg_list(&freeme);
 	pnfs_put_layout_hdr(lrp->args.layout);
 	nfs_iput_and_deactive(lrp->inode);
 	kfree(calldata);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d70cc467a87b..555151b6d31b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -54,6 +54,10 @@ static DEFINE_SPINLOCK(pnfs_spinlock);
 static LIST_HEAD(pnfs_modules_tbl);
 
 static void pnfs_layoutreturn_before_put_layout_hdr(struct pnfs_layout_hdr *lo);
+static void pnfs_free_returned_lsegs(struct pnfs_layout_hdr *lo,
+		struct list_head *free_me,
+		const struct pnfs_layout_range *range,
+		u32 seq);
 
 /* Return the registered pnfs layout driver module matching given id */
 static struct pnfs_layoutdriver_type *
@@ -326,6 +330,7 @@ pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 
 	set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 	pnfs_clear_layoutreturn_info(lo);
+	pnfs_free_returned_lsegs(lo, lseg_list, &range, 0);
 	return pnfs_mark_matching_lsegs_invalid(lo, lseg_list, &range, 0);
 }
 
@@ -405,9 +410,10 @@ pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
 
 static void pnfs_free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct inode *ino = lseg->pls_layout->plh_inode;
-
-	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
+	if (lseg != NULL) {
+		struct inode *inode = lseg->pls_layout->plh_inode;
+		NFS_SERVER(inode)->pnfs_curr_ld->free_lseg(lseg);
+	}
 }
 
 static void
@@ -430,6 +436,18 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	rpc_wake_up(&NFS_SERVER(inode)->roc_rpcwaitq);
 }
 
+static bool
+pnfs_cache_lseg_for_layoutreturn(struct pnfs_layout_hdr *lo,
+		struct pnfs_layout_segment *lseg)
+{
+	if (test_and_clear_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
+	    pnfs_layout_is_valid(lo)) {
+		list_move_tail(&lseg->pls_list, &lo->plh_return_segs);
+		return true;
+	}
+	return false;
+}
+
 void
 pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 {
@@ -453,6 +471,8 @@ pnfs_put_lseg(struct pnfs_layout_segment *lseg)
 		}
 		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
+		if (pnfs_cache_lseg_for_layoutreturn(lo, lseg))
+			lseg = NULL;
 		spin_unlock(&inode->i_lock);
 		pnfs_free_lseg(lseg);
 		pnfs_put_layout_hdr(lo);
@@ -493,9 +513,11 @@ pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
 		struct pnfs_layout_hdr *lo = lseg->pls_layout;
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags))
 			return;
-		pnfs_get_layout_hdr(lo);
 		pnfs_layout_remove_lseg(lo, lseg);
-		pnfs_free_lseg_async(lseg);
+		if (!pnfs_cache_lseg_for_layoutreturn(lo, lseg)) {
+			pnfs_get_layout_hdr(lo);
+			pnfs_free_lseg_async(lseg);
+		}
 	}
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg_locked);
@@ -619,6 +641,20 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	return remaining;
 }
 
+static void
+pnfs_free_returned_lsegs(struct pnfs_layout_hdr *lo,
+		struct list_head *free_me,
+		const struct pnfs_layout_range *range,
+		u32 seq)
+{
+	struct pnfs_layout_segment *lseg, *next;
+
+	list_for_each_entry_safe(lseg, next, &lo->plh_return_segs, pls_list) {
+		if (pnfs_match_lseg_recall(lseg, range, seq))
+			list_move_tail(&lseg->pls_list, free_me);
+	}
+}
+
 /* note free_me must contain lsegs from a single layout_hdr */
 void
 pnfs_free_lseg_list(struct list_head *free_me)
@@ -915,7 +951,7 @@ static void pnfs_clear_layoutcommit(struct inode *inode,
 	}
 }
 
-void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
+static void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 {
 	clear_bit_unlock(NFS_LAYOUT_RETURN, &lo->plh_flags);
 	clear_bit(NFS_LAYOUT_RETURN_LOCK, &lo->plh_flags);
@@ -924,6 +960,27 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 }
 
+void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
+		const struct pnfs_layout_range *range,
+		u32 seq,
+		const nfs4_stateid *stateid)
+{
+	struct inode *inode = lo->plh_inode;
+	LIST_HEAD(freeme);
+
+	spin_lock(&inode->i_lock);
+	if (stateid) {
+		pnfs_mark_matching_lsegs_invalid(lo, &freeme, range, seq);
+		pnfs_free_returned_lsegs(lo, &freeme, range, seq);
+		pnfs_set_layout_stateid(lo, stateid, true);
+	} else
+		pnfs_mark_layout_stateid_invalid(lo, &freeme);
+	pnfs_clear_layoutreturn_waitbit(lo);
+	spin_unlock(&inode->i_lock);
+	pnfs_free_lseg_list(&freeme);
+
+}
+
 static bool
 pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo,
 		nfs4_stateid *stateid,
@@ -1349,6 +1406,7 @@ alloc_init_layout_hdr(struct inode *ino,
 	atomic_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->plh_layouts);
 	INIT_LIST_HEAD(&lo->plh_segs);
+	INIT_LIST_HEAD(&lo->plh_return_segs);
 	INIT_LIST_HEAD(&lo->plh_bulk_destroy);
 	lo->plh_inode = ino;
 	lo->plh_lc_cred = get_rpccred(ctx->cred);
@@ -1920,7 +1978,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		.offset = 0,
 		.length = NFS4_MAX_UINT64,
 	};
-	LIST_HEAD(free_me);
 	bool return_now = false;
 
 	spin_lock(&inode->i_lock);
@@ -1932,7 +1989,7 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (!pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0)) {
+	if (!pnfs_mark_matching_lsegs_return(lo, &lo->plh_return_segs, &range, 0)) {
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
 
@@ -1944,7 +2001,6 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 		spin_unlock(&inode->i_lock);
 		nfs_commit_inode(inode, 0);
 	}
-	pnfs_free_lseg_list(&free_me);
 }
 EXPORT_SYMBOL_GPL(pnfs_error_mark_layout_for_return);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 337dad382b6a..a382710edf40 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -191,6 +191,7 @@ struct pnfs_layout_hdr {
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_bulk_destroy;
 	struct list_head	plh_segs;      /* layout segments list */
+	struct list_head	plh_return_segs; /* invalid layout segments */
 	unsigned long		plh_block_lgets; /* block LAYOUTGET if >0 */
 	unsigned long		plh_retry_timestamp;
 	unsigned long		plh_flags;
@@ -293,7 +294,10 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       enum pnfs_iomode iomode,
 					       bool strict_iomode,
 					       gfp_t gfp_flags);
-void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo);
+void pnfs_layoutreturn_free_lsegs(struct pnfs_layout_hdr *lo,
+		const struct pnfs_layout_range *range,
+		u32 seq,
+		const nfs4_stateid *stateid);
 
 void pnfs_generic_layout_insert_lseg(struct pnfs_layout_hdr *lo,
 		   struct pnfs_layout_segment *lseg,
-- 
2.9.3

