Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34880 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbcGVTe4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 15:34:56 -0400
Received: by mail-io0-f196.google.com with SMTP id q83so8028146iod.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 12:34:56 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] pNFS: Cleanup - don't open code pnfs_mark_layout_stateid_invalid()
Date: Fri, 22 Jul 2016 15:33:58 -0400
Message-Id: <1469216038-71882-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469216038-71882-6-git-send-email-trond.myklebust@primarydata.com>
References: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-2-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-3-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-4-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-5-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-6-git-send-email-trond.myklebust@primarydata.com>
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
index de97567795a5..676d0e5392c7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7932,8 +7932,7 @@ nfs4_layoutget_handle_exception(struct rpc_task *task,
 			 * Mark the bad layout state as invalid, then retry
 			 * with the current stateid.
 			 */
-			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-			pnfs_mark_matching_lsegs_invalid(lo, &head, NULL, 0);
+			pnfs_mark_layout_stateid_invalid(lo, &head);
 			spin_unlock(&inode->i_lock);
 			pnfs_free_lseg_list(&head);
 		} else
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0d68768e7afe..7ac0eaa97a89 100644
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
index b21bd0bee784..4a7ab14900d9 100644
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

