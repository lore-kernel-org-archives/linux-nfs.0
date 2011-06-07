Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53060 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753797Ab1FGR1d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:33 -0400
Date: Tue, 7 Jun 2011 13:27:28 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 14/88] pnfsblock: call and parse getdevicelist
Message-ID: <43efe43d446261a498acbb571f459ce25b171edf.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Call GETDEVICELIST during mount, then call and parse GETDEVICEINFO
for each device returned.

[pnfsblock: fix pnfs_deviceid references]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix print format warnings for sector_t and size_t]
[pnfs-block: #include <linux/vmalloc.h>]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsblock: fix bug determining size of striped volume]
[pnfsblock: fix oops when using multiple devices]
Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/Makefile         |    2 +-
 fs/nfs/blocklayout/blocklayout.c    |  163 +++++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h    |   89 ++++++++++
 fs/nfs/blocklayout/blocklayoutdev.c |  324 +++++++++++++++++++++++++++++++++++
 fs/nfs/blocklayout/blocklayoutdm.c  |   72 ++++++++
 5 files changed, 646 insertions(+), 4 deletions(-)
 create mode 100644 fs/nfs/blocklayout/blocklayoutdm.c

diff --git a/fs/nfs/blocklayout/Makefile b/fs/nfs/blocklayout/Makefile
index 36d959f..2c4c062 100644
--- a/fs/nfs/blocklayout/Makefile
+++ b/fs/nfs/blocklayout/Makefile
@@ -2,4 +2,4 @@
 # Makefile for the pNFS block layout driver kernel module
 #
 obj-$(CONFIG_PNFS_BLOCK) += blocklayoutdriver.o
-blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o
+blocklayoutdriver-objs := blocklayout.o blocklayoutdev.o blocklayoutdm.o
diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9889f27..ebaa48a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 
+#include <linux/vmalloc.h>
 #include "blocklayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
@@ -133,26 +134,182 @@ bl_cleanup_layoutcommit(struct pnfs_layout_type *lo,
 	dprintk("%s enter\n", __func__);
 }
 
+static void free_blk_mountid(struct block_mount_id *mid)
+{
+	if (mid) {
+		struct pnfs_block_dev *dev;
+		spin_lock(&mid->bm_lock);
+		while (!list_empty(&mid->bm_devlist)) {
+			dev = list_first_entry(&mid->bm_devlist,
+					       struct pnfs_block_dev,
+					       bm_node);
+			list_del(&dev->bm_node);
+			free_block_dev(dev);
+		}
+		spin_unlock(&mid->bm_lock);
+		kfree(mid);
+	}
+}
+
+/* This is mostly copied form the filelayout's get_device_info function.
+ * It seems much of this should be at the generic pnfs level.
+ */
+static struct pnfs_block_dev *
+nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
+			struct pnfs_deviceid *d_id,
+			struct list_head *sdlist)
+{
+	struct pnfs_device *dev;
+	struct pnfs_block_dev *rv = NULL;
+	int maxpages = NFS4_GETDEVINFO_MAXSIZE >> PAGE_SHIFT;
+	struct page *pages[maxpages];
+	int alloced_pages = 0, used_pages = 1;
+	int j, rc;
+
+	dprintk("%s enter\n", __func__);
+	dev = kmalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev) {
+		dprintk("%s kmalloc failed\n", __func__);
+		return NULL;
+	}
+ retry_once:
+	dprintk("%s trying used_pages %d\n", __func__, used_pages);
+	for (; alloced_pages < used_pages; alloced_pages++) {
+		pages[alloced_pages] = alloc_page(GFP_KERNEL);
+		if (!pages[alloced_pages])
+			goto out_free;
+	}
+	/* set dev->area */
+	if (used_pages == 1)
+		dev->area = page_address(pages[0]);
+	else {
+		dev->area = vmap(pages, used_pages, VM_MAP, PAGE_KERNEL);
+		if (!dev->area)
+			goto out_free;
+	}
+
+	memcpy(&dev->dev_id, d_id, sizeof(*d_id));
+	dev->layout_type = LAYOUT_BLOCK_VOLUME;
+	dev->dev_notify_types = 0;
+	dev->pages = pages;
+	dev->pgbase = 0;
+	dev->pglen = PAGE_SIZE * used_pages;
+	dev->mincount = 0;
+
+	rc = pnfs_callback_ops->nfs_getdeviceinfo(sb, dev);
+	dprintk("%s getdevice info returns %d used_pages %d\n", __func__, rc,
+		used_pages);
+	if (rc == -ETOOSMALL && used_pages == 1) {
+		dev->area = NULL;
+		used_pages = (dev->mincount + PAGE_SIZE - 1) >> PAGE_SHIFT;
+		if (used_pages > 1 && used_pages <= maxpages)
+			goto retry_once;
+	}
+	if (rc)
+		goto out_free;
+
+	rv = nfs4_blk_decode_device(sb, dev, sdlist);
+ out_free:
+	if (used_pages > 1 && dev->area != NULL)
+		vunmap(dev->area);
+	for (j = 0; j < alloced_pages; j++)
+		__free_page(pages[j]);
+	kfree(dev);
+	return rv;
+}
+
+
 /*
- * This is just a STUB to check the scsi scanning code
+ * Retrieve the list of available devices for the mountpoint.
  */
 static struct pnfs_mount_type *
 bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 {
+	struct block_mount_id *b_mt_id = NULL;
+	struct pnfs_mount_type *mtype = NULL;
+	struct pnfs_devicelist *dlist = NULL;
+	struct pnfs_block_dev *bdev;
 	LIST_HEAD(scsi_disklist);
+	int status, i;
 
 	dprintk("%s enter\n", __func__);
 
-	nfs4_blk_create_scsi_disk_list(&scsi_disklist);
+	if (NFS_SB(sb)->pnfs_blksize == 0) {
+		dprintk("%s Server did not return blksize\n", __func__);
+		return NULL;
+	}
+	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_KERNEL);
+	if (!b_mt_id)
+		goto out_error;
+	/* Initialize nfs4 block layout mount id */
+	b_mt_id->bm_sb = sb; /* back pointer to retrieve nfs_server struct */
+	spin_lock_init(&b_mt_id->bm_lock);
+	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
+	mtype = kzalloc(sizeof(struct pnfs_mount_type), GFP_KERNEL);
+	if (!mtype)
+		goto out_error;
+	mtype->mountid = (void *)b_mt_id;
+
+	/* Construct a list of all visible scsi disks that have not been
+	 * claimed.
+	 */
+	status =  nfs4_blk_create_scsi_disk_list(&scsi_disklist);
+	if (status < 0)
+		goto out_error;
+
+	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_KERNEL);
+	if (!dlist)
+		goto out_error;
+	dlist->eof = 0;
+	while (!dlist->eof) {
+		status = pnfs_callback_ops->nfs_getdevicelist(sb, fh, dlist);
+		if (status)
+			goto out_error;
+		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
+			__func__, dlist->num_devs, dlist->eof);
+		/* For each device returned in dlist, call GETDEVICEINFO, and
+		 * decode the opaque topology encoding to create a flat
+		 * volume topology, matching VOLUME_SIMPLE disk signatures
+		 * to disks in the visible scsi disk list.
+		 * Construct an LVM meta device from the flat volume topology.
+		 */
+		for (i = 0; i < dlist->num_devs; i++) {
+			bdev = nfs4_blk_get_deviceinfo(sb, fh,
+						     &dlist->dev_id[i],
+						     &scsi_disklist);
+			if (!bdev)
+				goto out_error;
+			spin_lock(&b_mt_id->bm_lock);
+			list_add(&bdev->bm_node, &b_mt_id->bm_devlist);
+			spin_unlock(&b_mt_id->bm_lock);
+		}
+	}
+	dprintk("%s SUCCESS\n", __func__);
+
+ out_return:
+	kfree(dlist);
 	nfs4_blk_destroy_disk_list(&scsi_disklist);
+	return mtype;
 
-	return NULL;
+ out_error:
+	free_blk_mountid(b_mt_id);
+	kfree(mtype);
+	mtype = NULL;
+	goto out_return;
 }
 
 static int
 bl_uninitialize_mountpoint(struct pnfs_mount_type *mtype)
 {
+	struct block_mount_id *b_mt_id = NULL;
+
 	dprintk("%s enter\n", __func__);
+	if (!mtype)
+		return 0;
+	b_mt_id = (struct block_mount_id *)mtype->mountid;
+	free_blk_mountid(b_mt_id);
+	kfree(mtype);
+	dprintk("%s RETURNS\n", __func__);
 	return 0;
 }
 
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 5dbb8f2..4af6685 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -38,6 +38,19 @@
 
 extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
 
+struct block_mount_id {
+	struct super_block		*bm_sb;     /* back pointer */
+	spinlock_t			bm_lock;    /* protects list */
+	struct list_head		bm_devlist; /* holds pnfs_block_dev */
+};
+
+struct pnfs_block_dev {
+	struct list_head		bm_node;
+	char				*bm_mdevname; /* meta device name */
+	struct pnfs_deviceid		bm_mdevid;    /* associated devid */
+	struct block_device		*bm_mdev;     /* meta device itself */
+};
+
 /* holds visible disks that can be matched against VOLUME_SIMPLE signatures */
 struct visible_block_device {
 	struct list_head	vi_node;
@@ -46,8 +59,84 @@ struct visible_block_device {
 	int			vi_put_done;
 };
 
+enum blk_vol_type {
+	PNFS_BLOCK_VOLUME_SIMPLE   = 0,	/* maps to a single LU */
+	PNFS_BLOCK_VOLUME_SLICE    = 1,	/* slice of another volume */
+	PNFS_BLOCK_VOLUME_CONCAT   = 2,	/* concatenation of multiple volumes */
+	PNFS_BLOCK_VOLUME_STRIPE   = 3	/* striped across multiple volumes */
+};
+
+/* All disk offset/lengths are stored in 512-byte sectors */
+struct pnfs_blk_volume {
+	uint32_t		bv_type;
+	sector_t 		bv_size;
+	struct pnfs_blk_volume 	**bv_vols;
+	int 			bv_vol_n;
+	union {
+		dev_t			bv_dev;
+		sector_t		bv_stripe_unit;
+		sector_t 		bv_offset;
+	};
+};
+
+/* Since components need not be aligned, cannot use sector_t */
+struct pnfs_blk_sig_comp {
+	int64_t 	bs_offset;  /* In bytes */
+	uint32_t   	bs_length;  /* In bytes */
+	char 		*bs_string;
+};
+
+/* Maximum number of signatures components in a simple volume */
+# define PNFS_BLOCK_MAX_SIG_COMP 16
+
+struct pnfs_blk_sig {
+	int 				si_num_comps;
+	struct pnfs_blk_sig_comp	si_comps[PNFS_BLOCK_MAX_SIG_COMP];
+};
+
+uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
+
+#define BLK_READBUF(p, e, nbytes)  do { \
+	p = blk_overflow(p, e, nbytes); \
+	if (!p) { \
+		printk(KERN_WARNING \
+			"%s: reply buffer overflowed in line %d.\n", \
+			__func__, __LINE__); \
+		goto out_err; \
+	} \
+} while (0)
+
+#define READ32(x)         (x) = ntohl(*p++)
+#define READ64(x)         do {                  \
+	(x) = (uint64_t)ntohl(*p++) << 32;           \
+	(x) |= ntohl(*p++);                     \
+} while (0)
+#define COPYMEM(x, nbytes) do {                 \
+	memcpy((x), p, nbytes);                 \
+	p += XDR_QUADLEN(nbytes);               \
+} while (0)
+#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_PNFS_DEVICEID4_SIZE)
+#define READ_SECTOR(x)     do { \
+	READ64(tmp); \
+	if (tmp & 0x1ff) { \
+		printk(KERN_WARNING \
+		       "%s Value not 512-byte aligned at line %d\n", \
+		       __func__, __LINE__);			     \
+		goto out_err; \
+	} \
+	(x) = tmp >> 9; \
+} while (0)
+
 /* blocklayoutdev.c */
+struct pnfs_block_dev *nfs4_blk_decode_device(struct super_block *sb,
+					      struct pnfs_device *dev,
+					      struct list_head *sdlist);
 int nfs4_blk_create_scsi_disk_list(struct list_head *);
 void nfs4_blk_destroy_disk_list(struct list_head *);
+/* blocklayoutdm.c */
+struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
+					     struct pnfs_device *dev);
+int nfs4_blk_flatten(struct pnfs_blk_volume *, int, struct pnfs_block_dev *);
+void free_block_dev(struct pnfs_block_dev *bdev);
 
 #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index b4f52fb..f1689b9 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -229,3 +229,327 @@ int nfs4_blk_create_scsi_disk_list(struct list_head *dlist)
 	return class_for_each_device(&shost_class, NULL,
 				     &lc, nfs4_blk_iter_scsi_disk_list);
 }
+/* We are given an array of XDR encoded array indices, each of which should
+ * refer to a previously decoded device.  Translate into a list of pointers
+ * to the appropriate pnfs_blk_volume's.
+ */
+static int set_vol_array(uint32_t **pp, uint32_t *end,
+			 struct pnfs_blk_volume *vols, int working)
+{
+	int i, index;
+	uint32_t *p = *pp;
+	struct pnfs_blk_volume **array = vols[working].bv_vols;
+	for (i = 0; i < vols[working].bv_vol_n; i++) {
+		BLK_READBUF(p, end, 4);
+		READ32(index);
+		if ((index < 0) || (index >= working)) {
+			dprintk("%s Index %i out of expected range\n",
+				__func__, index);
+			goto out_err;
+		}
+		array[i] = &vols[index];
+	}
+	*pp = p;
+	return 0;
+ out_err:
+	return -EIO;
+}
+
+static uint64_t sum_subvolume_sizes(struct pnfs_blk_volume *vol)
+{
+	int i;
+	uint64_t sum = 0;
+	for (i = 0; i < vol->bv_vol_n; i++)
+		sum += vol->bv_vols[i]->bv_size;
+	return sum;
+}
+
+static int decode_blk_signature(uint32_t **pp, uint32_t *end,
+				struct pnfs_blk_sig *sig)
+{
+	int i, tmp;
+	uint32_t *p = *pp;
+
+	BLK_READBUF(p, end, 4);
+	READ32(sig->si_num_comps);
+	if (sig->si_num_comps == 0) {
+		dprintk("%s 0 components in sig\n", __func__);
+		goto out_err;
+	}
+	if (sig->si_num_comps >= PNFS_BLOCK_MAX_SIG_COMP) {
+		dprintk("number of sig comps %i >= PNFS_BLOCK_MAX_SIG_COMP\n",
+		       sig->si_num_comps);
+		goto out_err;
+	}
+	for (i = 0; i < sig->si_num_comps; i++) {
+		BLK_READBUF(p, end, 12);
+		READ64(sig->si_comps[i].bs_offset);
+		READ32(tmp);
+		sig->si_comps[i].bs_length = tmp;
+		BLK_READBUF(p, end, tmp);
+		/* Note we rely here on fact that sig is used immediately
+		 * for mapping, then thrown away.
+		 */
+		sig->si_comps[i].bs_string = (char *)p;
+		p += XDR_QUADLEN(tmp);
+	}
+	*pp = p;
+	return 0;
+ out_err:
+	return -EIO;
+}
+
+/* Translate a signature component into a block and offset. */
+static void get_sector(struct block_device *bdev,
+		       struct pnfs_blk_sig_comp *comp,
+		       sector_t *block,
+		       uint32_t *offset_in_block)
+{
+	int64_t use_offset = comp->bs_offset;
+	unsigned int blkshift = blksize_bits(block_size(bdev));
+
+	dprintk("%s enter\n", __func__);
+	if (use_offset < 0)
+		use_offset += (get_capacity(bdev->bd_disk) << 9);
+	*block = use_offset >> blkshift;
+	*offset_in_block = use_offset - (*block << blkshift);
+
+	dprintk("%s block %llu offset_in_block %u\n",
+			__func__, (u64)*block, *offset_in_block);
+	return;
+}
+
+/*
+ * All signatures in sig must be found on bdev for verification.
+ * Returns True if sig matches, False otherwise.
+ *
+ * STUB - signature crossing a block boundary will cause problems.
+ */
+static int verify_sig(struct block_device *bdev, struct pnfs_blk_sig *sig)
+{
+	sector_t block = 0;
+	struct pnfs_blk_sig_comp *comp;
+	struct buffer_head *bh = NULL;
+	uint32_t offset_in_block = 0;
+	char *ptr;
+	int i;
+
+	dprintk("%s enter. bd_disk->capacity %ld, bd_block_size %d\n",
+			__func__, (unsigned long)get_capacity(bdev->bd_disk),
+			bdev->bd_block_size);
+	for (i = 0; i < sig->si_num_comps; i++) {
+		comp = &sig->si_comps[i];
+		dprintk("%s comp->bs_offset %lld, length=%d\n", __func__,
+			comp->bs_offset, comp->bs_length);
+		get_sector(bdev, comp, &block, &offset_in_block);
+		bh = __bread(bdev, block, bdev->bd_block_size);
+		if (!bh)
+			goto out_err;
+		ptr = (char *)bh->b_data + offset_in_block;
+		if (memcmp(ptr, comp->bs_string, comp->bs_length))
+			goto out_err;
+		brelse(bh);
+	}
+	dprintk("%s Complete Match Found\n", __func__);
+	return 1;
+
+out_err:
+	brelse(bh);
+	dprintk("%s  No Match\n", __func__);
+	return 0;
+}
+
+/*
+ * map_sig_to_device()
+ * Given a signature, walk the list of visible scsi disks searching for
+ * a match. Returns True if mapping was done, False otherwise.
+ *
+ * While we're at it, fill in the vol->bv_size.
+ */
+/* XXX FRED - use normal 0=success status */
+static int map_sig_to_device(struct pnfs_blk_sig *sig,
+			     struct pnfs_blk_volume *vol,
+			     struct list_head *sdlist)
+{
+	int mapped = 0;
+	struct visible_block_device *vis_dev;
+
+	list_for_each_entry(vis_dev, sdlist, vi_node) {
+		if (vis_dev->vi_mapped)
+			continue;
+		mapped = verify_sig(vis_dev->vi_bdev, sig);
+		if (mapped) {
+			vol->bv_dev = vis_dev->vi_bdev->bd_dev;
+			vol->bv_size = get_capacity(vis_dev->vi_bdev->bd_disk);
+			vis_dev->vi_mapped = 1;
+			/* XXX FRED check this */
+			/* We no longer need to scan this device, and
+			 * we need to "put" it before creating metadevice.
+			 */
+			if (!vis_dev->vi_put_done) {
+				vis_dev->vi_put_done = 1;
+				nfs4_blkdev_put(vis_dev->vi_bdev);
+			}
+			break;
+		}
+	}
+	return mapped;
+}
+
+/* XDR decodes pnfs_block_volume4 structure */
+static int decode_blk_volume(uint32_t **pp, uint32_t *end,
+			     struct pnfs_blk_volume *vols, int i,
+			     struct list_head *sdlist, int *array_cnt)
+{
+	int status = 0;
+	struct pnfs_blk_sig sig;
+	uint32_t *p = *pp;
+	uint64_t tmp; /* Used by READ_SECTOR */
+	struct pnfs_blk_volume *vol = &vols[i];
+	int j;
+	u64 tmp_size;
+
+	BLK_READBUF(p, end, 4);
+	READ32(vol->bv_type);
+	dprintk("%s vol->bv_type = %i\n", __func__, vol->bv_type);
+	switch (vol->bv_type) {
+	case PNFS_BLOCK_VOLUME_SIMPLE:
+		*array_cnt = 0;
+		status = decode_blk_signature(&p, end, &sig);
+		if (status)
+			return status;
+		status = map_sig_to_device(&sig, vol, sdlist);
+		if (!status) {
+			dprintk("Could not find disk for device\n");
+			return -EIO;
+		}
+		status = 0;
+		dprintk("%s Set Simple vol to dev %d:%d, size %llu\n",
+				__func__,
+				MAJOR(vol->bv_dev),
+				MINOR(vol->bv_dev),
+				(u64)vol->bv_size);
+		break;
+	case PNFS_BLOCK_VOLUME_SLICE:
+		BLK_READBUF(p, end, 16);
+		READ_SECTOR(vol->bv_offset);
+		READ_SECTOR(vol->bv_size);
+		*array_cnt = vol->bv_vol_n = 1;
+		status = set_vol_array(&p, end, vols, i);
+		break;
+	case PNFS_BLOCK_VOLUME_STRIPE:
+		BLK_READBUF(p, end, 8);
+		READ_SECTOR(vol->bv_stripe_unit);
+		BLK_READBUF(p, end, 4);
+		READ32(vol->bv_vol_n);
+		if (!vol->bv_vol_n)
+			return -EIO;
+		*array_cnt = vol->bv_vol_n;
+		status = set_vol_array(&p, end, vols, i);
+		if (status)
+			return status;
+		/* Ensure all subvolumes are the same size */
+		for (j = 1; j < vol->bv_vol_n; j++) {
+			if (vol->bv_vols[j]->bv_size !=
+			    vol->bv_vols[0]->bv_size) {
+				dprintk("%s varying subvol size\n", __func__);
+				return -EIO;
+			}
+		}
+		/* Make sure total size only includes addressable areas */
+		tmp_size = vol->bv_vols[0]->bv_size;
+		do_div(tmp_size, (u32)vol->bv_stripe_unit);
+		vol->bv_size = vol->bv_vol_n * tmp_size * vol->bv_stripe_unit;
+		dprintk("%s Set Stripe vol to size %llu\n",
+				__func__, (u64)vol->bv_size);
+		break;
+	case PNFS_BLOCK_VOLUME_CONCAT:
+		BLK_READBUF(p, end, 4);
+		READ32(vol->bv_vol_n);
+		if (!vol->bv_vol_n)
+			return -EIO;
+		*array_cnt = vol->bv_vol_n;
+		status = set_vol_array(&p, end, vols, i);
+		if (status)
+			return status;
+		vol->bv_size = sum_subvolume_sizes(vol);
+		dprintk("%s Set Concat vol to size %llu\n",
+				__func__, (u64)vol->bv_size);
+		break;
+	default:
+		dprintk("Unknown volume type %i\n", vol->bv_type);
+ out_err:
+		return -EIO;
+	}
+	*pp = p;
+	return status;
+}
+
+/* Decodes pnfs_block_deviceaddr4 (draft-8) which is XDR encoded
+ * in dev->dev_addr_buf.
+ */
+struct pnfs_block_dev *
+nfs4_blk_decode_device(struct super_block *sb,
+				  struct pnfs_device *dev,
+				  struct list_head *sdlist)
+{
+	int num_vols, i, status, count;
+	struct pnfs_blk_volume *vols, **arrays, **arrays_ptr;
+	uint32_t *p = dev->area;
+	uint32_t *end = (uint32_t *) ((char *) p + dev->mincount);
+	struct pnfs_block_dev *rv = NULL;
+	struct visible_block_device *vis_dev;
+
+	dprintk("%s enter\n", __func__);
+
+	READ32(num_vols);
+	dprintk("%s num_vols = %i\n", __func__, num_vols);
+
+	vols = kmalloc(sizeof(struct pnfs_blk_volume) * num_vols, GFP_KERNEL);
+	if (!vols)
+		return NULL;
+	/* Each volume in vols array needs its own array.  Save time by
+	 * allocating them all in one large hunk.  Because each volume
+	 * array can only reference previous volumes, and because once
+	 * a concat or stripe references a volume, it may never be
+	 * referenced again, the volume arrays are guaranteed to fit
+	 * in the suprisingly small space allocated.
+	 */
+	arrays = kmalloc(sizeof(struct pnfs_blk_volume *) * num_vols * 2,
+			 GFP_KERNEL);
+	if (!arrays)
+		goto out;
+	arrays_ptr = arrays;
+
+	list_for_each_entry(vis_dev, sdlist, vi_node) {
+		/* Wipe crud left from parsing previous device */
+		vis_dev->vi_mapped = 0;
+	}
+	for (i = 0; i < num_vols; i++) {
+		vols[i].bv_vols = arrays_ptr;
+		status = decode_blk_volume(&p, end, vols, i, sdlist, &count);
+		if (status)
+			goto out;
+		arrays_ptr += count;
+	}
+
+	/* Check that we have used up opaque */
+	if (p != end) {
+		dprintk("Undecoded cruft at end of opaque\n");
+		goto out;
+	}
+
+	/* Now use info in vols to create the meta device */
+	rv = nfs4_blk_init_metadev(sb, dev);
+	if (!rv)
+		goto out;
+	status = nfs4_blk_flatten(vols, num_vols, rv);
+	if (status) {
+		free_block_dev(rv);
+		rv = NULL;
+	}
+ out:
+	kfree(arrays);
+	kfree(vols);
+	return rv;
+}
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
new file mode 100644
index 0000000..15eaed2
--- /dev/null
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -0,0 +1,72 @@
+/*
+ *  linux/fs/nfs/blocklayout/blocklayoutdm.c
+ *
+ *  Module for the NFSv4.1 pNFS block layout driver.
+ *
+ *  Copyright (c) 2007 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Fred Isaman <iisaman@umich.edu>
+ *  Andy Adamson <andros@citi.umich.edu>
+ *
+ * permission is granted to use, copy, create derivative works and
+ * redistribute this software and such derivative works for any purpose,
+ * so long as the name of the university of michigan is not used in
+ * any advertising or publicity pertaining to the use or distribution
+ * of this software without specific, written prior authorization.  if
+ * the above copyright notice or any other identification of the
+ * university of michigan is included in any copy of any portion of
+ * this software, then the disclaimer below must also be included.
+ *
+ * this software is provided as is, without representation from the
+ * university of michigan as to its fitness for any purpose, and without
+ * warranty by the university of michigan of any kind, either express
+ * or implied, including without limitation the implied warranties of
+ * merchantability and fitness for a particular purpose.  the regents
+ * of the university of michigan shall not be liable for any damages,
+ * including special, indirect, incidental, or consequential damages,
+ * with respect to any claim arising out or in connection with the use
+ * of the software, even if it has been or is hereafter advised of the
+ * possibility of such damages.
+ */
+
+#include "blocklayout.h"
+
+#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
+
+/* Stub */
+static int nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
+{
+	return 0;
+}
+
+void free_block_dev(struct pnfs_block_dev *bdev)
+{
+	if (bdev) {
+		if (bdev->bm_mdev) {
+			dprintk("%s Removing DM device: %s %d:%d\n",
+				__func__,
+				bdev->bm_mdevname,
+				MAJOR(bdev->bm_mdev->bd_dev),
+				MINOR(bdev->bm_mdev->bd_dev));
+			/* XXX Check status ?? */
+			nfs4_blk_metadev_release(bdev);
+		}
+		kfree(bdev);
+	}
+}
+
+/* Stub */
+struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
+					     struct pnfs_device *dev)
+{
+	return NULL;
+}
+
+/* Stub */
+int nfs4_blk_flatten(struct pnfs_blk_volume *vols, int size,
+		     struct pnfs_block_dev *bdev)
+{
+	return 0;
+}
+
-- 
1.7.4.1

