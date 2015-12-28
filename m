Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34765 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514AbbL1Phq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Dec 2015 10:37:46 -0500
Received: by mail-io0-f176.google.com with SMTP id e126so307351702ioa.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 Dec 2015 07:37:46 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] pNFS: If we have to delay the layout callback, mark the layout for return
Date: Mon, 28 Dec 2015 10:37:06 -0500
Message-Id: <1451317026-15469-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1451317026-15469-1-git-send-email-trond.myklebust@primarydata.com>
References: <1451317026-15469-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the client needs to delay the layout callback, then speed up the recall
process by marking the remaining layout segments to be actively returned
by the client.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 3 +++
 fs/nfs/pnfs.c          | 4 +++-
 fs/nfs/pnfs.h          | 3 +++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 807eb6ef4f91..320f9d37eee2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -184,6 +184,9 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    pnfs_mark_matching_lsegs_invalid(lo, &free_me_list,
 					&args->cbl_range)) {
+		pnfs_mark_matching_lsegs_return(lo,
+				&free_me_list,
+				&args->cbl_range);
 		rv = NFS4ERR_DELAY;
 		goto unlock;
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 113c3b327e24..cc50eaecd367 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1733,7 +1733,7 @@ out_forget_reply:
 	goto out;
 }
 
-static void
+void
 pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				struct pnfs_layout_range *return_range)
@@ -1745,6 +1745,8 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 	if (list_empty(&lo->plh_segs))
 		return;
 
+	assert_spin_locked(&lo->plh_inode->i_lock);
+
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
 		if (should_free_lseg(&lseg->pls_range, return_range)) {
 			dprintk("%s: marking lseg %p iomode %d "
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6916ff4e86f9..4ad4c5fb2e7d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -265,6 +265,9 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
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

