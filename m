Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753237Ab0LWMr7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Dec 2010 07:47:59 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/15] pnfs: change lo refcounting to atomic_t
Date: Thu, 23 Dec 2010 07:47:42 -0500
Message-Id: <1293108466-31768-12-git-send-email-iisaman@netapp.com>
In-Reply-To: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
References: <1293108466-31768-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This will be required to allow us to grab reference outside of i_lock.
While we are at it, make put_layout_hdr take the same argument as all the
related functions.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   48 ++++++++++++++++++++++++++----------------------
 fs/nfs/pnfs.h |    4 ++--
 2 files changed, 28 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 18f9ddc..5a2ca98 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -177,34 +177,38 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
  * pNFS client layout cache
  */
 
+/* Need to hold i_lock if caller does not already hold reference */
 static void
-get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	lo->plh_refcount++;
+	atomic_inc(&lo->plh_refcount);
 }
 
 static void
-put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	assert_spin_locked(&lo->plh_inode->i_lock);
-	BUG_ON(lo->plh_refcount == 0);
+	dprintk("%s: freeing layout cache %p\n", __func__, lo);
+	BUG_ON(!list_empty(&lo->plh_layouts));
+	NFS_I(lo->plh_inode)->layout = NULL;
+	kfree(lo);
+}
 
-	lo->plh_refcount--;
-	if (!lo->plh_refcount) {
-		dprintk("%s: freeing layout cache %p\n", __func__, lo);
-		BUG_ON(!list_empty(&lo->plh_layouts));
-		NFS_I(lo->plh_inode)->layout = NULL;
-		kfree(lo);
-	}
+static void
+put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+{
+	if (atomic_dec_and_test(&lo->plh_refcount))
+		destroy_layout_hdr(lo);
 }
 
 void
-put_layout_hdr(struct inode *inode)
+put_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	spin_lock(&inode->i_lock);
-	put_layout_hdr_locked(NFS_I(inode)->layout);
-	spin_unlock(&inode->i_lock);
+	struct inode *inode = lo->plh_inode;
+
+	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
+		destroy_layout_hdr(lo);
+		spin_unlock(&inode->i_lock);
+	}
 }
 
 static void
@@ -223,7 +227,7 @@ static void free_lseg(struct pnfs_layout_segment *lseg)
 
 	NFS_SERVER(ino)->pnfs_curr_ld->free_lseg(lseg);
 	/* Matched by get_layout_hdr in pnfs_insert_layout */
-	put_layout_hdr(ino);
+	put_layout_hdr(NFS_I(ino)->layout);
 }
 
 /* The use of tmp_list is necessary because pnfs_curr_ld->free_lseg
@@ -481,7 +485,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 			__func__, lseg, lseg->pls_range.iomode,
 			lseg->pls_range.offset, lseg->pls_range.length);
 	}
-	get_layout_hdr_locked(lo);
+	get_layout_hdr(lo);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -494,7 +498,7 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
 	if (!lo)
 		return NULL;
-	lo->plh_refcount = 1;
+	atomic_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->plh_layouts);
 	INIT_LIST_HEAD(&lo->plh_segs);
 	lo->plh_inode = ino;
@@ -609,7 +613,7 @@ pnfs_update_layout(struct inode *ino,
 		goto out_unlock;
 	atomic_inc(&lo->plh_outstanding);
 
-	get_layout_hdr_locked(lo);
+	get_layout_hdr(lo);
 	if (list_empty(&lo->plh_segs)) {
 		/* The lo must be on the clp list if there is any
 		 * chance of a CB_LAYOUTRECALL(FILE) coming in.
@@ -632,7 +636,7 @@ pnfs_update_layout(struct inode *ino,
 		spin_unlock(&ino->i_lock);
 	}
 	atomic_dec(&lo->plh_outstanding);
-	put_layout_hdr(ino);
+	put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
 		nfsi->layout->plh_flags, lseg);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 698380d..8aaab56 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -65,7 +65,7 @@ struct pnfs_layoutdriver_type {
 };
 
 struct pnfs_layout_hdr {
-	unsigned long		plh_refcount;
+	atomic_t		plh_refcount;
 	struct list_head	plh_layouts;   /* other client layouts */
 	struct list_head	plh_segs;      /* layout segments list */
 	nfs4_stateid		plh_stateid;
@@ -147,7 +147,7 @@ void unset_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_layout_process(struct nfs4_layoutget *lgp);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
-void put_layout_hdr(struct inode *inode);
+void put_layout_hdr(struct pnfs_layout_hdr *lo);
 int pnfs_choose_layoutget_stateid(nfs4_stateid *dst,
 				  struct pnfs_layout_hdr *lo,
 				  struct nfs4_state *open_state);
-- 
1.7.2.1

