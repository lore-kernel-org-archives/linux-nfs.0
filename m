From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/15] NFSv4: Kill nfs4_async_handle_error() abuses by NFSv4.1
Date: Mon, 14 Jun 2010 17:51:28 -0400
Message-ID: <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756611Ab0FNVvn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:43 -0400
In-Reply-To: <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |   78 ++++++++++++++++++++++++++++-------------------------
 1 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 67b2359..7034188 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3457,9 +3457,11 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-_nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs_client *clp, struct nfs4_state *state)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
 {
-	if (!clp || task->tk_status >= 0)
+	struct nfs_client *clp = server->nfs_client;
+
+	if (task->tk_status >= 0)
 		return 0;
 	switch(task->tk_status) {
 		case -NFS4ERR_ADMIN_REVOKED:
@@ -3491,8 +3493,7 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
-			if (server)
-				nfs_inc_server_stats(server, NFSIOS_DELAY);
+			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
@@ -3513,12 +3514,6 @@ do_state_recovery:
 	return -EAGAIN;
 }
 
-static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
-{
-	return _nfs4_async_handle_error(task, server, server->nfs_client, state);
-}
-
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		unsigned short port, struct rpc_cred *cred,
 		struct nfs4_setclientid_res *res)
@@ -5088,6 +5083,19 @@ static void nfs41_sequence_release(void *data)
 	kfree(calldata);
 }
 
+static int nfs41_sequence_handle_errors(struct rpc_task *task, struct nfs_client *clp)
+{
+	switch(task->tk_status) {
+	case -NFS4ERR_DELAY:
+	case -EKEYEXPIRED:
+		rpc_delay(task, NFS4_POLL_RETRY_MAX);
+		return -EAGAIN;
+	default:
+		nfs4_schedule_state_recovery(clp);
+	}
+	return 0;
+}
+
 static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_sequence_data *calldata = data;
@@ -5100,9 +5108,8 @@ static void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 		if (atomic_read(&clp->cl_count) == 1)
 			goto out;
 
-		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
-								== -EAGAIN) {
-			nfs_restart_rpc(task, clp);
+		if (nfs41_sequence_handle_errors(task, clp) == -EAGAIN) {
+			rpc_restart_call_prepare(task);
 			return;
 		}
 	}
@@ -5174,6 +5181,23 @@ static void nfs4_reclaim_complete_prepare(struct rpc_task *task, void *data)
 	rpc_call_start(task);
 }
 
+static int nfs41_reclaim_complete_handle_errors(struct rpc_task *task, struct nfs_client *clp)
+{
+	switch(task->tk_status) {
+	case 0:
+	case -NFS4ERR_COMPLETE_ALREADY:
+	case -NFS4ERR_WRONG_CRED: /* What to do here? */
+		break;
+	case -NFS4ERR_DELAY:
+	case -EKEYEXPIRED:
+		rpc_delay(task, NFS4_POLL_RETRY_MAX);
+		return -EAGAIN;
+	default:
+		nfs4_schedule_state_recovery(clp);
+	}
+	return 0;
+}
+
 static void nfs4_reclaim_complete_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_reclaim_complete_data *calldata = data;
@@ -5182,31 +5206,11 @@ static void nfs4_reclaim_complete_done(struct rpc_task *task, void *data)
 
 	dprintk("--> %s\n", __func__);
 	nfs41_sequence_done(res);
-	switch (task->tk_status) {
-	case 0:
-	case -NFS4ERR_COMPLETE_ALREADY:
-		break;
-	case -NFS4ERR_BADSESSION:
-	case -NFS4ERR_DEADSESSION:
-		/*
-		 * Handle the session error, but do not retry the operation, as
-		 * we have no way of telling whether the clientid had to be
-		 * reset before we got our reply.  If reset, a new wave of
-		 * reclaim operations will follow, containing their own reclaim
-		 * complete.  We don't want our retry to get on the way of
-		 * recovery by incorrectly indicating to the server that we're
-		 * done reclaiming state since the process had to be restarted.
-		 */
-		_nfs4_async_handle_error(task, NULL, clp, NULL);
-		break;
-	default:
-		if (_nfs4_async_handle_error(
-				task, NULL, clp, NULL) == -EAGAIN) {
-			rpc_restart_call_prepare(task);
-			return;
-		}
-	}
 
+	if (nfs41_reclaim_complete_handle_errors(task, clp) == -EAGAIN) {
+		rpc_restart_call_prepare(task);
+		return;
+	}
 	dprintk("<-- %s\n", __func__);
 }
 
-- 
1.7.0.1

