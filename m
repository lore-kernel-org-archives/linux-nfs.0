From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 14/15] SUNRPC: Remove the BKL from the callback functions
Date: Thu, 12 Jun 2008 15:28:18 -0400
Message-ID: <20080612192817.24916.94236.stgit@localhost.localdomain>
References: <20080612192817.24916.52065.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11707 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522AbYFLTt1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:49:27 -0400
Received: from sacexrs01.hq.netapp.com (sacexrs01.hq.netapp.com [10.99.190.105])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m5CJnOln008577
	for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 12:49:25 -0700 (PDT)
In-Reply-To: <20080612192817.24916.52065.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Push it into those callback functions that actually need it.

Note that all the NFS operations use their own locking, so don't need the
BKL. Ditto for the rpcbind client.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |    6 ++++++
 fs/lockd/svc4proc.c |    2 ++
 fs/lockd/svclock.c  |    7 ++++++-
 fs/lockd/svcproc.c  |    2 ++
 net/sunrpc/sched.c  |    9 +--------
 5 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 5df517b..271eda2 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -224,7 +224,9 @@ void nlm_release_call(struct nlm_rqst *call)
 
 static void nlmclnt_rpc_release(void *data)
 {
+	lock_kernel();
 	nlm_release_call(data);
+	unlock_kernel();
 }
 
 static int nlm_wait_on_grace(wait_queue_head_t *queue)
@@ -710,7 +712,9 @@ static void nlmclnt_unlock_callback(struct rpc_task *task, void *data)
 die:
 	return;
  retry_rebind:
+	lock_kernel();
 	nlm_rebind_host(req->a_host);
+	unlock_kernel();
  retry_unlock:
 	rpc_restart_call(task);
 }
@@ -788,7 +792,9 @@ retry_cancel:
 	/* Don't ever retry more than 3 times */
 	if (req->a_retries++ >= NLMCLNT_MAX_RETRIES)
 		goto die;
+	lock_kernel();
 	nlm_rebind_host(req->a_host);
+	unlock_kernel();
 	rpc_restart_call(task);
 	rpc_delay(task, 30 * HZ);
 }
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 385437e..2e27176 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -248,7 +248,9 @@ static void nlm4svc_callback_exit(struct rpc_task *task, void *data)
 
 static void nlm4svc_callback_release(void *data)
 {
+	lock_kernel();
 	nlm_release_call(data);
+	unlock_kernel();
 }
 
 static const struct rpc_call_ops nlm4svc_callback_ops = {
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 81aca85..56a08ab 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -795,6 +795,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 
 	dprintk("lockd: GRANT_MSG RPC callback\n");
 
+	lock_kernel();
 	/* if the block is not on a list at this point then it has
 	 * been invalidated. Don't try to requeue it.
 	 *
@@ -804,7 +805,7 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 	 * for nlm_blocked?
 	 */
 	if (list_empty(&block->b_list))
-		return;
+		goto out;
 
 	/* Technically, we should down the file semaphore here. Since we
 	 * move the block towards the head of the queue only, no harm
@@ -818,13 +819,17 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
 	}
 	nlmsvc_insert_block(block, timeout);
 	svc_wake_up(block->b_daemon);
+out:
+	unlock_kernel();
 }
 
 static void nlmsvc_grant_release(void *data)
 {
 	struct nlm_rqst		*call = data;
 
+	lock_kernel();
 	nlmsvc_release_block(call->a_block);
+	unlock_kernel();
 }
 
 static const struct rpc_call_ops nlmsvc_grant_ops = {
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 88379cc..ce6952b 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -278,7 +278,9 @@ static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
 
 static void nlmsvc_callback_release(void *data)
 {
+	lock_kernel();
 	nlm_release_call(data);
+	unlock_kernel();
 }
 
 static const struct rpc_call_ops nlmsvc_callback_ops = {
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 6288af0..385f427 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -576,9 +576,7 @@ EXPORT_SYMBOL_GPL(rpc_delay);
  */
 static void rpc_prepare_task(struct rpc_task *task)
 {
-	lock_kernel();
 	task->tk_ops->rpc_call_prepare(task, task->tk_calldata);
-	unlock_kernel();
 }
 
 /*
@@ -588,9 +586,7 @@ void rpc_exit_task(struct rpc_task *task)
 {
 	task->tk_action = NULL;
 	if (task->tk_ops->rpc_call_done != NULL) {
-		lock_kernel();
 		task->tk_ops->rpc_call_done(task, task->tk_calldata);
-		unlock_kernel();
 		if (task->tk_action != NULL) {
 			WARN_ON(RPC_ASSASSINATED(task));
 			/* Always release the RPC slot and buffer memory */
@@ -602,11 +598,8 @@ EXPORT_SYMBOL_GPL(rpc_exit_task);
 
 void rpc_release_calldata(const struct rpc_call_ops *ops, void *calldata)
 {
-	if (ops->rpc_release != NULL) {
-		lock_kernel();
+	if (ops->rpc_release != NULL)
 		ops->rpc_release(calldata);
-		unlock_kernel();
-	}
 }
 
 /*

