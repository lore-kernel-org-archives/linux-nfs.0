Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51401 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:19 -0400
Date: Tue, 7 Jun 2011 13:32:16 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 52/88] pnfsblock: iterating all local block disks instead of
 only scsi disks when initializing mount point.
Message-ID: <19e50a87f04780d1c4ba346f14b65d4c8d58f0f1.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Tao Guo <guotao@nrchpc.ac.cn>

So we can use virtual block devices like MD/DM in blocklayoutdriver.

Signed-off-by: Huang Haoi <huanghao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   12 ++--
 fs/nfs/blocklayout/blocklayout.h    |    3 +-
 fs/nfs/blocklayout/blocklayoutdev.c |  116 +++++++++++++++--------------------
 fs/nfs/blocklayout/blocklayoutdm.c  |    2 +-
 4 files changed, 57 insertions(+), 76 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 918e6d6..688984f 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -765,7 +765,7 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 	struct pnfs_mount_type *mtype = NULL;
 	struct pnfs_devicelist *dlist = NULL;
 	struct pnfs_block_dev *bdev;
-	LIST_HEAD(scsi_disklist);
+	LIST_HEAD(block_disklist);
 	int status, i;
 
 	dprintk("%s enter\n", __func__);
@@ -783,10 +783,10 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 	spin_lock_init(&b_mt_id->bm_lock);
 	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
 
-	/* Construct a list of all visible scsi disks that have not been
+	/* Construct a list of all visible block disks that have not been
 	 * claimed.
 	 */
-	status =  nfs4_blk_create_scsi_disk_list(&scsi_disklist);
+	status =  nfs4_blk_create_block_disk_list(&block_disklist);
 	if (status < 0)
 		goto out_error;
 
@@ -804,13 +804,13 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 		/* For each device returned in dlist, call GETDEVICEINFO, and
 		 * decode the opaque topology encoding to create a flat
 		 * volume topology, matching VOLUME_SIMPLE disk signatures
-		 * to disks in the visible scsi disk list.
+		 * to disks in the visible block disk list.
 		 * Construct an LVM meta device from the flat volume topology.
 		 */
 		for (i = 0; i < dlist->num_devs; i++) {
 			bdev = nfs4_blk_get_deviceinfo(server, fh,
 						     &dlist->dev_id[i],
-						     &scsi_disklist);
+						     &block_disklist);
 			if (!bdev)
 				goto out_error;
 			spin_lock(&b_mt_id->bm_lock);
@@ -823,7 +823,7 @@ bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 	status = 0;
  out_return:
 	kfree(dlist);
-	nfs4_blk_destroy_disk_list(&scsi_disklist);
+	nfs4_blk_destroy_disk_list(&block_disklist);
 	return status;
 
  out_error:
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 286adc9..0efed8d 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -44,7 +44,6 @@
 #define SetPagePnfsErr(page)	set_bit(PG_pnfserr, &(page)->flags)
 #define ClearPagePnfsErr(page)	clear_bit(PG_pnfserr, &(page)->flags)
 
-extern struct class shost_class; /* exported from drivers/scsi/hosts.c */
 extern int dm_dev_create(struct dm_ioctl *param); /* from dm-ioctl.c */
 extern int dm_dev_remove(struct dm_ioctl *param); /* from dm-ioctl.c */
 extern int dm_do_resume(struct dm_ioctl *param);
@@ -250,7 +249,7 @@ struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
 					      struct list_head *sdlist);
 int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 			       struct nfs4_pnfs_layoutget_res *lgr);
-int nfs4_blk_create_scsi_disk_list(struct list_head *);
+int nfs4_blk_create_block_disk_list(struct list_head *);
 void nfs4_blk_destroy_disk_list(struct list_head *);
 /* blocklayoutdm.c */
 struct pnfs_block_dev *nfs4_blk_init_metadev(struct nfs_server *server,
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 4f45523..ef39c36 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -32,15 +32,14 @@
 #include <linux/module.h>
 #include <linux/buffer_head.h> /* __bread */
 
-#include <scsi/scsi.h>
-#include <scsi/scsi_device.h>
-#include <scsi/scsi_host.h>
+#include <linux/genhd.h>
+#include <linux/blkdev.h>
 
 #include "blocklayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-#define MAX_VOLS  256  /* Maximum number of SCSI disks.  Totally arbitrary */
+#define MAX_VOLS  256  /* Maximum number of block disks.  Totally arbitrary */
 
 uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
 {
@@ -78,7 +77,7 @@ int nfs4_blkdev_put(struct block_device *bdev)
 	return blkdev_put(bdev, FMODE_READ);
 }
 
-/* Add a visible, claimed (by us!) scsi disk to the device list */
+/* Add a visible, claimed (by us!) block disk to the device list */
 static int alloc_add_disk(struct block_device *blk_dev, struct list_head *dlist)
 {
 	struct visible_block_device *vis_dev;
@@ -96,17 +95,16 @@ static int alloc_add_disk(struct block_device *blk_dev, struct list_head *dlist)
 	return 0;
 }
 
-/* Walk the list of scsi_devices. Add disks that can be opened and claimed
+/* Walk the list of block_devices. Add disks that can be opened and claimed
  * to the device list
  */
 static int
-nfs4_blk_add_scsi_disk(struct Scsi_Host *shost,
+nfs4_blk_add_block_disk(struct device *cdev,
 		       int index, struct list_head *dlist)
 {
 	static char *claim_ptr = "I belong to pnfs block driver";
 	struct block_device *bdev;
 	struct gendisk *gd;
-	struct scsi_device *sdev;
 	unsigned int major, minor, ret = 0;
 	dev_t dev;
 
@@ -115,62 +113,49 @@ nfs4_blk_add_scsi_disk(struct Scsi_Host *shost,
 		dprintk("%s MAX_VOLS hit\n", __func__);
 		return -ENOSPC;
 	}
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
+	gd = dev_to_disk(cdev);
+	if (gd == NULL || get_capacity(gd) == 0 ||
+	    (gd->flags & GENHD_FL_SUPPRESS_PARTITION_INFO)) /* Skip ramdisks */
+		goto out;
 
-		ret = alloc_add_disk(bdev, dlist);
-		if (ret < 0)
-			goto out_err;
-		dprintk("%s ADDED DEVICE capacity %ld, bd_block_size %d\n",
-					__func__,
-					(unsigned long)get_capacity(gd),
-					bdev->bd_block_size);
+	dev = cdev->devt;
+	major = MAJOR(dev);
+	minor = MINOR(dev);
+	bdev = nfs4_blkdev_get(dev);
+	if (!bdev) {
+		dprintk("%s: failed to open device %d:%d\n",
+			__func__, major, minor);
+		goto out;
+	}
 
+	if (bd_claim(bdev, claim_ptr)) {
+		dprintk("%s: failed to claim device %d:%d\n",
+			 __func__, major, minor);
+		blkdev_put(bdev, FMODE_READ);
+		goto out;
 	}
+
+	ret = alloc_add_disk(bdev, dlist);
+	if (ret < 0)
+		goto out_err;
 	index++;
+	dprintk("%s ADDED DEVICE %d:%d capacity %ld, bd_block_size %d\n",
+		__func__, major, minor,
+		(unsigned long)get_capacity(gd),
+		bdev->bd_block_size);
+
+out:
 	dprintk("%s returns index %d \n", __func__, index);
 	return index;
 
 out_err:
-	dprintk("%s Can't add disk to list. ERROR: %d\n", __func__, ret);
+	dprintk("%s Can't add disk %d:%d to list. ERROR: %d\n",
+			__func__, major, minor, ret);
 	nfs4_blkdev_put(bdev);
 	return ret;
 }
 
-/* Destroy the temporary scsi disk list */
+/* Destroy the temporary block disk list */
 void nfs4_blk_destroy_disk_list(struct list_head *dlist)
 {
 	struct visible_block_device *vis_dev;
@@ -189,20 +174,18 @@ void nfs4_blk_destroy_disk_list(struct list_head *dlist)
 	}
 }
 
-struct nfs4_blk_scsi_disk_list_ctl {
+struct nfs4_blk_block_disk_list_ctl {
 	struct list_head *dlist;
 	int index;
 };
 
-static int nfs4_blk_iter_scsi_disk_list(struct device *cdev, void *data)
+static int nfs4_blk_iter_block_disk_list(struct device *cdev, void *data)
 {
-	struct Scsi_Host *shost;
-	struct nfs4_blk_scsi_disk_list_ctl *lc = data;
+	struct nfs4_blk_block_disk_list_ctl *lc = data;
 	int ret;
 
 	dprintk("%s enter\n", __func__);
-	shost = class_to_shost(cdev);
-	ret = nfs4_blk_add_scsi_disk(shost, lc->index, lc->dlist);
+	ret = nfs4_blk_add_block_disk(cdev, lc->index, lc->dlist);
 	dprintk("%s 1 ret %d\n", __func__, ret);
 	if (ret >= 0) {
 		lc->index = ret;
@@ -212,22 +195,21 @@ static int nfs4_blk_iter_scsi_disk_list(struct device *cdev, void *data)
 }
 
 /*
- * Create a temporary list of all SCSI disks host can see, and that have not
+ * Create a temporary list of all block disks host can see, and that have not
  * yet been claimed.
- * shost_class: list of all registered scsi_hosts
+ * block_class: list of all registered block disks.
  * returns -errno on error, and #of devices found on success.
- * XXX Loosely emulate scsi_host_lookup from scsi/host.c
 */
-int nfs4_blk_create_scsi_disk_list(struct list_head *dlist)
+int nfs4_blk_create_block_disk_list(struct list_head *dlist)
 {
-	struct nfs4_blk_scsi_disk_list_ctl lc = {
+	struct nfs4_blk_block_disk_list_ctl lc = {
 		.dlist = dlist,
 		.index = 0,
 	};
 
 	dprintk("%s enter\n", __func__);
-	return class_for_each_device(&shost_class, NULL,
-				     &lc, nfs4_blk_iter_scsi_disk_list);
+	return class_for_each_device(&block_class, NULL,
+				     &lc, nfs4_blk_iter_block_disk_list);
 }
 /* We are given an array of XDR encoded array indices, each of which should
  * refer to a previously decoded device.  Translate into a list of pointers
@@ -361,7 +343,7 @@ out_err:
 
 /*
  * map_sig_to_device()
- * Given a signature, walk the list of visible scsi disks searching for
+ * Given a signature, walk the list of visible block disks searching for
  * a match. Returns True if mapping was done, False otherwise.
  *
  * While we're at it, fill in the vol->bv_size.
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index d70f6b2..3d15de0 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -257,7 +257,7 @@ static int nfs4_blk_resolve(int root, struct pnfs_blk_volume *vols,
  * Create an LVM dm device table that represents the volume topology returned
  * by GETDEVICELIST or GETDEVICEINFO.
  *
- * vols:  topology with VOLUME_SIMPLEs mapped to visable scsi disks.
+ * vols:  topology with VOLUME_SIMPLEs mapped to visable block disks.
  * size:  number of volumes in vols.
  */
 int nfs4_blk_flatten(struct pnfs_blk_volume *vols, int size,
-- 
1.7.4.1

