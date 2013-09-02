Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61092 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab3IBSRR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Sep 2013 14:17:17 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
CC: <andros@netapp.com>
Subject: [PATCH v3 15/17] RPCSEC_GSS: Share rpc_pipes when an rpc_clnt owns multiple rpcsec auth caches
Date: Mon, 2 Sep 2013 14:16:58 -0400
Message-ID: <1378145820-29990-15-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1378145820-29990-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1378145820-29990-1-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-2-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-3-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-4-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-5-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-6-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-7-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-8-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-9-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-10-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-11-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-12-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-13-git-send-email-Trond.Myklebust@netapp.com>
 <1378145820-29990-14-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that if an rpc_clnt owns more than one RPCSEC_GSS-based authentication
mechanism, then those caches will share the same 'gssd' upcall pipe.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 77 +++++++++++++++++++++++++++++++++++++-----
 1 file changed, 68 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index d214aec..5ec15bb 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -76,6 +76,7 @@ struct gss_pipe {
 	struct rpc_pipe *pipe;
 	struct rpc_clnt *clnt;
 	const char *name;
+	struct kref kref;
 };
 
 struct gss_auth {
@@ -832,7 +833,6 @@ static struct gss_pipe *gss_pipe_alloc(struct rpc_clnt *clnt,
 		const char *name,
 		const struct rpc_pipe_ops *upcall_ops)
 {
-	struct net *net = rpc_net_ns(clnt);
 	struct gss_pipe *p;
 	int err = -ENOMEM;
 
@@ -846,19 +846,71 @@ static struct gss_pipe *gss_pipe_alloc(struct rpc_clnt *clnt,
 	}
 	p->name = name;
 	p->clnt = clnt;
+	kref_init(&p->kref);
 	rpc_init_pipe_dir_object(&p->pdo,
 			&gss_pipe_dir_object_ops,
 			p);
-	err = rpc_add_pipe_dir_object(net, &clnt->cl_pipedir_objects, &p->pdo);
-	if (!err)
-		return p;
-	rpc_destroy_pipe_data(p->pipe);
+	return p;
 err_free_gss_pipe:
 	kfree(p);
 err:
 	return ERR_PTR(err);
 }
 
+struct gss_alloc_pdo {
+	struct rpc_clnt *clnt;
+	const char *name;
+	const struct rpc_pipe_ops *upcall_ops;
+};
+
+static int gss_pipe_match_pdo(struct rpc_pipe_dir_object *pdo, void *data)
+{
+	struct gss_pipe *gss_pipe;
+	struct gss_alloc_pdo *args = data;
+
+	if (pdo->pdo_ops != &gss_pipe_dir_object_ops)
+		return 0;
+	gss_pipe = container_of(pdo, struct gss_pipe, pdo);
+	if (strcmp(gss_pipe->name, args->name) != 0)
+		return 0;
+	if (!kref_get_unless_zero(&gss_pipe->kref))
+		return 0;
+	return 1;
+}
+
+static struct rpc_pipe_dir_object *gss_pipe_alloc_pdo(void *data)
+{
+	struct gss_pipe *gss_pipe;
+	struct gss_alloc_pdo *args = data;
+
+	gss_pipe = gss_pipe_alloc(args->clnt, args->name, args->upcall_ops);
+	if (!IS_ERR(gss_pipe))
+		return &gss_pipe->pdo;
+	return NULL;
+}
+
+static struct gss_pipe *gss_pipe_get(struct rpc_clnt *clnt,
+		const char *name,
+		const struct rpc_pipe_ops *upcall_ops)
+{
+	struct net *net = rpc_net_ns(clnt);
+	struct rpc_pipe_dir_object *pdo;
+	struct gss_alloc_pdo args = {
+		.clnt = clnt,
+		.name = name,
+		.upcall_ops = upcall_ops,
+	};
+
+	pdo = rpc_find_or_alloc_pipe_dir_object(net,
+			&clnt->cl_pipedir_objects,
+			gss_pipe_match_pdo,
+			gss_pipe_alloc_pdo,
+			&args);
+	if (pdo != NULL)
+		return container_of(pdo, struct gss_pipe, pdo);
+	return ERR_PTR(-ENOMEM);
+}
+
 static void __gss_pipe_free(struct gss_pipe *p)
 {
 	struct rpc_clnt *clnt = p->clnt;
@@ -871,10 +923,17 @@ static void __gss_pipe_free(struct gss_pipe *p)
 	kfree(p);
 }
 
+static void __gss_pipe_release(struct kref *kref)
+{
+	struct gss_pipe *p = container_of(kref, struct gss_pipe, kref);
+
+	__gss_pipe_free(p);
+}
+
 static void gss_pipe_free(struct gss_pipe *p)
 {
 	if (p != NULL)
-		__gss_pipe_free(p);
+		kref_put(&p->kref, __gss_pipe_release);
 }
 
 /*
@@ -930,14 +989,14 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 	 * that we supported only the old pipe.  So we instead create
 	 * the new pipe first.
 	 */
-	gss_pipe = gss_pipe_alloc(clnt, "gssd", &gss_upcall_ops_v1);
+	gss_pipe = gss_pipe_get(clnt, "gssd", &gss_upcall_ops_v1);
 	if (IS_ERR(gss_pipe)) {
 		err = PTR_ERR(gss_pipe);
 		goto err_destroy_credcache;
 	}
 	gss_auth->gss_pipe[1] = gss_pipe;
 
-	gss_pipe = gss_pipe_alloc(clnt, gss_auth->mech->gm_name,
+	gss_pipe = gss_pipe_get(clnt, gss_auth->mech->gm_name,
 			&gss_upcall_ops_v0);
 	if (IS_ERR(gss_pipe)) {
 		err = PTR_ERR(gss_pipe);
@@ -947,7 +1006,7 @@ gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 
 	return auth;
 err_destroy_pipe_1:
-	__gss_pipe_free(gss_auth->gss_pipe[1]);
+	gss_pipe_free(gss_auth->gss_pipe[1]);
 err_destroy_credcache:
 	rpcauth_destroy_credcache(auth);
 err_put_mech:
-- 
1.8.3.1

