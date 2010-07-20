From: andros@netapp.com
Subject: [PATCH 3/5] SQUASHME pnfs-submit don't call put_lseg under spin lock
Date: Tue, 20 Jul 2010 13:01:21 -0400
Message-ID: <1279645283-9862-4-git-send-email-andros@netapp.com>
References: <1279645283-9862-1-git-send-email-andros@netapp.com>
 <1279645283-9862-2-git-send-email-andros@netapp.com>
 <1279645283-9862-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761395Ab0GTRCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Jul 2010 13:02:01 -0400
In-Reply-To: <1279645283-9862-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

kfree can be called in destroy_lseg.

Move the spin_lock into pnfs_free_layout.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   89 +++++++++++++++++++--------------------------
 fs/nfs/pnfs.h             |    2 +-
 include/linux/nfs4_pnfs.h |    2 +-
 3 files changed, 40 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2cef53e..cf64f16 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -57,7 +57,7 @@
 
 static int pnfs_initialized;
 
-static void pnfs_free_layout(struct pnfs_layout_type *lo,
+static void pnfs_free_layout(struct inode *inode,
 			     struct nfs4_pnfs_layout_segment *range);
 static inline void get_layout(struct pnfs_layout_type *lo);
 
@@ -350,10 +350,8 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 {
 	struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
 
-	spin_lock(&nfsi->vfs_inode.i_lock);
 	if (range)
-		pnfs_free_layout(lo, range);
-	spin_unlock(&nfsi->vfs_inode.i_lock);
+		pnfs_free_layout(lo->lo_inode, range);
 	/*
 	 * Matched in _pnfs_update_layout for layoutget
 	 * and by get_layout in _pnfs_return_layout for layoutreturn
@@ -373,8 +371,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 
 	if (!has_layout(nfsi))
 		return;
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	pnfs_free_layout(nfsi->layout, &range);
+	pnfs_free_layout(&nfsi->vfs_inode, &range);
 	WARN_ON(!list_empty(&nfsi->layout->segs));
 	WARN_ON(!list_empty(&nfsi->layout->lo_layouts));
 
@@ -382,7 +379,6 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
 			__func__, atomic_read(&nfsi->layout->refcount));
 
-	spin_unlock(&nfsi->vfs_inode.i_lock);
 
 	/* Matched by refcount set to 1 in alloc_init_layout */
 	put_layout(&nfsi->vfs_inode);
@@ -392,59 +388,40 @@ static inline void
 init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->fi_list);
-	kref_init(&lseg->kref);
+	atomic_set(&lseg->refcount, 1);
 	lseg->valid = true;
 	lseg->layout = lo;
 }
 
 static void
-destroy_lseg(struct kref *kref)
+destroy_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct pnfs_layout_segment *lseg =
-		container_of(kref, struct pnfs_layout_segment, kref);
-
 	dprintk("--> %s\n", __func__);
 	/* Matched by get_layout in pnfs_insert_layout */
 	put_layout(lseg->layout->lo_inode);
 	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
 }
 
-static void
-put_lseg_locked(struct pnfs_layout_segment *lseg)
-{
-	bool do_wake_up;
-	struct nfs_inode *nfsi;
-
-	if (!lseg)
-		return;
-
-	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount), lseg->valid);
-	do_wake_up = !lseg->valid;
-	nfsi = PNFS_NFS_INODE(lseg->layout);
-	kref_put(&lseg->kref, destroy_lseg);
-	if (do_wake_up)
-		wake_up(&nfsi->lo_waitq);
-}
-
 void
 put_lseg(struct pnfs_layout_segment *lseg)
 {
 	bool do_wake_up;
-	struct nfs_inode *nfsi;
+	struct inode *inode;
 
 	if (!lseg)
 		return;
 
 	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
-		atomic_read(&lseg->kref.refcount), lseg->valid);
+		atomic_read(&lseg->refcount), lseg->valid);
 	do_wake_up = !lseg->valid;
-	nfsi = PNFS_NFS_INODE(lseg->layout);
-	spin_lock(&nfsi->vfs_inode.i_lock);
-	kref_put(&lseg->kref, destroy_lseg);
-	spin_unlock(&nfsi->vfs_inode.i_lock);
+	inode = lseg->layout->lo_inode;
+
+	if (!atomic_dec_and_lock(&lseg->refcount, &inode->i_lock))
+		return;
+	spin_unlock(&inode->i_lock);
+	destroy_lseg(lseg);
 	if (do_wake_up)
-		wake_up(&nfsi->lo_waitq);
+		wake_up(&NFS_I(inode)->lo_waitq);
 }
 EXPORT_SYMBOL(put_lseg);
 
@@ -588,39 +565,49 @@ has_layout_to_return(struct pnfs_layout_type *lo,
 static inline bool
 _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 {
-	return atomic_read(&lseg->kref.refcount) == 1;
+	return atomic_read(&lseg->refcount) == 1;
 }
 
 
 static void
-pnfs_free_layout(struct pnfs_layout_type *lo,
-		 struct nfs4_pnfs_layout_segment *range)
+pnfs_free_layout(struct inode *inode,
+		struct nfs4_pnfs_layout_segment *range)
 {
 	struct pnfs_layout_segment *lseg, *next;
-	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
-		__func__, lo, range->offset, range->length, range->iomode);
+	struct pnfs_layout_type *lo = NFS_I(inode)->layout;
+	LIST_HEAD(freeme);
 
-	BUG_ON_UNLOCKED_LO(lo);
-	list_for_each_entry_safe (lseg, next, &lo->segs, fi_list) {
+	dprintk("--> %s i_ino %lu lo %p offset %llu length %llu iomode %d\n",
+		__func__, inode->i_ino, lo, range->offset, range->length,
+		range->iomode);
+
+	spin_lock(&inode->i_lock);
+	if (lo == NULL)
+		goto out_unlock;
+
+	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
 		if (!should_free_lseg(lseg, range) ||
 		    !_pnfs_can_return_lseg(lseg))
 			continue;
-		dprintk("%s: freeing lseg %p iomode %d "
+		dprintk("%s: put lseg %p iomode %d "
 			"offset %llu length %llu\n", __func__,
 			lseg, lseg->range.iomode, lseg->range.offset,
 			lseg->range.length);
-		list_del(&lseg->fi_list);
-		put_lseg_locked(lseg);
+		list_move(&lseg->fi_list, &freeme);
 	}
 	if (list_empty(&lo->segs)) {
-		struct nfs_client *clp;
+		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 
-		clp = PNFS_NFS_SERVER(lo)->nfs_client;
 		spin_lock(&clp->cl_lock);
 		list_del_init(&lo->lo_layouts);
 		spin_unlock(&clp->cl_lock);
 		pnfs_set_layout_stateid(lo, &zero_stateid);
 	}
+out_unlock:
+	spin_unlock(&inode->i_lock);
+
+	list_for_each_entry_safe(lseg, next, &freeme, fi_list)
+		put_lseg(lseg);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -640,7 +627,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
 		if (!_pnfs_can_return_lseg(lseg)) {
 			dprintk("%s: wait on lseg %p refcount %d\n",
 				__func__, lseg,
-				atomic_read(&lseg->kref.refcount));
+				atomic_read(&lseg->refcount));
 			ret = true;
 		}
 	}
@@ -916,7 +903,7 @@ out_unlock:
 		NFS_SERVER(inode)->pnfs_curr_ld->ld_io_ops->free_layout(new);
 out:
 	dprintk("<-- %s lseg %p ref %d valid %d\n",
-		__func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0,
+		__func__, ret, ret ? atomic_read(&ret->refcount) : 0,
 		ret ? ret->valid : 0);
 	return ret;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1d16049..9498e4e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -84,7 +84,7 @@ static inline int lo_fail_bit(u32 iomode)
 
 static inline void get_lseg(struct pnfs_layout_segment *lseg)
 {
-	kref_get(&lseg->kref);
+	atomic_inc(&lseg->refcount);
 }
 
 /* Return true if a layout driver is being used for this mountpoint */
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 52fe384..a2239a5 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -94,7 +94,7 @@ layoutcommit_needed(struct nfs_inode *nfsi)
 struct pnfs_layout_segment {
 	struct list_head fi_list;
 	struct nfs4_pnfs_layout_segment range;
-	struct kref kref;
+	atomic_t refcount;
 	bool valid;
 	struct pnfs_layout_type *layout;
 	struct nfs4_deviceid *deviceid;
-- 
1.6.6

