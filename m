From: andros@netapp.com
Subject: [PATCH 1/2] nfs41: fix multiple free slot calls
Date: Wed, 21 Oct 2009 14:24:51 -0400
Message-ID: <1256149492-25481-2-git-send-email-andros@netapp.com>
References: <1256149492-25481-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6584 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754343AbZJUSYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2009 14:24:49 -0400
In-Reply-To: <1256149492-25481-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>

nfs41_sequence_free_slot is called multiple times on SEQUENCE operation errors.

Fix this by moving the call to nfs41_sequence_free_slot from the error path of
nfs41_sequence_done to nfs4_async_handle_error for the SEQUENCE operation
error cases.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |   63 ++++++++++++++++++++++++++++++----------------------
 1 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c321002..eb245a1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -65,7 +65,8 @@
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *,
+			 struct nfs4_state *, struct nfs4_sequence_res *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
@@ -370,11 +371,12 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 
 	/* -ERESTARTSYS can result in skipping nfs41_sequence_setup */
 	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE)
-		goto out;
+		return;
 
 	tbl = &clp->cl_session->fc_slot_table;
 	slot = tbl->slots + res->sr_slotid;
 
+	/* Check the SEQUENCE operation status */
 	if (res->sr_status == 0) {
 		/* Update the slot's sequence and clientid lease timer */
 		++slot->seq_nr;
@@ -386,15 +388,6 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 		return;
 	}
 
-	/* Do not free slot if retried while operation was in progress */
-	if (res->sr_status == -NFS4ERR_DELAY) {
-		dprintk("%s: Operation in progress\n", __func__);
-		return;
-	}
-out:
-	/* The session may be reset by one of the error handlers. */
-	dprintk("%s: Error %d free the slot \n", __func__, res->sr_status);
-	nfs41_sequence_free_slot(clp, res);
 }
 
 /*
@@ -1743,7 +1736,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.fmode == 0)
 				break;
 		default:
-			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
+			if (nfs4_async_handle_error(task, server, state,
+					&calldata->res.seq_res) == -EAGAIN) {
 				nfs4_restart_rpc(task, server->nfs_client);
 				return;
 			}
@@ -2537,7 +2531,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
 	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
-	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL,
+						&res->seq_res) == -EAGAIN)
 		return 0;
 	nfs4_sequence_free_slot(res->server->nfs_client, &res->seq_res);
 	update_changeattr(dir, &res->cinfo);
@@ -2981,7 +2976,8 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	/* nfs4_sequence_free_slot called in the read rpc_call_done */
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
-	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, server, data->args.context->state,
+					&data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, server->nfs_client);
 		return -EAGAIN;
 	}
@@ -3002,11 +2998,14 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 	/* slot is freed in nfs_writeback_done */
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
+				    data->args.context->state,
+				    &data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3032,9 +3031,12 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
+	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
+
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL,
+					&data->res.seq_res) == -EAGAIN) {
 		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
@@ -3330,7 +3332,9 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-_nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs_client *clp, struct nfs4_state *state)
+_nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
+			 struct nfs_client *clp, struct nfs4_state *state,
+			 struct nfs4_sequence_res *res)
 {
 	if (!clp || task->tk_status >= 0)
 		return 0;
@@ -3361,6 +3365,8 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
 			set_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state);
+			/* Free the slot so session can drain */
+			nfs41_sequence_free_slot(clp, res);
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
@@ -3380,9 +3386,11 @@ _nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
+			struct nfs4_state *state, struct nfs4_sequence_res *res)
 {
-	return _nfs4_async_handle_error(task, server, server->nfs_client, state);
+	return _nfs4_async_handle_error(task, server, server->nfs_client,
+					state, res);
 }
 
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short port, struct rpc_cred *cred)
@@ -3732,9 +3740,9 @@ static void nfs4_locku_release_calldata(void *data)
 static void nfs4_locku_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
+	struct nfs4_sequence_res *res = &calldata->res.seq_res;
 
-	nfs4_sequence_done(calldata->server, &calldata->res.seq_res,
-			   task->tk_status);
+	nfs4_sequence_done(calldata->server, res, task->tk_status);
 	if (RPC_ASSASSINATED(task))
 		return;
 	switch (task->tk_status) {
@@ -3750,12 +3758,12 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
+			if (nfs4_async_handle_error(task, calldata->server,
+						    NULL, res) == -EAGAIN)
 				nfs4_restart_rpc(task,
 						calldata->server->nfs_client);
 	}
-	nfs4_sequence_free_slot(calldata->server->nfs_client,
-				&calldata->res.seq_res);
+	nfs4_sequence_free_slot(calldata->server->nfs_client, res);
 }
 
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
@@ -4875,19 +4883,20 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 {
 	struct nfs_client *clp = (struct nfs_client *)data;
+	struct nfs4_sequence_res *res = task->tk_msg.rpc_resp;
 
-	nfs41_sequence_done(clp, task->tk_msg.rpc_resp, task->tk_status);
+	nfs41_sequence_done(clp, res, task->tk_status);
 
 	if (task->tk_status < 0) {
 		dprintk("%s ERROR %d\n", __func__, task->tk_status);
 
-		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
+		if (_nfs4_async_handle_error(task, NULL, clp, NULL, res)
 								== -EAGAIN) {
 			nfs4_restart_rpc(task, clp);
 			return;
 		}
 	}
-	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
+	nfs41_sequence_free_slot(clp, res);
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
 	put_rpccred(task->tk_msg.rpc_cred);
-- 
1.6.2.5

