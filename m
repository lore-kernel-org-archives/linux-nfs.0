Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35770 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbcERVIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2016 17:08:12 -0400
Received: by mail-pa0-f45.google.com with SMTP id tb2so3916969pac.2
        for <linux-nfs@vger.kernel.org>; Wed, 18 May 2016 14:08:11 -0700 (PDT)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: [PATCH 3/3] pnfs: pnfs_update_layout needs to consider if strict iomode checking is on
Date: Wed, 18 May 2016 14:07:56 -0700
Message-Id: <1463605676-82483-4-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
References: <1463605676-82483-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As flexfiles has FF_FLAGS_NO_READ_IO, there is a need to generically
support enforcing that a IOMODE_RW segment will not allow READ I/O.

Signed-off-by: Tom Haynes <loghyr@primarydata.com>
---
 fs/nfs/filelayout/filelayout.c         |  2 ++
 fs/nfs/flexfilelayout/flexfilelayout.c | 49 +++++++++++++++++++++++++---------
 fs/nfs/pnfs.c                          | 34 ++++++++++++++---------
 fs/nfs/pnfs.h                          |  1 +
 4 files changed, 61 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 7cda834..8f9ab33 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -898,6 +898,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 					   0,
 					   NFS4_MAX_UINT64,
 					   IOMODE_READ,
+					   false,
 					   GFP_KERNEL);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
@@ -923,6 +924,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 					   0,
 					   NFS4_MAX_UINT64,
 					   IOMODE_RW,
+					   false,
 					   GFP_NOFS);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ea24b0a..6b62035 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -843,6 +843,36 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 }
 
 static void
+ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
+		      struct nfs_page *req,
+		      bool strict_iomode)
+{
+retry_strict:
+	pnfs_put_lseg(pgio->pg_lseg);
+	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
+					   req->wb_context,
+					   0,
+					   NFS4_MAX_UINT64,
+					   IOMODE_READ,
+					   strict_iomode,
+					   GFP_KERNEL);
+	if (IS_ERR(pgio->pg_lseg)) {
+		pgio->pg_error = PTR_ERR(pgio->pg_lseg);
+		pgio->pg_lseg = NULL;
+	}
+
+	/* If we don't have checking, do get a IOMODE_RW
+	 * segment, and the server wants to avoid READs
+	 * there, then retry!
+	 */
+	if (pgio->pg_lseg && !strict_iomode &&
+	    ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
+		strict_iomode = true;
+		goto retry_strict;
+	}
+}
+
+static void
 ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 			struct nfs_page *req)
 {
@@ -852,19 +882,10 @@ ff_layout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	int ds_idx;
 
 	/* Use full layout for now */
-	if (!pgio->pg_lseg || ff_layout_avoid_read_on_rw(pgio->pg_lseg)) {
-		pnfs_put_lseg(pgio->pg_lseg);
-		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   req->wb_context,
-						   0,
-						   NFS4_MAX_UINT64,
-						   IOMODE_READ,
-						   GFP_KERNEL);
-		if (IS_ERR(pgio->pg_lseg)) {
-			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
-			pgio->pg_lseg = NULL;
-		}
-	}
+	if (!pgio->pg_lseg)
+		ff_layout_pg_get_read(pgio, req, false);
+	else if (ff_layout_avoid_read_on_rw(pgio->pg_lseg))
+		ff_layout_pg_get_read(pgio, req, true);
 
 	/* If no lseg, fall back to read through mds */
 	if (pgio->pg_lseg == NULL)
@@ -916,6 +937,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 						   0,
 						   NFS4_MAX_UINT64,
 						   IOMODE_RW,
+						   false,
 						   GFP_NOFS);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
@@ -974,6 +996,7 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 						   0,
 						   NFS4_MAX_UINT64,
 						   IOMODE_RW,
+						   false,
 						   GFP_NOFS);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8bbaeaa..376cedf 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1321,23 +1321,28 @@ out_existing:
 
 /*
  * iomode matching rules:
- * iomode	lseg	match
- * -----	-----	-----
- * ANY		READ	true
- * ANY		RW	true
- * RW		READ	false
- * RW		RW	true
- * READ		READ	true
- * READ		RW	true
+ * iomode	lseg	strict match
+ *                      iomode
+ * -----	-----	------ -----
+ * ANY		READ	N/A    true
+ * ANY		RW	N/A    true
+ * RW		READ	N/A    false
+ * RW		RW	N/A    true
+ * READ		READ	N/A    true
+ * READ		RW	true   false
+ * READ		RW	false  true
  */
 static bool
 pnfs_lseg_range_match(const struct pnfs_layout_range *ls_range,
-		 const struct pnfs_layout_range *range)
+		 const struct pnfs_layout_range *range,
+		 bool strict_iomode)
 {
 	struct pnfs_layout_range range1;
 
 	if ((range->iomode == IOMODE_RW &&
 	     ls_range->iomode != IOMODE_RW) ||
+	    (range->iomode != ls_range->iomode &&
+	     strict_iomode == true) ||
 	    !pnfs_lseg_range_intersecting(ls_range, range))
 		return 0;
 
@@ -1352,7 +1357,8 @@ pnfs_lseg_range_match(const struct pnfs_layout_range *ls_range,
  */
 static struct pnfs_layout_segment *
 pnfs_find_lseg(struct pnfs_layout_hdr *lo,
-		struct pnfs_layout_range *range)
+		struct pnfs_layout_range *range,
+		bool strict_iomode)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
 
@@ -1361,7 +1367,8 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
 		    !test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags) &&
-		    pnfs_lseg_range_match(&lseg->pls_range, range)) {
+		    pnfs_lseg_range_match(&lseg->pls_range, range,
+					  strict_iomode)) {
 			ret = pnfs_get_lseg(lseg);
 			break;
 		}
@@ -1478,6 +1485,7 @@ pnfs_update_layout(struct inode *ino,
 		   loff_t pos,
 		   u64 count,
 		   enum pnfs_iomode iomode,
+		   bool strict_iomode,
 		   gfp_t gfp_flags)
 {
 	struct pnfs_layout_range arg = {
@@ -1539,7 +1547,7 @@ lookup_again:
 		goto out_unlock;
 	}
 
-	lseg = pnfs_find_lseg(lo, &arg);
+	lseg = pnfs_find_lseg(lo, &arg, strict_iomode);
 	if (lseg) {
 		trace_pnfs_update_layout(ino, pos, count, iomode, lo, lseg,
 				PNFS_UPDATE_LAYOUT_FOUND_CACHED);
@@ -1858,6 +1866,7 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 						   req_offset(req),
 						   rd_size,
 						   IOMODE_READ,
+						   false,
 						   GFP_KERNEL);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
@@ -1882,6 +1891,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 						   req_offset(req),
 						   wb_size,
 						   IOMODE_RW,
+						   false,
 						   GFP_NOFS);
 		if (IS_ERR(pgio->pg_lseg)) {
 			pgio->pg_error = PTR_ERR(pgio->pg_lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 30d94d1e..ce1b5bc 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -299,6 +299,7 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 					       loff_t pos,
 					       u64 count,
 					       enum pnfs_iomode iomode,
+					       bool strict_iomode,
 					       gfp_t gfp_flags);
 void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo);
 
-- 
1.8.3.1

