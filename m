Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:37010 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754300AbeEORDm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2018 13:03:42 -0400
Received: by mail-it0-f66.google.com with SMTP id 70-v6so3482204ity.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 May 2018 10:03:42 -0700 (PDT)
From: schumaker.anna@gmail.com
To: Trond.Myklebust@hammerspace.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Merge nfs41_free_stateid() with _nfs41_free_stateid()
Date: Tue, 15 May 2018 13:03:39 -0400
Message-Id: <20180515170339.12971-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Having these exist as two functions doesn't seem to add anything useful,
and I think merging them together makes this easier to follow.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4proc.c | 37 ++++++++++++++-----------------------
 1 file changed, 14 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9cf678477a37..33e24c971d1a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9299,7 +9299,17 @@ static const struct rpc_call_ops nfs41_free_stateid_ops = {
 	.rpc_release = nfs41_free_stateid_release,
 };
 
-static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
+/**
+ * nfs41_free_stateid - perform a FREE_STATEID operation
+ *
+ * @server: server / transport on which to perform the operation
+ * @stateid: state ID to release
+ * @cred: credential
+ * @is_recovery: set to true if this call needs to be privileged
+ *
+ * Note: this function is always asynchronous.
+ */
+static int nfs41_free_stateid(struct nfs_server *server,
 		const nfs4_stateid *stateid,
 		struct rpc_cred *cred,
 		bool privileged)
@@ -9315,6 +9325,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct nfs_free_stateid_data *data;
+	struct rpc_task *task;
 
 	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
 		&task_setup.rpc_client, &msg);
@@ -9322,7 +9333,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc(sizeof(*data), GFP_NOFS);
 	if (!data)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 	data->server = server;
 	nfs4_stateid_copy(&data->args.stateid, stateid);
 
@@ -9331,27 +9342,7 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	msg.rpc_argp = &data->args;
 	msg.rpc_resp = &data->res;
 	nfs4_init_sequence(&data->args.seq_args, &data->res.seq_res, 1, privileged);
-	return rpc_run_task(&task_setup);
-}
-
-/**
- * nfs41_free_stateid - perform a FREE_STATEID operation
- *
- * @server: server / transport on which to perform the operation
- * @stateid: state ID to release
- * @cred: credential
- * @is_recovery: set to true if this call needs to be privileged
- *
- * Note: this function is always asynchronous.
- */
-static int nfs41_free_stateid(struct nfs_server *server,
-		const nfs4_stateid *stateid,
-		struct rpc_cred *cred,
-		bool is_recovery)
-{
-	struct rpc_task *task;
-
-	task = _nfs41_free_stateid(server, stateid, cred, is_recovery);
+	task = rpc_run_task(&task_setup);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	rpc_put_task(task);
-- 
2.17.0

