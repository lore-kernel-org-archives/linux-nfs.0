Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:32878 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751375AbdEDTl0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 15:41:26 -0400
Received: by mail-io0-f195.google.com with SMTP id l196so6023589ioe.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 May 2017 12:41:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: RECLAIM_COMPLETE must handle NFS4ERR_CONN_NOT_BOUND_TO_SESSION
Date: Thu,  4 May 2017 15:41:21 -0400
Message-Id: <20170504194121.9932-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server returns NFS4ERR_CONN_NOT_BOUND_TO_SESSION because we
are trunking, then RECLAIM_COMPLETE must handle that by calling
nfs4_schedule_session_recovery() and then retrying.

Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4proc.c  |  7 ++++++-
 fs/nfs/nfs4state.c | 10 +++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 158c3d52146f..62fc8eed53cc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8153,6 +8153,12 @@ static int nfs41_reclaim_complete_handle_errors(struct rpc_task *task, struct nf
 		/* fall through */
 	case -NFS4ERR_RETRY_UNCACHED_REP:
 		return -EAGAIN;
+	case -NFS4ERR_BADSESSION:
+	case -NFS4ERR_DEADSESSION:
+	case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
+		nfs4_schedule_session_recovery(clp->cl_session,
+				task->tk_status);
+		break;
 	default:
 		nfs4_schedule_lease_recovery(clp);
 	}
@@ -8231,7 +8237,6 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 	if (status == 0)
 		status = task->tk_status;
 	rpc_put_task(task);
-	return 0;
 out:
 	dprintk("<-- %s status=%d\n", __func__, status);
 	return status;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 8156bad6b441..b34de036501b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1649,13 +1649,14 @@ static void nfs4_state_start_reclaim_reboot(struct nfs_client *clp)
 	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_reboot);
 }
 
-static void nfs4_reclaim_complete(struct nfs_client *clp,
+static int nfs4_reclaim_complete(struct nfs_client *clp,
 				 const struct nfs4_state_recovery_ops *ops,
 				 struct rpc_cred *cred)
 {
 	/* Notify the server we're done reclaiming our state */
 	if (ops->reclaim_complete)
-		(void)ops->reclaim_complete(clp, cred);
+		return ops->reclaim_complete(clp, cred);
+	return 0;
 }
 
 static void nfs4_clear_reclaim_server(struct nfs_server *server)
@@ -1702,13 +1703,16 @@ static void nfs4_state_end_reclaim_reboot(struct nfs_client *clp)
 {
 	const struct nfs4_state_recovery_ops *ops;
 	struct rpc_cred *cred;
+	int err;
 
 	if (!nfs4_state_clear_reclaim_reboot(clp))
 		return;
 	ops = clp->cl_mvops->reboot_recovery_ops;
 	cred = nfs4_get_clid_cred(clp);
-	nfs4_reclaim_complete(clp, ops, cred);
+	err = nfs4_reclaim_complete(clp, ops, cred);
 	put_rpccred(cred);
+	if (err == -NFS4ERR_CONN_NOT_BOUND_TO_SESSION)
+		set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
 }
 
 static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
-- 
2.9.3

