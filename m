Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52220 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958Ab1FGReb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:34:31 -0400
Date: Tue, 7 Jun 2011 13:34:29 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 72/88] SQAUSHME: pnfsblock: no PNFS_NFS_SERVER
Message-ID: <e6eb5a784ac623b3ea0a3f2345737976a2a300d2.1307464382.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

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
1.7.4.1

