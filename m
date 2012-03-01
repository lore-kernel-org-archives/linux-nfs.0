Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:51202 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291Ab2CAWBH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:01:07 -0500
Received: by iagz16 with SMTP id z16so1389945iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Mar 2012 14:01:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] SUNRPC: Move clnt->cl_server into struct rpc_xprt
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 01 Mar 2012 17:01:05 -0500
Message-ID: <20120301220105.2138.97152.stgit@degas.1015granger.net>
In-Reply-To: <20120301215755.2138.73488.stgit@degas.1015granger.net>
References: <20120301215755.2138.73488.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

When the cl_xprt field is updated, the cl_server field will also have
to change.  Since the contents of cl_server follow the remote endpoint
of cl_xprt, just move that field to the rpc_xprt.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
[ cel: simplify check_gss_callback_principal(), whitespace changes ]
[ cel: forward ported to 3.4 ]
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/callback.c           |    3 -
 fs/nfs/nfs4proc.c           |    3 +
 include/linux/sunrpc/clnt.h |    1 
 include/linux/sunrpc/xprt.h |    2 +
 net/sunrpc/clnt.c           |   88 +++++++++++++++++++++----------------------
 net/sunrpc/rpc_pipe.c       |    3 +
 net/sunrpc/rpcb_clnt.c      |    4 +-
 net/sunrpc/xprt.c           |   15 +++++++
 8 files changed, 66 insertions(+), 53 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 4a122ae..2afe233 100644
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
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3ec09fb..d43bcda 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1100,6 +1100,7 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 	if (state == NULL)
 		goto err_put_inode;
 	if (data->o_res.delegation_type != 0) {
+		struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 		int delegation_flags = 0;
 
 		rcu_read_lock();
@@ -1111,7 +1112,7 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 			pr_err_ratelimited("NFS: Broken NFSv4 server %s is "
 					"returning a delegation for "
 					"OPEN(CLAIM_DELEGATE_CUR)\n",
-					NFS_CLIENT(inode)->cl_server);
+					clp->cl_hostname);
 		} else if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
 			nfs_inode_set_delegation(state->inode,
 					data->owner->so_cred,
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index e3d12b4..acd5502 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -41,7 +41,6 @@ struct rpc_clnt {
 				cl_vers,	/* RPC version number */
 				cl_maxproc;	/* max procedure number */
 
-	const char *		cl_server;	/* server machine name */
 	const char *		cl_protname;	/* protocol name */
 	struct rpc_auth *	cl_auth;	/* authenticator */
 	struct rpc_stat *	cl_stats;	/* per-program statistics */
diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index ea712f9..77d278d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -229,6 +229,7 @@ struct rpc_xprt {
 	} stat;
 
 	struct net		*xprt_net;
+	const char		*servername;
 	const char		*address_strings[RPC_DISPLAY_MAX];
 };
 
@@ -258,6 +259,7 @@ struct xprt_create {
 	struct sockaddr *	srcaddr;	/* optional local address */
 	struct sockaddr *	dstaddr;	/* remote peer address */
 	size_t			addrlen;
+	const char		*servername;
 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
 };
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index f043c7b..84bebb1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -249,15 +249,8 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
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
 
@@ -280,10 +273,6 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 		goto out_err;
 	clnt->cl_parent = clnt;
 
-	clnt->cl_server = kstrdup(args->servername, GFP_KERNEL);
-	if (clnt->cl_server == NULL)
-		goto out_no_server;
-
 	rcu_assign_pointer(clnt->cl_xprt, xprt);
 	clnt->cl_procinfo = version->procs;
 	clnt->cl_maxproc  = version->nrprocs;
@@ -347,8 +336,6 @@ out_no_path:
 out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
-	kfree(clnt->cl_server);
-out_no_server:
 	kfree(clnt);
 out_err:
 	xprt_put(xprt);
@@ -378,6 +365,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 		.srcaddr = args->saddress,
 		.dstaddr = args->address,
 		.addrlen = args->addrsize,
+		.servername = args->servername,
 		.bc_xprt = args->bc_xprt,
 	};
 	char servername[48];
@@ -386,7 +374,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 * If the caller chooses not to specify a hostname, whip
 	 * up a string representation of the passed-in address.
 	 */
-	if (args->servername == NULL) {
+	if (xprtargs.servername == NULL) {
 		struct sockaddr_un *sun =
 				(struct sockaddr_un *)args->address;
 		struct sockaddr_in *sin =
@@ -413,7 +401,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 			 * address family isn't recognized. */
 			return ERR_PTR(-EINVAL);
 		}
-		args->servername = servername;
+		xprtargs.servername = servername;
 	}
 
 	xprt = xprt_create_transport(&xprtargs);
@@ -472,9 +460,6 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new = kmemdup(clnt, sizeof(*new), GFP_KERNEL);
 	if (!new)
 		goto out_no_clnt;
-	new->cl_server = kstrdup(clnt->cl_server, GFP_KERNEL);
-	if (new->cl_server == NULL)
-		goto out_no_server;
 	new->cl_parent = clnt;
 	/* Turn off autobind on clones */
 	new->cl_autobind = 0;
@@ -512,8 +497,6 @@ out_no_transport:
 out_no_principal:
 	rpc_free_iostats(new->cl_metrics);
 out_no_stats:
-	kfree(new->cl_server);
-out_no_server:
 	kfree(new);
 out_no_clnt:
 	dprintk("RPC:       %s: returned error %d\n", __func__, err);
@@ -558,8 +541,9 @@ EXPORT_SYMBOL_GPL(rpc_killall_tasks);
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
@@ -577,11 +561,11 @@ EXPORT_SYMBOL_GPL(rpc_shutdown_client);
 static void
 rpc_free_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC:       destroying %s client for %s\n",
-			clnt->cl_protname, clnt->cl_server);
+	dprintk_rcu("RPC:       destroying %s client for %s\n",
+			clnt->cl_protname,
+			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		rpc_release_client(clnt->cl_parent);
-	kfree(clnt->cl_server);
 	rpc_unregister_client(clnt);
 	rpc_clnt_remove_pipedir(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
@@ -1669,8 +1653,11 @@ call_timeout(struct rpc_task *task)
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
@@ -1680,9 +1667,13 @@ call_timeout(struct rpc_task *task)
 
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
@@ -1711,9 +1702,13 @@ call_decode(struct rpc_task *task)
 	dprint_status(task);
 
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
 
@@ -1791,6 +1786,7 @@ rpc_encode_header(struct rpc_task *task)
 static __be32 *
 rpc_verify_header(struct rpc_task *task)
 {
+	struct rpc_clnt *clnt = task->tk_client;
 	struct kvec *iov = &task->tk_rqstp->rq_rcv_buf.head[0];
 	int len = task->tk_rqstp->rq_rcv_buf.len >> 2;
 	__be32	*p = iov->iov_base;
@@ -1863,8 +1859,11 @@ rpc_verify_header(struct rpc_task *task)
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
+			rcu_read_lock();
 			printk(KERN_NOTICE "RPC: server %s requires stronger "
-			       "authentication.\n", task->tk_client->cl_server);
+			       "authentication.\n",
+			       rcu_dereference(clnt->cl_xprt)->servername);
+			rcu_read_unlock();
 			break;
 		default:
 			dprintk("RPC: %5u %s: unknown auth error: %x\n",
@@ -1887,28 +1886,27 @@ rpc_verify_header(struct rpc_task *task)
 	case RPC_SUCCESS:
 		return p;
 	case RPC_PROG_UNAVAIL:
-		dprintk("RPC: %5u %s: program %u is unsupported by server %s\n",
-				task->tk_pid, __func__,
-				(unsigned int)task->tk_client->cl_prog,
-				task->tk_client->cl_server);
+		dprintk_rcu("RPC: %5u %s: program %u is unsupported "
+				"by server %s\n", task->tk_pid, __func__,
+				(unsigned int)clnt->cl_prog,
+				rcu_dereference(clnt->cl_xprt)->servername);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
-		dprintk("RPC: %5u %s: program %u, version %u unsupported by "
-				"server %s\n", task->tk_pid, __func__,
-				(unsigned int)task->tk_client->cl_prog,
-				(unsigned int)task->tk_client->cl_vers,
-				task->tk_client->cl_server);
+		dprintk_rcu("RPC: %5u %s: program %u, version %u unsupported "
+				"by server %s\n", task->tk_pid, __func__,
+				(unsigned int)clnt->cl_prog,
+				(unsigned int)clnt->cl_vers,
+				rcu_dereference(clnt->cl_xprt)->servername);
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
+		dprintk_rcu("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
 				task->tk_pid, __func__,
 				rpc_proc_name(task),
-				task->tk_client->cl_prog,
-				task->tk_client->cl_vers,
-				task->tk_client->cl_server);
+				clnt->cl_prog, clnt->cl_vers,
+				rcu_dereference(clnt->cl_xprt)->servername);
 		error = -EOPNOTSUPP;
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
@@ -1922,7 +1920,7 @@ rpc_verify_header(struct rpc_task *task)
 	}
 
 out_garbage:
-	task->tk_client->cl_stats->rpcgarbage++;
+	clnt->cl_stats->rpcgarbage++;
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
 		dprintk("RPC: %5u %s: retrying\n",
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index bbd636b..3c9b16f 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -385,7 +385,8 @@ rpc_show_info(struct seq_file *m, void *v)
 	struct rpc_clnt *clnt = m->private;
 
 	rcu_read_lock();
-	seq_printf(m, "RPC server: %s\n", clnt->cl_server);
+	seq_printf(m, "RPC server: %s\n",
+			rcu_dereference(clnt->cl_xprt)->servername);
 	seq_printf(m, "service: %s (%d) version %d\n", clnt->cl_protname,
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 4f8af63..e699ff0 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -663,7 +663,7 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
-		clnt->cl_server, clnt->cl_prog, clnt->cl_vers, xprt->prot);
+		xprt->servername, clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
 	/* Put self on the wait queue to ensure we get notified if
 	 * some other task is already attempting to bind the port */
@@ -714,7 +714,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __func__, bind_version);
 
-	rpcb_clnt = rpcb_create(xprt->xprt_net, clnt->cl_server, sap, salen,
+	rpcb_clnt = rpcb_create(xprt->xprt_net, xprt->servername, sap, salen,
 				xprt->prot, bind_version);
 	if (IS_ERR(rpcb_clnt)) {
 		status = PTR_ERR(rpcb_clnt);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 32e3794..0cbcd1a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -66,6 +66,7 @@ static void	 xprt_init(struct rpc_xprt *xprt, struct net *net);
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
+static void	 xprt_destroy(struct rpc_xprt *xprt);
 
 static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
@@ -751,7 +752,7 @@ static void xprt_connect_status(struct rpc_task *task)
 	default:
 		dprintk("RPC: %5u xprt_connect_status: error %d connecting to "
 				"server %s\n", task->tk_pid, -task->tk_status,
-				task->tk_client->cl_server);
+				xprt->servername);
 		xprt_release_write(xprt, task);
 		task->tk_status = -EIO;
 	}
@@ -1229,6 +1230,17 @@ found:
 			    (unsigned long)xprt);
 	else
 		init_timer(&xprt->timer);
+
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
 out:
@@ -1251,6 +1263,7 @@ static void xprt_destroy(struct rpc_xprt *xprt)
 	rpc_destroy_wait_queue(&xprt->sending);
 	rpc_destroy_wait_queue(&xprt->backlog);
 	cancel_work_sync(&xprt->task_cleanup);
+	kfree(xprt->servername);
 	/*
 	 * Tear down transport state and free the rpc_xprt
 	 */

