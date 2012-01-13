Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:41779 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932709Ab2AMULP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:15 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 08/44] NFS: Created custom init_aclclient() functions
Date: Fri, 13 Jan 2012 15:10:17 -0500
Message-Id: <1326485453-1350-9-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This should be filled in by the v2, v3 and v4 nfs_subversion structures
for creating an aclclient.  Right now, v2 and v4 clear the flags while
v3 does some extra setup.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |   17 ++++++++++++-----
 fs/nfs/nfs.h         |    1 +
 fs/nfs/nfs2/Makefile |    2 +-
 fs/nfs/nfs2/client.c |   12 ++++++++++++
 fs/nfs/nfs2/module.c |    1 +
 fs/nfs/nfs2/nfs2.h   |    2 ++
 6 files changed, 29 insertions(+), 6 deletions(-)
 create mode 100644 fs/nfs/nfs2/client.c

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 20d1708..3f36e6e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -53,6 +53,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
+static void nfs_init_server_aclclient(struct nfs_server *server);
+
 static DEFINE_SPINLOCK(nfs_client_lock);
 static DEFINE_SPINLOCK(nfs_version_lock);
 static LIST_HEAD(nfs_versions);
@@ -132,8 +134,10 @@ static struct nfs_subversion nfs_v3_mod = {
 	.version  = 3,
 	.rpc_vers = &nfs_version3,
 	.rpc_ops  = &nfs_v3_clientops,
+
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
+	.init_aclclient = nfs_init_server_aclclient,
 };
 #endif /* CONFIG_NFS_V3 */
 
@@ -142,8 +146,10 @@ static struct nfs_subversion nfs_v4_mod = {
 	.version  = 4,
 	.rpc_vers = &nfs_version4,
 	.rpc_ops  = &nfs_v4_clientops,
+
 	.reference = nfs_module_null_function,
 	.unreference = nfs_module_null_function,
+	.init_aclclient = nfs_init_server_aclclient,
 };
 #endif /* CONFIG_NFS_V4 */
 
@@ -830,8 +836,6 @@ static int nfs_start_lockd(struct nfs_server *server)
 #ifdef CONFIG_NFS_V3_ACL
 static void nfs_init_server_aclclient(struct nfs_server *server)
 {
-	if (server->nfs_client->rpc_ops->version != 3)
-		goto out_noacl;
 	if (server->flags & NFS_MOUNT_NOACL)
 		goto out_noacl;
 
@@ -1001,7 +1005,7 @@ static int nfs_init_server(struct nfs_server *server,
 
 	server->namelen  = data->namlen;
 	/* Create a client RPC handle for the NFSv3 ACL management interface */
-	nfs_init_server_aclclient(server);
+	nfs_mod->init_aclclient(server);
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -1814,6 +1818,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 {
 	struct nfs_server *server;
 	struct nfs_fattr *fattr_fsinfo;
+	struct nfs_subversion *nfs_mod;
 	int error;
 
 	dprintk("--> nfs_clone_server(,%llx:%llx,)\n",
@@ -1842,8 +1847,10 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 			source->client->cl_auth->au_flavor);
 	if (error < 0)
 		goto out_free_server;
-	if (!IS_ERR(source->client_acl))
-		nfs_init_server_aclclient(server);
+	if (!IS_ERR(source->client_acl)) {
+		nfs_mod = get_nfs_server_version(server);
+		nfs_mod->init_aclclient(server);
+	}
 
 	/* probe the filesystem info for this server filesystem */
 	error = nfs_probe_fsinfo(server, fh, fattr_fsinfo);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index b1fe653..6b746d7 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -19,6 +19,7 @@ struct nfs_subversion {
 
 	void (*reference)(void);	/* For reference counting */
 	void (*unreference)(void);	/* Also for reference counting */
+	void (*init_aclclient)(struct nfs_server *);
 };
 
 void nfs_register_versions(void);
diff --git a/fs/nfs/nfs2/Makefile b/fs/nfs/nfs2/Makefile
index 0ca3b59..d5de35f 100644
--- a/fs/nfs/nfs2/Makefile
+++ b/fs/nfs/nfs2/Makefile
@@ -2,4 +2,4 @@
 # Makefile for NFS v2
 #
 obj-$(CONFIG_NFS_V2) += nfs2.o
-nfs2-y := module.o dir.o file.o proc.o xdr.o
+nfs2-y := module.o client.o dir.o file.o proc.o xdr.o
diff --git a/fs/nfs/nfs2/client.c b/fs/nfs/nfs2/client.c
new file mode 100644
index 0000000..1150704
--- /dev/null
+++ b/fs/nfs/nfs2/client.c
@@ -0,0 +1,12 @@
+/*
+ * Copyright (c) 2012 Netapp, Inc. All rights reserved.
+ */
+#include <linux/sunrpc/sched.h>
+#include <linux/nfs_fs_sb.h>
+#include <linux/nfs_mount.h>
+
+void nfs2_init_aclclient(struct nfs_server *server)
+{
+	server->flags &= ~NFS_MOUNT_NOACL;
+	server->caps &= ~NFS_CAP_ACLS;
+}
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 04d415a..60302c7 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -26,6 +26,7 @@ struct nfs_subversion nfs_v2 = {
 
 	.reference = nfs2_reference,
 	.unreference = nfs2_unreference,
+	.init_aclclient = nfs2_init_aclclient,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs2/nfs2.h b/fs/nfs/nfs2/nfs2.h
index 6274821..76e62bf 100644
--- a/fs/nfs/nfs2/nfs2.h
+++ b/fs/nfs/nfs2/nfs2.h
@@ -7,6 +7,8 @@
 extern struct rpc_version nfs_version2;
 extern const struct nfs_rpc_ops nfs_v2_clientops;
 
+void nfs2_init_aclclient(struct nfs_server *);
+
 extern const struct inode_operations nfs_file_inode_operations;
 extern const struct file_operations nfs_file_operations;
 
-- 
1.7.8.3

