Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47231 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab1BUWbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:31:02 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 8/9] pnfs: fix nfs4_asynch_forget_layouts accounting
Date: Mon, 21 Feb 2011 14:30:58 -0800
Message-Id: <1298327458-9310-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

increment notify_count only the first time is it associated with a callback.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8c5f4b4..a10e8e8 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -441,17 +441,22 @@ should_free_lseg(struct pnfs_layout_range *lseg_range,
 	       lo_seg_intersecting(lseg_range, recall_range);
 }
 
-static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
+static bool mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 			      struct list_head *tmp_list)
 {
+	bool rv;
+
 	assert_spin_locked(&lseg->layout->inode->i_lock);
-	if (test_and_clear_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
+	rv = test_and_clear_bit(NFS_LSEG_VALID, &lseg->pls_flags);
+	if (rv) {
 		/* Remove the reference keeping the lseg in the
 		 * list.  It will now be removed when all
 		 * outstanding io is finished.
 		 */
 		put_lseg_locked(lseg, tmp_list);
 	}
+
+	return rv;
 }
 
 /* Returns false if there was nothing to do, true otherwise */
@@ -652,8 +657,10 @@ bool nfs4_asynch_forget_layouts(struct pnfs_layout_hdr *lo,
 	dprintk("%s\n", __func__);
 	list_for_each_entry_safe(lseg, tmp, &lo->segs, fi_list)
 		if (should_free_lseg(&lseg->range, range)) {
-			lseg->pls_notify_mask |= (1 << notify_idx);
-			atomic_inc(notify_count);
+			if (lseg->pls_notify_mask & (1 << notify_idx)) {
+				lseg->pls_notify_mask |= (1 << notify_idx);
+				atomic_inc(notify_count);
+			}
 			mark_lseg_invalid(lseg, tmp_list);
 			rv = true;
 		}
-- 
1.7.3.4

