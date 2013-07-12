Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53041 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965059Ab3GLQdG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:33:06 -0400
Received: by mail-gg0-f174.google.com with SMTP id y3so3139083ggc.5
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:33:05 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id m5sm68990821yha.23.2013.07.12.09.33.04
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:33:04 -0700 (PDT)
Subject: [PATCH v1 11/19] SUNRPC: Add a helper to switch the transport of an
 rpc_clnt
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:33:03 -0400
Message-ID: <20130712163303.1444.96148.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: forward ported to 3.10 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h |    4 ++
 net/sunrpc/clnt.c           |   83 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 81 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index bfe11be..29bb018 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -134,6 +134,10 @@ void rpc_task_reset_client(struct rpc_task *task, struct rpc_clnt *clnt);
 struct rpc_clnt *rpc_clone_client(struct rpc_clnt *);
 struct rpc_clnt *rpc_clone_client_set_auth(struct rpc_clnt *,
 				rpc_authflavor_t);
+int		rpc_switch_client_transport(struct rpc_clnt *,
+				struct xprt_create *,
+				const struct rpc_timeout *);
+
 void		rpc_shutdown_client(struct rpc_clnt *);
 void		rpc_release_client(struct rpc_clnt *);
 void		rpc_task_release_client(struct rpc_task *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 5a750b9..e4e8ab0 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -25,6 +25,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/slab.h>
+#include <linux/rcupdate.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
 #include <linux/in.h>
@@ -289,12 +290,35 @@ static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 	memcpy(clnt->cl_nodename, nodename, clnt->cl_nodelen);
 }
 
+static void rpc_clnt_set_transport(struct rpc_clnt *clnt,
+		struct rpc_xprt *xprt,
+		const struct rpc_timeout *timeout)
+{
+	struct rpc_xprt *old;
+
+	spin_lock(&clnt->cl_lock);
+	old = clnt->cl_xprt;
+
+	if (!xprt_bound(xprt))
+		clnt->cl_autobind = 1;
+
+	clnt->cl_timeout = timeout;
+	rcu_assign_pointer(clnt->cl_xprt, xprt);
+	spin_unlock(&clnt->cl_lock);
+
+	if (old != NULL) {
+		synchronize_rcu();
+		xprt_put(old);
+	}
+}
+
 static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, struct rpc_xprt *xprt)
 {
 	const struct rpc_program *program = args->program;
 	const struct rpc_version *version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
+	const struct rpc_timeout *timeout;
 	int err;
 
 	/* sanity check the name before trying to print it */
@@ -318,7 +342,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -333,16 +356,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	INIT_LIST_HEAD(&clnt->cl_tasks);
 	spin_lock_init(&clnt->cl_lock);
 
-	if (!xprt_bound(xprt))
-		clnt->cl_autobind = 1;
-
-	clnt->cl_timeout = xprt->timeout;
+	timeout = xprt->timeout;
 	if (args->timeout != NULL) {
 		memcpy(&clnt->cl_timeout_default, args->timeout,
 				sizeof(clnt->cl_timeout_default));
-		clnt->cl_timeout = &clnt->cl_timeout_default;
+		timeout = &clnt->cl_timeout_default;
 	}
 
+	rpc_clnt_set_transport(clnt, xprt, timeout);
+
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
 	clnt->cl_principal = NULL;
@@ -573,6 +595,55 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 }
 EXPORT_SYMBOL_GPL(rpc_clone_client_set_auth);
 
+/**
+ * rpc_switch_client_transport: switch the RPC transport on the fly
+ * @clnt: pointer to a struct rpc_clnt
+ * @args: pointer to the new transport arguments
+ * @timeout: pointer to the new timeout parameters
+ *
+ * This function allows the caller to switch the RPC transport for the
+ * rpc_clnt structure 'clnt' to allow it to connect to a mirrored NFS
+ * server, for instance.  It assumes that the caller has ensured that
+ * there are no active tasks by using some form of locking.
+ *
+ * Returns zero on success, otherwise a negative errno is returned.
+ */
+int rpc_switch_client_transport(struct rpc_clnt *clnt,
+		struct xprt_create *args,
+		const struct rpc_timeout *timeout)
+{
+	struct rpc_xprt *xprt;
+	struct rpc_auth *auth;
+	rpc_authflavor_t pseudoflavor;
+
+	xprt = xprt_create_transport(args);
+	if (IS_ERR(xprt)) {
+		dprintk("RPC:      failed to switch xprt for clnt %p\n", clnt);
+		/* XXX: this leaves the clnt in its previous state */
+		return PTR_ERR(xprt);
+	}
+
+	pseudoflavor = clnt->cl_auth->au_flavor;
+
+	rpc_clnt_set_transport(clnt, xprt, timeout);
+
+	/*
+	 * Note: we must always create a new rpc_auth cache
+	 * when switching to a different server!  GSS contexts
+	 * in particular are between a single client and
+	 * server.
+	 */
+	auth = rpcauth_create(pseudoflavor, clnt);
+	if (IS_ERR(auth)) {
+		printk(KERN_INFO "RPC: Couldn't create auth handle (flavor %u)\n",
+				pseudoflavor);
+		/* XXX: this leaves the clnt in a broken state */
+		return PTR_ERR(auth);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_switch_client_transport);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

