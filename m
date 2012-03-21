Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759034Ab2CUPV0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:26 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 22/23] NFS: Use the IS_ENABLED macro for CONFIG_NFS_V4
Date: Wed, 21 Mar 2012 11:20:52 -0400
Message-Id: <1332343253-24970-23-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Once v4 is a module CONFIG_NFS_V4_MODULE may be set instead of
CONFIG_NFS_V4.  This code doesn't care if it's a module or built in, but
it does need to know if any form of the option is enabled.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/callback.h         |    2 +-
 fs/nfs/client.c           |    8 ++++----
 fs/nfs/delegation.h       |    2 +-
 fs/nfs/dir.c              |    4 ++--
 fs/nfs/direct.c           |    2 +-
 fs/nfs/inode.c            |    8 ++++----
 fs/nfs/internal.h         |   12 ++++++------
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/netns.h            |    2 +-
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/super.c            |   14 +++++++-------
 fs/nfs/write.c            |    8 ++++----
 include/linux/nfs_fs.h    |    6 +++---
 include/linux/nfs_fs_sb.h |    6 +++---
 include/linux/nfs_idmap.h |    2 +-
 include/linux/nfs_xdr.h   |    4 ++--
 16 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index a5527c9..b44d7b1 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -192,7 +192,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_process_state *cps);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 96de872..45f3a21 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -53,7 +53,7 @@
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
 static DEFINE_SPINLOCK(nfs_version_lock);
 static LIST_HEAD(nfs_versions);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 /*
  * Get a unique NFSv4.0 callback identifier which will be used
@@ -213,7 +213,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	return nfs_mod->alloc_client(cl_init);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void pnfs_init_server(struct nfs_server *server)
 {
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
@@ -1159,7 +1159,7 @@ error:
 }
 EXPORT_SYMBOL_GPL(nfs_create_server);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 /*
  * NFSv4.0 callback thread helper
  *
@@ -1302,7 +1302,7 @@ void nfs_clients_init(struct net *net)
 
 	INIT_LIST_HEAD(&nn->nfs_client_list);
 	INIT_LIST_HEAD(&nn->nfs_volume_list);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	idr_init(&nn->cb_ident_idr);
 #endif
 	spin_lock_init(&nn->nfs_client_lock);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 26f77ca..6436548 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -9,7 +9,7 @@
 #define FS_NFS_DELEGATION_H
 
 #include "nfs.h"
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 /*
  * NFSv4 delegation
  */
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4e8d06b..10c7275 100644
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
index 18b16a7..a43b9bd 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -458,7 +458,7 @@ static void nfs_direct_free_writedata(struct nfs_direct_req *dreq)
 	}
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 {
 	struct inode *inode = dreq->inode;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 35f4175..e1e0568 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1532,7 +1532,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);
 #endif
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
@@ -1551,7 +1551,7 @@ void nfs_destroy_inode(struct inode *inode)
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	INIT_LIST_HEAD(&nfsi->open_states);
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
@@ -1700,7 +1700,7 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	init_nfs_v4();
 #endif
 	return 0;
@@ -1733,7 +1733,7 @@ out9:
 
 static void __exit exit_nfs_fs(void)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	exit_nfs_v4();
 #endif
 	nfs_destroy_directcache();
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 42d0903..2049975 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -188,7 +188,7 @@ static inline void nfs_fs_proc_exit(void)
 #endif
 
 /* nfs4namespace.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
 #else
 static inline
@@ -225,7 +225,7 @@ extern int nfs3_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
 /* nfs4xdr.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs4_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 #endif
@@ -235,7 +235,7 @@ extern const u32 nfs41_maxwrite_overhead;
 #endif
 
 /* nfs4proc.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct rpc_procinfo nfs4_procedures[];
 void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
@@ -264,7 +264,7 @@ extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
 extern struct file_system_type nfs_xdev_fs_type;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
@@ -280,14 +280,14 @@ extern void nfs_sb_deactive(struct super_block *sb);
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
index c071f54..aa8e6db 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -121,7 +121,7 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
diff --git a/fs/nfs/netns.h b/fs/nfs/netns.h
index aa14ec3..c777c0d 100644
--- a/fs/nfs/netns.h
+++ b/fs/nfs/netns.h
@@ -16,7 +16,7 @@ struct nfs_net {
 	wait_queue_head_t bl_wq;
 	struct list_head nfs_client_list;
 	struct list_head nfs_volume_list;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	struct idr cb_ident_idr; /* Protected by nfs_client_lock */
 #endif
 	spinlock_t nfs_client_lock;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 636786e..6258397 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -9,7 +9,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 #include "nfs.h"
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 97f3ff0..b214f44 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -534,7 +534,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	nfs_show_mountd_netid(m, nfss, showdefaults);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 				    int showdefaults)
 {
@@ -666,7 +666,7 @@ int nfs_show_options(struct seq_file *m, struct dentry *root)
 	return 0;
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_sessions(struct seq_file *m, struct nfs_server *server)
 {
@@ -699,7 +699,7 @@ static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
 	}
 }
 #else
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
 }
@@ -764,7 +764,7 @@ int nfs_show_stats(struct seq_file *m, struct dentry *root)
 	seq_printf(m, ",bsize=%u", nfss->bsize);
 	seq_printf(m, ",namlen=%u", nfss->namelen);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	if (nfss->nfs_client->rpc_ops->version == 4) {
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
@@ -1847,7 +1847,7 @@ static int nfs_validate_mount_data(void *options,
 			goto out_no_address;
 
 		if (args->version == 4)
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 			return nfs4_validate_text_mount_data(options,
 							     args, dev_name);
 #else
@@ -1902,7 +1902,7 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
-#ifndef CONFIG_NFS_V4
+#if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
@@ -2422,7 +2422,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	return nfs_mod->xdev_mount(flags, dev_name, data);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 static void nfs4_validate_mount_flags(struct nfs_parsed_mount_data *args)
 {
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 46fff97..d8e9ef7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -416,7 +416,7 @@ nfs_mark_request_dirty(struct nfs_page *req)
 	__set_page_dirty_nobuffers(req->wb_page);
 }
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 /**
  * nfs_request_add_commit_list - add request to a commit list
  * @req: pointer to a struct nfs_page
@@ -551,7 +551,7 @@ int nfs_reschedule_unstable_write(struct nfs_page *req,
 }
 #endif
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int
 nfs_need_commit(struct nfs_inode *nfsi)
 {
@@ -1271,7 +1271,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		return;
 	nfs_add_stats(data->inode, NFSIOS_SERVERWRITTENBYTES, resp->count);
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 	if (resp->verf->committed < argp->stable && task->tk_status >= 0) {
 		/* We tried a write call, but the server did not
 		 * commit data to stable storage even though we
@@ -1330,7 +1330,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 }
 
 
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 static int nfs_commit_set_lock(struct nfs_inode *nfsi, int may_wait)
 {
 	int ret;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 3e0758e..b17fbae 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -191,7 +191,7 @@ struct nfs_inode {
 	struct hlist_head	silly_list;
 	wait_queue_head_t	waitqueue;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
 	struct list_head	open_states;
@@ -436,7 +436,7 @@ extern const struct inode_operations nfs_file_inode_operations;
 extern const struct inode_operations nfs3_file_inode_operations;
 #endif /* CONFIG_NFS_V3 */
 extern const struct file_operations nfs_file_operations;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern const struct file_operations nfs4_file_operations;
 #endif /* CONFIG_NFS_V4 */
 extern const struct address_space_operations nfs_file_aops;
@@ -550,7 +550,7 @@ extern void nfs_writeback_done(struct rpc_task *, struct nfs_write_data *);
 extern int nfs_wb_all(struct inode *inode);
 extern int nfs_wb_page(struct inode *inode, struct page* page);
 extern int nfs_wb_page_cancel(struct inode *inode, struct page* page);
-#if IS_ENABLED(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V3) || IS_ENABLED(CONFIG_NFS_V4)
 extern int  nfs_commit_inode(struct inode *, int);
 extern struct nfs_write_data *nfs_commitdata_alloc(void);
 extern void nfs_commit_free(struct nfs_write_data *wdata);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 7073fc7..c47cea9 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -48,7 +48,7 @@ struct nfs_client {
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
@@ -136,7 +136,7 @@ struct nfs_server {
 #endif
 
 	u32			pnfs_blksize;	/* layout_blksize attr */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
@@ -199,7 +199,7 @@ struct nfs_server {
 #define NFS4_MAX_SLOT_TABLE (256U)
 #define NFS4_NO_SLOT ((u32)-1)
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 /* Sessions */
 #define SLOT_TABLE_SZ DIV_ROUND_UP(NFS4_MAX_SLOT_TABLE, 8*sizeof(long))
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 7eed201..ece91c5 100644
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
index a52ddd5..8d70dfa 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -790,7 +790,7 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 typedef u64 clientid4;
 
@@ -1184,7 +1184,7 @@ struct nfs_write_data {
 	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 	__u64			mds_offset;	/* Filelayout dense stripe */
-- 
1.7.9.4

