Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53437 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab1FGR2i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:38 -0400
Date: Tue, 7 Jun 2011 13:28:36 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 22/88] pnfsblock: xdr decode pnfs_block_layout4
Message-ID: <498fac41cf7e347d658ce3e2fd86fc751ef16c43.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

XDR decodes the block layout payload sent in LAYOUTGET result, storing
the result in an extent list.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h    |    2 +
 fs/nfs/blocklayout/blocklayoutdev.c |  165 ++++++++++++++++++++++++++++++++++-
 fs/nfs/blocklayout/extents.c        |   12 +++
 3 files changed, 177 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index bcf85be..f91939d 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -142,6 +142,7 @@ struct pnfs_block_layout {
 	sector_t		bl_blocksize;  /* Server blocksize in sectors */
 };
 
+#define BLK_ID(lo)     ((struct block_mount_id *)(PNFS_MOUNTID(lo)->mountid))
 #define BLK_LSEG2EXT(lseg) ((struct pnfs_block_layout *)lseg->layout->ld_data)
 #define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
 
@@ -195,4 +196,5 @@ int nfs4_blk_flatten(struct pnfs_blk_volume *, int, struct pnfs_block_dev *);
 void free_block_dev(struct pnfs_block_dev *bdev);
 /* extents.c */
 void put_extent(struct pnfs_block_extent *be);
+struct pnfs_block_extent *alloc_extent(void);
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 818cc1c..77190fd 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -554,11 +554,172 @@ nfs4_blk_decode_device(struct super_block *sb,
 	return rv;
 }
 
+/* Map deviceid returned by the server to constructed block_device */
+static struct block_device *translate_devid(struct pnfs_layout_type *lo,
+					    struct pnfs_deviceid *id)
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
+			   NFS4_PNFS_DEVICEID4_SIZE) == 0) {
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
 /* XDR decode pnfs_block_layout4 structure */
 int
 nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 			   struct nfs4_pnfs_layoutget_res *lgr)
 {
-	/* STUB */
-	return -EIO;
+	struct pnfs_block_layout *bl = PNFS_LD_DATA(lo);
+	uint32_t *p = (uint32_t *)lgr->layout.buf;
+	uint32_t *end = (uint32_t *)((char *)lgr->layout.buf + lgr->layout.len);
+	int i, status = -EIO;
+	uint32_t count;
+	struct pnfs_block_extent *be = NULL;
+	uint64_t tmp; /* Used by READSECTOR */
+	struct layout_verification lv = {
+		.mode = lgr->lseg.iomode,
+		.start = lgr->lseg.offset >> 9,
+		.inval = lgr->lseg.offset >> 9,
+		.cowread = lgr->lseg.offset >> 9,
+	};
+
+	LIST_HEAD(extents);
+
+	BLK_READBUF(p, end, 4);
+	READ32(count);
+
+	dprintk("%s enter, number of extents %i\n", __func__, count);
+	BLK_READBUF(p, end, (28 + NFS4_PNFS_DEVICEID4_SIZE) * count);
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
+	if (p != end) {
+		dprintk("%s Undecoded cruft at end of opaque\n", __func__);
+		be = NULL;
+		goto out_err;
+	}
+	if (lgr->lseg.offset + lgr->lseg.length != lv.start << 9) {
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
+	/* STUB - instead we just throw them away */
+	status = 0;
+	goto out_err;
+ out:
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
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index efdcc08..a952d39 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -53,3 +53,15 @@ put_extent(struct pnfs_block_extent *be)
 	}
 }
 
+struct pnfs_block_extent *alloc_extent(void)
+{
+	struct pnfs_block_extent *be;
+
+	be = kmalloc(sizeof(struct pnfs_block_extent), GFP_KERNEL);
+	if (!be)
+		return NULL;
+	INIT_LIST_HEAD(&be->be_node);
+	kref_init(&be->be_refcnt);
+	be->be_inval = NULL;
+	return be;
+}
-- 
1.7.4.1

