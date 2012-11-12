Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60018 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666Ab2KLVzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 16:55:47 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFS: Add sequence_priviliged_ops for nfs4_proc_sequence()
Date: Mon, 12 Nov 2012 16:55:38 -0500
Message-Id: <1352757338-14679-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

If I mount an NFS v4.1 server to a single client multiple times and then
run xfstests over each mountpoint I usually get the client into a state
where recovery deadlocks.  The server informs the client of a
cb_path_down sequence error, the client then does a
bind_connection_to_session and checks the status of the lease.

I found that bind_connection_to_session sets the NFS4_SESSION_DRAINING
flag on the client, but this flag is never unset before
nfs4_check_lease() reaches nfs4_proc_sequence().  This causes the client
to deadlock, halting all NFS activity to the server.  nfs4_proc_sequence()
is only called by the state manager, so I can change it to run in privileged
mode to bypass the NFS4_SESSION_DRAINING check and avoid the deadlock.

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

