Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:56184 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932709Ab2AMULN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:13 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 04/44] NFS: Add version registering framework
Date: Fri, 13 Jan 2012 15:10:13 -0500
Message-Id: <1326485453-1350-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch adds in the code to track multiple versions of the NFS
protocol.  I created default structures for v2, v3 and v4 so that each
version can continue to work while I convert them into kernel modules.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c |  148 +++++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfs/inode.c  |    2 +
 fs/nfs/nfs.h    |   73 +++++++++++++++++++++++++++
 fs/nfs/super.c  |   13 +++++
 4 files changed, 216 insertions(+), 20 deletions(-)
 create mode 100644 fs/nfs/nfs.h

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 01cb068..ee63d6a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -49,10 +49,13 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 static DEFINE_SPINLOCK(nfs_client_lock);
+static DEFINE_SPINLOCK(nfs_version_lock);
+static LIST_HEAD(nfs_versions);
 static LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
@@ -90,15 +93,9 @@ static int nfs4_disable_idmapping = 0;
  * RPC cruft for NFS
  */
 static struct rpc_version *nfs_version[5] = {
-#ifdef CONFIG_NFS_V2
-	[2]			= &nfs_version2,
-#endif
-#ifdef CONFIG_NFS_V3
-	[3]			= &nfs_version3,
-#endif
-#ifdef CONFIG_NFS_V4
-	[4]			= &nfs_version4,
-#endif
+	[2] = NULL,
+	[3] = NULL,
+	[4] = NULL,
 };
 
 struct rpc_program nfs_program = {
@@ -114,6 +111,51 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
+/*
+ * Default function for referencing and unreferencing
+ * nfs_version_module structures to prevent dereferencing
+ * a null pointer by the framework code.  A functional
+ * version will be implemented by individual nfs versions
+ * as they are converted into modules.
+ *
+ * Once everything has been converted this function will
+ * be removed.
+ */
+#if defined(CONFIG_NFS_V2) || defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
+static void nfs_module_null_function(void)
+{
+}
+#endif
+
+#ifdef CONFIG_NFS_V2
+static struct nfs_subversion nfs_v2_mod = {
+	.version  = 2,
+	.rpc_vers = &nfs_version2,
+	.rpc_ops  = &nfs_v2_clientops,
+	.reference = nfs_module_null_function,
+	.unreference = nfs_module_null_function,
+};
+#endif /* CONFIG_NFS_V2 */
+
+#ifdef CONFIG_NFS_V3
+static struct nfs_subversion nfs_v3_mod = {
+	.version  = 3,
+	.rpc_vers = &nfs_version3,
+	.rpc_ops  = &nfs_v3_clientops,
+	.reference = nfs_module_null_function,
+	.unreference = nfs_module_null_function,
+};
+#endif /* CONFIG_NFS_V3 */
+
+#ifdef CONFIG_NFS_V4
+static struct nfs_subversion nfs_v4_mod = {
+	.version  = 4,
+	.rpc_vers = &nfs_version4,
+	.rpc_ops  = &nfs_v4_clientops,
+	.reference = nfs_module_null_function,
+	.unreference = nfs_module_null_function,
+};
+#endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
@@ -139,6 +181,78 @@ struct nfs_client_initdata {
 	u32 minorversion;
 };
 
+struct nfs_subversion *get_nfs_version(unsigned int version)
+{
+	struct nfs_subversion *nfs;
+
+	spin_lock(&nfs_version_lock);
+
+	list_for_each_entry(nfs, &nfs_versions, list) {
+		if (nfs->version == version) {
+			/* Keep track of the most recently used version */
+			list_move(&nfs->list, &nfs_versions);
+			goto out;
+		}
+	};
+
+	nfs = ERR_PTR(-EPROTONOSUPPORT);
+
+out:
+	spin_unlock(&nfs_version_lock);
+	return nfs;
+}
+
+inline struct nfs_subversion *get_nfs_client_version(struct nfs_client *clp)
+{
+	return get_nfs_version(clp->rpc_ops->version);
+}
+
+inline struct nfs_subversion *get_nfs_server_version(struct nfs_server *srv)
+{
+	return get_nfs_client_version(srv->nfs_client);
+}
+
+void register_nfs_version(struct nfs_subversion *nfs)
+{
+	spin_lock(&nfs_version_lock);
+
+	INIT_LIST_HEAD(&nfs->list);
+	list_add(&nfs->list, &nfs_versions);
+	nfs_version[nfs->version] = nfs->rpc_vers;
+
+	spin_unlock(&nfs_version_lock);
+}
+EXPORT_SYMBOL_GPL(register_nfs_version);
+
+void unregister_nfs_version(struct nfs_subversion *nfs)
+{
+	spin_lock(&nfs_version_lock);
+
+	nfs_version[nfs->version] = NULL;
+	list_del(&nfs->list);
+
+	spin_unlock(&nfs_version_lock);
+}
+EXPORT_SYMBOL_GPL(unregister_nfs_version);
+
+/*
+ * Preload all configured NFS versions during module init.
+ * This function should be edited after each protocol is converted,
+ * and eventually removed.
+ */
+void __init nfs_register_versions(void)
+{
+#ifdef CONFIG_NFS_V2
+	register_nfs_version(&nfs_v2_mod);
+#endif
+#ifdef CONFIG_NFS_V3
+	register_nfs_version(&nfs_v3_mod);
+#endif
+#ifdef CONFIG_NFS_V4
+	register_nfs_version(&nfs_v4_mod);
+#endif
+}
+
 /*
  * Allocate a shared client record
  *
@@ -836,21 +950,15 @@ static int nfs_init_server(struct nfs_server *server,
 	};
 	struct rpc_timeout timeparms;
 	struct nfs_client *clp;
+	struct nfs_subversion *nfs_mod;
 	int error;
 
 	dprintk("--> nfs_init_server()\n");
 
-
-#ifdef CONFIG_NFS_V2
-	if (data->version == 2)
-		cl_init.rpc_ops = &nfs_v2_clientops;
-#endif
-#ifdef CONFIG_NFS_V3
-	if (data->version == 3)
-		cl_init.rpc_ops = &nfs_v3_clientops;
-#endif
-	if (cl_init.rpc_ops == NULL)
-		return -EPROTONOSUPPORT;
+	nfs_mod = get_nfs_version(data->version);
+	if (IS_ERR(nfs_mod))
+		return PTR_ERR(nfs_mod);
+	cl_init.rpc_ops = nfs_mod->rpc_ops;
 
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f59cab1..3c81a32 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -50,6 +50,7 @@
 #include "fscache.h"
 #include "dns_resolve.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -1604,6 +1605,7 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
+	nfs_register_versions();
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
new file mode 100644
index 0000000..b1fe653
--- /dev/null
+++ b/fs/nfs/nfs.h
@@ -0,0 +1,73 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ *
+ * Function and structures exported by the NFS module
+ * for use by NFS version-specific modules.
+ */
+#ifndef __LINUX_INTERNAL_NFS_H
+#define __LINUX_INTERNAL_NFS_H
+
+#include <linux/fs.h>
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs_xdr.h>
+
+struct nfs_subversion {
+	unsigned int version;		/* Protocol number */
+	struct rpc_version *rpc_vers;	/* NFS version information */
+	const struct nfs_rpc_ops *rpc_ops;	/* NFS operations */
+	struct list_head list;		/* List of NFS versions */
+
+	void (*reference)(void);	/* For reference counting */
+	void (*unreference)(void);	/* Also for reference counting */
+};
+
+void nfs_register_versions(void);
+
+struct nfs_subversion *get_nfs_version(unsigned int);
+struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
+struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
+void register_nfs_version(struct nfs_subversion *);
+void unregister_nfs_version(struct nfs_subversion *);
+
+/* Exported in dir.c */
+int nfs_lookup_revalidate(struct dentry *, struct nameidata *);
+int nfs_dentry_delete(const struct dentry *);
+void nfs_dentry_iput(struct dentry *, struct inode *);
+void nfs_d_release(struct dentry *);
+struct dentry *nfs_lookup(struct inode *, struct dentry *, struct nameidata *);
+int nfs_create(struct inode *, struct dentry *, int, struct nameidata *);
+int nfs_mknod(struct inode *, struct dentry *, int, dev_t);
+int nfs_mkdir(struct inode *, struct dentry *, int);
+int nfs_rmdir(struct inode *, struct dentry *);
+int nfs_unlink(struct inode *, struct dentry *);
+int nfs_symlink(struct inode *, struct dentry *, const char *);
+int nfs_link(struct dentry *, struct inode *, struct dentry *);
+int nfs_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+int nfs_permission(struct inode *, int);
+
+/* Exported in file.c */
+int nfs_check_flags(int);
+int nfs_file_open(struct inode *, struct file *);
+int nfs_file_release(struct inode *, struct file *);
+loff_t nfs_file_llseek(struct file *, loff_t, int);
+int nfs_file_flush(struct file *, fl_owner_t);
+ssize_t nfs_file_read(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
+			     size_t, unsigned int);
+int nfs_file_mmap(struct file *, struct vm_area_struct *);
+int nfs_file_fsync(struct file *, loff_t, loff_t, int);
+ssize_t nfs_file_write(struct kiocb *, const struct iovec *, unsigned long, loff_t);
+ssize_t nfs_file_splice_write(struct pipe_inode_info *, struct file *,
+			      loff_t *, size_t, unsigned int);
+int nfs_lock(struct file *, int, struct file_lock *);
+int nfs_flock(struct file *, int, struct file_lock *);
+int nfs_setlease(struct file *, long, struct file_lock **);
+
+/* Exported in inode.c */
+int nfs_setattr(struct dentry *, struct iattr *);
+int nfs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
+
+/* Exported in namespace.c */
+struct vfsmount *nfs_d_automount(struct path *);
+
+#endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3ada13c..aee7b00 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -64,6 +64,7 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -2229,6 +2230,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
+	struct nfs_subversion *nfs_mod;
 	int error;
 
 	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
@@ -2243,6 +2245,12 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		goto out;
 	}
 
+	nfs_mod = get_nfs_version(data->version);
+	if (IS_ERR(nfs_mod)) {
+		mntroot = (struct dentry *)nfs_mod;
+		goto out;
+	}
+
 #ifdef CONFIG_NFS_V4
 	if (data->version == 4) {
 		mntroot = nfs4_try_mount(flags, dev_name, data);
@@ -2297,6 +2305,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	if (error)
 		goto error_splat_root;
 
+	nfs_mod->reference();
 	s->s_flags |= MS_ACTIVE;
 
 out:
@@ -2326,6 +2335,10 @@ error_splat_bdi:
 static void nfs_put_super(struct super_block *s)
 {
 	struct nfs_server *server = NFS_SB(s);
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+
+	if (!IS_ERR(nfs_mod))
+		nfs_mod->unreference();
 
 	bdi_unregister(&server->backing_dev_info);
 }
-- 
1.7.8.3

