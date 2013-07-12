Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f182.google.com ([209.85.160.182]:45289 "EHLO
	mail-gh0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964825Ab3GLQlB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:41:01 -0400
Received: by mail-gh0-f182.google.com with SMTP id z15so3273998ghb.27
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:41:00 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id s65sm69003872yhs.14.2013.07.12.09.32.46
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:46 -0700 (PDT)
Subject: [PATCH v1 09/19] NFS: Add a "struct nfs_server *" argument to
 nfs4_sequence_done()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:45 -0400
Message-ID: <20130712163245.1444.48096.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4.1, a session slot table reference is passed to
nfs4_sequence_done().

For NFSv4.0, transport state is managed in the nfs_client that owns
this nfs_server.  The nfs_server struct must be passed to
nfs4_sequence_done() to make it available to the functions dealing
with transport blocking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0c1fa13..20768e8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -553,8 +553,9 @@ out_retry:
 	return 0;
 }
 
-static int nfs4_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
+static int nfs4_sequence_done(const struct nfs_server *server,
+			      struct rpc_task *task,
+			      struct nfs4_sequence_res *res)
 {
 	if (res->sr_slot == NULL)
 		return 1;
@@ -726,8 +727,9 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 	return 0;
 }
 
-static int nfs4_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
+static int nfs4_sequence_done(const struct nfs_server *server,
+			      struct rpc_task *task,
+			      struct nfs4_sequence_res *res)
 {
 	return 1;
 }
@@ -745,7 +747,7 @@ static void nfs40_call_sync_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
 
-	nfs4_sequence_done(task, data->seq_res);
+	nfs4_sequence_done(data->seq_server, task, data->seq_res);
 }
 
 static const struct rpc_call_ops nfs40_call_sync_ops = {
@@ -1622,7 +1624,7 @@ unlock_no_action:
 out_no_action:
 	task->tk_action = NULL;
 out_wait:
-	nfs4_sequence_done(task, &data->o_res.seq_res);
+	nfs4_sequence_done(data->o_arg.server, task, &data->o_res.seq_res);
 }
 
 static void nfs4_open_done(struct rpc_task *task, void *calldata)
@@ -1631,7 +1633,7 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 
 	data->rpc_status = task->tk_status;
 
-	if (!nfs4_sequence_done(task, &data->o_res.seq_res))
+	if (!nfs4_sequence_done(data->o_arg.server, task, &data->o_res.seq_res))
 		return;
 
 	if (task->tk_status == 0) {
@@ -2294,7 +2296,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 	struct nfs_server *server = NFS_SERVER(calldata->inode);
 
 	dprintk("%s: begin!\n", __func__);
-	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
+	if (!nfs4_sequence_done(server, task, &calldata->res.seq_res))
 		return;
         /* hmm. we are done with the inode, and in the process of freeing
 	 * the state_owner. we keep this around to process errors
@@ -2381,7 +2383,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 out_no_action:
 	task->tk_action = NULL;
 out_wait:
-	nfs4_sequence_done(task, &calldata->res.seq_res);
+	nfs4_sequence_done(NFS_SERVER(inode), task, &calldata->res.seq_res);
 }
 
 static const struct rpc_call_ops nfs4_close_ops = {
@@ -3149,7 +3151,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
-	if (!nfs4_sequence_done(task, &res->seq_res))
+	if (!nfs4_sequence_done(res->server, task, &res->seq_res))
 		return 0;
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
@@ -3181,7 +3183,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 {
 	struct nfs_renameres *res = task->tk_msg.rpc_resp;
 
-	if (!nfs4_sequence_done(task, &res->seq_res))
+	if (!nfs4_sequence_done(res->server, task, &res->seq_res))
 		return 0;
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
@@ -3705,10 +3707,11 @@ static bool nfs4_read_stateid_changed(struct rpc_task *task,
 
 static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
+	struct nfs_server *server = NFS_SERVER(data->header->inode);
 
 	dprintk("--> %s\n", __func__);
 
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
+	if (!nfs4_sequence_done(server, task, &data->res.seq_res))
 		return -EAGAIN;
 	if (nfs4_read_stateid_changed(task, &data->args))
 		return -EAGAIN;
@@ -3753,7 +3756,6 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 static bool nfs4_write_stateid_changed(struct rpc_task *task,
 		struct nfs_writeargs *args)
 {
-
 	if (!nfs4_error_stateid_expired(task->tk_status) ||
 		nfs4_stateid_is_current(&args->stateid,
 				args->context,
@@ -3766,7 +3768,9 @@ static bool nfs4_write_stateid_changed(struct rpc_task *task,
 
 static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
+	struct nfs_server *server = NFS_SERVER(data->header->inode);
+
+	if (!nfs4_sequence_done(server, task, &data->res.seq_res))
 		return -EAGAIN;
 	if (nfs4_write_stateid_changed(task, &data->args))
 		return -EAGAIN;
@@ -3839,7 +3843,9 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *da
 
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_commit_data *data)
 {
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
+	struct nfs_server *server = NFS_SERVER(data->inode);
+
+	if (!nfs4_sequence_done(server, task, &data->res.seq_res))
 		return -EAGAIN;
 	return data->commit_done_cb(task, data);
 }
@@ -4439,7 +4445,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
 
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
+	if (!nfs4_sequence_done(data->res.server, task, &data->res.seq_res))
 		return;
 
 	switch (task->tk_status) {
@@ -4690,7 +4696,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
 
-	if (!nfs4_sequence_done(task, &calldata->res.seq_res))
+	if (!nfs4_sequence_done(calldata->server, task, &calldata->res.seq_res))
 		return;
 	switch (task->tk_status) {
 		case 0:
@@ -4730,7 +4736,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 out_no_action:
 	task->tk_action = NULL;
 out_wait:
-	nfs4_sequence_done(task, &calldata->res.seq_res);
+	nfs4_sequence_done(calldata->server, task, &calldata->res.seq_res);
 }
 
 static const struct rpc_call_ops nfs4_locku_ops = {
@@ -4905,7 +4911,7 @@ out_release_open_seqid:
 out_release_lock_seqid:
 	nfs_release_seqid(data->arg.lock_seqid);
 out_wait:
-	nfs4_sequence_done(task, &data->res.seq_res);
+	nfs4_sequence_done(data->server, task, &data->res.seq_res);
 	dprintk("%s: done!, ret = %d\n", __func__, data->rpc_status);
 }
 
@@ -4915,7 +4921,7 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 
-	if (!nfs4_sequence_done(task, &data->res.seq_res))
+	if (!nfs4_sequence_done(data->server, task, &data->res.seq_res))
 		return;
 
 	data->rpc_status = task->tk_status;

