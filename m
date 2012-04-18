Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab2DRRqc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:32 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 1/6] NFS: pre-clone the rpc_clnt
Date: Wed, 18 Apr 2012 13:46:20 -0400
Message-Id: <1334771185-9841-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

A later patch will need an rpc_clnt with the correct authflavor to find
properties of a submount.  It's easiest to set up the rpc_clnt once and
pass it to nfs_clone_server() instead of cloning the clnt multiple times.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c        |   50 ++++++++++++++++++++++++++++--------------------
 fs/nfs/internal.h      |    3 ++-
 fs/nfs/namespace.c     |    8 +++++++-
 fs/nfs/nfs4namespace.c |    2 +-
 fs/nfs/super.c         |    4 ++--
 5 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index da7b5e4..1faa091 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -772,36 +772,45 @@ static inline void nfs_init_server_aclclient(struct nfs_server *server)
 /*
  * Create a general RPC client
  */
-static int nfs_init_server_rpcclient(struct nfs_server *server,
+static void nfs_init_server_rpcclient(struct nfs_server *server,
+				      struct rpc_clnt *client,
+				      const struct rpc_timeout *timeo)
+{
+	memcpy(&client->cl_timeout_default, timeo, sizeof(client->cl_timeout_default));
+
+	client->cl_timeout = &client->cl_timeout_default;
+	client->cl_softrtry = 0;
+	if (server->flags & NFS_MOUNT_SOFT)
+		client->cl_softrtry = 1;
+
+	server->client = client;
+}
+
+static int nfs_alloc_server_rpcclient(struct nfs_server *server,
 		const struct rpc_timeout *timeo,
 		rpc_authflavor_t pseudoflavour)
 {
+	struct rpc_clnt *client;
 	struct nfs_client *clp = server->nfs_client;
 
-	server->client = rpc_clone_client(clp->cl_rpcclient);
-	if (IS_ERR(server->client)) {
+	client = rpc_clone_client(clp->cl_rpcclient);
+	if (IS_ERR(client)) {
 		dprintk("%s: couldn't create rpc_client!\n", __func__);
 		return PTR_ERR(server->client);
 	}
 
-	memcpy(&server->client->cl_timeout_default,
-			timeo,
-			sizeof(server->client->cl_timeout_default));
-	server->client->cl_timeout = &server->client->cl_timeout_default;
-
 	if (pseudoflavour != clp->cl_rpcclient->cl_auth->au_flavor) {
 		struct rpc_auth *auth;
 
-		auth = rpcauth_create(pseudoflavour, server->client);
+		auth = rpcauth_create(pseudoflavour, client);
 		if (IS_ERR(auth)) {
 			dprintk("%s: couldn't create credcache!\n", __func__);
+			rpc_shutdown_client(client);
 			return PTR_ERR(auth);
 		}
 	}
-	server->client->cl_softrtry = 0;
-	if (server->flags & NFS_MOUNT_SOFT)
-		server->client->cl_softrtry = 1;
 
+	nfs_init_server_rpcclient(server, client, timeo);
 	return 0;
 }
 
@@ -899,7 +908,7 @@ static int nfs_init_server(struct nfs_server *server,
 
 	server->port = data->nfs_server.port;
 
-	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
+	error = nfs_alloc_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 	if (error < 0)
 		goto error;
 
@@ -1626,7 +1635,7 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	server->port = data->nfs_server.port;
 
-	error = nfs_init_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
+	error = nfs_alloc_server_rpcclient(server, &timeparms, data->auth_flavors[0]);
 
 error:
 	/* Done */
@@ -1697,7 +1706,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 				data->addr,
 				data->addrlen,
 				parent_client->cl_ipaddr,
-				data->authflavor,
+				data->client->cl_auth->au_flavor,
 				rpc_protocol(parent_server->client),
 				parent_server->client->cl_timeout,
 				parent_client->cl_mvops->minor_version,
@@ -1705,7 +1714,8 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 	if (error < 0)
 		goto error;
 
-	error = nfs_init_server_rpcclient(server, parent_server->client->cl_timeout, data->authflavor);
+	error = nfs_alloc_server_rpcclient(server, parent_server->client->cl_timeout,
+					   data->client->cl_auth->au_flavor);
 	if (error < 0)
 		goto error;
 
@@ -1728,6 +1738,7 @@ error:
  * Clone an NFS2, NFS3 or NFS4 server record
  */
 struct nfs_server *nfs_clone_server(struct nfs_server *source,
+				    struct rpc_clnt *client,
 				    struct nfs_fh *fh,
 				    struct nfs_fattr *fattr)
 {
@@ -1756,11 +1767,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 
 	server->fsid = fattr->fsid;
 
-	error = nfs_init_server_rpcclient(server,
-			source->client->cl_timeout,
-			source->client->cl_auth->au_flavor);
-	if (error < 0)
-		goto out_free_server;
+	nfs_init_server_rpcclient(server, client, source->client->cl_timeout);
 	if (!IS_ERR(source->client_acl))
 		nfs_init_server_aclclient(server);
 
@@ -1788,6 +1795,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 	return server;
 
 out_free_server:
+	server->client = NULL;
 	nfs_free_fattr(fattr_fsinfo);
 	nfs_free_server(server);
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 2476dc6..b499cd0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -59,13 +59,13 @@ static inline int nfs_attr_use_mounted_on_fileid(struct nfs_fattr *fattr)
 struct nfs_clone_mount {
 	const struct super_block *sb;
 	const struct dentry *dentry;
+	struct rpc_clnt *client;
 	struct nfs_fh *fh;
 	struct nfs_fattr *fattr;
 	char *hostname;
 	char *mnt_path;
 	struct sockaddr *addr;
 	size_t addrlen;
-	rpc_authflavor_t authflavor;
 };
 
 /*
@@ -164,6 +164,7 @@ extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 						      struct nfs_fh *);
 extern void nfs_free_server(struct nfs_server *server);
 extern struct nfs_server *nfs_clone_server(struct nfs_server *,
+					   struct rpc_clnt *,
 					   struct nfs_fh *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 1807866..3e40460 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -346,7 +346,6 @@ static struct vfsmount *nfs_do_submount(struct dentry *dentry,
 		.dentry = dentry,
 		.fh = fh,
 		.fattr = fattr,
-		.authflavor = authflavor,
 	};
 	struct vfsmount *mnt = ERR_PTR(-ENOMEM);
 	char *page = (char *) __get_free_page(GFP_USER);
@@ -363,7 +362,14 @@ static struct vfsmount *nfs_do_submount(struct dentry *dentry,
 	mnt = (struct vfsmount *)devname;
 	if (IS_ERR(devname))
 		goto free_page;
+
+	mountdata.client = rpc_clone_client(NFS_SB(dentry->d_sb)->client);
+	if (IS_ERR(mountdata.client))
+		goto free_page;
+
 	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
+	if (IS_ERR(mnt))
+		rpc_shutdown_client(mountdata.client);
 free_page:
 	free_page((unsigned long)page);
 out:
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 9c8eca3..28a4771 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -174,7 +174,7 @@ static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 	struct nfs_clone_mount mountdata = {
 		.sb = dentry->d_sb,
 		.dentry = dentry,
-		.authflavor = NFS_SB(dentry->d_sb)->client->cl_auth->au_flavor,
+		.client = NFS_SB(dentry->d_sb)->client,
 	};
 	char *page = NULL, *page2 = NULL;
 	int loc, error;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 37412f7..ce9c0c1 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2428,7 +2428,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	dprintk("--> nfs_xdev_mount()\n");
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	server = nfs_clone_server(NFS_SB(data->sb), data->client, data->fh, data->fattr);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
@@ -2951,7 +2951,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	dprintk("--> nfs4_xdev_mount()\n");
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	server = nfs_clone_server(NFS_SB(data->sb), data->client, data->fh, data->fattr);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
-- 
1.7.10

