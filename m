Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52028 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755799Ab1FGReD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:03 -0400
Date: Tue, 7 Jun 2011 13:33:59 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 67/88] SQUASHME: pnfs-block: apply types rename
Message-ID: <db277a3157cc934f0706bab1b803fe3e8e0e690e.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   32 ++++++++++++++++----------------
 fs/nfs/blocklayout/blocklayout.h    |   13 ++++++-------
 fs/nfs/blocklayout/blocklayoutdev.c |   16 ++++++++--------
 fs/nfs/blocklayout/extents.c        |    8 ++++----
 4 files changed, 34 insertions(+), 35 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index e3cd75f..f49c68c 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -515,7 +515,7 @@ bl_write_pagelist(struct nfs_write_data *wdata,
 /* FIXME - range ignored */
 static void
 release_extents(struct pnfs_block_layout *bl,
-		struct nfs4_pnfs_layout_segment *range)
+		struct pnfs_layout_range *range)
 {
 	int i;
 	struct pnfs_block_extent *be;
@@ -547,7 +547,7 @@ release_inval_marks(struct pnfs_inval_markings *marks)
 
 /* Note we are relying on caller locking to prevent nasty races. */
 static void
-bl_free_layout(struct pnfs_layout_type *lo)
+bl_free_layout(struct pnfs_layout_hdr *lo)
 {
 	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 
@@ -557,7 +557,7 @@ bl_free_layout(struct pnfs_layout_type *lo)
 	kfree(bl);
 }
 
-static struct pnfs_layout_type *
+static struct pnfs_layout_hdr *
 bl_alloc_layout(struct inode *inode)
 {
 	struct pnfs_block_layout	*bl;
@@ -590,8 +590,8 @@ bl_free_lseg(struct pnfs_layout_segment *lseg)
  * cause lots of unnecessary overlapping LAYOUTGET requests.
  */
 static struct pnfs_layout_segment *
-bl_alloc_lseg(struct pnfs_layout_type *lo,
-	      struct nfs4_pnfs_layoutget_res *lgr)
+bl_alloc_lseg(struct pnfs_layout_hdr *lo,
+	      struct nfs4_layoutget_res *lgr)
 {
 	struct pnfs_layout_segment *lseg;
 	int status;
@@ -617,8 +617,8 @@ bl_alloc_lseg(struct pnfs_layout_type *lo,
 }
 
 static int
-bl_setup_layoutcommit(struct pnfs_layout_type *lo,
-		      struct pnfs_layoutcommit_arg *arg)
+bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
+		      struct nfs4_layoutcommit_args *arg)
 {
 	struct nfs_server *nfss = PNFS_NFS_SERVER(lo);
 	struct bl_layoutupdate_data *layoutupdate_data;
@@ -627,11 +627,11 @@ bl_setup_layoutcommit(struct pnfs_layout_type *lo,
 	/* Need to ensure commit is block-size aligned */
 	if (nfss->pnfs_blksize) {
 		u64 mask = nfss->pnfs_blksize - 1;
-		u64 offset = arg->lseg.offset & mask;
+		u64 offset = arg->range.offset & mask;
 
-		arg->lseg.offset -= offset;
-		arg->lseg.length += offset + mask;
-		arg->lseg.length &= ~mask;
+		arg->range.offset -= offset;
+		arg->range.length += offset + mask;
+		arg->range.length &= ~mask;
 	}
 
 	layoutupdate_data = kmalloc(sizeof(struct bl_layoutupdate_data),
@@ -645,16 +645,16 @@ bl_setup_layoutcommit(struct pnfs_layout_type *lo,
 }
 
 static void
-bl_encode_layoutcommit(struct pnfs_layout_type *lo, struct xdr_stream *xdr,
-		       const struct pnfs_layoutcommit_arg *arg)
+bl_encode_layoutcommit(struct pnfs_layout_hdr *lo, struct xdr_stream *xdr,
+		       const struct nfs4_layoutcommit_args *arg)
 {
 	dprintk("%s enter\n", __func__);
 	encode_pnfs_block_layoutupdate(BLK_LO2EXT(lo), xdr, arg);
 }
 
 static void
-bl_cleanup_layoutcommit(struct pnfs_layout_type *lo,
-			struct pnfs_layoutcommit_arg *arg, int status)
+bl_cleanup_layoutcommit(struct pnfs_layout_hdr *lo,
+			struct nfs4_layoutcommit_args *arg, int status)
 {
 	dprintk("%s enter\n", __func__);
 	clean_pnfs_block_layoutupdate(BLK_LO2EXT(lo), arg, status);
@@ -1087,7 +1087,7 @@ bl_write_end_cleanup(struct file *filp, struct pnfs_fsdata *fsdata)
 }
 
 static ssize_t
-bl_get_stripesize(struct pnfs_layout_type *lo)
+bl_get_stripesize(struct pnfs_layout_hdr *lo)
 {
 	dprintk("%s enter\n", __func__);
 	return 0;
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 8931944..ab61a19 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -33,7 +33,6 @@
 #define FS_NFS_NFS4BLOCKLAYOUT_H
 
 #include <linux/nfs_fs.h>
-#include <linux/pnfs_xdr.h> /* Needed by nfs4_pnfs.h */
 #include <linux/nfs4_pnfs.h>
 #include <linux/dm-ioctl.h> /* Needed for struct dm_ioctl*/
 
@@ -176,7 +175,7 @@ static inline int choose_list(enum exstate4 state)
 }
 
 struct pnfs_block_layout {
-	struct pnfs_layout_type bl_layout;
+	struct pnfs_layout_hdr bl_layout;
 	struct pnfs_inval_markings bl_inval; /* tracks INVAL->RW transition */
 	spinlock_t		bl_ext_lock;   /* Protects list manipulation */
 	struct list_head	bl_extents[EXTENT_LISTS]; /* R and RW extents */
@@ -195,7 +194,7 @@ struct bl_layoutupdate_data {
 #define BLK_ID(lo) ((struct block_mount_id *)(PNFS_NFS_SERVER(lo)->pnfs_ld_data))
 
 static inline struct pnfs_block_layout *
-BLK_LO2EXT(struct pnfs_layout_type *lo)
+BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 {
 	return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
@@ -257,8 +256,8 @@ int nfs4_blkdev_put(struct block_device *bdev);
 struct pnfs_block_dev *nfs4_blk_decode_device(struct nfs_server *server,
 					      struct pnfs_device *dev,
 					      struct list_head *sdlist);
-int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
-			       struct nfs4_pnfs_layoutget_res *lgr);
+int nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+			       struct nfs4_layoutget_res *lgr);
 int nfs4_blk_create_block_disk_list(struct list_head *);
 void nfs4_blk_destroy_disk_list(struct list_head *);
 /* blocklayoutdm.c */
@@ -277,9 +276,9 @@ struct pnfs_block_extent *get_extent(struct pnfs_block_extent *be);
 int is_sector_initialized(struct pnfs_inval_markings *marks, sector_t isect);
 int encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 				   struct xdr_stream *xdr,
-				   const struct pnfs_layoutcommit_arg *arg);
+				   const struct nfs4_layoutcommit_args *arg);
 void clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-				   const struct pnfs_layoutcommit_arg *arg,
+				   const struct nfs4_layoutcommit_args *arg,
 				   int status);
 int add_and_merge_extent(struct pnfs_block_layout *bl,
 			 struct pnfs_block_extent *new);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 98ec92b3..e9ea86a 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -152,7 +152,7 @@ out_err:
 }
 
 /* Map deviceid returned by the server to constructed block_device */
-static struct block_device *translate_devid(struct pnfs_layout_type *lo,
+static struct block_device *translate_devid(struct pnfs_layout_hdr *lo,
 					    struct pnfs_deviceid *id)
 {
 	struct block_device *rv = NULL;
@@ -231,8 +231,8 @@ static int verify_extent(struct pnfs_block_extent *be,
 
 /* XDR decode pnfs_block_layout4 structure */
 int
-nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
-			   struct nfs4_pnfs_layoutget_res *lgr)
+nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+			   struct nfs4_layoutget_res *lgr)
 {
 	struct pnfs_block_layout *bl = BLK_LO2EXT(lo);
 	uint32_t *p = (uint32_t *)lgr->layout.buf;
@@ -242,10 +242,10 @@ nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 	struct pnfs_block_extent *be = NULL, *save;
 	uint64_t tmp; /* Used by READSECTOR */
 	struct layout_verification lv = {
-		.mode = lgr->lseg.iomode,
-		.start = lgr->lseg.offset >> 9,
-		.inval = lgr->lseg.offset >> 9,
-		.cowread = lgr->lseg.offset >> 9,
+		.mode = lgr->range.iomode,
+		.start = lgr->range.offset >> 9,
+		.inval = lgr->range.offset >> 9,
+		.cowread = lgr->range.offset >> 9,
 	};
 
 	LIST_HEAD(extents);
@@ -290,7 +290,7 @@ nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
 		be = NULL;
 		goto out_err;
 	}
-	if (lgr->lseg.offset + lgr->lseg.length != lv.start << 9) {
+	if (lgr->range.offset + lgr->range.length != lv.start << 9) {
 		dprintk("%s Final length mismatch\n", __func__);
 		be = NULL;
 		goto out_err;
diff --git a/fs/nfs/blocklayout/extents.c b/fs/nfs/blocklayout/extents.c
index 6c26cd4..20cc863 100644
--- a/fs/nfs/blocklayout/extents.c
+++ b/fs/nfs/blocklayout/extents.c
@@ -738,7 +738,7 @@ find_get_extent_locked(struct pnfs_block_layout *bl, sector_t isect)
 int
 encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 			       struct xdr_stream *xdr,
-			       const struct pnfs_layoutcommit_arg *arg)
+			       const struct nfs4_layoutcommit_args *arg)
 {
 	sector_t start, end;
 	struct pnfs_block_short_extent *lce, *save;
@@ -748,8 +748,8 @@ encode_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
 	__be32 *p, *xdr_start;
 
 	dprintk("%s enter\n", __func__);
-	start = arg->lseg.offset >> 9;
-	end = start + (arg->lseg.length >> 9);
+	start = arg->range.offset >> 9;
+	end = start + (arg->range.length >> 9);
 	dprintk("%s set start=%llu, end=%llu\n",
 		__func__, (u64)start, (u64)end);
 
@@ -922,7 +922,7 @@ set_to_rw(struct pnfs_block_layout *bl, u64 offset, u64 length)
 
 void
 clean_pnfs_block_layoutupdate(struct pnfs_block_layout *bl,
-			      const struct pnfs_layoutcommit_arg *arg,
+			      const struct nfs4_layoutcommit_args *arg,
 			      int status)
 {
 	struct bl_layoutupdate_data *bld = arg->layoutdriver_data;
-- 
1.7.4.1

