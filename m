Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35063 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447Ab2KLSf6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 13:35:58 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()
Date: Mon, 12 Nov 2012 13:35:54 -0500
Message-Id: <1352745355-31157-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

During recovery the NFS4_SESSION_DRAINING flag might be set on the
client structure.  This can cause lease renewal to abort when
nfs41_setup_sequence sees that we are doing recovery.  As a result, the
client never recovers and all activity with the NFS server halts.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4proc.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5eec442..537181c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6138,13 +6138,26 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	rpc_call_start(task);
 }
 
+static void nfs41_sequence_prepare_privileged(struct rpc_task *task, void *data)
+{
+	rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
+	nfs41_sequence_prepare(task, data);
+}
+
 static const struct rpc_call_ops nfs41_sequence_ops = {
 	.rpc_call_done = nfs41_sequence_call_done,
 	.rpc_call_prepare = nfs41_sequence_prepare,
 	.rpc_release = nfs41_sequence_release,
 };
 
-static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
+static const struct rpc_call_ops nfs41_sequence_privileged_ops = {
+	.rpc_call_done = nfs41_sequence_call_done,
+	.rpc_call_prepare = nfs41_sequence_prepare_privileged,
+	.rpc_release = nfs41_sequence_release,
+};
+
+static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred,
+					     const struct rpc_call_ops *seq_ops)
 {
 	struct nfs4_sequence_data *calldata;
 	struct rpc_message msg = {
@@ -6154,7 +6167,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
-		.callback_ops = &nfs41_sequence_ops,
+		.callback_ops = seq_ops,
 		.flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
 	};
 
@@ -6181,7 +6194,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
 
 	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
 		return 0;
-	task = _nfs41_proc_sequence(clp, cred);
+	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_ops);
 	if (IS_ERR(task))
 		ret = PTR_ERR(task);
 	else
@@ -6195,7 +6208,7 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 	struct rpc_task *task;
 	int ret;
 
-	task = _nfs41_proc_sequence(clp, cred);
+	task = _nfs41_proc_sequence(clp, cred, &nfs41_sequence_privileged_ops);
 	if (IS_ERR(task)) {
 		ret = PTR_ERR(task);
 		goto out;
-- 
1.8.0

