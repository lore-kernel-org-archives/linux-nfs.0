Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36648 "EHLO
	mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbcGVTeu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 15:34:50 -0400
Received: by mail-it0-f65.google.com with SMTP id j124so3675976ith.3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 12:34:50 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] NFS: pnfs_mark_matching_lsegs_return() should match the layout sequence id
Date: Fri, 22 Jul 2016 15:33:57 -0400
Message-Id: <1469216038-71882-6-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469216038-71882-5-git-send-email-trond.myklebust@primarydata.com>
References: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-2-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-3-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-4-git-send-email-trond.myklebust@primarydata.com>
 <1469216038-71882-5-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When determining which layout segments to return, we do want
pnfs_mark_matching_lsegs_return to check that they match the layout
sequence id. This ensures that we don't waste time if the server
is replaying a layout recall that has already been satisfied.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 37 +++++++++++++++++++++++--------------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 010f8803090b..0d68768e7afe 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -484,15 +484,6 @@ pnfs_lseg_range_intersecting(const struct pnfs_layout_range *l1,
 	       (end2 == NFS4_MAX_UINT64 || end2 > start1);
 }
 
-static bool
-should_free_lseg(const struct pnfs_layout_range *lseg_range,
-		 const struct pnfs_layout_range *recall_range)
-{
-	return (recall_range->iomode == IOMODE_ANY ||
-		lseg_range->iomode == recall_range->iomode) &&
-	       pnfs_lseg_range_intersecting(lseg_range, recall_range);
-}
-
 static bool pnfs_lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,
 		struct list_head *tmp_list)
 {
@@ -531,6 +522,27 @@ static bool pnfs_seqid_is_newer(u32 s1, u32 s2)
 	return (s32)(s1 - s2) > 0;
 }
 
+static bool
+pnfs_should_free_range(const struct pnfs_layout_range *lseg_range,
+		 const struct pnfs_layout_range *recall_range)
+{
+	return (recall_range->iomode == IOMODE_ANY ||
+		lseg_range->iomode == recall_range->iomode) &&
+	       pnfs_lseg_range_intersecting(lseg_range, recall_range);
+}
+
+static bool
+pnfs_match_lseg_recall(const struct pnfs_layout_segment *lseg,
+		const struct pnfs_layout_range *recall_range,
+		u32 seq)
+{
+	if (seq != 0 && pnfs_seqid_is_newer(lseg->pls_seq, seq))
+		return false;
+	if (recall_range == NULL)
+		return true;
+	return pnfs_should_free_range(&lseg->pls_range, recall_range);
+}
+
 /**
  * pnfs_mark_matching_lsegs_invalid - tear down lsegs or mark them for later
  * @lo: layout header containing the lsegs
@@ -560,10 +572,7 @@ pnfs_mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 	if (list_empty(&lo->plh_segs))
 		return 0;
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (!recall_range ||
-		    should_free_lseg(&lseg->pls_range, recall_range)) {
-			if (seq && pnfs_seqid_is_newer(lseg->pls_seq, seq))
-				continue;
+		if (pnfs_match_lseg_recall(lseg, recall_range, seq)) {
 			dprintk("%s: freeing lseg %p iomode %d seq %u"
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode, lseg->pls_seq,
@@ -1839,7 +1848,7 @@ pnfs_mark_matching_lsegs_return(struct pnfs_layout_hdr *lo,
 	assert_spin_locked(&lo->plh_inode->i_lock);
 
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (should_free_lseg(&lseg->pls_range, return_range)) {
+		if (pnfs_match_lseg_recall(lseg, return_range, seq)) {
 			dprintk("%s: marking lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode,
-- 
2.7.4

