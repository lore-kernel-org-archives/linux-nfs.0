From: andros@netapp.com
Subject: [PATCH 2/5] SQUASHME pnfs-submit remove pnfs_alloc_init_inode
Date: Tue,  6 Jul 2010 17:16:59 -0400
Message-ID: <1278451022-2889-3-git-send-email-andros@netapp.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
 <1278451022-2889-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30187 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754201Ab0GFURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:14 -0400
In-Reply-To: <1278451022-2889-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Place all layout initialization in nfs4_init_once

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 231cfa3..fa310b1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1361,18 +1361,6 @@ void nfs4_clear_inode(struct inode *inode)
 }
 #endif
 
-static void pnfs_alloc_init_inode(struct nfs_inode *nfsi)
-{
-#ifdef CONFIG_NFS_V4_1
-	nfsi->layout.pnfs_layout_state = 0;
-	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
-	nfsi->layout.roc_iomode = 0;
-	nfsi->layout.lo_cred = NULL;
-	nfsi->layout.pnfs_write_begin_pos = 0;
-	nfsi->layout.pnfs_write_end_pos = 0;
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 struct inode *nfs_alloc_inode(struct super_block *sb)
 {
 	struct nfs_inode *nfsi;
@@ -1388,7 +1376,6 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 #ifdef CONFIG_NFS_V4
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
-	pnfs_alloc_init_inode(nfsi);
 	return &nfsi->vfs_inode;
 }
 
@@ -1430,6 +1417,12 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	INIT_LIST_HEAD(&nfsi->layout.segs);
 	nfsi->layout.refcount = 0;
 	nfsi->layout.ld_data = NULL;
+	nfsi->layout.pnfs_layout_state = 0;
+	memset(&nfsi->layout.stateid, 0, NFS4_STATEID_SIZE);
+	nfsi->layout.roc_iomode = 0;
+	nfsi->layout.lo_cred = NULL;
+	nfsi->layout.pnfs_write_begin_pos = 0;
+	nfsi->layout.pnfs_write_end_pos = 0;
 #endif /* CONFIG_NFS_V4_1 */
 #endif
 }
-- 
1.6.6

