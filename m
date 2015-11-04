Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:36165 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbbKDT50 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Nov 2015 14:57:26 -0500
Received: by qkcl124 with SMTP id l124so24422710qkc.3
        for <linux-nfs@vger.kernel.org>; Wed, 04 Nov 2015 11:57:25 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs4: use sliding delay in async calls that get NFS4ERR_DELAY
Date: Wed,  4 Nov 2015 14:57:17 -0500
Message-Id: <1446667037-28753-1-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1446583411-9901-1-git-send-email-jeff.layton@primarydata.com>
References: <1446583411-9901-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Most of the async calls in the client pass in a NULL instead of a
pointer to a timeout value. This causes them to wait a full 15s
before retrying the call again.

In some cases (e.g. RELEASE_LOCKOWNER), that delay is harmless (though
15s is a _really_ long time). For something like a LAYOUTGET or LOCKU
though, we really don't want to wait that long before trying again.

The machinery to handle an exponential backoff is already present in
most of this code. We just need to add a timeout value to the RPC
calldata so that it can keep track of it.

Add that to all of the calls that use nfs4_async_handle_error, so they
don't wait quite so long before retrying in this situation.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4proc.c       | 34 +++++++++++++++++++++-------------
 include/linux/nfs_xdr.h |  5 +++++
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5133bb18830e..a71e84f354ae 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2685,6 +2685,7 @@ struct nfs4_closedata {
 	struct nfs_closeres res;
 	struct nfs_fattr fattr;
 	unsigned long timestamp;
+	long timeout;
 	bool roc;
 	u32 roc_barrier;
 };
@@ -2739,7 +2740,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.fmode == 0)
 				break;
 		default:
-			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN) {
+			if (nfs4_async_handle_error(task, server, state,
+					&calldata->timeout) == -EAGAIN) {
 				rpc_restart_call_prepare(task);
 				goto out_release;
 			}
@@ -2884,7 +2886,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->arg.seqid = alloc_seqid(&state->owner->so_seqid, gfp_mask);
 	if (IS_ERR(calldata->arg.seqid))
 		goto out_free_calldata;
-	calldata->arg.fmode = 0;
 	calldata->arg.bitmask = server->cache_consistency_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
@@ -4250,7 +4251,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_pgio_header *hdr)
 	trace_nfs4_read(hdr, task->tk_status);
 	if (nfs4_async_handle_error(task, server,
 				    hdr->args.context->state,
-				    NULL) == -EAGAIN) {
+				    &hdr->timeout) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -4322,7 +4323,7 @@ static int nfs4_write_done_cb(struct rpc_task *task,
 	trace_nfs4_write(hdr, task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
 				    hdr->args.context->state,
-				    NULL) == -EAGAIN) {
+				    &hdr->timeout) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -4403,7 +4404,7 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *da
 
 	trace_nfs4_commit(data, task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
-				    NULL, NULL) == -EAGAIN) {
+				    NULL, &data->timeout) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -5289,6 +5290,7 @@ struct nfs4_delegreturndata {
 	struct nfs_fh fh;
 	nfs4_stateid stateid;
 	unsigned long timestamp;
+	long timeout;
 	struct nfs_fattr fattr;
 	int rpc_status;
 	struct inode *inode;
@@ -5319,7 +5321,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		break;
 	default:
 		if (nfs4_async_handle_error(task, data->res.server,
-					    NULL, NULL) == -EAGAIN) {
+					    NULL, &data->timeout) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -5394,7 +5396,6 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->res.server = server;
 	nfs_fattr_init(data->res.fattr);
 	data->timestamp = jiffies;
-	data->rpc_status = 0;
 	data->inode = nfs_igrab_and_active(inode);
 	if (data->inode)
 		data->roc = nfs4_roc(inode);
@@ -5535,6 +5536,7 @@ struct nfs4_unlockdata {
 	struct file_lock fl;
 	const struct nfs_server *server;
 	unsigned long timestamp;
+	long timeout;
 };
 
 static struct nfs4_unlockdata *nfs4_alloc_unlockdata(struct file_lock *fl,
@@ -5593,7 +5595,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			break;
 		default:
 			if (nfs4_async_handle_error(task, calldata->server,
-						    NULL, NULL) == -EAGAIN)
+						    NULL, &calldata->timeout) == -EAGAIN)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
@@ -6184,6 +6186,7 @@ struct nfs_release_lockowner_data {
 	struct nfs_release_lockowner_args args;
 	struct nfs_release_lockowner_res res;
 	unsigned long timestamp;
+	long timeout;
 };
 
 static void nfs4_release_lockowner_prepare(struct rpc_task *task, void *calldata)
@@ -6214,7 +6217,7 @@ static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
 	case -NFS4ERR_LEASE_MOVED:
 	case -NFS4ERR_DELAY:
 		if (nfs4_async_handle_error(task, server,
-					    NULL, NULL) == -EAGAIN)
+					    NULL, &data->timeout) == -EAGAIN)
 			rpc_restart_call_prepare(task);
 	}
 }
@@ -6251,6 +6254,7 @@ nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
 	data->args.lock_owner.clientid = server->nfs_client->cl_clientid;
 	data->args.lock_owner.id = lsp->ls_seqid.owner_id;
 	data->args.lock_owner.s_dev = server->s_dev;
+	data->timeout = 0;
 
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
@@ -7872,7 +7876,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			spin_unlock(&inode->i_lock);
 		goto out_restart;
 	}
-	if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
 		goto out_restart;
 out:
 	dprintk("<-- %s\n", __func__);
@@ -8040,7 +8044,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	case 0:
 		break;
 	case -NFS4ERR_DELAY:
-		if (nfs4_async_handle_error(task, server, NULL, NULL) != -EAGAIN)
+		if (nfs4_async_handle_error(task, server, NULL, &lrp->timeout) != -EAGAIN)
 			break;
 		rpc_restart_call_prepare(task);
 		return;
@@ -8192,7 +8196,8 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	case 0:
 		break;
 	default:
-		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
+		if (nfs4_async_handle_error(task, server, NULL,
+					&data->timeout) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -8469,6 +8474,7 @@ static int nfs41_test_stateid(struct nfs_server *server,
 
 struct nfs_free_stateid_data {
 	struct nfs_server *server;
+	long timeout;
 	struct nfs41_free_stateid_args args;
 	struct nfs41_free_stateid_res res;
 };
@@ -8490,7 +8496,8 @@ static void nfs41_free_stateid_done(struct rpc_task *task, void *calldata)
 
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
-		if (nfs4_async_handle_error(task, data->server, NULL, NULL) == -EAGAIN)
+		if (nfs4_async_handle_error(task, data->server, NULL,
+						&data->timeout) == -EAGAIN)
 			rpc_restart_call_prepare(task);
 	}
 }
@@ -8531,6 +8538,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	if (!data)
 		return ERR_PTR(-ENOMEM);
 	data->server = server;
+	data->timeout = 0;
 	nfs4_stateid_copy(&data->args.stateid, stateid);
 
 	task_setup.callback_data = data;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 52faf7e96c65..4b8f68568c99 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -250,6 +250,7 @@ struct nfs4_layoutget {
 	struct nfs4_layoutget_res res;
 	struct rpc_cred *cred;
 	gfp_t gfp_flags;
+	long timeout;
 };
 
 struct nfs4_getdeviceinfo_args {
@@ -288,6 +289,7 @@ struct nfs4_layoutcommit_data {
 	struct list_head lseg_list;
 	struct rpc_cred *cred;
 	struct inode *inode;
+	long timeout;
 	struct nfs4_layoutcommit_args args;
 	struct nfs4_layoutcommit_res res;
 };
@@ -313,6 +315,7 @@ struct nfs4_layoutreturn {
 	struct rpc_cred *cred;
 	struct nfs_client *clp;
 	struct inode *inode;
+	long timeout;
 	int rpc_status;
 };
 
@@ -1378,6 +1381,7 @@ struct nfs_pgio_header {
 	int			error;		/* merge with pnfs_error */
 	unsigned long		good_bytes;	/* boundary of good data */
 	unsigned long		flags;
+	long			timeout;
 
 	/*
 	 * rpc data
@@ -1430,6 +1434,7 @@ struct nfs_commit_data {
 	struct nfs_open_context *context;
 	struct pnfs_layout_segment *lseg;
 	struct nfs_client	*ds_clp;	/* pNFS data server */
+	long			timeout;
 	int			ds_commit_index;
 	loff_t			lwb;
 	const struct rpc_call_ops *mds_ops;
-- 
2.4.3

