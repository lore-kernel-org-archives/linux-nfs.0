Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8518 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534Ab1JSUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 16:50:40 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] NFS: Get rid of nfs_restart_rpc()
Date: Wed, 19 Oct 2011 13:50:15 -0700
Message-Id: <1319057418-9851-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1319057418-9851-1-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-2-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-3-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-4-git-send-email-Trond.Myklebust@netapp.com>
 <1319057418-9851-5-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It can trivially be replaced with rpc_restart_call_prepare.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/internal.h       |   10 ----------
 fs/nfs/nfs4filelayout.c |   12 ++++--------
 fs/nfs/nfs4proc.c       |   17 ++++++++---------
 fs/nfs/read.c           |    2 +-
 fs/nfs/unlink.c         |    4 ++--
 fs/nfs/write.c          |    2 +-
 net/sunrpc/clnt.c       |    4 +++-
 7 files changed, 19 insertions(+), 32 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ab12913..c1a1bd8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -457,13 +457,3 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
 		PAGE_SIZE - 1) >> PAGE_SHIFT;
 }
 
-/*
- * Helper for restarting RPC calls in the possible presence of NFSv4.1
- * sessions.
- */
-static inline int nfs_restart_rpc(struct rpc_task *task, const struct nfs_client *clp)
-{
-	if (nfs4_has_session(clp))
-		return rpc_restart_call_prepare(task);
-	return rpc_restart_call(task);
-}
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4c78c62..dc52597 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -122,7 +122,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
-	struct nfs_client *clp = data->ds_clp;
 	int reset = 0;
 
 	dprintk("%s DS read\n", __func__);
@@ -134,9 +133,8 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 		if (reset) {
 			pnfs_set_lo_fail(data->lseg);
 			nfs4_reset_read(task, data);
-			clp = NFS_SERVER(data->inode)->nfs_client;
 		}
-		nfs_restart_rpc(task, clp);
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
@@ -210,10 +208,8 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 		if (reset) {
 			pnfs_set_lo_fail(data->lseg);
 			nfs4_reset_write(task, data);
-			clp = NFS_SERVER(data->inode)->nfs_client;
-		} else
-			clp = data->ds_clp;
-		nfs_restart_rpc(task, clp);
+		}
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
@@ -245,7 +241,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 			prepare_to_resend_writes(data);
 			pnfs_set_lo_fail(data->lseg);
 		} else
-			nfs_restart_rpc(task, data->ds_clp);
+			rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ba0da50..d2ae413 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3191,7 +3191,7 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
-		nfs_restart_rpc(task, server->nfs_client);
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 
@@ -3241,7 +3241,7 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
 	struct inode *inode = data->inode;
 	
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
-		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 	if (task->tk_status >= 0) {
@@ -3298,7 +3298,7 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_write_data *dat
 	struct inode *inode = data->inode;
 
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
+		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
 	nfs_refresh_inode(inode, data->res.fattr);
@@ -3838,7 +3838,7 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 	default:
 		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
 				-EAGAIN) {
-			nfs_restart_rpc(task, data->res.server->nfs_client);
+			rpc_restart_call_prepare(task);
 			return;
 		}
 	}
@@ -4092,8 +4092,7 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			break;
 		default:
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
-				nfs_restart_rpc(task,
-						 calldata->server->nfs_client);
+				rpc_restart_call_prepare(task);
 	}
 }
 
@@ -4926,7 +4925,7 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		task->tk_status = 0;
 		/* fall through */
 	case -NFS4ERR_RETRY_UNCACHED_REP:
-		nfs_restart_rpc(task, data->clp);
+		rpc_restart_call_prepare(task);
 		return;
 	}
 	dprintk("<-- %s\n", __func__);
@@ -5767,7 +5766,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 
 	server = NFS_SERVER(lrp->args.inode);
 	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, lrp->clp);
+		rpc_restart_call_prepare(task);
 		return;
 	}
 	spin_lock(&lo->plh_inode->i_lock);
@@ -5938,7 +5937,7 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	}
 
 	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
-		nfs_restart_rpc(task, server->nfs_client);
+		rpc_restart_call_prepare(task);
 		return;
 	}
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index bfc20b1..e866a7e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -435,7 +435,7 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
+	rpc_restart_call_prepare(task);
 }
 
 /*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index b2fbbde..4f9319a 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -87,7 +87,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 	struct inode *dir = data->dir;
 
 	if (!NFS_PROTO(dir)->unlink_done(task, dir))
-		nfs_restart_rpc(task, NFS_SERVER(dir)->nfs_client);
+		rpc_restart_call_prepare(task);
 }
 
 /**
@@ -369,7 +369,7 @@ static void nfs_async_rename_done(struct rpc_task *task, void *calldata)
 	struct dentry *new_dentry = data->new_dentry;
 
 	if (!NFS_PROTO(old_dir)->rename_done(task, old_dir, new_dir)) {
-		nfs_restart_rpc(task, NFS_SERVER(old_dir)->nfs_client);
+		rpc_restart_call_prepare(task);
 		return;
 	}
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 2084a64..ad90b0c9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1305,7 +1305,7 @@ void nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				 */
 				argp->stable = NFS_FILE_SYNC;
 			}
-			nfs_restart_rpc(task, server->nfs_client);
+			rpc_restart_call_prepare(task);
 			return;
 		}
 		if (time_before(complain, jiffies)) {
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c5347d2..f0268ea 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -850,7 +850,9 @@ rpc_restart_call_prepare(struct rpc_task *task)
 {
 	if (RPC_ASSASSINATED(task))
 		return 0;
-	task->tk_action = rpc_prepare_task;
+	task->tk_action = call_start;
+	if (task->tk_ops->rpc_call_prepare != NULL)
+		task->tk_action = rpc_prepare_task;
 	return 1;
 }
 EXPORT_SYMBOL_GPL(rpc_restart_call_prepare);
-- 
1.7.6.4

