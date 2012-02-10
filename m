Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753303Ab2BJWCN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 17:02:13 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC 03/21] NFS: Add version registering framework
Date: Fri, 10 Feb 2012 17:01:47 -0500
Message-Id: <1328911325-1566-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
References: <1328911325-1566-1-git-send-email-bjschuma@netapp.com>
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
 fs/lockd/clnt4xdr.c         |    2 +-
 fs/lockd/clntxdr.c          |    6 +-
 fs/lockd/mon.c              |    4 +-
 fs/nfs/Makefile             |    6 +-
 fs/nfs/client.c             |  108 +++++++++++++++++++++++++++++++++---------
 fs/nfs/inode.c              |    2 +
 fs/nfs/mount_clnt.c         |    6 +-
 fs/nfs/nfs.h                |   35 ++++++++++++++
 fs/nfs/nfs2super.c          |   31 ++++++++++++
 fs/nfs/nfs2xdr.c            |    2 +-
 fs/nfs/nfs3super.c          |   31 ++++++++++++
 fs/nfs/nfs3xdr.c            |    4 +-
 fs/nfs/nfs4super.c          |   31 ++++++++++++
 fs/nfs/nfs4xdr.c            |    2 +-
 fs/nfs/super.c              |   48 ++++++++++++++-----
 fs/nfsd/nfs4callback.c      |    2 +-
 include/linux/lockd/xdr4.h  |    2 +-
 include/linux/nfs_xdr.h     |    8 ++--
 include/linux/sunrpc/clnt.h |    2 +-
 net/sunrpc/rpcb_clnt.c      |    8 ++--
 20 files changed, 277 insertions(+), 63 deletions(-)
 create mode 100644 fs/nfs/nfs.h
 create mode 100644 fs/nfs/nfs2super.c
 create mode 100644 fs/nfs/nfs3super.c
 create mode 100644 fs/nfs/nfs4super.c

diff --git a/fs/lockd/clnt4xdr.c b/fs/lockd/clnt4xdr.c
index 3ddcbb1..580dbe2 100644
--- a/fs/lockd/clnt4xdr.c
+++ b/fs/lockd/clnt4xdr.c
@@ -598,7 +598,7 @@ static struct rpc_procinfo	nlm4_procedures[] = {
 	PROC(GRANTED_RES,	res,		norep),
 };
 
-const struct rpc_version nlm_version4 = {
+struct rpc_version nlm_version4 = {
 	.number		= 4,
 	.nrprocs	= ARRAY_SIZE(nlm4_procedures),
 	.procs		= nlm4_procedures,
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index 3d35e3e..78e80c4 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -596,19 +596,19 @@ static struct rpc_procinfo	nlm_procedures[] = {
 	PROC(GRANTED_RES,	res,		norep),
 };
 
-static const struct rpc_version	nlm_version1 = {
+static struct rpc_version	nlm_version1 = {
 		.number		= 1,
 		.nrprocs	= ARRAY_SIZE(nlm_procedures),
 		.procs		= nlm_procedures,
 };
 
-static const struct rpc_version	nlm_version3 = {
+static struct rpc_version	nlm_version3 = {
 		.number		= 3,
 		.nrprocs	= ARRAY_SIZE(nlm_procedures),
 		.procs		= nlm_procedures,
 };
 
-static const struct rpc_version	*nlm_versions[] = {
+static struct rpc_version	*nlm_versions[] = {
 	[1] = &nlm_version1,
 	[3] = &nlm_version3,
 #ifdef CONFIG_LOCKD_V4
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index c196030..ff247f4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -534,13 +534,13 @@ static struct rpc_procinfo	nsm_procedures[] = {
 	},
 };
 
-static const struct rpc_version nsm_version1 = {
+static struct rpc_version nsm_version1 = {
 		.number		= 1,
 		.nrprocs	= ARRAY_SIZE(nsm_procedures),
 		.procs		= nsm_procedures
 };
 
-static const struct rpc_version *nsm_version[] = {
+static struct rpc_version *nsm_version[] = {
 	[1] = &nsm_version1,
 };
 
diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 7ddd45d..c6e7844 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,11 +9,11 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V2)	+= proc.o nfs2xdr.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3proc.o nfs3xdr.o
+nfs-$(CONFIG_NFS_V2)	+= nfs2super.o proc.o nfs2xdr.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
-			   delegation.o idmap.o \
+			   nfs4super.o delegation.o idmap.o \
 			   callback.o callback_xdr.o callback_proc.o \
 			   nfs4namespace.o
 nfs-$(CONFIG_NFS_V4_1)	+= pnfs.o pnfs_dev.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 02a33d8..59bf964 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -49,10 +49,13 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 DEFINE_SPINLOCK(nfs_client_lock);
+static DEFINE_SPINLOCK(nfs_version_lock);
+static LIST_HEAD(nfs_versions);
 LIST_HEAD(nfs_client_list);
 static LIST_HEAD(nfs_volume_list);
 static DECLARE_WAIT_QUEUE_HEAD(nfs_client_active_wq);
@@ -89,16 +92,10 @@ static bool nfs4_disable_idmapping = true;
 /*
  * RPC cruft for NFS
  */
-static const struct rpc_version *nfs_version[5] = {
-#ifdef CONFIG_NFS_V2
-	[2]			= &nfs_version2,
-#endif
-#ifdef CONFIG_NFS_V3
-	[3]			= &nfs_version3,
-#endif
-#ifdef CONFIG_NFS_V4
-	[4]			= &nfs_version4,
-#endif
+static struct rpc_version *nfs_version[5] = {
+	[2] = NULL,
+	[3] = NULL,
+	[4] = NULL,
 };
 
 const struct rpc_program nfs_program = {
@@ -114,10 +111,9 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-
 #ifdef CONFIG_NFS_V3_ACL
 static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static const struct rpc_version *nfsacl_version[] = {
+static struct rpc_version *nfsacl_version[] = {
 	[3]			= &nfsacl_version3,
 };
 
@@ -140,6 +136,78 @@ struct nfs_client_initdata {
 	struct net *net;
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
+	init_nfs_v2();
+#endif
+#ifdef CONFIG_NFS_V3
+	init_nfs_v3();
+#endif
+#ifdef CONFIG_NFS_V4
+	init_nfs_v4();
+#endif
+}
+
 /*
  * Allocate a shared client record
  *
@@ -842,21 +910,15 @@ static int nfs_init_server(struct nfs_server *server,
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
index d2c760e..e30d6d3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -51,6 +51,7 @@
 #include "fscache.h"
 #include "dns_resolve.h"
 #include "pnfs.h"
+#include "nfs.h"
 #include "netns.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
@@ -1629,6 +1630,7 @@ static int __init init_nfs_fs(void)
 #endif
 	if ((err = register_nfs_fs()) != 0)
 		goto out;
+	nfs_register_versions();
 	return 0;
 out:
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index b37ca34..4d147a3 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -488,19 +488,19 @@ static struct rpc_procinfo mnt3_procedures[] = {
 };
 
 
-static const struct rpc_version mnt_version1 = {
+static struct rpc_version mnt_version1 = {
 	.number		= 1,
 	.nrprocs	= ARRAY_SIZE(mnt_procedures),
 	.procs		= mnt_procedures,
 };
 
-static const struct rpc_version mnt_version3 = {
+static struct rpc_version mnt_version3 = {
 	.number		= 3,
 	.nrprocs	= ARRAY_SIZE(mnt3_procedures),
 	.procs		= mnt3_procedures,
 };
 
-static const struct rpc_version *mnt_version[] = {
+static struct rpc_version *mnt_version[] = {
 	NULL,
 	&mnt_version1,
 	NULL,
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
new file mode 100644
index 0000000..05f6849
--- /dev/null
+++ b/fs/nfs/nfs.h
@@ -0,0 +1,35 @@
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
+int init_nfs_v2(void);
+int init_nfs_v3(void);
+int init_nfs_v4(void);
+
+struct nfs_subversion *get_nfs_version(unsigned int);
+struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
+struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
+void register_nfs_version(struct nfs_subversion *);
+void unregister_nfs_version(struct nfs_subversion *);
+
+#endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
new file mode 100644
index 0000000..12fa906
--- /dev/null
+++ b/fs/nfs/nfs2super.c
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include "nfs.h"
+
+static void nfs2_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs2_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+static struct nfs_subversion nfs_v2 = {
+	.version  = 2,
+	.rpc_vers = &nfs_version2,
+	.rpc_ops  = &nfs_v2_clientops,
+
+	.reference = nfs2_reference,
+	.unreference = nfs2_unreference,
+};
+
+int __init init_nfs_v2(void)
+{
+	register_nfs_version(&nfs_v2);
+	return 0;
+}
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index a01084d..5d9ec8b 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -1086,7 +1086,7 @@ struct rpc_procinfo	nfs_procedures[] = {
 	PROC(STATFS,	fhandle,	statfsres,	0),
 };
 
-const struct rpc_version nfs_version2 = {
+struct rpc_version nfs_version2 = {
 	.number			= 2,
 	.nrprocs		= ARRAY_SIZE(nfs_procedures),
 	.procs			= nfs_procedures
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
new file mode 100644
index 0000000..a02c815
--- /dev/null
+++ b/fs/nfs/nfs3super.c
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include "nfs.h"
+
+static void nfs3_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs3_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+static struct nfs_subversion nfs_v3 = {
+	.version  = 3,
+	.rpc_vers = &nfs_version3,
+	.rpc_ops  = &nfs_v3_clientops,
+
+	.reference = nfs3_reference,
+	.unreference = nfs3_unreference,
+};
+
+int __init init_nfs_v3(void)
+{
+	register_nfs_version(&nfs_v3);
+	return 0;
+}
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index a77cc9a..5f9aabd 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -2461,7 +2461,7 @@ struct rpc_procinfo	nfs3_procedures[] = {
 	PROC(COMMIT,		commit,		commit,		5),
 };
 
-const struct rpc_version nfs_version3 = {
+struct rpc_version nfs_version3 = {
 	.number			= 3,
 	.nrprocs		= ARRAY_SIZE(nfs3_procedures),
 	.procs			= nfs3_procedures
@@ -2489,7 +2489,7 @@ static struct rpc_procinfo	nfs3_acl_procedures[] = {
 	},
 };
 
-const struct rpc_version nfsacl_version3 = {
+struct rpc_version nfsacl_version3 = {
 	.number			= 3,
 	.nrprocs		= sizeof(nfs3_acl_procedures)/
 				  sizeof(nfs3_acl_procedures[0]),
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
new file mode 100644
index 0000000..9b2a679
--- /dev/null
+++ b/fs/nfs/nfs4super.c
@@ -0,0 +1,31 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/module.h>
+#include <linux/nfs_fs.h>
+#include "nfs.h"
+
+static void nfs4_reference(void)
+{
+	try_module_get(THIS_MODULE);
+}
+
+static void nfs4_unreference(void)
+{
+	module_put(THIS_MODULE);
+}
+
+static struct nfs_subversion nfs_v4 = {
+	.version  = 4,
+	.rpc_vers = &nfs_version4,
+	.rpc_ops  = &nfs_v4_clientops,
+
+	.reference = nfs4_reference,
+	.unreference = nfs4_unreference,
+};
+
+int __init init_nfs_v4(void)
+{
+	register_nfs_version(&nfs_v4);
+	return 0;
+}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ca288d1..c091f73 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -7114,7 +7114,7 @@ struct rpc_procinfo	nfs4_procedures[] = {
 #endif /* CONFIG_NFS_V4_1 */
 };
 
-const struct rpc_version nfs_version4 = {
+struct rpc_version nfs_version4 = {
 	.number			= 4,
 	.nrprocs		= ARRAY_SIZE(nfs4_procedures),
 	.procs			= nfs4_procedures
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8e210b2..c5a2085 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -64,6 +64,7 @@
 #include "internal.h"
 #include "fscache.h"
 #include "pnfs.h"
+#include "nfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -2220,6 +2221,22 @@ static int nfs_bdi_register(struct nfs_server *server)
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
 
+static int nfs_register(struct nfs_server *server)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+	int err = nfs_bdi_register(server);
+	if (!err)
+		nfs_mod->reference();
+	return err;
+}
+
+static void nfs_unregister(struct nfs_server *server)
+{
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
+	bdi_unregister(&server->backing_dev_info);
+	nfs_mod->unreference();
+}
+
 static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data)
 {
@@ -2232,6 +2249,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
 	};
+	struct nfs_subversion *nfs_mod;
 	int error;
 
 	data = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
@@ -2246,6 +2264,12 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
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
@@ -2279,7 +2303,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
+		error = nfs_register(server);
 		if (error) {
 			mntroot = ERR_PTR(error);
 			goto error_splat_bdi;
@@ -2316,7 +2340,7 @@ error_splat_root:
 	mntroot = ERR_PTR(error);
 error_splat_super:
 	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
+		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
@@ -2328,9 +2352,7 @@ error_splat_bdi:
  */
 static void nfs_put_super(struct super_block *s)
 {
-	struct nfs_server *server = NFS_SB(s);
-
-	bdi_unregister(&server->backing_dev_info);
+	nfs_unregister(NFS_SB(s));
 }
 
 /*
@@ -2390,7 +2412,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
+		error = nfs_register(server);
 		if (error)
 			goto error_splat_bdi;
 	}
@@ -2428,7 +2450,7 @@ out_err_noserver:
 
 error_splat_super:
 	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
+		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
 	dprintk("<-- nfs_xdev_mount() = %d [splat]\n", error);
@@ -2659,7 +2681,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
+		error = nfs_register(server);
 		if (error)
 			goto error_splat_bdi;
 	}
@@ -2697,7 +2719,7 @@ error_splat_root:
 	dput(mntroot);
 error_splat_super:
 	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
+		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
 	goto out;
@@ -2919,7 +2941,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
+		error = nfs_register(server);
 		if (error)
 			goto error_splat_bdi;
 	}
@@ -2956,7 +2978,7 @@ out_err_noserver:
 
 error_splat_super:
 	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
+		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
 	dprintk("<-- nfs4_xdev_mount() = %d [splat]\n", error);
@@ -3010,7 +3032,7 @@ nfs4_remote_referral_mount(struct file_system_type *fs_type, int flags,
 		nfs_free_server(server);
 		server = NULL;
 	} else {
-		error = nfs_bdi_register(server);
+		error = nfs_register(server);
 		if (error)
 			goto error_splat_bdi;
 	}
@@ -3050,7 +3072,7 @@ out_err_nofh:
 
 error_splat_super:
 	if (server && !s->s_root)
-		bdi_unregister(&server->backing_dev_info);
+		nfs_unregister(server);
 error_splat_bdi:
 	deactivate_locked_super(s);
 	nfs_free_fhandle(mntfh);
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 0e262f3..74d19d4 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -605,7 +605,7 @@ static struct rpc_version nfs_cb_version4 = {
 	.procs			= nfs4_cb_procedures
 };
 
-static const struct rpc_version *nfs_cb_version[] = {
+static struct rpc_version *nfs_cb_version[] = {
 	&nfs_cb_version4,
 };
 
diff --git a/include/linux/lockd/xdr4.h b/include/linux/lockd/xdr4.h
index e58c88b..7353821 100644
--- a/include/linux/lockd/xdr4.h
+++ b/include/linux/lockd/xdr4.h
@@ -42,6 +42,6 @@ int	nlmclt_encode_lockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_cancargs(struct rpc_rqst *, u32 *, struct nlm_args *);
 int	nlmclt_encode_unlockargs(struct rpc_rqst *, u32 *, struct nlm_args *);
  */
-extern const struct rpc_version nlm_version4;
+extern struct rpc_version nlm_version4;
 
 #endif /* LOCKD_XDR4_H */
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 144419a..9eaa8f7 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1274,11 +1274,11 @@ struct nfs_rpc_ops {
 extern const struct nfs_rpc_ops	nfs_v2_clientops;
 extern const struct nfs_rpc_ops	nfs_v3_clientops;
 extern const struct nfs_rpc_ops	nfs_v4_clientops;
-extern const struct rpc_version nfs_version2;
-extern const struct rpc_version nfs_version3;
-extern const struct rpc_version nfs_version4;
+extern struct rpc_version nfs_version2;
+extern struct rpc_version nfs_version3;
+extern struct rpc_version nfs_version4;
 
-extern const struct rpc_version nfsacl_version3;
+extern struct rpc_version nfsacl_version3;
 extern const struct rpc_program nfsacl_program;
 
 #endif
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a4c62e9..0c0ee9e 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -73,7 +73,7 @@ struct rpc_program {
 	const char *		name;		/* protocol name */
 	u32			number;		/* program number */
 	unsigned int		nrvers;		/* number of versions */
-	const struct rpc_version **	version;	/* version array */
+	struct rpc_version **	version;	/* version array */
 	struct rpc_stat *	stats;		/* statistics */
 	const char *		pipe_dir_name;	/* path to rpc_pipefs dir */
 };
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index b1f08bd..bd3954f 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -1075,25 +1075,25 @@ static const struct rpcb_info rpcb_next_version6[] = {
 	},
 };
 
-static const struct rpc_version rpcb_version2 = {
+static struct rpc_version rpcb_version2 = {
 	.number		= RPCBVERS_2,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures2),
 	.procs		= rpcb_procedures2
 };
 
-static const struct rpc_version rpcb_version3 = {
+static struct rpc_version rpcb_version3 = {
 	.number		= RPCBVERS_3,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures3),
 	.procs		= rpcb_procedures3
 };
 
-static const struct rpc_version rpcb_version4 = {
+static struct rpc_version rpcb_version4 = {
 	.number		= RPCBVERS_4,
 	.nrprocs	= ARRAY_SIZE(rpcb_procedures4),
 	.procs		= rpcb_procedures4
 };
 
-static const struct rpc_version *rpcb_version[] = {
+static struct rpc_version *rpcb_version[] = {
 	NULL,
 	NULL,
 	&rpcb_version2,
-- 
1.7.9

