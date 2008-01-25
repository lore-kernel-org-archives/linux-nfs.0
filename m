From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 018/112] SUNRPC: Clean up rpc_run_task
Date: Fri, 25 Jan 2008 11:37:28 -0500
Message-ID: <20080125163727.31887.80312.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14334 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754619AbYAYQ7r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 11:59:47 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxk1k010174
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 08:59:46 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it use the new task initialiser structure instead of acting as a
wrapper.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c            |   49 ++++++++++++++++++++++++++++++++++++------
 fs/nfs/unlink.c              |    9 +++++++-
 include/linux/sunrpc/sched.h |    3 +--
 net/sunrpc/clnt.c            |   36 ++++++++-----------------------
 net/sunrpc/rpcb_clnt.c       |    8 ++++++-
 5 files changed, 67 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a51a753..ff2c5f8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -779,12 +779,18 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->dir->d_inode);
 	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.callback_ops = &nfs4_open_confirm_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
 	int status;
 
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
-	task = rpc_run_task(server->client, RPC_TASK_ASYNC, &nfs4_open_confirm_ops, data);
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
@@ -908,13 +914,19 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	struct nfs_openargs *o_arg = &data->o_arg;
 	struct nfs_openres *o_res = &data->o_res;
 	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.callback_ops = &nfs4_open_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
 	int status;
 
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
 	data->cancelled = 0;
-	task = rpc_run_task(server->client, RPC_TASK_ASYNC, &nfs4_open_ops, data);
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
@@ -1309,6 +1321,11 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	struct nfs4_closedata *calldata;
 	struct nfs4_state_owner *sp = state->owner;
 	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.callback_ops = &nfs4_close_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	int status = -ENOMEM;
 
 	calldata = kmalloc(sizeof(*calldata), GFP_KERNEL);
@@ -1328,7 +1345,8 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->path.mnt = mntget(path->mnt);
 	calldata->path.dentry = dget(path->dentry);
 
-	task = rpc_run_task(server->client, RPC_TASK_ASYNC, &nfs4_close_ops, calldata);
+	task_setup_data.callback_data = calldata;
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = 0;
@@ -3027,6 +3045,11 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	struct nfs4_delegreturndata *data;
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = server->client,
+		.callback_ops = &nfs4_delegreturn_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	int status;
 
 	data = kmalloc(sizeof(*data), GFP_KERNEL);
@@ -3043,7 +3066,8 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data->timestamp = jiffies;
 	data->rpc_status = 0;
 
-	task = rpc_run_task(NFS_CLIENT(inode), RPC_TASK_ASYNC, &nfs4_delegreturn_ops, data);
+	task_setup_data.callback_data = data;
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = nfs4_wait_for_completion_rpc_task(task);
@@ -3260,6 +3284,11 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		struct nfs_seqid *seqid)
 {
 	struct nfs4_unlockdata *data;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(lsp->ls_state->inode),
+		.callback_ops = &nfs4_locku_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 
 	/* Ensure this is an unlock - when canceling a lock, the
 	 * canceled lock is passed in, and it won't be an unlock.
@@ -3272,7 +3301,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	return rpc_run_task(NFS_CLIENT(lsp->ls_state->inode), RPC_TASK_ASYNC, &nfs4_locku_ops, data);
+	task_setup_data.callback_data = data;
+	return rpc_run_task(&task_setup_data);
 }
 
 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
@@ -3438,6 +3468,11 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 {
 	struct nfs4_lockdata *data;
 	struct rpc_task *task;
+	struct rpc_task_setup task_setup_data = {
+		.rpc_client = NFS_CLIENT(state->inode),
+		.callback_ops = &nfs4_lock_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	int ret;
 
 	dprintk("%s: begin!\n", __FUNCTION__);
@@ -3449,8 +3484,8 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		data->arg.block = 1;
 	if (reclaim != 0)
 		data->arg.reclaim = 1;
-	task = rpc_run_task(NFS_CLIENT(state->inode), RPC_TASK_ASYNC,
-			&nfs4_lock_ops, data);
+	task_setup_data.callback_data = data;
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	ret = nfs4_wait_for_completion_rpc_task(task);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c90862a..e07b499 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -127,6 +127,11 @@ static const struct rpc_call_ops nfs_unlink_ops = {
 
 static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct nfs_unlinkdata *data)
 {
+	struct rpc_task_setup task_setup_data = {
+		.callback_ops = &nfs_unlink_ops,
+		.callback_data = data,
+		.flags = RPC_TASK_ASYNC,
+	};
 	struct rpc_task *task;
 	struct dentry *alias;
 
@@ -158,7 +163,9 @@ static int nfs_do_call_unlink(struct dentry *parent, struct inode *dir, struct n
 	data->args.fh = NFS_FH(dir);
 	nfs_fattr_init(&data->res.dir_attr);
 
-	task = rpc_run_task(NFS_CLIENT(dir), RPC_TASK_ASYNC, &nfs_unlink_ops, data);
+	task_setup_data.rpc_client = NFS_CLIENT(dir);
+
+	task = rpc_run_task(&task_setup_data);
 	if (!IS_ERR(task))
 		rpc_put_task(task);
 	return 1;
diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 9efe045..d974421 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -244,8 +244,7 @@ struct rpc_wait_queue {
  * Function prototypes
  */
 struct rpc_task *rpc_new_task(const struct rpc_task_setup *);
-struct rpc_task *rpc_run_task(struct rpc_clnt *clnt, int flags,
-				const struct rpc_call_ops *ops, void *data);
+struct rpc_task *rpc_run_task(const struct rpc_task_setup *);
 void		rpc_init_task(struct rpc_task *task, const struct rpc_task_setup *);
 void		rpc_put_task(struct rpc_task *);
 void		rpc_exit_task(struct rpc_task *);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7c80abd..9aad459 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -523,8 +523,11 @@ void rpc_clnt_sigunmask(struct rpc_clnt *clnt, sigset_t *oldset)
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_sigunmask);
 
-static
-struct rpc_task *rpc_do_run_task(const struct rpc_task_setup *task_setup_data)
+/**
+ * rpc_run_task - Allocate a new RPC task, then run rpc_execute against it
+ * @task_setup_data: pointer to task initialisation data
+ */
+struct rpc_task *rpc_run_task(const struct rpc_task_setup *task_setup_data)
 {
 	struct rpc_task *task, *ret;
 	sigset_t oldset;
@@ -553,6 +556,7 @@ out:
 	rpc_restore_sigmask(&oldset);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(rpc_run_task);
 
 /**
  * rpc_call_sync - Perform a synchronous RPC call
@@ -573,7 +577,7 @@ int rpc_call_sync(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 
 	BUG_ON(flags & RPC_TASK_ASYNC);
 
-	task = rpc_do_run_task(&task_setup_data);
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = task->tk_status;
@@ -603,7 +607,7 @@ rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg, int flags,
 		.flags = flags|RPC_TASK_ASYNC,
 	};
 
-	task = rpc_do_run_task(&task_setup_data);
+	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
@@ -611,28 +615,6 @@ rpc_call_async(struct rpc_clnt *clnt, struct rpc_message *msg, int flags,
 }
 EXPORT_SYMBOL_GPL(rpc_call_async);
 
-/**
- * rpc_run_task - Allocate a new RPC task, then run rpc_execute against it
- * @clnt: pointer to RPC client
- * @flags: RPC flags
- * @ops: RPC call ops
- * @data: user call data
- */
-struct rpc_task *rpc_run_task(struct rpc_clnt *clnt, int flags,
-					const struct rpc_call_ops *tk_ops,
-					void *data)
-{
-	struct rpc_task_setup task_setup_data = {
-		.rpc_client = clnt,
-		.callback_ops = tk_ops,
-		.callback_data = data,
-		.flags = flags,
-	};
-
-	return rpc_do_run_task(&task_setup_data);
-}
-EXPORT_SYMBOL_GPL(rpc_run_task);
-
 void
 rpc_call_setup(struct rpc_task *task, const struct rpc_message *msg, int flags)
 {
@@ -1550,7 +1532,7 @@ struct rpc_task *rpc_call_null(struct rpc_clnt *clnt, struct rpc_cred *cred, int
 		.callback_ops = &rpc_default_ops,
 		.flags = flags,
 	};
-	return rpc_do_run_task(&task_setup_data);
+	return rpc_run_task(&task_setup_data);
 }
 EXPORT_SYMBOL_GPL(rpc_call_null);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index a05493a..7c362e5 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -310,6 +310,10 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct rpc_clnt	*rpcb_clnt;
 	static struct rpcbind_args *map;
 	struct rpc_task	*child;
+	struct rpc_task_setup task_setup_data = {
+		.callback_ops = &rpcb_getport_ops,
+		.flags = RPC_TASK_ASYNC,
+	};
 	struct sockaddr addr;
 	int status;
 	struct rpcb_info *info;
@@ -395,7 +399,9 @@ void rpcb_getport_async(struct rpc_task *task)
 	       sizeof(map->r_addr));
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
-	child = rpc_run_task(rpcb_clnt, RPC_TASK_ASYNC, &rpcb_getport_ops, map);
+	task_setup_data.rpc_client = rpcb_clnt;
+	task_setup_data.callback_data = map;
+	child = rpc_run_task(&task_setup_data);
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
 		status = -EIO;
