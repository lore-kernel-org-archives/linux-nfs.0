Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab0HMVcU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:20 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 19/50] pnfs_submit: layout header alloc,reference, and destroy
Date: Fri, 13 Aug 2010 17:31:31 -0400
Message-Id: <1281735122-1496-20-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-19-git-send-email-andros@netapp.com>
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
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

---
 fs/nfs/client.c           |    4 +-
 fs/nfs/inode.c            |    8 ++-
 fs/nfs/nfs4state.c        |    2 +
 fs/nfs/pnfs.c             |  229 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |   22 +++++
 include/linux/nfs4.h      |    6 +
 include/linux/nfs4_pnfs.h |   51 ++++++++++
 include/linux/nfs_fs.h    |   25 +++++
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/pnfs_xdr.h  |    8 ++
 10 files changed, 354 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2e440b6..09ee926 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -156,7 +156,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
-
+#if defined(CONFIG_NFS_V4_1)
+	INIT_LIST_HEAD(&clp->cl_layouts);
+#endif
 	nfs_fscache_get_client_cookie(clp);
 
 	return clp;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 64261ea..15cdcb1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1430,7 +1430,10 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 
 void nfs_destroy_inode(struct inode *inode)
 {
-	kmem_cache_free(nfs_inode_cachep, NFS_I(inode));
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	pnfs_destroy_layout(nfsi);
+	kmem_cache_free(nfs_inode_cachep, nfsi);
 }
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
@@ -1440,6 +1443,9 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
+#ifdef CONFIG_NFS_V4_1
+	nfsi->layout = NULL;
+#endif /* CONFIG_NFS_V4_1 */
 #endif
 }
 
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cedd0cc..506a92f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -53,6 +53,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define OPENOWNER_POOL_SIZE	8
 
@@ -1447,6 +1448,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+			pnfs_destroy_all_layouts(clp);
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dcede52..3dc3701 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -57,6 +57,10 @@
 
 static int pnfs_initialized;
 
+static void pnfs_free_layout(struct pnfs_layout_type *lo,
+			     struct nfs4_pnfs_layout_segment *range);
+static inline void get_layout(struct pnfs_layout_type *lo);
+
 /* Locking:
  *
  * pnfs_spinlock:
@@ -152,6 +156,7 @@ struct pnfs_client_operations*
 pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 {
 	struct pnfs_module *pnfs_mod;
+	struct layoutdriver_io_operations *io_ops = ld_type->ld_io_ops;
 
 	if (!pnfs_initialized) {
 		printk(KERN_ERR "%s Registration failure. "
@@ -159,6 +164,12 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 		return NULL;
 	}
 
+	if (!io_ops || !io_ops->alloc_layout || !io_ops->free_layout) {
+		printk(KERN_ERR "%s Layout driver must provide "
+		       "alloc_layout and free_layout.\n", __func__);
+		return NULL;
+	}
+
 	pnfs_mod = kmalloc(sizeof(struct pnfs_module), GFP_KERNEL);
 	if (pnfs_mod != NULL) {
 		dprintk("%s Registering id:%u name:%s\n",
@@ -191,6 +202,224 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 	}
 }
 
+/*
+ * pNFS client layout cache
+ */
+#if defined(CONFIG_SMP)
+#define BUG_ON_UNLOCKED_INO(ino) \
+	BUG_ON(!spin_is_locked(&ino->i_lock))
+#define BUG_ON_UNLOCKED_LO(lo) \
+	BUG_ON_UNLOCKED_INO(PNFS_INODE(lo))
+#else /* CONFIG_SMP */
+#define BUG_ON_UNLOCKED_INO(lo) do {} while (0)
+#define BUG_ON_UNLOCKED_LO(lo) do {} while (0)
+#endif /* CONFIG_SMP */
+
+static inline void
+get_layout(struct pnfs_layout_type *lo)
+{
+	BUG_ON_UNLOCKED_LO(lo);
+	lo->refcount++;
+}
+
+static inline void
+put_layout_locked(struct pnfs_layout_type *lo)
+{
+	BUG_ON_UNLOCKED_LO(lo);
+	BUG_ON(lo->refcount <= 0);
+
+	lo->refcount--;
+	if (!lo->refcount) {
+		struct layoutdriver_io_operations *io_ops = PNFS_LD_IO_OPS(lo);
+		struct nfs_inode *nfsi = PNFS_NFS_INODE(lo);
+
+		dprintk("%s: freeing layout cache %p\n", __func__, lo);
+		WARN_ON(!list_empty(&lo->lo_layouts));
+		io_ops->free_layout(lo);
+		nfsi->layout = NULL;
+	}
+}
+
+void
+put_layout(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	put_layout_locked(NFS_I(inode)->layout);
+	spin_unlock(&inode->i_lock);
+
+}
+
+void
+pnfs_destroy_layout(struct nfs_inode *nfsi)
+{
+	struct pnfs_layout_type *lo;
+	struct nfs4_pnfs_layout_segment range = {
+		.iomode = IOMODE_ANY,
+		.offset = 0,
+		.length = NFS4_MAX_UINT64,
+	};
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	lo = nfsi->layout;
+	if (lo) {
+		pnfs_free_layout(lo, &range);
+		WARN_ON(!list_empty(&nfsi->layout->segs));
+		WARN_ON(!list_empty(&nfsi->layout->lo_layouts));
+
+		if (nfsi->layout->refcount != 1)
+			printk(KERN_WARNING "%s: layout refcount not=1 %d\n",
+				__func__, nfsi->layout->refcount);
+		WARN_ON(nfsi->layout->refcount != 1);
+
+		/* Matched by refcount set to 1 in alloc_init_layout */
+		put_layout_locked(lo);
+	}
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+}
+
+/*
+ * Called by the state manger to remove all layouts established under an
+ * expired lease.
+ */
+void
+pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+	struct pnfs_layout_type *lo;
+
+	while (!list_empty(&clp->cl_layouts)) {
+		lo = list_entry(clp->cl_layouts.next, struct pnfs_layout_type,
+				lo_layouts);
+		dprintk("%s freeing layout for inode %lu\n", __func__,
+			lo->lo_inode->i_ino);
+		pnfs_destroy_layout(NFS_I(lo->lo_inode));
+	}
+}
+
+void
+pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
+			const nfs4_stateid *stateid)
+{
+	write_seqlock(&lo->seqlock);
+	memcpy(lo->stateid.u.data, stateid->u.data, sizeof(lo->stateid.u.data));
+	write_sequnlock(&lo->seqlock);
+}
+
+void
+pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo)
+{
+	int seq;
+
+	dprintk("--> %s\n", __func__);
+
+	do {
+		seq = read_seqbegin(&lo->seqlock);
+		memcpy(dst->u.data, lo->stateid.u.data,
+		       sizeof(lo->stateid.u.data));
+	} while (read_seqretry(&lo->seqlock, seq));
+
+	dprintk("<-- %s\n", __func__);
+}
+
+static void
+pnfs_layout_from_open_stateid(struct pnfs_layout_type *lo,
+			      struct nfs4_state *state)
+{
+	int seq;
+
+	dprintk("--> %s\n", __func__);
+
+	write_seqlock(&lo->seqlock);
+	if (!memcmp(lo->stateid.u.data, &zero_stateid, NFS4_STATEID_SIZE))
+		do {
+			seq = read_seqbegin(&state->seqlock);
+			memcpy(lo->stateid.u.data, state->stateid.u.data,
+					sizeof(state->stateid.u.data));
+		} while (read_seqretry(&state->seqlock, seq));
+	write_sequnlock(&lo->seqlock);
+	dprintk("<-- %s\n", __func__);
+}
+
+static void
+pnfs_free_layout(struct pnfs_layout_type *lo,
+		 struct nfs4_pnfs_layout_segment *range)
+{
+	dprintk("%s:Begin lo %p offset %llu length %llu iomode %d\n",
+		__func__, lo, range->offset, range->length, range->iomode);
+
+	if (list_empty(&lo->segs)) {
+		struct nfs_client *clp;
+
+		clp = PNFS_NFS_SERVER(lo)->nfs_client;
+		spin_lock(&clp->cl_lock);
+		list_del_init(&lo->lo_layouts);
+		spin_unlock(&clp->cl_lock);
+		pnfs_set_layout_stateid(lo, &zero_stateid);
+	}
+
+	dprintk("%s:Return\n", __func__);
+}
+
+/*
+ * Each layoutdriver embeds pnfs_layout_type as the first field in it's
+ * per-layout type layout cache structure and returns it ZEROed
+ * from layoutdriver_io_ops->alloc_layout
+ */
+static struct pnfs_layout_type *
+alloc_init_layout(struct inode *ino)
+{
+	struct pnfs_layout_type *lo;
+	struct layoutdriver_io_operations *io_ops;
+
+	io_ops = NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops;
+	lo = io_ops->alloc_layout(ino);
+	if (!lo) {
+		printk(KERN_ERR
+			"%s: out of memory: io_ops->alloc_layout failed\n",
+			__func__);
+		return NULL;
+	}
+	lo->refcount = 1;
+	INIT_LIST_HEAD(&lo->lo_layouts);
+	INIT_LIST_HEAD(&lo->segs);
+	seqlock_init(&lo->seqlock);
+	lo->lo_inode = ino;
+	return lo;
+}
+
+/*
+ * Retrieve and possibly allocate the inode layout
+ *
+ * ino->i_lock must be taken by the caller.
+ */
+static struct pnfs_layout_type *
+pnfs_alloc_layout(struct inode *ino)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_type *new = NULL;
+
+	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
+
+	BUG_ON_UNLOCKED_INO(ino);
+	if (likely(nfsi->layout))
+		return nfsi->layout;
+
+	spin_unlock(&ino->i_lock);
+	new = alloc_init_layout(ino);
+	spin_lock(&ino->i_lock);
+
+	if (likely(nfsi->layout == NULL)) {	/* Won the race? */
+		nfsi->layout = new;
+	} else if (new) {
+		/* Reference the layout accross i_lock release and grab */
+		get_layout(nfsi->layout);
+		spin_unlock(&ino->i_lock);
+		NFS_SERVER(ino)->pnfs_curr_ld->ld_io_ops->free_layout(new);
+		spin_lock(&ino->i_lock);
+		put_layout_locked(nfsi->layout);
+	}
+	return nfsi->layout;
+}
+
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f9fb58b..1e40a0d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -28,6 +28,12 @@ extern int nfs4_pnfs_getdeviceinfo(struct nfs_server *server,
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
+void pnfs_set_layout_stateid(struct pnfs_layout_type *lo,
+			     const nfs4_stateid *stateid);
+void pnfs_destroy_layout(struct nfs_inode *);
+void pnfs_destroy_all_layouts(struct nfs_client *);
+void put_layout(struct inode *inode);
+void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_type *lo);
 
 #define PNFS_EXISTS_LDIO_OP(srv, opname) ((srv)->pnfs_curr_ld &&	\
 				     (srv)->pnfs_curr_ld->ld_io_ops &&	\
@@ -35,6 +41,22 @@ int pnfs_initialize(void);
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
+/* Return true if a layout driver is being used for this mountpoint */
+static inline int pnfs_enabled_sb(struct nfs_server *nfss)
+{
+	return nfss->pnfs_curr_ld != NULL;
+}
+
+#else  /* CONFIG_NFS_V4_1 */
+
+static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+}
+
+static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
+{
+}
+
 #endif /* CONFIG_NFS_V4_1 */
 
 #endif /* FS_NFS_PNFS_H */
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 25665cc..06912b0 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -569,6 +569,12 @@ enum pnfs_layouttype {
 	LAYOUT_NFSV4_1_FILES  = 1,
 };
 
+enum pnfs_iomode {
+	IOMODE_READ = 1,
+	IOMODE_RW = 2,
+	IOMODE_ANY = 3,
+};
+
 #endif
 #endif
 
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index dee53f2..b961f97 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -22,10 +22,61 @@ struct pnfs_layoutdriver_type {
 	struct layoutdriver_policy_operations *ld_policy_ops;
 };
 
+#if defined(CONFIG_NFS_V4_1)
+
+static inline struct nfs_inode *
+PNFS_NFS_INODE(struct pnfs_layout_type *lo)
+{
+	return NFS_I(lo->lo_inode);
+}
+
+static inline struct inode *
+PNFS_INODE(struct pnfs_layout_type *lo)
+{
+	return lo->lo_inode;
+}
+
+static inline struct nfs_server *
+PNFS_NFS_SERVER(struct pnfs_layout_type *lo)
+{
+	return NFS_SERVER(PNFS_INODE(lo));
+}
+
+static inline struct pnfs_layoutdriver_type *
+PNFS_LD(struct pnfs_layout_type *lo)
+{
+	return NFS_SERVER(PNFS_INODE(lo))->pnfs_curr_ld;
+}
+
+static inline struct layoutdriver_io_operations *
+PNFS_LD_IO_OPS(struct pnfs_layout_type *lo)
+{
+	return PNFS_LD(lo)->ld_io_ops;
+}
+
+
+#endif /* CONFIG_NFS_V4_1 */
+
+struct pnfs_layout_segment {
+	struct list_head fi_list;
+	struct nfs4_pnfs_layout_segment range;
+	struct kref kref;
+	bool valid;
+	struct pnfs_layout_type *layout;
+	struct nfs4_deviceid *deviceid;
+	u8 ld_data[];			/* layout driver private data */
+};
+
 /* Layout driver I/O operations.
  * Either the pagecache or non-pagecache read/write operations must be implemented
  */
 struct layoutdriver_io_operations {
+	/* Layout information. For each inode, alloc_layout is executed once to retrieve an
+	 * inode specific layout structure.  Each subsequent layoutget operation results in
+	 * a set_layout call to set the opaque layout in the layout driver.*/
+	struct pnfs_layout_type * (*alloc_layout) (struct inode *inode);
+	void (*free_layout) (struct pnfs_layout_type *);
+
 	/* Registration information for a new mounted file system
 	 */
 	int (*initialize_mountpoint) (struct nfs_client *);
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index a0f49a3..e3b11b3 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -104,6 +104,26 @@ struct nfs_delegation;
 
 struct posix_acl;
 
+struct pnfs_layout_type {
+	int refcount;
+	struct list_head lo_layouts;	/* other client layouts */
+	struct list_head segs;		/* layout segments list */
+	int roc_iomode;			/* iomode to return on close, 0=none */
+	seqlock_t seqlock;		/* Protects the stateid */
+	nfs4_stateid stateid;
+	unsigned long pnfs_layout_state;
+	#define NFS_INO_RO_LAYOUT_FAILED 0      /* get ro layout failed stop trying */
+	#define NFS_INO_RW_LAYOUT_FAILED 1      /* get rw layout failed stop trying */
+	#define NFS_INO_LAYOUTCOMMIT     3      /* LAYOUTCOMMIT needed */
+	struct rpc_cred         *lo_cred; /* layoutcommit credential */
+	/* DH: These vars keep track of the maximum write range
+	 * so the values can be used for layoutcommit.
+	 */
+	loff_t                  pnfs_write_begin_pos;
+	loff_t                  pnfs_write_end_pos;
+	struct inode		*lo_inode;
+};
+
 /*
  * nfs fs inode data in memory
  */
@@ -188,6 +208,11 @@ struct nfs_inode {
 	struct nfs_delegation	*delegation;
 	fmode_t			 delegation_state;
 	struct rw_semaphore	rwsem;
+
+	/* pNFS layout information */
+#if defined(CONFIG_NFS_V4_1)
+	struct pnfs_layout_type *layout;
+#endif /* CONFIG_NFS_V4_1 */
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4544b52..8d17e67 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -82,6 +82,7 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
+	struct list_head	cl_layouts;
 	struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index 458ff69..0f037a6 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -12,12 +12,20 @@
 #ifndef LINUX_PNFS_XDR_H
 #define LINUX_PNFS_XDR_H
 
+#define PNFS_LAYOUT_MAXSIZE 4096
 #define NFS4_PNFS_DEVICEID4_SIZE 16
 
 struct pnfs_deviceid {
 	char data[NFS4_PNFS_DEVICEID4_SIZE];
 };
 
+
+struct nfs4_pnfs_layout_segment {
+	u32 iomode;
+	u64 offset;
+	u64 length;
+};
+
 struct nfs4_pnfs_getdeviceinfo_arg {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.6.2.5

