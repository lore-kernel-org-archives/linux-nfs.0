Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:51303 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067Ab1FGRcB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:32:01 -0400
Date: Tue, 7 Jun 2011 13:31:58 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 49/88] SQUASHME: pnfs-block: convert APIs pnfs-post-submit
Message-ID: <6ce6a39344caf05bf3331dac4d799e0d9b67bed3.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   45 ++++++++++++++--------------------
 fs/nfs/blocklayout/blocklayout.h    |    7 ++---
 fs/nfs/blocklayout/blocklayoutdev.c |    8 +++---
 fs/nfs/blocklayout/blocklayoutdm.c  |    4 +-
 4 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 768d8fa..918e6d6 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -564,7 +564,7 @@ bl_free_layout(void *p)
 }
 
 static void *
-bl_alloc_layout(struct pnfs_mount_type *mtype, struct inode *inode)
+bl_alloc_layout(struct inode *inode)
 {
 	struct pnfs_block_layout	*bl;
 
@@ -688,7 +688,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
  * It seems much of this should be at the generic pnfs level.
  */
 static struct pnfs_block_dev *
-nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
+nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 			struct pnfs_deviceid *d_id,
 			struct list_head *sdlist)
 {
@@ -698,7 +698,6 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
 	int max_pages;
 	struct page **pages = NULL;
 	int i, rc;
-	struct nfs_server *server = NFS_SB(sb);
 
 	/*
 	 * Use the session max response size as the basis for setting
@@ -739,12 +738,12 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
 	dev->pglen = PAGE_SIZE * max_pages;
 	dev->mincount = 0;
 
-	rc = pnfs_block_callback_ops->nfs_getdeviceinfo(sb, dev);
+	rc = pnfs_block_callback_ops->nfs_getdeviceinfo(server, dev);
 	dprintk("%s getdevice info returns %d\n", __func__, rc);
 	if (rc)
 		goto out_free;
 
-	rv = nfs4_blk_decode_device(sb, dev, sdlist);
+	rv = nfs4_blk_decode_device(server, dev, sdlist);
  out_free:
 	if (dev->area != NULL)
 		vunmap(dev->area);
@@ -759,8 +758,8 @@ nfs4_blk_get_deviceinfo(struct super_block *sb, struct nfs_fh *fh,
 /*
  * Retrieve the list of available devices for the mountpoint.
  */
-static struct pnfs_mount_type *
-bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
+static int
+bl_initialize_mountpoint(struct nfs_server *server, const struct nfs_fh *fh)
 {
 	struct block_mount_id *b_mt_id = NULL;
 	struct pnfs_mount_type *mtype = NULL;
@@ -771,21 +770,18 @@ bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 
 	dprintk("%s enter\n", __func__);
 
-	if (NFS_SB(sb)->pnfs_blksize == 0) {
+	if (server->pnfs_blksize == 0) {
 		dprintk("%s Server did not return blksize\n", __func__);
-		return NULL;
+		return -EINVAL;
 	}
 	b_mt_id = kzalloc(sizeof(struct block_mount_id), GFP_KERNEL);
-	if (!b_mt_id)
+	if (!b_mt_id) {
+		status = -ENOMEM;
 		goto out_error;
+	}
 	/* Initialize nfs4 block layout mount id */
-	b_mt_id->bm_sb = sb; /* back pointer to retrieve nfs_server struct */
 	spin_lock_init(&b_mt_id->bm_lock);
 	INIT_LIST_HEAD(&b_mt_id->bm_devlist);
-	mtype = kzalloc(sizeof(struct pnfs_mount_type), GFP_KERNEL);
-	if (!mtype)
-		goto out_error;
-	mtype->mountid = (void *)b_mt_id;
 
 	/* Construct a list of all visible scsi disks that have not been
 	 * claimed.
@@ -799,7 +795,8 @@ bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 		goto out_error;
 	dlist->eof = 0;
 	while (!dlist->eof) {
-		status = pnfs_block_callback_ops->nfs_getdevicelist(sb, fh, dlist);
+		status = pnfs_block_callback_ops->nfs_getdevicelist(
+							server, fh, dlist);
 		if (status)
 			goto out_error;
 		dprintk("%s GETDEVICELIST numdevs=%i, eof=%i\n",
@@ -811,7 +808,7 @@ bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 		 * Construct an LVM meta device from the flat volume topology.
 		 */
 		for (i = 0; i < dlist->num_devs; i++) {
-			bdev = nfs4_blk_get_deviceinfo(sb, fh,
+			bdev = nfs4_blk_get_deviceinfo(server, fh,
 						     &dlist->dev_id[i],
 						     &scsi_disklist);
 			if (!bdev)
@@ -822,30 +819,26 @@ bl_initialize_mountpoint(struct super_block *sb, struct nfs_fh *fh)
 		}
 	}
 	dprintk("%s SUCCESS\n", __func__);
-
+	server->pnfs_ld_data = b_mt_id;
+	status = 0;
  out_return:
 	kfree(dlist);
 	nfs4_blk_destroy_disk_list(&scsi_disklist);
-	return mtype;
+	return status;
 
  out_error:
 	free_blk_mountid(b_mt_id);
 	kfree(mtype);
-	mtype = NULL;
 	goto out_return;
 }
 
 static int
-bl_uninitialize_mountpoint(struct pnfs_mount_type *mtype)
+bl_uninitialize_mountpoint(struct nfs_server *server)
 {
-	struct block_mount_id *b_mt_id = NULL;
+	struct block_mount_id *b_mt_id = server->pnfs_ld_data;
 
 	dprintk("%s enter\n", __func__);
-	if (!mtype)
-		return 0;
-	b_mt_id = (struct block_mount_id *)mtype->mountid;
 	free_blk_mountid(b_mt_id);
-	kfree(mtype);
 	dprintk("%s RETURNS\n", __func__);
 	return 0;
 }
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 45939e1..286adc9 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -51,7 +51,6 @@ extern int dm_do_resume(struct dm_ioctl *param);
 extern int dm_table_load(struct dm_ioctl *param, size_t param_size);
 
 struct block_mount_id {
-	struct super_block		*bm_sb;     /* back pointer */
 	spinlock_t			bm_lock;    /* protects list */
 	struct list_head		bm_devlist; /* holds pnfs_block_dev */
 };
@@ -194,7 +193,7 @@ struct bl_layoutupdate_data {
 	struct list_head ranges;
 };
 
-#define BLK_ID(lo)     ((struct block_mount_id *)(PNFS_MOUNTID(lo)->mountid))
+#define BLK_ID(lo) ((struct block_mount_id *)(PNFS_NFS_SERVER(lo)->pnfs_ld_data))
 #define BLK_LSEG2EXT(lseg) ((struct pnfs_block_layout *)lseg->layout->ld_data)
 #define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
 
@@ -246,7 +245,7 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 /* blocklayoutdev.c */
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
-struct pnfs_block_dev *nfs4_blk_decode_device(struct super_block *sb,
+struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
 					      struct pnfs_device *dev,
 					      struct list_head *sdlist);
 int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
@@ -254,7 +253,7 @@ int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 int nfs4_blk_create_scsi_disk_list(struct list_head *);
 void nfs4_blk_destroy_disk_list(struct list_head *);
 /* blocklayoutdm.c */
-struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
+struct pnfs_block_dev *nfs4_blk_init_metadev(struct nfs_server *server,
 					     struct pnfs_device *dev);
 int nfs4_blk_flatten(struct pnfs_blk_volume *, int, struct pnfs_block_dev *);
 void free_block_dev(struct pnfs_block_dev *bdev);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 9fc3d46..4f45523 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -489,9 +489,9 @@ static int decode_blk_volume(uint32_t **pp, uint32_t *end,
  * in dev->dev_addr_buf.
  */
 struct pnfs_block_dev *
-nfs4_blk_decode_device(struct super_block *sb,
-				  struct pnfs_device *dev,
-				  struct list_head *sdlist)
+nfs4_blk_decode_device(struct nfs_server *server,
+		       struct pnfs_device *dev,
+		       struct list_head *sdlist)
 {
 	int num_vols, i, status, count;
 	struct pnfs_blk_volume *vols, **arrays, **arrays_ptr;
@@ -540,7 +540,7 @@ nfs4_blk_decode_device(struct super_block *sb,
 	}
 
 	/* Now use info in vols to create the meta device */
-	rv = nfs4_blk_init_metadev(sb, dev);
+	rv = nfs4_blk_init_metadev(server, dev);
 	if (!rv)
 		goto out;
 	status = nfs4_blk_flatten(vols, num_vols, rv);
diff --git a/fs/nfs/blocklayout/blocklayoutdm.c b/fs/nfs/blocklayout/blocklayoutdm.c
index 4bff748..d70f6b2 100644
--- a/fs/nfs/blocklayout/blocklayoutdm.c
+++ b/fs/nfs/blocklayout/blocklayoutdm.c
@@ -129,7 +129,7 @@ void free_block_dev(struct pnfs_block_dev *bdev)
 /*
  *  Create meta device. Keep it open to use for I/O.
  */
-struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
+struct pnfs_block_dev *nfs4_blk_init_metadev(struct nfs_server *server,
 					     struct pnfs_device *dev)
 {
 	static uint64_t dev_count; /* STUB used for device names */
@@ -151,7 +151,7 @@ struct pnfs_block_dev *nfs4_blk_init_metadev(struct super_block *sb,
 	bd = nfs4_blkdev_get(meta_dev);
 	if (!bd)
 		goto out_err;
-	if (bd_claim(bd, sb)) {
+	if (bd_claim(bd, server)) {
 		dprintk("%s: failed to claim device %d:%d\n",
 					__func__,
 					MAJOR(meta_dev),
-- 
1.7.4.1

