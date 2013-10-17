Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44557 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758540Ab3JQSMY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:12:24 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HICNOR004705
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:24 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HICNAF009990
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:12:23 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/21] SUNRPC: Add a helper to switch the transport of an rpc_clnt
Date: Thu, 17 Oct 2013 14:12:23 -0400
Message-Id: <20131017181222.1073.37277.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add an RPC client API to redirect an rpc_clnt's transport from a
source server to a destination server during a migration event.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: forward ported to 3.12 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/clnt.h |    4 ++
 net/sunrpc/clnt.c           |  107 ++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 104 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6740801..e90c543 100644
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
index 1aa361b..d2c8091 100644
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
@@ -264,6 +265,25 @@ void rpc_clients_notifier_unregister(void)
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
@@ -338,7 +358,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 {
 	const struct rpc_program *program = args->program;
 	const struct rpc_version *version;
-	struct rpc_clnt		*clnt = NULL;
+	struct rpc_clnt *clnt = NULL;
+	const struct rpc_timeout *timeout;
 	int err;
 
 	/* sanity check the name before trying to print it */
@@ -366,7 +387,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
 	if (err)
 		goto out_no_clid;
 
-	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_prog     = args->prognumber ? : program->number;
@@ -381,16 +401,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args,
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
 
@@ -601,6 +620,80 @@ rpc_clone_client_set_auth(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
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
+ * there are no active RPC tasks by using some form of locking.
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
+	struct rpc_clnt *parent;
+	int err;
+
+	xprt = xprt_create_transport(args);
+	if (IS_ERR(xprt)) {
+		dprintk("RPC:       failed to create new xprt for clnt %p\n",
+			clnt);
+		return PTR_ERR(xprt);
+	}
+
+	pseudoflavor = clnt->cl_auth->au_flavor;
+
+	old_timeo = clnt->cl_timeout;
+	old = rpc_clnt_set_transport(clnt, xprt, timeout);
+
+	rpc_unregister_client(clnt);
+	__rpc_clnt_remove_pipedir(clnt);
+
+	/*
+	 * A new transport was created.  "clnt" therefore
+	 * becomes the root of a new cl_parent tree.  clnt's
+	 * children, if it has any, still point to the old xprt.
+	 */
+	parent = clnt->cl_parent;
+	clnt->cl_parent = clnt;
+
+	/*
+	 * The old rpc_auth cache cannot be re-used.  GSS
+	 * contexts in particular are between a single
+	 * client and server.
+	 */
+	err = rpc_client_register(clnt, pseudoflavor, NULL);
+	if (err)
+		goto out_revert;
+
+	synchronize_rcu();
+	if (parent != clnt)
+		rpc_release_client(parent);
+	xprt_put(old);
+	dprintk("RPC:       replaced xprt for clnt %p\n", clnt);
+	return 0;
+
+out_revert:
+	rpc_clnt_set_transport(clnt, old, old_timeo);
+	clnt->cl_parent = parent;
+	rpc_client_register(clnt, pseudoflavor, NULL);
+	xprt_put(xprt);
+	dprintk("RPC:       failed to switch xprt for clnt %p\n", clnt);
+	return err;
+}
+EXPORT_SYMBOL_GPL(rpc_switch_client_transport);
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?

