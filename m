Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47235 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752980Ab0I2LLz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:11:55 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 13/15] SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
Date: Wed, 29 Sep 2010 13:11:53 +0200
Message-Id: <1285758713-27193-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

---
 fs/nfs/blocklayout/blocklayout.c |    2 +-
 fs/nfs/blocklayout/blocklayout.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 5dbd9c6..5e50c93 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -619,7 +619,7 @@ static int
 bl_setup_layoutcommit(struct pnfs_layout_hdr *lo,
 		      struct nfs4_layoutcommit_args *arg)
 {
-	struct nfs_server *nfss = PNFS_NFS_SERVER(lo);
+	struct nfs_server *nfss = NFS_SERVER(lo->inode);
 	struct bl_layoutupdate_data *layoutupdate_data;
 
 	dprintk("%s enter\n", __func__);
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index d62e3f9..7db7768 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -191,7 +191,7 @@ struct bl_layoutupdate_data {
 	struct list_head ranges;
 };
 
-#define BLK_ID(lo) ((struct block_mount_id *)(PNFS_NFS_SERVER(lo)->pnfs_ld_data))
+#define BLK_ID(lo) ((struct block_mount_id *)(NFS_SERVER(lo->inode)->pnfs_ld_data))
 
 static inline struct pnfs_block_layout *
 BLK_LO2EXT(struct pnfs_layout_hdr *lo)
-- 
1.7.2.3

