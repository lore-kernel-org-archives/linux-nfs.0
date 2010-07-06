From: andros@netapp.com
Subject: [PATCH 3/5] SQUASHME pnfs-submit: remove pnfs_destroy_inode
Date: Tue,  6 Jul 2010 17:17:00 -0400
Message-ID: <1278451022-2889-4-git-send-email-andros@netapp.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
 <1278451022-2889-2-git-send-email-andros@netapp.com>
 <1278451022-2889-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752366Ab0GFURO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:14 -0400
In-Reply-To: <1278451022-2889-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Move WARN_ONs and list check into pnfs_layout_destroy under the i_lock

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c |   18 +-----------------
 fs/nfs/pnfs.c  |    9 +++++++++
 fs/nfs/pnfs.h  |    4 ++++
 3 files changed, 14 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index fa310b1..229cdab 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1379,27 +1379,11 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 	return &nfsi->vfs_inode;
 }
 
-static void pnfs_destroy_inode(struct nfs_inode *nfsi)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (!list_empty(&nfsi->layout.segs))
-		pnfs_destroy_layout(nfsi);
-
-	WARN_ON(!list_empty(&nfsi->layout.segs));
-	if (nfsi->layout.refcount)
-		printk("%s: WARNING: layout.refcount %d\n", __func__,
-			nfsi->layout.refcount);
-	WARN_ON(nfsi->layout.refcount);
-	WARN_ON(!list_empty(&nfsi->layout.lo_layouts));
-	WARN_ON(nfsi->layout.ld_data);
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 void nfs_destroy_inode(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	pnfs_destroy_inode(nfsi);
+	pnfs_destroy_layout(nfsi);
 	kmem_cache_free(nfs_inode_cachep, nfsi);
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index baa3de7..fb9374b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -379,6 +379,15 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	lo = grab_current_layout(nfsi);
 	if (lo) {
 		pnfs_free_layout(lo, &range);
+		WARN_ON(!list_empty(&nfsi->layout.segs));
+		WARN_ON(!list_empty(&nfsi->layout.lo_layouts));
+		WARN_ON(nfsi->layout.ld_data);
+
+		if (nfsi->layout.refcount != 1)
+			printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
+				__func__, nfsi->layout.refcount);
+		WARN_ON(nfsi->layout.refcount != 1);
+
 		put_layout(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c60eff6..9b0fed4 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -190,6 +190,10 @@ static inline void pnfs_update_layout(struct inode *ino,
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
+{
+}
+
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
 {
 }
-- 
1.6.6

