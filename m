From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RE: [PATCH 0/12] Fix session reset deadlocks Version 4
Date: Sat, 05 Dec 2009 15:06:02 -0500
Message-ID: <1260043562.2624.94.camel@localhost>
References: <1259965498.2825.5.camel@localhost>
	 <273FE88A07F5D445824060902F70034408A1A330@SACMVEXC1-PRD.hq.netapp.com>
	 <89c397150912051103y52ca3ef1ua238cb7f2887be81@mail.gmail.com>
	 <273FE88A07F5D445824060902F70034406371449@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6707 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbZLEUKN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:10:13 -0500
In-Reply-To: <273FE88A07F5D445824060902F70034406371449-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is another cleanup/bugfix...

----------------------------------------------------------------------------------------------------
NFSv41: Clean up slot table management

From: Trond Myklebust <Trond.Myklebust@netapp.com>

We no longer need to maintain a distinction between nfs41_sequence_done and
nfs41_sequence_free_slot.

This fixes a number of slot table leakages in the NFSv4.1 code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/internal.h |   17 +-------------
 fs/nfs/nfs4proc.c |   64 ++++++++++++-----------------------------------------
 fs/nfs/read.c     |   13 ++---------
 fs/nfs/unlink.c   |    3 +-
 fs/nfs/write.c    |    4 +--
 5 files changed, 21 insertions(+), 80 deletions(-)


diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 83a9284..b1a020c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -197,8 +197,7 @@ extern const u32 nfs41_maxwrite_overhead;
 #endif
 
 /* nfs4proc.c */
-extern void nfs4_restart_rpc(struct rpc_task *, const struct nfs_client *,
-			     struct nfs4_sequence_res *);
+extern void nfs4_restart_rpc(struct rpc_task *, const struct nfs_client *);
 #ifdef CONFIG_NFS_V4
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
@@ -275,20 +274,6 @@ extern int _nfs4_call_sync_session(struct nfs_server *server,
 				   struct nfs4_sequence_res *res,
 				   int cache_reply);
 
-#ifdef CONFIG_NFS_V4_1
-extern void nfs41_sequence_free_slot(const struct nfs_client *,
-				     struct nfs4_sequence_res *res);
-#endif /* CONFIG_NFS_V4_1 */
-
-static inline void nfs4_sequence_free_slot(const struct nfs_client *clp,
-					   struct nfs4_sequence_res *res)
-{
-#ifdef CONFIG_NFS_V4_1
-	if (nfs4_has_session(clp))
-		nfs41_sequence_free_slot(clp, res);
-#endif /* CONFIG_NFS_V4_1 */
-}
-
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 71993f1..906585b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -341,15 +341,11 @@ nfs4_free_slot(struct nfs4_slot_table *tbl, u8 free_slotid)
 		free_slotid, tbl->highest_used_slotid);
 }
 
-void nfs41_sequence_free_slot(const struct nfs_client *clp,
+static void nfs41_sequence_free_slot(const struct nfs_client *clp,
 			      struct nfs4_sequence_res *res)
 {
 	struct nfs4_slot_table *tbl;
 
-	if (!nfs4_has_session(clp)) {
-		dprintk("%s: No session\n", __func__);
-		return;
-	}
 	tbl = &clp->cl_session->fc_slot_table;
 	if (res->sr_slotid == NFS4_MAX_SLOT_TABLE) {
 		/* just wake up the next guy waiting since
@@ -407,7 +403,6 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 		spin_unlock(&clp->cl_lock);
 		/* Check sequence flags */
 		nfs41_handle_sequence_flag_errors(clp, res->sr_status_flags);
-		return;
 	}
 out:
 	/* The session may be reset by one of the error handlers. */
@@ -556,7 +551,6 @@ static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
 	struct nfs41_call_sync_data *data = calldata;
 
 	nfs41_sequence_done(data->clp, data->seq_res, task->tk_status);
-	nfs41_sequence_free_slot(data->clp, data->seq_res);
 }
 
 struct rpc_call_ops nfs41_call_sync_ops = {
@@ -632,12 +626,10 @@ static void nfs4_sequence_done(const struct nfs_server *server,
 #endif /* CONFIG_NFS_V4_1 */
 }
 
-void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp,
-		      struct nfs4_sequence_res *res)
+void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp)
 {
 #ifdef CONFIG_NFS_V4_1
 	if (nfs4_has_session(clp)) {
-		nfs41_sequence_free_slot(clp, res);
 		rpc_restart_call_prepare(task);
 		return;
 	}
@@ -645,15 +637,6 @@ void nfs4_restart_rpc(struct rpc_task *task, const struct nfs_client *clp,
 	rpc_restart_call(task);
 }
 
-/* no restart, therefore free slot here */
-static void nfs4_sequence_done_free_slot(const struct nfs_server *server,
-					 struct nfs4_sequence_res *res,
-					 int rpc_status)
-{
-	nfs4_sequence_done(server, res, rpc_status);
-	nfs4_sequence_free_slot(server->nfs_client, res);
-}
-
 static void update_changeattr(struct inode *dir, struct nfs4_change_info *cinfo)
 {
 	struct nfs_inode *nfsi = NFS_I(dir);
@@ -1350,8 +1333,8 @@ static void nfs4_open_done(struct rpc_task *task, void *calldata)
 
 	data->rpc_status = task->tk_status;
 
-	nfs4_sequence_done_free_slot(data->o_arg.server, &data->o_res.seq_res,
-				     task->tk_status);
+	nfs4_sequence_done(data->o_arg.server, &data->o_res.seq_res,
+			task->tk_status);
 
 	if (RPC_ASSASSINATED(task))
 		return;
@@ -1757,12 +1740,10 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				break;
 		default:
 			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
-				nfs4_restart_rpc(task, server->nfs_client,
-						 &calldata->res.seq_res);
+				nfs4_restart_rpc(task, server->nfs_client);
 				return;
 			}
 	}
-	nfs4_sequence_free_slot(server->nfs_client, &calldata->res.seq_res);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
 }
 
@@ -2553,7 +2534,6 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 	nfs4_sequence_done(res->server, &res->seq_res, task->tk_status);
 	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
-	nfs4_sequence_free_slot(res->server->nfs_client, &res->seq_res);
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, &res->dir_attr);
 	return 1;
@@ -2992,20 +2972,16 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 
 	dprintk("--> %s\n", __func__);
 
-	/* nfs4_sequence_free_slot called in the read rpc_call_done */
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
 
 	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
-		nfs4_restart_rpc(task, server->nfs_client, &data->res.seq_res);
+		nfs4_restart_rpc(task, server->nfs_client);
 		return -EAGAIN;
 	}
 
 	nfs_invalidate_atime(data->inode);
 	if (task->tk_status > 0)
 		renew_lease(server, data->timestamp);
-	else if (task->tk_status < 0)
-		nfs4_sequence_free_slot(server->nfs_client, &data->res.seq_res);
-
 	return 0;
 }
 
@@ -3019,13 +2995,11 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
-	/* slot is freed in nfs_writeback_done */
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
-		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client,
-				 &data->res.seq_res);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
 	if (task->tk_status >= 0) {
@@ -3053,12 +3027,9 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 	nfs4_sequence_done(NFS_SERVER(inode), &data->res.seq_res,
 			   task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
-		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client,
-				 &data->res.seq_res);
+		nfs4_restart_rpc(task, NFS_SERVER(inode)->nfs_client);
 		return -EAGAIN;
 	}
-	nfs4_sequence_free_slot(NFS_SERVER(inode)->nfs_client,
-				&data->res.seq_res);
 	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
@@ -3509,8 +3480,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_delegreturndata *data = calldata;
 
-	nfs4_sequence_done_free_slot(data->res.server, &data->res.seq_res,
-				     task->tk_status);
+	nfs4_sequence_done(data->res.server, &data->res.seq_res,
+			task->tk_status);
 
 	data->rpc_status = task->tk_status;
 	if (data->rpc_status == 0)
@@ -3768,11 +3739,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		default:
 			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				nfs4_restart_rpc(task,
-						 calldata->server->nfs_client,
-						 &calldata->res.seq_res);
+						 calldata->server->nfs_client);
 	}
-	nfs4_sequence_free_slot(calldata->server->nfs_client,
-				&calldata->res.seq_res);
 }
 
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
@@ -3954,8 +3922,8 @@ static void nfs4_lock_done(struct rpc_task *task, void *calldata)
 
 	dprintk("%s: begin!\n", __func__);
 
-	nfs4_sequence_done_free_slot(data->server, &data->res.seq_res,
-				     task->tk_status);
+	nfs4_sequence_done(data->server, &data->res.seq_res,
+			task->tk_status);
 
 	data->rpc_status = task->tk_status;
 	if (RPC_ASSASSINATED(task))
@@ -4425,10 +4393,9 @@ static void nfs4_get_lease_time_done(struct rpc_task *task, void *calldata)
 		dprintk("%s Retry: tk_status %d\n", __func__, task->tk_status);
 		rpc_delay(task, NFS4_POLL_RETRY_MIN);
 		task->tk_status = 0;
-		rpc_restart_call(task);
+		nfs4_restart_rpc(task, data->clp);
 		return;
 	}
-	nfs41_sequence_free_slot(data->clp, &data->res->lr_seq_res);
 	dprintk("<-- %s\n", __func__);
 }
 
@@ -4912,11 +4879,10 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
 
 		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
 								== -EAGAIN) {
-			nfs4_restart_rpc(task, clp, task->tk_msg.rpc_resp);
+			nfs4_restart_rpc(task, clp);
 			return;
 		}
 	}
-	nfs41_sequence_free_slot(clp, task->tk_msg.rpc_resp);
 	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
 
 	kfree(task->tk_msg.rpc_argp);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 3e04fb9..d319bfb 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -356,26 +356,19 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	struct nfs_readres *resp = &data->res;
 
 	if (resp->eof || resp->count == argp->count)
-		goto out;
+		return;
 
 	/* This is a short read! */
 	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
 	if (resp->count == 0)
-		goto out;
+		return;
 
 	/* Yes, so retry the read at the end of the data */
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
-	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client,
-			 &data->res.seq_res);
-	return;
-out:
-	nfs4_sequence_free_slot(NFS_SERVER(data->inode)->nfs_client,
-				&data->res.seq_res);
-	return;
-
+	nfs4_restart_rpc(task, NFS_SERVER(data->inode)->nfs_client);
 }
 
 /*
diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 52f7bdb..012a14c 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -84,8 +84,7 @@ static void nfs_async_unlink_done(struct rpc_task *task, void *calldata)
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
 	if (!NFS_PROTO(dir)->unlink_done(task, dir))
-		nfs4_restart_rpc(task, NFS_SERVER(dir)->nfs_client,
-				 &res->seq_res);
+		nfs4_restart_rpc(task, NFS_SERVER(dir)->nfs_client);
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 556668f..d546c60 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1216,8 +1216,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 				 */
 				argp->stable = NFS_FILE_SYNC;
 			}
-			nfs4_restart_rpc(task, server->nfs_client,
-					 &data->res.seq_res);
+			nfs4_restart_rpc(task, server->nfs_client);
 			return -EAGAIN;
 		}
 		if (time_before(complain, jiffies)) {
@@ -1229,7 +1228,6 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
-	nfs4_sequence_free_slot(server->nfs_client, &data->res.seq_res);
 	return 0;
 }
 

