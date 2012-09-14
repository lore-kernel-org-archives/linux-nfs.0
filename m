Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34623 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756190Ab2INVXz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:23:55 -0400
Received: by mail-yx0-f174.google.com with SMTP id m15so315385yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:23:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/10] SUNRPC: Refactor rpc_clone_client()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:23:52 -0400
Message-ID: <20120914212352.1635.44061.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc_clone_client() does most of the same tasks as rpc_new_client(),
so there is an opportunity for code re-use.  Create a generic helper
that makes it easy to clone an RPC client while replacing any of the
clnt's parameters.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   83 +++++++++++++++++++++++++++--------------------------
 1 files changed, 43 insertions(+), 40 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa48c60..afbeefa 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -490,59 +490,62 @@ EXPORT_SYMBOL_GPL(rpc_create);
  * same transport while varying parameters such as the authentication
  * flavour.
  */
-struct rpc_clnt *
-rpc_clone_client(struct rpc_clnt *clnt)
+static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
+					   struct rpc_clnt *clnt)
 {
-	struct rpc_clnt *new;
 	struct rpc_xprt *xprt;
-	int err = -ENOMEM;
+	struct rpc_clnt *new;
+	int err;
 
-	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
-	if (!new)
-		goto out_no_clnt;
-	new->cl_parent = clnt;
-	/* Turn off autobind on clones */
-	new->cl_autobind = 0;
-	INIT_LIST_HEAD(&new->cl_tasks);
-	spin_lock_init(&new->cl_lock);
-	rpc_init_rtt(&new->cl_rtt_default, clnt->cl_timeout->to_initval);
-	new->cl_metrics = rpc_alloc_iostats(clnt);
-	if (new->cl_metrics == NULL)
-		goto out_no_stats;
-	if (clnt->cl_principal) {
-		new->cl_principal = kstrdup(clnt->cl_principal, GFP_KERNEL);
-		if (new->cl_principal == NULL)
-			goto out_no_principal;
-	}
+	err = -ENOMEM;
 	rcu_read_lock();
 	xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
 	rcu_read_unlock();
 	if (xprt == NULL)
-		goto out_no_transport;
-	rcu_assign_pointer(new->cl_xprt, xprt);
-	atomic_set(&new->cl_count, 1);
-	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
-	if (err != 0)
-		goto out_no_path;
-	rpc_clnt_set_nodename(new, utsname()->nodename);
-	if (new->cl_auth)
-		atomic_inc(&new->cl_auth->au_count);
+		goto out_err;
+	args->servername = xprt->servername;
+
+	new = rpc_new_client(args, xprt);
+	if (IS_ERR(new)) {
+		err = PTR_ERR(new);
+		goto out_put;
+	}
+
 	atomic_inc(&clnt->cl_count);
-	rpc_register_client(new);
-	rpciod_up();
+	new->cl_parent = clnt;
+
+	/* Turn off autobind on clones */
+	new->cl_autobind = 0;
+	new->cl_softrtry = clnt->cl_softrtry;
+	new->cl_discrtry = clnt->cl_discrtry;
+	new->cl_chatty = clnt->cl_chatty;
 	return new;
-out_no_path:
+
+out_put:
 	xprt_put(xprt);
-out_no_transport:
-	kfree(new->cl_principal);
-out_no_principal:
-	rpc_free_iostats(new->cl_metrics);
-out_no_stats:
-	kfree(new);
-out_no_clnt:
+out_err:
 	dprintk("RPC:       %s: returned error %d\n", __func__, err);
 	return ERR_PTR(err);
 }
+
+/**
+ * rpc_clone_client - Clone an RPC client structure
+ *
+ * @clnt: RPC client whose parameters are copied
+ *
+ * Returns a fresh RPC client or an ERR_PTR.
+ */
+struct rpc_clnt *rpc_clone_client(struct rpc_clnt *clnt)
+{
+	struct rpc_create_args args = {
+		.program	= clnt->cl_program,
+		.prognumber	= clnt->cl_prog,
+		.version	= clnt->cl_vers,
+		.authflavor	= clnt->cl_auth->au_flavor,
+		.client_name	= clnt->cl_principal,
+	};
+	return __rpc_clone_client(&args, clnt);
+}
 EXPORT_SYMBOL_GPL(rpc_clone_client);
 
 /*

