Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34288 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751429AbdBHWC4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 17:02:56 -0500
Subject: [PATCH v3 10/12] sunrpc: Enable calls to rpc_call_null_helper()
 from other modules
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 17:00:59 -0500
Message-ID: <20170208220059.7152.8131.stgit@manet.1015granger.net>
In-Reply-To: <20170208214854.7152.83331.stgit@manet.1015granger.net>
References: <20170208214854.7152.83331.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To help detect unreachable servers, I'd like to emit an RPC ping
from rpcrdma.ko.

authnull_ops is not visible outside the sunrpc.ko module, so fold
the common case into rpc_call_null_helper, and export it, so that
it can be invoked from other kernel modules.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c            |    3 +--
 fs/nfsd/nfs4callback.c       |    2 +-
 include/linux/sunrpc/clnt.h  |    5 +++++
 include/linux/sunrpc/sched.h |    2 ++
 net/sunrpc/clnt.c            |   28 ++++++++++++++--------------
 5 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0a0eaec..0091e5a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -7640,8 +7640,7 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	if (xprt) {
 		calldata->xprt = xprt;
 		task_setup_data.rpc_xprt = xprt;
-		task_setup_data.flags =
-				RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC;
+		task_setup_data.flags = RPC_TASK_SOFTPING | RPC_TASK_ASYNC;
 		calldata->args.verifier = &clp->cl_confirm;
 	} else {
 		calldata->args.verifier = &verifier;
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index eb78109..e1e2224 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1182,7 +1182,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	}
 
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
-	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFTPING,
 			cb->cb_ops ? &nfsd4_cb_ops : &nfsd4_cb_probe_ops, cb);
 }
 
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 333ad11..f576127 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -173,6 +173,11 @@ int		rpc_call_async(struct rpc_clnt *clnt,
 			       void *calldata);
 int		rpc_call_sync(struct rpc_clnt *clnt,
 			      const struct rpc_message *msg, int flags);
+struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
+				      struct rpc_xprt *xprt,
+				      struct rpc_cred *cred, int flags,
+				      const struct rpc_call_ops *ops,
+				      void *data);
 struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred,
 			       int flags);
 int		rpc_restart_call_prepare(struct rpc_task *);
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 7ba040c..13822e6 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -128,6 +128,8 @@ struct rpc_task_setup {
 #define RPC_TASK_NOCONNECT	0x2000		/* return ENOTCONN if not connected */
 #define RPC_TASK_NO_RETRANS_TIMEOUT	0x4000		/* wait forever for a reply */
 
+#define RPC_TASK_SOFTPING	(RPC_TASK_SOFT | RPC_TASK_SOFTCONN)
+
 #define RPC_IS_ASYNC(t)		((t)->tk_flags & RPC_TASK_ASYNC)
 #define RPC_IS_SWAPPER(t)	((t)->tk_flags & RPC_TASK_SWAPPER)
 #define RPC_DO_ROOTOVERRIDE(t)	((t)->tk_flags & RPC_TASK_ROOTCREDS)
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1dc9f3b..642c93d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2520,12 +2520,11 @@ static int rpc_ping(struct rpc_clnt *clnt)
 	};
 	int err;
 	msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN);
+	err = rpc_call_sync(clnt, &msg, RPC_TASK_SOFTPING);
 	put_rpccred(msg.rpc_cred);
 	return err;
 }
 
-static
 struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 		struct rpc_xprt *xprt, struct rpc_cred *cred, int flags,
 		const struct rpc_call_ops *ops, void *data)
@@ -2542,9 +2541,17 @@ struct rpc_task *rpc_call_null_helper(struct rpc_clnt *clnt,
 		.callback_data = data,
 		.flags = flags,
 	};
+	struct rpc_task *task;
 
-	return rpc_run_task(&task_setup_data);
+	if (!cred)
+		msg.rpc_cred = authnull_ops.lookup_cred(NULL, NULL, 0);
+	task = rpc_run_task(&task_setup_data);
+	if (!cred)
+		put_rpccred(msg.rpc_cred);
+
+	return task;
 }
+EXPORT_SYMBOL_GPL(rpc_call_null_helper);
 
 struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int flags)
 {
@@ -2591,7 +2598,6 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 		void *dummy)
 {
 	struct rpc_cb_add_xprt_calldata *data;
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 
 	data = kmalloc(sizeof(*data), GFP_NOFS);
@@ -2600,11 +2606,9 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 	data->xps = xprt_switch_get(xps);
 	data->xprt = xprt_get(xprt);
 
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
-			&rpc_cb_add_xprt_call_ops, data);
-	put_rpccred(cred);
+	task = rpc_call_null_helper(clnt, xprt, NULL,
+				    RPC_TASK_SOFTPING | RPC_TASK_ASYNC,
+				    &rpc_cb_add_xprt_call_ops, data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
@@ -2635,7 +2639,6 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 				     struct rpc_xprt *xprt,
 				     void *data)
 {
-	struct rpc_cred *cred;
 	struct rpc_task *task;
 	struct rpc_add_xprt_test *xtest = (struct rpc_add_xprt_test *)data;
 	int status = -EADDRINUSE;
@@ -2647,11 +2650,8 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 		goto out_err;
 
 	/* Test the connection */
-	cred = authnull_ops.lookup_cred(NULL, NULL, 0);
-	task = rpc_call_null_helper(clnt, xprt, cred,
-				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
+	task = rpc_call_null_helper(clnt, xprt, NULL, RPC_TASK_SOFTPING,
 				    NULL, NULL);
-	put_rpccred(cred);
 	if (IS_ERR(task)) {
 		status = PTR_ERR(task);
 		goto out_err;

