Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48989 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185Ab0HMVc0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:26 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 25/50] pnfs_submit: layoutcommit helper functions
Date: Fri, 13 Aug 2010 17:31:37 -0400
Message-Id: <1281735122-1496-26-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-25-git-send-email-andros@netapp.com>
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
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/inode.c            |    4 ++
 fs/nfs/pnfs.c             |  119 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             |    4 ++
 include/linux/nfs4_pnfs.h |   13 +++++
 include/linux/pnfs_xdr.h  |   33 ++++++++++++
 5 files changed, 173 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5e355de..97fb2d1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1577,6 +1577,7 @@ out:
 #endif
 #ifdef CONFIG_NFS_V4_1
 out00:
+	pnfs_uninitialize();
 #endif /* CONFIG_NFS_V4_1 */
 	nfs_destroy_directcache();
 out0:
@@ -1611,6 +1612,9 @@ static void __exit exit_nfs_fs(void)
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
+#ifdef CONFIG_NFS_V4_1
+	pnfs_uninitialize();
+#endif
 	unregister_nfs_fs();
 	nfs_fs_proc_exit();
 	nfsiod_stop();
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 33be484..96d379d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -72,6 +72,23 @@ static spinlock_t pnfs_spinlock = __SPIN_LOCK_UNLOCKED(pnfs_spinlock);
  * pnfs_modules_tbl holds all pnfs modules
  */
 static struct list_head	pnfs_modules_tbl;
+static struct kmem_cache *pnfs_cachep;
+static mempool_t *pnfs_layoutcommit_mempool;
+
+static inline struct pnfs_layoutcommit_data *pnfs_layoutcommit_alloc(void)
+{
+	struct pnfs_layoutcommit_data *p =
+			mempool_alloc(pnfs_layoutcommit_mempool, GFP_NOFS);
+	if (p)
+		memset(p, 0, sizeof(*p));
+
+	return p;
+}
+
+void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *p)
+{
+	mempool_free(p, pnfs_layoutcommit_mempool);
+}
 
 /*
  * struct pnfs_module - One per pNFS device module.
@@ -86,10 +103,31 @@ pnfs_initialize(void)
 {
 	INIT_LIST_HEAD(&pnfs_modules_tbl);
 
+	pnfs_cachep = kmem_cache_create("pnfs_layoutcommit_data",
+					sizeof(struct pnfs_layoutcommit_data),
+					0, SLAB_HWCACHE_ALIGN, NULL);
+	if (pnfs_cachep == NULL)
+		return -ENOMEM;
+
+	pnfs_layoutcommit_mempool = mempool_create(MIN_POOL_LC,
+						   mempool_alloc_slab,
+						   mempool_free_slab,
+						   pnfs_cachep);
+	if (pnfs_layoutcommit_mempool == NULL) {
+		kmem_cache_destroy(pnfs_cachep);
+		return -ENOMEM;
+	}
+
 	pnfs_initialized = 1;
 	return 0;
 }
 
+void pnfs_uninitialize(void)
+{
+	mempool_destroy(pnfs_layoutcommit_mempool);
+	kmem_cache_destroy(pnfs_cachep);
+}
+
 /* search pnfs_modules_tbl for right pnfs module */
 static int
 find_pnfs(u32 id, struct pnfs_module **module) {
@@ -105,6 +143,52 @@ find_pnfs(u32 id, struct pnfs_module **module) {
 	return 0;
 }
 
+/* Set lo_cred to indicate we require a layoutcommit
+ * If we don't even have a layout, we don't need to commit it.
+ */
+void
+pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx)
+{
+	dprintk("%s: has_layout=%d ctx=%p\n", __func__, has_layout(nfsi), ctx);
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	if (has_layout(nfsi) &&
+	    !test_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->layout->pnfs_layout_state)) {
+		nfsi->layout->lo_cred = get_rpccred(ctx->state->owner->so_cred);
+		__set_bit(NFS_INO_LAYOUTCOMMIT,
+			  &nfsi->layout->pnfs_layout_state);
+		nfsi->change_attr++;
+		spin_unlock(&nfsi->vfs_inode.i_lock);
+		dprintk("%s: Set layoutcommit\n", __func__);
+		return;
+	}
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+}
+
+/* Update last_write_offset for layoutcommit.
+ * TODO: We should only use commited extents, but the current nfs
+ * implementation does not calculate the written range in nfs_commit_done.
+ * We therefore update this field in writeback_done.
+ */
+void
+pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent)
+{
+	loff_t end_pos;
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	if (offset < nfsi->layout->pnfs_write_begin_pos)
+		nfsi->layout->pnfs_write_begin_pos = offset;
+	end_pos = offset + extent - 1; /* I'm being inclusive */
+	if (end_pos > nfsi->layout->pnfs_write_end_pos)
+		nfsi->layout->pnfs_write_end_pos = end_pos;
+	dprintk("%s: Wrote %lu@%lu bpos %lu, epos: %lu\n",
+		__func__,
+		(unsigned long) extent,
+		(unsigned long) offset ,
+		(unsigned long) nfsi->layout->pnfs_write_begin_pos,
+		(unsigned long) nfsi->layout->pnfs_write_end_pos);
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+}
+
 /* Unitialize a mountpoint in a layout driver */
 void
 unmount_pnfs_layoutdriver(struct nfs_server *nfss)
@@ -921,6 +1005,41 @@ out:
 	return status;
 }
 
+/*
+ * Set up the argument/result storage required for the RPC call.
+ */
+static int
+pnfs_layoutcommit_setup(struct inode *inode,
+			struct pnfs_layoutcommit_data *data,
+			loff_t write_begin_pos, loff_t write_end_pos)
+{
+	struct nfs_server *nfss = NFS_SERVER(inode);
+	int result = 0;
+
+	dprintk("--> %s\n", __func__);
+
+	data->args.inode = inode;
+	data->args.fh = NFS_FH(inode);
+	data->args.layout_type = nfss->pnfs_curr_ld->id;
+	data->res.fattr = &data->fattr;
+	nfs_fattr_init(&data->fattr);
+
+	/* TODO: Need to determine the correct values */
+	data->args.time_modify_changed = 0;
+
+	/* Set values from inode so it can be reset
+	 */
+	data->args.lseg.iomode = IOMODE_RW;
+	data->args.lseg.offset = write_begin_pos;
+	data->args.lseg.length = write_end_pos - write_begin_pos + 1;
+	data->args.lastbytewritten =  min(write_end_pos,
+					  i_size_read(inode) - 1);
+	data->args.bitmask = nfss->attr_bitmask;
+	data->res.server = nfss;
+
+	dprintk("<-- %s Status %d\n", __func__, result);
+	return result;
+}
 /* Callback operations for layout drivers.
  */
 struct pnfs_client_operations pnfs_ops = {
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 379aa18..6410617 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -35,6 +35,10 @@ void _pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_initialize(void);
+void pnfs_uninitialize(void);
+void pnfs_layoutcommit_free(struct pnfs_layoutcommit_data *data);
+void pnfs_update_last_write(struct nfs_inode *nfsi, loff_t offset, size_t extent);
+void pnfs_need_layoutcommit(struct nfs_inode *nfsi, struct nfs_open_context *ctx);
 void pnfs_get_layout_done(struct nfs4_pnfs_layoutget *, int rpc_status);
 int pnfs_layout_process(struct nfs4_pnfs_layoutget *lgp);
 void pnfs_layout_release(struct pnfs_layout_type *, struct nfs4_pnfs_layout_segment *range);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 1ed509c..482659f 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -54,6 +54,19 @@ PNFS_LD_IO_OPS(struct pnfs_layout_type *lo)
 	return PNFS_LD(lo)->ld_io_ops;
 }
 
+static inline bool
+has_layout(struct nfs_inode *nfsi)
+{
+	return nfsi->layout != NULL;
+}
+
+#else /* CONFIG_NFS_V4_1 */
+
+static inline bool
+has_layout(struct nfs_inode *nfsi)
+{
+	return false;
+}
 
 #endif /* CONFIG_NFS_V4_1 */
 
diff --git a/include/linux/pnfs_xdr.h b/include/linux/pnfs_xdr.h
index b85320d..4921778 100644
--- a/include/linux/pnfs_xdr.h
+++ b/include/linux/pnfs_xdr.h
@@ -55,6 +55,39 @@ struct nfs4_pnfs_layoutget {
 	int status;
 };
 
+struct pnfs_layoutcommit_arg {
+	nfs4_stateid stateid;
+	__u64 lastbytewritten;
+	__u32 time_modify_changed;
+	struct timespec time_modify;
+	const u32 *bitmask;
+	struct nfs_fh *fh;
+	struct inode *inode;
+
+	/* Values set by layout driver */
+	struct nfs4_pnfs_layout_segment lseg;
+	__u32 layout_type;
+	void *layoutdriver_data;
+	struct nfs4_sequence_args seq_args;
+};
+
+struct pnfs_layoutcommit_res {
+	__u32 sizechanged;
+	__u64 newsize;
+	struct nfs_fattr *fattr;
+	const struct nfs_server *server;
+	struct nfs4_sequence_res seq_res;
+};
+
+struct pnfs_layoutcommit_data {
+	struct rpc_task task;
+	struct rpc_cred *cred;
+	struct nfs_fattr fattr;
+	struct pnfs_layoutcommit_arg args;
+	struct pnfs_layoutcommit_res res;
+	int status;
+};
+
 struct nfs4_pnfs_getdeviceinfo_arg {
 	struct pnfs_device *pdev;
 	struct nfs4_sequence_args seq_args;
-- 
1.6.2.5

