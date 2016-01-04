Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36467 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbcADSVr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jan 2016 13:21:47 -0500
Received: by mail-io0-f177.google.com with SMTP id o67so442617000iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jan 2016 10:21:47 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/18] pNFS: If we have to delay the layout callback, mark the layout for return
Date: Mon,  4 Jan 2016 13:21:01 -0500
Message-Id: <1451931676-68481-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
References: <1451931676-68481-1-git-send-email-trond.myklebust@primarydata.com>
 <1451931676-68481-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client needs to delay the layout callback, then speed up the recall
process by marking the remaining layout segments to be actively returned
by the client.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 14 ++++++++++++--
 fs/nfs/pnfs.c          |  4 +++-
 fs/nfs/pnfs.h          |  3 +++
 3 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 716cbff24450..34852ece4057 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -181,9 +181,19 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	pnfs_layoutcommit_inode(ino, false);
 
 	spin_lock(&ino->i_lock);
-	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
-	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
+	/*
+	 * Enforce RFC5661 Section 12.5.5.2.1.5 (Bulk Recall and Return)
+	 */
+	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) {
+		rv = NFS4ERR_DELAY;
+		goto unlock;
+	}
+
+	if (pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
 					&args->cbl_range)) {
+		pnfs_mark_matching_lsegs_return(lo,
+				&free_me_list,
+				&args->cbl_range);
 		rv = NFS4ERR_DELAY;
 		goto unlock;
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b3fb6bb02275..360fe95c97b5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1756,7 +1756,7 @@ out_forget_reply:
 	goto out;
 }
 
-static void
+void
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *return_range)
@@ -1768,6 +1768,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 	if (list_empty(&lo->plh_segs))
 		return;
 
+	assert_spin_locked(&lo->plh_inode->i_lock);
+
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (should_free_lseg(&lseg->pls_range, return_range)) {
 			dprintk("%s: marking lseg %p iomode %d "
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index be24a759b655..d93c2ebc0fd3 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -266,6 +266,9 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 int pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *recall_range);
+void pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
+				struct list_head *tmp_list,
+				struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-- 
2.5.0

