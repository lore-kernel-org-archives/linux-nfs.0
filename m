Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:46657 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753695Ab1GUTel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 15:34:41 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v2 11/25] pnfsblock: lseg alloc and free
Date: Thu, 21 Jul 2011 15:34:11 -0400
Message-Id: <1311276865-29484-12-git-send-email-rees@umich.edu>
In-Reply-To: <1311276865-29484-1-git-send-email-rees@umich.edu>
References: <1311276865-29484-1-git-send-email-rees@umich.edu>
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
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/blocklayout/blocklayout.c    |   36 +++++++++++++++++++++++++++++-----
 fs/nfs/blocklayout/blocklayout.h    |    6 +++++
 fs/nfs/blocklayout/blocklayoutdev.c |    8 +++++++
 3 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 3afe363..1858743 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -115,16 +115,40 @@ static struct pnfs_layout_hdr *bl_alloc_layout_hdr(struct inode *inode,
 	return &bl->bl_layout;
 }
 
-static void
-bl_free_lseg(struct pnfs_layout_segment *lseg)
+static void bl_free_lseg(struct pnfs_layout_segment *lseg)
 {
+	dprintk("%s enter\n", __func__);
+	kfree(lseg);
 }
 
-static struct pnfs_layout_segment *
-bl_alloc_lseg(struct pnfs_layout_hdr *lo,
-	      struct nfs4_layoutget_res *lgr, gfp_t gfp_flags)
+/* We pretty much ignore lseg, and store all data layout wide, so we
+ * can correctly merge.
+ */
+static struct pnfs_layout_segment *bl_alloc_lseg(struct pnfs_layout_hdr *lo,
+						 struct nfs4_layoutget_res *lgr,
+						 gfp_t gfp_flags)
 {
-	return NULL;
+	struct pnfs_layout_segment *lseg;
+	int status;
+
+	dprintk("%s enter\n", __func__);
+	lseg = kzalloc(sizeof(*lseg), gfp_flags);
+	if (!lseg)
+		return ERR_PTR(-ENOMEM);
+	status = nfs4_blk_process_layoutget(lo, lgr, gfp_flags);
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
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 08b4d6f..7dab978 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -96,6 +96,12 @@ static inline struct pnfs_block_layout *BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 	return container_of(lo, struct pnfs_block_layout, bl_layout);
 }
 
+static inline struct pnfs_block_layout *
+BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
+{
+	return BLK_LO2EXT(lseg->pls_layout);
+}
+
 struct bl_dev_msg {
 	int status;
 	uint32_t major, minor;
diff --git a/fs/nfs/blocklayout/blocklayoutdev.c b/fs/nfs/blocklayout/blocklayoutdev.c
index 7e1377f..64da33a 100644
--- a/fs/nfs/blocklayout/blocklayoutdev.c
+++ b/fs/nfs/blocklayout/blocklayoutdev.c
@@ -189,3 +189,11 @@ out:
 	kfree(msg.data);
 	return rv;
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

