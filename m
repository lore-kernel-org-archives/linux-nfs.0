Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:9029 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756064Ab1EWQgG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:36:06 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v6 09/26] pnfs: Use byte-range for cb_layoutrecall
Date: Mon, 23 May 2011 19:35:59 +0300
Message-Id: <1306168559-11267-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DDA8C3D.5080706@panasas.com>
References: <4DDA8C3D.5080706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use recalled range to invalidate particular layout segments in the layout cache.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    4 ++--
 fs/nfs/pnfs.c          |   15 +++++++++------
 fs/nfs/pnfs.h          |    2 +-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index fb5e5b9..5780c37 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -139,7 +139,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    mark_matching_lsegs_invalid(lo, &free_me_list,
-					args->cbl_range.iomode))
+					&args->cbl_range))
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
@@ -184,7 +184,7 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		ino = lo->plh_inode;
 		spin_lock(&ino->i_lock);
 		set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-		if (mark_matching_lsegs_invalid(lo, &free_me_list, range.iomode))
+		if (mark_matching_lsegs_invalid(lo, &free_me_list, &range))
 			rv = NFS4ERR_DELAY;
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2357ee3..20436a5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -321,10 +321,12 @@ lo_seg_intersecting(struct pnfs_layout_range *l1,
 }
 
 static bool
-should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
+should_free_lseg(struct pnfs_layout_range *lseg_range,
+		 struct pnfs_layout_range *recall_range)
 {
-	return (recall_iomode == IOMODE_ANY ||
-		lseg_iomode == recall_iomode);
+	return (recall_range->iomode == IOMODE_ANY ||
+		lseg_range->iomode == recall_range->iomode) &&
+	       lo_seg_intersecting(lseg_range, recall_range);
 }
 
 /* Returns 1 if lseg is removed from list, 0 otherwise */
@@ -355,7 +357,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 int
 mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct list_head *tmp_list,
-			    u32 iomode)
+			    struct pnfs_layout_range *recall_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	int invalid = 0, removed = 0;
@@ -368,7 +370,8 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (should_free_lseg(lseg->pls_range.iomode, iomode)) {
+		if (!recall_range ||
+		    should_free_lseg(&lseg->pls_range, recall_range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
@@ -417,7 +420,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	lo = nfsi->layout;
 	if (lo) {
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
+		mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f1fb823..7417be9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -154,7 +154,7 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct nfs4_state *open_state);
 int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-				u32 iomode);
+				struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-- 
1.7.3.4

