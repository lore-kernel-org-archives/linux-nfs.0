From: sfaibish <sfaibish@emc.com>
Subject: [pnfs][PATCH 2/3] pnfs-blocklayout client: remove device creation or remove from kernel
Date: Fri, 04 Jun 2010 14:15:35 -0400
Message-ID: <op.vdsfn9iounckof@usensfaibisl2e.eng.emc.com>
References: <op.vdsfeiz2unckof@usensfaibisl2e.eng.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed	delsp=yes
Cc: "pnfs@linux-nfs.org" <pnfs@linux-nfs.org>,
	"Sorin Faibish" <sfaibish@emc.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:17291 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0FDSQC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jun 2010 14:16:02 -0400
In-Reply-To: <op.vdsfeiz2unckof-sXut7+96orlxdPWQvOaHCoI83tS8F2Zb0E9HWUfgJXw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patch changes the client decodes pnfs_block_deviceaddr4 (draft-8)
which is XDR encoded in dev->dev_addr_buf. Maps deviceid returned by
the server to constructed block_device list of comples volumes. It also
removes device creation from the kernel and will be done in user space
by the discovery daemon.

Signed-off-by: Sorin Faibish <sfaibish-Wuw85uim5zDR7s880joybQ@public.gmane.org>
---
  fs/nfs/blocklayout/blocklayout.c    |   19 +-
  fs/nfs/blocklayout/blocklayout.h    |   24 ++-
  fs/nfs/blocklayout/blocklayoutdev.c |  508  
++++-------------------------------
  fs/nfs/blocklayout/blocklayoutdm.c  |  296 +++------------------
  4 files changed, 110 insertions(+), 737 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c  
b/fs/nfs/blocklayout/blocklayout.c
index db008e6..123fa2f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -687,8 +687,7 @@ static void free_blk_mountid(struct block_mount_id  
*mid)
   */
  static struct pnfs_block_dev *
  nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
-			struct pnfs_deviceid *d_id,
-			struct list_head *sdlist)
+			struct pnfs_deviceid *d_id)
  {
  	struct pnfs_device *dev;
  	struct pnfs_block_dev *rv = NULL;
@@ -739,7 +738,7 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct  
nfs_fh *fh,
  	if (rc)
  		goto out_free;

-	rv = nfs4_blk_decode_device(sb, dev, sdlist);
+	rv = nfs4_blk_decode_device(sb, dev);
   out_free:
  	if (used_pages > 1 && dev->area != NULL)
  		vunmap(dev->area);
@@ -760,7 +759,6 @@ bl_initialize_mountpoint(struct super_block *sb,  
struct nfs_fh *fh)
  	struct pnfs_mount_type *mtype = NULL;
  	struct pnfs_devicelist *dlist = NULL;
  	struct pnfs_block_dev *bdev;
-	LIST_HEAD(scsi_disklist);
  	int status, i;

  	dprintk("%s enter\n", __func__);
@@ -781,13 +779,6 @@ bl_initialize_mountpoint(struct super_block *sb,  
struct nfs_fh *fh)
  		goto out_error;
  	mtype->mountid = (void *)b_mt_id;

-	/* Construct a list of all visible scsi disks that have not been
-	 * claimed.
-	 */
-	status =  nfs4_blk_create_scsi_disk_list(&scsi_disklist);
-	if (status < 0)
-		goto out_error;
-
  	dlist = kmalloc(sizeof(struct pnfs_devicelist), GFP_KERNEL);
  	if (!dlist)
  		goto out_error;
@@ -806,8 +797,7 @@ bl_initialize_mountpoint(struct super_block *sb,  
struct nfs_fh *fh)
  		 */
  		for (i = 0; i < dlist->num_devs; i++) {
  			bdev = nfs4_blk_get_deviceinfo(sb, fh,
-						     &dlist->dev_id[i],
-						     &scsi_disklist);
+						     &dlist->dev_id[i]);
  			if (!bdev)
  				goto out_error;
  			spin_lock(&b_mt_id->bm_lock);
@@ -819,7 +809,6 @@ bl_initialize_mountpoint(struct super_block *sb,  
struct nfs_fh *fh)

   out_return:
  	kfree(dlist);
-	nfs4_blk_destroy_disk_list(&scsi_disklist);
  	return mtype;

   out_error:
@@ -1181,6 +1170,7 @@ static int __init nfs4blocklayout_init(void)
  	dprintk("%s: NFSv4 Block Layout Driver Registering...\n", __func__);

  	pnfs_callback_ops = pnfs_register_layoutdriver(&blocklayout_type);
+	bl_pipe_init();
  	return 0;
  }

@@ -1190,6 +1180,7 @@ static void __exit nfs4blocklayout_exit(void)
  	       __func__);

  	pnfs_unregister_layoutdriver(&blocklayout_type);
+	bl_pipe_exit();
  }

  module_init(nfs4blocklayout_init);
diff --git a/fs/nfs/blocklayout/blocklayout.h  
b/fs/nfs/blocklayout/blocklayout.h
index ca36e61..3cfa149 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -58,7 +58,6 @@ struct block_mount_id {

  struct pnfs_block_dev {
  	struct list_head		bm_node;
-	char				*bm_mdevname; /* meta device name */
  	struct pnfs_deviceid		bm_mdevid;    /* associated devid */
  	struct block_device		*bm_mdev;     /* meta device itself */
  };
@@ -241,16 +240,10 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end,  
size_t nbytes);
  struct block_device *nfs4_blkdev_get(dev_t dev);
  int nfs4_blkdev_put(struct block_device *bdev);
  struct pnfs_block_dev *nfs4_blk_decode_device(struct super_block *sb,
-					      struct pnfs_device *dev,
-					      struct list_head *sdlist);
+					      struct pnfs_device *dev);
  int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
  			       struct nfs4_pnfs_layoutget_res *lgr);
-int nfs4_blk_create_scsi_disk_list(struct list_head *);
-void nfs4_blk_destroy_disk_list(struct list_head *);
  /* blocklayoutdm.c */
-struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
-					     struct pnfs_device *dev);
-int nfs4_blk_flatten(struct pnfs_blk_volume *, int, struct pnfs_block_dev  
*);
  void free_block_dev(struct pnfs_block_dev *bdev);
  /* extents.c */
  struct pnfs_block_extent *
@@ -273,4 +266,19 @@ int add_and_merge_extent(struct pnfs_block_layout *bl,
  			 struct pnfs_block_extent *new);
  int mark_for_commit(struct pnfs_block_extent *be,
  		    sector_t offset, sector_t length);
+
+#include <linux/sunrpc/simple_rpc_pipefs.h>
+
+extern pipefs_list_t bl_device_list;
+extern struct dentry *bl_device_pipe;
+
+int bl_pipe_init(void);
+void bl_pipe_exit(void);
+
+#define BL_DEVICE_UMOUNT               0x0 /* Umount--delete devices */
+#define BL_DEVICE_MOUNT                0x1 /* Mount--create devices*/
+#define BL_DEVICE_REQUEST_INIT         0x0 /* Start request */
+#define BL_DEVICE_REQUEST_PROC         0x1 /* User level process succeeds  
*/
+#define BL_DEVICE_REQUEST_ERR          0x2 /* User level process fails */
+
  #endif /* FS_NFS_NFS4BLOCKLAYOUT_H */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c  
b/fs/nfs/blocklayout/blocklayoutdev.c
index ac5c117..c42108a 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -40,8 +40,6 @@

  #define NFSDBG_FACILITY         NFSDBG_PNFS_LD

-#define MAX_VOLS  256  /* Maximum number of SCSI disks.  Totally  
arbitrary */
-
  uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
  {
  	uint32_t *q = p + XDR_QUADLEN(nbytes);
@@ -78,480 +76,74 @@ int nfs4_blkdev_put(struct block_device *bdev)
  	return blkdev_put(bdev, FMODE_READ);
  }

-/* Add a visible, claimed (by us!) scsi disk to the device list */
-static int alloc_add_disk(struct block_device *blk_dev, struct list_head  
*dlist)
-{
-	struct visible_block_device *vis_dev;
-
-	dprintk("%s enter\n", __func__);
-	vis_dev = kmalloc(sizeof(struct visible_block_device), GFP_KERNEL);
-	if (!vis_dev) {
-		dprintk("%s nfs4_get_sig failed\n", __func__);
-		return -ENOMEM;
-	}
-	vis_dev->vi_bdev = blk_dev;
-	vis_dev->vi_mapped = 0;
-	vis_dev->vi_put_done = 0;
-	list_add(&vis_dev->vi_node, dlist);
-	return 0;
-}
-
-/* Walk the list of scsi_devices. Add disks that can be opened and claimed
- * to the device list
- */
-static int
-nfs4_blk_add_scsi_disk(struct Scsi_Host *shost,
-		       int index, struct list_head *dlist)
-{
-	static char *claim_ptr = "I belong to pnfs block driver";
-	struct block_device *bdev;
-	struct gendisk *gd;
-	struct scsi_device *sdev;
-	unsigned int major, minor, ret = 0;
-	dev_t dev;
-
-	dprintk("%s enter \n", __func__);
-	if (index >= MAX_VOLS) {
-		dprintk("%s MAX_VOLS hit\n", __func__);
-		return -ENOSPC;
-	}
-	dprintk("%s 1 \n", __func__);
-	index--;
-	shost_for_each_device(sdev, shost) {
-		dprintk("%s 2\n", __func__);
-		/* Need to do this check before bumping index */
-		if (sdev->type != TYPE_DISK)
-			continue;
-		dprintk("%s 3 index %d \n", __func__, index);
-		if (++index >= MAX_VOLS) {
-			scsi_device_put(sdev);
-			break;
-		}
-		major = (!(index >> 4) ? SCSI_DISK0_MAJOR :
-			 SCSI_DISK1_MAJOR-1 + (index  >> 4));
-		minor =  ((index << 4) & 255);
-
-		dprintk("%s SCSI device %d:%d \n", __func__, major, minor);
-
-		dev = MKDEV(major, minor);
-		bdev = nfs4_blkdev_get(dev);
-		if (!bdev) {
-			dprintk("%s: failed to open device %d:%d\n",
-					__func__, major, minor);
-			continue;
-		}
-		gd = bdev->bd_disk;
-
-		dprintk("%s 4\n", __func__);
-
-		if (bd_claim(bdev, claim_ptr)) {
-			dprintk("%s: failed to claim device %d:%d\n",
-				__func__, gd->major, gd->first_minor);
-			blkdev_put(bdev, FMODE_READ);
-			continue;
-		}
-
-		ret = alloc_add_disk(bdev, dlist);
-		if (ret < 0)
-			goto out_err;
-		dprintk("%s ADDED DEVICE capacity %ld, bd_block_size %d\n",
-					__func__,
-					(unsigned long)get_capacity(gd),
-					bdev->bd_block_size);
-
-	}
-	index++;
-	dprintk("%s returns index %d \n", __func__, index);
-	return index;
-
-out_err:
-	dprintk("%s Can't add disk to list. ERROR: %d\n", __func__, ret);
-	nfs4_blkdev_put(bdev);
-	return ret;
-}
-
-/* Destroy the temporary scsi disk list */
-void nfs4_blk_destroy_disk_list(struct list_head *dlist)
-{
-	struct visible_block_device *vis_dev;
-
-	dprintk("%s enter\n", __func__);
-	while (!list_empty(dlist)) {
-		vis_dev = list_first_entry(dlist, struct visible_block_device,
-					   vi_node);
-		dprintk("%s removing device %d:%d\n", __func__,
-				MAJOR(vis_dev->vi_bdev->bd_dev),
-				MINOR(vis_dev->vi_bdev->bd_dev));
-		list_del(&vis_dev->vi_node);
-		if (!vis_dev->vi_put_done)
-			nfs4_blkdev_put(vis_dev->vi_bdev);
-		kfree(vis_dev);
-	}
-}
-
-struct nfs4_blk_scsi_disk_list_ctl {
-	struct list_head *dlist;
-	int index;
-};
-
-static int nfs4_blk_iter_scsi_disk_list(struct device *cdev, void *data)
-{
-	struct Scsi_Host *shost;
-	struct nfs4_blk_scsi_disk_list_ctl *lc = data;
-	int ret;
-
-	dprintk("%s enter\n", __func__);
-	shost = class_to_shost(cdev);
-	ret = nfs4_blk_add_scsi_disk(shost, lc->index, lc->dlist);
-	dprintk("%s 1 ret %d\n", __func__, ret);
-	if (ret >= 0) {
-		lc->index = ret;
-		ret = 0;
-	}
-	return ret;
-}
-
-/*
- * Create a temporary list of all SCSI disks host can see, and that have  
not
- * yet been claimed.
- * shost_class: list of all registered scsi_hosts
- * returns -errno on error, and #of devices found on success.
- * XXX Loosely emulate scsi_host_lookup from scsi/host.c
-*/
-int nfs4_blk_create_scsi_disk_list(struct list_head *dlist)
-{
-	struct nfs4_blk_scsi_disk_list_ctl lc = {
-		.dlist = dlist,
-		.index = 0,
-	};
-
-	dprintk("%s enter\n", __func__);
-	return class_for_each_device(&shost_class, NULL,
-				     &lc, nfs4_blk_iter_scsi_disk_list);
-}
-/* We are given an array of XDR encoded array indices, each of which  
should
- * refer to a previously decoded device.  Translate into a list of  
pointers
- * to the appropriate pnfs_blk_volume's.
- */
-static int set_vol_array(uint32_t **pp, uint32_t *end,
-			 struct pnfs_blk_volume *vols, int working)
-{
-	int i, index;
-	uint32_t *p = *pp;
-	struct pnfs_blk_volume **array = vols[working].bv_vols;
-	for (i = 0; i < vols[working].bv_vol_n; i++) {
-		BLK_READBUF(p, end, 4);
-		READ32(index);
-		if ((index < 0) || (index >= working)) {
-			dprintk("%s Index %i out of expected range\n",
-				__func__, index);
-			goto out_err;
-		}
-		array[i] = &vols[index];
-	}
-	*pp = p;
-	return 0;
- out_err:
-	return -EIO;
-}
-
-static uint64_t sum_subvolume_sizes(struct pnfs_blk_volume *vol)
-{
-	int i;
-	uint64_t sum = 0;
-	for (i = 0; i < vol->bv_vol_n; i++)
-		sum += vol->bv_vols[i]->bv_size;
-	return sum;
-}
-
-static int decode_blk_signature(uint32_t **pp, uint32_t *end,
-				struct pnfs_blk_sig *sig)
-{
-	int i, tmp;
-	uint32_t *p = *pp;
-
-	BLK_READBUF(p, end, 4);
-	READ32(sig->si_num_comps);
-	if (sig->si_num_comps == 0) {
-		dprintk("%s 0 components in sig\n", __func__);
-		goto out_err;
-	}
-	if (sig->si_num_comps >= PNFS_BLOCK_MAX_SIG_COMP) {
-		dprintk("number of sig comps %i >= PNFS_BLOCK_MAX_SIG_COMP\n",
-		       sig->si_num_comps);
-		goto out_err;
-	}
-	for (i = 0; i < sig->si_num_comps; i++) {
-		BLK_READBUF(p, end, 12);
-		READ64(sig->si_comps[i].bs_offset);
-		READ32(tmp);
-		sig->si_comps[i].bs_length = tmp;
-		BLK_READBUF(p, end, tmp);
-		/* Note we rely here on fact that sig is used immediately
-		 * for mapping, then thrown away.
-		 */
-		sig->si_comps[i].bs_string = (char *)p;
-		p += XDR_QUADLEN(tmp);
-	}
-	*pp = p;
-	return 0;
- out_err:
-	return -EIO;
-}
-
-/* Translate a signature component into a block and offset. */
-static void get_sector(struct block_device *bdev,
-		       struct pnfs_blk_sig_comp *comp,
-		       sector_t *block,
-		       uint32_t *offset_in_block)
-{
-	int64_t use_offset = comp->bs_offset;
-	unsigned int blkshift = blksize_bits(block_size(bdev));
-
-	dprintk("%s enter\n", __func__);
-	if (use_offset < 0)
-		use_offset += (get_capacity(bdev->bd_disk) << 9);
-	*block = use_offset >> blkshift;
-	*offset_in_block = use_offset - (*block << blkshift);
-
-	dprintk("%s block %llu offset_in_block %u\n",
-			__func__, (u64)*block, *offset_in_block);
-	return;
-}
-
-/*
- * All signatures in sig must be found on bdev for verification.
- * Returns True if sig matches, False otherwise.
- *
- * STUB - signature crossing a block boundary will cause problems.
- */
-static int verify_sig(struct block_device *bdev, struct pnfs_blk_sig *sig)
-{
-	sector_t block = 0;
-	struct pnfs_blk_sig_comp *comp;
-	struct buffer_head *bh = NULL;
-	uint32_t offset_in_block = 0;
-	char *ptr;
-	int i;
-
-	dprintk("%s enter. bd_disk->capacity %ld, bd_block_size %d\n",
-			__func__, (unsigned long)get_capacity(bdev->bd_disk),
-			bdev->bd_block_size);
-	for (i = 0; i < sig->si_num_comps; i++) {
-		comp = &sig->si_comps[i];
-		dprintk("%s comp->bs_offset %lld, length=%d\n", __func__,
-			comp->bs_offset, comp->bs_length);
-		get_sector(bdev, comp, &block, &offset_in_block);
-		bh = __bread(bdev, block, bdev->bd_block_size);
-		if (!bh)
-			goto out_err;
-		ptr = (char *)bh->b_data + offset_in_block;
-		if (memcmp(ptr, comp->bs_string, comp->bs_length))
-			goto out_err;
-		brelse(bh);
-	}
-	dprintk("%s Complete Match Found\n", __func__);
-	return 1;
-
-out_err:
-	brelse(bh);
-	dprintk("%s  No Match\n", __func__);
-	return 0;
-}
-
-/*
- * map_sig_to_device()
- * Given a signature, walk the list of visible scsi disks searching for
- * a match. Returns True if mapping was done, False otherwise.
- *
- * While we're at it, fill in the vol->bv_size.
- */
-/* XXX FRED - use normal 0=success status */
-static int map_sig_to_device(struct pnfs_blk_sig *sig,
-			     struct pnfs_blk_volume *vol,
-			     struct list_head *sdlist)
-{
-	int mapped = 0;
-	struct visible_block_device *vis_dev;
-
-	list_for_each_entry(vis_dev, sdlist, vi_node) {
-		if (vis_dev->vi_mapped)
-			continue;
-		mapped = verify_sig(vis_dev->vi_bdev, sig);
-		if (mapped) {
-			vol->bv_dev = vis_dev->vi_bdev->bd_dev;
-			vol->bv_size = get_capacity(vis_dev->vi_bdev->bd_disk);
-			vis_dev->vi_mapped = 1;
-			/* XXX FRED check this */
-			/* We no longer need to scan this device, and
-			 * we need to "put" it before creating metadevice.
-			 */
-			if (!vis_dev->vi_put_done) {
-				vis_dev->vi_put_done = 1;
-				nfs4_blkdev_put(vis_dev->vi_bdev);
-			}
-			break;
-		}
-	}
-	return mapped;
-}
-
-/* XDR decodes pnfs_block_volume4 structure */
-static int decode_blk_volume(uint32_t **pp, uint32_t *end,
-			     struct pnfs_blk_volume *vols, int i,
-			     struct list_head *sdlist, int *array_cnt)
-{
-	int status = 0;
-	struct pnfs_blk_sig sig;
-	uint32_t *p = *pp;
-	uint64_t tmp; /* Used by READ_SECTOR */
-	struct pnfs_blk_volume *vol = &vols[i];
-	int j;
-	u64 tmp_size;
-
-	BLK_READBUF(p, end, 4);
-	READ32(vol->bv_type);
-	dprintk("%s vol->bv_type = %i\n", __func__, vol->bv_type);
-	switch (vol->bv_type) {
-	case PNFS_BLOCK_VOLUME_SIMPLE:
-		*array_cnt = 0;
-		status = decode_blk_signature(&p, end, &sig);
-		if (status)
-			return status;
-		status = map_sig_to_device(&sig, vol, sdlist);
-		if (!status) {
-			dprintk("Could not find disk for device\n");
-			return -EIO;
-		}
-		status = 0;
-		dprintk("%s Set Simple vol to dev %d:%d, size %llu\n",
-				__func__,
-				MAJOR(vol->bv_dev),
-				MINOR(vol->bv_dev),
-				(u64)vol->bv_size);
-		break;
-	case PNFS_BLOCK_VOLUME_SLICE:
-		BLK_READBUF(p, end, 16);
-		READ_SECTOR(vol->bv_offset);
-		READ_SECTOR(vol->bv_size);
-		*array_cnt = vol->bv_vol_n = 1;
-		status = set_vol_array(&p, end, vols, i);
-		break;
-	case PNFS_BLOCK_VOLUME_STRIPE:
-		BLK_READBUF(p, end, 8);
-		READ_SECTOR(vol->bv_stripe_unit);
-		BLK_READBUF(p, end, 4);
-		READ32(vol->bv_vol_n);
-		if (!vol->bv_vol_n)
-			return -EIO;
-		*array_cnt = vol->bv_vol_n;
-		status = set_vol_array(&p, end, vols, i);
-		if (status)
-			return status;
-		/* Ensure all subvolumes are the same size */
-		for (j = 1; j < vol->bv_vol_n; j++) {
-			if (vol->bv_vols[j]->bv_size !=
-			    vol->bv_vols[0]->bv_size) {
-				dprintk("%s varying subvol size\n", __func__);
-				return -EIO;
-			}
-		}
-		/* Make sure total size only includes addressable areas */
-		tmp_size = vol->bv_vols[0]->bv_size;
-		do_div(tmp_size, (u32)vol->bv_stripe_unit);
-		vol->bv_size = vol->bv_vol_n * tmp_size * vol->bv_stripe_unit;
-		dprintk("%s Set Stripe vol to size %llu\n",
-				__func__, (u64)vol->bv_size);
-		break;
-	case PNFS_BLOCK_VOLUME_CONCAT:
-		BLK_READBUF(p, end, 4);
-		READ32(vol->bv_vol_n);
-		if (!vol->bv_vol_n)
-			return -EIO;
-		*array_cnt = vol->bv_vol_n;
-		status = set_vol_array(&p, end, vols, i);
-		if (status)
-			return status;
-		vol->bv_size = sum_subvolume_sizes(vol);
-		dprintk("%s Set Concat vol to size %llu\n",
-				__func__, (u64)vol->bv_size);
-		break;
-	default:
-		dprintk("Unknown volume type %i\n", vol->bv_type);
- out_err:
-		return -EIO;
-	}
-	*pp = p;
-	return status;
-}
-
  /* Decodes pnfs_block_deviceaddr4 (draft-8) which is XDR encoded
   * in dev->dev_addr_buf.
   */
  struct pnfs_block_dev *
  nfs4_blk_decode_device(struct super_block *sb,
-				  struct pnfs_device *dev,
-				  struct list_head *sdlist)
+				  struct pnfs_device *dev)
  {
-	int num_vols, i, status, count;
-	struct pnfs_blk_volume *vols, **arrays, **arrays_ptr;
-	uint32_t *p = dev->area;
-	uint32_t *end = (uint32_t *) ((char *) p + dev->mincount);
  	struct pnfs_block_dev *rv = NULL;
-	struct visible_block_device *vis_dev;
+	struct block_device *bd = NULL;
+	pipefs_hdr_t *msg = NULL, *reply = NULL;
+	uint32_t major, minor;

  	dprintk("%s enter\n", __func__);

-	READ32(num_vols);
-	dprintk("%s num_vols = %i\n", __func__, num_vols);
-
-	vols = kmalloc(sizeof(struct pnfs_blk_volume) * num_vols, GFP_KERNEL);
-	if (!vols)
+	if (IS_ERR(bl_device_pipe))
  		return NULL;
-	/* Each volume in vols array needs its own array.  Save time by
-	 * allocating them all in one large hunk.  Because each volume
-	 * array can only reference previous volumes, and because once
-	 * a concat or stripe references a volume, it may never be
-	 * referenced again, the volume arrays are guaranteed to fit
-	 * in the suprisingly small space allocated.
-	 */
-	arrays = kmalloc(sizeof(struct pnfs_blk_volume *) * num_vols * 2,
-			 GFP_KERNEL);
-	if (!arrays)
-		goto out;
-	arrays_ptr = arrays;

-	list_for_each_entry(vis_dev, sdlist, vi_node) {
-		/* Wipe crud left from parsing previous device */
-		vis_dev->vi_mapped = 0;
-	}
-	for (i = 0; i < num_vols; i++) {
-		vols[i].bv_vols = arrays_ptr;
-		status = decode_blk_volume(&p, end, vols, i, sdlist, &count);
-		if (status)
-			goto out;
-		arrays_ptr += count;
+	msg = pipefs_alloc_init_msg(0, BL_DEVICE_MOUNT, 0, dev->area,
+				    dev->mincount);
+	if (IS_ERR(msg)) {
+		dprintk("ERROR: couldn't make pipefs message.\n");
+		goto out_err;
  	}
+	msg->msgid = (u32)(&msg);
+	msg->status = BL_DEVICE_REQUEST_INIT;

-	/* Check that we have used up opaque */
-	if (p != end) {
-		dprintk("Undecoded cruft at end of opaque\n");
-		goto out;
+	reply = pipefs_queue_upcall_waitreply(bl_device_pipe, msg,
+					      &bl_device_list, 0, 0);
+
+	if (IS_ERR(reply)) {
+		dprintk("ERROR: upcall_waitreply failed\n");
+		goto out_err;
+	}
+	if (reply->status != BL_DEVICE_REQUEST_PROC) {
+		dprintk("%s : reply status is %d\n", __func__, reply->status);
+		goto out_err;
+	}
+	memcpy(&major, (uint32_t *)(payload_of(reply)), sizeof(uint32_t));
+	memcpy(&minor, (uint32_t *)(payload_of(reply) + sizeof(uint32_t)),
+		sizeof(uint32_t));
+	bd = nfs4_blkdev_get(MKDEV(major, minor));	
+	if (IS_ERR(bd)) {
+		dprintk("%s failed to open device : %ld\n",
+			__func__, PTR_ERR(bd));
+		goto out_err;
  	}

-	/* Now use info in vols to create the meta device */
-	rv = nfs4_blk_init_metadev(sb, dev);
+	rv = kzalloc(sizeof(*rv), GFP_KERNEL);
  	if (!rv)
-		goto out;
-	status = nfs4_blk_flatten(vols, num_vols, rv);
-	if (status) {
-		free_block_dev(rv);
-		rv = NULL;
-	}
- out:
-	kfree(arrays);
-	kfree(vols);
+		goto out_err;
+
+	rv->bm_mdev = bd;
+	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct pnfs_deviceid));
+	dprintk("%s Created device %s with bd_block_size %u\n",
+		__func__,
+		bd->bd_disk->disk_name,
+		bd->bd_block_size);
+	kfree(reply);
+	kfree(msg);
  	return rv;
+
+out_err:
+	kfree(rv);
+	if (!IS_ERR(reply))
+		kfree(reply);
+	if (!IS_ERR(msg))
+		kfree(msg);
+	return NULL;
  }

  /* Map deviceid returned by the server to constructed block_device */
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c  
b/fs/nfs/blocklayout/blocklayoutdm.c
index 4bff748..f094bc1 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -31,6 +31,7 @@
   */

  #include <linux/genhd.h> /* gendisk - used in a dprintk*/
+#include <linux/sched.h>

  #include "blocklayout.h"

@@ -45,52 +46,44 @@
  #define roundup8(x) (((x)+7) & ~7)
  #define sizeof8(x) roundup8(sizeof(x))

-/* Given x>=1, return smallest n such that 2**n >= x */
-static unsigned long find_order(int x)
+static int dev_remove(dev_t dev)
  {
-	unsigned long rv = 0;
-	for (x--; x; x >>= 1)
-		rv++;
-	return rv;
-}
-
-/* Debugging aid */
-static void print_extent(u64 meta_offset, dev_t disk,
-			 u64 disk_offset, u64 length)
-{
-	dprintk("%lli:, %d:%d %lli, %lli\n", meta_offset, MAJOR(disk),
-			MINOR(disk), disk_offset, length);
-}
-static int dev_create(const char *name, dev_t *dev)
-{
-	struct dm_ioctl ctrl;
-	int rv;
-
-	memset(&ctrl, 0, sizeof(ctrl));
-	strncpy(ctrl.name, name, DM_NAME_LEN-1);
-	rv = dm_dev_create(&ctrl); /* XXX - need to pull data out of ctrl */
-	dprintk("Tried to create %s, got %i\n", name, rv);
-	if (!rv) {
-		*dev = huge_decode_dev(ctrl.dev);
-		dprintk("dev = (%i, %i)\n", MAJOR(*dev), MINOR(*dev));
+	int ret = 1;
+	pipefs_hdr_t *msg = NULL, *reply = NULL;
+	uint64_t bl_dev;
+	uint32_t major = MAJOR(dev), minor = MINOR(dev);
+
+	dprintk("Entering %s \n", __func__);
+
+	if (IS_ERR(bl_device_pipe))
+		return ret;
+
+	memcpy((void *)&bl_dev, &major, sizeof(uint32_t));
+	memcpy((void *)&bl_dev + sizeof(uint32_t), &minor, sizeof(uint32_t));
+	msg = pipefs_alloc_init_msg(0, BL_DEVICE_UMOUNT, 0, (void *)&bl_dev,
+				    sizeof(uint64_t));
+	if (IS_ERR(msg)) {
+		dprintk("ERROR: couldn't make pipefs message.\n");
+		goto out;
+	}
+	msg->msgid = (uint32_t)(&msg);
+	msg->status = BL_DEVICE_REQUEST_INIT;
+
+	reply = pipefs_queue_upcall_waitreply(bl_device_pipe, msg,
+					      &bl_device_list, 0, 0);
+	if (IS_ERR(reply)) {
+		dprintk("ERROR: upcall_waitreply failed\n");
+		goto out;
  	}
-	return rv;
-}
-
-static int dev_remove(const char *name)
-{
-	struct dm_ioctl ctrl;
-	memset(&ctrl, 0, sizeof(ctrl));
-	strncpy(ctrl.name, name, DM_NAME_LEN-1);
-	return dm_dev_remove(&ctrl);
-}

-static int dev_resume(const char *name)
-{
-	struct dm_ioctl ctrl;
-	memset(&ctrl, 0, sizeof(ctrl));
-	strncpy(ctrl.name, name, DM_NAME_LEN-1);
-	return dm_do_resume(&ctrl);
+	if (reply->status == BL_DEVICE_REQUEST_PROC)
+		ret = 0; /*TODO: what to return*/
+out:
+	if (!IS_ERR(reply))
+		kfree(reply);
+	if (!IS_ERR(msg))
+		kfree(msg);
+	return ret;
  }

  /*
@@ -100,12 +93,12 @@ static int nfs4_blk_metadev_release(struct  
pnfs_block_dev *bdev)
  {
  	int rv;

-	dprintk("%s Releasing %s\n", __func__, bdev->bm_mdevname);
+	dprintk("%s Releasing \n", __func__);
  	/* XXX Check return? */
  	rv = nfs4_blkdev_put(bdev->bm_mdev);
  	dprintk("%s nfs4_blkdev_put returns %d\n", __func__, rv);

-	rv = dev_remove(bdev->bm_mdevname);
+	rv = dev_remove(bdev->bm_mdev->bd_dev);
  	dprintk("%s Returns %d\n", __func__, rv);
  	return rv;
  }
@@ -114,9 +107,8 @@ void free_block_dev(struct pnfs_block_dev *bdev)
  {
  	if (bdev) {
  		if (bdev->bm_mdev) {
-			dprintk("%s Removing DM device: %s %d:%d\n",
+			dprintk("%s Removing DM device: %d:%d\n",
  				__func__,
-				bdev->bm_mdevname,
  				MAJOR(bdev->bm_mdev->bd_dev),
  				MINOR(bdev->bm_mdev->bd_dev));
  			/* XXX Check status ?? */
@@ -125,213 +117,3 @@ void free_block_dev(struct pnfs_block_dev *bdev)
  		kfree(bdev);
  	}
  }
-
-/*
- *  Create meta device. Keep it open to use for I/O.
- */
-struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
-					     struct pnfs_device *dev)
-{
-	static uint64_t dev_count; /* STUB used for device names */
-	struct block_device *bd;
-	dev_t meta_dev;
-	struct pnfs_block_dev *rv;
-	int status;
-
-	dprintk("%s enter\n", __func__);
-
-	rv = kmalloc(sizeof(*rv) + 32, GFP_KERNEL);
-	if (!rv)
-		return NULL;
-	rv->bm_mdevname = (char *)rv + sizeof(*rv);
-	sprintf(rv->bm_mdevname, "FRED_%llu", dev_count++);
-	status = dev_create(rv->bm_mdevname, &meta_dev);
-	if (status)
-		goto out_err;
-	bd = nfs4_blkdev_get(meta_dev);
-	if (!bd)
-		goto out_err;
-	if (bd_claim(bd, sb)) {
-		dprintk("%s: failed to claim device %d:%d\n",
-					__func__,
-					MAJOR(meta_dev),
-					MINOR(meta_dev));
-		blkdev_put(bd, FMODE_READ);
-		goto out_err;
-	}
-
-	rv->bm_mdev = bd;
-	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct pnfs_deviceid));
-	dprintk("%s Created device %s named %s with bd_block_size %u\n",
-				__func__,
-				bd->bd_disk->disk_name,
-				rv->bm_mdevname,
-				bd->bd_block_size);
-	return rv;
-
- out_err:
-	kfree(rv);
-	return NULL;
-}
-
-/*
- * Given a vol_offset into root, returns the disk and disk_offset it
- * corresponds to, as well as the length of the contiguous segment  
thereafter.
- * All offsets/lengths are in 512-byte sectors.
- */
-static int nfs4_blk_resolve(int root, struct pnfs_blk_volume *vols,
-			    u64 vol_offset, dev_t *disk, u64 *disk_offset,
-			    u64 *length)
-{
-	struct pnfs_blk_volume *node;
-	u64 node_offset;
-
-	/* Walk down device tree until we hit a leaf node (VOLUME_SIMPLE) */
-	node = &vols[root];
-	node_offset = vol_offset;
-	*length = node->bv_size;
-	while (1) {
-		dprintk("offset=%lli, length=%lli\n",
-			node_offset, *length);
-		if (node_offset > node->bv_size)
-			return -EIO;
-		switch (node->bv_type) {
-		case PNFS_BLOCK_VOLUME_SIMPLE:
-			*disk = node->bv_dev;
-			dprintk("%s VOLUME_SIMPLE: node->bv_dev %d:%d\n",
-			       __func__,
-			       MAJOR(node->bv_dev),
-			       MINOR(node->bv_dev));
-			*disk_offset = node_offset;
-			*length = min(*length, node->bv_size - node_offset);
-			return 0;
-		case PNFS_BLOCK_VOLUME_SLICE:
-			dprintk("%s VOLUME_SLICE:\n", __func__);
-			*length = min(*length, node->bv_size - node_offset);
-			node_offset += node->bv_offset;
-			node = node->bv_vols[0];
-			break;
-		case PNFS_BLOCK_VOLUME_CONCAT: {
-			u64 next = 0, sum = 0;
-			int i;
-			dprintk("%s VOLUME_CONCAT:\n", __func__);
-			for (i = 0; i < node->bv_vol_n; i++) {
-				next = sum + node->bv_vols[i]->bv_size;
-				if (node_offset < next)
-					break;
-				sum = next;
-			}
-			*length = min(*length, next - node_offset);
-			node_offset -= sum;
-			node = node->bv_vols[i];
-			}
-			break;
-		case PNFS_BLOCK_VOLUME_STRIPE: {
-			u64 global_s_no;
-			u64 stripe_pos;
-			u64 local_s_no;
-			u64 disk_number;
-
-			dprintk("%s VOLUME_STRIPE:\n", __func__);
-			global_s_no = node_offset;
-			/* BUG - note this assumes stripe_unit <= 2**32 */
-			stripe_pos = (u64) do_div(global_s_no,
-						  (u32)node->bv_stripe_unit);
-			local_s_no = global_s_no;
-			disk_number = (u64) do_div(local_s_no,
-						   (u32) node->bv_vol_n);
-			*length = min(*length,
-				      node->bv_stripe_unit - stripe_pos);
-			node_offset = local_s_no * node->bv_stripe_unit +
-					stripe_pos;
-			node = node->bv_vols[disk_number];
-			}
-			break;
-		default:
-			return -EIO;
-		}
-	}
-}
-
-/*
- * Create an LVM dm device table that represents the volume topology  
returned
- * by GETDEVICELIST or GETDEVICEINFO.
- *
- * vols:  topology with VOLUME_SIMPLEs mapped to visable scsi disks.
- * size:  number of volumes in vols.
- */
-int nfs4_blk_flatten(struct pnfs_blk_volume *vols, int size,
-		     struct pnfs_block_dev *bdev)
-{
-	u64 meta_offset = 0;
-	u64 meta_size = vols[size-1].bv_size;
-	dev_t disk;
-	u64 disk_offset, len;
-	int status = 0, count = 0, pages_needed;
-	struct dm_ioctl *ctl;
-	struct dm_target_spec *spec;
-	char *args = NULL;
-	unsigned long p;
-
-	dprintk("%s enter. mdevname %s number of volumes %d\n", __func__,
-			bdev->bm_mdevname, size);
-
-	/* We need to reserve memory to store segments, so need to count
-	 * segments.  This means we resolve twice, basically throwing away
-	 * all info from first run apart from the count.  Seems like
-	 * there should be a better way.
-	 */
-	for (meta_offset = 0; meta_offset < meta_size; meta_offset += len) {
-		status = nfs4_blk_resolve(size-1, vols, meta_offset, &disk,
-						&disk_offset, &len);
-		/* TODO Check status */
-		count += 1;
-	}
-
-	dprintk("%s: Have %i segments\n", __func__, count);
-	pages_needed = ((count + SPEC_HEADER_ADJUST) / SPECS_PER_PAGE) + 1;
-	dprintk("%s: Need %i pages\n", __func__, pages_needed);
-	p = __get_free_pages(GFP_KERNEL, find_order(pages_needed));
-	if (!p)
-		return -ENOMEM;
-	/* A dm_ioctl is placed at the beginning, followed by a series of
-	 * (dm_target_spec, argument string) pairs.
-	 */
-	ctl = (struct dm_ioctl *) p;
-	spec = (struct dm_target_spec *) (p + sizeof8(*ctl));
-	memset(ctl, 0, sizeof(*ctl));
-	ctl->data_start = (char *) spec - (char *) ctl;
-	ctl->target_count = count;
-	strncpy(ctl->name, bdev->bm_mdevname, DM_NAME_LEN);
-
-	dprintk("%s ctl->name %s\n", __func__, ctl->name);
-	for (meta_offset = 0; meta_offset < meta_size; meta_offset += len) {
-		status = nfs4_blk_resolve(size-1, vols, meta_offset, &disk,
-							&disk_offset, &len);
-		if (!len)
-			break;
-		/* TODO Check status */
-		print_extent(meta_offset, disk, disk_offset, len);
-		spec->sector_start = meta_offset;
-		spec->length = len;
-		spec->status = 0;
-		strcpy(spec->target_type, "linear");
-		args = (char *) (spec + 1);
-		sprintf(args, "%i:%i %lli",
-			MAJOR(disk), MINOR(disk), disk_offset);
-		dprintk("%s args %s\n", __func__, args);
-		spec->next = roundup8(sizeof(*spec) + strlen(args) + 1);
-		spec = (struct dm_target_spec *) (((char *) spec) + spec->next);
-	}
-	ctl->data_size = (char *) spec - (char *) ctl;
-
-	status = dm_table_load(ctl, ctl->data_size);
-	dprintk("%s dm_table_load returns %d\n", __func__, status);
-
-	dev_resume(bdev->bm_mdevname);
-
-	free_pages(p, find_order(pages_needed));
-	dprintk("%s returns %d\n", __func__, status);
-	return status;
-}
-
-- 
1.6.6.1

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


