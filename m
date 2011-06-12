Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60707 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754463Ab1FLXo0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:44:26 -0400
Message-Id: <4752592e870fddcabe8a706d0194c405faf8292e.1307921138.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:44:24 -0400
Subject: [PATCH 15/34] pnfsblock: lseg alloc and free
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
[pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Zhang Jingwang <Jingwang.Zhang@emc.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   30 +++++++++++++++++++++++++++++-
 fs/nfs/blocklayout/blocklayout.h    |    6 ++++++
 fs/nfs/blocklayout/blocklayoutdev.c |    8 ++++++++
 3 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index a245e73..88b9d1a 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -115,13 +115,41 @@ bl_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
 static void
 bl_free_lseg(struct pnfs_layout_segment *lseg)
 {
+        dprintk("%s enter\n", __func__);
+        kfree(lseg);
 }
 
+/* Because the generic infrastructure does not correctly merge layouts,
+ * we pretty much ignore lseg, and store all data layout wide, so we
+ * can correctly merge.  Eventually we should push some correct merge
+ * behavior up to the generic code, as the current behavior tends to
+ * cause lots of unnecessary overlapping LAYOUTGET requests.
+ */
 static struct pnfs_layout_segment *
 bl_alloc_lseg(struct pnfs_layout_hdr *lo,
 	      struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
 {
-	return NULL;
+        struct pnfs_layout_segment *lseg;
+        int status;
+
+        dprintk("%s enter\n", __func__);
+        lseg = kzalloc(sizeof(*lseg) + 0, gfp_flags);
+        if (!lseg)
+                return NULL;
+        status = nfs4_blk_process_layoutget(lo, lgr, gfp_flags);
+        if (status) {
+                /* We don't want to call the full-blown bl_free_lseg,
+                 * since on error extents were not touched.
+                 */
+                /* STUB - we really want to distinguish between 2 error
+                 * conditions here.  This lseg failed, but lo data structures
+                 * are OK, or we hosed the lo data structures.  The calling
+                 * code probably needs to distinguish this too.
+                 */
+                kfree(lseg);
+                return ERR_PTR(status);
+        }
+        return lseg;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index e5ee11c..3cd447f 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -94,6 +94,12 @@ BLK_LO2EXT(struct pnfs_layout_hdr *lo)
         return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+static inline struct pnfs_block_layout *
+BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
+{
+        return BLK_LO2EXT(lseg->pls_layout);
+}
+
 /* blocklayoutdev.c */
 struct block_device *nfs4_blkdev_get(dev_t dev);
 int nfs4_blkdev_put(struct block_device *bdev);
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 9a65a66..0fedf50 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -149,3 +149,11 @@ out_err:
 		kfree(msg);
 	return NULL;
 }
+
+int
+nfs4_blk_process_layoutget(struct pnfs_layout_hdr *lo,
+			   struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
+{
+	/* STUB */
+	return -EIO;
+}
-- 
1.7.4.1

