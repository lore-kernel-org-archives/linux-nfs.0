Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60762 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754543Ab1FLXoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:37 -0400
Message-Id: <1e279c67ea9fcb5471bc3b8afd49dbe71872ea60.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:34 -0400
Subject: [PATCH 19/34] pnfsblock: xdr decode pnfs_block_layout4
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

XDR decodes the block layout payload sent in LAYOUTGET result, storing
the result in an extent list.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |  191 ++++++++++++++++++++++++++++++++++-
 1 files changed, 189 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 0fedf50..a90eb6b 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -150,10 +150,197 @@ out_err:
 	return NULL;
 }
 
+/* Map deviceid returned by the server to constructed block_device */
+static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
+					    struct nfs4_deviceid *id)
+{
+	struct block_device *rv = NULL;
+	struct block_mount_id *mid;
+	struct pnfs_block_dev *dev;
+
+	dprintk("%s enter, lo=%p, id=%p\n", __func__, lo, id);
+	mid = BLK_ID(lo);
+	spin_lock(&mid->bm_lock);
+	list_for_each_entry(dev, &mid->bm_devlist, bm_node) {
+		if (memcmp(id->data, dev->bm_mdevid.data,
+			   NFS4_DEVICEID4_SIZE) == 0) {
+			rv = dev->bm_mdev;
+			goto out;
+		}
+	}
+ out:
+	spin_unlock(&mid->bm_lock);
+	dprintk("%s returning %p\n", __func__, rv);
+	return rv;
+}
+
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
+/* XDR decode pnfs_block_layout4 structure */
 int
 nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
 {
-	/* STUB */
-	return -EIO;
+	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
+	int i, status = -EIO;
+	uint32_t count;
+	struct pnfs_block_extent *be = NULL, *save;
+	struct xdr_stream stream;
+	struct xdr_buf buf;
+	struct page *scratch;
+	__be32 *p;
+	uint64_t tmp; /* Used by READSECTOR */
+	struct layout_verification lv = {
+		.mode = lgr->range.iomode,
+		.start = lgr->range.offset >> 9,
+		.inval = lgr->range.offset >> 9,
+		.cowread = lgr->range.offset >> 9,
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
+	READ32(count);
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
+		be = alloc_extent();
+		if (!be) {
+			status = -ENOMEM;
+			goto out_err;
+		}
+		READ_DEVID(&be->be_devid);
+		be->be_mdev = translate_devid(lo, &be->be_devid);
+		if (!be->be_mdev)
+			goto out_err;
+
+		/* The next three values are read in as bytes,
+		 * but stored as 512-byte sector lengths
+		 */
+		READ_SECTOR(be->be_f_offset);
+		READ_SECTOR(be->be_length);
+		READ_SECTOR(be->be_v_offset);
+		READ32(be->be_state);
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
+			be->be_inval = &bl->bl_inval;
+		if (verify_extent(be, &lv)) {
+			dprintk("%s verify failed\n", __func__);
+			goto out_err;
+		}
+		list_add_tail(&be->be_node, &extents);
+	}
+	if (lgr->range.offset + lgr->range.length != lv.start << 9) {
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
+	spin_lock(&bl->bl_ext_lock);
+	list_for_each_entry_safe(be, save, &extents, be_node) {
+		list_del(&be->be_node);
+		status = add_and_merge_extent(bl, be);
+		if (status) {
+			spin_unlock(&bl->bl_ext_lock);
+			/* This is a fairly catastrophic error, as the
+			 * entire layout extent lists are now corrupted.
+			 * We should have some way to distinguish this.
+			 */
+			be = NULL;
+			goto out_err;
+		}
+	}
+	spin_unlock(&bl->bl_ext_lock);
+	status = 0;
+ out:
+	__free_page(scratch);
+	dprintk("%s returns %i\n", __func__, status);
+	return status;
+
+ out_err:
+	put_extent(be);
+	while (!list_empty(&extents)) {
+		be = list_first_entry(&extents, struct pnfs_block_extent,
+				      be_node);
+		list_del(&be->be_node);
+		put_extent(be);
+	}
+	goto out;
 }
-- 
1.7.4.1

