Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146Ab1BDVee (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:34 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 14/40] REVERT: pnfs_submit: update nfs4_async_handle_error for data server
Date: Fri,  4 Feb 2011 16:33:36 -0500
Message-Id: <1296855242-2592-15-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-14-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Except for is_ds_only_session declaration
Layout drivers will declare their own handlers for async i/o.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   36 +++++++++++++++---------------------
 1 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index acaaed5..9c50be7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,7 +70,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, struct nfs_client *);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
@@ -1898,7 +1898,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.fmode == 0)
 				break;
 		default:
-			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
+			if (nfs4_async_handle_error(task, server, state) == -EAGAIN)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
@@ -2597,7 +2597,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
-	if (nfs4_async_handle_error(task, res->server, NULL, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, res->dir_attr);
@@ -2622,7 +2622,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
-	if (nfs4_async_handle_error(task, res->server, NULL, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 
 	update_changeattr(old_dir, &res->old_cinfo);
@@ -3088,7 +3088,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, server, data->args.context->state, client) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
@@ -3112,7 +3112,7 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state, NULL) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3141,7 +3141,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL, NULL) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3461,10 +3461,9 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state, struct nfs_client *clp)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
 {
-	if (!clp)
-		clp = server->nfs_client;
+	struct nfs_client *clp = server->nfs_client;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -3488,16 +3487,14 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 		case -NFS4ERR_SEQ_FALSE_RETRY:
 		case -NFS4ERR_SEQ_MISORDERED:
-			dprintk("%s ERROR %d, Reset session. Exchangeid "
-				"flags 0x%x\n", __func__, task->tk_status,
-				clp->cl_exchange_flags);
+			dprintk("%s ERROR %d, Reset session\n", __func__,
+				task->tk_status);
 			nfs4_schedule_state_recovery(clp);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
-			if (server)
-				nfs_inc_server_stats(server, NFSIOS_DELAY);
+			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
@@ -3510,8 +3507,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
 do_state_recovery:
-	if (is_ds_only_client(clp))
-		return 0;
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	nfs4_schedule_state_recovery(clp);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
@@ -3645,8 +3640,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		renew_lease(data->res.server, data->timestamp);
 		break;
 	default:
-		if (nfs4_async_handle_error(task, data->res.server, NULL, NULL)
-				== -EAGAIN) {
+		if (nfs4_async_handle_error(task, data->res.server, NULL) == -EAGAIN) {
 			nfs_restart_rpc(task, data->res.server->nfs_client);
 			return;
 		}
@@ -3900,7 +3894,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server, NULL, NULL) == -EAGAIN)
+			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				nfs_restart_rpc(task,
 						 calldata->server->nfs_client);
 	}
@@ -5372,7 +5366,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 		task->tk_status = -NFS4ERR_DELAY;
 		/* Fall through */
 	default:
-		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
+		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
-- 
1.6.6

