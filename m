Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52131 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1FGReT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:19 -0400
Date: Tue, 7 Jun 2011 13:34:17 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 70/88] SQUASHME: pnfsblock: use nfs4_deviceid
Message-ID: <46c734e555b29eaf35df9843a85862d53cffa476.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

---
 fs/nfs/blocklayout/blocklayout.c    |    2 +-
 fs/nfs/blocklayout/blocklayout.h    |   10 +++++-----
 fs/nfs/blocklayout/blocklayoutdev.c |    8 ++++----
 fs/nfs/blocklayout/extents.c        |    2 +-
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index f49c68c..071e7ef 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -683,7 +683,7 @@ static void free_blk_mountid(struct block_mount_id *mid)
  */
 static struct pnfs_block_dev *
 nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
-			struct pnfs_deviceid *d_id,
+			struct nfs4_deviceid *d_id,
 			struct list_head *sdlist)
 {
 	struct pnfs_device *dev;
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index fc0fb23..d62e3f9 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -55,7 +55,7 @@ struct block_mount_id {
 
 struct pnfs_block_dev {
 	struct list_head		bm_node;
-	struct pnfs_deviceid		bm_mdevid;    /* associated devid */
+	struct nfs4_deviceid		bm_mdevid;    /* associated devid */
 	struct block_device		*bm_mdev;     /* meta device itself */
 };
 
@@ -132,7 +132,7 @@ struct pnfs_inval_tracking {
 struct pnfs_block_extent {
 	struct kref	be_refcnt;
 	struct list_head be_node;	/* link into lseg list */
-	struct pnfs_deviceid be_devid;  /* STUB - remevable??? */
+	struct nfs4_deviceid be_devid;  /* STUB - remevable??? */
 	struct block_device *be_mdev;
 	sector_t	be_f_offset;	/* the starting offset in the file */
 	sector_t	be_length;	/* the size of the extent */
@@ -144,7 +144,7 @@ struct pnfs_block_extent {
 /* Shortened extent used by LAYOUTCOMMIT */
 struct pnfs_block_short_extent {
 	struct list_head bse_node;
-	struct pnfs_deviceid bse_devid;	/* STUB - removable??? */
+	struct nfs4_deviceid bse_devid;	/* STUB - removable??? */
 	struct block_device *bse_mdev;
 	sector_t	bse_f_offset;	/* the starting offset in the file */
 	sector_t	bse_length;	/* the size of the extent */
@@ -226,7 +226,7 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 	memcpy((x), p, nbytes);                 \
 	p += XDR_QUADLEN(nbytes);               \
 } while (0)
-#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_PNFS_DEVICEID4_SIZE)
+#define READ_DEVID(x)	COPYMEM((x)->data, NFS4_DEVICEID4_SIZE)
 #define READ_SECTOR(x)     do { \
 	READ64(tmp); \
 	if (tmp & 0x1ff) { \
@@ -248,7 +248,7 @@ uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
 #define WRITEMEM(ptr, nbytes)     do {                          \
 	p = xdr_encode_opaque_fixed(p, ptr, nbytes);	\
 } while (0)
-#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_PNFS_DEVICEID4_SIZE)
+#define WRITE_DEVID(x)  WRITEMEM((x)->data, NFS4_DEVICEID4_SIZE)
 
 /* blocklayoutdev.c */
 struct block_device *nfs4_blkdev_get(dev_t dev);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index e9ea86a..17bd25a 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -133,7 +133,7 @@ nfs4_blk_decode_device(struct nfs_server *server,
 		goto out_err;
 
 	rv->bm_mdev = bd;
-	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct pnfs_deviceid));
+	memcpy(&rv->bm_mdevid, &dev->dev_id, sizeof(struct nfs4_deviceid));
 	dprintk("%s Created device %s with bd_block_size %u\n",
 		__func__,
 		bd->bd_disk->disk_name,
@@ -153,7 +153,7 @@ out_err:
 
 /* Map deviceid returned by the server to constructed block_device */
 static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
-					    struct pnfs_deviceid *id)
+					    struct nfs4_deviceid *id)
 {
 	struct block_device *rv = NULL;
 	struct block_mount_id *mid;
@@ -164,7 +164,7 @@ static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
 	spin_lock(&mid->bm_lock);
 	list_for_each_entry(dev, &mid->bm_devlist, bm_node) {
 		if (memcmp(id->data, dev->bm_mdevid.data,
-			   NFS4_PNFS_DEVICEID4_SIZE) == 0) {
+			   NFS4_DEVICEID4_SIZE) == 0) {
 			rv = dev->bm_mdev;
 			goto out;
 		}
@@ -254,7 +254,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
 	READ32(count);
 
 	dprintk("%s enter, number of extents %i\n", __func__, count);
-	BLK_READBUF(p, end, (28 + NFS4_PNFS_DEVICEID4_SIZE) * count);
+	BLK_READBUF(p, end, (28 + NFS4_DEVICEID4_SIZE) * count);
 
 	/* Decode individual extents, putting them in temporary
 	 * staging area until whole layout is decoded to make error
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 20cc863..40dff82 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -794,7 +794,7 @@ _prep_new_extent(struct pnfs_block_extent *new,
 {
 	kref_init(&new->be_refcnt);
 	/* don't need to INIT_LIST_HEAD(&new->be_node) */
-	memcpy(&new->be_devid, &orig->be_devid, sizeof(struct pnfs_deviceid));
+	memcpy(&new->be_devid, &orig->be_devid, sizeof(struct nfs4_deviceid));
 	new->be_mdev = orig->be_mdev;
 	new->be_f_offset = offset;
 	new->be_length = length;
-- 
1.7.4.1

