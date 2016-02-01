Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33492 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933009AbcBAPXT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 10:23:19 -0500
Received: by mail-io0-f181.google.com with SMTP id f81so159991923iof.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 07:23:19 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 07/13] SUNRPC: Use the multipath iterator to assign a transport to each task
Date: Mon,  1 Feb 2016 10:22:29 -0500
Message-Id: <1454340155-7670-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1454340155-7670-7-git-send-email-trond.myklebust@primarydata.com>
References: <1454340155-7670-1-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-2-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-3-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-4-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-5-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-6-git-send-email-trond.myklebust@primarydata.com>
 <1454340155-7670-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/sched.h |  2 ++
 net/sunrpc/clnt.c            | 38 ++++++++++++++++++++------------------
 net/sunrpc/rpcb_clnt.c       |  6 ++----
 net/sunrpc/xprt.c            | 14 +++-----------
 net/sunrpc/xprtsock.c        |  4 +---
 5 files changed, 28 insertions(+), 36 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index ee0fbcf9b02e..0b248e98ee3b 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -69,6 +69,8 @@ struct rpc_task {
 	const struct rpc_call_ops *tk_ops;	/* Caller callbacks */
 
 	struct rpc_clnt *	tk_client;	/* RPC client */
+	struct rpc_xprt *	tk_xprt;	/* Transport */
+
 	struct rpc_rqst *	tk_rqstp;	/* RPC request */
 
 	struct workqueue_struct	*tk_workqueue;	/* Normally rpciod, but could
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 625fb8a184c6..8e46fa5a2ab1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -894,6 +894,7 @@ EXPORT_SYMBOL_GPL(rpc_bind_new_program);
 void rpc_task_release_client(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
+	struct rpc_xprt *xprt = task->tk_xprt;
 
 	if (clnt != NULL) {
 		/* Remove from client task list */
@@ -904,13 +905,22 @@ void rpc_task_release_client(struct rpc_task *task)
 
 		rpc_release_client(clnt);
 	}
+
+	if (xprt != NULL) {
+		task->tk_xprt = NULL;
+
+		xprt_put(xprt);
+	}
 }
 
 static
 void rpc_task_set_client(struct rpc_task *task, struct rpc_clnt *clnt)
 {
+
 	if (clnt != NULL) {
 		rpc_task_release_client(task);
+		if (task->tk_xprt == NULL)
+			task->tk_xprt = xprt_iter_get_next(&clnt->cl_xpi);
 		task->tk_client = clnt;
 		atomic_inc(&clnt->cl_count);
 		if (clnt->cl_softrtry)
@@ -2122,11 +2132,9 @@ call_timeout(struct rpc_task *task)
 	}
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty) {
-			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_program->name,
-				rcu_dereference(clnt->cl_xprt)->servername);
-			rcu_read_unlock();
+				task->tk_xprt->servername);
 		}
 		if (task->tk_flags & RPC_TASK_TIMEOUT)
 			rpc_exit(task, -ETIMEDOUT);
@@ -2138,11 +2146,9 @@ call_timeout(struct rpc_task *task)
 	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
 		task->tk_flags |= RPC_CALL_MAJORSEEN;
 		if (clnt->cl_chatty) {
-			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s not responding, still trying\n",
 			clnt->cl_program->name,
-			rcu_dereference(clnt->cl_xprt)->servername);
-			rcu_read_unlock();
+			task->tk_xprt->servername);
 		}
 	}
 	rpc_force_rebind(clnt);
@@ -2172,11 +2178,9 @@ call_decode(struct rpc_task *task)
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
 		if (clnt->cl_chatty) {
-			rcu_read_lock();
 			printk(KERN_NOTICE "%s: server %s OK\n",
 				clnt->cl_program->name,
-				rcu_dereference(clnt->cl_xprt)->servername);
-			rcu_read_unlock();
+				task->tk_xprt->servername);
 		}
 		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
 	}
@@ -2330,11 +2334,9 @@ rpc_verify_header(struct rpc_task *task)
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
-			rcu_read_lock();
 			printk(KERN_NOTICE "RPC: server %s requires stronger "
 			       "authentication.\n",
-			       rcu_dereference(clnt->cl_xprt)->servername);
-			rcu_read_unlock();
+			       task->tk_xprt->servername);
 			break;
 		default:
 			dprintk("RPC: %5u %s: unknown auth error: %x\n",
@@ -2359,27 +2361,27 @@ rpc_verify_header(struct rpc_task *task)
 	case RPC_SUCCESS:
 		return p;
 	case RPC_PROG_UNAVAIL:
-		dprintk_rcu("RPC: %5u %s: program %u is unsupported "
+		dprintk("RPC: %5u %s: program %u is unsupported "
 				"by server %s\n", task->tk_pid, __func__,
 				(unsigned int)clnt->cl_prog,
-				rcu_dereference(clnt->cl_xprt)->servername);
+				task->tk_xprt->servername);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
-		dprintk_rcu("RPC: %5u %s: program %u, version %u unsupported "
+		dprintk("RPC: %5u %s: program %u, version %u unsupported "
 				"by server %s\n", task->tk_pid, __func__,
 				(unsigned int)clnt->cl_prog,
 				(unsigned int)clnt->cl_vers,
-				rcu_dereference(clnt->cl_xprt)->servername);
+				task->tk_xprt->servername);
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk_rcu("RPC: %5u %s: proc %s unsupported by program %u, "
+		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
 				"version %u on server %s\n",
 				task->tk_pid, __func__,
 				rpc_proc_name(task),
 				clnt->cl_prog, clnt->cl_vers,
-				rcu_dereference(clnt->cl_xprt)->servername);
+				task->tk_xprt->servername);
 		error = -EOPNOTSUPP;
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 44f025c150d8..5b30603596d0 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -683,11 +683,9 @@ void rpcb_getport_async(struct rpc_task *task)
 	int status;
 
 	rcu_read_lock();
-	do {
-		clnt = rpcb_find_transport_owner(task->tk_client);
-		xprt = xprt_get(rcu_dereference(clnt->cl_xprt));
-	} while (xprt == NULL);
+	clnt = rpcb_find_transport_owner(task->tk_client);
 	rcu_read_unlock();
+	xprt = xprt_get(task->tk_xprt);
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 323b332f8f7c..216a1385718a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1181,7 +1181,7 @@ EXPORT_SYMBOL_GPL(xprt_free);
  */
 void xprt_reserve(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt;
+	struct rpc_xprt *xprt = task->tk_xprt;
 
 	task->tk_status = 0;
 	if (task->tk_rqstp != NULL)
@@ -1189,11 +1189,8 @@ void xprt_reserve(struct rpc_task *task)
 
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	rcu_read_lock();
-	xprt = rcu_dereference(task->tk_client->cl_xprt);
 	if (!xprt_throttle_congested(xprt, task))
 		xprt->ops->alloc_slot(xprt, task);
-	rcu_read_unlock();
 }
 
 /**
@@ -1207,7 +1204,7 @@ void xprt_reserve(struct rpc_task *task)
  */
 void xprt_retry_reserve(struct rpc_task *task)
 {
-	struct rpc_xprt	*xprt;
+	struct rpc_xprt *xprt = task->tk_xprt;
 
 	task->tk_status = 0;
 	if (task->tk_rqstp != NULL)
@@ -1215,10 +1212,7 @@ void xprt_retry_reserve(struct rpc_task *task)
 
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	rcu_read_lock();
-	xprt = rcu_dereference(task->tk_client->cl_xprt);
 	xprt->ops->alloc_slot(xprt, task);
-	rcu_read_unlock();
 }
 
 static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
@@ -1265,11 +1259,9 @@ void xprt_release(struct rpc_task *task)
 
 	if (req == NULL) {
 		if (task->tk_client) {
-			rcu_read_lock();
-			xprt = rcu_dereference(task->tk_client->cl_xprt);
+			xprt = task->tk_xprt;
 			if (xprt->snd_task == task)
 				xprt_release_write(xprt, task);
-			rcu_read_unlock();
 		}
 		return;
 	}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fde2138b81e7..65e759569e48 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1844,9 +1844,7 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
  */
 static void xs_local_rpcbind(struct rpc_task *task)
 {
-	rcu_read_lock();
-	xprt_set_bound(rcu_dereference(task->tk_client->cl_xprt));
-	rcu_read_unlock();
+	xprt_set_bound(task->tk_xprt);
 }
 
 static void xs_local_set_port(struct rpc_xprt *xprt, unsigned short port)
-- 
2.5.0

