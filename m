Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758462Ab2CUPVQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:16 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 08/23] NFS: Only initialize the ACL client in the v3 case
Date: Wed, 21 Mar 2012 11:20:38 -0400
Message-Id: <1332343253-24970-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v4 don't use it, so the function can be limited to v3 only.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile     |    2 +-
 fs/nfs/client.c     |   35 +----------------------------
 fs/nfs/nfs.h        |    3 ++-
 fs/nfs/nfs2super.c  |    6 ++++-
 fs/nfs/nfs3client.c |   62 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3super.c  |   12 ++++++++--
 fs/nfs/nfs4super.c  |    6 ++++-
 fs/nfs/super.c      |   12 ++--------
 8 files changed, 88 insertions(+), 50 deletions(-)
 create mode 100644 fs/nfs/nfs3client.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index bc2ba86..6764e66 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -9,7 +9,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   write.o namespace.o mount_clnt.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3proc.o nfs3xdr.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o delegation.o idmap.o \
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ee4a154..5db8005 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -810,36 +810,6 @@ static int nfs_start_lockd(struct nfs_server *server)
 }
 
 /*
- * Initialise an NFSv3 ACL client connection
- */
-#ifdef CONFIG_NFS_V3_ACL
-static void nfs_init_server_aclclient(struct nfs_server *server)
-{
-	if (server->nfs_client->rpc_ops->version != 3)
-		goto out_noacl;
-	if (server->flags & NFS_MOUNT_NOACL)
-		goto out_noacl;
-
-	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
-	if (IS_ERR(server->client_acl))
-		goto out_noacl;
-
-	/* No errors! Assume that Sun nfsacls are supported */
-	server->caps |= NFS_CAP_ACLS;
-	return;
-
-out_noacl:
-	server->caps &= ~NFS_CAP_ACLS;
-}
-#else
-static inline void nfs_init_server_aclclient(struct nfs_server *server)
-{
-	server->flags &= ~NFS_MOUNT_NOACL;
-	server->caps &= ~NFS_CAP_ACLS;
-}
-#endif
-
-/*
  * Create a general RPC client
  */
 static int nfs_init_server_rpcclient(struct nfs_server *server,
@@ -986,8 +956,6 @@ static int nfs_init_server(struct nfs_server *server,
 	server->mountd_protocol = data->mount_server.protocol;
 
 	server->namelen  = data->namlen;
-	/* Create a client RPC handle for the NFSv3 ACL management interface */
-	nfs_init_server_aclclient(server);
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -1834,8 +1802,6 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 			source->client->cl_auth->au_flavor);
 	if (error < 0)
 		goto out_free_server;
-	if (!IS_ERR(source->client_acl))
-		nfs_init_server_aclclient(server);
 
 	/* probe the filesystem info for this server filesystem */
 	error = nfs_probe_fsinfo(server, fh, fattr_fsinfo);
@@ -1866,6 +1832,7 @@ out_free_server:
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
+EXPORT_SYMBOL_GPL(nfs_clone_server);
 
 void nfs_clients_init(struct net *net)
 {
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index a5e6a63..8ac594b 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -45,7 +45,8 @@ extern struct file_system_type nfs_fs_type;
 struct dentry *_nfs_fs_mount(struct file_system_type *, struct nfs_server *,
 			     int, const char *, struct nfs_fh *,
 			     struct nfs_parsed_mount_data *);
-struct dentry *_nfs_xdev_mount(struct file_system_type *, int, const char *, void *, int);
+struct dentry *_nfs_xdev_mount(struct file_system_type *, struct nfs_server *,
+			       int, const char *, void *, int);
 
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index d1074a9..ddcc4d1 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -6,6 +6,7 @@
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
+#include "internal.h"
 #include "nfs.h"
 
 static void nfs2_reference(void)
@@ -32,7 +33,10 @@ static struct dentry *nfs2_fs_mount(struct file_system_type *fs_type,
 static struct dentry *nfs2_xdev_mount(int flags, const char *dev_name,
 				      struct nfs_clone_mount *data)
 {
-	return _nfs_xdev_mount(&nfs_fs_type, flags, dev_name, data, NFS_MOUNT_UNSHARED);
+	struct nfs_server *server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+	return _nfs_xdev_mount(&nfs_fs_type, server, flags, dev_name, data, NFS_MOUNT_UNSHARED);
 }
 
 static struct nfs_subversion nfs_v2 = {
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
new file mode 100644
index 0000000..c2e6593
--- /dev/null
+++ b/fs/nfs/nfs3client.c
@@ -0,0 +1,62 @@
+/* Copyright (C) 2006 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+#include <linux/types.h>
+#include <linux/nfs.h>
+#include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
+#include "internal.h"
+#include "nfs.h"
+
+/*
+ * Initialise an NFSv3 ACL client connection
+ */
+#ifdef CONFIG_NFS_V3_ACL
+static void nfs_init_server_aclclient(struct nfs_server *server)
+{
+	if (server->flags & NFS_MOUNT_NOACL)
+		goto out_noacl;
+
+	server->client_acl = rpc_bind_new_program(server->client, &nfsacl_program, 3);
+	if (IS_ERR(server->client_acl))
+		goto out_noacl;
+
+	/* No errors! Assume that Sun nfsacls are supported */
+	server->caps |= NFS_CAP_ACLS;
+	return;
+
+out_noacl:
+	server->caps &= ~NFS_CAP_ACLS;
+}
+#else
+static inline void nfs_init_server_aclclient(struct nfs_server *server)
+{
+	server->flags &= ~NFS_MOUNT_NOACL;
+	server->caps &= ~NFS_CAP_ACLS;
+}
+#endif
+
+struct nfs_server *nfs3_create_server(const struct nfs_parsed_mount_data *data,
+				      struct nfs_fh *mntfh)
+{
+	struct nfs_server *server = nfs_create_server(data, mntfh);
+	/* Create a client RPC handle for the NFS v3 ACL management interface */
+	if (server)
+		nfs_init_server_aclclient(server);
+	return server;
+}
+
+struct nfs_server *nfs3_clone_server(struct nfs_server *source,
+				     struct nfs_fh *fh,
+				     struct nfs_fattr *fattr)
+{
+	struct nfs_server *server = nfs_clone_server(source, fh, fattr);
+	if (server && !IS_ERR(source->client_acl))
+		nfs_init_server_aclclient(server);
+	return server;
+}
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index 7bdd388..5702895 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -4,8 +4,13 @@
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_mount.h>
+#include "internal.h"
 #include "nfs.h"
 
+/* From nfs3client.c */
+struct nfs_server *nfs3_create_server(const struct nfs_parsed_mount_data *, struct nfs_fh *);
+struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *);
+
 static void nfs3_reference(void)
 {
 	try_module_get(THIS_MODULE);
@@ -21,7 +26,7 @@ struct dentry *nfs3_fs_mount(struct file_system_type *fs_type,
 			     struct nfs_fh *mntfh,
 			     struct nfs_parsed_mount_data *data)
 {
-	struct nfs_server *server = nfs_create_server(data, mntfh);
+	struct nfs_server *server = nfs3_create_server(data, mntfh);
 	if (IS_ERR(server))
 		return ERR_CAST(server);
 	return _nfs_fs_mount(fs_type, server, flags, dev_name, mntfh, data);
@@ -30,7 +35,10 @@ struct dentry *nfs3_fs_mount(struct file_system_type *fs_type,
 static struct dentry *nfs3_xdev_mount(int flags, const char *dev_name,
 				      struct nfs_clone_mount *data)
 {
-	return _nfs_xdev_mount(&nfs_fs_type, flags, dev_name, data, NFS_MOUNT_UNSHARED);
+	struct nfs_server *server = nfs3_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+	return _nfs_xdev_mount(&nfs_fs_type, server, flags, dev_name, data, NFS_MOUNT_UNSHARED);
 }
 
 static struct nfs_subversion nfs_v3 = {
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 8a297c5..f6c8f9f 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -4,6 +4,7 @@
 #include <linux/module.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs4_mount.h>
+#include "internal.h"
 #include "nfs4_fs.h"
 #include "nfs.h"
 
@@ -31,7 +32,10 @@ struct dentry *nfs4_fs_mount(struct file_system_type *fs_type,
 struct dentry *nfs4_xdev_mount(int flags, const char *dev_name,
 			       struct nfs_clone_mount *data)
 {
-	return _nfs_xdev_mount(&nfs4_fs_type, flags, dev_name, data, NFS4_MOUNT_UNSHARED);
+	struct nfs_server *server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	if (IS_ERR(server))
+		return ERR_CAST(server);
+	return _nfs_xdev_mount(&nfs4_fs_type, server, flags, dev_name, data, NFS4_MOUNT_UNSHARED);
 }
 
 static struct nfs_subversion nfs_v4 = {
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 994a0cc..810b28e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2437,12 +2437,11 @@ static void nfs_kill_super(struct super_block *s)
  * Clone an NFS2/3 server record on xdev traversal (FSID-change)
  */
 struct dentry *
-_nfs_xdev_mount(struct file_system_type *fs_type, int flags,
-		const char *dev_name, void *raw_data, int unshared_flag)
+_nfs_xdev_mount(struct file_system_type *fs_type, struct nfs_server *server,
+		int flags, const char *dev_name, void *raw_data, int unshared_flag)
 {
 	struct nfs_clone_mount *data = raw_data;
 	struct super_block *s;
-	struct nfs_server *server;
 	struct dentry *mntroot;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
@@ -2452,12 +2451,6 @@ _nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 
 	dprintk("--> _nfs_xdev_mount()\n");
 
-	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
-	if (IS_ERR(server)) {
-		error = PTR_ERR(server);
-		goto out_err_noserver;
-	}
 	sb_mntdata.server = server;
 
 	if (server->flags & unshared_flag)
@@ -2510,7 +2503,6 @@ _nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 
 out_err_nosb:
 	nfs_free_server(server);
-out_err_noserver:
 	dprintk("<-- _nfs_xdev_mount() = %d [error]\n", error);
 	return ERR_PTR(error);
 
-- 
1.7.9.4

