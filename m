Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:45223 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbeEDUXm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 16:23:42 -0400
Received: by mail-qk0-f193.google.com with SMTP id x22so17614983qkb.12
        for <linux-nfs@vger.kernel.org>; Fri, 04 May 2018 13:23:41 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] NFS: Pass "privileged" value to nfs4_init_sequence()
Date: Fri,  4 May 2018 16:22:50 -0400
Message-Id: <20180504202252.5862-4-Anna.Schumaker@Netapp.com>
In-Reply-To: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
References: <20180504202252.5862-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

We currently have a separate function just to set this, but I think it
makes more sense to set it at the same time as the other values in
nfs4_init_sequence()

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs42proc.c |  2 +-
 fs/nfs/nfs4_fs.h   |  2 +-
 fs/nfs/nfs4proc.c  | 81 ++++++++++++++++++----------------------------
 3 files changed, 33 insertions(+), 52 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 9c374441f660..4d4a3df28779 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -462,7 +462,7 @@ int nfs42_proc_layoutstats_generic(struct nfs_server *server,
 		nfs42_layoutstat_release(data);
 		return -EAGAIN;
 	}
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0, 0);
 	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b374f680830c..06a41aa2fdb2 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -251,7 +251,7 @@ extern int nfs4_handle_exception(struct nfs_server *, int, struct nfs4_exception
 extern int nfs4_call_sync(struct rpc_clnt *, struct nfs_server *,
 			  struct rpc_message *, struct nfs4_sequence_args *,
 			  struct nfs4_sequence_res *, int);
-extern void nfs4_init_sequence(struct nfs4_sequence_args *, struct nfs4_sequence_res *, int);
+extern void nfs4_init_sequence(struct nfs4_sequence_args *, struct nfs4_sequence_res *, int, int);
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
 extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *, bool);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 50a067018a60..6c749ce7587e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -608,20 +608,16 @@ struct nfs4_call_sync_data {
 };
 
 void nfs4_init_sequence(struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res, int cache_reply)
+			struct nfs4_sequence_res *res, int cache_reply,
+			int privileged)
 {
 	args->sa_slot = NULL;
 	args->sa_cache_this = cache_reply;
-	args->sa_privileged = 0;
+	args->sa_privileged = privileged;
 
 	res->sr_slot = NULL;
 }
 
-static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
-{
-	args->sa_privileged = 1;
-}
-
 static void nfs40_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot *slot = res->sr_slot;
@@ -1035,7 +1031,7 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs4_sequence_res *res,
 		   int cache_reply)
 {
-	nfs4_init_sequence(args, res, cache_reply);
+	nfs4_init_sequence(args, res, cache_reply, 0);
 	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
 }
 
@@ -2187,13 +2183,12 @@ static int _nfs4_proc_open_confirm(struct nfs4_opendata *data)
 	};
 	int status;
 
-	nfs4_init_sequence(&data->c_arg.seq_args, &data->c_res.seq_res, 1);
+	nfs4_init_sequence(&data->c_arg.seq_args, &data->c_res.seq_res, 1,
+				data->is_recover);
 	kref_get(&data->kref);
 	data->rpc_done = false;
 	data->rpc_status = 0;
 	data->timestamp = jiffies;
-	if (data->is_recover)
-		nfs4_set_sequence_privileged(&data->c_arg.seq_args);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -2350,16 +2345,14 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	};
 	int status;
 
-	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
+	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1, isrecover);
 	kref_get(&data->kref);
 	data->rpc_done = false;
 	data->rpc_status = 0;
 	data->cancelled = false;
 	data->is_recover = false;
-	if (isrecover) {
-		nfs4_set_sequence_privileged(&o_arg->seq_args);
+	if (isrecover)
 		data->is_recover = true;
-	}
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -3393,7 +3386,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
-	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 1);
+	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 1, 0);
 	calldata->inode = state->inode;
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
@@ -4273,7 +4266,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct dentry *dentr
 
 	res->server = NFS_SB(dentry->d_sb);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
-	nfs4_init_sequence(&args->seq_args, &res->seq_res, 1);
+	nfs4_init_sequence(&args->seq_args, &res->seq_res, 1, 0);
 
 	nfs_fattr_init(res->dir_attr);
 
@@ -4319,7 +4312,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg,
 		nfs4_inode_return_delegation(new_inode);
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
 	res->server = NFS_SB(old_dentry->d_sb);
-	nfs4_init_sequence(&arg->seq_args, &res->seq_res, 1);
+	nfs4_init_sequence(&arg->seq_args, &res->seq_res, 1, 0);
 }
 
 static void nfs4_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
@@ -4895,7 +4888,7 @@ static void nfs4_proc_read_setup(struct nfs_pgio_header *hdr,
 	if (!hdr->pgio_done_cb)
 		hdr->pgio_done_cb = nfs4_read_done_cb;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
-	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 0);
+	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 0, 0);
 }
 
 static int nfs4_proc_pgio_rpc_prepare(struct rpc_task *task,
@@ -4996,7 +4989,7 @@ static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
 	hdr->timestamp   = jiffies;
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
-	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 1);
+	nfs4_init_sequence(&hdr->args.seq_args, &hdr->res.seq_res, 1, 0);
 	nfs4_state_protect_write(server->nfs_client, clnt, msg, hdr);
 }
 
@@ -5037,7 +5030,7 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 		data->commit_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, 0);
 	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_COMMIT, clnt, msg);
 }
 
@@ -5976,7 +5969,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, 0);
 
 	nfs4_state_protect(server->nfs_client,
 			NFS_SP4_MACH_CRED_CLEANUP,
@@ -6251,7 +6244,7 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1, 0);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
@@ -6513,14 +6506,14 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		return -ENOMEM;
 	if (IS_SETLKW(cmd))
 		data->arg.block = 1;
-	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1,
+				recovery_type > NFS_LOCK_NEW);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
 	if (recovery_type > NFS_LOCK_NEW) {
 		if (recovery_type == NFS_LOCK_RECLAIM)
 			data->arg.reclaim = NFS_LOCK_RECLAIM;
-		nfs4_set_sequence_privileged(&data->arg.seq_args);
 	} else
 		data->arg.new_lock = 1;
 	task = rpc_run_task(&task_setup_data);
@@ -6915,7 +6908,7 @@ nfs4_release_lockowner(struct nfs_server *server, struct nfs4_lock_state *lsp)
 
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0, 0);
 	rpc_call_async(server->client, &msg, 0, &nfs4_release_lockowner_ops, data);
 }
 
@@ -7111,8 +7104,7 @@ static int _nfs40_proc_get_locations(struct inode *inode,
 	locations->server = server;
 	locations->nlocations = 0;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
 	status = nfs4_call_sync_sequence(clnt, server, &msg,
 					&args.seq_args, &res.seq_res);
 	if (status)
@@ -7165,8 +7157,7 @@ static int _nfs41_proc_get_locations(struct inode *inode,
 	locations->server = server;
 	locations->nlocations = 0;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
 	status = nfs4_call_sync_sequence(clnt, server, &msg,
 					&args.seq_args, &res.seq_res);
 	if (status == NFS4_OK &&
@@ -7253,8 +7244,7 @@ static int _nfs40_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
 	if (res.fh == NULL)
 		return -ENOMEM;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
 	status = nfs4_call_sync_sequence(clnt, server, &msg,
 						&args.seq_args, &res.seq_res);
 	nfs_free_fhandle(res.fh);
@@ -7295,8 +7285,7 @@ static int _nfs41_proc_fsid_present(struct inode *inode, struct rpc_cred *cred)
 	if (res.fh == NULL)
 		return -ENOMEM;
 
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
 	status = nfs4_call_sync_sequence(clnt, server, &msg,
 						&args.seq_args, &res.seq_res);
 	nfs_free_fhandle(res.fh);
@@ -8074,8 +8063,7 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	};
 	int status;
 
-	nfs4_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
-	nfs4_set_sequence_privileged(&args.la_seq_args);
+	nfs4_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0, 1);
 	task = rpc_run_task(&task_setup);
 
 	if (IS_ERR(task))
@@ -8412,10 +8400,8 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 	calldata = kzalloc(sizeof(*calldata), GFP_NOFS);
 	if (calldata == NULL)
 		goto out_put_clp;
-	nfs4_init_sequence(&calldata->args, &calldata->res, 0);
+	nfs4_init_sequence(&calldata->args, &calldata->res, 0, is_privileged);
 	nfs4_sequence_attach_slot(&calldata->args, &calldata->res, slot);
-	if (is_privileged)
-		nfs4_set_sequence_privileged(&calldata->args);
 	msg.rpc_argp = &calldata->args;
 	msg.rpc_resp = &calldata->res;
 	calldata->clp = clp;
@@ -8567,8 +8553,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 	calldata->clp = clp;
 	calldata->arg.one_fs = 0;
 
-	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 0);
-	nfs4_set_sequence_privileged(&calldata->arg.seq_args);
+	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 0, 1);
 	msg.rpc_argp = &calldata->arg;
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
@@ -8804,7 +8789,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
-	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
+	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0, 0);
 
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
@@ -8931,7 +8916,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool sync)
 		}
 		task_setup_data.flags |= RPC_TASK_ASYNC;
 	}
-	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
+	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -9078,7 +9063,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		}
 		task_setup_data.flags = RPC_TASK_ASYNC;
 	}
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, 0);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -9258,8 +9243,7 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 		&rpc_client, &msg);
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
-	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
-	nfs4_set_sequence_privileged(&args.seq_args);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0, 1);
 	status = nfs4_call_sync_sequence(rpc_client, server, &msg,
 			&args.seq_args, &res.seq_res);
 	if (status != NFS_OK) {
@@ -9382,10 +9366,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
-	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
-	if (privileged)
-		nfs4_set_sequence_privileged(&data->args.seq_args);
-
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, privileged);
 	return rpc_run_task(&task_setup);
 }
 
-- 
2.17.0

