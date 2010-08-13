Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52094 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754277Ab0HMVcb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:31 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 30/50] pnfs_submit: update nfs4_async_handle_error for data server
Date: Fri, 13 Aug 2010 17:31:42 -0400
Message-Id: <1281735122-1496-31-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-30-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c         |   39 ++++++++++++++++++++++-----------------
 include/linux/nfs4.h      |    7 +++++++
 include/linux/nfs_fs_sb.h |   10 ++++++++++
 3 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e8b1620..353c2fb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,7 +70,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, struct nfs_client *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
@@ -1896,7 +1896,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.fmode == 0)
 				break;
 		default:
-			if (nfs4_async_handle_error(task, server, state) == -EAGAIN)
+			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
@@ -2688,7 +2688,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
-	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, res->dir_attr);
@@ -3135,7 +3135,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, server, data->args.context->state, NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, server->nfs_client);
 		return -EAGAIN;
 	}
@@ -3159,7 +3159,7 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state, NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3188,7 +3188,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (!nfs4_sequence_done(task, &data->res.seq_res))
 		return -EAGAIN;
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL, NULL) == -EAGAIN) {
 		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3505,9 +3505,10 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state, struct nfs_client *clp)
 {
-	struct nfs_client *clp = server->nfs_client;
+	if (!clp)
+		clp = server->nfs_client;
 
 	if (task->tk_status >= 0)
 		return 0;
@@ -3534,14 +3535,16 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 		case -NFS4ERR_SEQ_FALSE_RETRY:
 		case -NFS4ERR_SEQ_MISORDERED:
-			dprintk("%s ERROR %d, Reset session\n", __func__,
-				task->tk_status);
+			dprintk("%s ERROR %d, Reset session. Exchangeid "
+				"flags 0x%x\n", __func__, task->tk_status,
+				clp->cl_exchange_flags);
 			nfs4_schedule_state_recovery(clp);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
-			nfs_inc_server_stats(server, NFSIOS_DELAY);
+			if (server)
+				nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
@@ -3554,6 +3557,8 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
 do_state_recovery:
+	if (is_ds_only_client(clp))
+		return 0;
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	nfs4_schedule_state_recovery(clp);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
@@ -3687,8 +3692,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		renew_lease(data->res.server, data->timestamp);
 		break;
 	default:
-		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
-				-EAGAIN) {
+		if (nfs4_async_handle_error(task, data->res.server, NULL, NULL)
+				== -EAGAIN) {
 			nfs_restart_rpc(task, data->res.server->nfs_client);
 			return;
 		}
@@ -3946,7 +3951,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
+			if (nfs4_async_handle_error(task, calldata->server, NULL, NULL) == -EAGAIN)
 				nfs_restart_rpc(task,
 						 calldata->server->nfs_client);
 	}
@@ -5399,7 +5404,7 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
 
 	pnfs_get_layout_done(lgp, task->tk_status);
 
-	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
 	lgp->status = task->tk_status;
@@ -5508,7 +5513,7 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
 	if (RPC_ASSASSINATED(task))
 		return;
 
-	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
 	data->status = task->tk_status;
@@ -5618,7 +5623,7 @@ static void nfs4_pnfs_layoutreturn_done(struct rpc_task *task, void *calldata)
 	if (RPC_ASSASSINATED(task))
 		return;
 
-	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
 	dprintk("<-- %s\n", __func__);
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 004a867..2737013 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -121,6 +121,13 @@
 #define EXCHGID4_FLAG_MASK_A			0x40070003
 #define EXCHGID4_FLAG_MASK_R			0x80070003
 
+static inline bool
+is_ds_only_session(u32 exchange_flags)
+{
+	u32 mask = EXCHGID4_FLAG_USE_PNFS_DS | EXCHGID4_FLAG_USE_PNFS_MDS;
+	return (exchange_flags & mask) == EXCHGID4_FLAG_USE_PNFS_DS;
+}
+
 #define SEQ4_STATUS_CB_PATH_DOWN		0x00000001
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRING	0x00000002
 #define SEQ4_STATUS_CB_GSS_CONTEXTS_EXPIRED	0x00000004
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8d17e67..c17440b 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -91,6 +91,16 @@ struct nfs_client {
 #endif
 };
 
+static inline bool
+is_ds_only_client(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	return is_ds_only_session(clp->cl_exchange_flags);
+#else
+	return false;
+#endif
+}
+
 /*
  * NFS client parameters stored in the superblock.
  */
-- 
1.6.2.5

