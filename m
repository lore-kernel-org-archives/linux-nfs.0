Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:36779 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbcGXVbn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:43 -0400
Received: by mail-it0-f67.google.com with SMTP id j124so6500593ith.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 09/14] pNFS: Cleanup - don't open code pnfs_mark_layout_stateid_invalid()
Date: Sun, 24 Jul 2016 17:30:54 -0400
Message-Id: <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure nfs42_layoutstat_done() layoutget don't open code layout stateid
invalidation.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs42proc.c | 3 +--
 fs/nfs/nfs4proc.c  | 3 +--
 fs/nfs/pnfs.c      | 2 +-
 fs/nfs/pnfs.h      | 2 ++
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index aa03ed09ba06..6ea5ad6f0d44 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -336,8 +336,7 @@ nfs42_layoutstat_done(struct rpc_task *task, void *calldata)
 			 * Mark the bad layout state as invalid, then retry
 			 * with the current stateid.
 			 */
-			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
+			pnfs_mark_layout_stateid_invalid(lo, &head);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
 		} else
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index dc50ba4d84ad..8c453515d98c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7931,8 +7931,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			 * Mark the bad layout state as invalid, then retry
 			 * with the current stateid.
 			 */
-			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
+			pnfs_mark_layout_stateid_invalid(lo, &head);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
 			status = -EAGAIN;
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 52b2a4dfdcb0..1374fcd40484 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -259,7 +259,7 @@ pnfs_put_layout_hdr(struct pnfs_layout_hdr *lo)
  * is required.
  * Note that caller must hold inode->i_lock.
  */
-static int
+int
 pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
 		struct list_head *lseg_list)
 {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2f4f26905c03..d71c9493693a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -268,6 +268,8 @@ int pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
 				const struct pnfs_layout_range *recall_range,
 				u32 seq);
+int pnfs_mark_layout_stateid_invalid(struct pnfs_layout_hdr *lo,
+		struct list_head *lseg_list);
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
-- 
2.7.4

