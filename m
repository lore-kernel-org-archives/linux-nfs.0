Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:53139 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbaIKAfM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 20:35:12 -0400
Received: from ip-64-134-224-54.public.wayport.net ([64.134.224.54] helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XRsLv-00083w-3W
	for linux-nfs@vger.kernel.org; Thu, 11 Sep 2014 00:35:11 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] pnfs/blocklayout: move extent processing to blocklayout.c
Date: Wed, 10 Sep 2014 17:37:24 -0700
Message-Id: <1410395848-2437-2-git-send-email-hch@lst.de>
In-Reply-To: <1410395848-2437-1-git-send-email-hch@lst.de>
References: <1410395848-2437-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This isn't device(id) related, so move it into the main file.  Simple move
for now, the next commit will clean it up a bit.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/blocklayout.c    | 186 ++++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayout.h    |   2 -
 fs/nfs/blocklayout/blocklayoutdev.c | 186 ------------------------------------
 3 files changed, 186 insertions(+), 188 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index cf10a6e..61a858c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -446,6 +446,192 @@ static void bl_free_lseg(struct pnfs_layout_segment *lseg)
 	kfree(lseg);
 }
 
+/* Tracks info needed to ensure extents in layout obey constraints of spec */
+struct layout_verification {
+	u32 mode;	/* R or RW */
+	u64 start;	/* Expected start of next non-COW extent */
+	u64 inval;	/* Start of INVAL coverage */
+	u64 cowread;	/* End of COW read coverage */
+};
+
+/* Verify the extent meets the layout requirements of the pnfs-block draft,
+ * section 2.3.1.
+ */
+static int verify_extent(struct pnfs_block_extent *be,
+			 struct layout_verification *lv)
+{
+	if (lv->mode == IOMODE_READ) {
+		if (be->be_state == PNFS_BLOCK_READWRITE_DATA ||
+		    be->be_state == PNFS_BLOCK_INVALID_DATA)
+			return -EIO;
+		if (be->be_f_offset != lv->start)
+			return -EIO;
+		lv->start += be->be_length;
+		return 0;
+	}
+	/* lv->mode == IOMODE_RW */
+	if (be->be_state == PNFS_BLOCK_READWRITE_DATA) {
+		if (be->be_f_offset != lv->start)
+			return -EIO;
+		if (lv->cowread > lv->start)
+			return -EIO;
+		lv->start += be->be_length;
+		lv->inval = lv->start;
+		return 0;
+	} else if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
+		if (be->be_f_offset != lv->start)
+			return -EIO;
+		lv->start += be->be_length;
+		return 0;
+	} else if (be->be_state == PNFS_BLOCK_READ_DATA) {
+		if (be->be_f_offset > lv->start)
+			return -EIO;
+		if (be->be_f_offset < lv->inval)
+			return -EIO;
+		if (be->be_f_offset < lv->cowread)
+			return -EIO;
+		/* It looks like you might want to min this with lv->start,
+		 * but you really don't.
+		 */
+		lv->inval = lv->inval + be->be_length;
+		lv->cowread = be->be_f_offset + be->be_length;
+		return 0;
+	} else
+		return -EIO;
+}
+
+static int decode_sector_number(__be32 **rp, sector_t *sp)
+{
+	uint64_t s;
+
+	*rp = xdr_decode_hyper(*rp, &s);
+	if (s & 0x1ff) {
+		printk(KERN_WARNING "NFS: %s: sector not aligned\n", __func__);
+		return -1;
+	}
+	*sp = s >> SECTOR_SHIFT;
+	return 0;
+}
+
+/* XDR decode pnfs_block_layout4 structure */
+static int
+nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
+{
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+	int i, status = -EIO;
+	uint32_t count;
+	struct pnfs_block_extent *be = NULL, *save;
+	struct xdr_stream stream;
+	struct xdr_buf buf;
+	struct page *scratch;
+	__be32 *p;
+	struct layout_verification lv = {
+		.mode = lgr->range.iomode,
+		.start = lgr->range.offset >> SECTOR_SHIFT,
+		.inval = lgr->range.offset >> SECTOR_SHIFT,
+		.cowread = lgr->range.offset >> SECTOR_SHIFT,
+	};
+	LIST_HEAD(extents);
+
+	dprintk("---> %s\n", __func__);
+
+	scratch = alloc_page(gfp_flags);
+	if (!scratch)
+		return -ENOMEM;
+
+	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages, lgr->layoutp->len);
+	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
+
+	p = xdr_inline_decode(&stream, 4);
+	if (unlikely(!p))
+		goto out_err;
+
+	count = be32_to_cpup(p++);
+
+	dprintk("%s enter, number of extents %i\n", __func__, count);
+	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
+	if (unlikely(!p))
+		goto out_err;
+
+	/* Decode individual extents, putting them in temporary
+	 * staging area until whole layout is decoded to make error
+	 * recovery easier.
+	 */
+	for (i = 0; i < count; i++) {
+		struct nfs4_deviceid id;
+
+		be = kzalloc(sizeof(struct pnfs_block_extent), GFP_NOFS);
+		if (!be) {
+			status = -ENOMEM;
+			goto out_err;
+		}
+		memcpy(&id, p, NFS4_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+
+		be->be_device =
+			nfs4_find_get_deviceid(NFS_SERVER(lo->plh_inode), &id,
+						lo->plh_lc_cred, gfp_flags);
+		if (!be->be_device)
+			goto out_err;
+
+		/* The next three values are read in as bytes,
+		 * but stored as 512-byte sector lengths
+		 */
+		if (decode_sector_number(&p, &be->be_f_offset) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_length) < 0)
+			goto out_err;
+		if (decode_sector_number(&p, &be->be_v_offset) < 0)
+			goto out_err;
+		be->be_state = be32_to_cpup(p++);
+		if (verify_extent(be, &lv)) {
+			dprintk("%s verify failed\n", __func__);
+			goto out_err;
+		}
+		list_add_tail(&be->be_list, &extents);
+	}
+	if (lgr->range.offset + lgr->range.length !=
+			lv.start << SECTOR_SHIFT) {
+		dprintk("%s Final length mismatch\n", __func__);
+		be = NULL;
+		goto out_err;
+	}
+	if (lv.start < lv.cowread) {
+		dprintk("%s Final uncovered COW extent\n", __func__);
+		be = NULL;
+		goto out_err;
+	}
+	/* Extents decoded properly, now try to merge them in to
+	 * existing layout extents.
+	 */
+	list_for_each_entry_safe(be, save, &extents, be_list) {
+		list_del(&be->be_list);
+
+		status = ext_tree_insert(bl, be);
+		if (status)
+			goto out_free_list;
+	}
+	status = 0;
+ out:
+	__free_page(scratch);
+	dprintk("%s returns %i\n", __func__, status);
+	return status;
+
+ out_err:
+	nfs4_put_deviceid_node(be->be_device);
+	kfree(be);
+ out_free_list:
+	while (!list_empty(&extents)) {
+		be = list_first_entry(&extents, struct pnfs_block_extent,
+				      be_list);
+		list_del(&be->be_list);
+		nfs4_put_deviceid_node(be->be_device);
+		kfree(be);
+	}
+	goto out;
+}
+
 /* We pretty much ignore lseg, and store all data layout wide, so we
  * can correctly merge.
  */
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 9757f3e..00c11eb 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -113,8 +113,6 @@ struct bl_msg_hdr {
 /* blocklayoutdev.c */
 ssize_t bl_pipe_downcall(struct file *, const char __user *, size_t);
 void bl_pipe_destroy_msg(struct rpc_pipe_msg *);
-int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
-				struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 
 struct nfs4_deviceid_node *bl_alloc_deviceid_node(struct nfs_server *server,
 		struct pnfs_device *pdev, gfp_t gfp_mask);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index d6527d2..2b54e29 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -40,19 +40,6 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-static int decode_sector_number(__be32 **rp, sector_t *sp)
-{
-	uint64_t s;
-
-	*rp = xdr_decode_hyper(*rp, &s);
-	if (s & 0x1ff) {
-		printk(KERN_WARNING "NFS: %s: sector not aligned\n", __func__);
-		return -1;
-	}
-	*sp = s >> SECTOR_SHIFT;
-	return 0;
-}
-
 ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
 			 size_t mlen)
 {
@@ -183,176 +170,3 @@ bl_free_deviceid_node(struct nfs4_deviceid_node *d)
 
 	kfree(dev);
 }
-
-/* Tracks info needed to ensure extents in layout obey constraints of spec */
-struct layout_verification {
-	u32 mode;	/* R or RW */
-	u64 start;	/* Expected start of next non-COW extent */
-	u64 inval;	/* Start of INVAL coverage */
-	u64 cowread;	/* End of COW read coverage */
-};
-
-/* Verify the extent meets the layout requirements of the pnfs-block draft,
- * section 2.3.1.
- */
-static int verify_extent(struct pnfs_block_extent *be,
-			 struct layout_verification *lv)
-{
-	if (lv->mode == IOMODE_READ) {
-		if (be->be_state == PNFS_BLOCK_READWRITE_DATA ||
-		    be->be_state == PNFS_BLOCK_INVALID_DATA)
-			return -EIO;
-		if (be->be_f_offset != lv->start)
-			return -EIO;
-		lv->start += be->be_length;
-		return 0;
-	}
-	/* lv->mode == IOMODE_RW */
-	if (be->be_state == PNFS_BLOCK_READWRITE_DATA) {
-		if (be->be_f_offset != lv->start)
-			return -EIO;
-		if (lv->cowread > lv->start)
-			return -EIO;
-		lv->start += be->be_length;
-		lv->inval = lv->start;
-		return 0;
-	} else if (be->be_state == PNFS_BLOCK_INVALID_DATA) {
-		if (be->be_f_offset != lv->start)
-			return -EIO;
-		lv->start += be->be_length;
-		return 0;
-	} else if (be->be_state == PNFS_BLOCK_READ_DATA) {
-		if (be->be_f_offset > lv->start)
-			return -EIO;
-		if (be->be_f_offset < lv->inval)
-			return -EIO;
-		if (be->be_f_offset < lv->cowread)
-			return -EIO;
-		/* It looks like you might want to min this with lv->start,
-		 * but you really don't.
-		 */
-		lv->inval = lv->inval + be->be_length;
-		lv->cowread = be->be_f_offset + be->be_length;
-		return 0;
-	} else
-		return -EIO;
-}
-
-/* XDR decode pnfs_block_layout4 structure */
-int
-nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
-			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
-{
-	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
-	int i, status = -EIO;
-	uint32_t count;
-	struct pnfs_block_extent *be = NULL, *save;
-	struct xdr_stream stream;
-	struct xdr_buf buf;
-	struct page *scratch;
-	__be32 *p;
-	struct layout_verification lv = {
-		.mode = lgr->range.iomode,
-		.start = lgr->range.offset >> SECTOR_SHIFT,
-		.inval = lgr->range.offset >> SECTOR_SHIFT,
-		.cowread = lgr->range.offset >> SECTOR_SHIFT,
-	};
-	LIST_HEAD(extents);
-
-	dprintk("---> %s\n", __func__);
-
-	scratch = alloc_page(gfp_flags);
-	if (!scratch)
-		return -ENOMEM;
-
-	xdr_init_decode_pages(&stream, &buf, lgr->layoutp->pages, lgr->layoutp->len);
-	xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
-
-	p = xdr_inline_decode(&stream, 4);
-	if (unlikely(!p))
-		goto out_err;
-
-	count = be32_to_cpup(p++);
-
-	dprintk("%s enter, number of extents %i\n", __func__, count);
-	p = xdr_inline_decode(&stream, (28 + NFS4_DEVICEID4_SIZE) * count);
-	if (unlikely(!p))
-		goto out_err;
-
-	/* Decode individual extents, putting them in temporary
-	 * staging area until whole layout is decoded to make error
-	 * recovery easier.
-	 */
-	for (i = 0; i < count; i++) {
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
-	}
-	if (lgr->range.offset + lgr->range.length !=
-			lv.start << SECTOR_SHIFT) {
-		dprintk("%s Final length mismatch\n", __func__);
-		be = NULL;
-		goto out_err;
-	}
-	if (lv.start < lv.cowread) {
-		dprintk("%s Final uncovered COW extent\n", __func__);
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
-	}
-	status = 0;
- out:
-	__free_page(scratch);
-	dprintk("%s returns %i\n", __func__, status);
-	return status;
-
- out_err:
-	nfs4_put_deviceid_node(be->be_device);
-	kfree(be);
- out_free_list:
-	while (!list_empty(&extents)) {
-		be = list_first_entry(&extents, struct pnfs_block_extent,
-				      be_list);
-		list_del(&be->be_list);
-		nfs4_put_deviceid_node(be->be_device);
-		kfree(be);
-	}
-	goto out;
-}
-- 
1.9.1

