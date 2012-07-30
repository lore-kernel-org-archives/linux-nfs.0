Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50661 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754786Ab2G3UFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/10] NFS: Only initialize the ACL client in the v3 case
Date: Mon, 30 Jul 2012 16:05:19 -0400
Message-Id: <1343678725-8659-5-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

v2 and v4 don't use it, so I create two new nfs_rpc_ops functions to
initialize the ACL client only when we are using v3.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/Makefile         |  2 +-
 fs/nfs/client.c         | 61 ++++------------------------------------------
 fs/nfs/internal.h       | 15 ++++++++----
 fs/nfs/nfs3client.c     | 65 +++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs3proc.c       |  2 ++
 fs/nfs/nfs4client.c     | 10 +++++---
 fs/nfs/nfs4proc.c       |  2 ++
 fs/nfs/nfs4super.c      |  2 +-
 fs/nfs/proc.c           |  2 ++
 fs/nfs/super.c          |  4 +--
 include/linux/nfs_xdr.h |  3 +++
 11 files changed, 99 insertions(+), 69 deletions(-)
 create mode 100644 fs/nfs/nfs3client.c

diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 66dd307..7ca0125 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -10,7 +10,7 @@ nfs-y 			:= client.o dir.o file.o getroot.o inode.o super.o \
 			   dns_resolve.o cache_lib.o
 nfs-$(CONFIG_ROOT_NFS)	+= nfsroot.o
 nfs-$(CONFIG_NFS_V2)	+= nfs2super.o proc.o nfs2xdr.o
-nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3proc.o nfs3xdr.o
+nfs-$(CONFIG_NFS_V3)	+= nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
 nfs-$(CONFIG_NFS_V3_ACL)	+= nfs3acl.o
 nfs-$(CONFIG_NFS_V4)	+= nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
 			   nfs4super.o nfs4file.o delegation.o idmap.o \
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 462de24..1f29082 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -83,22 +83,6 @@ struct rpc_stat nfs_rpcstat = {
 	.program		= &nfs_program
 };
 
-
-#ifdef CONFIG_NFS_V3_ACL
-static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
-static const struct rpc_version *nfsacl_version[] = {
-	[3]			= &nfsacl_version3,
-};
-
-const struct rpc_program nfsacl_program = {
-	.name			= "nfsacl",
-	.number			= NFS_ACL_PROGRAM,
-	.nrvers			= ARRAY_SIZE(nfsacl_version),
-	.version		= nfsacl_version,
-	.stats			= &nfsacl_rpcstat,
-};
-#endif  /* CONFIG_NFS_V3_ACL */
-
 static struct nfs_subversion *find_nfs_version(unsigned int version)
 {
 	struct nfs_subversion *nfs;
@@ -696,36 +680,6 @@ static int nfs_start_lockd(struct nfs_server *server)
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
 int nfs_init_server_rpcclient(struct nfs_server *server,
@@ -874,8 +828,6 @@ static int nfs_init_server(struct nfs_server *server,
 	server->mountd_protocol = data->mount_server.protocol;
 
 	server->namelen  = data->namlen;
-	/* Create a client RPC handle for the NFSv3 ACL management interface */
-	nfs_init_server_aclclient(server);
 	dprintk("<-- nfs_init_server() = 0 [new %p]\n", clp);
 	return 0;
 
@@ -1108,8 +1060,7 @@ void nfs_free_server(struct nfs_server *server)
  * Create a version 2 or 3 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
-				     struct nfs_fh *mntfh,
+struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 				     struct nfs_subversion *nfs_mod)
 {
 	struct nfs_server *server;
@@ -1126,7 +1077,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 		goto error;
 
 	/* Get a client representation */
-	error = nfs_init_server(server, data, nfs_mod);
+	error = nfs_init_server(server, mount_info->parsed, nfs_mod);
 	if (error < 0)
 		goto error;
 
@@ -1135,13 +1086,13 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs_probe_fsinfo(server, mntfh, fattr);
+	error = nfs_probe_fsinfo(server, mount_info->mntfh, fattr);
 	if (error < 0)
 		goto error;
 	if (server->nfs_client->rpc_ops->version == 3) {
 		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
 			server->namelen = NFS3_MAXNAMLEN;
-		if (!(data->flags & NFS_MOUNT_NORDIRPLUS))
+		if (!(mount_info->parsed->flags & NFS_MOUNT_NORDIRPLUS))
 			server->caps |= NFS_CAP_READDIRPLUS;
 	} else {
 		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
@@ -1149,7 +1100,7 @@ struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = server->nfs_client->rpc_ops->getattr(server, mntfh, fattr);
+		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
@@ -1210,8 +1161,6 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 			flavor);
 	if (error < 0)
 		goto out_free_server;
-	if (!IS_ERR(source->client_acl))
-		nfs_init_server_aclclient(server);
 
 	/* probe the filesystem info for this server filesystem */
 	error = nfs_probe_fsinfo(server, fh, fattr_fsinfo);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3364ecc..2151baf 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -187,13 +187,11 @@ extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
 nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
 				struct nfs4_sessionid *);
-extern struct nfs_server *nfs_create_server(
-					const struct nfs_parsed_mount_data *,
-					struct nfs_fh *,
+extern struct nfs_server *nfs_create_server(struct nfs_mount_info *,
 					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_server(
-					const struct nfs_parsed_mount_data *,
-					struct nfs_fh *);
+					struct nfs_mount_info *,
+					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 						      struct nfs_fh *);
 extern void nfs_free_server(struct nfs_server *server);
@@ -225,6 +223,13 @@ static inline void nfs_fs_proc_exit(void)
 int nfs_sockaddr_match_ipaddr(const struct sockaddr *, const struct sockaddr *);
 #endif
 
+/* nfs3client.c */
+#ifdef CONFIG_NFS_V3
+struct nfs_server *nfs3_create_server(struct nfs_mount_info *, struct nfs_subversion *);
+struct nfs_server *nfs3_clone_server(struct nfs_server *, struct nfs_fh *,
+				     struct nfs_fattr *, rpc_authflavor_t);
+#endif
+
 /* callback_xdr.c */
 extern struct svc_version nfs4_callback_version1;
 extern struct svc_version nfs4_callback_version4;
diff --git a/fs/nfs/nfs3client.c b/fs/nfs/nfs3client.c
new file mode 100644
index 0000000..b3fc65e
--- /dev/null
+++ b/fs/nfs/nfs3client.c
@@ -0,0 +1,65 @@
+#include <linux/nfs_fs.h>
+#include <linux/nfs_mount.h>
+#include "internal.h"
+
+#ifdef CONFIG_NFS_V3_ACL
+static struct rpc_stat		nfsacl_rpcstat = { &nfsacl_program };
+static const struct rpc_version *nfsacl_version[] = {
+	[3]			= &nfsacl_version3,
+};
+
+const struct rpc_program nfsacl_program = {
+	.name			= "nfsacl",
+	.number			= NFS_ACL_PROGRAM,
+	.nrvers			= ARRAY_SIZE(nfsacl_version),
+	.version		= nfsacl_version,
+	.stats			= &nfsacl_rpcstat,
+};
+
+/*
+ * Initialise an NFSv3 ACL client connection
+ */
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
+struct nfs_server *nfs3_create_server(struct nfs_mount_info *mount_info,
+				      struct nfs_subversion *nfs_mod)
+{
+	struct nfs_server *server = nfs_create_server(mount_info, nfs_mod);
+	/* Create a client RPC handle for the NFS v3 ACL management interface */
+	if (!IS_ERR(server))
+		nfs_init_server_aclclient(server);
+	return server;
+}
+
+struct nfs_server *nfs3_clone_server(struct nfs_server *source,
+				     struct nfs_fh *fh,
+				     struct nfs_fattr *fattr,
+				     rpc_authflavor_t flavor)
+{
+	struct nfs_server *server = nfs_clone_server(source, fh, fattr, flavor);
+	if (!IS_ERR(server) && !IS_ERR(source->client_acl))
+		nfs_init_server_aclclient(server);
+	return server;
+}
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4f4cb8e..0952c79 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -969,4 +969,6 @@ const struct nfs_rpc_ops nfs_v3_clientops = {
 	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
+	.create_server	= nfs3_create_server,
+	.clone_server	= nfs3_clone_server,
 };
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 769e798..b2d409d 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -574,8 +574,10 @@ error:
  * Create a version 4 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
-				      struct nfs_fh *mntfh)
+/*struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
+				      struct nfs_fh *mntfh)*/
+struct nfs_server *nfs4_create_server(struct nfs_mount_info *mount_info,
+				      struct nfs_subversion *nfs_mod)
 {
 	struct nfs_server *server;
 	int error;
@@ -587,11 +589,11 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 		return ERR_PTR(-ENOMEM);
 
 	/* set up the general RPC client */
-	error = nfs4_init_server(server, data);
+	error = nfs4_init_server(server, mount_info->parsed);
 	if (error < 0)
 		goto error;
 
-	error = nfs4_server_common_setup(server, mntfh);
+	error = nfs4_server_common_setup(server, mount_info->mntfh);
 	if (error < 0)
 		goto error;
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ac78df9..2e87727 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6916,6 +6916,8 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.alloc_client	= nfs4_alloc_client,
 	.init_client	= nfs4_init_client,
 	.free_client	= nfs4_free_client,
+	.create_server	= nfs4_create_server,
+	.clone_server	= nfs_clone_server,
 };
 
 static const struct xattr_handler nfs4_xattr_nfs4_acl_handler = {
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 9384f66..a628362 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -105,7 +105,7 @@ nfs4_remote_mount(struct file_system_type *fs_type, int flags,
 	mount_info->set_security = nfs_set_sb_security;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(mount_info->parsed, mount_info->mntfh);
+	server = nfs4_create_server(mount_info, &nfs_v4);
 	if (IS_ERR(server)) {
 		mntroot = ERR_CAST(server);
 		goto out;
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index ebb3d9c..50a88c3 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -817,4 +817,6 @@ const struct nfs_rpc_ops nfs_v2_clientops = {
 	.alloc_client	= nfs_alloc_client,
 	.init_client	= nfs_init_client,
 	.free_client	= nfs_free_client,
+	.create_server	= nfs_create_server,
+	.clone_server	= nfs_clone_server,
 };
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5fca59d7..a5f9fb3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1664,7 +1664,7 @@ struct dentry *nfs_try_mount(int flags, const char *dev_name,
 	}
 
 	/* Get a volume representation */
-	server = nfs_create_server(mount_info->parsed, mount_info->mntfh, nfs_mod);
+	server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
 	if (IS_ERR(server))
 		return ERR_CAST(server);
 
@@ -2458,7 +2458,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	mount_info.mntfh = mount_info.cloned->fh;
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
+	server = nfs_mod->rpc_ops->clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index bc7415b..6311820 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1439,6 +1439,9 @@ struct nfs_rpc_ops {
 		(*init_client) (struct nfs_client *, const struct rpc_timeout *,
 				const char *, rpc_authflavor_t);
 	void	(*free_client) (struct nfs_client *);
+	struct nfs_server *(*create_server)(struct nfs_mount_info *, struct nfs_subversion *);
+	struct nfs_server *(*clone_server)(struct nfs_server *, struct nfs_fh *,
+					   struct nfs_fattr *, rpc_authflavor_t);
 };
 
 /*
-- 
1.7.11.3

