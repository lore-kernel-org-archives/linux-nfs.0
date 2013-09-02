Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:37320 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758880Ab3IBSRN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:13 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 10/17] RPCSEC_GSS: Switch auth_gss to use the new framework for pipefs dentries
Date: Mon, 2 Sep 2013 14:16:53 -0400
Message-ID: <1378145820-29990-10-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-6-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-7-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-8-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-9-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 181 +++++++++++++++++++++--------------------
 1 file changed, 92 insertions(+), 89 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index c0d36bb..d214aec 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -71,6 +71,13 @@ static unsigned int gss_expired_cred_retry_delay = GSS_RETRY_EXPIRED;
  * using integrity (two 4-byte integers): */
 #define GSS_VERF_SLACK		100
 
+struct gss_pipe {
+	struct rpc_pipe_dir_object pdo;
+	struct rpc_pipe *pipe;
+	struct rpc_clnt *clnt;
+	const char *name;
+};
+
 struct gss_auth {
 	struct kref kref;
 	struct rpc_auth rpc_auth;
@@ -84,7 +91,7 @@ struct gss_auth {
 	 * mechanism (for example, "krb5") and exists for
 	 * backwards-compatibility with older gssd's.
 	 */
-	struct rpc_pipe *pipe[2];
+	struct gss_pipe *gss_pipe[2];
 	const char *target_name;
 };
 
@@ -456,7 +463,7 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 		kfree(gss_msg);
 		return ERR_PTR(vers);
 	}
-	gss_msg->pipe = gss_auth->pipe[vers];
+	gss_msg->pipe = gss_auth->gss_pipe[vers]->pipe;
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
@@ -791,85 +798,83 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 	}
 }
 
-static void gss_pipes_dentries_destroy(struct rpc_auth *auth)
+static void gss_pipe_dentry_destroy(struct dentry *dir,
+		struct rpc_pipe_dir_object *pdo)
 {
-	struct gss_auth *gss_auth;
+	struct gss_pipe *gss_pipe = pdo->pdo_data;
+	struct rpc_pipe *pipe = gss_pipe->pipe;
 
-	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
-	if (gss_auth->pipe[0]->dentry) {
-		rpc_unlink(gss_auth->pipe[0]->dentry);
-		gss_auth->pipe[0]->dentry = NULL;
-	}
-	if (gss_auth->pipe[1]->dentry) {
-		rpc_unlink(gss_auth->pipe[1]->dentry);
-		gss_auth->pipe[1]->dentry = NULL;
+	if (pipe->dentry != NULL) {
+		rpc_unlink(pipe->dentry);
+		pipe->dentry = NULL;
 	}
 }
 
-static int gss_pipes_dentries_create(struct rpc_auth *auth)
+static int gss_pipe_dentry_create(struct dentry *dir,
+		struct rpc_pipe_dir_object *pdo)
 {
-	int err;
-	struct gss_auth *gss_auth;
-	struct rpc_clnt *clnt;
+	struct gss_pipe *p = pdo->pdo_data;
 	struct dentry *dentry;
 
-	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
-	clnt = gss_auth->client;
+	dentry = rpc_mkpipe_dentry(dir, p->name, p->clnt, p->pipe);
+	if (IS_ERR(dentry))
+		return PTR_ERR(dentry);
+	p->pipe->dentry = dentry;
+	return 0;
+}
+
+static const struct rpc_pipe_dir_object_ops gss_pipe_dir_object_ops = {
+	.create = gss_pipe_dentry_create,
+	.destroy = gss_pipe_dentry_destroy,
+};
+
+static struct gss_pipe *gss_pipe_alloc(struct rpc_clnt *clnt,
+		const char *name,
+		const struct rpc_pipe_ops *upcall_ops)
+{
+	struct net *net = rpc_net_ns(clnt);
+	struct gss_pipe *p;
+	int err = -ENOMEM;
 
-	dentry = rpc_mkpipe_dentry(clnt->cl_dentry, "gssd",
-			clnt, gss_auth->pipe[1]);
-	if (IS_ERR(dentry)) {
-		err = PTR_ERR(dentry);
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
+	if (p == NULL)
 		goto err;
+	p->pipe = rpc_mkpipe_data(upcall_ops, RPC_PIPE_WAIT_FOR_OPEN);
+	if (IS_ERR(p->pipe)) {
+		err = PTR_ERR(p->pipe);
+		goto err_free_gss_pipe;
 	}
-	gss_auth->pipe[1]->dentry = dentry;
-	dentry = rpc_mkpipe_dentry(clnt->cl_dentry, gss_auth->mech->gm_name,
-			clnt, gss_auth->pipe[0]);
-	if (IS_ERR(dentry)) {
-		err = PTR_ERR(dentry);
-		goto err_unlink_pipe_1;
-	}
-	return 0;
-
-err_unlink_pipe_1:
-	rpc_unlink(gss_auth->pipe[1]->dentry);
-	gss_auth->pipe[1]->dentry = NULL;
+	p->name = name;
+	p->clnt = clnt;
+	rpc_init_pipe_dir_object(&p->pdo,
+			&gss_pipe_dir_object_ops,
+			p);
+	err = rpc_add_pipe_dir_object(net, &clnt->cl_pipedir_objects, &p->pdo);
+	if (!err)
+		return p;
+	rpc_destroy_pipe_data(p->pipe);
+err_free_gss_pipe:
+	kfree(p);
 err:
-	return err;
+	return ERR_PTR(err);
 }
 
-static void gss_pipes_dentries_destroy_net(struct rpc_clnt *clnt,
-					   struct rpc_auth *auth)
+static void __gss_pipe_free(struct gss_pipe *p)
 {
-	struct gss_auth *gss_auth = container_of(auth, struct gss_auth,
-			rpc_auth);
-	struct net *net = gss_auth->net;
-	struct super_block *sb;
+	struct rpc_clnt *clnt = p->clnt;
+	struct net *net = rpc_net_ns(clnt);
 
-	sb = rpc_get_sb_net(net);
-	if (sb) {
-		if (clnt->cl_dentry)
-			gss_pipes_dentries_destroy(auth);
-		rpc_put_sb_net(net);
-	}
+	rpc_remove_pipe_dir_object(net,
+			&clnt->cl_pipedir_objects,
+			&p->pdo);
+	rpc_destroy_pipe_data(p->pipe);
+	kfree(p);
 }
 
-static int gss_pipes_dentries_create_net(struct rpc_clnt *clnt,
-					 struct rpc_auth *auth)
+static void gss_pipe_free(struct gss_pipe *p)
 {
-	struct gss_auth *gss_auth = container_of(auth, struct gss_auth,
-			rpc_auth);
-	struct net *net = gss_auth->net;
-	struct super_block *sb;
-	int err = 0;
-
-	sb = rpc_get_sb_net(net);
-	if (sb) {
-		if (clnt->cl_dentry)
-			err = gss_pipes_dentries_create(auth);
-		rpc_put_sb_net(net);
-	}
-	return err;
+	if (p != NULL)
+		__gss_pipe_free(p);
 }
 
 /*
@@ -881,6 +886,7 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	rpc_authflavor_t flavor = args->pseudoflavor;
 	struct gss_auth *gss_auth;
+	struct gss_pipe *gss_pipe;
 	struct rpc_auth * auth;
 	int err = -ENOMEM; /* XXX? */
 
@@ -915,39 +921,35 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	atomic_set(&auth->au_count, 1);
 	kref_init(&gss_auth->kref);
 
+	err = rpcauth_init_credcache(auth);
+	if (err)
+		goto err_put_mech;
 	/*
 	 * Note: if we created the old pipe first, then someone who
 	 * examined the directory at the right moment might conclude
 	 * that we supported only the old pipe.  So we instead create
 	 * the new pipe first.
 	 */
-	gss_auth->pipe[1] = rpc_mkpipe_data(&gss_upcall_ops_v1,
-					    RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(gss_auth->pipe[1])) {
-		err = PTR_ERR(gss_auth->pipe[1]);
-		goto err_put_mech;
+	gss_pipe = gss_pipe_alloc(clnt, "gssd", &gss_upcall_ops_v1);
+	if (IS_ERR(gss_pipe)) {
+		err = PTR_ERR(gss_pipe);
+		goto err_destroy_credcache;
 	}
+	gss_auth->gss_pipe[1] = gss_pipe;
 
-	gss_auth->pipe[0] = rpc_mkpipe_data(&gss_upcall_ops_v0,
-					    RPC_PIPE_WAIT_FOR_OPEN);
-	if (IS_ERR(gss_auth->pipe[0])) {
-		err = PTR_ERR(gss_auth->pipe[0]);
+	gss_pipe = gss_pipe_alloc(clnt, gss_auth->mech->gm_name,
+			&gss_upcall_ops_v0);
+	if (IS_ERR(gss_pipe)) {
+		err = PTR_ERR(gss_pipe);
 		goto err_destroy_pipe_1;
 	}
-	err = gss_pipes_dentries_create_net(clnt, auth);
-	if (err)
-		goto err_destroy_pipe_0;
-	err = rpcauth_init_credcache(auth);
-	if (err)
-		goto err_unlink_pipes;
+	gss_auth->gss_pipe[0] = gss_pipe;
 
 	return auth;
-err_unlink_pipes:
-	gss_pipes_dentries_destroy_net(clnt, auth);
-err_destroy_pipe_0:
-	rpc_destroy_pipe_data(gss_auth->pipe[0]);
 err_destroy_pipe_1:
-	rpc_destroy_pipe_data(gss_auth->pipe[1]);
+	__gss_pipe_free(gss_auth->gss_pipe[1]);
+err_destroy_credcache:
+	rpcauth_destroy_credcache(auth);
 err_put_mech:
 	gss_mech_put(gss_auth->mech);
 err_put_net:
@@ -963,9 +965,8 @@ out_dec:
 static void
 gss_free(struct gss_auth *gss_auth)
 {
-	gss_pipes_dentries_destroy_net(gss_auth->client, &gss_auth->rpc_auth);
-	rpc_destroy_pipe_data(gss_auth->pipe[0]);
-	rpc_destroy_pipe_data(gss_auth->pipe[1]);
+	gss_pipe_free(gss_auth->gss_pipe[0]);
+	gss_pipe_free(gss_auth->gss_pipe[1]);
 	gss_mech_put(gss_auth->mech);
 	put_net(gss_auth->net);
 	kfree(gss_auth->target_name);
@@ -985,14 +986,18 @@ gss_free_callback(struct kref *kref)
 static void
 gss_destroy(struct rpc_auth *auth)
 {
-	struct gss_auth *gss_auth;
+	struct gss_auth *gss_auth = container_of(auth,
+			struct gss_auth, rpc_auth);
 
 	dprintk("RPC:       destroying GSS authenticator %p flavor %d\n",
 			auth, auth->au_flavor);
 
+	gss_pipe_free(gss_auth->gss_pipe[0]);
+	gss_auth->gss_pipe[0] = NULL;
+	gss_pipe_free(gss_auth->gss_pipe[1]);
+	gss_auth->gss_pipe[1] = NULL;
 	rpcauth_destroy_credcache(auth);
 
-	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	kref_put(&gss_auth->kref, gss_free_callback);
 }
 
@@ -1676,8 +1681,6 @@ static const struct rpc_authops authgss_ops = {
 	.destroy	= gss_destroy,
 	.lookup_cred	= gss_lookup_cred,
 	.crcreate	= gss_create_cred,
-	.pipes_create	= gss_pipes_dentries_create,
-	.pipes_destroy	= gss_pipes_dentries_destroy,
 	.list_pseudoflavors = gss_mech_list_pseudoflavors,
 	.info2flavor	= gss_mech_info2flavor,
 	.flavor2info	= gss_mech_flavor2info,
-- 
1.8.3.1

