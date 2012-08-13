Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:36181 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318Ab2HMVWL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 17:22:11 -0400
Received: by ggdk6 with SMTP id k6so3744493ggd.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Aug 2012 14:22:11 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] SUNRPC: Share upcall pipes among an rpc_clnt's rpc_auth
 objects
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Aug 2012 17:22:08 -0400
Message-ID: <20120813212208.1680.84688.stgit@degas.1015granger.net>
In-Reply-To: <20120813210739.1680.53741.stgit@degas.1015granger.net>
References: <20120813210739.1680.53741.stgit@degas.1015granger.net>
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

The ->pipes_destroy method works only on whatever rpc_auth is
associated with the rpc_clnt when it is destroyed.  But there is no
guarantee that this is the same rpc_auth that was created when
the rpc_clnt was created.  Thus cached pipe data must be reference
counted and destroyed when no more gss_auth's are using it.

Pipe dentries appear to be created and deleted independently of the
rpc_pipe data.  We must allow this to continue in order that mounting
and unmounting the pipe FS can work.

In the meantime, we need to provide a way for gss_create() to find
an existing pipe of a particular name so it may be shared.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---

 include/linux/sunrpc/clnt.h    |    1 
 net/sunrpc/auth_gss/auth_gss.c |  141 ++++++++++++++++++++++++++++++++++------
 net/sunrpc/clnt.c              |    1 
 3 files changed, 123 insertions(+), 20 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 523547e..31857e0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -62,6 +62,7 @@ struct rpc_clnt {
 	struct rpc_timeout	cl_timeout_default;
 	const struct rpc_program *cl_program;
 	char			*cl_principal;	/* target to authenticate to */
+	struct list_head	cl_pipes;	/* clnt's upcall pipes */
 };
 
 /*
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 82a3156..b85ebe8 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -84,6 +84,14 @@ struct gss_auth {
 	struct rpc_pipe *pipe[2];
 };
 
+struct gss_cached_pipe {
+	struct list_head	gp_list;
+	unsigned int		gp_ref;
+	char			*gp_name;
+	struct rpc_pipe		*gp_pipe;
+};
+DEFINE_MUTEX(gss_pipe_mutex);
+
 /* pipe_version >= 0 if and only if someone has a pipe open. */
 static int pipe_version = -1;
 static atomic_t pipe_users = ATOMIC_INIT(0);
@@ -765,6 +773,20 @@ static void gss_pipe_dentry_destroy(struct rpc_pipe *pipe)
 	}
 }
 
+static void gss_pipe_dentry_destroy_net(struct rpc_clnt *clnt,
+					struct rpc_pipe *pipe)
+{
+	struct net *net = rpc_net_ns(clnt);
+	struct super_block *sb;
+
+	sb = rpc_get_sb_net(net);
+	if (sb) {
+		if (clnt->cl_dentry)
+			gss_pipe_dentry_destroy(pipe);
+		rpc_put_sb_net(net);
+	}
+}
+
 /*
  * Release existing pipe dentries, but leave the rpc_pipe data
  * ready to receive fresh dentries if subsequently needed.
@@ -827,20 +849,6 @@ out_err:
 	return err;
 }
 
-static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
-					   struct rpc_auth *auth)
-{
-	struct net *net = rpc_net_ns(clnt);
-	struct super_block *sb;
-
-	sb = rpc_get_sb_net(net);
-	if (sb) {
-		if (clnt->cl_dentry)
-			gss_pipes_dentries_destroy(auth);
-		rpc_put_sb_net(net);
-	}
-}
-
 static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 					 struct rpc_auth *auth)
 {
@@ -857,16 +865,111 @@ static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
 	return err;
 }
 
+static struct gss_cached_pipe *gss_alloc_cached_pipe(char *name)
+{
+	struct gss_cached_pipe *cp;
+
+	cp = kmalloc(sizeof(*cp), GFP_KERNEL);
+	if (cp == NULL)
+		return NULL;
+
+	cp->gp_name = kstrdup(name, GFP_KERNEL);
+	if (cp->gp_name == NULL) {
+		kfree(cp);
+		return NULL;
+	}
+
+	INIT_LIST_HEAD(&cp->gp_list);
+	cp->gp_ref = 1;
+	return cp;
+}
+
+static void gss_free_cached_pipe(struct gss_cached_pipe *cp)
+{
+	kfree(cp->gp_name);
+	kfree(cp);
+}
+
+/*
+ * Returns a fresh or cached pipe data object.  A cached pipe
+ * data object may already have a dentry attached to it.  If an
+ * object cannot be found or created, an ERR_PTR is returned.
+ */
 static struct rpc_pipe *gss_mkpipe_data(struct rpc_clnt *clnt,
 					const struct rpc_pipe_ops *ops,
 					char *name)
 {
-	return rpc_mkpipe_data(ops, RPC_PIPE_WAIT_FOR_OPEN);
+	struct gss_cached_pipe *cp;
+	struct rpc_pipe *pipe;
+
+	mutex_lock(&gss_pipe_mutex);
+
+	list_for_each_entry(cp, &clnt->cl_pipes, gp_list) {
+		if (strcmp(cp->gp_name, name) == 0) {
+			dprintk("RPC:       %s found '%s' for clnt %p: %p\n",
+				__func__, name, clnt, cp->gp_pipe);
+			cp->gp_ref++;
+			pipe = cp->gp_pipe;
+			goto out;
+		}
+	}
+
+	pipe = ERR_PTR(-ENOMEM);
+	cp = gss_alloc_cached_pipe(name);
+	if (cp == NULL)
+		goto out;
+
+	pipe = rpc_mkpipe_data(ops, RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(pipe)) {
+		gss_free_cached_pipe(cp);
+		goto out;
+	}
+
+	dprintk("RPC:       %s created '%s' for clnt %p: %p\n",
+		__func__, name, clnt, pipe);
+	cp->gp_pipe = pipe;
+	list_add(&cp->gp_list, &clnt->cl_pipes);
+
+out:
+	mutex_unlock(&gss_pipe_mutex);
+	return pipe;
 }
 
+/*
+ * Decrements a cached pipes reference count, and releases it if
+ * the count goes to zero.  Associated dentry is freed if present.
+ */
 static void gss_destroy_pipe_data(struct rpc_clnt *clnt, struct rpc_pipe *pipe)
 {
-	rpc_destroy_pipe_data(pipe);
+	struct gss_cached_pipe *cp;
+
+	mutex_lock(&gss_pipe_mutex);
+
+	list_for_each_entry(cp, &clnt->cl_pipes, gp_list) {
+		if (cp->gp_pipe == pipe)
+			goto found;
+	}
+
+	dprintk("RPC:       %s missing cache for pipe %p for clnt %p\n",
+		__func__, pipe, clnt);
+	WARN_ON(true);
+
+	mutex_unlock(&gss_pipe_mutex);
+	return;
+
+found:
+	if (--cp->gp_ref == 0) {
+		dprintk("RPC:       %s destroying '%s' (%p) for clnt %p\n",
+			__func__, cp->gp_name, pipe, clnt);
+		gss_pipe_dentry_destroy_net(clnt, pipe);
+		rpc_destroy_pipe_data(pipe);
+		list_del(&cp->gp_list);
+		gss_free_cached_pipe(cp);
+	} else
+		dprintk("RPC:       %s leaving '%s' (%p) for clnt %p\n",
+			__func__, cp->gp_name, pipe, clnt);
+
+	mutex_unlock(&gss_pipe_mutex);
 }
 
 /*
@@ -925,13 +1028,12 @@ gss_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 	err = gss_pipes_dentries_create_net(clnt, auth);
 	if (err)
 		goto err_destroy_pipe_0;
+
 	err = rpcauth_init_credcache(auth);
 	if (err)
-		goto err_unlink_pipes;
+		goto err_destroy_pipe_0;
 
 	return auth;
-err_unlink_pipes:
-	gss_pipes_dentries_destroy_net(clnt, auth);
 err_destroy_pipe_0:
 	gss_destroy_pipe_data(clnt, gss_auth->pipe[0]);
 err_destroy_pipe_1:
@@ -948,7 +1050,6 @@ out_dec:
 static void
 gss_free(struct gss_auth *gss_auth)
 {
-	gss_pipes_dentries_destroy_net(gss_auth->client, &gss_auth->rpc_auth);
 	gss_destroy_pipe_data(gss_auth->client, gss_auth->pipe[0]);
 	gss_destroy_pipe_data(gss_auth->client, gss_auth->pipe[1]);
 	gss_mech_put(gss_auth->mech);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f56f045..7bf6ed1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -349,6 +349,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		if (!clnt->cl_principal)
 			goto out_no_principal;
 	}
+	INIT_LIST_HEAD(&clnt->cl_pipes);
 
 	atomic_set(&clnt->cl_count, 1);
 

