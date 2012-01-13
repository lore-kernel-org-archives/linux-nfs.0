Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:33936 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932754Ab2AMULm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:42 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 42/44] NFS: Switch to using IS_ENABLED macro for CONFIG_NFS_V4
Date: Fri, 13 Jan 2012 15:10:51 -0500
Message-Id: <1326485453-1350-43-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Just checking if CONFIG_NFS_V4 is defined will check if v4 is built in
to the kernel.  Instead, we want to check if it is either built in OR a
module (CONFIG_NFS_V4_MODULE).  This macro will do both.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/inode.c            |    4 ++--
 fs/nfs/internal.h         |   14 +++++++-------
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/nfs4/Makefile      |    7 +++++++
 fs/nfs/nfs4/callback.h    |    2 +-
 fs/nfs/nfs4/delegation.h  |    2 +-
 fs/nfs/nfs4/nfs4_fs.h     |    2 +-
 fs/nfs/super.c            |   16 ++++++++--------
 include/linux/nfs_fs.h    |    4 ++--
 include/linux/nfs_fs_sb.h |    6 +++---
 include/linux/nfs_xdr.h   |    4 ++--
 11 files changed, 35 insertions(+), 28 deletions(-)
 create mode 100644 fs/nfs/nfs4/Makefile

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index a8d138b..57a68b8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1468,7 +1468,7 @@ struct inode *nfs_alloc_inode(struct super_block *sb)
 	nfsi->acl_access = ERR_PTR(-EAGAIN);
 	nfsi->acl_default = ERR_PTR(-EAGAIN);
 #endif
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	nfsi->nfs4_acl = NULL;
 #endif /* CONFIG_NFS_V4 */
 	return &nfsi->vfs_inode;
@@ -1488,7 +1488,7 @@ void nfs_destroy_inode(struct inode *inode)
 
 static inline void nfs4_init_once(struct nfs_inode *nfsi)
 {
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	INIT_LIST_HEAD(&nfsi->open_states);
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 347f49f..8428aab 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -185,7 +185,7 @@ static inline void nfs_fs_proc_exit(void)
 #endif
 
 /* nfs4namespace.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct vfsmount *nfs_do_refmount(struct dentry *dentry);
 #else
 static inline
@@ -222,7 +222,7 @@ extern int nfs3_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 
 /* nfs4xdr.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs4_decode_dirent(struct xdr_stream *,
 				struct nfs_entry *, int);
 #endif
@@ -232,7 +232,7 @@ extern const u32 nfs41_maxwrite_overhead;
 #endif
 
 /* nfs4proc.c */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern struct rpc_procinfo nfs4_procedures[];
 void nfs_fixup_secinfo_attributes(struct nfs_fattr *, struct nfs_fh *);
 #endif
@@ -256,7 +256,7 @@ extern struct inode *nfs_alloc_inode(struct super_block *sb);
 extern void nfs_destroy_inode(struct inode *);
 extern int nfs_write_inode(struct inode *, struct writeback_control *);
 extern void nfs_evict_inode(struct inode *);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern void nfs4_evict_inode(struct inode *);
 #endif
 void nfs_zap_acl_cache(struct inode *inode);
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
index 721d882..203b4b3 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -115,7 +115,7 @@ Elong:
 	return ERR_PTR(-ENAMETOOLONG);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *flavors)
 {
 	struct gss_api_mech *mech;
diff --git a/fs/nfs/nfs4/Makefile b/fs/nfs/nfs4/Makefile
new file mode 100644
index 0000000..0355a3c
--- /dev/null
+++ b/fs/nfs/nfs4/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for NFS v4
+#
+obj-$(CONFIG_NFS_V4) += nfs4.o
+nfs4-y := proc.o xdr.o state.o renewd.o delegation.o idmap.o callback.o \
+	  callback_xdr.o callback_proc.o namespace.o client.o module.o \
+	  sysctl.o getroot.o inode.o file.o dir.o super.o
diff --git a/fs/nfs/nfs4/callback.h b/fs/nfs/nfs4/callback.h
index 07df5f1..ee18319 100644
--- a/fs/nfs/nfs4/callback.h
+++ b/fs/nfs/nfs4/callback.h
@@ -191,7 +191,7 @@ extern __be32 nfs4_callback_getattr(struct cb_getattrargs *args,
 				    struct cb_process_state *cps);
 extern __be32 nfs4_callback_recall(struct cb_recallargs *args, void *dummy,
 				   struct cb_process_state *cps);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt);
 extern void nfs_callback_down(int minorversion);
 extern int nfs4_validate_delegation_stateid(struct nfs_delegation *delegation,
diff --git a/fs/nfs/nfs4/delegation.h b/fs/nfs/nfs4/delegation.h
index 40bd6c2..ea58699 100644
--- a/fs/nfs/nfs4/delegation.h
+++ b/fs/nfs/nfs4/delegation.h
@@ -8,7 +8,7 @@
 #ifndef FS_NFS_DELEGATION_H
 #define FS_NFS_DELEGATION_H
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 /*
  * NFSv4 delegation
  */
diff --git a/fs/nfs/nfs4/nfs4_fs.h b/fs/nfs/nfs4/nfs4_fs.h
index 4d7d0ae..01d7b63 100644
--- a/fs/nfs/nfs4/nfs4_fs.h
+++ b/fs/nfs/nfs4/nfs4_fs.h
@@ -9,7 +9,7 @@
 #ifndef __LINUX_FS_NFS_NFS4_FS_H
 #define __LINUX_FS_NFS_NFS4_FS_H
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 struct idmap;
 
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7bab19e..2c8ed6f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -318,7 +318,7 @@ int __init register_nfs_fs(void)
 	ret = nfs_register_sysctl();
 	if (ret < 0)
 		goto error_1;
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	ret = init_nfs_v4();
 	if (ret < 0)
 		goto error_2;
@@ -326,7 +326,7 @@ int __init register_nfs_fs(void)
 	register_shrinker(&acl_shrinker);
 	return 0;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 error_2:
 	nfs_unregister_sysctl();
 #endif
@@ -342,7 +342,7 @@ error_0:
 void __exit unregister_nfs_fs(void)
 {
 	unregister_shrinker(&acl_shrinker);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	exit_nfs_v4();
 #endif
 	nfs_unregister_sysctl();
@@ -535,7 +535,7 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
 	nfs_show_mountd_netid(m, nfss, showdefaults);
 }
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 static void nfs_show_nfsv4_options(struct seq_file *m, struct nfs_server *nfss,
 				    int showdefaults)
 {
@@ -656,7 +656,7 @@ int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 }
 EXPORT_SYMBOL_GPL(nfs_show_options);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_sessions(struct seq_file *m, struct nfs_server *server)
 {
@@ -668,7 +668,7 @@ static void show_sessions(struct seq_file *m, struct nfs_server *server) {}
 #endif
 #endif
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 #ifdef CONFIG_NFS_V4_1
 static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
@@ -738,7 +738,7 @@ int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 	seq_printf(m, ",bsize=%u", nfss->bsize);
 	seq_printf(m, ",namlen=%u", nfss->namelen);
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	if (nfss->nfs_client->rpc_ops->version == 4) {
 		seq_printf(m, "\n\tnfsv4:\t");
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
@@ -1866,7 +1866,7 @@ out_v3_not_compiled:
 	return -EPROTONOSUPPORT;
 #endif /* !CONFIG_NFS_V3 */
 
-#ifndef CONFIG_NFS_V4
+#if !IS_ENABLED(CONFIG_NFS_V4)
 out_v4_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv4 is not compiled into kernel\n");
 	return -EPROTONOSUPPORT;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 4814fcc..8cd22a5 100644
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
@@ -405,7 +405,7 @@ extern __be32 root_nfs_parse_addr(char *name); /*__init*/
 /*
  * linux/fs/nfs/file.c
  */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 extern const struct file_operations nfs4_file_operations;
 #endif /* CONFIG_NFS_V4 */
 extern const struct address_space_operations nfs_file_aops;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index ba4d765..ff49972 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -46,7 +46,7 @@ struct nfs_client {
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
@@ -132,7 +132,7 @@ struct nfs_server {
 #endif
 
 	u32			pnfs_blksize;	/* layout_blksize attr */
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	u32			attr_bitmask[3];/* V4 bitmask representing the set
 						   of attributes supported on this
 						   filesystem */
@@ -190,7 +190,7 @@ struct nfs_server {
 /* maximum number of slots to use */
 #define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
 
-#if defined(CONFIG_NFS_V4)
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 /* Sessions */
 #define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index afa36f8..164fbef 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -791,7 +791,7 @@ struct nfs3_getaclres {
 	struct posix_acl *	acl_default;
 };
 
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 
 typedef u64 clientid4;
 
@@ -1185,7 +1185,7 @@ struct nfs_write_data {
 	int			ds_commit_index;
 	const struct rpc_call_ops *mds_ops;
 	int (*write_done_cb) (struct rpc_task *task, struct nfs_write_data *data);
-#ifdef CONFIG_NFS_V4
+#if IS_ENABLED(CONFIG_NFS_V4)
 	unsigned long		timestamp;	/* For lease renewal */
 #endif
 	__u64			mds_offset;	/* Filelayout dense stripe */
-- 
1.7.8.3

