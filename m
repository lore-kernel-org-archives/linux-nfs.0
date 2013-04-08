Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:45756 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935997Ab3DHV7a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Apr 2013 17:59:30 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Handle timeouts correctly when probing for lease validity
Date: Mon,  8 Apr 2013 17:59:27 -0400
Message-Id: <1365458367-40376-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we send a RENEW or SEQUENCE operation in order to probe if the
lease is still valid, we want it to be able to time out since the
lease we are probing is likely to time out too. Currently, because
we use soft mount semantics for these RPC calls, the return value
is EIO, which causes the state manager to exit with an "unhandled
error" message.
This patch changes the call semantics, so that the RPC layer returns
ETIMEDOUT instead of EIO. We then have the state manager default to
a simple retry instead of exiting.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 6 +++---
 fs/nfs/nfs4state.c | 4 ++++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8652345..c50f153 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3797,7 +3797,7 @@ static int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred,
 		return -ENOMEM;
 	data->client = clp;
 	data->timestamp = jiffies;
-	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
+	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT,
 			&nfs4_renew_ops, data);
 }
 
@@ -3811,7 +3811,7 @@ static int nfs4_proc_renew(struct nfs_client *clp, struct rpc_cred *cred)
 	unsigned long now = jiffies;
 	int status;
 
-	status = rpc_call_sync(clp->cl_rpcclient, &msg, 0);
+	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
 	if (status < 0)
 		return status;
 	do_renew_lease(clp, now);
@@ -5959,7 +5959,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		.rpc_client = clp->cl_rpcclient,
 		.rpc_message = &msg,
 		.callback_ops = &nfs41_sequence_ops,
-		.flags = RPC_TASK_ASYNC | RPC_TASK_SOFT,
+		.flags = RPC_TASK_ASYNC | RPC_TASK_TIMEOUT,
 	};
 
 	if (!atomic_inc_not_zero(&clp->cl_count))
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 81c809d..34e9434 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1739,6 +1739,10 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	}
 	status = ops->renew_lease(clp, cred);
 	put_rpccred(cred);
+	if (status == -ETIMEDOUT) {
+		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
+		return 0;
+	}
 out:
 	return nfs4_recovery_handle_error(clp, status);
 }
-- 
1.8.1.4

