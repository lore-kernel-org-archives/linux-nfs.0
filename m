Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f172.google.com ([209.85.213.172]:54397 "EHLO
	mail-ye0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968243Ab3HIQ6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:58:04 -0400
Received: by mail-ye0-f172.google.com with SMTP id m2so1304459yen.31
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:58:03 -0700 (PDT)
Subject: [PATCH v2 17/33] SUNRPC: Add a helper to switch the transport of an
 rpc_clnt
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 09 Aug 2013 12:50:14 -0400
Message-ID: <20130809165014.5362.56326.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: forward ported to 3.11 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h |    4 ++
 net/sunrpc/clnt.c           |   90 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 87 insertions(+), 7 deletions(-)

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
index f9e3926..ebacc63 100644
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
@@ -271,6 +272,25 @@ void rpc_clients_notifier_unregister(void)
 	return rpc_pipefs_notifier_unregister(&rpc_clients_block);
 }
 
+static struct rpc_xprt *rpc_clnt_set_transport(struct rpc_clnt *clnt,
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
+	return old;
+}
+
 static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 {
 	clnt->cl_nodelen = strlen(nodename);
@@ -321,7 +341,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 {
 	const struct rpc_program *program = args->program;
 	const struct rpc_version *version;
-	struct rpc_clnt		*clnt = NULL;
+	struct rpc_clnt *clnt = NULL;
+	const struct rpc_timeout *timeout;
 	int err;
 
 	/* sanity check the name before trying to print it */
@@ -345,7 +366,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -360,16 +380,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
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
@@ -589,6 +608,63 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
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
+ * Returns zero if "clnt" is now using the new xprt.  Otherwise a
+ * negative errno is returned, and "clnt" continues to use the old
+ * xprt.
+ */
+int rpc_switch_client_transport(struct rpc_clnt *clnt,
+		struct xprt_create *args,
+		const struct rpc_timeout *timeout)
+{
+	const struct rpc_timeout *old_timeo;
+	rpc_authflavor_t pseudoflavor;
+	struct rpc_xprt *xprt, *old;
+	int err;
+
+	xprt = xprt_create_transport(args);
+	if (IS_ERR(xprt)) {
+		dprintk("RPC:      failed to switch xprt for clnt %p\n", clnt);
+		return PTR_ERR(xprt);
+	}
+
+	pseudoflavor = clnt->cl_auth->au_flavor;
+
+	old_timeo = clnt->cl_timeout;
+	old = rpc_clnt_set_transport(clnt, xprt, timeout);
+
+	/*
+	 * Note: we must always create a new rpc_auth cache
+	 * when switching to a different server!  GSS contexts
+	 * in particular are between a single client and
+	 * server.
+	 */
+	rpc_unregister_client(clnt);
+	__rpc_clnt_remove_pipedir(clnt);
+	err = rpc_client_register(clnt, pseudoflavor);
+	if (err) {
+		rpc_clnt_set_transport(clnt, old, old_timeo);
+		rpc_client_register(clnt, pseudoflavor);
+		xprt_put(xprt);
+		return err;
+	}
+
+	synchronize_rcu();
+	xprt_put(old);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rpc_switch_client_transport);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

