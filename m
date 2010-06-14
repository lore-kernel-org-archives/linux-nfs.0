From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/15] NFSv4.1: Make nfs4_setup_sequence take a nfs_server argument
Date: Mon, 14 Jun 2010 17:51:30 -0400
Message-ID: <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53421 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756757Ab0FNVvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:44 -0400
In-Reply-To: <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In anticipation of the day when we have per-filesystem sessions, and also
in order to allow the session to change in the event of a filesystem
migration event.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h  |   14 ++++++++++++--
 fs/nfs/nfs4proc.c |   49 +++++++++++++++++++++++++++----------------------
 fs/nfs/read.c     |    2 +-
 fs/nfs/unlink.c   |    2 +-
 fs/nfs/write.c    |    4 ++--
 5 files changed, 43 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c538c61..9c0aa81 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -223,7 +223,12 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 extern struct nfs4_state_recovery_ops *nfs4_reboot_recovery_ops[];
 extern struct nfs4_state_recovery_ops *nfs4_nograce_recovery_ops[];
 #if defined(CONFIG_NFS_V4_1)
-extern int nfs4_setup_sequence(struct nfs_client *clp,
+static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
+{
+	return server->nfs_client->cl_session;
+}
+
+extern int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task);
 extern void nfs4_destroy_session(struct nfs4_session *session);
@@ -234,7 +239,12 @@ extern int nfs4_init_session(struct nfs_server *server);
 extern int nfs4_proc_get_lease_time(struct nfs_client *clp,
 		struct nfs_fsinfo *fsinfo);
 #else /* CONFIG_NFS_v4_1 */
-static inline int nfs4_setup_sequence(struct nfs_client *clp,
+static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
+{
+	return NULL;
+}
+
+static inline int nfs4_setup_sequence(const struct nfs_server *server,
 		struct nfs4_sequence_args *args, struct nfs4_sequence_res *res,
 		int cache_reply, struct rpc_task *task)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ae2651e..94377a5 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -531,20 +531,25 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	return 0;
 }
 
-int nfs4_setup_sequence(struct nfs_client *clp,
+int nfs4_setup_sequence(const struct nfs_server *server,
 			struct nfs4_sequence_args *args,
 			struct nfs4_sequence_res *res,
 			int cache_reply,
 			struct rpc_task *task)
 {
+	struct nfs4_session *session = nfs4_get_session(server);
 	int ret = 0;
 
+	if (session == NULL) {
+		args->sa_session = NULL;
+		res->sr_session = NULL;
+		goto out;
+	}
+
 	dprintk("--> %s clp %p session %p sr_slotid %d\n",
-		__func__, clp, clp->cl_session, res->sr_slotid);
+		__func__, session->clp, session, res->sr_slotid);
 
-	if (!nfs4_has_session(clp))
-		goto out;
-	ret = nfs41_setup_sequence(clp->cl_session, args, res, cache_reply,
+	ret = nfs41_setup_sequence(session, args, res, cache_reply,
 				   task);
 out:
 	dprintk("<-- %s status=%d\n", __func__, ret);
@@ -552,7 +557,7 @@ out:
 }
 
 struct nfs41_call_sync_data {
-	struct nfs_client *clp;
+	const struct nfs_server *seq_server;
 	struct nfs4_sequence_args *seq_args;
 	struct nfs4_sequence_res *seq_res;
 	int cache_reply;
@@ -562,9 +567,9 @@ static void nfs41_call_sync_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs41_call_sync_data *data = calldata;
 
-	dprintk("--> %s data->clp->cl_session %p\n", __func__,
-		data->clp->cl_session);
-	if (nfs4_setup_sequence(data->clp, data->seq_args,
+	dprintk("--> %s data->seq_server %p\n", __func__, data->seq_server);
+
+	if (nfs4_setup_sequence(data->seq_server, data->seq_args,
 				data->seq_res, data->cache_reply, task))
 		return;
 	rpc_call_start(task);
@@ -593,8 +598,7 @@ struct rpc_call_ops nfs41_call_priv_sync_ops = {
 	.rpc_call_done = nfs41_call_sync_done,
 };
 
-static int nfs4_call_sync_sequence(struct nfs_client *clp,
-				   struct rpc_clnt *clnt,
+static int nfs4_call_sync_sequence(struct nfs_server *server,
 				   struct rpc_message *msg,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
@@ -604,13 +608,13 @@ static int nfs4_call_sync_sequence(struct nfs_client *clp,
 	int ret;
 	struct rpc_task *task;
 	struct nfs41_call_sync_data data = {
-		.clp = clp,
+		.seq_server = server,
 		.seq_args = args,
 		.seq_res = res,
 		.cache_reply = cache_reply,
 	};
 	struct rpc_task_setup task_setup = {
-		.rpc_client = clnt,
+		.rpc_client = server->client,
 		.rpc_message = msg,
 		.callback_ops = &nfs41_call_sync_ops,
 		.callback_data = &data
@@ -635,8 +639,7 @@ int _nfs4_call_sync_session(struct nfs_server *server,
 			    struct nfs4_sequence_res *res,
 			    int cache_reply)
 {
-	return nfs4_call_sync_sequence(server->nfs_client, server->client,
-				       msg, args, res, cache_reply, 0);
+	return nfs4_call_sync_sequence(server, msg, args, res, cache_reply, 0);
 }
 
 #endif /* CONFIG_NFS_V4_1 */
@@ -1355,7 +1358,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		nfs_copy_fh(&data->o_res.fh, data->o_arg.fh);
 	}
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->o_arg.server->nfs_client,
+	if (nfs4_setup_sequence(data->o_arg.server,
 				&data->o_arg.seq_args,
 				&data->o_res.seq_res, 1, task))
 		return;
@@ -1896,7 +1899,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 
 	nfs_fattr_init(calldata->res.fattr);
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence((NFS_SERVER(calldata->inode))->nfs_client,
+	if (nfs4_setup_sequence(NFS_SERVER(calldata->inode),
 				&calldata->arg.seq_args, &calldata->res.seq_res,
 				1, task))
 		return;
@@ -3660,7 +3663,7 @@ static void nfs4_delegreturn_prepare(struct rpc_task *task, void *data)
 
 	d_data = (struct nfs4_delegreturndata *)data;
 
-	if (nfs4_setup_sequence(d_data->res.server->nfs_client,
+	if (nfs4_setup_sequence(d_data->res.server,
 				&d_data->args.seq_args,
 				&d_data->res.seq_res, 1, task))
 		return;
@@ -3915,7 +3918,7 @@ static void nfs4_locku_prepare(struct rpc_task *task, void *data)
 		return;
 	}
 	calldata->timestamp = jiffies;
-	if (nfs4_setup_sequence(calldata->server->nfs_client,
+	if (nfs4_setup_sequence(calldata->server,
 				&calldata->arg.seq_args,
 				&calldata->res.seq_res, 1, task))
 		return;
@@ -4070,7 +4073,8 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 	} else
 		data->arg.new_lock_owner = 0;
 	data->timestamp = jiffies;
-	if (nfs4_setup_sequence(data->server->nfs_client, &data->arg.seq_args,
+	if (nfs4_setup_sequence(data->server,
+				&data->arg.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
@@ -5110,7 +5114,7 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
 	args = task->tk_msg.rpc_argp;
 	res = task->tk_msg.rpc_resp;
 
-	if (nfs4_setup_sequence(clp, args, res, 0, task))
+	if (nfs41_setup_sequence(clp->cl_session, args, res, 0, task))
 		return;
 	rpc_call_start(task);
 }
@@ -5194,7 +5198,8 @@ static void nfs4_reclaim_complete_prepare(struct rpc_task *task, void *data)
 	struct nfs4_reclaim_complete_data *calldata = data;
 
 	rpc_task_set_priority(task, RPC_PRIORITY_PRIVILEGED);
-	if (nfs4_setup_sequence(calldata->clp, &calldata->arg.seq_args,
+	if (nfs41_setup_sequence(calldata->clp->cl_session,
+				&calldata->arg.seq_args,
 				&calldata->res.seq_res, 0, task))
 		return;
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 6e2b06e..5a33a92 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -410,7 +410,7 @@ void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
 
-	if (nfs4_setup_sequence(NFS_SERVER(data->inode)->nfs_client,
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
 				&data->args.seq_args, &data->res.seq_res,
 				0, task))
 		return;
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index a2242af..2f84ada 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -110,7 +110,7 @@ void nfs_unlink_prepare(struct rpc_task *task, void *calldata)
 	struct nfs_unlinkdata *data = calldata;
 	struct nfs_server *server = NFS_SERVER(data->dir);
 
-	if (nfs4_setup_sequence(server->nfs_client, &data->args.seq_args,
+	if (nfs4_setup_sequence(server, &data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 91679e2..03df228 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1036,9 +1036,9 @@ out:
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
-	struct nfs_client *clp = (NFS_SERVER(data->inode))->nfs_client;
 
-	if (nfs4_setup_sequence(clp, &data->args.seq_args,
+	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
+				&data->args.seq_args,
 				&data->res.seq_res, 1, task))
 		return;
 	rpc_call_start(task);
-- 
1.7.0.1

