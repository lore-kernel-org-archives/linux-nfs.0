Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:64535 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072Ab1EITgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:36:43 -0400
Received: by ywj3 with SMTP id 3so1917414ywj.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:36:42 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/16] SUNRPC: Move clnt->cl_server into struct rpc_xprt
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:36:39 -0400
Message-ID: <20110509193639.16568.89675.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

When the cl_xprt field is updated, the cl_server field will also have
to change.  Since the contents of cl_server follow the remote endpoint
of cl_xprt, just move that field to the rpc_xprt.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: simplify check_gss_callback_principal(), whitespace changes ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback.c           |    3 +-
 include/linux/sunrpc/clnt.h |    3 +-
 include/linux/sunrpc/xprt.h |    2 +
 net/sunrpc/clnt.c           |   74 ++++++++++++++++++++-----------------------
 net/sunrpc/rpc_pipe.c       |    2 +
 net/sunrpc/rpcb_clnt.c      |    9 +++--
 net/sunrpc/xprt.c           |   14 ++++++++
 7 files changed, 58 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index e3d2942..1253540 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -332,7 +332,6 @@ void nfs_callback_down(int minorversion)
 int
 check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 {
-	struct rpc_clnt *r = clp->cl_rpcclient;
 	char *p = svc_gss_principal(rqstp);
 
 	if (rqstp->rq_authop->flavour != RPC_AUTH_GSS)
@@ -353,7 +352,7 @@ check_gss_callback_principal(struct nfs_client *clp, struct svc_rqst *rqstp)
 	if (memcmp(p, "nfs@", 4) != 0)
 		return 0;
 	p += 4;
-	if (strcmp(p, r->cl_server) != 0)
+	if (strcmp(p, clp->cl_hostname) != 0)
 		return 0;
 	return 1;
 }
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 7a1d124..2eea0d7 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -42,7 +42,6 @@ struct rpc_clnt {
 				cl_vers,	/* RPC version number */
 				cl_maxproc;	/* max procedure number */
 
-	char *			cl_server;	/* server machine name */
 	char *			cl_protname;	/* protocol name */
 	struct rpc_auth *	cl_auth;	/* authenticator */
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
@@ -116,7 +115,7 @@ struct rpc_create_args {
 	size_t			addrsize;
 	struct sockaddr		*saddress;
 	const struct rpc_timeout *timeout;
-	char			*servername;
+	const char		*servername;
 	struct rpc_program	*program;
 	u32			prognumber;	/* overrides program->number */
 	u32			version;
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 81cce3b..5a75b4b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -225,6 +225,7 @@ struct rpc_xprt {
 	} stat;
 
 	struct net		*xprt_net;
+	const char		*servername;
 	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
@@ -254,6 +255,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
+	const char *		servername;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 31ee4db..6479e1d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -150,15 +150,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_auth		*auth;
 	int err;
-	size_t len;
 
 	/* sanity check the name before trying to print it */
-	err = -EINVAL;
-	len = strlen(args->servername);
-	if (len > RPC_MAXNETNAMELEN)
-		goto out_no_rpciod;
-	len++;
-
 	dprintk("RPC:       creating %s client for %s (xprt %p)\n",
 			program->name, args->servername, xprt);
 
@@ -181,16 +174,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	clnt->cl_server = clnt->cl_inline_name;
-	if (len > sizeof(clnt->cl_inline_name)) {
-		char *buf = kmalloc(len, GFP_KERNEL);
-		if (buf != NULL)
-			clnt->cl_server = buf;
-		else
-			len = sizeof(clnt->cl_inline_name);
-	}
-	strlcpy(clnt->cl_server, args->servername, len);
-
 	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
@@ -259,8 +242,6 @@ out_no_path:
 out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
-	if (clnt->cl_server != clnt->cl_inline_name)
-		kfree(clnt->cl_server);
 	kfree(clnt);
 out_err:
 	xprt_put(xprt);
@@ -290,6 +271,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
+		.servername = args->servername,
 		.bc_xprt = args->bc_xprt,
 	};
 	char servername[48];
@@ -298,7 +280,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.
 	 */
-	if (args->servername == NULL) {
+	if (xprtargs.servername == NULL) {
 		struct sockaddr_un *sun =
 				(struct sockaddr_un *)args->address;
 		struct sockaddr_in *sin =
@@ -325,7 +307,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 			 * address family isn't recognized. */
 			return ERR_PTR(-EINVAL);
 		}
-		args->servername = servername;
+		xprtargs.servername = servername;
 	}
 
 	xprt = xprt_create_transport(&xprtargs);
@@ -467,8 +449,9 @@ EXPORT_SYMBOL_GPL(rpc_killall_tasks);
  */
 void rpc_shutdown_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC:       shutting down %s client for %s\n",
-			clnt->cl_protname, clnt->cl_server);
+	dprintk_rcu("RPC:       shutting down %s client for %s\n",
+			clnt->cl_protname,
+			rcu_dereference(clnt->cl_xprt)->servername);
 
 	while (!list_empty(&clnt->cl_tasks)) {
 		rpc_killall_tasks(clnt);
@@ -486,8 +469,9 @@ EXPORT_SYMBOL_GPL(rpc_shutdown_client);
 static void
 rpc_free_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC:       destroying %s client for %s\n",
-			clnt->cl_protname, clnt->cl_server);
+	dprintk_rcu("RPC:       destroying %s client for %s\n",
+			clnt->cl_protname,
+			rcu_dereference(clnt->cl_xprt)->servername);
 	if (!IS_ERR(clnt->cl_path.dentry)) {
 		rpc_remove_client_dir(clnt->cl_path.dentry);
 		rpc_put_mount();
@@ -496,8 +480,6 @@ rpc_free_client(struct rpc_clnt *clnt)
 		rpc_release_client(clnt->cl_parent);
 		goto out_free;
 	}
-	if (clnt->cl_server != clnt->cl_inline_name)
-		kfree(clnt->cl_server);
 out_free:
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
@@ -1645,8 +1627,11 @@ call_timeout(struct rpc_task *task)
 	}
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty)
+			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
-				clnt->cl_protname, clnt->cl_server);
+				clnt->cl_protname,
+				rcu_dereference(clnt->cl_xprt)->servername);
+			rcu_read_unlock();
 		if (task->tk_flags & RPC_TASK_TIMEOUT)
 			rpc_exit(task, -ETIMEDOUT);
 		else
@@ -1656,9 +1641,13 @@ call_timeout(struct rpc_task *task)
 
 	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
-		if (clnt->cl_chatty)
+		if (clnt->cl_chatty) {
+			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
-			clnt->cl_protname, clnt->cl_server);
+			clnt->cl_protname,
+			rcu_dereference(clnt->cl_xprt)->servername);
+			rcu_read_unlock();
+		}
 	}
 	rpc_force_rebind(clnt);
 	/*
@@ -1688,9 +1677,13 @@ call_decode(struct rpc_task *task)
 			task->tk_pid, task->tk_status);
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
-		if (clnt->cl_chatty)
+		if (clnt->cl_chatty) {
+			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s OK\n",
-				clnt->cl_protname, clnt->cl_server);
+				clnt->cl_protname,
+				rcu_dereference(clnt->cl_xprt)->servername);
+			rcu_read_unlock();
+		}
 		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
 	}
 
@@ -1841,8 +1834,11 @@ rpc_verify_header(struct rpc_task *task)
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
+			rcu_read_lock();
 			printk(KERN_NOTICE "RPC: server %s requires stronger "
-			       "authentication.\n", task->tk_client->cl_server);
+			       "authentication.\n",
+			       rcu_dereference(task->tk_client->cl_xprt)->servername);
+			rcu_read_unlock();
 			break;
 		default:
 			dprintk("RPC: %5u %s: unknown auth error: %x\n",
@@ -1865,28 +1861,28 @@ rpc_verify_header(struct rpc_task *task)
 	case RPC_SUCCESS:
 		return p;
 	case RPC_PROG_UNAVAIL:
-		dprintk("RPC: %5u %s: program %u is unsupported by server %s\n",
+		dprintk_rcu("RPC: %5u %s: program %u is unsupported by server %s\n",
 				task->tk_pid, __func__,
 				(unsigned int)task->tk_client->cl_prog,
-				task->tk_client->cl_server);
+				rcu_dereference(task->tk_client->cl_xprt)->servername);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
-		dprintk("RPC: %5u %s: program %u, version %u unsupported by "
+		dprintk_rcu("RPC: %5u %s: program %u, version %u unsupported by "
 				"server %s\n", task->tk_pid, __func__,
 				(unsigned int)task->tk_client->cl_prog,
 				(unsigned int)task->tk_client->cl_vers,
-				task->tk_client->cl_server);
+				rcu_dereference(task->tk_client->cl_xprt)->servername);
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
+		dprintk_rcu("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
 				task->tk_pid, __func__,
 				rpc_proc_name(task),
 				task->tk_client->cl_prog,
 				task->tk_client->cl_vers,
-				task->tk_client->cl_server);
+				rcu_dereference(task->tk_client->cl_xprt)->servername);
 		error = -EOPNOTSUPP;
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 47053e5..e7b12b5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -361,7 +361,7 @@ rpc_show_info(struct seq_file *m, void *v)
 	struct rpc_clnt *clnt = m->private;
 
 	rcu_read_lock();
-	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
+	seq_printf(m, "RPC server: %s\n", rcu_dereference(clnt->cl_xprt)->servername);
 	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a861e19..9fa4cb4 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -291,8 +291,9 @@ out:
 	return result;
 }
 
-static struct rpc_clnt *rpcb_create(char *hostname, struct sockaddr *srvaddr,
-				    size_t salen, int proto, u32 version)
+static struct rpc_clnt *rpcb_create(const char *hostname,
+				    struct sockaddr *srvaddr, size_t salen,
+				    int proto, u32 version)
 {
 	struct rpc_create_args args = {
 		.net		= &init_net,
@@ -614,7 +615,7 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
-		clnt->cl_server, clnt->cl_prog, clnt->cl_vers, xprt->prot);
+		xprt->servername, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
 	/* Put self on the wait queue to ensure we get notified if
 	 * some other task is already attempting to bind the port */
@@ -665,7 +666,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __func__, bind_version);
 
-	rpcb_clnt = rpcb_create(clnt->cl_server, sap, salen, xprt->prot,
+	rpcb_clnt = rpcb_create(xprt->servername, sap, salen, xprt->prot,
 				bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce5eb68..76879bc 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -65,6 +65,7 @@
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
+static void	 xprt_destroy(struct rpc_xprt *xprt);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
@@ -740,7 +741,7 @@ static void xprt_connect_status(struct rpc_task *task)
 	default:
 		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
 				"server %s\n", task->tk_pid, -task->tk_status,
-				task->tk_client->cl_server);
+				xprt->servername);
 		xprt_release_write(xprt, task);
 		task->tk_status = -EIO;
 	}
@@ -1138,6 +1139,16 @@ found:
 
 	xprt_init_xid(xprt);
 
+	if (strlen(args->servername) > RPC_MAXNETNAMELEN) {
+		xprt_destroy(xprt);
+		return ERR_PTR(-EINVAL);
+	}
+	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
+	if (xprt->servername == NULL) {
+		xprt_destroy(xprt);
+		return ERR_PTR(-ENOMEM);
+	}
+
 	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
 	return xprt;
@@ -1160,6 +1171,7 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 	rpc_destroy_wait_queue(&xprt->resend);
 	rpc_destroy_wait_queue(&xprt->backlog);
 	cancel_work_sync(&xprt->task_cleanup);
+	kfree(xprt->servername);
 	/*
 	 * Tear down transport state and free the rpc_xprt
 	 */

