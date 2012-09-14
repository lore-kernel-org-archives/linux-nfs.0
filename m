Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43958 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755248Ab2INVYE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:24:04 -0400
Received: by yhmm54 with SMTP id m54so1133966yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:24:04 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] SUNRPC: Introduce rpc_clone_client_set_auth()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:24:02 -0400
Message-ID: <20120914212401.1635.80063.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An ULP is supposed to be able to replace a GSS rpc_auth object with
another GSS rpc_auth object using rpcauth_create().  However,
rpcauth_create() in 3.5 reliably fails with -EEXIST in this case.
This is because when gss_create() attempts to create the upcall pipes,
sometimes they are already there.  For example if a pipe FS mount
event occurs, or a previous GSS flavor was in use for this rpc_clnt.

It turns out that's not the only problem here.  While working on a
fix for the above problem, we noticed that replacing an rpc_clnt's
rpc_auth is not safe, since dereferencing the cl_auth field is not
protected in any way.

So we're deprecating the ability of rpcauth_create() to switch an
rpc_clnt's security flavor during normal operation.  Instead, let's
add a fresh API that clones an rpc_clnt and gives the clone a new
flavor before it's used.

This makes immediate use of the new __rpc_clone_client() helper.

This can be used in a similar fashion to rpcauth_create() when a
client is hunting for the correct security flavor.  Instead of
replacing an rpc_clnt's security flavor in a loop, the ULP replaces
the whole rpc_clnt.

To fix the -EEXIST problem, any ULP logic that relies on replacing
an rpc_clnt's rpc_auth with rpcauth_create() must be changed to use
this API instead.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c             |   13 ++-----------
 fs/nfs/nfs4namespace.c      |   14 +-------------
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/clnt.c           |   22 ++++++++++++++++++++++
 4 files changed, 27 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9969444..143149d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -668,7 +668,8 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 {
 	struct nfs_client *clp = server->nfs_client;
 
-	server->client = rpc_clone_client(clp->cl_rpcclient);
+	server->client = rpc_clone_client_set_auth(clp->cl_rpcclient,
+							pseudoflavour);
 	if (IS_ERR(server->client)) {
 		dprintk("%s: couldn't create rpc_client!\n", __func__);
 		return PTR_ERR(server->client);
@@ -678,16 +679,6 @@ int nfs_init_server_rpcclient(struct nfs_server *server,
 			timeo,
 			sizeof(server->client->cl_timeout_default));
 	server->client->cl_timeout = &server->client->cl_timeout_default;
-
-	if (pseudoflavour != clp->cl_rpcclient->cl_auth->au_flavor) {
-		struct rpc_auth *auth;
-
-		auth = rpcauth_create(pseudoflavour, server->client);
-		if (IS_ERR(auth)) {
-			dprintk("%s: couldn't create credcache!\n", __func__);
-			return PTR_ERR(auth);
-		}
-	}
 	server->client->cl_softrtry = 0;
 	if (server->flags & NFS_MOUNT_SOFT)
 		server->client->cl_softrtry = 1;
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 017b4b0..5ce7024 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -192,25 +192,13 @@ out:
 struct rpc_clnt *nfs4_create_sec_client(struct rpc_clnt *clnt, struct inode *inode,
 					struct qstr *name)
 {
-	struct rpc_clnt *clone;
-	struct rpc_auth *auth;
 	rpc_authflavor_t flavor;
 
 	flavor = nfs4_negotiate_security(inode, name);
 	if ((int)flavor < 0)
 		return ERR_PTR(flavor);
 
-	clone = rpc_clone_client(clnt);
-	if (IS_ERR(clone))
-		return clone;
-
-	auth = rpcauth_create(flavor, clone);
-	if (!auth) {
-		rpc_shutdown_client(clone);
-		clone = ERR_PTR(-EIO);
-	}
-
-	return clone;
+	return rpc_clone_client_set_auth(clnt, flavor);
 }
 
 static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 523547e..34206b8 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -130,6 +130,8 @@ struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
 				const struct rpc_program *, u32);
 void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
+struct rpc_clnt *rpc_clone_client_set_auth(struct rpc_clnt *,
+				rpc_authflavor_t);
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index afbeefa..cdc7564 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -548,6 +548,28 @@ struct rpc_clnt *rpc_clone_client(struct rpc_clnt *clnt)
 }
 EXPORT_SYMBOL_GPL(rpc_clone_client);
 
+/**
+ * rpc_clone_client_set_auth - Clone an RPC client structure and set its auth
+ *
+ * @clnt: RPC client whose parameters are copied
+ * @auth: security flavor for new client
+ *
+ * Returns a fresh RPC client or an ERR_PTR.
+ */
+struct rpc_clnt *
+rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
+{
+	struct rpc_create_args args = {
+		.program	= clnt->cl_program,
+		.prognumber	= clnt->cl_prog,
+		.version	= clnt->cl_vers,
+		.authflavor	= flavor,
+		.client_name	= clnt->cl_principal,
+	};
+	return __rpc_clone_client(&args, clnt);
+}
+EXPORT_SYMBOL_GPL(rpc_clone_client_set_auth);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

