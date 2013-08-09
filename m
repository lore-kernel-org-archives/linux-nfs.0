Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f182.google.com ([209.85.160.182]:42575 "EHLO
	mail-gh0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQsU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:20 -0400
Received: by mail-gh0-f182.google.com with SMTP id z15so1294786ghb.41
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:20 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id f67sm20679890yhh.9.2013.08.09.09.48.19
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:19 -0700 (PDT)
Subject: [PATCH v2 04/33] NFS: Common versions of sequence helper functions
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:18 -0400
Message-ID: <20130809164818.5362.28355.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4.0 will have need for this functionality when I add the ability
to block NFSv4.0 traffic before migration recovery.

I'm not really clear on why nfs4_set_sequence_privileged() gets a
generic name, but nfs41_init_sequence() gets a minor
version-specific name.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   79 +++++++++++++++++++++++------------------------------
 1 file changed, 34 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 275d17d..bc8f5d7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -453,6 +453,21 @@ struct nfs4_call_sync_data {
 	struct nfs4_sequence_res *seq_res;
 };
 
+static void nfs4_init_sequence(struct nfs4_sequence_args *args,
+			       struct nfs4_sequence_res *res, int cache_reply)
+{
+	args->sa_slot = NULL;
+	args->sa_cache_this = cache_reply;
+	args->sa_privileged = 0;
+
+	res->sr_slot = NULL;
+}
+
+static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
+{
+	args->sa_privileged = 1;
+}
+
 #if defined(CONFIG_NFS_V4_1)
 
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
@@ -600,22 +615,6 @@ static int nfs4_sequence_done(struct rpc_task *task,
 	return nfs41_sequence_done(task, res);
 }
 
-static void nfs41_init_sequence(struct nfs4_sequence_args *args,
-		struct nfs4_sequence_res *res, int cache_reply)
-{
-	args->sa_slot = NULL;
-	args->sa_cache_this = 0;
-	args->sa_privileged = 0;
-	if (cache_reply)
-		args->sa_cache_this = 1;
-	res->sr_slot = NULL;
-}
-
-static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
-{
-	args->sa_privileged = 1;
-}
-
 int nfs41_setup_sequence(struct nfs4_session *session,
 				struct nfs4_sequence_args *args,
 				struct nfs4_sequence_res *res,
@@ -755,16 +754,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 }
 
 #else
-static
-void nfs41_init_sequence(struct nfs4_sequence_args *args,
-		struct nfs4_sequence_res *res, int cache_reply)
-{
-}
-
-static void nfs4_set_sequence_privileged(struct nfs4_sequence_args *args)
-{
-}
-
 static int nfs4_setup_sequence(const struct nfs_server *server,
 			       struct nfs4_sequence_args *args,
 			       struct nfs4_sequence_res *res,
@@ -799,7 +788,7 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs4_sequence_res *res,
 		   int cache_reply)
 {
-	nfs41_init_sequence(args, res, cache_reply);
+	nfs4_init_sequence(args, res, cache_reply);
 	return server->nfs_client->cl_mvops->call_sync(clnt, server, msg,
 						args, res);
 }
@@ -1750,7 +1739,7 @@ static int nfs4_run_open_task(struct nfs4_opendata *data, int isrecover)
 	};
 	int status;
 
-	nfs41_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
+	nfs4_init_sequence(&o_arg->seq_args, &o_res->seq_res, 1);
 	kref_get(&data->kref);
 	data->rpc_done = 0;
 	data->rpc_status = 0;
@@ -2522,7 +2511,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
 		goto out;
-	nfs41_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 1);
+	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 1);
 	calldata->inode = state->inode;
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
@@ -3278,7 +3267,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 	res->server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_REMOVE];
-	nfs41_init_sequence(&args->seq_args, &res->seq_res, 1);
+	nfs4_init_sequence(&args->seq_args, &res->seq_res, 1);
 
 	nfs_fattr_init(res->dir_attr);
 }
@@ -3311,7 +3300,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_RENAME];
 	res->server = server;
-	nfs41_init_sequence(&arg->seq_args, &res->seq_res, 1);
+	nfs4_init_sequence(&arg->seq_args, &res->seq_res, 1);
 }
 
 static void nfs4_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
@@ -3912,7 +3901,7 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 	data->timestamp   = jiffies;
 	data->read_done_cb = nfs4_read_done_cb;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_READ];
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 }
 
 static void nfs4_proc_read_rpc_prepare(struct rpc_task *task, struct nfs_read_data *data)
@@ -3995,7 +3984,7 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 	data->timestamp   = jiffies;
 
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_WRITE];
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
 static void nfs4_proc_write_rpc_prepare(struct rpc_task *task, struct nfs_write_data *data)
@@ -4043,7 +4032,7 @@ static void nfs4_proc_commit_setup(struct nfs_commit_data *data, struct rpc_mess
 		data->commit_done_cb = nfs4_commit_done_cb;
 	data->res.server = server;
 	msg->rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_COMMIT];
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 }
 
 struct nfs4_renewdata {
@@ -4845,7 +4834,7 @@ static int _nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, co
 	data = kzalloc(sizeof(*data), GFP_NOFS);
 	if (data == NULL)
 		return -ENOMEM;
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	data->args.fhandle = &data->fh;
 	data->args.stateid = &data->stateid;
 	data->args.bitmask = server->cache_consistency_bitmask;
@@ -5108,7 +5097,7 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		return ERR_PTR(-ENOMEM);
 	}
 
-	nfs41_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
@@ -5343,7 +5332,7 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 		return -ENOMEM;
 	if (IS_SETLKW(cmd))
 		data->arg.block = 1;
-	nfs41_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->arg.seq_args, &data->res.seq_res, 1);
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
@@ -6165,7 +6154,7 @@ int nfs4_proc_get_lease_time(struct nfs_client *clp, struct nfs_fsinfo *fsinfo)
 	};
 	int status;
 
-	nfs41_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
+	nfs4_init_sequence(&args.la_seq_args, &res.lr_seq_res, 0);
 	nfs4_set_sequence_privileged(&args.la_seq_args);
 	dprintk("--> %s\n", __func__);
 	task = rpc_run_task(&task_setup);
@@ -6468,7 +6457,7 @@ static struct rpc_task *_nfs41_proc_sequence(struct nfs_client *clp,
 		nfs_put_client(clp);
 		return ERR_PTR(-ENOMEM);
 	}
-	nfs41_init_sequence(&calldata->args, &calldata->res, 0);
+	nfs4_init_sequence(&calldata->args, &calldata->res, 0);
 	if (is_privileged)
 		nfs4_set_sequence_privileged(&calldata->args);
 	msg.rpc_argp = &calldata->args;
@@ -6610,7 +6599,7 @@ static int nfs41_proc_reclaim_complete(struct nfs_client *clp,
 	calldata->clp = clp;
 	calldata->arg.one_fs = 0;
 
-	nfs41_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 0);
+	nfs4_init_sequence(&calldata->arg.seq_args, &calldata->res.seq_res, 0);
 	nfs4_set_sequence_privileged(&calldata->arg.seq_args);
 	msg.rpc_argp = &calldata->arg;
 	msg.rpc_resp = &calldata->res;
@@ -6801,7 +6790,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
 
 	lgp->res.layoutp = &lgp->args.layout;
 	lgp->res.seq_res.sr_slot = NULL;
-	nfs41_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
+	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0);
 
 	/* nfs4_layoutget_release calls pnfs_put_layout_hdr */
 	pnfs_get_layout_hdr(NFS_I(inode)->layout);
@@ -6892,7 +6881,7 @@ int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp)
 	int status;
 
 	dprintk("--> %s\n", __func__);
-	nfs41_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
+	nfs4_init_sequence(&lrp->args.seq_args, &lrp->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -7073,7 +7062,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 		data->args.lastbytewritten,
 		data->args.inode->i_ino);
 
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1);
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
@@ -7186,7 +7175,7 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 	};
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
-	nfs41_init_sequence(&args.seq_args, &res.seq_res, 0);
+	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
 	nfs4_set_sequence_privileged(&args.seq_args);
 	status = nfs4_call_sync_sequence(server->client, server, &msg,
 			&args.seq_args, &res.seq_res);
@@ -7291,7 +7280,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
-	nfs41_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
+	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 0);
 	if (privileged)
 		nfs4_set_sequence_privileged(&data->args.seq_args);
 

