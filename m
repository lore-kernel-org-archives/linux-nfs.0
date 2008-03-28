From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NLM/lockd: convert __nlm_async_call to use
	rpc_run_task()
Date: Fri, 28 Mar 2008 16:12:29 -0400
Message-ID: <20080328201229.18158.35718.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080328201229.18158.52437.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60292 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753941AbYC1UTg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 28 Mar 2008 16:19:36 -0400
In-Reply-To: <20080328201229.18158.52437.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
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

 fs/lockd/clntproc.c |   58 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index b6b74a6..82c9a27 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -343,10 +343,16 @@ in_grace_period:
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
@@ -356,21 +362,38 @@ static int __nlm_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message *
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
 }
 
+/*
+ * NLM asynchronous call.
+ *
+ * Note that although the calls are asynchronous, and are therefore
+ *      guaranteed to complete, we still always attempt to wait for
+ *      completion in order to be able to correctly track the lock
+ *      state.
+ */
 int nlm_async_call(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
 {
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_args,
 		.rpc_resp	= &req->a_res,
 	};
-	return __nlm_async_call(req, proc, &msg, tk_ops);
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
 
 int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
@@ -378,7 +401,13 @@ int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *t
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_res,
 	};
-	return __nlm_async_call(req, proc, &msg, tk_ops);
+	struct rpc_task *task;
+
+	task = __nlm_async_call(req, proc, &msg, tk_ops);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	rpc_put_task(task);
+	return 0;
 }
 
 /*
@@ -597,8 +626,6 @@ static int
 nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 {
 	struct nlm_host	*host = req->a_host;
-	struct nlm_res	*resp = &req->a_res;
-	int status = 0;
 
 	/*
 	 * Note: the server is supposed to either grant us the unlock
@@ -613,23 +640,10 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	}
 	up_read(&host->h_rwsem);
 
-	if (req->a_flags & RPC_TASK_ASYNC)
-		return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
-
-	status = nlmclnt_call(req, NLMPROC_UNLOCK);
-	if (status < 0)
-		goto out;
-
-	if (resp->status == nlm_granted)
-		goto out;
-
-	if (resp->status != nlm_lck_denied_nolocks)
-		printk("lockd: unexpected unlock status: %d\n", resp->status);
-	/* What to do now? I'm out of my depth... */
-	status = -ENOLCK;
+	return nlm_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
 out:
 	nlm_release_call(req);
-	return status;
+	return 0;
 }
 
 static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)

