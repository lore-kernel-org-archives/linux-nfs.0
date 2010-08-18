Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6955 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab0HROoX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Aug 2010 10:44:23 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 01/11] SQUASHME pnfs-submit: rename pnfs_layout_type 1
Date: Wed, 18 Aug 2010 10:44:08 -0400
Message-Id: <1282142658-21579-2-git-send-email-andros@netapp.com>
In-Reply-To: <1282142658-21579-1-git-send-email-andros@netapp.com>
References: <1282142658-21579-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: layout header alloc,reference, and destroy

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   32 ++++++++++++++++----------------
 fs/nfs/pnfs.h             |    4 ++--
 include/linux/nfs4_pnfs.h |   16 ++++++++--------
 include/linux/nfs_fs.h    |    4 ++--
 4 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 393855e..bf86975 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -57,9 +57,9 @@
 
 static int pnfs_initialized;
 
-static void pnfs_free_layout(struct pnfs_layout_type *lo,
+static void pnfs_free_layout(struct pnfs_layout_hdr *lo,
 			     struct nfs4_pnfs_layout_segment *range);
-static inline void get_layout(struct pnfs_layout_type *lo);
+static inline void get_layout(struct pnfs_layout_hdr *lo);
 
 /* Locking:
  *
@@ -314,14 +314,14 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 #endif /* CONFIG_SMP */
 
 static inline void
-get_layout(struct pnfs_layout_type *lo)
+get_layout(struct pnfs_layout_hdr *lo)
 {
 	BUG_ON_UNLOCKED_LO(lo);
 	lo->refcount++;
 }
 
 static inline void
-put_layout_locked(struct pnfs_layout_type *lo)
+put_layout_locked(struct pnfs_layout_hdr *lo)
 {
 	BUG_ON_UNLOCKED_LO(lo);
 	BUG_ON(lo->refcount <= 0);
@@ -368,7 +368,7 @@ pnfs_layout_release(struct pnfs_layout_type *lo,
 void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
-	struct pnfs_layout_type *lo;
+	struct pnfs_layout_hdr *lo;
 	struct nfs4_pnfs_layout_segment range = {
 		.iomode = IOMODE_ANY,
 		.offset = 0,
@@ -400,10 +400,10 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 void
 pnfs_destroy_all_layouts(struct nfs_client *clp)
 {
-	struct pnfs_layout_type *lo;
+	struct pnfs_layout_hdr *lo;
 
 	while (!list_empty(&clp->cl_layouts)) {
-		lo = list_entry(clp->cl_layouts.next, struct pnfs_layout_type,
+		lo = list_entry(clp->cl_layouts.next, struct pnfs_layout_hdr,
 				lo_layouts);
 		dprintk("%s freeing layout for inode %lu\n", __func__,
 			lo->lo_inode->i_ino);
@@ -472,7 +472,7 @@ put_lseg(struct pnfs_layout_segment *lseg)
 EXPORT_SYMBOL(put_lseg);
 
 void
-pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
+pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			const nfs4_stateid *stateid)
 {
 	write_seqlock(&lo->seqlock);
@@ -481,7 +481,7 @@ pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 }
 
 void
-pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
+pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
 {
 	int seq;
 
@@ -497,7 +497,7 @@ pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
 }
 
 static void
-pnfs_layout_from_open_stateid(struct pnfs_layout_type *lo,
+pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
 			      struct nfs4_state *state)
 {
 	int seq;
@@ -616,7 +616,7 @@ _pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
 
 
 static void
-pnfs_free_layout(struct pnfs_layout_type *lo,
+pnfs_free_layout(struct pnfs_layout_hdr *lo,
 		 struct nfs4_pnfs_layout_segment *range)
 {
 	struct pnfs_layout_segment *lseg, *next;
@@ -833,14 +833,14 @@ pnfs_insert_layout(struct pnfs_layout_type *lo,
 }
 
 /*
- * Each layoutdriver embeds pnfs_layout_type as the first field in it's
+ * Each layoutdriver embeds pnfs_layout_hdr as the first field in it's
  * per-layout type layout cache structure and returns it ZEROed
  * from layoutdriver_io_ops->alloc_layout
  */
-static struct pnfs_layout_type *
+static struct pnfs_layout_hdr *
 alloc_init_layout(struct inode *ino)
 {
-	struct pnfs_layout_type *lo;
+	struct pnfs_layout_hdr *lo;
 	struct layoutdriver_io_operations *io_ops;
 
 	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
@@ -864,11 +864,11 @@ alloc_init_layout(struct inode *ino)
  *
  * ino->i_lock must be taken by the caller.
  */
-static struct pnfs_layout_type *
+static struct pnfs_layout_hdr *
 pnfs_alloc_layout(struct inode *ino)
 {
 	struct nfs_inode *nfsi = NFS_I(ino);
-	struct pnfs_layout_type *new = NULL;
+	struct pnfs_layout_hdr *new = NULL;
 
 	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 80f67c7..7da54fe 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -59,12 +59,12 @@ void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
-void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
+void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
 			     const nfs4_stateid *stateid);
 void pnfs_destroy_layout(struct nfs_inode *);
 void pnfs_destroy_all_layouts(struct nfs_client *);
 void put_layout(struct inode *inode);
-void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
+void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index ef160e6..59a1a12 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -31,31 +31,31 @@ struct pnfs_layoutdriver_type {
 #if defined(CONFIG_NFS_V4_1)
 
 static inline struct nfs_inode *
-PNFS_NFS_INODE(struct pnfs_layout_type *lo)
+PNFS_NFS_INODE(struct pnfs_layout_hdr *lo)
 {
 	return NFS_I(lo->lo_inode);
 }
 
 static inline struct inode *
-PNFS_INODE(struct pnfs_layout_type *lo)
+PNFS_INODE(struct pnfs_layout_hdr *lo)
 {
 	return lo->lo_inode;
 }
 
 static inline struct nfs_server *
-PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
+PNFS_NFS_SERVER(struct pnfs_layout_hdr *lo)
 {
 	return NFS_SERVER(PNFS_INODE(lo));
 }
 
 static inline struct pnfs_layoutdriver_type *
-PNFS_LD(struct pnfs_layout_type *lo)
+PNFS_LD(struct pnfs_layout_hdr *lo)
 {
 	return NFS_SERVER(PNFS_INODE(lo))->pnfs_curr_ld;
 }
 
 static inline struct layoutdriver_io_operations *
-PNFS_LD_IO_OPS(struct pnfs_layout_type *lo)
+PNFS_LD_IO_OPS(struct pnfs_layout_hdr *lo)
 {
 	return PNFS_LD(lo)->ld_io_ops;
 }
@@ -94,7 +94,7 @@ struct pnfs_layout_segment {
 	struct nfs4_pnfs_layout_segment range;
 	struct kref kref;
 	bool valid;
-	struct pnfs_layout_type *layout;
+	struct pnfs_layout_hdr *layout;
 	struct nfs4_deviceid *deviceid;
 	u8 ld_data[];			/* layout driver private data */
 };
@@ -135,8 +135,8 @@ struct layoutdriver_io_operations {
 	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
 	 * inode specific layout structure.  Each subsequent layoutget operation results in
 	 * a set_layout call to set the opaque layout in the layout driver.*/
-	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
-	void (*free_layout) (struct pnfs_layout_type *);
+	struct pnfs_layout_hdr * (*alloc_layout) (struct inode *inode);
+	void (*free_layout) (struct pnfs_layout_hdr *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 6f67aec..420932a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -104,7 +104,7 @@ struct nfs_delegation;
 
 struct posix_acl;
 
-struct pnfs_layout_type {
+struct pnfs_layout_hdr {
 	int refcount;
 	struct list_head lo_layouts;	/* other client layouts */
 	struct list_head segs;		/* layout segments list */
@@ -212,7 +212,7 @@ struct nfs_inode {
 	/* pNFS layout information */
 #if defined(CONFIG_NFS_V4_1)
 	wait_queue_head_t lo_waitq;
-	struct pnfs_layout_type *layout;
+	struct pnfs_layout_hdr *layout;
 	time_t pnfs_layout_suspend;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
-- 
1.6.2.5

