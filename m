Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435Ab0KDPWy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Nov 2010 11:22:54 -0400
Received: from localhost.localdomain (dnsindia.hq.netapp.com [10.58.52.94] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oA4FMYMV029583
	for <linux-nfs@vger.kernel.org>; Thu, 4 Nov 2010 08:22:44 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/18] pnfs-submit: change pnfs_layout_hdr refcount to atomic_t
Date: Thu,  4 Nov 2010 11:22:22 -0400
Message-Id: <1288884151-11128-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
References: <1288884151-11128-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This is needed because we need to increment the refcount outside
of the i_lock.  In particular, we will need to scan cl_layouts
while holding cl_lock, and grab reference of each lo found.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   50 +++++++++++++++++++++++++++++---------------------
 fs/nfs/pnfs.h |    2 +-
 2 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a2d8d3f..d9a867f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -232,34 +232,42 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
  * pNFS client layout cache
  */
 
+/* Need to hold i_lock if caller does not already hold reference */
 static void
-get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
-	assert_spin_locked(&lo->inode->i_lock);
-	lo->refcount++;
+	atomic_inc(&lo->plh_refcount);
+	smp_mb__after_atomic_inc();
+}
+
+static void
+destroy_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	dprintk("%s: freeing layout cache %p\n", __func__, lo);
+	BUG_ON(!list_empty(&lo->layouts));
+	NFS_I(lo->inode)->layout = NULL;
+	kfree(lo);
 }
 
 static void
 put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
 	assert_spin_locked(&lo->inode->i_lock);
-	BUG_ON(lo->refcount == 0);
-
-	lo->refcount--;
-	if (!lo->refcount) {
-		dprintk("%s: freeing layout cache %p\n", __func__, lo);
-		BUG_ON(!list_empty(&lo->layouts));
-		NFS_I(lo->inode)->layout = NULL;
-		kfree(lo);
-	}
+	BUG_ON(atomic_read(&lo->plh_refcount) == 0);
+	if (atomic_dec_and_test(&lo->plh_refcount))
+		destroy_layout_hdr(lo);
 }
 
 void
 put_layout_hdr(struct inode *inode)
 {
-	spin_lock(&inode->i_lock);
-	put_layout_hdr_locked(NFS_I(inode)->layout);
-	spin_unlock(&inode->i_lock);
+	struct pnfs_layout_hdr *lo = NFS_I(inode)->layout;
+
+	BUG_ON(atomic_read(&lo->plh_refcount) == 0);
+	if (atomic_dec_and_lock(&lo->plh_refcount, &inode->i_lock)) {
+		destroy_layout_hdr(lo);
+		spin_unlock(&inode->i_lock);
+	}
 }
 
 static void
@@ -413,7 +421,7 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 		pnfs_clear_lseg_list(lo, &tmp_list, &range);
 		WARN_ON(!list_empty(&nfsi->layout->segs));
 		WARN_ON(!list_empty(&nfsi->layout->layouts));
-		WARN_ON(nfsi->layout->refcount != 1);
+		WARN_ON(atomic_read(&nfsi->layout->plh_refcount) != 1);
 
 		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
 		put_layout_hdr_locked(lo);
@@ -657,7 +665,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 			if (should_free_lseg(lseg, &arg))
 				mark_lseg_invalid(lseg, &tmp_list);
 		/* Reference matched in nfs4_layoutreturn_release */
-		get_layout_hdr_locked(lo);
+		get_layout_hdr(lo);
 		spin_unlock(&ino->i_lock);
 		pnfs_free_lseg_list(&tmp_list);
 
@@ -738,7 +746,7 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
 			__func__, lseg, lseg->range.iomode,
 			lseg->range.offset, lseg->range.length);
 	}
-	get_layout_hdr_locked(lo);
+	get_layout_hdr(lo);
 
 	dprintk("%s:Return\n", __func__);
 }
@@ -751,7 +759,7 @@ alloc_init_layout_hdr(struct inode *ino)
 	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
 	if (!lo)
 		return NULL;
-	lo->refcount = 1;
+	atomic_set(&lo->plh_refcount, 1);
 	INIT_LIST_HEAD(&lo->layouts);
 	INIT_LIST_HEAD(&lo->segs);
 	lo->inode = ino;
@@ -875,7 +883,7 @@ pnfs_update_layout(struct inode *ino,
 	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->plh_flags))
 		goto out_unlock;
 
-	get_layout_hdr_locked(lo); /* Matched in pnfs_layoutget_release */
+	get_layout_hdr(lo); /* Matched in pnfs_layoutget_release */
 	spin_unlock(&ino->i_lock);
 
 	lseg = send_layoutget(lo, ctx, &arg);
@@ -1177,7 +1185,7 @@ pnfs_layoutcommit_inode(struct inode *inode, int sync)
 	pnfs_copy_layout_stateid(&data->args.stateid, nfsi->layout);
 
 	/* Reference for layoutcommit matched in pnfs_layoutcommit_release */
-	get_layout_hdr_locked(NFS_I(inode)->layout);
+	get_layout_hdr(NFS_I(inode)->layout);
 
 	spin_unlock(&inode->i_lock);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 96af66f..e631487 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -92,7 +92,7 @@ struct pnfs_layoutdriver_type {
 };
 
 struct pnfs_layout_hdr {
-	unsigned long		refcount;
+	atomic_t		plh_refcount;
 	struct list_head	layouts;   /* other client layouts */
 	struct list_head	segs;      /* layout segments list */
 	int			roc_iomode;/* return on close iomode, 0=none */
-- 
1.7.2.1

