Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19473 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753264AbdAKSzK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 13:55:10 -0500
From: <Anna.Schumaker@Netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 03/11] NFS: Change nfs4_setup_sequence() to take an nfs_client structure
Date: Wed, 11 Jan 2017 13:54:46 -0500
Message-ID: <20170111185454.9315-4-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
References: <20170111185454.9315-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

I want to have all callers use this function, rather than calling the
NFS v4.0 and v4.1 versions directly.  This includes pNFS, which only has
access to the nfs_client structure in some places.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d1fde35bfd7e..a2e5c6f39182 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -948,16 +948,16 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 }
 EXPORT_SYMBOL_GPL(nfs41_setup_sequence);
 
-static int nfs4_setup_sequence(const struct nfs_server *server,
+static int nfs4_setup_sequence(const struct nfs_client *client,
 			       struct nfs4_sequence_args *args,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	struct nfs4_session *session = nfs4_get_session(server->nfs_client);
+	struct nfs4_session *session = nfs4_get_session(client);
 	int ret = 0;
 
 	if (!session)
-		return nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
+		return nfs40_setup_sequence(client->cl_slot_tbl,
 					    args, res, task);
 
 	dprintk("--> %s clp %p session %p sr_slot %u\n",
@@ -994,13 +994,12 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 
 #else	/* !CONFIG_NFS_V4_1 */
 
-static int nfs4_setup_sequence(const struct nfs_server *server,
+static int nfs4_setup_sequence(const struct nfs_client *client,
 			       struct nfs4_sequence_args *args,
 			       struct nfs4_sequence_res *res,
 			       struct rpc_task *task)
 {
-	return nfs40_setup_sequence(server->nfs_client->cl_slot_tbl,
-				    args, res, task);
+	return nfs40_setup_sequence(client->cl_slot_tbl, args, res, task);
 }
 
 static int nfs4_sequence_process(struct rpc_task *task, struct nfs4_sequence_res *res)
@@ -1026,7 +1025,7 @@ EXPORT_SYMBOL_GPL(nfs4_sequence_done);
 static void nfs40_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_call_sync_data *data = calldata;
-	nfs4_setup_sequence(data->seq_server,
+	nfs4_setup_sequence(data->seq_server->nfs_client,
 				data->seq_args, data->seq_res, task);
 }
 
@@ -2171,7 +2170,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->o_arg.server,
+	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
 				&data->o_arg.seq_args,
 				&data->o_res.seq_res,
 				task) != 0)
@@ -3230,7 +3229,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	else if (calldata->arg.bitmask == NULL)
 		calldata->res.fattr = NULL;
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(NFS_SERVER(inode),
+	if (nfs4_setup_sequence(NFS_SERVER(inode)->nfs_client,
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res,
 				task) != 0)
@@ -4109,7 +4108,7 @@ static void nfs4_proc_unlink_setup(struct rpc_message *msg, struct inode *dir)
 
 static void nfs4_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlinkdata *data)
 {
-	nfs4_setup_sequence(NFS_SB(data->dentry->d_sb),
+	nfs4_setup_sequence(NFS_SB(data->dentry->d_sb)->nfs_client,
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
@@ -4142,7 +4141,7 @@ static void nfs4_proc_rename_setup(struct rpc_message *msg, struct inode *dir)
 
 static void nfs4_proc_rename_rpc_prepare(struct rpc_task *task, struct nfs_renamedata *data)
 {
-	nfs4_setup_sequence(NFS_SERVER(data->old_dir),
+	nfs4_setup_sequence(NFS_SERVER(data->old_dir)->nfs_client,
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
@@ -4713,7 +4712,7 @@ static void nfs4_proc_read_setup(struct nfs_pgio_header *hdr,
 static int nfs4_proc_pgio_rpc_prepare(struct rpc_task *task,
 				      struct nfs_pgio_header *hdr)
 {
-	if (nfs4_setup_sequence(NFS_SERVER(hdr->inode),
+	if (nfs4_setup_sequence(NFS_SERVER(hdr->inode)->nfs_client,
 			&hdr->args.seq_args,
 			&hdr->res.seq_res,
 			task))
@@ -4812,7 +4811,7 @@ static void nfs4_proc_write_setup(struct nfs_pgio_header *hdr,
 
 static void nfs4_proc_commit_rpc_prepare(struct rpc_task *task, struct nfs_commit_data *data)
 {
-	nfs4_setup_sequence(NFS_SERVER(data->inode),
+	nfs4_setup_sequence(NFS_SERVER(data->inode)->nfs_client,
 			&data->args.seq_args,
 			&data->res.seq_res,
 			task);
@@ -5737,7 +5736,7 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 	if (!d_data->lr.roc && nfs4_wait_on_layoutreturn(d_data->inode, task))
 		return;
 
-	nfs4_setup_sequence(d_data->res.server,
+	nfs4_setup_sequence(d_data->res.server->nfs_client,
 			&d_data->args.seq_args,
 			&d_data->res.seq_res,
 			task);
@@ -5979,7 +5978,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		goto out_no_action;
 	}
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(calldata->server,
+	if (nfs4_setup_sequence(calldata->server->nfs_client,
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res,
 				task) != 0)
@@ -6165,7 +6164,7 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		goto out_release_open_seqid;
 	}
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->server,
+	if (nfs4_setup_sequence(data->server->nfs_client,
 				&data->arg.seq_args,
 				&data->res.seq_res,
 				task) == 0)
-- 
2.11.0

