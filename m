From: Jim Rees <rees@umich.edu>
Subject: [PATCH v6 17/26] pnfsblock: xdr decode pnfs_block_layout4
Date: Sat, 30 Jul 2011 13:08:40 -0400
Message-ID: <1312045729-27554-18-git-send-email-rees@umich.edu>
References: <1312045729-27554-1-git-send-email-rees@umich.edu>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:49615 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506Ab1G3RJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 13:09:20 -0400
In-Reply-To: <1312045729-27554-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

XDR decodes the block layout payload sent in LAYOUTGET result, storing
the result in an extent list.

[pnfsblock: get rid of deprecated xdr macros]
Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
Signed-off-by: Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/blocklayout/blocklayoutdev.c |  208 ++++++++++++++++++++++++++++++++++-
 1 files changed, 206 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index b23fe60..a83b393 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -40,6 +40,19 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
+static int decode_sector_number(__be32 **rp, sector_t *sp)
+{
+	uint64_t s;
+
+	*rp = xdr_decode_hyper(*rp, &s);
+	if (s & 0x1ff) {
+		printk(KERN_WARNING "%s: sector not aligned\n", __func__);
+		return -1;
+	}
+	*sp = s >> SECTOR_SHIFT;
+	return 0;
+}
+
 /* Open a block_device by device number. */
 struct block_device *nfs4_blkdev_get(dev_t dev)
 {
@@ -197,10 +210,201 @@ out:
 	return rv;
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
+		be = bl_alloc_extent();
+		if (!be) {
+			status = -ENOMEM;
+			goto out_err;
+		}
+		memcpy(&be->be_devid, p, NFS4_DEVICEID4_SIZE);
+		p += XDR_QUADLEN(NFS4_DEVICEID4_SIZE);
+		be->be_mdev = translate_devid(lo, &be->be_devid);
+		if (!be->be_mdev)
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
+		if (be->be_state == PNFS_BLOCK_INVALID_DATA)
+			be->be_inval = &bl->bl_inval;
+		if (verify_extent(be, &lv)) {
+			dprintk("%s verify failed\n", __func__);
+			goto out_err;
+		}
+		list_add_tail(&be->be_node, &extents);
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
+	spin_lock(&bl->bl_ext_lock);
+	list_for_each_entry_safe(be, save, &extents, be_node) {
+		list_del(&be->be_node);
+		status = bl_add_merge_extent(bl, be);
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
+	bl_put_extent(be);
+	while (!list_empty(&extents)) {
+		be = list_first_entry(&extents, struct pnfs_block_extent,
+				      be_node);
+		list_del(&be->be_node);
+		bl_put_extent(be);
+	}
+	goto out;
 }
-- 
1.7.4.1

