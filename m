Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387Ab0LWRaY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 12:30:24 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/15] pnfs: change how lsegs are removed from layout list
Date: Thu, 23 Dec 2010 12:29:48 -0500
Message-Id: <1293125397-30088-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
References: <1293125397-30088-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is to prepare the way for sensible io draining.  Instead of just
removing the lseg from the list, we instead clear the VALID flag
(preventing new io from grabbing references to the lseg) and remove
the reference holding it in the list.  Thus the lseg will be removed
once any io in progress completes and any references still held are
dropped.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/inode.c |    2 +-
 fs/nfs/pnfs.c  |  117 +++++++++++++++++++++++++++++++++++++-------------------
 fs/nfs/pnfs.h  |    8 +++-
 3 files changed, 85 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index e67e31c..43a69da 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1410,9 +1410,9 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
+	pnfs_destroy_layout(NFS_I(inode));
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
-	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
 	/* First call standard NFS clear_inode() code */
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 08313f53..bbca2e5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -211,68 +211,100 @@ static void
 init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
-	kref_init(&lseg->pls_refcount);
+	atomic_set(&lseg->pls_refcount, 1);
+	smp_mb();
+	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
 }
 
-/* Called without i_lock held, as the free_lseg call may sleep */
-static void
-destroy_lseg(struct kref *kref)
+static void free_lseg(struct pnfs_layout_segment *lseg)
 {
-	struct pnfs_layout_segment *lseg =
-		container_of(kref, struct pnfs_layout_segment, pls_refcount);
 	struct inode *ino = lseg->pls_layout->plh_inode;
 
-	dprintk("--> %s\n", __func__);
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 	/* Matched by get_layout_hdr in pnfs_insert_layout */
 	put_layout_hdr(ino);
 }
 
+/* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
+ * could sleep, so must be called outside of the lock.
+ */
 static void
-put_lseg(struct pnfs_layout_segment *lseg)
+put_lseg_locked(struct pnfs_layout_segment *lseg,
+		struct list_head *tmp_list)
 {
-	if (!lseg)
-		return;
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->pls_refcount),
+		test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+	if (atomic_dec_and_test(&lseg->pls_refcount)) {
+		struct inode *ino = lseg->pls_layout->plh_inode;
 
-	dprintk("%s: lseg %p ref %d\n", __func__, lseg,
-		atomic_read(&lseg->pls_refcount.refcount));
-	kref_put(&lseg->pls_refcount, destroy_lseg);
+		BUG_ON(test_bit(NFS_LSEG_VALID, &lseg->pls_flags));
+		list_del(&lseg->pls_list);
+		if (list_empty(&lseg->pls_layout->plh_segs)) {
+			struct nfs_client *clp;
+
+			clp = NFS_SERVER(ino)->nfs_client;
+			spin_lock(&clp->cl_lock);
+			/* List does not take a reference, so no need for put here */
+			list_del_init(&lseg->pls_layout->plh_layouts);
+			spin_unlock(&clp->cl_lock);
+		}
+		list_add(&lseg->pls_list, tmp_list);
+	}
 }
 
-static void
-pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo, struct list_head *tmp_list)
+static bool
+should_free_lseg(u32 lseg_iomode, u32 recall_iomode)
+{
+	return (recall_iomode == IOMODE_ANY ||
+		lseg_iomode == recall_iomode);
+}
+
+static void mark_lseg_invalid(struct pnfs_layout_segment *lseg,
+			      struct list_head *tmp_list)
+{
+	if (test_and_clear_bit(NFS_LSEG_VALID, &lseg->pls_flags)) {
+		/* Remove the reference keeping the lseg in the
+		 * list.  It will now be removed when all
+		 * outstanding io is finished.
+		 */
+		put_lseg_locked(lseg, tmp_list);
+	}
+}
+
+/* Returns false if no lsegs match, true otherwise */
+static bool
+mark_matching_lsegs_invalid(struct pnfs_layout_hdr *lo,
+			    struct list_head *tmp_list,
+			    u32 iomode)
 {
 	struct pnfs_layout_segment *lseg, *next;
-	struct nfs_client *clp;
+	bool rv = false;
 
 	dprintk("%s:Begin lo %p\n", __func__, lo);
 
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list) {
-		dprintk("%s: freeing lseg %p\n", __func__, lseg);
-		list_move(&lseg->pls_list, tmp_list);
-	}
-	clp = NFS_SERVER(lo->plh_inode)->nfs_client;
-	spin_lock(&clp->cl_lock);
-	/* List does not take a reference, so no need for put here */
-	list_del_init(&lo->plh_layouts);
-	spin_unlock(&clp->cl_lock);
-
+	list_for_each_entry_safe(lseg, next, &lo->plh_segs, pls_list)
+		if (should_free_lseg(lseg->pls_range.iomode, iomode)) {
+			dprintk("%s: freeing lseg %p iomode %d "
+				"offset %llu length %llu\n", __func__,
+				lseg, lseg->pls_range.iomode, lseg->pls_range.offset,
+				lseg->pls_range.length);
+			mark_lseg_invalid(lseg, tmp_list);
+			rv = true;
+		}
 	dprintk("%s:Return\n", __func__);
+	return rv;
 }
 
 static void
-pnfs_free_lseg_list(struct list_head *tmp_list)
+pnfs_free_lseg_list(struct list_head *free_me)
 {
-	struct pnfs_layout_segment *lseg;
+	struct pnfs_layout_segment *lseg, *tmp;
 
-	while (!list_empty(tmp_list)) {
-		lseg = list_entry(tmp_list->next, struct pnfs_layout_segment,
-				pls_list);
-		dprintk("%s calling put_lseg on %p\n", __func__, lseg);
+	list_for_each_entry_safe(lseg, tmp, free_me, pls_list) {
 		list_del(&lseg->pls_list);
-		put_lseg(lseg);
+		free_lseg(lseg);
 	}
 }
 
@@ -285,7 +317,8 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
-		pnfs_clear_lseg_list(lo, &tmp_list);
+		set_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags);
+		mark_matching_lsegs_invalid(lo, &tmp_list, IOMODE_ANY);
 		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
 		put_layout_hdr_locked(lo);
 	}
@@ -477,9 +510,12 @@ pnfs_find_alloc_layout(struct inode *ino)
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
 	assert_spin_locked(&ino->i_lock);
-	if (nfsi->layout)
-		return nfsi->layout;
-
+	if (nfsi->layout) {
+		if (test_bit(NFS_LAYOUT_DESTROYED, &nfsi->layout->plh_flags))
+			return NULL;
+		else
+			return nfsi->layout;
+	}
 	spin_unlock(&ino->i_lock);
 	new = alloc_init_layout_hdr(ino);
 	spin_lock(&ino->i_lock);
@@ -520,7 +556,8 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
 
 	assert_spin_locked(&lo->plh_inode->i_lock);
 	list_for_each_entry(lseg, &lo->plh_segs, pls_list) {
-		if (is_matching_lseg(lseg, iomode)) {
+		if (test_bit(NFS_LSEG_VALID, &lseg->pls_flags) &&
+		    is_matching_lseg(lseg, iomode)) {
 			ret = lseg;
 			break;
 		}
@@ -529,7 +566,7 @@ pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
 	}
 
 	dprintk("%s:Return lseg %p ref %d\n",
-		__func__, ret, ret ? atomic_read(&ret->pls_refcount.refcount) : 0);
+		__func__, ret, ret ? atomic_read(&ret->pls_refcount) : 0);
 	return ret;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1093720..787253e 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,10 +30,15 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+enum {
+	NFS_LSEG_VALID = 0,	/* cleared when lseg is recalled/returned */
+};
+
 struct pnfs_layout_segment {
 	struct list_head pls_list;
 	struct pnfs_layout_range pls_range;
-	struct kref pls_refcount;
+	atomic_t pls_refcount;
+	unsigned long pls_flags;
 	struct pnfs_layout_hdr *pls_layout;
 };
 
@@ -44,6 +49,7 @@ struct pnfs_layout_segment {
 enum {
 	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
 	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
+	NFS_LAYOUT_DESTROYED,		/* no new use of layout allowed */
 };
 
 /* Per-layout driver specific registration structure */
-- 
1.7.2.1

