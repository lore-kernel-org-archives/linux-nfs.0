From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 09/10] pnfs-submit: API change: alloc_layout returns layout cache head
Date: Mon, 14 Jun 2010 21:46:14 -0400
Message-ID: <1276566375-24566-10-git-send-email-iisaman@netapp.com>
References: <1276566375-24566-1-git-send-email-iisaman@netapp.com>
 <1276566375-24566-2-git-send-email-iisaman@netapp.com>
 <1276566375-24566-3-git-send-email-iisaman@netapp.com>
 <1276566375-24566-4-git-send-email-iisaman@netapp.com>
 <1276566375-24566-5-git-send-email-iisaman@netapp.com>
 <1276566375-24566-6-git-send-email-iisaman@netapp.com>
 <1276566375-24566-7-git-send-email-iisaman@netapp.com>
 <1276566375-24566-8-git-send-email-iisaman@netapp.com>
 <1276566375-24566-9-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:52265 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932179Ab0FOO3E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jun 2010 10:29:04 -0400
Received: from localhost.localdomain (netapp-61.citi.umich.edu [141.212.112.250])
	by citi.umich.edu (Postfix) with ESMTP id 6F3981816A
	for <linux-nfs@vger.kernel.org>; Tue, 15 Jun 2010 10:20:11 -0400 (EDT)
In-Reply-To: <1276566375-24566-9-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

pnfs_layout_type (to be renamed later) is the head of the inode layout
segment cache. Embed the layout cache head struct in the per layout cache
head struct and allocate them both in the alloc_layout
layoutdriver_io_operation.

This requires layout drivers to change their alloc/free_layout routines.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c             |   21 +++++----------------
 include/linux/nfs4_pnfs.h |    8 +-------
 include/linux/nfs_fs.h    |    1 -
 3 files changed, 6 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 943519b..edffee3 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -380,10 +380,9 @@ put_layout(struct pnfs_layout_type *lo)
 		struct layoutdriver_io_operations *io_ops =
 			PNFS_LD_IO_OPS(lo);
 
-		dprintk("%s: freeing layout %p\n", __func__, lo->ld_data);
-		io_ops->free_layout(lo->ld_data);
+		dprintk("%s: freeing layout %p\n", __func__, lo);
+		io_ops->free_layout(lo);
 		nfsi->layout = NULL;
-		kfree(lo);
 	}
 }
 
@@ -919,27 +918,17 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 static struct pnfs_layout_type *
 alloc_init_layout(struct inode *ino)
 {
-	void *ld_data;
 	struct pnfs_layout_type *lo;
-	struct layoutdriver_io_operations *io_ops;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_type), GFP_KERNEL);
-	if (!lo)
-		return NULL;
-	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
-	ld_data = io_ops->alloc_layout(ino);
-	if (!ld_data) {
+	/* Layoutdriver must zero (kzalloc) lo_cache fields */
+	lo = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->alloc_layout(ino);
+	if (!lo) {
 		printk(KERN_ERR
 			"%s: out of memory: io_ops->alloc_layout failed\n",
 			__func__);
-		kfree(lo);
 		return NULL;
 	}
-
-	lo->ld_data = ld_data;
-	memset(&lo->stateid, 0, NFS4_STATEID_SIZE);
 	lo->refcount = 1;
-	lo->roc_iomode = 0;
 	lo->lo_inode = ino;
 	INIT_LIST_HEAD(&lo->lo_layouts);
 	INIT_LIST_HEAD(&lo->segs);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 5885352..dd11022 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -50,12 +50,6 @@ PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
 	return NFS_SERVER(PNFS_INODE(lo));
 }
 
-static inline void *
-PNFS_LD_DATA(struct pnfs_layout_type *lo)
-{
-	return lo->ld_data;
-}
-
 static inline struct pnfs_layoutdriver_type *
 PNFS_LD(struct pnfs_layout_type *lo)
 {
@@ -151,7 +145,7 @@ struct layoutdriver_io_operations {
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
-	void * (*alloc_layout) (struct inode *inode);
+	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
 	void (*free_layout) (void *layoutid);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6b62a53..149051c 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -104,7 +104,6 @@ struct pnfs_layout_type {
 	int roc_iomode;			/* iomode to return on close, 0=none */
 	seqlock_t seqlock;		/* Protects the stateid */
 	nfs4_stateid stateid;
-	void *ld_data;			/* layout driver private data */
 	struct rpc_cred         *lo_cred; /* layoutcommit credential */
 	/* DH: These vars keep track of the maximum write range
 	 * so the values can be used for layoutcommit.
-- 
1.6.6.1

