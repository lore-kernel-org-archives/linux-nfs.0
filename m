From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/8] NLM/lockd: convert __nlm_async_call to use
	rpc_run_task()
Date: Thu, 03 Apr 2008 18:39:22 -0400
Message-ID: <20080403223921.12713.3284.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8113 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751979AbYDCW57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:57:59 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Staubach comments:

> In the course of investigating testing failures in the locking phase of
> the Connectathon testsuite, I discovered a couple of things.  One was
> that one of the tests in the locking tests was racy when it didn't seem
> to need to be and two, that the NFS client asynchronously releases locks
> when a process is exiting.
...
> The Single UNIX Specification Version 3 specifies that:  "All locks
> associated with a file for a given process shall be removed when a file
> descriptor for that file is closed by that process or the process holding
> that file descriptor terminates.".
>
> This does not specify whether those locks must be released prior to the
> completion of the exit processing for the process or not.  However,
> general assumptions seem to be that those locks will be released.  This
> leads to more deterministic behavior under normal circumstances.

The following patch converts the NFSv2/v3 locking code to use the same
mechanism as NFSv4 for sending asynchronous RPC calls and then waiting for
them to complete. This ensures that the UNLOCK and CANCEL RPC calls will
complete even if the user interrupts the call, yet satisfies the
above request for synchronous behaviour on process exit.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   64 +++++++++++++++++++++++++++++++++++++++++++--------
 1 files changed, 54 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 749eb53..a34b709 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -346,10 +346,16 @@ in_grace_period:
 /*
  * Generic NLM call, async version.
  */
-static int __nlm_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message *msg, const struct rpc_call_ops *tk_ops)
+static struct rpc_task *__nlm_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message *msg, const struct rpc_call_ops *tk_ops)
 {
 	struct nlm_host	*host = req->a_host;
 	struct rpc_clnt	*clnt;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_message = msg,
+		.callback_ops = tk_ops,
+		.callback_data = req,
+		.flags = RPC_TASK_ASYNC,
+	};
 
 	dprintk("lockd: call procedure %d on %s (async)\n",
 			(int)proc, host->h_name);
@@ -359,21 +365,36 @@ static int __nlm_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message *
 	if (clnt == NULL)
 		goto out_err;
 	msg->rpc_proc = &clnt->cl_procinfo[proc];
+	task_setup_data.rpc_client = clnt;
 
         /* bootstrap and kick off the async RPC call */
-        return rpc_call_async(clnt, msg, RPC_TASK_ASYNC, tk_ops, req);
+	return rpc_run_task(&task_setup_data);
 out_err:
 	tk_ops->rpc_release(req);
-	return -ENOLCK;
+	return ERR_PTR(-ENOLCK);
+}
+
+static int nlm_do_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message *msg, const struct rpc_call_ops *tk_ops)
+{
+	struct rpc_task *task;
+
+	task = __nlm_async_call(req, proc, msg, tk_ops);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
+/*
+ * NLM asynchronous call.
+ */
 int nlm_async_call(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
 {
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_args,
 		.rpc_resp	= &req->a_res,
 	};
-	return __nlm_async_call(req, proc, &msg, tk_ops);
+	return nlm_do_async_call(req, proc, &msg, tk_ops);
 }
 
 int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
@@ -381,7 +402,32 @@ int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *t
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_res,
 	};
-	return __nlm_async_call(req, proc, &msg, tk_ops);
+	return nlm_do_async_call(req, proc, &msg, tk_ops);
+}
+
+/*
+ * NLM client asynchronous call.
+ *
+ * Note that although the calls are asynchronous, and are therefore
+ *      guaranteed to complete, we still always attempt to wait for
+ *      completion in order to be able to correctly track the lock
+ *      state.
+ */
+static int nlmclnt_async_call(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
+{
+	struct rpc_message msg = {
+		.rpc_argp	= &req->a_args,
+		.rpc_resp	= &req->a_res,
+	};
+	struct rpc_task *task;
+	int err;
+
+	task = __nlm_async_call(req, proc, &msg, tk_ops);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	err = rpc_wait_for_completion_task(task);
+	rpc_put_task(task);
+	return err;
 }
 
 /*
@@ -620,10 +666,8 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 		goto out;
 	}
 
-	if (req->a_flags & RPC_TASK_ASYNC)
-		return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
-
-	status = nlmclnt_call(req, NLMPROC_UNLOCK);
+	atomic_inc(&req->a_count);
+	status = nlmclnt_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
 	if (status < 0)
 		goto out;
 
@@ -697,7 +741,7 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.block = block;
 
-	status = nlm_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
+	status = nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
 
 	spin_lock_irqsave(&current->sighand->siglock, flags);
 	current->blocked = oldset;

