From: andros@netapp.com
Subject: [PATCH 04/11] nfs41: call free slot from nfs4_restart_rpc
Date: Fri,  4 Dec 2009 15:25:39 -0500
Message-ID: <1259958347-9031-5-git-send-email-andros@netapp.com>
References: <1259958347-9031-1-git-send-email-andros@netapp.com>
 <1259958347-9031-2-git-send-email-andros@netapp.com>
 <1259958347-9031-3-git-send-email-andros@netapp.com>
 <1259958347-9031-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56650 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757245AbZLDUZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 15:25:54 -0500
In-Reply-To: <1259958347-9031-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs41_sequence_free_slot can be called multiple times on SEQUENCE operation
errors.
No reason to inline nfs4_restart_rpc

Reported-by: Trond Myklebust <trond.myklebust@netapp.com>

nfs_writeback_done and nfs_readpage_retry call nfs4_restart_rpc outside the
error handler, and the slot is not freed prior to restarting in the rpc_prepare
state during session reset.

Fix this by moving the call to nfs41_sequence_free_slot from the error
path of nfs41_sequence_done into nfs4_restart_rpc, and by removing the test
for NFS4CLNT_SESSION_SETUP.
Always free slot and goto the rpc prepare state on async errors.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h |   16 ++--------------
 fs/nfs/nfs4proc.c |   29 +++++++++++++++++++++++------
 fs/nfs/read.c     |    3 ++-
 fs/nfs/unlink.c   |    4 +++-
 fs/nfs/write.c    |    3 ++-
 5 files changed, 32 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ebcd379..a6f7b6c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -177,26 +177,14 @@ extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
 extern struct rpc_procinfo nfs3_procedures[];
 extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);
 
-/* nfs4proc.c */
-static inline void nfs4_restart_rpc(struct rpc_task *task,
-				    const struct nfs_client *clp)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp) &&
-	    test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state)) {
-		rpc_restart_call_prepare(task);
-		return;
-	}
-#endif /* CONFIG_NFS_V4_1 */
-	rpc_restart_call(task);
-}
-
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
 extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
 #endif
 
 /* nfs4proc.c */
+extern void nfs4_restart_rpc(struct rpc_task *, const struct nfs_client *,
+			     struct nfs4_sequence_res *);
 #ifdef CONFIG_NFS_V4
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 979d2e3..d847e98 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -637,6 +637,19 @@ static void nfs4_sequence_done(const struct nfs_server *server,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
+void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp,
+		      struct nfs4_sequence_res *res)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp)) {
+		nfs41_sequence_free_slot(clp, res);
+		rpc_restart_call_prepare(task);
+		return;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+	rpc_restart_call(task);
+}
+
 /* no restart, therefore free slot here */
 static void nfs4_sequence_done_free_slot(const struct nfs_server *server,
 					 struct nfs4_sequence_res *res,
@@ -1737,7 +1750,8 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				break;
 		default:
 			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
-				nfs4_restart_rpc(task, server->nfs_client);
+				nfs4_restart_rpc(task, server->nfs_client,
+						 &calldata->res.seq_res);
 				return;
 			}
 	}
@@ -2975,7 +2989,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
-		nfs4_restart_rpc(task, server->nfs_client);
+		nfs4_restart_rpc(task, server->nfs_client, &data->res.seq_res);
 		return -EAGAIN;
 	}
 
@@ -3000,7 +3014,8 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 			   task->tk_status);
 
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
-		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client,
+				 &data->res.seq_res);
 		return -EAGAIN;
 	}
 	if (task->tk_status >= 0) {
@@ -3028,7 +3043,8 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
-		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client,
+				 &data->res.seq_res);
 		return -EAGAIN;
 	}
 	nfs4_sequence_free_slot(NFS_SERVER(inode)->nfs_client,
@@ -3742,7 +3758,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		default:
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				nfs4_restart_rpc(task,
-						calldata->server->nfs_client);
+						 calldata->server->nfs_client,
+						 &calldata->res.seq_res);
 	}
 	nfs4_sequence_free_slot(calldata->server->nfs_client,
 				&calldata->res.seq_res);
@@ -4871,7 +4888,7 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 
 		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
 								== -EAGAIN) {
-			nfs4_restart_rpc(task, clp);
+			nfs4_restart_rpc(task, clp, task->tk_msg.rpc_resp);
 			return;
 		}
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 12c9e66..3e04fb9 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -368,7 +368,8 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
+	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client,
+			 &data->res.seq_res);
 	return;
 out:
 	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 1064c91..52f7bdb 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -81,9 +81,11 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs_unlinkdata *data = calldata;
 	struct inode *dir = data->dir;
+	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
 	if (!NFS_PROTO(dir)->unlink_done(task, dir))
-		nfs4_restart_rpc(task, NFS_SERVER(dir)->nfs_client);
+		nfs4_restart_rpc(task, NFS_SERVER(dir)->nfs_client,
+				 &res->seq_res);
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 53eb26c..556668f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1216,7 +1216,8 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				 */
 				argp->stable = NFS_FILE_SYNC;
 			}
-			nfs4_restart_rpc(task, server->nfs_client);
+			nfs4_restart_rpc(task, server->nfs_client,
+					 &data->res.seq_res);
 			return -EAGAIN;
 		}
 		if (time_before(complain, jiffies)) {
-- 
1.6.0.6

