Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57095 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753247Ab1DTR0z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:26:55 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 05/27] pnfs: Use byte-range layout segments
Date: Wed, 20 Apr 2011 20:26:49 +0300
Message-Id: <1303320409-21143-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |    4 +-
 fs/nfs/pnfs.c          |  175 +++++++++++++++++++++++++++++++++++++----------
 fs/nfs/pnfs.h          |    6 +-
 fs/nfs/read.c          |   10 ++-
 fs/nfs/write.c         |    8 ++-
 5 files changed, 156 insertions(+), 47 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 99494f6..96f35f2 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -139,7 +139,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
 	spin_lock(&ino->i_lock);
 	if (test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags) ||
 	    mark_matching_lsegs_invalid(lo, &free_me_list,
-					args->cbl_range.iomode))
+					&args->cbl_range))
 		rv = NFS4ERR_DELAY;
 	else
 		rv = NFS4ERR_NOMATCHING_LAYOUT;
@@ -184,7 +184,7 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 		ino = lo->plh_inode;
 		spin_lock(&ino->i_lock);
 		set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-		if (mark_matching_lsegs_invalid(lo, &free_me_list, range.iomode))
+		if (mark_matching_lsegs_invalid(lo, &free_me_list, &range))
 			rv = NFS4ERR_DELAY;
 		list_del_init(&lo->plh_bulk_recall);
 		spin_unlock(&ino->i_lock);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 89e7725..0b4ad1f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -261,11 +261,72 @@ put_lseg(struct pnfs_layout_segment *lseg)
 }
 EXPORT_SYMBOL_GPL(put_lseg);
 
-static bool
-should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
+static inline u64
+end_offset(u64 start, u64 len)
+{
+	u64 end;
+
+	end = start + len;
+	return end >= start ? end: NFS4_MAX_UINT64;
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
+	return end > start ? end - 1: NFS4_MAX_UINT64;
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
+bool
+should_free_lseg(struct pnfs_layout_range *lseg_range,
+		 struct pnfs_layout_range *recall_range)
 {
-	return (recall_iomode == IOMODE_ANY ||
-		lseg_iomode == recall_iomode);
+	return (recall_range->iomode == IOMODE_ANY ||
+		lseg_range->iomode == recall_range->iomode) &&
+	       lo_seg_intersecting(lseg_range, recall_range);
 }
 
 /* Returns 1 if lseg is removed from list, 0 otherwise */
@@ -296,7 +357,7 @@ static int mark_lseg_invalid(struct pnfs_layout_segment *lseg,
 int
 mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 			    struct list_head *tmp_list,
-			    u32 iomode)
+			    struct pnfs_layout_range *recall_range)
 {
 	struct pnfs_layout_segment *lseg, *next;
 	int invalid = 0, removed = 0;
@@ -309,10 +370,11 @@ mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (should_free_lseg(lseg->pls_range.iomode, iomode)) {
+		if (should_free_lseg(&lseg->pls_range, recall_range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
-				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
+				lseg, lseg->pls_range.iomode,
+				lseg->pls_range.offset,
 				lseg->pls_range.length);
 			invalid++;
 			removed += mark_lseg_invalid(lseg, tmp_list);
@@ -338,7 +400,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list,
 		return 0;
 	}
 	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
-		if (should_free_lseg(lseg->pls_range.iomode, range->iomode)) {
+		if (should_free_lseg(&lseg->pls_range, range)) {
 			dprintk("%s: freeing lseg %p iomode %d "
 				"offset %llu length %llu\n", __func__,
 				lseg, lseg->pls_range.iomode,
@@ -383,12 +445,17 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 	struct pnfs_layout_hdr *lo;
 	LIST_HEAD(tmp_list);
+	struct pnfs_layout_range range = {
+		.iomode = IOMODE_ANY,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
 
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
 		lo->plh_block_lgets++; /* permanently block new LAYOUTGETs */
-		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
+		mark_matching_lsegs_invalid(lo, &tmp_list, &range);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 	pnfs_free_lseg_list(&tmp_list);
@@ -496,7 +563,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
-	   u32 iomode)
+	   struct pnfs_layout_range *range)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -527,11 +594,11 @@ send_layoutget(struct pnfs_layout_hdr *lo,
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
@@ -545,7 +612,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
+		set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
 	}
 
 	/* free xdr pages */
@@ -718,10 +785,24 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
  * are seen first.
  */
 static s64
-cmp_layout(u32 iomode1, u32 iomode2)
+cmp_layout(struct pnfs_layout_range *l1,
+	   struct pnfs_layout_range *l2)
 {
+	s64 d;
+
+	/* higher offset > lower offset */
+	d = l1->offset - l2->offset;
+	if (d)
+		return d;
+
+	/* longer length > shorter length */
+	d = l1->length - l2->length;
+	if (d)
+		return d;
+
 	/* read > read/write */
-	return (int)(iomode2 == IOMODE_READ) - (int)(iomode1 == IOMODE_READ);
+	return (int)(l2->iomode == IOMODE_READ) -
+		(int)(l1->iomode == IOMODE_READ);
 }
 
 static void
@@ -735,7 +816,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
-		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
+		if (cmp_layout(&lp->pls_range, &lseg->pls_range) > 0)
 			continue;
 		list_add_tail(&lseg->pls_list, &lp->pls_list);
 		dprintk("%s: inserted lseg %p "
@@ -814,16 +895,28 @@ pnfs_find_alloc_layout(struct inode *ino)
  * READ		RW	true
  */
 static int
-is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
+is_matching_lseg(struct pnfs_layout_segment *lseg,
+		 struct pnfs_layout_range *range)
 {
-	return (iomode != IOMODE_RW || lseg->pls_range.iomode == IOMODE_RW);
+	struct pnfs_layout_range range1;
+
+	if ((range->iomode == IOMODE_RW &&
+	     lseg->pls_range.iomode != IOMODE_RW) ||
+	    !lo_seg_intersecting(&lseg->pls_range, range))
+		return 0;
+
+	/* range1 covers only the first byte in the range */
+	range1 = *range;
+	range1.length = 1;
+	return lo_seg_contained(&lseg->pls_range, &range1);
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
 
@@ -832,11 +925,11 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
 		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
-		    is_matching_lseg(lseg, iomode)) {
+		    is_matching_lseg(lseg, range)) {
 			ret = get_lseg(lseg);
 			break;
 		}
-		if (cmp_layout(iomode, lseg->pls_range.iomode) > 0)
+		if (cmp_layout(range, &lseg->pls_range) > 0)
 			break;
 	}
 
@@ -852,8 +945,15 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino,
 		   struct nfs_open_context *ctx,
+		   loff_t pos,
+		   u64 count,
 		   enum pnfs_iomode iomode)
 {
+	struct pnfs_layout_range arg = {
+		.iomode = iomode,
+		.offset = pos,
+		.length = count,
+	};
 	struct nfs_inode *nfsi = NFS_I(ino);
 	struct nfs_client *clp = NFS_SERVER(ino)->nfs_client;
 	struct pnfs_layout_hdr *lo;
@@ -881,7 +981,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 
 	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_find_lseg(lo, iomode);
+	lseg = pnfs_find_lseg(lo, &arg);
 	if (lseg)
 		goto out_unlock;
 
@@ -903,7 +1003,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 
-	lseg = send_layoutget(lo, ctx, iomode);
+	lseg = send_layoutget(lo, ctx, &arg);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->plh_layouts);
@@ -930,17 +1030,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
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
 	lseg = NFS_SERVER(ino)->pnfs_curr_ld->alloc_lseg(lo, res);
 	if (!lseg || IS_ERR(lseg)) {
@@ -995,8 +1084,13 @@ static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
+						   req_offset(req),
+						   pgio->pg_count,
 						   IOMODE_READ);
-	}
+	} else if (pgio->pg_lseg &&
+		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+						pgio->pg_lseg->pls_range.length))
+		return 0;
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
@@ -1017,8 +1111,13 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
 		/* This is first coelesce call for a series of nfs_pages */
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
 						   prev->wb_context,
+						   req_offset(req),
+						   pgio->pg_count,
 						   IOMODE_RW);
-	}
+	} else if (pgio->pg_lseg &&
+		   req_offset(req) > end_offset(pgio->pg_lseg->pls_range.offset,
+						pgio->pg_lseg->pls_range.length))
+		return 0;
 	return NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->pg_test(pgio, prev, req);
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 3506ad4..c315109 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -136,7 +136,7 @@ void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type);
+		   loff_t pos, u64 count, enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
@@ -158,7 +158,7 @@ int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct nfs4_state *open_state);
 int mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
 				struct list_head *tmp_list,
-				u32 iomode);
+				struct pnfs_layout_range *recall_range);
 bool pnfs_roc(struct inode *ino);
 void pnfs_roc_release(struct inode *ino);
 void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
@@ -279,7 +279,7 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type)
+		   loff_t pos, u64 count, enum pnfs_iomode access_type)
 {
 	return NULL;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 7cded2b..f43d41a 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -288,13 +288,17 @@ static int nfs_pagein_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg != NULL);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+				  req_offset(req), desc->pg_count,
+				  IOMODE_READ);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
 	do {
 		int ret2;
 
+		/* FIXME: need a new layout segment? */
+
 		data = list_entry(list.next, struct nfs_read_data, pages);
 		list_del_init(&data->pages);
 
@@ -351,7 +355,9 @@ static int nfs_pagein_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_READ);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+     					  req_offset(req), desc->pg_count,
+					  IOMODE_READ);
 
 	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
 				0, lseg);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af0c627..5d76bf5 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -936,7 +936,9 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+				  req_offset(req), desc->pg_count,
+				  IOMODE_RW);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -1010,7 +1012,9 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
 	}
 	req = nfs_list_entry(data->pages.next);
 	if ((!lseg) && list_is_singular(&data->pages))
-		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
+		lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+					  req_offset(req), desc->pg_count,
+					  IOMODE_RW);
 
 	if ((desc->pg_ioflags & FLUSH_COND_STABLE) &&
 	    (desc->pg_moreio || NFS_I(desc->pg_inode)->ncommit))
-- 
1.7.3.4

