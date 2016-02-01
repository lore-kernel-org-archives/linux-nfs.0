Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:34916 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbcBAElW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jan 2016 23:41:22 -0500
Received: by mail-ig0-f181.google.com with SMTP id t15so26670263igr.0
        for <linux-nfs@vger.kernel.org>; Sun, 31 Jan 2016 20:41:22 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 06/13] SUNRPC: Make rpc_clnt store the multipath iterators
Date: Sun, 31 Jan 2016 23:40:23 -0500
Message-Id: <1454301630-17358-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
References: <1454301630-17358-1-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-2-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-3-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-4-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-5-git-send-email-trond.myklebust@primarydata.com>
 <1454301630-17358-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a pre-patch for the RPC multipath code. It sets up the storage in
struct rpc_clnt for the multipath code.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/clnt.h    |  2 ++
 net/sunrpc/auth_gss/auth_gss.c |  4 ++--
 net/sunrpc/clnt.c              | 32 +++++++++++++++++++++++++++++---
 net/sunrpc/rpcb_clnt.c         |  4 ++--
 4 files changed, 35 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 0c5c2cbe96c9..1713e41d65ae 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -25,6 +25,7 @@
 #include <asm/signal.h>
 #include <linux/path.h>
 #include <net/ipv6.h>
+#include <linux/sunrpc/xprtmultipath.h>
 
 struct rpc_inode;
 
@@ -67,6 +68,7 @@ struct rpc_clnt {
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	struct dentry		*cl_debugfs;	/* debugfs directory */
 #endif
+	struct rpc_xprt_iter	cl_xpi;
 };
 
 /*
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 799e65b944b9..3ce391cb80c4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1181,12 +1181,12 @@ static struct rpc_auth *
 gss_create(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
 {
 	struct gss_auth *gss_auth;
-	struct rpc_xprt *xprt = rcu_access_pointer(clnt->cl_xprt);
+	struct rpc_xprt_switch *xps = rcu_access_pointer(clnt->cl_xpi.xpi_xpswitch);
 
 	while (clnt != clnt->cl_parent) {
 		struct rpc_clnt *parent = clnt->cl_parent;
 		/* Find the original parent for this transport */
-		if (rcu_access_pointer(parent->cl_xprt) != xprt)
+		if (rcu_access_pointer(parent->cl_xpi.xpi_xpswitch) != xps)
 			break;
 		clnt = parent;
 	}
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2b4ad7aa40c6..625fb8a184c6 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -354,6 +354,7 @@ static void rpc_free_clid(struct rpc_clnt *clnt)
 }
 
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
+		struct rpc_xprt_switch *xps,
 		struct rpc_xprt *xprt,
 		struct rpc_clnt *parent)
 {
@@ -411,6 +412,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	}
 
 	rpc_clnt_set_transport(clnt, xprt, timeout);
+	xprt_iter_init(&clnt->cl_xpi, xps);
+	xprt_switch_put(xps);
 
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
@@ -438,6 +441,7 @@ out_no_clid:
 out_err:
 	rpciod_down();
 out_no_rpciod:
+	xprt_switch_put(xps);
 	xprt_put(xprt);
 	return ERR_PTR(err);
 }
@@ -446,8 +450,13 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
 					struct rpc_xprt *xprt)
 {
 	struct rpc_clnt *clnt = NULL;
+	struct rpc_xprt_switch *xps;
 
-	clnt = rpc_new_client(args, xprt, NULL);
+	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
+	if (xps == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	clnt = rpc_new_client(args, xps, xprt, NULL);
 	if (IS_ERR(clnt))
 		return clnt;
 
@@ -564,6 +573,7 @@ EXPORT_SYMBOL_GPL(rpc_create);
 static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 					   struct rpc_clnt *clnt)
 {
+	struct rpc_xprt_switch *xps;
 	struct rpc_xprt *xprt;
 	struct rpc_clnt *new;
 	int err;
@@ -571,13 +581,17 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_create_args *args,
 	err = -ENOMEM;
 	rcu_read_lock();
 	xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
+	xps = xprt_switch_get(rcu_dereference(clnt->cl_xpi.xpi_xpswitch));
 	rcu_read_unlock();
-	if (xprt == NULL)
+	if (xprt == NULL || xps == NULL) {
+		xprt_put(xprt);
+		xprt_switch_put(xps);
 		goto out_err;
+	}
 	args->servername = xprt->servername;
 	args->nodename = clnt->cl_nodename;
 
-	new = rpc_new_client(args, xprt, clnt);
+	new = rpc_new_client(args, xps, xprt, clnt);
 	if (IS_ERR(new)) {
 		err = PTR_ERR(new);
 		goto out_err;
@@ -657,6 +671,7 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 {
 	const struct rpc_timeout *old_timeo;
 	rpc_authflavor_t pseudoflavor;
+	struct rpc_xprt_switch *xps, *oldxps;
 	struct rpc_xprt *xprt, *old;
 	struct rpc_clnt *parent;
 	int err;
@@ -668,10 +683,17 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 		return PTR_ERR(xprt);
 	}
 
+	xps = xprt_switch_alloc(xprt, GFP_KERNEL);
+	if (xps == NULL) {
+		xprt_put(xprt);
+		return -ENOMEM;
+	}
+
 	pseudoflavor = clnt->cl_auth->au_flavor;
 
 	old_timeo = clnt->cl_timeout;
 	old = rpc_clnt_set_transport(clnt, xprt, timeout);
+	oldxps = xprt_iter_xchg_switch(&clnt->cl_xpi, xps);
 
 	rpc_unregister_client(clnt);
 	__rpc_clnt_remove_pipedir(clnt);
@@ -697,14 +719,17 @@ int rpc_switch_client_transport(struct rpc_clnt *clnt,
 	synchronize_rcu();
 	if (parent != clnt)
 		rpc_release_client(parent);
+	xprt_switch_put(oldxps);
 	xprt_put(old);
 	dprintk("RPC:       replaced xprt for clnt %p\n", clnt);
 	return 0;
 
 out_revert:
+	xps = xprt_iter_xchg_switch(&clnt->cl_xpi, oldxps);
 	rpc_clnt_set_transport(clnt, old, old_timeo);
 	clnt->cl_parent = parent;
 	rpc_client_register(clnt, pseudoflavor, NULL);
+	xprt_switch_put(xps);
 	xprt_put(xprt);
 	dprintk("RPC:       failed to switch xprt for clnt %p\n", clnt);
 	return err;
@@ -783,6 +808,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 	rpc_free_iostats(clnt->cl_metrics);
 	clnt->cl_metrics = NULL;
 	xprt_put(rcu_dereference_raw(clnt->cl_xprt));
+	xprt_iter_destroy(&clnt->cl_xpi);
 	rpciod_down();
 	rpc_free_clid(clnt);
 	kfree(clnt);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index cf5770d8f49a..44f025c150d8 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -648,10 +648,10 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 static struct rpc_clnt *rpcb_find_transport_owner(struct rpc_clnt *clnt)
 {
 	struct rpc_clnt *parent = clnt->cl_parent;
-	struct rpc_xprt *xprt = rcu_dereference(clnt->cl_xprt);
+	struct rpc_xprt_switch *xps = rcu_access_pointer(clnt->cl_xpi.xpi_xpswitch);
 
 	while (parent != clnt) {
-		if (rcu_dereference(parent->cl_xprt) != xprt)
+		if (rcu_access_pointer(parent->cl_xpi.xpi_xpswitch) != xps)
 			break;
 		if (clnt->cl_autobind)
 			break;
-- 
2.5.0

