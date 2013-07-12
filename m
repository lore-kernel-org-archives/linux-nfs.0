Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f170.google.com ([209.85.161.170]:45637 "EHLO
	mail-gg0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965059Ab3GLQcj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:32:39 -0400
Received: by mail-gg0-f170.google.com with SMTP id s5so3184393ggc.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:32:38 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id y70sm68997822yhe.15.2013.07.12.09.32.37
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:38 -0700 (PDT)
Subject: [PATCH v1 08/19] NFS: Use RPC callouts to start NFSv4.0 synchronous
 requests
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:37 -0400
Message-ID: <20130712163237.1444.49030.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for adding a transport blocking mechanism for
NFSv4.0, replace _nfs4_call_sync() with a common function that
handles synchronous RPC calls for all minor versions using RPC
callouts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |    6 +-----
 fs/nfs/nfs4proc.c |   47 ++++++++++++++++++++++++++++++++++-------------
 2 files changed, 35 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 419fc87..ae05978 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -38,17 +38,13 @@ struct nfs4_minor_version_ops {
 	u32	minor_version;
 	unsigned init_caps;
 
-	int	(*call_sync)(struct rpc_clnt *clnt,
-			struct nfs_server *server,
-			struct rpc_message *msg,
-			struct nfs4_sequence_args *args,
-			struct nfs4_sequence_res *res);
 	bool	(*match_stateid)(const nfs4_stateid *,
 			const nfs4_stateid *);
 	int	(*find_root_sec)(struct nfs_server *, struct nfs_fh *,
 			struct nfs_fsinfo *);
 	int	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
+	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5913e1d..0c1fa13 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -397,8 +397,6 @@ struct nfs4_call_sync_data {
 	struct nfs4_sequence_res *seq_res;
 };
 
-#if defined(CONFIG_NFS_V4_1)
-
 static int nfs4_run_rpc_task(struct rpc_clnt *clnt,
 			     struct rpc_message *msg,
 			     struct rpc_task_setup *task_setup)
@@ -416,6 +414,8 @@ static int nfs4_run_rpc_task(struct rpc_clnt *clnt,
 	return ret;
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
 static void nfs41_sequence_free_slot(struct nfs4_sequence_res *res)
 {
 	struct nfs4_session *session;
@@ -733,16 +733,26 @@ static int nfs4_sequence_done(struct rpc_task *task,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-static
-int _nfs4_call_sync(struct rpc_clnt *clnt,
-		    struct nfs_server *server,
-		    struct rpc_message *msg,
-		    struct nfs4_sequence_args *args,
-		    struct nfs4_sequence_res *res)
+static void nfs40_call_sync_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_call_sync_data *data = calldata;
+	const struct nfs_server *server = data->seq_server;
+
+	nfs4_setup_sequence(server, data->seq_args, data->seq_res, task);
+}
+
+static void nfs40_call_sync_done(struct rpc_task *task, void *calldata)
 {
-	return rpc_call_sync(clnt, msg, 0);
+	struct nfs4_call_sync_data *data = calldata;
+
+	nfs4_sequence_done(task, data->seq_res);
 }
 
+static const struct rpc_call_ops nfs40_call_sync_ops = {
+	.rpc_call_prepare = nfs40_call_sync_prepare,
+	.rpc_call_done = nfs40_call_sync_done,
+};
+
 static
 int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs_server *server,
@@ -751,9 +761,20 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 		   struct nfs4_sequence_res *res,
 		   int cache_reply)
 {
+	struct nfs4_call_sync_data data = {
+		.seq_server	= server,
+		.seq_args	= args,
+		.seq_res	= res,
+	};
+	struct rpc_task_setup task_setup = {
+		.rpc_client	= clnt,
+		.rpc_message	= msg,
+		.callback_ops	= server->nfs_client->cl_mvops->call_sync_ops,
+		.callback_data	= &data,
+	};
+
 	nfs41_init_sequence(args, res, cache_reply);
-	return server->nfs_client->cl_mvops->call_sync(clnt, server, msg,
-						args, res);
+	return nfs4_run_rpc_task(clnt, msg, &task_setup);
 }
 
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
@@ -6996,10 +7017,10 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 		| NFS_CAP_ATOMIC_OPEN
 		| NFS_CAP_CHANGE_ATTR
 		| NFS_CAP_POSIX_LOCK,
-	.call_sync = _nfs4_call_sync,
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
+	.call_sync_ops = &nfs40_call_sync_ops,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
@@ -7015,10 +7036,10 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 		| NFS_CAP_POSIX_LOCK
 		| NFS_CAP_STATEID_NFSV41
 		| NFS_CAP_ATOMIC_OPEN_V1,
-	.call_sync = nfs4_call_sync_sequence,
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
+	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,

