Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:37640 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbaICEgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2014 00:36:43 -0400
Received: from [64.134.221.109] (helo=localhost)
	by casper.infradead.org with esmtpsa (Exim 4.80.1 #2 (Red Hat Linux))
	id 1XP2JE-0003bo-Cm
	for linux-nfs@vger.kernel.org; Wed, 03 Sep 2014 04:36:42 +0000
From: Christoph Hellwig <hch@lst.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/6] pnfs/blocklayout: in-kernel GETDEVICEINFO XDR parsing
Date: Tue,  2 Sep 2014 21:38:38 -0700
Message-Id: <1409719119-2110-6-git-send-email-hch@lst.de>
In-Reply-To: <1409719119-2110-1-git-send-email-hch@lst.de>
References: <1409719119-2110-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patches moves parsing of the GETDEVICEINFO XDR to kernel space, as well
as the management of complex devices.  The reason for that is we might have
multiple outstanding complex devices after a NOTIFY_DEVICEID4_CHANGE, which
device mapper or md can't handle as they claim devices exclusively.

But as is turns out simple striping / concatenation is fairly trivial to
implement anyway, so we make our life simpler by reducing the reliance
on blkmapd.  For now we still use blkmapd by feeding it synthetic SIMPLE
device XDR to translate device signatures to device numbers, but in the
long runs I have plans to eliminate it entirely.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/blocklayout/Makefile      |   2 +-
 fs/nfs/blocklayout/blocklayout.c |  92 ++++++----
 fs/nfs/blocklayout/blocklayout.h |  81 ++++++++-
 fs/nfs/blocklayout/dev.c         | 358 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/rpc_pipefs.c  | 141 ++++-----------
 5 files changed, 526 insertions(+), 148 deletions(-)
 create mode 100644 fs/nfs/blocklayout/dev.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index e177026..3ca14c3 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -3,4 +3,4 @@
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
 
-blocklayoutdriver-y += blocklayout.o extent_tree.o rpc_pipefs.o
+blocklayoutdriver-y += blocklayout.o dev.o extent_tree.o rpc_pipefs.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 7b3c8c9..e92591c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -114,13 +114,10 @@ bl_submit_bio(int rw, struct bio *bio)
 	return NULL;
 }
 
-static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
-				     struct pnfs_block_extent *be,
-				     void (*end_io)(struct bio *, int err),
-				     struct parallel_io *par)
+static struct bio *
+bl_alloc_init_bio(int npg, struct block_device *bdev, sector_t disk_sector,
+		void (*end_io)(struct bio *, int err), struct parallel_io *par)
 {
-	struct pnfs_block_dev *dev =
-		container_of(be->be_device, struct pnfs_block_dev, d_node);
 	struct bio *bio;
 
 	npg = min(npg, BIO_MAX_PAGES);
@@ -131,32 +128,55 @@ static struct bio *bl_alloc_init_bio(int npg, sector_t isect,
 	}
 
 	if (bio) {
-		bio->bi_iter.bi_sector = isect - be->be_f_offset +
-			be->be_v_offset;
-		bio->bi_bdev = dev->d_bdev;
+		bio->bi_iter.bi_sector = disk_sector;
+		bio->bi_bdev = bdev;
 		bio->bi_end_io = end_io;
 		bio->bi_private = par;
 	}
 	return bio;
 }
 
-static struct bio *do_add_page_to_bio(struct bio *bio, int npg, int rw,
-				      sector_t isect, struct page *page,
-				      struct pnfs_block_extent *be,
-				      void (*end_io)(struct bio *, int err),
-				      struct parallel_io *par,
-				      unsigned int offset, int len)
+static struct bio *
+do_add_page_to_bio(struct bio *bio, int npg, int rw, sector_t isect,
+		struct page *page, struct pnfs_block_dev_map *map,
+		struct pnfs_block_extent *be,
+		void (*end_io)(struct bio *, int err),
+		struct parallel_io *par, unsigned int offset, int *len)
 {
-	isect = isect + (offset >> SECTOR_SHIFT);
+	struct pnfs_block_dev *dev =
+		container_of(be->be_device, struct pnfs_block_dev, node);
+	u64 disk_addr, end;
+
 	dprintk("%s: npg %d rw %d isect %llu offset %u len %d\n", __func__,
-		npg, rw, (unsigned long long)isect, offset, len);
+		npg, rw, (unsigned long long)isect, offset, *len);
+
+	/* translate to device offset */
+	isect += be->be_v_offset;
+	isect -= be->be_f_offset;
+
+	/* translate to physical disk offset */
+	disk_addr = (u64)isect << SECTOR_SHIFT;
+	if (disk_addr < map->start || disk_addr >= map->start + map->len) {
+		if (!dev->map(dev, disk_addr, map))
+			return ERR_PTR(-EIO);
+		bio = bl_submit_bio(rw, bio);
+	}
+	disk_addr += map->disk_offset;
+	disk_addr -= map->start;
+
+	/* limit length to what the device mapping allows */
+	end = disk_addr + *len;
+	if (end >= map->start + map->len)
+		*len = map->start + map->len - disk_addr;
+
 retry:
 	if (!bio) {
-		bio = bl_alloc_init_bio(npg, isect, be, end_io, par);
+		bio = bl_alloc_init_bio(npg, map->bdev,
+				disk_addr >> SECTOR_SHIFT, end_io, par);
 		if (!bio)
 			return ERR_PTR(-ENOMEM);
 	}
-	if (bio_add_page(bio, page, len, offset) < len) {
+	if (bio_add_page(bio, page, *len, offset) < *len) {
 		bio = bl_submit_bio(rw, bio);
 		goto retry;
 	}
@@ -203,6 +223,7 @@ static enum pnfs_try_status
 bl_read_pagelist(struct nfs_pgio_header *header)
 {
 	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
+	struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
 	struct bio *bio = NULL;
 	struct pnfs_block_extent be;
 	sector_t isect, extent_length = 0;
@@ -248,28 +269,29 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 				pg_len = PAGE_CACHE_SIZE - pg_offset;
 			else
 				pg_len = bytes_left;
-
-			f_offset += pg_len;
-			bytes_left -= pg_len;
-			isect += (pg_offset >> SECTOR_SHIFT);
-			extent_length -= (pg_offset >> SECTOR_SHIFT);
 		} else {
 			BUG_ON(pg_offset != 0);
 			pg_len = PAGE_CACHE_SIZE;
 		}
 
+		isect += (pg_offset >> SECTOR_SHIFT);
+		extent_length -= (pg_offset >> SECTOR_SHIFT);
+
 		if (is_hole(&be)) {
 			bio = bl_submit_bio(READ, bio);
 			/* Fill hole w/ zeroes w/o accessing device */
 			dprintk("%s Zeroing page for hole\n", __func__);
 			zero_user_segment(pages[i], pg_offset, pg_len);
+
+			/* invalidate map */
+			map.start = NFS4_MAX_UINT64;
 		} else {
 			bio = do_add_page_to_bio(bio,
 						 header->page_array.npages - i,
 						 READ,
-						 isect, pages[i], &be,
+						 isect, pages[i], &map, &be,
 						 bl_end_io_read, par,
-						 pg_offset, pg_len);
+						 pg_offset, &pg_len);
 			if (IS_ERR(bio)) {
 				header->pnfs_error = PTR_ERR(bio);
 				bio = NULL;
@@ -278,6 +300,8 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 		}
 		isect += (pg_len >> SECTOR_SHIFT);
 		extent_length -= (pg_len >> SECTOR_SHIFT);
+		f_offset += pg_len;
+		bytes_left -= pg_len;
 	}
 	if ((isect << SECTOR_SHIFT) >= header->inode->i_size) {
 		header->res.eof = 1;
@@ -346,6 +370,7 @@ static enum pnfs_try_status
 bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 {
 	struct pnfs_block_layout *bl = BLK_LSEG2EXT(header->lseg);
+	struct pnfs_block_dev_map map = { .start = NFS4_MAX_UINT64 };
 	struct bio *bio = NULL;
 	struct pnfs_block_extent be;
 	sector_t isect, extent_length = 0;
@@ -354,6 +379,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	size_t count = header->args.count;
 	struct page **pages = header->args.pages;
 	int pg_index = pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	unsigned int pg_len;
 	struct blk_plug plug;
 	int i;
 
@@ -387,19 +413,21 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 			extent_length = be.be_length - (isect - be.be_f_offset);
 		}
 
+		pg_len = PAGE_CACHE_SIZE;
 		bio = do_add_page_to_bio(bio, header->page_array.npages - i,
-					 WRITE, isect, pages[i], &be,
+					 WRITE, isect, pages[i], &map, &be,
 					 bl_end_io_write, par,
-					 0, PAGE_CACHE_SIZE);
+					 0, &pg_len);
 		if (IS_ERR(bio)) {
 			header->pnfs_error = PTR_ERR(bio);
 			bio = NULL;
 			goto out;
 		}
-		offset += PAGE_CACHE_SIZE;
-		count -= PAGE_CACHE_SIZE;
-		isect += PAGE_CACHE_SECTORS;
-		extent_length -= PAGE_CACHE_SECTORS;
+
+		offset += pg_len;
+		count -= pg_len;
+		isect += (pg_len >> SECTOR_SHIFT);
+		extent_length -= (pg_len >> SECTOR_SHIFT);
 	}
 
 	header->res.count = header->args.count;
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index c98d98a..3077391 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -44,9 +44,75 @@
 #define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
 #define SECTOR_SIZE (1 << SECTOR_SHIFT)
 
+struct pnfs_block_dev;
+
+enum pnfs_block_volume_type {
+	PNFS_BLOCK_VOLUME_SIMPLE	= 0,
+	PNFS_BLOCK_VOLUME_SLICE		= 1,
+	PNFS_BLOCK_VOLUME_CONCAT	= 2,
+	PNFS_BLOCK_VOLUME_STRIPE	= 3,
+};
+
+#define PNFS_BLOCK_MAX_UUIDS	4
+
+/*
+ * Random upper cap for the uuid length to avoid unbounded allocation.
+ * Not actually limited by the protocol.
+ */
+#define PNFS_BLOCK_UUID_LEN	128
+
+struct pnfs_block_volume {
+	enum pnfs_block_volume_type	type;
+	union {
+		struct {
+			int		len;
+			int		nr_sigs;
+			struct {
+				u64		offset;
+				u32		sig_len;
+				u8		sig[PNFS_BLOCK_UUID_LEN];
+			} sigs[PNFS_BLOCK_MAX_UUIDS];
+		} simple;
+		struct {
+			u64		start;
+			u64		len;
+			u32		volume;
+		} slice;
+		struct {
+			u32		volumes_count;
+			u32		volumes[MAX_RAID_DEVICES];
+		} concat;
+		struct {
+			u64		chunk_size;
+			u32		volumes_count;
+			u32		volumes[MAX_RAID_DEVICES];
+		} stripe;
+	};
+};
+
+struct pnfs_block_dev_map {
+	sector_t			start;
+	sector_t			len;
+
+	sector_t			disk_offset;
+	struct block_device		*bdev;
+};
+
 struct pnfs_block_dev {
-	struct nfs4_deviceid_node	d_node;
-	struct block_device		*d_bdev;
+	struct nfs4_deviceid_node	node;
+
+	u64				start;
+	u64				len;
+
+	u32				nr_children;
+	struct pnfs_block_dev		*children;
+	u64				chunk_size;
+
+	struct block_device		*bdev;
+	u64				disk_offset;
+
+	bool (*map)(struct pnfs_block_dev *dev, u64 offset,
+			struct pnfs_block_dev_map *map);
 };
 
 enum exstate4 {
@@ -110,6 +176,11 @@ struct bl_msg_hdr {
 #define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds */
 #define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
 
+/* dev.c */
+struct nfs4_deviceid_node *bl_alloc_deviceid_node(struct nfs_server *server,
+		struct pnfs_device *pdev, gfp_t gfp_mask);
+void bl_free_deviceid_node(struct nfs4_deviceid_node *d);
+
 /* extent_tree.c */
 int ext_tree_insert(struct pnfs_block_layout *bl,
 		struct pnfs_block_extent *new);
@@ -123,10 +194,8 @@ int ext_tree_prepare_commit(struct nfs4_layoutcommit_args *arg);
 void ext_tree_mark_committed(struct nfs4_layoutcommit_args *arg, int status);
 
 /* rpc_pipefs.c */
-struct nfs4_deviceid_node *bl_alloc_deviceid_node(struct nfs_server *server,
-		struct pnfs_device *pdev, gfp_t gfp_mask);
-void bl_free_deviceid_node(struct nfs4_deviceid_node *d);
-
+dev_t bl_resolve_deviceid(struct nfs_server *server,
+		struct pnfs_block_volume *b, gfp_t gfp_mask);
 int __init bl_init_pipefs(void);
 void __exit bl_cleanup_pipefs(void);
 
diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
new file mode 100644
index 0000000..ae18f80
--- /dev/null
+++ b/fs/nfs/blocklayout/dev.c
@@ -0,0 +1,358 @@
+/*
+ * Copyright (c) 2014 Christoph Hellwig.
+ */
+#include <linux/sunrpc/svc.h>
+#include <linux/blkdev.h>
+#include <linux/nfs4.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_xdr.h>
+
+#include "blocklayout.h"
+
+static void
+bl_free_device(struct pnfs_block_dev *dev)
+{
+	if (dev->nr_children) {
+		int i;
+
+		for (i = 0; i < dev->nr_children; i++)
+			bl_free_device(&dev->children[i]);
+		kfree(dev->children);
+	} else {
+		if (dev->bdev)
+			blkdev_put(dev->bdev, FMODE_READ);
+	}
+}
+
+void
+bl_free_deviceid_node(struct nfs4_deviceid_node *d)
+{
+	struct pnfs_block_dev *dev =
+		container_of(d, struct pnfs_block_dev, node);
+
+	bl_free_device(dev);
+	kfree(dev);
+}
+
+static int
+nfs4_block_decode_volume(struct xdr_stream *xdr, struct pnfs_block_volume *b)
+{
+	__be32 *p;
+	int i;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (!p)
+		return -EIO;
+	b->type = be32_to_cpup(p++);
+
+	switch (b->type) {
+	case PNFS_BLOCK_VOLUME_SIMPLE:
+		p = xdr_inline_decode(xdr, 4);
+		if (!p)
+			return -EIO;
+		b->simple.nr_sigs = be32_to_cpup(p++);
+		if (!b->simple.nr_sigs) {
+			dprintk("no signature\n");
+			return -EIO;
+		}
+
+		b->simple.len = 4 + 4;
+		for (i = 0; i < b->simple.nr_sigs; i++) {
+			p = xdr_inline_decode(xdr, 8 + 4);
+			if (!p)
+				return -EIO;
+			p = xdr_decode_hyper(p, &b->simple.sigs[i].offset);
+			b->simple.sigs[i].sig_len = be32_to_cpup(p++);
+
+			p = xdr_inline_decode(xdr, b->simple.sigs[i].sig_len);
+			if (!p)
+				return -EIO;
+			memcpy(&b->simple.sigs[i].sig, p,
+				b->simple.sigs[i].sig_len);
+
+			b->simple.len += 8 + 4 + b->simple.sigs[i].sig_len;
+		}
+		break;
+	case PNFS_BLOCK_VOLUME_SLICE:
+		p = xdr_inline_decode(xdr, 8 + 8 + 4);
+		if (!p)
+			return -EIO;
+		p = xdr_decode_hyper(p, &b->slice.start);
+		p = xdr_decode_hyper(p, &b->slice.len);
+		b->slice.volume = be32_to_cpup(p++);
+		break;
+	case PNFS_BLOCK_VOLUME_CONCAT:
+		p = xdr_inline_decode(xdr, 4);
+		if (!p)
+			return -EIO;
+		b->concat.volumes_count = be32_to_cpup(p++);
+
+		p = xdr_inline_decode(xdr, b->concat.volumes_count * 4);
+		if (!p)
+			return -EIO;
+		for (i = 0; i < b->concat.volumes_count; i++)
+			b->concat.volumes[i] = be32_to_cpup(p++);
+		break;
+	case PNFS_BLOCK_VOLUME_STRIPE:
+		p = xdr_inline_decode(xdr, 8 + 4);
+		if (!p)
+			return -EIO;
+		p = xdr_decode_hyper(p, &b->stripe.chunk_size);
+		b->stripe.volumes_count = be32_to_cpup(p++);
+
+		p = xdr_inline_decode(xdr, b->stripe.volumes_count * 4);
+		if (!p)
+			return -EIO;
+		for (i = 0; i < b->stripe.volumes_count; i++)
+			b->stripe.volumes[i] = be32_to_cpup(p++);
+		break;
+	default:
+		dprintk("unknown volume type!\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static bool bl_map_simple(struct pnfs_block_dev *dev, u64 offset,
+		struct pnfs_block_dev_map *map)
+{
+	map->start = dev->start;
+	map->len = dev->len;
+	map->disk_offset = dev->disk_offset;
+	map->bdev = dev->bdev;
+	return true;
+}
+
+static bool bl_map_concat(struct pnfs_block_dev *dev, u64 offset,
+		struct pnfs_block_dev_map *map)
+{
+	int i;
+
+	for (i = 0; i < dev->nr_children; i++) {
+		struct pnfs_block_dev *child = &dev->children[i];
+
+		if (child->start > offset ||
+		    child->start + child->len <= offset)
+			continue;
+
+		child->map(child, offset - child->start, map);
+		return true;
+	}
+
+	dprintk("%s: ran off loop!\n", __func__);
+	return false;
+}
+
+static bool bl_map_stripe(struct pnfs_block_dev *dev, u64 offset,
+		struct pnfs_block_dev_map *map)
+{
+	struct pnfs_block_dev *child;
+	u64 chunk = (offset / dev->chunk_size);
+	int chunk_idx = chunk % dev->nr_children;
+	u64 disk_offset;
+
+	if (chunk_idx > dev->nr_children) {
+		dprintk("%s: invalid chunk idx %d (%lld/%lld)\n",
+			__func__, chunk_idx, offset, dev->chunk_size);
+		/* error, should not happen */
+		return false;
+	}
+
+	/* truncate offset to the beginning of the stripe */
+	offset = chunk * dev->chunk_size;
+
+	/* disk offset of the stripe */
+	disk_offset = offset / dev->nr_children;
+
+	child = &dev->children[chunk_idx];
+	child->map(child, disk_offset, map);
+
+	map->start += offset;
+	map->disk_offset += disk_offset;
+	map->len = dev->chunk_size;
+	return true;
+}
+
+static int
+bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask);
+
+
+static int
+bl_parse_simple(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	dev_t dev;
+
+	dev = bl_resolve_deviceid(server, v, gfp_mask);
+	if (!dev)
+		return -EIO;
+
+	d->bdev = blkdev_get_by_dev(dev, FMODE_READ, NULL);
+	if (IS_ERR(d->bdev)) {
+		printk(KERN_WARNING "pNFS: failed to open device %d:%d (%ld)\n",
+			MAJOR(dev), MINOR(dev), PTR_ERR(d->bdev));
+		return PTR_ERR(d->bdev);
+	}
+
+
+	d->len = i_size_read(d->bdev->bd_inode);
+	d->map = bl_map_simple;
+
+	printk(KERN_INFO "pNFS: using block device %s\n",
+		d->bdev->bd_disk->disk_name);
+	return 0;
+}
+
+static int
+bl_parse_slice(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	int ret;
+
+	ret = bl_parse_deviceid(server, d, volumes, v->slice.volume, gfp_mask);
+	if (ret)
+		return ret;
+
+	d->disk_offset = v->slice.start;
+	d->len = v->slice.len;
+	return 0;
+}
+
+static int
+bl_parse_concat(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	u64 len = 0;
+	int ret, i;
+
+	d->children = kcalloc(v->concat.volumes_count,
+			sizeof(struct pnfs_block_dev), GFP_KERNEL);
+	if (!d->children)
+		return -ENOMEM;
+
+	for (i = 0; i < v->concat.volumes_count; i++) {
+		ret = bl_parse_deviceid(server, &d->children[i],
+				volumes, v->concat.volumes[i], gfp_mask);
+		if (ret)
+			return ret;
+
+		d->nr_children++;
+		d->children[i].start += len;
+		len += d->children[i].len;
+	}
+
+	d->len = len;
+	d->map = bl_map_concat;
+	return 0;
+}
+
+static int
+bl_parse_stripe(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	struct pnfs_block_volume *v = &volumes[idx];
+	u64 len = 0;
+	int ret, i;
+
+	d->children = kcalloc(v->stripe.volumes_count,
+			sizeof(struct pnfs_block_dev), GFP_KERNEL);
+	if (!d->children)
+		return -ENOMEM;
+
+	for (i = 0; i < v->stripe.volumes_count; i++) {
+		ret = bl_parse_deviceid(server, &d->children[i],
+				volumes, v->stripe.volumes[i], gfp_mask);
+		if (ret)
+			return ret;
+
+		d->nr_children++;
+		len += d->children[i].len;
+	}
+
+	d->len = len;
+	d->chunk_size = v->stripe.chunk_size;
+	d->map = bl_map_stripe;
+	return 0;
+}
+
+static int
+bl_parse_deviceid(struct nfs_server *server, struct pnfs_block_dev *d,
+		struct pnfs_block_volume *volumes, int idx, gfp_t gfp_mask)
+{
+	switch (volumes[idx].type) {
+	case PNFS_BLOCK_VOLUME_SIMPLE:
+		return bl_parse_simple(server, d, volumes, idx, gfp_mask);
+	case PNFS_BLOCK_VOLUME_SLICE:
+		return bl_parse_slice(server, d, volumes, idx, gfp_mask);
+	case PNFS_BLOCK_VOLUME_CONCAT:
+		return bl_parse_concat(server, d, volumes, idx, gfp_mask);
+	case PNFS_BLOCK_VOLUME_STRIPE:
+		return bl_parse_stripe(server, d, volumes, idx, gfp_mask);
+	default:
+		dprintk("unsupported volume type: %d\n", volumes[idx].type);
+		return -EIO;
+	}
+}
+
+struct nfs4_deviceid_node *
+bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
+		gfp_t gfp_mask)
+{
+	struct nfs4_deviceid_node *node = NULL;
+	struct pnfs_block_volume *volumes;
+	struct pnfs_block_dev *top;
+	struct xdr_stream xdr;
+	struct xdr_buf buf;
+	struct page *scratch;
+	int nr_volumes, ret, i;
+	__be32 *p;
+
+	scratch = alloc_page(gfp_mask);
+	if (!scratch)
+		goto out;
+
+	xdr_init_decode_pages(&xdr, &buf, pdev->pages, pdev->pglen);
+	xdr_set_scratch_buffer(&xdr, page_address(scratch), PAGE_SIZE);
+
+	p = xdr_inline_decode(&xdr, sizeof(__be32));
+	if (!p)
+		goto out_free_scratch;
+	nr_volumes = be32_to_cpup(p++);
+
+	volumes = kcalloc(nr_volumes, sizeof(struct pnfs_block_volume),
+			  gfp_mask);
+	if (!volumes)
+		goto out_free_scratch;
+
+	for (i = 0; i < nr_volumes; i++) {
+		ret = nfs4_block_decode_volume(&xdr, &volumes[i]);
+		if (ret < 0)
+			goto out_free_volumes;
+	}
+
+	top = kzalloc(sizeof(*top), gfp_mask);
+	if (!top)
+		goto out_free_volumes;
+
+	ret = bl_parse_deviceid(server, top, volumes, nr_volumes - 1, gfp_mask);
+	if (ret) {
+		bl_free_device(top);
+		kfree(top);
+		goto out_free_volumes;
+	}
+
+	node = &top->node;
+	nfs4_init_deviceid_node(node, server, &pdev->dev_id);
+
+out_free_volumes:
+	kfree(volumes);
+out_free_scratch:
+	__free_page(scratch);
+out:
+	return node;
+}
diff --git a/fs/nfs/blocklayout/rpc_pipefs.c b/fs/nfs/blocklayout/rpc_pipefs.c
index bfb0486..8d04bda 100644
--- a/fs/nfs/blocklayout/rpc_pipefs.c
+++ b/fs/nfs/blocklayout/rpc_pipefs.c
@@ -34,94 +34,53 @@
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-static void bl_dm_remove(struct net *net, dev_t dev)
+static void
+nfs4_encode_simple(__be32 *p, struct pnfs_block_volume *b)
 {
-	struct bl_pipe_msg bl_pipe_msg;
-	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
-	struct bl_dev_msg bl_umount_request;
-	struct bl_msg_hdr bl_msg = {
-		.type = BL_DEVICE_UMOUNT,
-		.totallen = sizeof(bl_umount_request),
-	};
-	uint8_t *dataptr;
-	DECLARE_WAITQUEUE(wq, current);
-	struct nfs_net *nn = net_generic(net, nfs_net_id);
-
-	dprintk("Entering %s\n", __func__);
-
-	bl_pipe_msg.bl_wq = &nn->bl_wq;
-	memset(msg, 0, sizeof(*msg));
-	msg->len = sizeof(bl_msg) + bl_msg.totallen;
-	msg->data = kzalloc(msg->len, GFP_NOFS);
-	if (!msg->data)
-		goto out;
-
-	memset(&bl_umount_request, 0, sizeof(bl_umount_request));
-	bl_umount_request.major = MAJOR(dev);
-	bl_umount_request.minor = MINOR(dev);
-
-	memcpy(msg->data, &bl_msg, sizeof(bl_msg));
-	dataptr = (uint8_t *) msg->data;
-	memcpy(&dataptr[sizeof(bl_msg)], &bl_umount_request, sizeof(bl_umount_request));
-
-	add_wait_queue(&nn->bl_wq, &wq);
-	if (rpc_queue_upcall(nn->bl_device_pipe, msg) < 0) {
-		remove_wait_queue(&nn->bl_wq, &wq);
-		goto out;
+	int i;
+
+	*p++ = cpu_to_be32(1);
+	*p++ = cpu_to_be32(b->type);
+	*p++ = cpu_to_be32(b->simple.nr_sigs);
+	for (i = 0; i < b->simple.nr_sigs; i++) {
+		p = xdr_encode_hyper(p, b->simple.sigs[i].offset);
+		p = xdr_encode_opaque(p, b->simple.sigs[i].sig,
+					 b->simple.sigs[i].sig_len);
 	}
-
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule();
-	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&nn->bl_wq, &wq);
-
-out:
-	kfree(msg->data);
 }
 
-/*
- * Decodes pnfs_block_deviceaddr4 which is XDR encoded in dev->dev_addr_buf.
- */
-struct nfs4_deviceid_node *
-bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *dev,
+dev_t
+bl_resolve_deviceid(struct nfs_server *server, struct pnfs_block_volume *b,
 		gfp_t gfp_mask)
 {
-	struct pnfs_block_dev *rv;
-	struct block_device *bd;
-	struct bl_pipe_msg bl_pipe_msg;
-	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
-	struct bl_msg_hdr bl_msg = {
-		.type = BL_DEVICE_MOUNT,
-		.totallen = dev->mincount,
-	};
-	uint8_t *dataptr;
-	DECLARE_WAITQUEUE(wq, current);
-	int offset, len, i, rc;
 	struct net *net = server->nfs_client->cl_net;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
 	struct bl_dev_msg *reply = &nn->bl_mount_reply;
+	struct bl_pipe_msg bl_pipe_msg;
+	struct rpc_pipe_msg *msg = &bl_pipe_msg.msg;
+	struct bl_msg_hdr *bl_msg;
+	DECLARE_WAITQUEUE(wq, current);
+	dev_t dev = 0;
+	int rc;
 
 	dprintk("%s CREATING PIPEFS MESSAGE\n", __func__);
-	dprintk("%s: deviceid: %s, mincount: %d\n", __func__, dev->dev_id.data,
-		dev->mincount);
 
 	bl_pipe_msg.bl_wq = &nn->bl_wq;
+
+	b->simple.len += 4;	/* single volume */
+	if (b->simple.len > PAGE_SIZE)
+		return -EIO;
+
 	memset(msg, 0, sizeof(*msg));
-	msg->data = kzalloc(sizeof(bl_msg) + dev->mincount, gfp_mask);
+	msg->len = sizeof(*bl_msg) + b->simple.len;
+	msg->data = kzalloc(msg->len, gfp_mask);
 	if (!msg->data)
 		goto out;
 
-	memcpy(msg->data, &bl_msg, sizeof(bl_msg));
-	dataptr = (uint8_t *) msg->data;
-	len = dev->mincount;
-	offset = sizeof(bl_msg);
-	for (i = 0; len > 0; i++) {
-		memcpy(&dataptr[offset], page_address(dev->pages[i]),
-				len < PAGE_CACHE_SIZE ? len : PAGE_CACHE_SIZE);
-		len -= PAGE_CACHE_SIZE;
-		offset += PAGE_CACHE_SIZE;
-	}
-	msg->len = sizeof(bl_msg) + dev->mincount;
+	bl_msg = msg->data;
+	bl_msg->type = BL_DEVICE_MOUNT,
+	bl_msg->totallen = b->simple.len;
+	nfs4_encode_simple(msg->data + sizeof(*bl_msg), b);
 
 	dprintk("%s CALLING USERSPACE DAEMON\n", __func__);
 	add_wait_queue(&nn->bl_wq, &wq);
@@ -142,46 +101,10 @@ bl_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *dev,
 		goto out;
 	}
 
-	bd = blkdev_get_by_dev(MKDEV(reply->major, reply->minor),
-			       FMODE_READ, NULL);
-	if (IS_ERR(bd)) {
-		printk(KERN_WARNING "%s failed to open device %d:%d (%ld)\n",
-			__func__, reply->major, reply->minor,
-			PTR_ERR(bd));
-		goto out;
-	}
-
-	rv = kzalloc(sizeof(*rv), gfp_mask);
-	if (!rv)
-		goto out;
-
-	nfs4_init_deviceid_node(&rv->d_node, server, &dev->dev_id);
-	rv->d_bdev = bd;
-
-	dprintk("%s Created device %s with bd_block_size %u\n",
-		__func__,
-		bd->bd_disk->disk_name,
-		bd->bd_block_size);
-
-	kfree(msg->data);
-	return &rv->d_node;
-
+	dev = MKDEV(reply->major, reply->minor);
 out:
 	kfree(msg->data);
-	return NULL;
-}
-
-void
-bl_free_deviceid_node(struct nfs4_deviceid_node *d)
-{
-	struct pnfs_block_dev *dev =
-		container_of(d, struct pnfs_block_dev, d_node);
-	struct net *net = d->nfs_client->cl_net;
-
-	blkdev_put(dev->d_bdev, FMODE_READ);
-	bl_dm_remove(net, dev->d_bdev->bd_dev);
-
-	kfree(dev);
+	return dev;
 }
 
 static ssize_t bl_pipe_downcall(struct file *filp, const char __user *src,
-- 
1.9.1

