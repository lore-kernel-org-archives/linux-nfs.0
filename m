Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18554 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017Ab2IXT5Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:57:24 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/28] NFSv4.1: Cleanup add a "pnfs_" prefix to mark_matching_lsegs_invalid
Date: Mon, 24 Sep 2012 15:56:20 -0400
Message-Id: <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c | 4 ++--
 fs/nfs/pnfs.c          | 6 +++---
 fs/nfs/pnfs.h          | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 1b5d809..57b8bda 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -158,7 +158,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	ino = lo->plh_inode;
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-	    mark_matching_lsegs_invalid(lo, &free_me_list,
+	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
 					&args->cbl_range))
 		rv = NFS4ERR_DELAY;
 	else
@@ -211,7 +211,7 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		ino = lo->plh_inode;
 		spin_lock(&ino->i_lock);
 		set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-		if (mark_matching_lsegs_invalid(lo, &free_me_list, &range))
+		if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list, &range))
 			rv = NFS4ERR_DELAY;
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3a7ac97..aea2e52 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -390,7 +390,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
  * after call.
  */
 int
-mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct list_head *tmp_list,
 			    struct pnfs_layout_range *recall_range)
 {
@@ -458,7 +458,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	lo = nfsi->layout;
 	if (lo) {
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+		pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -651,7 +651,7 @@ _pnfs_return_layout(struct inode *ino)
 	/* Reference matched in nfs4_layoutreturn_release */
 	get_layout_hdr(lo);
 	empty = list_empty(&lo->plh_segs);
-	mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
+	pnfs_mark_matching_lsegs_invalid(lo, &tmp_list, NULL);
 	/* Don't send a LAYOUTRETURN if list was initially empty */
 	if (empty) {
 		spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index d51ef88..6af5189 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -203,7 +203,7 @@ void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
-int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
-- 
1.7.11.4

