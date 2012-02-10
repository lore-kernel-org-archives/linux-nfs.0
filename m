Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11202 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760264Ab2BJWCa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:30 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 18/21] NFS: Use the IS_ENABLED macro for CONFIG_NFS_V4
Date: Fri, 10 Feb 2012 17:02:02 -0500
Message-Id: <1328911325-1566-18-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Once v4 is a module CONFIG_NFS_V4_MODULE may be set instead of
CONFIG_NFS_V4.  This code doesn't care if it's a module or built in, but
it does need to know if any form of the option is enabled.  This patch
should probably be squashed with the next one before the end...

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h         |    2 +-
 fs/nfs/client.c           |    6 +++---
 fs/nfs/delegation.h       |    2 +-
 fs/nfs/dir.c              |    4 ++--
 fs/nfs/direct.c           |    2 +-
 fs/nfs/file.c             |    2 +-
 fs/nfs/inode.c            |    8 ++++----
 fs/nfs/internal.h         |   14 +++++++-------
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/super.c            |   20 ++++++++++----------
 fs/nfs/write.c            |    8 ++++----
 include/linux/nfs_fs.h    |    6 +++---
 include/linux/nfs_fs_sb.h |    6 +++---
 include/linux/nfs_idmap.h |    2 +-
 include/linux/nfs_xdr.h   |    4 ++--
 16 files changed, 45 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c89d3b9..8e6cf9f 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -191,7 +191,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_process_state *cps);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b709c38..6743a28 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -59,7 +59,7 @@ static LIST_HEAD(nfs_versions);
 LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static DEFINE_IDR(cb_ident_idr); /* Protected by nfs_client_lock */
 
 /*
@@ -217,7 +217,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	return nfs_mod->alloc_client(cl_init);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void pnfs_init_server(struct nfs_server *server)
 {
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
@@ -1153,7 +1153,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(nfs_create_server);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 /*
  * NFSv4.0 callback thread helper
  *
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 0b388d7..29d3502 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -8,7 +8,7 @@
 #ifndef FS_NFS_DELEGATION_H
 #define FS_NFS_DELEGATION_H
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 #include "nfs.h"
 /*
  * NFSv4 delegation
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 07ed31d..840a811 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -81,7 +81,7 @@ const struct address_space_operations nfs_dir_aops = {
 	.freepage = nfs_readdir_clear_array,
 };
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 static struct dentry *nfs_atomic_lookup(struct inode *, struct dentry *, struct nameidata *);
 static int nfs_open_create(struct inode *dir, struct dentry *dentry, umode_t mode, struct nameidata *nd);
@@ -1301,7 +1301,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(nfs_lookup);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_open_revalidate(struct dentry *, struct nameidata *);
 
 const struct dentry_operations nfs4_dentry_operations = {
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 185e177..7aa353c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -460,7 +460,7 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 	}
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index c678c00..5158bd3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -859,7 +859,7 @@ const struct file_operations nfs_file_operations = {
 };
 EXPORT_SYMBOL_GPL(nfs_file_operations);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static int
 nfs4_file_open(struct inode *inode, struct file *filp)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 2f48355..cb645e3f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1469,7 +1469,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);
 #endif
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
@@ -1490,7 +1490,7 @@ EXPORT_SYMBOL_GPL(nfs_destroy_inode);
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	INIT_LIST_HEAD(&nfsi->open_states);
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
@@ -1637,7 +1637,7 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	init_nfs_v4();
 #endif
 	return 0;
@@ -1670,7 +1670,7 @@ out9:
 
 static void __exit exit_nfs_fs(void)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	exit_nfs_v4();
 #endif
 	nfs_destroy_directcache();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4ea1b93..d66e660 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -181,13 +181,13 @@ static inline void nfs_fs_proc_exit(void)
 {
 }
 #endif
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern spinlock_t nfs_client_lock;
 extern struct list_head nfs_client_list;
 #endif
 
 /* nfs4namespace.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
 #else
 static inline
@@ -224,7 +224,7 @@ extern int nfs3_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
 /* nfs4xdr.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs4_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 #endif
@@ -234,7 +234,7 @@ extern const u32 nfs41_maxwrite_overhead;
 #endif
 
 /* nfs4proc.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct rpc_procinfo nfs4_procedures[];
 void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
@@ -263,7 +263,7 @@ extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
 extern struct file_system_type nfs_xdev_fs_type;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
@@ -279,14 +279,14 @@ extern void nfs_sb_deactive(struct super_block *sb);
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
 extern struct vfsmount *nfs_d_automount(struct path *path);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 #endif
 
 /* getroot.c */
 extern struct dentry *nfs_get_root(struct super_block *, struct nfs_fh *,
 				   const char *);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
 				    const char *);
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 31c3fcb..289560d 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -120,7 +120,7 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9a27673..6096a8d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -9,7 +9,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 #include "nfs.h"
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c8fcec5..427865f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -320,7 +320,7 @@ int __init register_nfs_fs(void)
 	ret = nfs_register_sysctl();
 	if (ret < 0)
 		goto error_1;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	ret = register_filesystem(&nfs4_fs_type);
 	if (ret < 0)
 		goto error_2;
@@ -328,7 +328,7 @@ int __init register_nfs_fs(void)
 	register_shrinker(&acl_shrinker);
 	return 0;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 error_2:
 	nfs_unregister_sysctl();
 #endif
@@ -344,7 +344,7 @@ error_0:
 void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	unregister_filesystem(&nfs4_fs_type);
 #endif
 	nfs_unregister_sysctl();
@@ -537,7 +537,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	nfs_show_mountd_netid(m, nfss, showdefaults);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 				    int showdefaults)
 {
@@ -658,7 +658,7 @@ int nfs_show_options(struct seq_file *m, struct dentry *root)
 }
 EXPORT_SYMBOL_GPL(nfs_show_options);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_sessions(struct seq_file *m, struct nfs_server *server)
 {
@@ -670,7 +670,7 @@ static void show_sessions(struct seq_file *m, struct nfs_server *server) {}
 #endif
 #endif
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
@@ -740,7 +740,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 	seq_printf(m, ",bsize=%u", nfss->bsize);
 	seq_printf(m, ",namlen=%u", nfss->namelen);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	if (nfss->nfs_client->rpc_ops->version == 4) {
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
@@ -1813,7 +1813,7 @@ static int nfs_validate_mount_data(void *options,
 			goto out_no_address;
 
 		if (args->version == 4)
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 			return nfs4_validate_text_mount_data(options,
 							     args, dev_name);
 #else
@@ -1868,7 +1868,7 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
-#ifndef CONFIG_NFS_V4
+#if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
@@ -2395,7 +2395,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 }
 EXPORT_SYMBOL_GPL(nfs_xdev_mount);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d906336..9788bee 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -431,7 +431,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /*
  * Add a request to the inode's commit list.
  */
@@ -516,7 +516,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
 {
@@ -1238,7 +1238,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1297,7 +1297,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 766ea02..3017614 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -188,7 +188,7 @@ struct nfs_inode {
 	struct hlist_head	silly_list;
 	wait_queue_head_t	waitqueue;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
 	struct list_head	open_states;
@@ -410,7 +410,7 @@ extern const struct inode_operations nfs_file_inode_operations;
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern const struct file_operations nfs4_file_operations;
 #endif /* CONFIG_NFS_V4 */
 extern const struct address_space_operations nfs_file_aops;
@@ -524,7 +524,7 @@ extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index c234693..50cef88 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -47,7 +47,7 @@ struct nfs_client {
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
@@ -134,7 +134,7 @@ struct nfs_server {
 #endif
 
 	u32			pnfs_blksize;	/* layout_blksize attr */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
@@ -192,7 +192,7 @@ struct nfs_server {
 /* maximum number of slots to use */
 #define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 /* Sessions */
 #define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 3c9eeb7..7ee83d6 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -69,7 +69,7 @@ struct nfs_server;
 struct nfs_fattr;
 struct nfs4_string;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 int nfs_idmap_init(void);
 void nfs_idmap_quit(void);
 #else
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9eaa8f7..c23dee4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -789,7 +789,7 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 typedef u64 clientid4;
 
@@ -1183,7 +1183,7 @@ struct nfs_write_data {
 	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 	__u64			mds_offset;	/* Filelayout dense stripe */
-- 
1.7.9

