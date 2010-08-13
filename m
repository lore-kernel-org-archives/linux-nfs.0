Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044Ab0HMVcW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:22 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 21/50] pnfs_submit: layout segment alloc, reference, destroy
Date: Fri, 13 Aug 2010 17:31:33 -0400
Message-Id: <1281735122-1496-22-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-21-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c            |    1 +
 fs/nfs/pnfs.c             |  105 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   14 ++++++
 include/linux/nfs4_pnfs.h |    2 +
 include/linux/nfs_fs.h    |    1 +
 include/linux/pnfs_xdr.h  |    3 +
 6 files changed, 126 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 15cdcb1..ce91e8f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1444,6 +1444,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
 #ifdef CONFIG_NFS_V4_1
+	init_waitqueue_head(&nfsi->lo_waitq);
 	nfsi->layout = NULL;
 #endif /* CONFIG_NFS_V4_1 */
 #endif
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3dc3701..cfee1d6 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -170,6 +170,12 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		return NULL;
 	}
 
+	if (!io_ops->alloc_lseg || !io_ops->free_lseg) {
+		printk(KERN_ERR "%s Layout driver must provide "
+		       "alloc_lseg and free_lseg.\n", __func__);
+		return NULL;
+	}
+
 	pnfs_mod = kmalloc(sizeof(struct pnfs_module), GFP_KERNEL);
 	if (pnfs_mod != NULL) {
 		dprintk("%s Registering id:%u name:%s\n",
@@ -295,6 +301,66 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
 	}
 }
 
+static inline void
+init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
+{
+	INIT_LIST_HEAD(&lseg->fi_list);
+	kref_init(&lseg->kref);
+	lseg->valid = true;
+	lseg->layout = lo;
+}
+
+static void
+destroy_lseg(struct kref *kref)
+{
+	struct pnfs_layout_segment *lseg =
+		container_of(kref, struct pnfs_layout_segment, kref);
+
+	dprintk("--> %s\n", __func__);
+	/* Matched by get_layout in pnfs_insert_layout */
+	put_layout_locked(lseg->layout);
+	PNFS_LD_IO_OPS(lseg->layout)->free_lseg(lseg);
+}
+
+static void
+put_lseg_locked(struct pnfs_layout_segment *lseg)
+{
+	bool do_wake_up;
+	struct nfs_inode *nfsi;
+
+	if (!lseg)
+		return;
+
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->kref.refcount), lseg->valid);
+	do_wake_up = !lseg->valid;
+	nfsi = PNFS_NFS_INODE(lseg->layout);
+	kref_put(&lseg->kref, destroy_lseg);
+	if (do_wake_up)
+		wake_up(&nfsi->lo_waitq);
+}
+
+void
+put_lseg(struct pnfs_layout_segment *lseg)
+{
+	bool do_wake_up;
+	struct nfs_inode *nfsi;
+
+	if (!lseg)
+		return;
+
+	dprintk("%s: lseg %p ref %d valid %d\n", __func__, lseg,
+		atomic_read(&lseg->kref.refcount), lseg->valid);
+	do_wake_up = !lseg->valid;
+	nfsi = PNFS_NFS_INODE(lseg->layout);
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	kref_put(&lseg->kref, destroy_lseg);
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+	if (do_wake_up)
+		wake_up(&nfsi->lo_waitq);
+}
+EXPORT_SYMBOL(put_lseg);
+
 void
 pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
 			const nfs4_stateid *stateid)
@@ -339,13 +405,52 @@ pnfs_layout_from_open_stateid(struct pnfs_layout_type *lo,
 	dprintk("<-- %s\n", __func__);
 }
 
+/*
+ * iomode matching rules:
+ * range	lseg	match
+ * -----	-----	-----
+ * ANY		READ	true
+ * ANY		RW	true
+ * RW		READ	false
+ * RW		RW	true
+ * READ		READ	true
+ * READ		RW	false
+ */
+static inline int
+should_free_lseg(struct pnfs_layout_segment *lseg,
+		   struct nfs4_pnfs_layout_segment *range)
+{
+	return (range->iomode == IOMODE_ANY ||
+		lseg->range.iomode == range->iomode);
+}
+
+static inline bool
+_pnfs_can_return_lseg(struct pnfs_layout_segment *lseg)
+{
+	return atomic_read(&lseg->kref.refcount) == 1;
+}
+
+
 static void
 pnfs_free_layout(struct pnfs_layout_type *lo,
 		 struct nfs4_pnfs_layout_segment *range)
 {
+	struct pnfs_layout_segment *lseg, *next;
 	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
 		__func__, lo, range->offset, range->length, range->iomode);
 
+	BUG_ON_UNLOCKED_LO(lo);
+	list_for_each_entry_safe (lseg, next, &lo->segs, fi_list) {
+		if (!should_free_lseg(lseg, range) ||
+		    !_pnfs_can_return_lseg(lseg))
+			continue;
+		dprintk("%s: freeing lseg %p iomode %d "
+			"offset %llu length %llu\n", __func__,
+			lseg, lseg->range.iomode, lseg->range.offset,
+			lseg->range.length);
+		list_del(&lseg->fi_list);
+		put_lseg_locked(lseg);
+	}
 	if (list_empty(&lo->segs)) {
 		struct nfs_client *clp;
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 1e40a0d..d8de4c1 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -25,6 +25,7 @@
 extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 				   struct pnfs_device *dev);
 /* pnfs.c */
+void put_lseg(struct pnfs_layout_segment *lseg);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
@@ -41,6 +42,11 @@ void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+	kref_get(&lseg->kref);
+}
+
 /* Return true if a layout driver is being used for this mountpoint */
 static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 {
@@ -57,6 +63,14 @@ static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
 
+static inline void get_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
+static inline void put_lseg(struct pnfs_layout_segment *lseg)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b961f97..287a7dc 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -76,6 +76,8 @@ struct layoutdriver_io_operations {
 	 * a set_layout call to set the opaque layout in the layout driver.*/
 	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
 	void (*free_layout) (struct pnfs_layout_type *);
+	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
+	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
 	/* Registration information for a new mounted file system
 	 */
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index e3b11b3..c8b6129 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -211,6 +211,7 @@ struct nfs_inode {
 
 	/* pNFS layout information */
 #if defined(CONFIG_NFS_V4_1)
+	wait_queue_head_t lo_waitq;
 	struct pnfs_layout_type *layout;
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 0f037a6..e6743f3 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -26,6 +26,9 @@ struct nfs4_pnfs_layout_segment {
 	u64 length;
 };
 
+struct nfs4_pnfs_layoutget_res {
+};
+
 struct nfs4_pnfs_getdeviceinfo_arg {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.6.2.5

