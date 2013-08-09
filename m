Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f176.google.com ([209.85.213.176]:45186 "EHLO
	mail-ye0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968171Ab3HIQs3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:48:29 -0400
Received: by mail-ye0-f176.google.com with SMTP id q3so1301905yen.21
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:48:28 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id y70sm20672164yhe.15.2013.08.09.09.48.27
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:48:28 -0700 (PDT)
Subject: [PATCH v2 05/33] NFS: Add RPC callouts to start NFSv4.0 synchronous
 requests
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:48:27 -0400
Message-ID: <20130809164827.5362.42903.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor nfs4_call_sync_sequence() so it is used for NFSv4.0 now.
The RPC callouts will house transport blocking logic similar to
NFSv4.1 sessions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |   61 ++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 42 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 0feb238..bf2184e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -49,6 +49,7 @@ struct nfs4_minor_version_ops {
 			struct nfs_fsinfo *);
 	int	(*free_lock_state)(struct nfs_server *,
 			struct nfs4_lock_state *);
+	const struct rpc_call_ops *call_sync_ops;
 	const struct nfs4_state_recovery_ops *reboot_recovery_ops;
 	const struct nfs4_state_recovery_ops *nograce_recovery_ops;
 	const struct nfs4_state_maintenance_ops *state_renewal_ops;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index bc8f5d7..940a39e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -723,6 +723,41 @@ static const struct rpc_call_ops nfs41_call_sync_ops = {
 	.rpc_call_done = nfs41_call_sync_done,
 };
 
+#else
+static int nfs4_setup_sequence(const struct nfs_server *server,
+			       struct nfs4_sequence_args *args,
+			       struct nfs4_sequence_res *res,
+			       struct rpc_task *task)
+{
+	rpc_call_start(task);
+	return 0;
+}
+
+static int nfs4_sequence_done(struct rpc_task *task,
+			       struct nfs4_sequence_res *res)
+{
+	return 1;
+}
+#endif /* CONFIG_NFS_V4_1 */
+
+static void nfs40_call_sync_prepare(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_call_sync_data *data = calldata;
+	nfs4_setup_sequence(data->seq_server,
+				data->seq_args, data->seq_res, task);
+}
+
+static void nfs40_call_sync_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_call_sync_data *data = calldata;
+	nfs4_sequence_done(task, data->seq_res);
+}
+
+static const struct rpc_call_ops nfs40_call_sync_ops = {
+	.rpc_call_prepare = nfs40_call_sync_prepare,
+	.rpc_call_done = nfs40_call_sync_done,
+};
+
 static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 				   struct nfs_server *server,
 				   struct rpc_message *msg,
@@ -731,6 +766,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 {
 	int ret;
 	struct rpc_task *task;
+	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_call_sync_data data = {
 		.seq_server = server,
 		.seq_args = args,
@@ -739,7 +775,7 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	struct rpc_task_setup task_setup = {
 		.rpc_client = clnt,
 		.rpc_message = msg,
-		.callback_ops = &nfs41_call_sync_ops,
+		.callback_ops = clp->cl_mvops->call_sync_ops,
 		.callback_data = &data
 	};
 
@@ -753,23 +789,6 @@ static int nfs4_call_sync_sequence(struct rpc_clnt *clnt,
 	return ret;
 }
 
-#else
-static int nfs4_setup_sequence(const struct nfs_server *server,
-			       struct nfs4_sequence_args *args,
-			       struct nfs4_sequence_res *res,
-			       struct rpc_task *task)
-{
-	rpc_call_start(task);
-	return 0;
-}
-
-static int nfs4_sequence_done(struct rpc_task *task,
-			       struct nfs4_sequence_res *res)
-{
-	return 1;
-}
-#endif /* CONFIG_NFS_V4_1 */
-
 static
 int _nfs4_call_sync(struct rpc_clnt *clnt,
 		    struct nfs_server *server,
@@ -789,8 +808,7 @@ int nfs4_call_sync(struct rpc_clnt *clnt,
 		   int cache_reply)
 {
 	nfs4_init_sequence(args, res, cache_reply);
-	return server->nfs_client->cl_mvops->call_sync(clnt, server, msg,
-						args, res);
+	return nfs4_call_sync_sequence(clnt, server, msg, args, res);
 }
 
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
@@ -7413,6 +7431,7 @@ static const struct nfs4_minor_version_ops nfs_v4_0_minor_ops = {
 	.match_stateid = nfs4_match_stateid,
 	.find_root_sec = nfs4_find_root_sec,
 	.free_lock_state = nfs4_release_lockowner,
+	.call_sync_ops = &nfs40_call_sync_ops,
 	.reboot_recovery_ops = &nfs40_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs40_nograce_recovery_ops,
 	.state_renewal_ops = &nfs40_state_renewal_ops,
@@ -7431,6 +7450,7 @@ static const struct nfs4_minor_version_ops nfs_v4_1_minor_ops = {
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
+	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,
@@ -7450,6 +7470,7 @@ static const struct nfs4_minor_version_ops nfs_v4_2_minor_ops = {
 	.match_stateid = nfs41_match_stateid,
 	.find_root_sec = nfs41_find_root_sec,
 	.free_lock_state = nfs41_free_lock_state,
+	.call_sync_ops = &nfs41_call_sync_ops,
 	.reboot_recovery_ops = &nfs41_reboot_recovery_ops,
 	.nograce_recovery_ops = &nfs41_nograce_recovery_ops,
 	.state_renewal_ops = &nfs41_state_renewal_ops,

