Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43432 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754626Ab1EVXvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:51:35 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 12/38] pnfs: Use byte-range for layoutget
Date: Mon, 23 May 2011 02:51:00 +0300
Message-Id: <1306108260-28319-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add offset and count parameters to pnfs_update_layout and use them to get
the layout in the pageio path.

Order cache layout segments in the following order:
* offset (ascending)
* length (descending)
* iomode (RW before READ)

Test byte range against the layout segment in use in pnfs_{read,write}_pg_test
so not to coalesce pages not using the same layout segment.

[fix lseg ordering]
[clean up pnfs_find_lseg lseg arg]
[remove unnecessary FIXME]
[fix ordering in pnfs_insert_layout]
[clean up pnfs_insert_layout]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c  |  165 ++++++++++++++++++++++++++++++++++++++++++-------------
 fs/nfs/pnfs.h  |    6 ++-
 fs/nfs/read.c  |    8 ++-
 fs/nfs/write.c |    8 ++-
 4 files changed, 142 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f57f528..c2f09e9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -261,6 +261,65 @@ put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
+static inline u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end : NFS4_MAX_UINT64;
+}
+
+/* last octet in a range */
+static inline u64
+last_byte_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	BUG_ON(!len);
+	end = start + len;
+	return end > start ? end - 1 : NFS4_MAX_UINT64;
+}
+
+/*
+ * is l2 fully contained in l1?
+ *   start1                             end1
+ *   [----------------------------------)
+ *           start2           end2
+ *           [----------------)
+ */
+static inline int
+lo_seg_contained(struct pnfs_layout_range *l1,
+		 struct pnfs_layout_range *l2)
+{
+	u64 start1 = l1->offset;
+	u64 end1 = end_offset(start1, l1->length);
+	u64 start2 = l2->offset;
+	u64 end2 = end_offset(start2, l2->length);
+
+	return (start1 <= start2) && (end1 >= end2);
+}
+
+/*
+ * is l1 and l2 intersecting?
+ *   start1                             end1
+ *   [----------------------------------)
+ *                              start2           end2
+ *                              [----------------)
+ */
+static inline int
+lo_seg_intersecting(struct pnfs_layout_range *l1,
+		    struct pnfs_layout_range *l2)
+{
+	u64 start1 = l1->offset;
+	u64 end1 = end_offset(start1, l1->length);
+	u64 start2 = l2->offset;
+	u64 end2 = end_offset(start2, l2->length);
+
+	return (end1 == NFS4_MAX_UINT64 || end1 > start2) &&
+	       (end2 == NFS4_MAX_UINT64 || end2 > start1);
+}
+
 static bool
 should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
 {
@@ -467,7 +526,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
-	   u32 iomode,
+	   struct pnfs_layout_range *range,
 	   gfp_t gfp_flags)
 {
 	struct inode *ino = lo->plh_inode;
@@ -499,11 +558,11 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 			goto out_err_free;
 	}
 
-	lgp->args.minlength = NFS4_MAX_UINT64;
+	lgp->args.minlength = PAGE_CACHE_SIZE;
+	if (lgp->args.minlength > range->length)
+		lgp->args.minlength = range->length;
 	lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
-	lgp->args.range.iomode = iomode;
-	lgp->args.range.offset = 0;
-	lgp->args.range.length = NFS4_MAX_UINT64;
+	lgp->args.range = *range;
 	lgp->args.type = server->pnfs_curr_ld->id;
 	lgp->args.inode = ino;
 	lgp->args.ctx = get_nfs_open_context(ctx);
@@ -518,7 +577,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
+		set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
 	}
 
 	/* free xdr pages */
@@ -625,10 +684,23 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
  * are seen first.
  */
 static s64
-cmp_layout(u32 iomode1, u32 iomode2)
+cmp_layout(struct pnfs_layout_range *l1,
+	   struct pnfs_layout_range *l2)
 {
+	s64 d;
+
+	/* high offset > low offset */
+	d = l1->offset - l2->offset;
+	if (d)
+		return d;
+
+	/* short length > long length */
+	d = l2->length - l1->length;
+	if (d)
+		return d;
+
 	/* read > read/write */
-	return (int)(iomode2 == IOMODE_READ) - (int)(iomode1 == IOMODE_READ);
+	return (int)(l1->iomode == IOMODE_READ) - (int)(l2->iomode == IOMODE_READ);
 }
 
 static void
@@ -636,13 +708,12 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 		   struct pnfs_layout_segment *lseg)
 {
 	struct pnfs_layout_segment *lp;
-	int found = 0;
 
 	dprintk("%s:Begin\n", __func__);
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
-		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
+		if (cmp_layout(&lseg->pls_range, &lp->pls_range) > 0)
 			continue;
 		list_add_tail(&lseg->pls_list, &lp->pls_list);
 		dprintk("%s: inserted lseg %p "
@@ -652,16 +723,14 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 			lseg->pls_range.offset, lseg->pls_range.length,
 			lp, lp->pls_range.iomode, lp->pls_range.offset,
 			lp->pls_range.length);
-		found = 1;
-		break;
-	}
-	if (!found) {
-		list_add_tail(&lseg->pls_list, &lo->plh_segs);
-		dprintk("%s: inserted lseg %p "
-			"iomode %d offset %llu length %llu at tail\n",
-			__func__, lseg, lseg->pls_range.iomode,
-			lseg->pls_range.offset, lseg->pls_range.length);
+		goto out;
 	}
+	list_add_tail(&lseg->pls_list, &lo->plh_segs);
+	dprintk("%s: inserted lseg %p "
+		"iomode %d offset %llu length %llu at tail\n",
+		__func__, lseg, lseg->pls_range.iomode,
+		lseg->pls_range.offset, lseg->pls_range.length);
+out:
 	get_layout_hdr(lo);
 
 	dprintk("%s:Return\n", __func__);
@@ -721,16 +790,28 @@ pnfs_find_alloc_layout(struct inode *ino, gfp_t gfp_flags)
  * READ		RW	true
  */
 static int
-is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
+is_matching_lseg(struct pnfs_layout_range *ls_range,
+		 struct pnfs_layout_range *range)
 {
-	return (iomode != IOMODE_RW || lseg->pls_range.iomode == IOMODE_RW);
+	struct pnfs_layout_range range1;
+
+	if ((range->iomode == IOMODE_RW &&
+	     ls_range->iomode != IOMODE_RW) ||
+	    !lo_seg_intersecting(ls_range, range))
+		return 0;
+
+	/* range1 covers only the first byte in the range */
+	range1 = *range;
+	range1.length = 1;
+	return lo_seg_contained(ls_range, &range1);
 }
 
 /*
  * lookup range in layout
  */
 static struct pnfs_layout_segment *
-pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
+pnfs_find_lseg(struct pnfs_layout_hdr *lo,
+		struct pnfs_layout_range *range)
 {
 	struct pnfs_layout_segment *lseg, *ret = NULL;
 
@@ -739,11 +820,11 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
-		    is_matching_lseg(lseg, iomode)) {
+		    is_matching_lseg(&lseg->pls_range, range)) {
 			ret = get_lseg(lseg);
 			break;
 		}
-		if (cmp_layout(iomode, lseg->pls_range.iomode) > 0)
+		if (cmp_layout(range, &lseg->pls_range) > 0)
 			break;
 	}
 
@@ -759,9 +840,16 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
+		   loff_t pos,
+		   u64 count,
 		   enum pnfs_iomode iomode,
 		   gfp_t gfp_flags)
 {
+	struct pnfs_layout_range arg = {
+		.iomode = iomode,
+		.offset = pos,
+		.length = count,
+	};
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	struct pnfs_layout_hdr *lo;
@@ -789,7 +877,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 
 	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_find_lseg(lo, iomode);
+	lseg = pnfs_find_lseg(lo, &arg);
 	if (lseg)
 		goto out_unlock;
 
@@ -811,7 +899,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 
-	lseg = send_layoutget(lo, ctx, iomode, gfp_flags);
+	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->plh_layouts);
@@ -838,17 +926,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	int status = 0;
 
-	/* Verify we got what we asked for.
-	 * Note that because the xdr parsing only accepts a single
-	 * element array, this can fail even if the server is behaving
-	 * correctly.
-	 */
-	if (lgp->args.range.iomode > res->range.iomode ||
-	    res->range.offset != 0 ||
-	    res->range.length != NFS4_MAX_UINT64) {
-		status = -EINVAL;
-		goto out;
-	}
 	/* Inject layout blob into I/O device driver */
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res, lgp->gfp_flags);
 	if (!lseg || IS_ERR(lseg)) {
@@ -903,9 +980,14 @@ static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
+						   req_offset(req),
+						   pgio->pg_count,
 						   IOMODE_READ,
 						   GFP_KERNEL);
-	}
+	} else if (pgio->pg_lseg &&
+		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+						pgio->pg_lseg->pls_range.length))
+		return 0;
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
@@ -926,9 +1008,14 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
+						   req_offset(req),
+						   pgio->pg_count,
 						   IOMODE_RW,
 						   GFP_NOFS);
-	}
+	} else if (pgio->pg_lseg &&
+		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+						pgio->pg_lseg->pls_range.length))
+		return 0;
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 7f29e3a..f1fb823 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -131,7 +131,8 @@ void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type, gfp_t gfp_flags);
+		   loff_t pos, u64 count, enum pnfs_iomode access_type,
+		   gfp_t gfp_flags);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
@@ -271,7 +272,8 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type, gfp_t gfp_flags)
+		   loff_t pos, u64 count, enum pnfs_iomode access_type,
+		   gfp_t gfp_flags)
 {
 	return NULL;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2bcf0dc..540c8bc 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -288,7 +288,9 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg != NULL);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ, GFP_KERNEL);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+				  req_offset(req), desc->pg_count,
+				  IOMODE_READ, GFP_KERNEL);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -351,7 +353,9 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ, GFP_KERNEL);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+					  req_offset(req), desc->pg_count,
+					  IOMODE_READ, GFP_KERNEL);
 
 	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
 				0, lseg);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 49c715b..7edb72f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -939,7 +939,9 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW, GFP_NOFS);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+				  req_offset(req), desc->pg_count,
+				  IOMODE_RW, GFP_NOFS);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -1013,7 +1015,9 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW, GFP_NOFS);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+					  req_offset(req), desc->pg_count,
+					  IOMODE_RW, GFP_NOFS);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
-- 
1.7.3.4

