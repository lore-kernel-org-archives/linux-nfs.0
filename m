From: andros@netapp.com
Subject: [PATCH 2/5] SQUASHME pnfs-submit use atomic_dec_and_lock for layout refcounting
Date: Tue, 20 Jul 2010 13:01:20 -0400
Message-ID: <1279645283-9862-3-git-send-email-andros@netapp.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
 <1279645283-9862-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761395Ab0GTRCA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:02:00 -0400
In-Reply-To: <1279645283-9862-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Remove put_layout from under i_lock.
Note: destroy_lseg still calls put_layout under i_lock - fixed in next patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c          |   69 ++++++++++++++++++++---------------------------
 include/linux/nfs_fs.h |    2 +-
 2 files changed, 30 insertions(+), 41 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 77e6671..2cef53e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -322,35 +322,26 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 static inline void
 get_layout(struct pnfs_layout_type *lo)
 {
-	BUG_ON_UNLOCKED_LO(lo);
-	lo->refcount++;
+	atomic_inc(&lo->refcount);
 }
 
-static inline void
-put_layout_locked(struct pnfs_layout_type *lo)
+inline void
+put_layout(struct inode *inode)
 {
-	BUG_ON_UNLOCKED_LO(lo);
-	BUG_ON(lo->refcount <= 0);
+	struct pnfs_layout_type *lo = NFS_I(inode)->layout;
 
-	lo->refcount--;
-	if (!lo->refcount) {
-		struct layoutdriver_io_operations *io_ops = PNFS_LD_IO_OPS(lo);
-		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
+	dprintk("--> %s i_ino %lu, lo %p\n", __func__, inode->i_ino, lo);
 
-		dprintk("%s: freeing layout cache %p\n", __func__, lo);
-		WARN_ON(!list_empty(&lo->lo_layouts));
-		io_ops->free_layout(lo);
-		nfsi->layout = NULL;
-	}
-}
+	BUG_ON(lo == NULL);
+	if (!atomic_dec_and_lock(&lo->refcount, &inode->i_lock))
+		return;
+	WARN_ON(!list_empty(&lo->lo_layouts));
 
-void
-put_layout(struct inode *inode)
-{
-	spin_lock(&inode->i_lock);
-	put_layout_locked(NFS_I(inode)->layout);
+	NFS_I(inode)->layout = NULL;
 	spin_unlock(&inode->i_lock);
 
+	dprintk("%s: freeing layout cache %p\n", __func__, lo);
+	NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->free_layout(lo);
 }
 
 void
@@ -362,41 +353,39 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
 		pnfs_free_layout(lo, range);
+	spin_unlock(&nfsi->vfs_inode.i_lock);
 	/*
 	 * Matched in _pnfs_update_layout for layoutget
 	 * and by get_layout in _pnfs_return_layout for layoutreturn
 	 */
-	put_layout_locked(lo);
-	spin_unlock(&nfsi->vfs_inode.i_lock);
+	put_layout(lo->lo_inode);
 	wake_up_all(&nfsi->lo_waitq);
 }
 
 void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
-	struct pnfs_layout_type *lo;
 	struct nfs4_pnfs_layout_segment range = {
 		.iomode = IOMODE_ANY,
 		.offset = 0,
 		.length = NFS4_MAX_UINT64,
 	};
 
+	if (!has_layout(nfsi))
+		return;
 	spin_lock(&nfsi->vfs_inode.i_lock);
-	lo = nfsi->layout;
-	if (lo) {
-		pnfs_free_layout(lo, &range);
-		WARN_ON(!list_empty(&nfsi->layout->segs));
-		WARN_ON(!list_empty(&nfsi->layout->lo_layouts));
-
-		if (nfsi->layout->refcount != 1)
-			printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
-				__func__, nfsi->layout->refcount);
-		WARN_ON(nfsi->layout->refcount != 1);
-
-		/* Matched by refcount set to 1 in alloc_init_layout */
-		put_layout_locked(lo);
-	}
+	pnfs_free_layout(nfsi->layout, &range);
+	WARN_ON(!list_empty(&nfsi->layout->segs));
+	WARN_ON(!list_empty(&nfsi->layout->lo_layouts));
+
+	if (atomic_read(&nfsi->layout->refcount) != 1)
+		printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
+			__func__, atomic_read(&nfsi->layout->refcount));
+
 	spin_unlock(&nfsi->vfs_inode.i_lock);
+
+	/* Matched by refcount set to 1 in alloc_init_layout */
+	put_layout(&nfsi->vfs_inode);
 }
 
 static inline void
@@ -416,7 +405,7 @@ destroy_lseg(struct kref *kref)
 
 	dprintk("--> %s\n", __func__);
 	/* Matched by get_layout in pnfs_insert_layout */
-	put_layout_locked(lseg->layout);
+	put_layout(lseg->layout->lo_inode);
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
@@ -854,7 +843,7 @@ alloc_init_layout(struct inode *ino)
 			__func__);
 		return NULL;
 	}
-	lo->refcount = 1;
+	atomic_set(&lo->refcount, 1);
 	INIT_LIST_HEAD(&lo->lo_layouts);
 	INIT_LIST_HEAD(&lo->segs);
 	seqlock_init(&lo->seqlock);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 005b3ea..877673e 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -98,7 +98,7 @@ struct nfs_delegation;
 struct posix_acl;
 
 struct pnfs_layout_type {
-	int refcount;
+	atomic_t refcount;
 	struct list_head lo_layouts;	/* other client layouts */
 	struct list_head segs;		/* layout segments list */
 	int roc_iomode;			/* iomode to return on close, 0=none */
-- 
1.6.6

