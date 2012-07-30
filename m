Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754656Ab2G3UFa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:30 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/10] NFS: Add version registering framework
Date: Mon, 30 Jul 2012 16:05:16 -0400
Message-Id: <1343678725-8659-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch adds in the code to track multiple versions of the NFS
protocol.  I created default structures for v2, v3 and v4 so that each
version can continue to work while I convert them into kernel modules.
I also removed the const parameter from the rpc_version array so that I
can change it at runtime.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile           |   4 +-
 fs/nfs/client.c           | 147 +++++++++++++++++++++++++++++++++++-----------
 fs/nfs/inode.c            |   9 +--
 fs/nfs/internal.h         |  10 ++--
 fs/nfs/nfs.h              |  72 +++++++++++++++++++++++
 fs/nfs/nfs2super.c        |  25 ++++++++
 fs/nfs/nfs3super.c        |  25 ++++++++
 fs/nfs/nfs4_fs.h          |   1 +
 fs/nfs/nfs4client.c       |   4 +-
 fs/nfs/nfs4super.c        |  14 ++++-
 fs/nfs/super.c            |  32 ++++++----
 include/linux/nfs_fs_sb.h |   1 +
 12 files changed, 283 insertions(+), 61 deletions(-)
 create mode 100644 fs/nfs/nfs.h
 create mode 100644 fs/nfs/nfs2super.c
 create mode 100644 fs/nfs/nfs3super.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 0b96c20..66dd307 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,8 +9,8 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
+nfs-$(CONFIG_NFS_V2)	+= nfs2super.o proc.o nfs2xdr.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o nfs4file.o delegation.o idmap.o \
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 65afa38..462de24 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -51,25 +51,23 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 #include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
+static DEFINE_SPINLOCK(nfs_version_lock);
+static DEFINE_MUTEX(nfs_version_mutex);
+static LIST_HEAD(nfs_versions);
 
 /*
  * RPC cruft for NFS
  */
 static const struct rpc_version *nfs_version[5] = {
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
 
 const struct rpc_program nfs_program = {
@@ -101,6 +99,93 @@ const struct rpc_program nfsacl_program = {
 };
 #endif  /* CONFIG_NFS_V3_ACL */
 
+static struct nfs_subversion *find_nfs_version(unsigned int version)
+{
+	struct nfs_subversion *nfs;
+	spin_lock(&nfs_version_lock);
+
+	list_for_each_entry(nfs, &nfs_versions, list) {
+		if (nfs->rpc_ops->version == version) {
+			spin_unlock(&nfs_version_lock);
+			return nfs;
+		}
+	};
+
+	spin_unlock(&nfs_version_lock);
+	return ERR_PTR(-EPROTONOSUPPORT);;
+}
+
+struct nfs_subversion *get_nfs_version(unsigned int version)
+{
+	struct nfs_subversion *nfs = find_nfs_version(version);
+
+	if (IS_ERR(nfs)) {
+		mutex_lock(&nfs_version_mutex);
+		request_module("nfs%d", version);
+		nfs = find_nfs_version(version);
+		mutex_unlock(&nfs_version_mutex);
+	}
+
+	if (!IS_ERR(nfs))
+		try_module_get(nfs->owner);
+	return nfs;
+}
+
+void put_nfs_version(struct nfs_subversion *nfs)
+{
+	module_put(nfs->owner);
+}
+
+void register_nfs_version(struct nfs_subversion *nfs)
+{
+	spin_lock(&nfs_version_lock);
+
+	list_add(&nfs->list, &nfs_versions);
+	nfs_version[nfs->rpc_ops->version] = nfs->rpc_vers;
+
+	spin_unlock(&nfs_version_lock);
+}
+EXPORT_SYMBOL_GPL(register_nfs_version);
+
+void unregister_nfs_version(struct nfs_subversion *nfs)
+{
+	spin_lock(&nfs_version_lock);
+
+	nfs_version[nfs->rpc_ops->version] = NULL;
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
+int __init nfs_register_versions(void)
+{
+	int err = init_nfs_v2();
+	if (err)
+		return err;
+
+	err = init_nfs_v3();
+	if (err)
+		return err;
+
+	return init_nfs_v4();
+}
+
+/*
+ * Remove each pre-loaded NFS version
+ */
+void nfs_unregister_versions(void)
+{
+	exit_nfs_v2();
+	exit_nfs_v3();
+	exit_nfs_v4();
+}
+
 /*
  * Allocate a shared client record
  *
@@ -116,7 +201,10 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
 		goto error_0;
 
-	clp->rpc_ops = cl_init->rpc_ops;
+	clp->cl_nfs_mod = cl_init->nfs_mod;
+	try_module_get(clp->cl_nfs_mod->owner);
+
+	clp->rpc_ops = clp->cl_nfs_mod->rpc_ops;
 
 	atomic_set(&clp->cl_count, 1);
 	clp->cl_cons_state = NFS_CS_INITING;
@@ -145,6 +233,7 @@ struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_init)
 	return clp;
 
 error_cleanup:
+	put_nfs_version(clp->cl_nfs_mod);
 	kfree(clp);
 error_0:
 	return ERR_PTR(err);
@@ -205,6 +294,7 @@ void nfs_free_client(struct nfs_client *clp)
 		put_rpccred(clp->cl_machine_cred);
 
 	put_net(clp->cl_net);
+	put_nfs_version(clp->cl_nfs_mod);
 	kfree(clp->cl_hostname);
 	kfree(clp);
 
@@ -362,7 +452,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 			continue;
 
 		/* Different NFS versions cannot share the same nfs_client */
-		if (clp->rpc_ops != data->rpc_ops)
+		if (clp->rpc_ops != data->nfs_mod->rpc_ops)
 			continue;
 
 		if (clp->cl_proto != data->proto)
@@ -431,9 +521,10 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 {
 	struct nfs_client *clp, *new = NULL;
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
+	const struct nfs_rpc_ops *rpc_ops = cl_init->nfs_mod->rpc_ops;
 
 	dprintk("--> nfs_get_client(%s,v%u)\n",
-		cl_init->hostname ?: "", cl_init->rpc_ops->version);
+		cl_init->hostname ?: "", rpc_ops->version);
 
 	/* see if the client already exists */
 	do {
@@ -450,14 +541,13 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 			list_add(&new->cl_share_link, &nn->nfs_client_list);
 			spin_unlock(&nn->nfs_client_lock);
 			new->cl_flags = cl_init->init_flags;
-			return cl_init->rpc_ops->init_client(new,
-						timeparms, ip_addr,
-						authflavour);
+			return rpc_ops->init_client(new, timeparms, ip_addr,
+						    authflavour);
 		}
 
 		spin_unlock(&nn->nfs_client_lock);
 
-		new = cl_init->rpc_ops->alloc_client(cl_init);
+		new = rpc_ops->alloc_client(cl_init);
 	} while (!IS_ERR(new));
 
 	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
@@ -714,13 +804,14 @@ error:
  * Create a version 2 or 3 client
  */
 static int nfs_init_server(struct nfs_server *server,
-			   const struct nfs_parsed_mount_data *data)
+			   const struct nfs_parsed_mount_data *data,
+			   struct nfs_subversion *nfs_mod)
 {
 	struct nfs_client_initdata cl_init = {
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
-		.rpc_ops = NULL,
+		.nfs_mod = nfs_mod,
 		.proto = data->nfs_server.protocol,
 		.net = data->net,
 	};
@@ -730,21 +821,6 @@ static int nfs_init_server(struct nfs_server *server,
 
 	dprintk("--> nfs_init_server()\n");
 
-	switch (data->version) {
-#ifdef CONFIG_NFS_V2
-	case 2:
-		cl_init.rpc_ops = &nfs_v2_clientops;
-		break;
-#endif
-#ifdef CONFIG_NFS_V3
-	case 3:
-		cl_init.rpc_ops = &nfs_v3_clientops;
-		break;
-#endif
-	default:
-		return -EPROTONOSUPPORT;
-	}
-
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
 	if (data->flags & NFS_MOUNT_NORESVPORT)
@@ -1033,7 +1109,8 @@ void nfs_free_server(struct nfs_server *server)
  * - keyed on server and FSID
  */
 struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
-				     struct nfs_fh *mntfh)
+				     struct nfs_fh *mntfh,
+				     struct nfs_subversion *nfs_mod)
 {
 	struct nfs_server *server;
 	struct nfs_fattr *fattr;
@@ -1049,7 +1126,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 		goto error;
 
 	/* Get a client representation */
-	error = nfs_init_server(server, data);
+	error = nfs_init_server(server, data, nfs_mod);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 35f7e4b..e8877c8 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -50,6 +50,7 @@
 #include "fscache.h"
 #include "dns_resolve.h"
 #include "pnfs.h"
+#include "nfs.h"
 #include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -1671,21 +1672,17 @@ static int __init init_nfs_fs(void)
 	rpc_proc_register(&init_net, &nfs_rpcstat);
 #endif
 
-#ifdef CONFIG_NFS_V4
-	err = init_nfs_v4();
+	err = nfs_register_versions();
 	if (err)
 		goto out1;
-#endif
 
 	if ((err = register_nfs_fs()) != 0)
 		goto out0;
 
 	return 0;
 out0:
-#ifdef CONFIG_NFS_V4
-	exit_nfs_v4();
+	nfs_unregister_versions();
 out1:
-#endif
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister(&init_net, "nfs");
 #endif
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index cfafd13..ac93647 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -90,7 +90,7 @@ struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
 	size_t addrlen;
-	const struct nfs_rpc_ops *rpc_ops;
+	struct nfs_subversion *nfs_mod;
 	int proto;
 	u32 minorversion;
 	struct net *net;
@@ -189,7 +189,8 @@ nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 				struct nfs4_sessionid *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
-					struct nfs_fh *);
+					struct nfs_fh *,
+					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
@@ -321,6 +322,7 @@ void nfs_zap_acl_cache(struct inode *inode);
 extern int nfs_wait_bit_killable(void *word);
 
 /* super.c */
+extern struct file_system_type nfs_fs_type;
 extern struct file_system_type nfs_xdev_fs_type;
 #ifdef CONFIG_NFS_V4
 extern struct file_system_type nfs4_xdev_fs_type;
@@ -329,8 +331,8 @@ extern struct file_system_type nfs4_referral_fs_type;
 void nfs_initialise_sb(struct super_block *);
 int nfs_set_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
 int nfs_clone_sb_security(struct super_block *, struct dentry *, struct nfs_mount_info *);
-struct dentry *nfs_fs_mount_common(struct file_system_type *, struct nfs_server *,
-				   int, const char *, struct nfs_mount_info *);
+struct dentry *nfs_fs_mount_common(struct nfs_server *, int, const char *,
+				   struct nfs_mount_info *, struct nfs_subversion *);
 struct dentry *nfs_fs_mount(struct file_system_type *, int, const char *, void *);
 struct dentry * nfs_xdev_mount_common(struct file_system_type *, int,
 		const char *, struct nfs_mount_info *);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
new file mode 100644
index 0000000..ac10b9e
--- /dev/null
+++ b/fs/nfs/nfs.h
@@ -0,0 +1,72 @@
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
+	struct module *owner;	/* THIS_MODULE pointer */
+	struct file_system_type *nfs_fs;	/* NFS filesystem type */
+	const struct rpc_version *rpc_vers;	/* NFS version information */
+	const struct nfs_rpc_ops *rpc_ops;	/* NFS operations */
+	struct list_head list;		/* List of NFS versions */
+};
+
+int nfs_register_versions(void);
+void nfs_unregister_versions(void);
+
+#ifdef CONFIG_NFS_V2
+int init_nfs_v2(void);
+void exit_nfs_v2(void);
+#else /* CONFIG_NFS_V2 */
+static inline int __init init_nfs_v2(void)
+{
+	return 0;
+}
+
+static inline void exit_nfs_v2(void)
+{
+}
+#endif /* CONFIG_NFS_V2 */
+
+#ifdef CONFIG_NFS_V3
+int init_nfs_v3(void);
+void exit_nfs_v3(void);
+#else /* CONFIG_NFS_V3 */
+static inline int __init init_nfs_v3(void)
+{
+	return 0;
+}
+
+static inline void exit_nfs_v3(void)
+{
+}
+#endif /* CONFIG_NFS_V3 */
+
+#ifdef CONFIG_NFS_V4
+int init_nfs_v4(void);
+void exit_nfs_v4(void);
+#else /* CONFIG_NFS_V4 */
+static inline int __init init_nfs_v4(void)
+{
+	return 0;
+}
+
+static inline void exit_nfs_v4(void)
+{
+}
+#endif /* CONFIG_NFS_V4 */
+
+struct nfs_subversion *get_nfs_version(unsigned int);
+void put_nfs_version(struct nfs_subversion *);
+void register_nfs_version(struct nfs_subversion *);
+void unregister_nfs_version(struct nfs_subversion *);
+
+#endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
new file mode 100644
index 0000000..cef06d4
--- /dev/null
+++ b/fs/nfs/nfs2super.c
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include "internal.h"
+#include "nfs.h"
+
+static struct nfs_subversion nfs_v2 = {
+	.owner = THIS_MODULE,
+	.nfs_fs   = &nfs_fs_type,
+	.rpc_vers = &nfs_version2,
+	.rpc_ops  = &nfs_v2_clientops,
+};
+
+int __init init_nfs_v2(void)
+{
+	register_nfs_version(&nfs_v2);
+	return 0;
+}
+
+void exit_nfs_v2(void)
+{
+	unregister_nfs_version(&nfs_v2);
+}
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
new file mode 100644
index 0000000..f815cf3
--- /dev/null
+++ b/fs/nfs/nfs3super.c
@@ -0,0 +1,25 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include "internal.h"
+#include "nfs.h"
+
+static struct nfs_subversion nfs_v3 = {
+	.owner = THIS_MODULE,
+	.nfs_fs   = &nfs_fs_type,
+	.rpc_vers = &nfs_version3,
+	.rpc_ops  = &nfs_v3_clientops,
+};
+
+int __init init_nfs_v3(void)
+{
+	register_nfs_version(&nfs_v3);
+	return 0;
+}
+
+void exit_nfs_v3(void)
+{
+	unregister_nfs_version(&nfs_v3);
+}
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b1ecacd..005558a 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -366,6 +366,7 @@ extern const nfs4_stateid zero_stateid;
 
 /* nfs4super.c */
 struct nfs_mount_info;
+extern struct nfs_subversion nfs_v4;
 struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *);
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 1c3f13c..769e798 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -357,7 +357,7 @@ static int nfs4_set_client(struct nfs_server *server,
 		.hostname = hostname,
 		.addr = addr,
 		.addrlen = addrlen,
-		.rpc_ops = &nfs_v4_clientops,
+		.nfs_mod = &nfs_v4,
 		.proto = proto,
 		.minorversion = minorversion,
 		.net = net,
@@ -411,7 +411,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 	struct nfs_client_initdata cl_init = {
 		.addr = ds_addr,
 		.addrlen = ds_addrlen,
-		.rpc_ops = &nfs_v4_clientops,
+		.nfs_mod = &nfs_v4,
 		.proto = ds_proto,
 		.minorversion = mds_clp->cl_minorversion,
 		.net = mds_clp->cl_net,
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 59264fb..1f34019 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -8,6 +8,7 @@
 #include <linux/nfs_fs.h>
 #include "internal.h"
 #include "nfs4_fs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -75,6 +76,13 @@ static const struct super_operations nfs4_sops = {
 	.remount_fs	= nfs_remount,
 };
 
+struct nfs_subversion nfs_v4 = {
+	.owner = THIS_MODULE,
+	.nfs_fs   = &nfs4_fs_type,
+	.rpc_vers = &nfs_version4,
+	.rpc_ops  = &nfs_v4_clientops,
+};
+
 /*
  * Set up an NFS4 superblock
  */
@@ -113,7 +121,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		goto out;
 	}
 
-	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
+	mntroot = nfs_fs_mount_common(server, flags, dev_name, mount_info, &nfs_v4);
 
 out:
 	return mntroot;
@@ -293,7 +301,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 		goto out;
 	}
 
-	mntroot = nfs_fs_mount_common(&nfs4_fs_type, server, flags, dev_name, &mount_info);
+	mntroot = nfs_fs_mount_common(server, flags, dev_name, &mount_info, &nfs_v4);
 out:
 	nfs_free_fhandle(mount_info.mntfh);
 	return mntroot;
@@ -343,6 +351,7 @@ int __init init_nfs_v4(void)
 	if (err < 0)
 		goto out2;
 
+	register_nfs_version(&nfs_v4);
 	return 0;
 out2:
 	nfs4_unregister_sysctl();
@@ -354,6 +363,7 @@ out:
 
 void exit_nfs_v4(void)
 {
+	unregister_nfs_version(&nfs_v4);
 	unregister_filesystem(&nfs4_fs_type);
 	nfs4_unregister_sysctl();
 	nfs_idmap_quit();
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 95866a8..61405a7 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -64,6 +64,7 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 #define NFS_TEXT_DATA		1
@@ -281,7 +282,7 @@ static match_table_t nfs_vers_tokens = {
 static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data);
 
-static struct file_system_type nfs_fs_type = {
+struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfs",
 	.mount		= nfs_fs_mount,
@@ -1650,7 +1651,8 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
 }
 
 static struct dentry *nfs_try_mount(int flags, const char *dev_name,
-				    struct nfs_mount_info *mount_info)
+				    struct nfs_mount_info *mount_info,
+				    struct nfs_subversion *nfs_mod)
 {
 	int status;
 	struct nfs_server *server;
@@ -1662,11 +1664,11 @@ static struct dentry *nfs_try_mount(int flags, const char *dev_name,
 	}
 
 	/* Get a volume representation */
-	server = nfs_create_server(mount_info->parsed, mount_info->mntfh);
+	server = nfs_create_server(mount_info->parsed, mount_info->mntfh, nfs_mod);
 	if (IS_ERR(server))
 		return ERR_CAST(server);
 
-	return nfs_fs_mount_common(&nfs_fs_type, server, flags, dev_name, mount_info);
+	return nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
 }
 
 /*
@@ -2297,10 +2299,10 @@ int nfs_clone_sb_security(struct super_block *s, struct dentry *mntroot,
 	return 0;
 }
 
-struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
-				   struct nfs_server *server,
+struct dentry *nfs_fs_mount_common(struct nfs_server *server,
 				   int flags, const char *dev_name,
-				   struct nfs_mount_info *mount_info)
+				   struct nfs_mount_info *mount_info,
+				   struct nfs_subversion *nfs_mod)
 {
 	struct super_block *s;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
@@ -2319,7 +2321,7 @@ struct dentry *nfs_fs_mount_common(struct file_system_type *fs_type,
 		sb_mntdata.mntflags |= MS_SYNCHRONOUS;
 
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(fs_type, compare_super, nfs_set_super, flags, &sb_mntdata);
+	s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
 	if (IS_ERR(s)) {
 		mntroot = ERR_CAST(s);
 		goto out_err_nosb;
@@ -2378,6 +2380,7 @@ struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		.set_security = nfs_set_sb_security,
 	};
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	struct nfs_subversion *nfs_mod;
 	int error;
 
 	mount_info.parsed = nfs_alloc_parsed_mount_data();
@@ -2394,12 +2397,20 @@ struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		goto out;
 	}
 
+	nfs_mod = get_nfs_version(mount_info.parsed->version);
+	if (IS_ERR(nfs_mod)) {
+		mntroot = ERR_CAST(nfs_mod);
+		goto out;
+	}
+
 #ifdef CONFIG_NFS_V4
 	if (mount_info.parsed->version == 4)
 		mntroot = nfs4_try_mount(flags, dev_name, &mount_info);
 	else
 #endif	/* CONFIG_NFS_V4 */
-		mntroot = nfs_try_mount(flags, dev_name, &mount_info);
+		mntroot = nfs_try_mount(flags, dev_name, &mount_info, nfs_mod);
+
+	put_nfs_version(nfs_mod);
 
 out:
 	nfs_free_parsed_mount_data(mount_info.parsed);
@@ -2440,6 +2451,7 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 	struct nfs_clone_mount *data = mount_info->cloned;
 	struct nfs_server *server;
 	struct dentry *mntroot = ERR_PTR(-ENOMEM);
+	struct nfs_subversion *nfs_mod = NFS_SB(data->sb)->nfs_client->cl_nfs_mod;
 	int error;
 
 	dprintk("--> nfs_xdev_mount_common()\n");
@@ -2453,7 +2465,7 @@ nfs_xdev_mount_common(struct file_system_type *fs_type, int flags,
 		goto out_err;
 	}
 
-	mntroot = nfs_fs_mount_common(fs_type, server, flags, dev_name, mount_info);
+	mntroot = nfs_fs_mount_common(server, flags, dev_name, mount_info, nfs_mod);
 	dprintk("<-- nfs_xdev_mount_common() = 0\n");
 out:
 	return mntroot;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6532765..6039297 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -48,6 +48,7 @@ struct nfs_client {
 	struct rpc_clnt *	cl_rpcclient;
 	const struct nfs_rpc_ops *rpc_ops;	/* NFS protocol vector */
 	int			cl_proto;	/* Network transport protocol */
+	struct nfs_subversion *	cl_nfs_mod;	/* pointer to nfs version module */
 
 	u32			cl_minorversion;/* NFSv4 minorversion */
 	struct rpc_cred		*cl_machine_cred;
-- 
1.7.11.3

