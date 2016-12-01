Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36678 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759716AbcLAWTc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:32 -0500
Received: by mail-io0-f193.google.com with SMTP id s82so3821199ioi.3
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:32 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 07/26] pNFS: consolidate the different range intersection tests
Date: Thu,  1 Dec 2016 17:19:03 -0500
Message-Id: <20161201221922.15657-8-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-7-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both pnfs.c and the flexfiles code have their own versions of the
range intersection testing, and the "end_offset" helper.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 33 +++++++----------------------
 fs/nfs/pnfs.c                             | 35 +++----------------------------
 fs/nfs/pnfs.h                             | 32 ++++++++++++++++++++++++++++
 3 files changed, 43 insertions(+), 57 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index f7a3f6b05369..6cf545c06cd3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -198,22 +198,13 @@ static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 	return true;
 }
 
-static u64
-end_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	end = start + len;
-	return end >= start ? end : NFS4_MAX_UINT64;
-}
-
 static void extend_ds_error(struct nfs4_ff_layout_ds_err *err,
 			    u64 offset, u64 length)
 {
 	u64 end;
 
-	end = max_t(u64, end_offset(err->offset, err->length),
-		    end_offset(offset, length));
+	end = max_t(u64, pnfs_end_offset(err->offset, err->length),
+		    pnfs_end_offset(offset, length));
 	err->offset = min_t(u64, err->offset, offset);
 	err->length = end - err->offset;
 }
@@ -235,9 +226,9 @@ ff_ds_error_match(const struct nfs4_ff_layout_ds_err *e1,
 	ret = memcmp(&e1->deviceid, &e2->deviceid, sizeof(e1->deviceid));
 	if (ret != 0)
 		return ret;
-	if (end_offset(e1->offset, e1->length) < e2->offset)
+	if (pnfs_end_offset(e1->offset, e1->length) < e2->offset)
 		return -1;
-	if (e1->offset > end_offset(e2->offset, e2->length))
+	if (e1->offset > pnfs_end_offset(e2->offset, e2->length))
 		return 1;
 	/* If ranges overlap or are contiguous, they are the same */
 	return 0;
@@ -457,16 +448,6 @@ nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg, u32 ds_idx,
 	}
 }
 
-static bool is_range_intersecting(u64 offset1, u64 length1,
-				  u64 offset2, u64 length2)
-{
-	u64 end1 = end_offset(offset1, length1);
-	u64 end2 = end_offset(offset2, length2);
-
-	return (end1 == NFS4_MAX_UINT64 || end1 > offset2) &&
-	       (end2 == NFS4_MAX_UINT64 || end2 > offset1);
-}
-
 /* called with inode i_lock held */
 int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 			      struct xdr_stream *xdr, int *count,
@@ -476,8 +457,10 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 	__be32 *p;
 
 	list_for_each_entry_safe(err, n, &flo->error_list, list) {
-		if (!is_range_intersecting(err->offset, err->length,
-					   range->offset, range->length))
+		if (!pnfs_is_range_intersecting(err->offset,
+				pnfs_end_offset(err->offset, err->length),
+				range->offset,
+				pnfs_end_offset(range->offset, range->length)))
 			continue;
 		/* offset(8) + length(8) + stateid(NFS4_STATEID_SIZE)
 		 * + array length + deviceid(NFS4_DEVICEID4_SIZE)
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index e17d9ec82ca7..d70cc467a87b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -500,15 +500,6 @@ pnfs_put_lseg_locked(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(pnfs_put_lseg_locked);
 
-static u64
-end_offset(u64 start, u64 len)
-{
-	u64 end;
-
-	end = start + len;
-	return end >= start ? end : NFS4_MAX_UINT64;
-}
-
 /*
  * is l2 fully contained in l1?
  *   start1                             end1
@@ -521,33 +512,13 @@ pnfs_lseg_range_contained(const struct pnfs_layout_range *l1,
 		 const struct pnfs_layout_range *l2)
 {
 	u64 start1 = l1->offset;
-	u64 end1 = end_offset(start1, l1->length);
+	u64 end1 = pnfs_end_offset(start1, l1->length);
 	u64 start2 = l2->offset;
-	u64 end2 = end_offset(start2, l2->length);
+	u64 end2 = pnfs_end_offset(start2, l2->length);
 
 	return (start1 <= start2) && (end1 >= end2);
 }
 
-/*
- * is l1 and l2 intersecting?
- *   start1                             end1
- *   [----------------------------------)
- *                              start2           end2
- *                              [----------------)
- */
-static bool
-pnfs_lseg_range_intersecting(const struct pnfs_layout_range *l1,
-		    const struct pnfs_layout_range *l2)
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
 static bool pnfs_lseg_dec_and_remove_zero(struct pnfs_layout_segment *lseg,
 		struct list_head *tmp_list)
 {
@@ -2069,7 +2040,7 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 	 *
 	 */
 	if (pgio->pg_lseg) {
-		seg_end = end_offset(pgio->pg_lseg->pls_range.offset,
+		seg_end = pnfs_end_offset(pgio->pg_lseg->pls_range.offset,
 				     pgio->pg_lseg->pls_range.length);
 		req_start = req_offset(req);
 		WARN_ON_ONCE(req_start >= seg_end);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 44cad8afda0e..337dad382b6a 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -560,6 +560,38 @@ pnfs_copy_range(struct pnfs_layout_range *dst,
 	memcpy(dst, src, sizeof(*dst));
 }
 
+static inline u64
+pnfs_end_offset(u64 start, u64 len)
+{
+	if (NFS4_MAX_UINT64 - start <= len)
+		return NFS4_MAX_UINT64;
+	return start + len;
+}
+
+/*
+ * Are 2 ranges intersecting?
+ *   start1                             end1
+ *   [----------------------------------)
+ *                                start2           end2
+ *                                [----------------)
+ */
+static inline bool
+pnfs_is_range_intersecting(u64 start1, u64 end1, u64 start2, u64 end2)
+{
+	return (end1 == NFS4_MAX_UINT64 || start2 < end1) &&
+		(end2 == NFS4_MAX_UINT64 || start1 < end2);
+}
+
+static inline bool
+pnfs_lseg_range_intersecting(const struct pnfs_layout_range *l1,
+		const struct pnfs_layout_range *l2)
+{
+	u64 end1 = pnfs_end_offset(l1->offset, l1->length);
+	u64 end2 = pnfs_end_offset(l2->offset, l2->length);
+
+	return pnfs_is_range_intersecting(l1->offset, end1, l2->offset, end2);
+}
+
 extern unsigned int layoutstats_timer;
 
 #ifdef NFS_DEBUG
-- 
2.9.3

