Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:41078 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab2A3TaD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:03 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:03 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 5D0A3C9004C
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:29:59 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTwmD348346
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 14:29:58 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTwRt007310
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvJG007268
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 04/13] SUNRPC: Add a helper to switch the transport of the rpc_client
Date: Mon, 30 Jan 2012 13:29:46 -0600
Message-Id: <1327951795-16400-5-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: fix whitespace ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 include/linux/sunrpc/clnt.h |    3 ++
 net/sunrpc/clnt.c           |   76 +++++++++++++++++++++++++++++++++++++++---
 2 files changed, 73 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 0adc955..a786143 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -145,6 +145,9 @@ void		rpc_task_release_client(struct rpc_task *);
 
 int		rpc_lock_client(struct rpc_clnt *clnt, unsigned long timeout);
 void		rpc_unlock_client(struct rpc_clnt *clnt);
+int		rpc_switch_client_transport(struct rpc_clnt *,
+					    struct xprt_create *,
+					    const struct rpc_timeout *);
 
 int		rpcb_create_local(void);
 void		rpcb_put_local(void);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 26c1a2f..c5cc8ac 100644
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
@@ -142,12 +143,35 @@ err:
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
@@ -173,7 +197,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
 	clnt->cl_protname = program->name;
@@ -188,16 +211,15 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
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
@@ -411,6 +433,48 @@ out_no_clnt:
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
-- 
1.7.8.3

