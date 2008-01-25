From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 024/112] NFS/SUNRPC: Convert all users of rpc_call_setup()
Date: Fri, 25 Jan 2008 11:37:29 -0500
Message-ID: <20080125163729.31887.55224.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63573 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756962AbYAYRAh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:37 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH0LnG010494
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:35 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace use of rpc_call_setup() with rpc_init_task(), and in cases where we
need to initialise task->tk_action, with rpc_call_start().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c      |  112 ++++++++++++++++++++++--------------------------
 fs/nfs/unlink.c        |   28 +++---------
 net/sunrpc/rpcb_clnt.c |   40 ++++++++---------
 3 files changed, 78 insertions(+), 102 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7c0baf2..bda2957 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -718,19 +718,6 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 	return err;
 }
 
-static void nfs4_open_confirm_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfs4_opendata *data = calldata;
-	struct  rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_CONFIRM],
-		.rpc_argp = &data->c_arg,
-		.rpc_resp = &data->c_res,
-		.rpc_cred = data->owner->so_cred,
-	};
-	data->timestamp = jiffies;
-	rpc_call_setup(task, &msg, 0);
-}
-
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
@@ -767,7 +754,6 @@ out_free:
 }
 
 static const struct rpc_call_ops nfs4_open_confirm_ops = {
-	.rpc_call_prepare = nfs4_open_confirm_prepare,
 	.rpc_call_done = nfs4_open_confirm_done,
 	.rpc_release = nfs4_open_confirm_release,
 };
@@ -779,8 +765,15 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->dir->d_inode);
 	struct rpc_task *task;
+	struct  rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_CONFIRM],
+		.rpc_argp = &data->c_arg,
+		.rpc_resp = &data->c_res,
+		.rpc_cred = data->owner->so_cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
+		.rpc_message = &msg,
 		.callback_ops = &nfs4_open_confirm_ops,
 		.callback_data = data,
 		.flags = RPC_TASK_ASYNC,
@@ -790,6 +783,7 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
+	data->timestamp = jiffies;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -807,13 +801,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
 	struct nfs4_state_owner *sp = data->owner;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN],
-		.rpc_argp = &data->o_arg,
-		.rpc_resp = &data->o_res,
-		.rpc_cred = sp->so_cred,
-	};
-	
+
 	if (nfs_wait_on_sequence(data->o_arg.seqid, task) != 0)
 		return;
 	/*
@@ -838,11 +826,11 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	data->o_arg.id = sp->so_owner_id.id;
 	data->o_arg.clientid = sp->so_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
-		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
+		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-	rpc_call_setup(task, &msg, 0);
+	rpc_call_start(task);
 	return;
 out_no_action:
 	task->tk_action = NULL;
@@ -914,8 +902,15 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	struct nfs_openargs *o_arg = &data->o_arg;
 	struct nfs_openres *o_res = &data->o_res;
 	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN],
+		.rpc_argp = o_arg,
+		.rpc_resp = o_res,
+		.rpc_cred = data->owner->so_cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
+		.rpc_message = &msg,
 		.callback_ops = &nfs4_open_ops,
 		.callback_data = data,
 		.flags = RPC_TASK_ASYNC,
@@ -1256,12 +1251,6 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_closedata *calldata = data;
 	struct nfs4_state *state = calldata->state;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE],
-		.rpc_argp = &calldata->arg,
-		.rpc_resp = &calldata->res,
-		.rpc_cred = state->owner->so_cred,
-	};
 	int clear_rd, clear_wr, clear_rdwr;
 
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
@@ -1288,14 +1277,14 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	}
 	nfs_fattr_init(calldata->res.fattr);
 	if (test_bit(NFS_O_RDONLY_STATE, &state->flags) != 0) {
-		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
 		calldata->arg.open_flags = FMODE_READ;
 	} else if (test_bit(NFS_O_WRONLY_STATE, &state->flags) != 0) {
-		msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
+		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_DOWNGRADE];
 		calldata->arg.open_flags = FMODE_WRITE;
 	}
 	calldata->timestamp = jiffies;
-	rpc_call_setup(task, &msg, 0);
+	rpc_call_start(task);
 }
 
 static const struct rpc_call_ops nfs4_close_ops = {
@@ -1321,8 +1310,13 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	struct nfs4_closedata *calldata;
 	struct nfs4_state_owner *sp = state->owner;
 	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CLOSE],
+		.rpc_cred = state->owner->so_cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
+		.rpc_message = &msg,
 		.callback_ops = &nfs4_close_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -1345,6 +1339,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->path.mnt = mntget(path->mnt);
 	calldata->path.dentry = dget(path->dentry);
 
+	msg.rpc_argp = &calldata->arg,
+	msg.rpc_resp = &calldata->res,
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
@@ -2972,19 +2968,6 @@ struct nfs4_delegreturndata {
 	int rpc_status;
 };
 
-static void nfs4_delegreturn_prepare(struct rpc_task *task, void *calldata)
-{
-	struct nfs4_delegreturndata *data = calldata;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DELEGRETURN],
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};
-	nfs_fattr_init(data->res.fattr);
-	rpc_call_setup(task, &msg, 0);
-}
-
 static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
@@ -3002,7 +2985,6 @@ static void nfs4_delegreturn_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs4_delegreturn_ops = {
-	.rpc_call_prepare = nfs4_delegreturn_prepare,
 	.rpc_call_done = nfs4_delegreturn_done,
 	.rpc_release = nfs4_delegreturn_release,
 };
@@ -3012,6 +2994,10 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	struct nfs4_delegreturndata *data;
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_DELEGRETURN],
+		.rpc_cred = data->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = server->client,
 		.callback_ops = &nfs4_delegreturn_ops,
@@ -3029,11 +3015,14 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	memcpy(&data->stateid, stateid, sizeof(data->stateid));
 	data->res.fattr = &data->fattr;
 	data->res.server = server;
+	nfs_fattr_init(data->res.fattr);
 	data->cred = get_rpccred(cred);
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
 
 	task_setup_data.callback_data = data;
+	msg.rpc_argp = &data->args,
+	msg.rpc_resp = &data->res,
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -3221,12 +3210,6 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
-	struct rpc_message msg = {
-		.rpc_proc	= &nfs4_procedures[NFSPROC4_CLNT_LOCKU],
-		.rpc_argp       = &calldata->arg,
-		.rpc_resp       = &calldata->res,
-		.rpc_cred	= calldata->lsp->ls_state->owner->so_cred,
-	};
 
 	if (nfs_wait_on_sequence(calldata->arg.seqid, task) != 0)
 		return;
@@ -3236,7 +3219,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
-	rpc_call_setup(task, &msg, 0);
+	rpc_call_start(task);
 }
 
 static const struct rpc_call_ops nfs4_locku_ops = {
@@ -3251,8 +3234,13 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		struct nfs_seqid *seqid)
 {
 	struct nfs4_unlockdata *data;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOCKU],
+		.rpc_cred = ctx->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(lsp->ls_state->inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs4_locku_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -3268,6 +3256,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	msg.rpc_argp = &data->arg,
+	msg.rpc_resp = &data->res,
 	task_setup_data.callback_data = data;
 	return rpc_run_task(&task_setup_data);
 }
@@ -3353,13 +3343,6 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_lockdata *data = calldata;
 	struct nfs4_state *state = data->lsp->ls_state;
-	struct nfs4_state_owner *sp = state->owner;
-	struct rpc_message msg = {
-		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOCK],
-		.rpc_argp = &data->arg,
-		.rpc_resp = &data->res,
-		.rpc_cred = sp->so_cred,
-	};
 
 	dprintk("%s: begin!\n", __FUNCTION__);
 	if (nfs_wait_on_sequence(data->arg.lock_seqid, task) != 0)
@@ -3373,7 +3356,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
-	rpc_call_setup(task, &msg, 0);
+	rpc_call_start(task);
 	dprintk("%s: done!, ret = %d\n", __FUNCTION__, data->rpc_status);
 }
 
@@ -3435,8 +3418,13 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 {
 	struct nfs4_lockdata *data;
 	struct rpc_task *task;
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LOCK],
+		.rpc_cred = state->owner->so_cred,
+	};
 	struct rpc_task_setup task_setup_data = {
 		.rpc_client = NFS_CLIENT(state->inode),
+		.rpc_message = &msg,
 		.callback_ops = &nfs4_lock_ops,
 		.flags = RPC_TASK_ASYNC,
 	};
@@ -3451,6 +3439,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		data->arg.block = 1;
 	if (reclaim != 0)
 		data->arg.reclaim = 1;
+	msg.rpc_argp = &data->arg,
+	msg.rpc_resp = &data->res,
 	task_setup_data.callback_data = data;
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index e07b499..b0373b7 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -71,24 +71,6 @@ static void nfs_dec_sillycount(struct inode *dir)
 }
 
 /**
- * nfs_async_unlink_init - Initialize the RPC info
- * task: rpc_task of the sillydelete
- */
-static void nfs_async_unlink_init(struct rpc_task *task, void *calldata)
-{
-	struct nfs_unlinkdata *data = calldata;
-	struct inode *dir = data->dir;
-	struct rpc_message msg = {
-		.rpc_argp = &data->args,
-		.rpc_resp = &data->res,
-		.rpc_cred = data->cred,
-	};
-
-	NFS_PROTO(dir)->unlink_setup(&msg, dir);
-	rpc_call_setup(task, &msg, 0);
-}
-
-/**
  * nfs_async_unlink_done - Sillydelete post-processing
  * @task: rpc_task of the sillydelete
  *
@@ -120,14 +102,19 @@ static void nfs_async_unlink_release(void *calldata)
 }
 
 static const struct rpc_call_ops nfs_unlink_ops = {
-	.rpc_call_prepare = nfs_async_unlink_init,
 	.rpc_call_done = nfs_async_unlink_done,
 	.rpc_release = nfs_async_unlink_release,
 };
 
 static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
 {
+	struct rpc_message msg = {
+		.rpc_argp = &data->args,
+		.rpc_resp = &data->res,
+		.rpc_cred = data->cred,
+	};
 	struct rpc_task_setup task_setup_data = {
+		.rpc_message = &msg,
 		.callback_ops = &nfs_unlink_ops,
 		.callback_data = data,
 		.flags = RPC_TASK_ASYNC,
@@ -163,8 +150,9 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
-	task_setup_data.rpc_client = NFS_CLIENT(dir);
+	NFS_PROTO(dir)->unlink_setup(&msg, dir);
 
+	task_setup_data.rpc_client = NFS_CLIENT(dir);
 	task = rpc_run_task(&task_setup_data);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 7c362e5..f876e37 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -128,19 +128,6 @@ struct rpcb_info {
 static struct rpcb_info rpcb_next_version[];
 static struct rpcb_info rpcb_next_version6[];
 
-static void rpcb_getport_prepare(struct rpc_task *task, void *calldata)
-{
-	struct rpcbind_args *map = calldata;
-	struct rpc_xprt *xprt = map->r_xprt;
-	struct rpc_message msg = {
-		.rpc_proc	= rpcb_next_version[xprt->bind_index].rpc_proc,
-		.rpc_argp	= map,
-		.rpc_resp	= &map->r_port,
-	};
-
-	rpc_call_setup(task, &msg, 0);
-}
-
 static void rpcb_map_release(void *data)
 {
 	struct rpcbind_args *map = data;
@@ -150,7 +137,6 @@ static void rpcb_map_release(void *data)
 }
 
 static const struct rpc_call_ops rpcb_getport_ops = {
-	.rpc_call_prepare	= rpcb_getport_prepare,
 	.rpc_call_done		= rpcb_getport_done,
 	.rpc_release		= rpcb_map_release,
 };
@@ -295,6 +281,24 @@ int rpcb_getport_sync(struct sockaddr_in *sin, __u32 prog,
 }
 EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 
+static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbind_args *map, int version)
+{
+	struct rpc_message msg = {
+		.rpc_proc = rpcb_next_version[version].rpc_proc,
+		.rpc_argp = map,
+		.rpc_resp = &map->r_port,
+	};
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = rpcb_clnt,
+		.rpc_message = &msg,
+		.callback_ops = &rpcb_getport_ops,
+		.callback_data = map,
+		.flags = RPC_TASK_ASYNC,
+	};
+
+	return rpc_run_task(&task_setup_data);
+}
+
 /**
  * rpcb_getport_async - obtain the port for a given RPC service on a given host
  * @task: task that is waiting for portmapper request
@@ -310,10 +314,6 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
-	struct rpc_task_setup task_setup_data = {
-		.callback_ops = &rpcb_getport_ops,
-		.flags = RPC_TASK_ASYNC,
-	};
 	struct sockaddr addr;
 	int status;
 	struct rpcb_info *info;
@@ -399,9 +399,7 @@ void rpcb_getport_async(struct rpc_task *task)
 	       sizeof(map->r_addr));
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
-	task_setup_data.rpc_client = rpcb_clnt;
-	task_setup_data.callback_data = map;
-	child = rpc_run_task(&task_setup_data);
+	child = rpcb_call_async(rpcb_clnt, map, xprt->bind_index);
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
 		status = -EIO;
