Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37637 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbaICEge (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:36:34 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP2J6-0003bd-HM
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:36:33 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] pnfs/blocklayout: refactor extent processing
Date: Tue,  2 Sep 2014 21:38:36 -0700
Message-Id: <1409719119-2110-4-git-send-email-hch@lst.de>
In-Reply-To: <1409719119-2110-1-git-send-email-hch@lst.de>
References: <1409719119-2110-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Factor out a helper for all per-extent work, and merge the now trivial
functions for lseg allocation and parsing.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c | 207 ++++++++++++++++++++-------------------
 1 file changed, 105 insertions(+), 102 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index df8c567..28a8102 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -513,144 +513,147 @@ static int decode_sector_number(__be32 **rp, sector_t *sp)
 	return 0;
 }
 
-/* XDR decode pnfs_block_layout4 structure */
 static int
-nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
-			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
+bl_alloc_extent(struct xdr_stream *xdr, struct pnfs_layout_hdr *lo,
+		struct layout_verification *lv, struct list_head *extents,
+		gfp_t gfp_mask)
 {
-	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
-	int i, status = -EIO;
-	uint32_t count;
-	struct pnfs_block_extent *be = NULL, *save;
-	struct xdr_stream stream;
-	struct xdr_buf buf;
-	struct page *scratch;
+	struct pnfs_block_extent *be;
+	struct nfs4_deviceid id;
+	int error;
 	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 28 + NFS4_DEVICEID4_SIZE);
+	if (!p)
+		return -EIO;
+
+	be = kzalloc(sizeof(*be), GFP_NOFS);
+	if (!be)
+		return -ENOMEM;
+
+	memcpy(&id, p, NFS4_DEVICEID4_SIZE);
+	p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+
+	error = -EIO;
+	be->be_device = nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
+						lo->plh_lc_cred, gfp_mask);
+	if (!be->be_device)
+		goto out_free_be;
+
+	/*
+	 * The next three values are read in as bytes, but stored in the
+	 * extent structure in 512-byte granularity.
+	 */
+	if (decode_sector_number(&p, &be->be_f_offset) < 0)
+		goto out_put_deviceid;
+	if (decode_sector_number(&p, &be->be_length) < 0)
+		goto out_put_deviceid;
+	if (decode_sector_number(&p, &be->be_v_offset) < 0)
+		goto out_put_deviceid;
+	be->be_state = be32_to_cpup(p++);
+
+	error = verify_extent(be, lv);
+	if (error) {
+		dprintk("%s: extent verification failed\n", __func__);
+		goto out_put_deviceid;
+	}
+
+	list_add_tail(&be->be_list, extents);
+	return 0;
+
+out_put_deviceid:
+	nfs4_put_deviceid_node(be->be_device);
+out_free_be:
+	kfree(be);
+	return error;
+}
+
+static struct pnfs_layout_segment *
+bl_alloc_lseg(struct pnfs_layout_hdr *lo, struct nfs4_layoutget_res *lgr,
+		gfp_t gfp_mask)
+{
 	struct layout_verification lv = {
 		.mode = lgr->range.iomode,
 		.start = lgr->range.offset >> SECTOR_SHIFT,
 		.inval = lgr->range.offset >> SECTOR_SHIFT,
 		.cowread = lgr->range.offset >> SECTOR_SHIFT,
 	};
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+	struct pnfs_layout_segment *lseg;
+	struct xdr_buf buf;
+	struct xdr_stream xdr;
+	struct page *scratch;
+	int status, i;
+	uint32_t count;
+	__be32 *p;
 	LIST_HEAD(extents);
 
 	dprintk("---> %s\n", __func__);
 
-	scratch = alloc_page(gfp_flags);
+	lseg = kzalloc(sizeof(*lseg), gfp_mask);
+	if (!lseg)
+		return ERR_PTR(-ENOMEM);
+
+	status = -ENOMEM;
+	scratch = alloc_page(gfp_mask);
 	if (!scratch)
-		return -ENOMEM;
+		goto out;
 
-	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages, lgr->layoutp->len);
-	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+	xdr_init_decode_pages(&xdr, &buf,
+			lgr->layoutp->pages, lgr->layoutp->len);
+	xdr_set_scratch_buffer(&xdr, page_address(scratch), PAGE_SIZE);
 
-	p = xdr_inline_decode(&stream, 4);
+	status = -EIO;
+	p = xdr_inline_decode(&xdr, 4);
 	if (unlikely(!p))
-		goto out_err;
+		goto out_free_scratch;
 
 	count = be32_to_cpup(p++);
+	dprintk("%s: number of extents %d\n", __func__, count);
 
-	dprintk("%s enter, number of extents %i\n", __func__, count);
-	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
-	if (unlikely(!p))
-		goto out_err;
-
-	/* Decode individual extents, putting them in temporary
-	 * staging area until whole layout is decoded to make error
-	 * recovery easier.
+	/*
+	 * Decode individual extents, putting them in temporary staging area
+	 * until whole layout is decoded to make error recovery easier.
 	 */
 	for (i = 0; i < count; i++) {
-		struct nfs4_deviceid id;
-
-		be = kzalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
-		if (!be) {
-			status = -ENOMEM;
-			goto out_err;
-		}
-		memcpy(&id, p, NFS4_DEVICEID4_SIZE);
-		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
-
-		be->be_device =
-			nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
-						lo->plh_lc_cred, gfp_flags);
-		if (!be->be_device)
-			goto out_err;
-
-		/* The next three values are read in as bytes,
-		 * but stored as 512-byte sector lengths
-		 */
-		if (decode_sector_number(&p, &be->be_f_offset) < 0)
-			goto out_err;
-		if (decode_sector_number(&p, &be->be_length) < 0)
-			goto out_err;
-		if (decode_sector_number(&p, &be->be_v_offset) < 0)
-			goto out_err;
-		be->be_state = be32_to_cpup(p++);
-		if (verify_extent(be, &lv)) {
-			dprintk("%s verify failed\n", __func__);
-			goto out_err;
-		}
-		list_add_tail(&be->be_list, &extents);
+		status = bl_alloc_extent(&xdr, lo, &lv, &extents, gfp_mask);
+		if (status)
+			goto process_extents;
 	}
+
 	if (lgr->range.offset + lgr->range.length !=
 			lv.start << SECTOR_SHIFT) {
 		dprintk("%s Final length mismatch\n", __func__);
-		be = NULL;
-		goto out_err;
+		status = -EIO;
+		goto process_extents;
 	}
+
 	if (lv.start < lv.cowread) {
 		dprintk("%s Final uncovered COW extent\n", __func__);
-		be = NULL;
-		goto out_err;
-	}
-	/* Extents decoded properly, now try to merge them in to
-	 * existing layout extents.
-	 */
-	list_for_each_entry_safe(be, save, &extents, be_list) {
-		list_del(&be->be_list);
-
-		status = ext_tree_insert(bl, be);
-		if (status)
-			goto out_free_list;
+		status = -EIO;
 	}
-	status = 0;
- out:
-	__free_page(scratch);
-	dprintk("%s returns %i\n", __func__, status);
-	return status;
 
- out_err:
-	nfs4_put_deviceid_node(be->be_device);
-	kfree(be);
- out_free_list:
+process_extents:
 	while (!list_empty(&extents)) {
-		be = list_first_entry(&extents, struct pnfs_block_extent,
-				      be_list);
+		struct pnfs_block_extent *be =
+			list_first_entry(&extents, struct pnfs_block_extent,
+					 be_list);
 		list_del(&be->be_list);
-		nfs4_put_deviceid_node(be->be_device);
-		kfree(be);
-	}
-	goto out;
-}
 
-/* We pretty much ignore lseg, and store all data layout wide, so we
- * can correctly merge.
- */
-static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
-						 struct nfs4_layoutget_res *lgr,
-						 gfp_t gfp_flags)
-{
-	struct pnfs_layout_segment *lseg;
-	int status;
+		if (!status)
+			status = ext_tree_insert(bl, be);
 
-	dprintk("%s enter\n", __func__);
-	lseg = kzalloc(sizeof(*lseg), gfp_flags);
-	if (!lseg)
-		return ERR_PTR(-ENOMEM);
-	status = nfs4_blk_process_layoutget(lo, lgr, gfp_flags);
+		if (status) {
+			nfs4_put_deviceid_node(be->be_device);
+			kfree(be);
+		}
+	}
+
+out_free_scratch:
+	__free_page(scratch);
+out:
+	dprintk("%s returns %d\n", __func__, status);
 	if (status) {
-		/* We don't want to call the full-blown bl_free_lseg,
-		 * since on error extents were not touched.
-		 */
 		kfree(lseg);
 		return ERR_PTR(status);
 	}
-- 
1.9.1

