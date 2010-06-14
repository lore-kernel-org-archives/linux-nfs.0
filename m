From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 05/15] NFSv4.1: Merge the nfs41_proc_async_sequence() and nfs4_proc_sequence()
Date: Mon, 14 Jun 2010 17:51:29 -0400
Message-ID: <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34599 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756627Ab0FNVvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:44 -0400
In-Reply-To: <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   68 ++++++++++++++++++++++++++++++++++------------------
 1 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7034188..ae2651e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5048,24 +5048,6 @@ int nfs4_init_session(struct nfs_server *server)
 /*
  * Renew the cl_session lease.
  */
-static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
-{
-	struct nfs4_sequence_args args;
-	struct nfs4_sequence_res res;
-
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEQUENCE],
-		.rpc_argp = &args,
-		.rpc_resp = &res,
-		.rpc_cred = cred,
-	};
-
-	args.sa_cache_this = 0;
-
-	return nfs4_call_sync_sequence(clp, clp->cl_rpcclient, &msg, &args,
-				       &res, args.sa_cache_this, 1);
-}
-
 struct nfs4_sequence_data {
 	struct nfs_client *clp;
 	struct nfs4_sequence_args args;
@@ -5139,28 +5121,66 @@ static const struct rpc_call_ops nfs41_sequence_ops = {
 	.rpc_release = nfs41_sequence_release,
 };
 
-static int nfs41_proc_async_sequence(struct nfs_client *clp,
-				     struct rpc_cred *cred)
+static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	struct nfs4_sequence_data *calldata;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEQUENCE],
 		.rpc_cred = cred,
 	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = clp->cl_rpcclient,
+		.rpc_message = &msg,
+		.callback_ops = &nfs41_sequence_ops,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
+	};
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
-		return -EIO;
+		return ERR_PTR(-EIO);
 	calldata = kmalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL) {
 		nfs_put_client(clp);
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 	}
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
 	calldata->clp = clp;
+	task_setup_data.callback_data = calldata;
 
-	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
-			      &nfs41_sequence_ops, calldata);
+	return rpc_run_task(&task_setup_data);
+}
+
+static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	struct rpc_task *task;
+	int ret = 0;
+
+	task = _nfs41_proc_sequence(clp, cred);
+	if (IS_ERR(task))
+		ret = PTR_ERR(task);
+	else
+		rpc_put_task(task);
+	dprintk("<-- %s status=%d\n", __func__, ret);
+	return ret;
+}
+
+static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+{
+	struct rpc_task *task;
+	int ret;
+
+	task = _nfs41_proc_sequence(clp, cred);
+	if (IS_ERR(task)) {
+		ret = PTR_ERR(task);
+		goto out;
+	}
+	ret = rpc_wait_for_completion_task(task);
+	if (!ret)
+		ret = task->tk_status;
+	rpc_put_task(task);
+out:
+	dprintk("<-- %s status=%d\n", __func__, ret);
+	return ret;
 }
 
 struct nfs4_reclaim_complete_data {
-- 
1.7.0.1

