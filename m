Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56426 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752289AbdEVSUg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 14:20:36 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfs: Fix the check for requests in range of layout segment
Date: Mon, 22 May 2017 14:20:32 -0400
Message-Id: <bf2ea18703f605c6fcfe698f5a59c6062ca590ed.1495477047.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible and acceptable for NFS to attempt to add requests beyond the
range of the current pgio->pg_lseg, a case which should be caught and
limited by the pg_test operation.  However, the current handling of this
case replaces pgio->pg_lseg with a new layout segment (after a WARN) within
that pg_test operation.  That will cause all the previously added requests
to be submitted with this new layout segment, which may not be valid for
those requests.

Fix this problem by only returning zero for the number of bytes to coalesce
from pg_test for this case which allows any previously added requests to
complete on the current layout segment.  The check for requests starting
out of range of the layout segment moves to pg_init, so that the
replacement of pgio->pg_lseg will be done when the next request is added.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/pnfs.c | 27 +++++++++++++++++++--------
 fs/nfs/pnfs.h | 10 ++++++++++
 2 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index adc6ec28d4b5..0c26de3d3914 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2094,12 +2094,28 @@ pnfs_generic_pg_check_layout(struct nfs_pageio_descriptor *pgio)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_check_layout);
 
+/*
+ * Check for any intersection between the request and the pgio->pg_lseg,
+ * and if none, put this pgio->pg_lseg away.
+ */
+static void
+pnfs_generic_pg_check_range(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
+{
+	if (pgio->pg_lseg && !pnfs_lseg_request_intersecting(pgio->pg_lseg, req)) {
+		if (pgio->pg_ops->pg_cleanup)
+			pgio->pg_ops->pg_cleanup(pgio);
+		else
+			pnfs_generic_pg_cleanup(pgio);
+	}
+}
+
 void
 pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
 {
 	u64 rd_size = req->wb_bytes;
 
 	pnfs_generic_pg_check_layout(pgio);
+	pnfs_generic_pg_check_range(pgio, req);
 	if (pgio->pg_lseg == NULL) {
 		if (pgio->pg_dreq == NULL)
 			rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
@@ -2131,6 +2147,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
 {
 	pnfs_generic_pg_check_layout(pgio);
+	pnfs_generic_pg_check_range(pgio, req);
 	if (pgio->pg_lseg == NULL) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   req->wb_context,
@@ -2191,16 +2208,10 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio,
 		seg_end = pnfs_end_offset(pgio->pg_lseg->pls_range.offset,
 				     pgio->pg_lseg->pls_range.length);
 		req_start = req_offset(req);
-		WARN_ON_ONCE(req_start >= seg_end);
+
 		/* start of request is past the last byte of this segment */
-		if (req_start >= seg_end) {
-			/* reference the new lseg */
-			if (pgio->pg_ops->pg_cleanup)
-				pgio->pg_ops->pg_cleanup(pgio);
-			if (pgio->pg_ops->pg_init)
-				pgio->pg_ops->pg_init(pgio, req);
+		if (req_start >= seg_end)
 			return 0;
-		}
 
 		/* adjust 'size' iff there are fewer bytes left in the
 		 * segment than what nfs_generic_pg_test returned */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 2d05b756a8d6..99731e3e332f 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -593,6 +593,16 @@ pnfs_lseg_range_intersecting(const struct pnfs_layout_range *l1,
 	return pnfs_is_range_intersecting(l1->offset, end1, l2->offset, end2);
 }
 
+static inline bool
+pnfs_lseg_request_intersecting(struct pnfs_layout_segment *lseg, struct nfs_page *req)
+{
+	u64 seg_last = pnfs_end_offset(lseg->pls_range.offset, lseg->pls_range.length);
+	u64 req_last = req_offset(req) + req->wb_bytes;
+
+	return pnfs_is_range_intersecting(lseg->pls_range.offset, seg_last,
+				req_offset(req), req_last);
+}
+
 extern unsigned int layoutstats_timer;
 
 #ifdef NFS_DEBUG
-- 
2.9.3

