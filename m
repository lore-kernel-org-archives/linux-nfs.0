From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 56/67] nfs41: use rpc prepare call state for session reset
Date: Thu,  2 Apr 2009 16:58:35 +0300
Message-ID: <1238680715-15153-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30990 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752972AbZDBN7b (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:59:31 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

[nfs41: change nfs4_restart_rpc argument]
[nfs41: check for session not minorversion]
[nfs41: trigger the state manager for session reset]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |    4 ++++
 fs/nfs/nfs4proc.c |   27 ++++++++++++++++++++-------
 fs/nfs/read.c     |    2 +-
 fs/nfs/unlink.c   |    2 +-
 fs/nfs/write.c    |    8 ++++----
 5 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f3b310e..dc92be7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -148,6 +148,10 @@ extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
 extern struct rpc_procinfo nfs3_procedures[];
 extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);
 
+/* nfs4proc.c */
+extern void nfs4_restart_rpc(struct rpc_task *task,
+			     const struct nfs_client *clp);
+
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8e185eb..984a13a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -586,6 +586,18 @@ static void nfs4_sequence_done_free_slot(const struct nfs_server *server,
 	nfs4_sequence_free_slot(server->nfs_client, res);
 }
 
+void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp) &&
+	    test_bit(NFS4CLNT_SESSION_SETUP, &clp->cl_state)) {
+		rpc_restart_call_prepare(task);
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+	rpc_restart_call(task);
+}
+
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
@@ -1661,7 +1673,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				break;
 		default:
 			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
-				rpc_restart_call(task);
+				nfs4_restart_rpc(task, server->nfs_client);
 				return;
 			}
 	}
@@ -2874,7 +2886,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, server->nfs_client);
 		return -EAGAIN;
 	}
 
@@ -2899,7 +2911,7 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 			   task->tk_status);
 
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
 	if (task->tk_status >= 0) {
@@ -2927,7 +2939,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
 	nfs4_sequence_free_slot(NFS_SERVER(inode)->nfs_client,
@@ -3631,7 +3643,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			break;
 		default:
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
-				rpc_restart_call(task);
+				nfs4_restart_rpc(task,
+						calldata->server->nfs_client);
 	}
 	nfs4_sequence_free_slot(calldata->server->nfs_client,
 				&calldata->res.seq_res);
@@ -4240,7 +4253,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
 		rpc_delay(task, NFS4_POLL_RETRY_MIN);
 		task->tk_status = 0;
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, data->clp);
 		return;
 	}
 	nfs41_sequence_free_slot(data->clp, &data->res->lr_seq_res);
@@ -4650,7 +4663,7 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 
 		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
 								== -EAGAIN) {
-			rpc_restart_call(task);
+			nfs4_restart_rpc(task, clp);
 			return;
 		}
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index d71f0d5..96c4ebf 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -371,7 +371,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	rpc_restart_call(task);
+	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
 	return;
 out:
 	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 089a21b..1064c91 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -83,7 +83,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 	struct inode *dir = data->dir;
 
 	if (!NFS_PROTO(dir)->unlink_done(task, dir))
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, NFS_SERVER(dir)->nfs_client);
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 85a7640..ce72882 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1145,6 +1145,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct nfs_writeargs	*argp = &data->args;
 	struct nfs_writeres	*resp = &data->res;
+	struct nfs_server	*server = NFS_SERVER(data->inode);
 	int status;
 
 	dprintk("NFS: %5u nfs_writeback_done (status %d)\n",
@@ -1177,7 +1178,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		if (time_before(complain, jiffies)) {
 			dprintk("NFS:       faulty NFS server %s:"
 				" (committed = %d) != (stable = %d)\n",
-				NFS_SERVER(data->inode)->nfs_client->cl_hostname,
+				server->nfs_client->cl_hostname,
 				resp->verf->committed, argp->stable);
 			complain = jiffies + 300 * HZ;
 		}
@@ -1203,7 +1204,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				 */
 				argp->stable = NFS_FILE_SYNC;
 			}
-			rpc_restart_call(task);
+			nfs4_restart_rpc(task, server->nfs_client);
 			return -EAGAIN;
 		}
 		if (time_before(complain, jiffies)) {
@@ -1215,8 +1216,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
-	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
-				&data->res.seq_res);
+	nfs4_sequence_free_slot(server->nfs_client, &data->res.seq_res);
 	return 0;
 }
 
-- 
1.6.2.1

