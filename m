Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:50715 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab1EITgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:36:53 -0400
Received: by yia27 with SMTP id 27so1915432yia.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:36:53 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/16] SUNRPC: Add a helper to switch the transport of the
	rpc_client
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:36:49 -0400
Message-ID: <20110509193649.16568.42738.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: fix whitespace ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    3 ++
 net/sunrpc/clnt.c           |   76 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 73 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 2eea0d7..d18d952 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -144,6 +144,9 @@ void		rpc_task_release_client(struct rpc_task *);
 
 int		rpc_lock_client(struct rpc_clnt *clnt, unsigned long timeout);
 void		rpc_unlock_client(struct rpc_clnt *clnt);
+int		rpc_switch_client_transport(struct rpc_clnt *,
+				struct xprt_create *,
+				const struct rpc_timeout *);
 
 int		rpcb_register(u32, u32, int, unsigned short);
 int		rpcb_v4_register(const u32 program, const u32 version,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6479e1d..ac2d29e 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -26,6 +26,7 @@
 #include <linux/namei.h>
 #include <linux/mount.h>
 #include <linux/slab.h>
+#include <linux/rcupdate.h>
 #include <linux/utsname.h>
 #include <linux/workqueue.h>
 #include <linux/in.h>
@@ -143,12 +144,35 @@ err:
 	return error;
 }
 
+static void rpc_set_client_transport(struct rpc_clnt *clnt,
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
 	struct rpc_program	*program = args->program;
 	struct rpc_version	*version;
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
+	const struct rpc_timeout *timeout;
 	int err;
 
 	/* sanity check the name before trying to print it */
@@ -174,7 +198,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -189,16 +212,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
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
 
+	rpc_set_client_transport(clnt, xprt, timeout);
+
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
 	clnt->cl_principal = NULL;
@@ -412,6 +434,48 @@ out_no_clnt:
 }
 EXPORT_SYMBOL_GPL(rpc_clone_client);
 
+/**
+ * rpc_switch_client_transport: switch the RPC transport on the fly
+ * @clnt: pointer to a struct rpc_clnt
+ * @args: pointer to the new transport arguments
+ * @timeout: pointer to the new timeout parameters
+ *
+ * This function allows the caller to switch the RPC transport for the
+ * rpc_clnt structure 'clnt' to allow it to connect to a mirrored NFS server,
+ * for instance. It assumes that the caller has ensured that there are no
+ * active tasks by using some form of locking.
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
+	if (IS_ERR(xprt))
+		return PTR_ERR(xprt);
+
+	pseudoflavor = clnt->cl_auth->au_flavor;
+
+	rpc_set_client_transport(clnt, xprt, timeout);
+
+	/*
+	 * Note: we must always create a new rpc_auth cache
+	 * when switching to a different server! RPCSEC_GSS sessions
+	 * in particular are between a single client and server,
+	 * so we cannot reuse the sessions in the cache when we switch
+	 * servers.
+	 */
+	auth = rpcauth_create(pseudoflavor, clnt);
+	if (IS_ERR(auth))
+		return PTR_ERR(auth);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_switch_client_transport);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

