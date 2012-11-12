Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751932Ab2KLSf7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 13:35:59 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Don't set RPC_TASK_ASYNC for nfs4_proc_sequence()
Date: Mon, 12 Nov 2012 13:35:55 -0500
Message-Id: <1352745355-31157-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
References: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This should simplify the code a bit since the rpc layer will handle the
task properly, allowing us to remove the rpc_wait_for_completion_task()
call.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 537181c..a2efcae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6157,7 +6157,7 @@ static const struct rpc_call_ops nfs41_sequence_privileged_ops = {
 };
 
 static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred,
-					     const struct rpc_call_ops *seq_ops)
+					     const struct rpc_call_ops *seq_ops, int flags)
 {
 	struct nfs4_sequence_data *calldata;
 	struct rpc_message msg = {
@@ -6168,7 +6168,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
 		.callback_ops = seq_ops,
-		.flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
+		.flags = RPC_TASK_SOFT | flags,
 	};
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
@@ -6194,7 +6194,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
 
 	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
 		return 0;
-	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_ops);
+	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_ops, RPC_TASK_ASYNC);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
 	else
@@ -6208,19 +6208,16 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 	struct rpc_task *task;
 	int ret;
 
-	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_privileged_ops);
+	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_privileged_ops, 0);
 	if (IS_ERR(task)) {
 		ret = PTR_ERR(task);
 		goto out;
 	}
-	ret = rpc_wait_for_completion_task(task);
-	if (!ret) {
+	if (task->tk_status == 0) {
 		struct nfs4_sequence_res *res = task->tk_msg.rpc_resp;
-
-		if (task->tk_status == 0)
-			nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
-		ret = task->tk_status;
+		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
 	}
+	ret = task->tk_status;
 	rpc_put_task(task);
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
-- 
1.8.0

