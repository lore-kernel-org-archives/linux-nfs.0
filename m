Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:44133 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753331Ab1FGRfz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:35:55 -0400
Date: Tue, 7 Jun 2011 13:35:53 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 85/88] SQUASHME: pnfs-block: use pnfs_layout_hdr field prefix
Message-ID: <643e40da3aef3d3ec2b0c12b1ed628ead24a834d.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/blocklayout/blocklayout.c |    2 +-
 fs/nfs/blocklayout/blocklayout.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 161c113..2583b87 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -619,7 +619,7 @@ static int
 bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
 		      struct nfs4_layoutcommit_args *arg)
 {
-	struct nfs_server *nfss = NFS_SERVER(lo->inode);
+	struct nfs_server *nfss = NFS_SERVER(lo->plh_inode);
 	struct bl_layoutupdate_data *layoutupdate_data;
 
 	dprintk("%s enter\n", __func__);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index 9e7bd62..a8198ae 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -191,7 +191,7 @@ struct bl_layoutupdate_data {
 	struct list_head ranges;
 };
 
-#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->inode)->pnfs_ld_data))
+#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->plh_inode)->pnfs_ld_data))
 
 static inline struct pnfs_block_layout *
 BLK_LO2EXT(struct pnfs_layout_hdr *lo)
@@ -202,7 +202,7 @@ BLK_LO2EXT(struct pnfs_layout_hdr *lo)
 static inline struct pnfs_block_layout *
 BLK_LSEG2EXT(struct pnfs_layout_segment *lseg)
 {
-	return BLK_LO2EXT(lseg->layout);
+	return BLK_LO2EXT(lseg->pls_layout);
 }
 
 uint32_t *blk_overflow(uint32_t *p, uint32_t *end, size_t nbytes);
-- 
1.7.4.1

