Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19167 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760638Ab2D0R17 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 13:27:59 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v5 5/9] NFS: Honor the authflavor set in the clone mount data
Date: Fri, 27 Apr 2012 13:27:42 -0400
Message-Id: <1335547666-28315-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
References: <1335547666-28315-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

The authflavor is set in an nfs_clone_mount structure and passed to the
xdev_mount() functions where it was promptly ignored.  Instead, use it
to initialize an rpc_clnt for the cloned server.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c    |    5 +++--
 fs/nfs/internal.h  |    3 ++-
 fs/nfs/namespace.c |    3 +--
 fs/nfs/super.c     |    4 ++--
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index da7b5e4..60f7e4e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1729,7 +1729,8 @@ error:
  */
 struct nfs_server *nfs_clone_server(struct nfs_server *source,
 				    struct nfs_fh *fh,
-				    struct nfs_fattr *fattr)
+				    struct nfs_fattr *fattr,
+				    rpc_authflavor_t flavor)
 {
 	struct nfs_server *server;
 	struct nfs_fattr *fattr_fsinfo;
@@ -1758,7 +1759,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 
 	error = nfs_init_server_rpcclient(server,
 			source->client->cl_timeout,
-			source->client->cl_auth->au_flavor);
+			flavor);
 	if (error < 0)
 		goto out_free_server;
 	if (!IS_ERR(source->client_acl))
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 49c09b4..b777bda 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -165,7 +165,8 @@ extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 extern void nfs_free_server(struct nfs_server *server);
 extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fh *,
-					   struct nfs_fattr *);
+					   struct nfs_fattr *,
+					   rpc_authflavor_t);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index b9a593d..78dde30 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -257,7 +257,6 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	struct nfs_fh *fh = NULL;
 	struct nfs_fattr *fattr = NULL;
 	struct rpc_clnt *client;
-	rpc_authflavor_t flavor = RPC_AUTH_UNIX;
 
 	dprintk("--> nfs_d_automount()\n");
 
@@ -285,7 +284,7 @@ struct vfsmount *nfs_d_automount(struct path *path)
 	if (fattr->valid & NFS_ATTR_FATTR_V4_REFERRAL)
 		mnt = nfs_do_refmount(client, path->dentry);
 	else
-		mnt = nfs_do_submount(path->dentry, fh, fattr, flavor);
+		mnt = nfs_do_submount(path->dentry, fh, fattr, client->cl_auth->au_flavor);
 	rpc_shutdown_client(client);
 
 	if (IS_ERR(mnt))
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1e6715f..4ac7fca 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2428,7 +2428,7 @@ nfs_xdev_mount(struct file_system_type *fs_type, int flags,
 	dprintk("--> nfs_xdev_mount()\n");
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
@@ -2955,7 +2955,7 @@ nfs4_xdev_mount(struct file_system_type *fs_type, int flags,
 	dprintk("--> nfs4_xdev_mount()\n");
 
 	/* create a new volume representation */
-	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr);
+	server = nfs_clone_server(NFS_SB(data->sb), data->fh, data->fattr, data->authflavor);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out_err_noserver;
-- 
1.7.10

