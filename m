Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37924 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab1EIRG7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:06:59 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 03/29] pnfs: Use byte-range for layoutget
Date: Mon,  9 May 2011 20:06:51 +0300
Message-Id: <1304960811-3863-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Add offset and count parameters to pnfs_update_layout and use them to get
the layout in the pageio path.

Test byte range against the layout segment in use in pnfs_{read,write}_pg_test
so not to coalesce pages not using the same layout segment.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c  |  149 +++++++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfs/pnfs.h  |    4 +-
 fs/nfs/read.c  |   10 +++-
 fs/nfs/write.c |    8 ++-
 4 files changed, 136 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d9ab972..e689bdf 100644
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
@@ -466,7 +525,7 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
-	   u32 iomode)
+	   struct pnfs_layout_range *range)
 {
 	struct inode *ino = lo->plh_inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -497,11 +556,11 @@ send_layoutget(struct pnfs_layout_hdr *lo,
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
@@ -515,7 +574,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 	nfs4_proc_layoutget(lgp);
 	if (!lseg) {
 		/* remember that LAYOUTGET failed and suspend trying */
-		set_bit(lo_fail_bit(iomode), &lo->plh_flags);
+		set_bit(lo_fail_bit(range->iomode), &lo->plh_flags);
 	}
 
 	/* free xdr pages */
@@ -622,10 +681,24 @@ bool pnfs_roc_drain(struct inode *ino, u32 *barrier)
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
@@ -639,7 +712,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lp, &lo->plh_segs, pls_list) {
-		if (cmp_layout(lp->pls_range.iomode, lseg->pls_range.iomode) > 0)
+		if (cmp_layout(&lp->pls_range, &lseg->pls_range) > 0)
 			continue;
 		list_add_tail(&lseg->pls_list, &lp->pls_list);
 		dprintk("%s: inserted lseg %p "
@@ -718,16 +791,28 @@ pnfs_find_alloc_layout(struct inode *ino)
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
 
@@ -736,11 +821,11 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
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
 
@@ -756,8 +841,15 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo, u32 iomode)
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
@@ -785,7 +877,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 
 	/* Check to see if the layout for the given range already exists */
-	lseg = pnfs_find_lseg(lo, iomode);
+	lseg = pnfs_find_lseg(lo, &arg);
 	if (lseg)
 		goto out_unlock;
 
@@ -807,7 +899,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&clp->cl_lock);
 	}
 
-	lseg = send_layoutget(lo, ctx, iomode);
+	lseg = send_layoutget(lo, ctx, &arg);
 	if (!lseg && first) {
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->plh_layouts);
@@ -834,17 +926,6 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
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
@@ -899,8 +980,13 @@ static int pnfs_read_pg_test(struct nfs_pageio_descriptor *pgio,
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
 
@@ -921,8 +1007,13 @@ static int pnfs_write_pg_test(struct nfs_pageio_descriptor *pgio,
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
index 4cb0a0d..14a2af9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -129,7 +129,7 @@ void get_layout_hdr(struct pnfs_layout_hdr *lo);
 void put_lseg(struct pnfs_layout_segment *lseg);
 struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type);
+		   loff_t pos, u64 count, enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
@@ -248,7 +248,7 @@ static inline void put_lseg(struct pnfs_layout_segment *lseg)
 
 static inline struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
-		   enum pnfs_iomode access_type)
+		   loff_t pos, u64 count, enum pnfs_iomode access_type)
 {
 	return NULL;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 7cded2b..10eff1c 100644
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
+					  req_offset(req), desc->pg_count,
+					  IOMODE_READ);
 
 	ret = nfs_read_rpcsetup(req, data, &nfs_read_full_ops, desc->pg_count,
 				0, lseg);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e4cbc11..318e0a3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -940,7 +940,9 @@ static int nfs_flush_multi(struct nfs_pageio_descriptor *desc)
 	atomic_set(&req->wb_complete, requests);
 
 	BUG_ON(desc->pg_lseg);
-	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context, IOMODE_RW);
+	lseg = pnfs_update_layout(desc->pg_inode, req->wb_context,
+				  req_offset(req), desc->pg_count,
+				  IOMODE_RW);
 	ClearPageError(page);
 	offset = 0;
 	nbytes = desc->pg_count;
@@ -1014,7 +1016,9 @@ static int nfs_flush_one(struct nfs_pageio_descriptor *desc)
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

