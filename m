From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 03/19] SQUASHME: pnfs-submit: optionally pass nfs_client to nfs4_async_handle_error
Date: Thu, 17 Jun 2010 10:48:41 -0400
Message-ID: <1276786121-11720-1-git-send-email-bhalevy@panasas.com>
References: <4C1A3570.5030709@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50315 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755999Ab0FQOsf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 10:48:35 -0400
In-Reply-To: <4C1A3570.5030709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To overrise the server->client with the data server's nfs client.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4proc.c |   22 ++++++----------------
 1 files changed, 6 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8ab30d5..c4f707f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -70,7 +70,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, struct nfs4_session *ds_session);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, struct nfs_client *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
@@ -3165,7 +3165,6 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
 	struct nfs_client *client = mds_svr->nfs_client;
-	struct nfs4_session *ds_session = NULL;
 
 	dprintk("--> %s\n", __func__);
 
@@ -3176,7 +3175,6 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	if (data->fldata.ds_nfs_client) {
 		dprintk("%s DS read\n", __func__);
 		client = data->fldata.ds_nfs_client;
-		ds_session = data->fldata.ds_nfs_client->cl_session;
 	}
 
 	nfs41_sequence_done(&data->res.seq_res);
@@ -3187,7 +3185,7 @@ static int pnfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
 	   like in nfs4_read_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL, ds_session) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
 		nfs_restart_rpc(task, client);
 		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
 		return -EAGAIN;
@@ -3209,7 +3207,6 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
 	struct nfs_client *client = mds_svr->nfs_client;
-	struct nfs4_session *ds_session = NULL;
 
 	/* restore original count after retry? */
 	if (data->pdata.orig_count) {
@@ -3225,7 +3222,6 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	if (data->fldata.ds_nfs_client) {
 		dprintk("%s DS write\n", __func__);
 		client = data->fldata.ds_nfs_client;
-		ds_session = client->cl_session;
 	}
 
 	nfs41_sequence_done(&data->res.seq_res);
@@ -3235,7 +3231,7 @@ static int pnfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 	*/
 	/* FIXME: pass data->args.context->state to nfs4_async_handle_error
 	   like in nfs4_write_done? */
-	if (nfs4_async_handle_error(task, mds_svr, NULL, ds_session) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
 		nfs_restart_rpc(task, client);
 		dprintk("<-- %s status= %d\n", __func__, -EAGAIN);
 		return -EAGAIN;
@@ -3269,7 +3265,6 @@ static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_server *mds_svr = NFS_SERVER(data->inode);
 	struct nfs_client *client = mds_svr->nfs_client;
-	struct nfs4_session *ds_session = mds_svr->nfs_client->cl_session;
 
 	dprintk("--> %s task->tk_status %d\n", __func__, task->tk_status);
 
@@ -3284,7 +3279,7 @@ static int pnfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 
 	nfs41_sequence_done(&data->res.seq_res);
 
-	if (nfs4_async_handle_error(task, mds_svr, NULL, ds_session) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, mds_svr, NULL, client) == -EAGAIN) {
 		nfs_restart_rpc(task, client);
 		return -EAGAIN;
 	}
@@ -3698,14 +3693,9 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state, struct nfs4_session *ds_session)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state, struct nfs_client *clp)
 {
-	struct nfs_client *clp;
-
-	/* Either server or ds_session is set */
-	if (ds_session)
-		clp = ds_session->clp;
-	else
+	if (!clp)
 		clp = server->nfs_client;
 
 	if (task->tk_status >= 0)
-- 
1.6.4.4

