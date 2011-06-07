Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:53361 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab1FGR2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:28:16 -0400
Date: Tue, 7 Jun 2011 13:28:15 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 21/88] pnfsblock: lseg alloc and free
Message-ID: <b181c80c9a43c6a64664364dc0616c81fbe66c9e.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   29 +++++++++++++++++++++++++++--
 fs/nfs/blocklayout/blocklayout.h    |    3 +++
 fs/nfs/blocklayout/blocklayoutdev.c |    9 +++++++++
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index fb06f3a..f54e9a9 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -145,15 +145,40 @@ static void
 bl_free_lseg(struct pnfs_layout_segment *lseg)
 {
 	dprintk("%s enter\n", __func__);
-	return;
+	kfree(lseg);
 }
 
+/* Because the generic infrastructure does not correctly merge layouts,
+ * we pretty much ignore lseg, and store all data layout wide, so we
+ * can correctly merge.  Eventually we should push some correct merge
+ * behavior up to the generic code, as the current behavior tends to
+ * cause lots of unnecessary overlapping LAYOUTGET requests.
+ */
 static struct pnfs_layout_segment *
 bl_alloc_lseg(struct pnfs_layout_type *lo,
 	      struct nfs4_pnfs_layoutget_res *lgr)
 {
+	struct pnfs_layout_segment *lseg;
+	int status;
+
 	dprintk("%s enter\n", __func__);
-	return NULL;
+	lseg = kzalloc(sizeof(*lseg) + 0, GFP_KERNEL);
+	if (!lseg)
+		return NULL;
+	status = nfs4_blk_process_layoutget(lo, lgr);
+	if (status) {
+		/* We don't want to call the full-blown bl_free_lseg,
+		 * since on error extents were not touched.
+		 */
+		/* STUB - we really want to distinguish between 2 error
+		 * conditions here.  This lseg failed, but lo data structures
+		 * are OK, or we hosed the lo data structures.  The calling
+		 * code probably needs to distinguish this too.
+		 */
+		kfree(lseg);
+		return ERR_PTR(status);
+	}
+	return lseg;
 }
 
 static int
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 4e6f8fc..bcf85be 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -142,6 +142,7 @@ struct pnfs_block_layout {
 	sector_t		bl_blocksize;  /* Server blocksize in sectors */
 };
 
+#define BLK_LSEG2EXT(lseg) ((struct pnfs_block_layout *)lseg->layout->ld_data)
 #define BLK_LO2EXT(lo) ((struct pnfs_block_layout *)lo->ld_data)
 
 uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
@@ -183,6 +184,8 @@ int nfs4_blkdev_put(struct block_device *bdev);
 struct pnfs_block_dev *nfs4_blk_decode_device(struct super_block *sb,
 					      struct pnfs_device *dev,
 					      struct list_head *sdlist);
+int nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
+			       struct nfs4_pnfs_layoutget_res *lgr);
 int nfs4_blk_create_scsi_disk_list(struct list_head *);
 void nfs4_blk_destroy_disk_list(struct list_head *);
 /* blocklayoutdm.c */
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 0ea44aa..818cc1c 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -553,3 +553,12 @@ nfs4_blk_decode_device(struct super_block *sb,
 	kfree(vols);
 	return rv;
 }
+
+/* XDR decode pnfs_block_layout4 structure */
+int
+nfs4_blk_process_layoutget(struct pnfs_layout_type *lo,
+			   struct nfs4_pnfs_layoutget_res *lgr)
+{
+	/* STUB */
+	return -EIO;
+}
-- 
1.7.4.1

