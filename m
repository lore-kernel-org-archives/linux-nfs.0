Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53183 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR1v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:27:51 -0400
Date: Tue, 7 Jun 2011 13:27:50 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 17/88] pnfsblock: create and destroy dm metadevice
Message-ID: <76c6faff6537555ab92b3794b2e88116b30d236c.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Adds functions to create a (tableless) dm device and clean it up.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>

pnfsblock: fix pnfs_deviceid references

the pnfs_deviceid typedef was changed to struct pnfs_deviceid

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.h    |    2 +
 fs/nfs/blocklayout/blocklayoutdev.c |    4 +-
 fs/nfs/blocklayout/blocklayoutdm.c  |   84 +++++++++++++++++++++++++++++++++-
 3 files changed, 85 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 2c6e1fe..b705906 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -132,6 +132,8 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 } while (0)
 
 /* blocklayoutdev.c */
+struct block_device *nfs4_blkdev_get(dev_t dev);
+int nfs4_blkdev_put(struct block_device *bdev);
 struct pnfs_block_dev *nfs4_blk_decode_device(struct super_block *sb,
 					      struct pnfs_device *dev,
 					      struct list_head *sdlist);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index f1689b9..0ea44aa 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -52,7 +52,7 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes)
 EXPORT_SYMBOL(blk_overflow);
 
 /* Open a block_device by device number. */
-static struct block_device *nfs4_blkdev_get(dev_t dev)
+struct block_device *nfs4_blkdev_get(dev_t dev)
 {
 	struct block_device *bd;
 
@@ -70,7 +70,7 @@ fail:
 /*
  * Release the block device
  */
-static int nfs4_blkdev_put(struct block_device *bdev)
+int nfs4_blkdev_put(struct block_device *bdev)
 {
 	dprintk("%s for device %d:%d\n", __func__, MAJOR(bdev->bd_dev),
 			MINOR(bdev->bd_dev));
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 15eaed2..0e04494 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -30,14 +30,51 @@
  * possibility of such damages.
  */
 
+#include <linux/genhd.h> /* gendisk - used in a dprintk*/
+
 #include "blocklayout.h"
 
 #define NFSDBG_FACILITY         NFSDBG_PNFS_LD
 
-/* Stub */
+static int dev_create(const char *name, dev_t *dev)
+{
+	struct dm_ioctl ctrl;
+	int rv;
+
+	memset(&ctrl, 0, sizeof(ctrl));
+	strncpy(ctrl.name, name, DM_NAME_LEN-1);
+	rv = dm_dev_create(&ctrl); /* XXX - need to pull data out of ctrl */
+	dprintk("Tried to create %s, got %i\n", name, rv);
+	if (!rv) {
+		*dev = huge_decode_dev(ctrl.dev);
+		dprintk("dev = (%i, %i)\n", MAJOR(*dev), MINOR(*dev));
+	}
+	return rv;
+}
+
+static int dev_remove(const char *name)
+{
+	struct dm_ioctl ctrl;
+	memset(&ctrl, 0, sizeof(ctrl));
+	strncpy(ctrl.name, name, DM_NAME_LEN-1);
+	return dm_dev_remove(&ctrl);
+}
+
+/*
+ * Release meta device
+ */
 static int nfs4_blk_metadev_release(struct pnfs_block_dev *bdev)
 {
-	return 0;
+	int rv;
+
+	dprintk("%s Releasing %s\n", __func__, bdev->bm_mdevname);
+	/* XXX Check return? */
+	rv = nfs4_blkdev_put(bdev->bm_mdev);
+	dprintk("%s nfs4_blkdev_put returns %d\n", __func__, rv);
+
+	rv = dev_remove(bdev->bm_mdevname);
+	dprintk("%s Returns %d\n", __func__, rv);
+	return rv;
 }
 
 void free_block_dev(struct pnfs_block_dev *bdev)
@@ -56,10 +93,51 @@ void free_block_dev(struct pnfs_block_dev *bdev)
 	}
 }
 
-/* Stub */
+/*
+ *  Create meta device. Keep it open to use for I/O.
+ */
 struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
 					     struct pnfs_device *dev)
 {
+	static uint64_t dev_count; /* STUB used for device names */
+	struct block_device *bd;
+	dev_t meta_dev;
+	struct pnfs_block_dev *rv;
+	int status;
+
+	dprintk("%s enter\n", __func__);
+
+	rv = kmalloc(sizeof(*rv) + 32, GFP_KERNEL);
+	if (!rv)
+		return NULL;
+	rv->bm_mdevname = (char *)rv + sizeof(*rv);
+	sprintf(rv->bm_mdevname, "FRED_%llu", dev_count++);
+	status = dev_create(rv->bm_mdevname, &meta_dev);
+	if (status)
+		goto out_err;
+	bd = nfs4_blkdev_get(meta_dev);
+	if (!bd)
+		goto out_err;
+	if (bd_claim(bd, sb)) {
+		dprintk("%s: failed to claim device %d:%d\n",
+					__func__,
+					MAJOR(meta_dev),
+					MINOR(meta_dev));
+		blkdev_put(bd, FMODE_READ);
+		goto out_err;
+	}
+
+	rv->bm_mdev = bd;
+	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct pnfs_deviceid));
+	dprintk("%s Created device %s named %s with bd_block_size %u\n",
+				__func__,
+				bd->bd_disk->disk_name,
+				rv->bm_mdevname,
+				bd->bd_block_size);
+	return rv;
+
+ out_err:
+	kfree(rv);
 	return NULL;
 }
 
-- 
1.7.4.1

