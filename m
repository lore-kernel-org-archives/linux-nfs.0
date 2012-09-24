Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19856 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932119Ab2IXT6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 15:58:37 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 14/28] NFSv4.1: Get rid of pNFS layout state "NFS_LAYOUT_INVALID"
Date: Mon, 24 Sep 2012 15:56:32 -0400
Message-Id: <1348516606-22721-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1348516606-22721-1-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-2-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-3-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-4-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-5-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-6-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-7-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-8-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-9-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-10-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-11-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-12-git-send-email-Trond.Myklebust@netapp.com>
 <1348516606-22721-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In all cases where we set NFS_LAYOUT_INVALID, we also set NFS_LAYOUT_DESTROYED.
Furthermore, in all cases where we test for NFS_LAYOUT_INVALID, we should
also be testing for NFS_LAYOUT_DESTROYED, since the latter means that
we hold no valid layout segments.
Ergo the two are redundant.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c | 4 +---
 fs/nfs/nfs4filelayout.h | 6 ------
 fs/nfs/pnfs.h           | 7 ++++++-
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index dac2162..6cce57e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -190,8 +190,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		 * i/o and all i/o waiting on the slot table to the MDS until
 		 * layout is destroyed and a new valid layout is obtained.
 		 */
-		set_bit(NFS_LAYOUT_INVALID,
-				&NFS_I(inode)->layout->plh_flags);
 		pnfs_destroy_layout(NFS_I(inode));
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		goto reset;
@@ -281,7 +279,7 @@ filelayout_reset_to_mds(struct pnfs_layout_segment *lseg)
 {
 	struct nfs4_deviceid_node *node = FILELAYOUT_DEVID_NODE(lseg);
 
-	return filelayout_test_layout_invalid(lseg->pls_layout) ||
+	return pnfs_test_layout_destroyed(lseg->pls_layout) ||
 		filelayout_test_devid_unavailable(node);
 }
 
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index 10b0f13..dca47d78 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -129,12 +129,6 @@ filelayout_mark_devid_invalid(struct nfs4_deviceid_node *node)
 }
 
 static inline bool
-filelayout_test_layout_invalid(struct pnfs_layout_hdr *lo)
-{
-	return test_bit(NFS_LAYOUT_INVALID, &lo->plh_flags);
-}
-
-static inline bool
 filelayout_test_devid_invalid(struct nfs4_deviceid_node *node)
 {
 	return test_bit(NFS_DEVICEID_INVALID, &node->flags);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index aa9fa1b..aacda7f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -63,7 +63,6 @@ enum {
 	NFS_LAYOUT_BULK_RECALL,		/* bulk recall affecting layout */
 	NFS_LAYOUT_ROC,			/* some lseg had roc bit set */
 	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
-	NFS_LAYOUT_INVALID,		/* layout is being destroyed */
 	NFS_LAYOUT_RETURNED,		/* layout has already been returned */
 };
 
@@ -279,6 +278,12 @@ pnfs_test_layout_returned(struct pnfs_layout_hdr *lo)
 	return test_bit(NFS_LAYOUT_RETURNED, &lo->plh_flags);
 }
 
+static inline bool
+pnfs_test_layout_destroyed(struct pnfs_layout_hdr *lo)
+{
+	return test_bit(NFS_LAYOUT_DESTROYED, &lo->plh_flags);
+}
+
 static inline struct pnfs_layout_segment *
 pnfs_get_lseg(struct pnfs_layout_segment *lseg)
 {
-- 
1.7.11.4

