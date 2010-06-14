From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 01/15] NFSv41: Fix a memory leak in nfs41_proc_async_sequence()
Date: Mon, 14 Jun 2010 17:51:25 -0400
Message-ID: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756453Ab0FNVvm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the call to rpc_call_async() fails, then the arguments will not be
freed, since there will be no call to nfs41_sequence_call_done

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   38 ++++++++++++++++++++------------------
 1 files changed, 20 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 70015dd..bb70ff7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5078,18 +5078,27 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 				       &res, args.sa_cache_this, 1);
 }
 
+struct nfs4_sequence_data {
+	struct nfs_client *clp;
+	struct nfs4_sequence_args args;
+	struct nfs4_sequence_res res;
+};
+
 static void nfs41_sequence_release(void *data)
 {
-	struct nfs_client *clp = (struct nfs_client *)data;
+	struct nfs4_sequence_data *calldata = data;
+	struct nfs_client *clp = calldata->clp;
 
 	if (atomic_read(&clp->cl_count) > 1)
 		nfs4_schedule_state_renewal(clp);
 	nfs_put_client(clp);
+	kfree(calldata);
 }
 
 static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
-	struct nfs_client *clp = (struct nfs_client *)data;
+	struct nfs4_sequence_data *calldata = data;
+	struct nfs_client *clp = calldata->clp;
 
 	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
 
@@ -5106,19 +5115,16 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 	}
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 out:
-	kfree(task->tk_msg.rpc_argp);
-	kfree(task->tk_msg.rpc_resp);
-
 	dprintk("<-- %s\n", __func__);
 }
 
 static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 {
-	struct nfs_client *clp;
+	struct nfs4_sequence_data *calldata = data;
+	struct nfs_client *clp = calldata->clp;
 	struct nfs4_sequence_args *args;
 	struct nfs4_sequence_res *res;
 
-	clp = (struct nfs_client *)data;
 	args = task->tk_msg.rpc_argp;
 	res = task->tk_msg.rpc_resp;
 
@@ -5136,8 +5142,7 @@ static const struct rpc_call_ops nfs41_sequence_ops = {
 static int nfs41_proc_async_sequence(struct nfs_client *clp,
 				     struct rpc_cred *cred)
 {
-	struct nfs4_sequence_args *args;
-	struct nfs4_sequence_res *res;
+	struct nfs4_sequence_data *calldata;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SEQUENCE],
 		.rpc_cred = cred,
@@ -5145,20 +5150,17 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
 		return -EIO;
-	args = kzalloc(sizeof(*args), GFP_NOFS);
-	res = kzalloc(sizeof(*res), GFP_NOFS);
-	if (!args || !res) {
-		kfree(args);
-		kfree(res);
+	calldata = kmalloc(sizeof(*calldata), GFP_NOFS);
+	if (calldata == NULL) {
 		nfs_put_client(clp);
 		return -ENOMEM;
 	}
-	res->sr_slotid = NFS4_MAX_SLOT_TABLE;
-	msg.rpc_argp = args;
-	msg.rpc_resp = res;
+	msg.rpc_argp = &calldata->args;
+	msg.rpc_resp = &calldata->res;
+	calldata->clp = clp;
 
 	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
-			      &nfs41_sequence_ops, (void *)clp);
+			      &nfs41_sequence_ops, calldata);
 }
 
 struct nfs4_reclaim_complete_data {
-- 
1.7.0.1

