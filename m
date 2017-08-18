Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:55461 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750927AbdHRHOT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Aug 2017 03:14:19 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Aug 2017 17:12:52 +1000
Subject: [PATCH 7/8] NFS: remove error handling for callers of rpc_new_task()
Cc: linux-nfs@vger.kernel.org
Message-ID: <150304037206.30218.6010632417893362395.stgit@noble>
In-Reply-To: <150304014011.30218.1636255532744321171.stgit@noble>
References: <150304014011.30218.1636255532744321171.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since commit 62b2417e84ba ("sunrpc: don't check for failure from mempool_alloc()")

rpc_new_task() cannot fail, so functions which fail only when it failed
also cannot fail.
This means we no longer need to check for errors from:

  rpc_run_task()
  rpc_run_bc_task()
  __nlm_async_call()
  nfs4_do_unlck()
  _nfs41_proc_sequence()
  _nfs41_free_stateid()
  nfs_async_rename()
  rpc_call_null()
  rpc_call_null_helper()
  rpcb_call_async()

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: NeilBrown <neilb@suse.com>


 Hi,
  if you think there might ever be a need to allow
  rpc_new_task() to fail in the future, we might not
  want to take this approach.


Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/lockd/clntproc.c            |    4 ---
 fs/nfs/nfs42proc.c             |    2 -
 fs/nfs/nfs4proc.c              |   62 ++++------------------------------------
 fs/nfs/pagelist.c              |    5 ---
 fs/nfs/unlink.c                |    9 +-----
 fs/nfs/write.c                 |    2 -
 net/sunrpc/auth_gss/auth_gss.c |    3 +-
 net/sunrpc/clnt.c              |   10 ------
 net/sunrpc/rpcb_clnt.c         |    6 ----
 net/sunrpc/svc.c               |    6 ----
 10 files changed, 8 insertions(+), 101 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 066ac313ae5c..fefed4a8d9c8 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -367,8 +367,6 @@ static int nlm_do_async_call(struct nlm_rqst *req, u32 proc, struct rpc_message
 	struct rpc_task *task;
 
 	task = __nlm_async_call(req, proc, msg, tk_ops);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
@@ -412,8 +410,6 @@ static int nlmclnt_async_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 p
 	int err;
 
 	task = __nlm_async_call(req, proc, &msg, tk_ops);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	err = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 	return err;
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 6c2db51e67a7..0062a73973ee 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -463,8 +463,6 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	task = rpc_run_task(&task_setup);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d90132642340..df4a8724e85d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -977,12 +977,8 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	};
 
 	task = rpc_run_task(&task_setup);
-	if (IS_ERR(task))
-		ret = PTR_ERR(task);
-	else {
-		ret = task->tk_status;
-		rpc_put_task(task);
-	}
+	ret = task->tk_status;
+	rpc_put_task(task);
 	return ret;
 }
 
@@ -2024,8 +2020,6 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	if (data->is_recover)
 		nfs4_set_sequence_privileged(&data->c_arg.seq_args);
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
 		data->cancelled = true;
@@ -2191,8 +2185,6 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 		data->is_recover = true;
 	}
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	status = rpc_wait_for_completion_task(task);
 	if (status != 0) {
 		data->cancelled = true;
@@ -3213,8 +3205,6 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	status = 0;
 	if (wait)
 		status = rpc_wait_for_completion_task(task);
@@ -5536,10 +5526,6 @@ int nfs4_proc_setclientid(struct nfs_client *clp, u32 program,
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_owner_id);
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		status = PTR_ERR(task);
-		goto out;
-	}
 	status = task->tk_status;
 	if (setclientid.sc_cred) {
 		clp->cl_acceptor = rpcauth_stringify_acceptor(setclientid.sc_cred);
@@ -5755,8 +5741,6 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	if (!issync)
 		goto out;
 	status = rpc_wait_for_completion_task(task);
@@ -6035,9 +6019,6 @@ static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *
 	if (IS_ERR(seqid))
 		goto out;
 	task = nfs4_do_unlck(request, nfs_file_open_context(request->fl_file), lsp, seqid);
-	status = PTR_ERR(task);
-	if (IS_ERR(task))
-		goto out;
 	status = rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
 out:
@@ -6193,8 +6174,7 @@ static void nfs4_lock_release(void *calldata)
 		struct rpc_task *task;
 		task = nfs4_do_unlck(&data->fl, data->ctx, data->lsp,
 				data->arg.lock_seqid);
-		if (!IS_ERR(task))
-			rpc_put_task_async(task);
+		rpc_put_task_async(task);
 		dprintk("%s: cancelling lock!\n", __func__);
 	} else
 		nfs_free_seqid(data->arg.lock_seqid);
@@ -6263,8 +6243,6 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	} else
 		data->arg.new_lock = 1;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	ret = rpc_wait_for_completion_task(task);
 	if (ret == 0) {
 		ret = data->rpc_status;
@@ -7222,11 +7200,8 @@ int nfs4_proc_bind_one_conn_to_session(struct rpc_clnt *clnt,
 		args.dir = NFS4_CDFC4_FORE;
 
 	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task)) {
-		status = task->tk_status;
-		rpc_put_task(task);
-	} else
-		status = PTR_ERR(task);
+	status = task->tk_status;
+	rpc_put_task(task);
 	trace_nfs4_bind_conn_to_session(clp, status);
 	if (status == 0) {
 		if (memcmp(res.sessionid.data,
@@ -7573,8 +7548,6 @@ static int _nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred,
 	task_setup_data.callback_data = calldata;
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 
 	status = calldata->rpc_status;
 
@@ -7799,9 +7772,6 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	nfs4_set_sequence_privileged(&args.la_seq_args);
 	task = rpc_run_task(&task_setup);
 
-	if (IS_ERR(task))
-		return PTR_ERR(task);
-
 	status = task->tk_status;
 	rpc_put_task(task);
 	return status;
@@ -8149,10 +8119,7 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp, struct rpc_cred *cr
 	if ((renew_flags & NFS4_RENEW_TIMEOUT) == 0)
 		return -EAGAIN;
 	task = _nfs41_proc_sequence(clp, cred, false);
-	if (IS_ERR(task))
-		ret = PTR_ERR(task);
-	else
-		rpc_put_task_async(task);
+	rpc_put_task_async(task);
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
 }
@@ -8163,15 +8130,10 @@ static int nfs4_proc_sequence(struct nfs_client *clp, struct rpc_cred *cred)
 	int ret;
 
 	task = _nfs41_proc_sequence(clp, cred, true);
-	if (IS_ERR(task)) {
-		ret = PTR_ERR(task);
-		goto out;
-	}
 	ret = rpc_wait_for_completion_task(task);
 	if (!ret)
 		ret = task->tk_status;
 	rpc_put_task(task);
-out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
 	return ret;
 }
@@ -8280,10 +8242,6 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		status = PTR_ERR(task);
-		goto out;
-	}
 	status = rpc_wait_for_completion_task(task);
 	if (status == 0)
 		status = task->tk_status;
@@ -8515,8 +8473,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return ERR_CAST(task);
 	status = rpc_wait_for_completion_task(task);
 	if (status == 0) {
 		status = nfs4_layoutget_handle_exception(task, lgp, &exception);
@@ -8632,8 +8588,6 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 	}
 	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	if (sync)
 		status = task->tk_status;
 	trace_nfs4_layoutreturn(lrp->args.inode, &lrp->args.stateid, status);
@@ -8779,8 +8733,6 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 	}
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	if (sync)
 		status = task->tk_status;
 	trace_nfs4_layoutcommit(data->args.inode, &data->args.stateid, status);
@@ -9106,8 +9058,6 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	struct rpc_task *task;
 
 	task = _nfs41_free_stateid(server, stateid, cred, is_recovery);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index de9066a92c0d..12c1465c1472 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -646,17 +646,12 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		(unsigned long long)hdr->args.offset);
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task)) {
-		ret = PTR_ERR(task);
-		goto out;
-	}
 	if (how & FLUSH_SYNC) {
 		ret = rpc_wait_for_completion_task(task);
 		if (ret == 0)
 			ret = task->tk_status;
 	}
 	rpc_put_task(task);
-out:
 	return ret;
 }
 EXPORT_SYMBOL_GPL(nfs_initiate_pgio);
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index e3949d93085c..3cb88c073fde 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -108,8 +108,7 @@ static void nfs_do_call_unlink(struct nfs_unlinkdata *data)
 
 	task_setup_data.rpc_client = NFS_CLIENT(dir);
 	task = rpc_run_task(&task_setup_data);
-	if (!IS_ERR(task))
-		rpc_put_task_async(task);
+	rpc_put_task_async(task);
 }
 
 static int nfs_call_unlink(struct dentry *dentry, struct nfs_unlinkdata *data)
@@ -497,12 +496,6 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	/* run the rename task, undo unlink if it fails */
 	task = nfs_async_rename(dir, dir, dentry, sdentry,
 					nfs_complete_sillyrename);
-	if (IS_ERR(task)) {
-		error = -EBUSY;
-		nfs_cancel_async_unlink(dentry);
-		goto out_dput;
-	}
-
 	/* wait for the RPC task to complete, unless a SIGKILL intervenes */
 	error = rpc_wait_for_completion_task(task);
 	if (error == 0)
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index e833179d0d49..c2924d3f172a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1691,8 +1691,6 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	if (how & FLUSH_SYNC)
 		rpc_wait_for_completion_task(task);
 	rpc_put_task(task);
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9463af4b32e8..bfcf5e96483c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1232,8 +1232,7 @@ gss_destroying_context(struct rpc_cred *cred)
 	get_rpccred(cred);
 
 	task = rpc_call_null(gss_auth->client, cred, RPC_TASK_ASYNC|RPC_TASK_SOFT);
-	if (!IS_ERR(task))
-		rpc_put_task(task);
+	rpc_put_task(task);
 
 	put_rpccred(cred);
 	return 1;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2ad827db2704..e1d96f52e97f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1080,8 +1080,6 @@ int rpc_call_sync(struct rpc_clnt *clnt, const struct rpc_message *msg, int flag
 	}
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	status = task->tk_status;
 	rpc_put_task(task);
 	return status;
@@ -1110,8 +1108,6 @@ rpc_call_async(struct rpc_clnt *clnt, const struct rpc_message *msg, int flags,
 	};
 
 	task = rpc_run_task(&task_setup_data);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 0;
 }
@@ -2590,8 +2586,6 @@ int rpc_clnt_test_and_add_xprt(struct rpc_clnt *clnt,
 			RPC_TASK_SOFT|RPC_TASK_SOFTCONN|RPC_TASK_ASYNC,
 			&rpc_cb_add_xprt_call_ops, data);
 	put_rpccred(cred);
-	if (IS_ERR(task))
-		return PTR_ERR(task);
 	rpc_put_task(task);
 	return 1;
 }
@@ -2637,10 +2631,6 @@ int rpc_clnt_setup_test_and_add_xprt(struct rpc_clnt *clnt,
 				    RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 				    NULL, NULL);
 	put_rpccred(cred);
-	if (IS_ERR(task)) {
-		status = PTR_ERR(task);
-		goto out_err;
-	}
 	status = task->tk_status;
 	rpc_put_task(task);
 
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index ea0676f199c8..57a955583360 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -782,12 +782,6 @@ void rpcb_getport_async(struct rpc_task *task)
 
 	child = rpcb_call_async(rpcb_clnt, map, proc);
 	rpc_release_client(rpcb_clnt);
-	if (IS_ERR(child)) {
-		/* rpcb_map_release() has freed the arguments */
-		dprintk("RPC: %5u %s: rpc_run_task failed\n",
-			task->tk_pid, __func__);
-		return;
-	}
 
 	xprt->stat.bind_count++;
 	rpc_put_task(child);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 85ce0db5b0a6..10c2182f70aa 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1508,16 +1508,10 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
 	/* Finally, send the reply synchronously */
 	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
 	task = rpc_run_bc_task(req);
-	if (IS_ERR(task)) {
-		error = PTR_ERR(task);
-		goto out;
-	}
-
 	WARN_ON_ONCE(atomic_read(&task->tk_count) != 1);
 	error = task->tk_status;
 	rpc_put_task(task);
 
-out:
 	dprintk("svc: %s(), error=%d\n", __func__, error);
 	return error;
 }


