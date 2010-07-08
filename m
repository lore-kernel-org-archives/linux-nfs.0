From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/4] pnfs-submit: Rely on full-file layout assumption to clean out some code
Date: Thu,  8 Jul 2010 15:25:19 -0400
Message-ID: <1278617122-24164-2-git-send-email-iisaman@netapp.com>
References: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22871 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758513Ab0GHTZ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 15:25:26 -0400
Received: from localhost.localdomain (khang-lxp.hq.netapp.com [10.58.60.105] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o68JPOdL010802
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jul 2010 12:25:25 -0700 (PDT)
In-Reply-To: <1278617122-24164-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note that even assuming full file layout, there can still be two lsegs,
one for each iomode.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   85 +-------------------------------------------------------
 1 files changed, 2 insertions(+), 83 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index baa3de7..5b0c4ec 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -444,65 +444,6 @@ put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL(put_lseg);
 
-static inline u64
-end_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	end = start + len;
-	return end >= start ? end: NFS4_MAX_UINT64;
-}
-
-/* last octet in a range */
-static inline u64
-last_byte_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	BUG_ON(!len);
-	end = start + len;
-	return end > start ? end - 1: NFS4_MAX_UINT64;
-}
-
-/*
- * is l2 fully contained in l1?
- *   start1                             end1
- *   [----------------------------------)
- *           start2           end2
- *           [----------------)
- */
-static inline int
-lo_seg_contained(struct nfs4_pnfs_layout_segment *l1,
-		 struct nfs4_pnfs_layout_segment *l2)
-{
-	u64 start1 = l1->offset;
-	u64 end1 = end_offset(start1, l1->length);
-	u64 start2 = l2->offset;
-	u64 end2 = end_offset(start2, l2->length);
-
-	return (start1 <= start2) && (end1 >= end2);
-}
-
-/*
- * is l1 and l2 intersecting?
- *   start1                             end1
- *   [----------------------------------)
- *                              start2           end2
- *                              [----------------)
- */
-static inline int
-lo_seg_intersecting(struct nfs4_pnfs_layout_segment *l1,
-		    struct nfs4_pnfs_layout_segment *l2)
-{
-	u64 start1 = l1->offset;
-	u64 end1 = end_offset(start1, l1->length);
-	u64 start2 = l2->offset;
-	u64 end2 = end_offset(start2, l2->length);
-
-	return (end1 == NFS4_MAX_UINT64 || end1 > start2) &&
-	       (end2 == NFS4_MAX_UINT64 || end2 > start1);
-}
-
 void
 pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			const nfs4_stateid *stateid)
@@ -616,8 +557,7 @@ should_free_lseg(struct pnfs_layout_segment *lseg,
 		   struct nfs4_pnfs_layout_segment *range)
 {
 	return (range->iomode == IOMODE_ANY ||
-		lseg->range.iomode == range->iomode) &&
-	       lo_seg_intersecting(&lseg->range, range);
+		lseg->range.iomode == range->iomode);
 }
 
 static struct pnfs_layout_segment *
@@ -832,18 +772,6 @@ static inline s64
 cmp_layout(struct nfs4_pnfs_layout_segment *l1,
 	   struct nfs4_pnfs_layout_segment *l2)
 {
-	s64 d;
-
-	/* higher offset > lower offset */
-	d = l1->offset - l2->offset;
-	if (d)
-		return d;
-
-	/* longer length > shorter length */
-	d = l1->length - l2->length;
-	if (d)
-		return d;
-
 	/* read > read/write */
 	return (int)(l1->iomode == IOMODE_READ) -
 	       (int)(l2->iomode == IOMODE_READ);
@@ -1004,16 +932,7 @@ static inline int
 has_matching_lseg(struct pnfs_layout_segment *lseg,
 		  struct nfs4_pnfs_layout_segment *range)
 {
-	struct nfs4_pnfs_layout_segment range1;
-
-	if ((range->iomode == IOMODE_RW && lseg->range.iomode != IOMODE_RW) ||
-	    !lo_seg_intersecting(&lseg->range, range))
-		return 0;
-
-	/* range1 covers only the first byte in the range */
-	range1 = *range;
-	range1.length = 1;
-	return lo_seg_contained(&lseg->range, &range1);
+	return (range->iomode != IOMODE_RW || lseg->range.iomode == IOMODE_RW);
 }
 
 /*
-- 
1.6.6.1

