Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53625 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753224Ab2AQTNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:13:42 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/8] NFSv41: Add a new helper nfs4_init_sequence()
Date: Tue, 17 Jan 2012 14:13:30 -0500
Message-Id: <1326827613-7997-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326827613-7997-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1326827613-7997-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-2-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-3-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |    6 ++--
 fs/nfs/nfs4filelayout.c |    4 +-
 fs/nfs/nfs4proc.c       |   86 +++++++++++++++++++++++++++++------------------
 fs/nfs/read.c           |    2 +-
 fs/nfs/unlink.c         |    4 +-
 fs/nfs/write.c          |    2 +-
 6 files changed, 62 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2d1f5a5..583ded0 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -230,10 +230,10 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 
 extern int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		int cache_reply, struct rpc_task *task);
+		struct rpc_task *task);
 extern int nfs41_setup_sequence(struct nfs4_session *session,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		int cache_reply, struct rpc_task *task);
+		struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
 extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
 extern int nfs4_proc_create_session(struct nfs_client *);
@@ -264,7 +264,7 @@ static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *ser
 
 static inline int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
-		int cache_reply, struct rpc_task *task)
+		struct rpc_task *task)
 {
 	return 0;
 }
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 71ec086..b4f8f96 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -173,7 +173,7 @@ static void filelayout_read_prepare(struct rpc_task *task, void *data)
 
 	if (nfs41_setup_sequence(rdata->ds_clp->cl_session,
 				&rdata->args.seq_args, &rdata->res.seq_res,
-				0, task))
+				task))
 		return;
 
 	rpc_call_start(task);
@@ -254,7 +254,7 @@ static void filelayout_write_prepare(struct rpc_task *task, void *data)
 
 	if (nfs41_setup_sequence(wdata->ds_clp->cl_session,
 				&wdata->args.seq_args, &wdata->res.seq_res,
-				0, task))
+				task))
 		return;
 
 	rpc_call_start(task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7ccc12d..3233ee0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -534,10 +534,19 @@ out:
 	return ret_id;
 }
 
+static void nfs41_init_sequence(struct nfs4_sequence_args *args,
+		struct nfs4_sequence_res *res, int cache_reply)
+{
+	args->sa_session = NULL;
+	args->sa_cache_this = 0;
+	if (cache_reply)
+		args->sa_cache_this = 1;
+	res->sr_slot = NULL;
+}
+
 int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
-				int cache_reply,
 				struct rpc_task *task)
 {
 	struct nfs4_slot *slot;
@@ -582,7 +591,6 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 	slot = tbl->slots + slotid;
 	args->sa_session = session;
 	args->sa_slotid = slotid;
-	args->sa_cache_this = cache_reply;
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
 
@@ -602,7 +610,6 @@ EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 int nfs4_setup_sequence(const struct nfs_server *server,
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
-			int cache_reply,
 			struct rpc_task *task)
 {
 	struct nfs4_session *session = nfs4_get_session(server);
@@ -618,8 +625,7 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		__func__, session->clp, session, res->sr_slot ?
 			res->sr_slot - session->fc_slot_table.slots : -1);
 
-	ret = nfs41_setup_sequence(session, args, res, cache_reply,
-				   task);
+	ret = nfs41_setup_sequence(session, args, res, task);
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
@@ -629,7 +635,6 @@ struct nfs41_call_sync_data {
 	const struct nfs_server *seq_server;
 	struct nfs4_sequence_args *seq_args;
 	struct nfs4_sequence_res *seq_res;
-	int cache_reply;
 };
 
 static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
@@ -639,7 +644,7 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
 
 	if (nfs4_setup_sequence(data->seq_server, data->seq_args,
-				data->seq_res, data->cache_reply, task))
+				data->seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -672,7 +677,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
-				   int cache_reply,
 				   int privileged)
 {
 	int ret;
@@ -681,7 +685,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 		.seq_server = server,
 		.seq_args = args,
 		.seq_res = res,
-		.cache_reply = cache_reply,
 	};
 	struct rpc_task_setup task_setup = {
 		.rpc_client = clnt,
@@ -690,7 +693,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 		.callback_data = &data
 	};
 
-	res->sr_slot = NULL;
 	if (privileged)
 		task_setup.callback_ops = &nfs41_call_priv_sync_ops;
 	task = rpc_run_task(&task_setup);
@@ -710,10 +712,17 @@ int _nfs4_call_sync_session(struct rpc_clnt *clnt,
 			    struct nfs4_sequence_res *res,
 			    int cache_reply)
 {
-	return nfs4_call_sync_sequence(clnt, server, msg, args, res, cache_reply, 0);
+	nfs41_init_sequence(args, res, cache_reply);
+	return nfs4_call_sync_sequence(clnt, server, msg, args, res, 0);
 }
 
 #else
+static inline
+void nfs41_init_sequence(struct nfs4_sequence_args *args,
+		struct nfs4_sequence_res *res, int cache_reply)
+{
+}
+
 static int nfs4_sequence_done(struct rpc_task *task,
 			       struct nfs4_sequence_res *res)
 {
@@ -728,7 +737,7 @@ int _nfs4_call_sync(struct rpc_clnt *clnt,
 		    struct nfs4_sequence_res *res,
 		    int cache_reply)
 {
-	args->sa_session = res->sr_session = NULL;
+	nfs41_init_sequence(args, res, cache_reply);
 	return rpc_call_sync(clnt, msg, 0);
 }
 
@@ -1449,7 +1458,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	data->timestamp = jiffies;
 	if (nfs4_setup_sequence(data->o_arg.server,
 				&data->o_arg.seq_args,
-				&data->o_res.seq_res, 1, task))
+				&data->o_res.seq_res, task))
 		return;
 	rpc_call_start(task);
 	return;
@@ -1551,6 +1560,7 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	};
 	int status;
 
+	nfs41_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
@@ -2029,8 +2039,9 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
 	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
-				&calldata->arg.seq_args, &calldata->res.seq_res,
-				1, task))
+				&calldata->arg.seq_args,
+				&calldata->res.seq_res,
+				task))
 		return;
 	rpc_call_start(task);
 }
@@ -2074,6 +2085,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, bool roc)
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
+	nfs41_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 1);
 	calldata->inode = state->inode;
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
@@ -2712,8 +2724,8 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 	args->bitmask = server->cache_consistency_bitmask;
 	res->server = server;
-	res->seq_res.sr_slot = NULL;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
+	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
 }
 
 static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
@@ -2738,6 +2750,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
 	arg->bitmask = server->attr_bitmask;
 	res->server = server;
+	nfs41_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
 
 static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
@@ -3232,6 +3245,7 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	data->timestamp   = jiffies;
 	data->read_done_cb = nfs4_read_done_cb;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
+	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
 /* Reset the the nfs_read_data to send the read to the MDS. */
@@ -3305,6 +3319,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	data->timestamp   = jiffies;
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
+	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
 static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *data)
@@ -3891,7 +3906,7 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	if (nfs4_setup_sequence(d_data->res.server,
 				&d_data->args.seq_args,
-				&d_data->res.seq_res, 1, task))
+				&d_data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -3925,6 +3940,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
+	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	data->args.fhandle = &data->fh;
 	data->args.stateid = &data->stateid;
 	data->args.bitmask = server->attr_bitmask;
@@ -4142,7 +4158,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 	calldata->timestamp = jiffies;
 	if (nfs4_setup_sequence(calldata->server,
 				&calldata->arg.seq_args,
-				&calldata->res.seq_res, 1, task))
+				&calldata->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -4182,6 +4198,7 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
+	nfs41_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
@@ -4297,7 +4314,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	data->timestamp = jiffies;
 	if (nfs4_setup_sequence(data->server,
 				&data->arg.seq_args,
-				&data->res.seq_res, 1, task))
+				&data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
@@ -4415,6 +4432,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 			data->arg.reclaim = NFS_LOCK_RECLAIM;
 		task_setup_data.callback_ops = &nfs4_recover_lock_ops;
 	}
+	nfs41_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
@@ -4930,7 +4948,7 @@ static void nfs4_get_lease_time_prepare(struct rpc_task *task,
 	   since we're invoked within one */
 	ret = nfs41_setup_sequence(data->clp->cl_session,
 				   &data->args->la_seq_args,
-				   &data->res->lr_seq_res, 0, task);
+				   &data->res->lr_seq_res, task);
 
 	BUG_ON(ret == -EAGAIN);
 	rpc_call_start(task);
@@ -4994,6 +5012,7 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	};
 	int status;
 
+	nfs41_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
 	dprintk("--> %s\n", __func__);
 	task = rpc_run_task(&task_setup);
 
@@ -5467,7 +5486,7 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	args = task->tk_msg.rpc_argp;
 	res = task->tk_msg.rpc_resp;
 
-	if (nfs41_setup_sequence(clp->cl_session, args, res, 0, task))
+	if (nfs41_setup_sequence(clp->cl_session, args, res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -5499,6 +5518,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp, struct rpc_
 		nfs_put_client(clp);
 		return ERR_PTR(-ENOMEM);
 	}
+	nfs41_init_sequence(&calldata->args, &calldata->res, 0);
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
 	calldata->clp = clp;
@@ -5560,7 +5580,7 @@ static void nfs4_reclaim_complete_prepare(struct rpc_task *task, void *data)
 	rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
 	if (nfs41_setup_sequence(calldata->clp->cl_session,
 				&calldata->arg.seq_args,
-				&calldata->res.seq_res, 0, task))
+				&calldata->res.seq_res, task))
 		return;
 
 	rpc_call_start(task);
@@ -5639,6 +5659,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp)
 	calldata->clp = clp;
 	calldata->arg.one_fs = 0;
 
+	nfs41_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 0);
 	msg.rpc_argp = &calldata->arg;
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
@@ -5670,7 +5691,7 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
 	 * to be no way to prevent it completely.
 	 */
 	if (nfs4_setup_sequence(server, &lgp->args.seq_args,
-				&lgp->res.seq_res, 0, task))
+				&lgp->res.seq_res, task))
 		return;
 	if (pnfs_choose_layoutget_stateid(&lgp->args.stateid,
 					  NFS_I(lgp->args.inode)->layout,
@@ -5745,6 +5766,7 @@ int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
+	nfs41_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -5765,7 +5787,7 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 
 	dprintk("--> %s\n", __func__);
 	if (nfs41_setup_sequence(lrp->clp->cl_session, &lrp->args.seq_args,
-				&lrp->res.seq_res, 0, task))
+				&lrp->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -5831,6 +5853,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	int status;
 
 	dprintk("--> %s\n", __func__);
+	nfs41_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -5931,7 +5954,7 @@ static void nfs4_layoutcommit_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(data->args.inode);
 
 	if (nfs4_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, 1, task))
+				&data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -6018,6 +6041,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		data->args.lastbytewritten,
 		data->args.inode->i_ino);
 
+	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -6113,7 +6137,6 @@ out:
 }
 static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
 {
-	int status;
 	struct nfs41_test_stateid_args args = {
 		.stateid = &state->stateid,
 	};
@@ -6123,9 +6146,8 @@ static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *sta
 		.rpc_argp = &args,
 		.rpc_resp = &res,
 	};
-	args.seq_args.sa_session = res.seq_res.sr_session = NULL;
-	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 1);
-	return status;
+	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 }
 
 static int nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
@@ -6142,7 +6164,6 @@ static int nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *stat
 
 static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *state)
 {
-	int status;
 	struct nfs41_free_stateid_args args = {
 		.stateid = &state->stateid,
 	};
@@ -6153,9 +6174,8 @@ static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *stat
 		.rpc_resp = &res,
 	};
 
-	args.seq_args.sa_session = res.seq_res.sr_session = NULL;
-	status = nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 0, 1);
-	return status;
+	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
+	return nfs4_call_sync_sequence(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
 }
 
 static int nfs41_free_stateid(struct nfs_server *server, struct nfs4_state *state)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index cfa175c..3c2540d 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -472,7 +472,7 @@ void nfs_read_prepare(struct rpc_task *task, void *calldata)
 
 	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
 				&data->args.seq_args, &data->res.seq_res,
-				0, task))
+				task))
 		return;
 	rpc_call_start(task);
 }
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 4f9319a..490613b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -114,7 +114,7 @@ void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(data->dir);
 
 	if (nfs4_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, 1, task))
+				&data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
@@ -410,7 +410,7 @@ static void nfs_rename_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = NFS_SERVER(data->old_dir);
 
 	if (nfs4_setup_sequence(server, &data->args.seq_args,
-				&data->res.seq_res, 1, task))
+				&data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 834f0fe..0b1831d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1135,7 +1135,7 @@ void nfs_write_prepare(struct rpc_task *task, void *calldata)
 
 	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
 				&data->args.seq_args,
-				&data->res.seq_res, 1, task))
+				&data->res.seq_res, task))
 		return;
 	rpc_call_start(task);
 }
-- 
1.7.7.5

