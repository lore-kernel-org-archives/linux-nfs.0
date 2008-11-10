From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 31/85] nfs41: separate free slot from sequence done
Date: Mon, 10 Nov 2008 22:23:38 +0200
Message-ID: <1226348618-8254-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48792 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbYKJUXo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:23:44 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Don't free the slot until after all rpc_restart_calls have completed.
Session reset will require more work.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/internal.h |   14 ++++++++++++++
 fs/nfs/nfs4proc.c |   36 +++++++++++++++++++++++++++++-------
 fs/nfs/read.c     |    8 ++++++--
 fs/nfs/write.c    |    1 +
 4 files changed, 50 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9b2228f..86cd70b 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -180,6 +180,20 @@ extern int nfs4_path_walk(struct nfs_server *server,
 			  const char *path);
 #endif
 
+/* nfs4proc.c */
+#ifdef CONFIG_NFS_V4_1
+extern void nfs41_sequence_free_slot(struct nfs41_sequence_res *res);
+#endif /* CONFIG_NFS_V4_1 */
+
+static inline void nfs4_sequence_free_slot(const struct nfs_server *server,
+					   struct nfs41_sequence_res *res)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (server->nfs_client->cl_minorversion)
+		nfs41_sequence_free_slot(res);
+#endif /* CONFIG_NFS_V4_1 */
+}
+
 /*
  * Determine the device name as a string
  */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5d9ca20..6d90b07 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -258,7 +258,7 @@ static inline int bmp2idx(unsigned long *base, unsigned long *bmp,
  * word in the bitmap.
  * If none found, highest_used_slotid is set to -1.
  */
-static void
+void
 nfs41_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 {
 	int slotid = slot_idx(tbl, slot);
@@ -296,6 +296,17 @@ nfs41_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 	rpc_wake_up_next(&tbl->slot_tbl_waitq);
 }
 
+void nfs41_sequence_free_slot(struct nfs41_sequence_res *res)
+{
+	if (res->sr_session == NULL || res->sr_slot == NULL) {
+		dprintk("%s: %s\n", __func__,
+			res->sr_session == NULL ? "No session" :  "No slot");
+		return;
+	}
+	nfs41_free_slot(&res->sr_session->fore_channel.slot_table,
+			res->sr_slot);
+}
+
 /* For pNFS filelayout data servers:
  * the nfs_client is NULL - to signal no lease update.
  * session is the data server.
@@ -346,14 +357,18 @@ static void nfs41_sequence_done(struct nfs_client *clp,
 	case -NFS4ERR_SEQ_FALSE_RETRY:
 	case -NFS4ERR_SEQ_MISORDERED:
 	case -NFS4ERR_TOO_MANY_OPS:
-		dprintk("%s: status %d\n", __func__, status);
+		dprintk("%s: Free Slot: status %d\n", __func__, status);
+		/* The session needs to be reset, so free the slot and set the
+		 * sr_slot to NULL so that nfs4_setup_sequence calls
+		 * nfs41_find_slot and kicks off session reset. */
+		nfs41_sequence_free_slot(res);
+		res->sr_slot = NULL;
 		break;
 
 	default:
 		printk(KERN_WARNING "%s: Unexpected status %d\n", __func__,
 			status);
 	}
-	nfs41_free_slot(tbl, slot);
 }
 
 /*
@@ -495,6 +510,7 @@ static void nfs41_call_sync_done(struct rpc_task *task, void *calldata)
 	struct nfs_server *server = data->server;
 
 	nfs41_sequence_done(server->nfs_client, data->seq_res, task->tk_status);
+	nfs41_sequence_free_slot(data->seq_res);
 }
 
 struct rpc_call_ops nfs41_call_sync_ops = {
@@ -1592,6 +1608,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 				return;
 			}
 	}
+	nfs4_sequence_free_slot(server, &calldata->res.seq_res);
 	nfs_refresh_inode(calldata->inode, calldata->res.fattr);
 }
 
@@ -2352,6 +2369,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 
 	if (nfs4_async_handle_error(task, res->server) == -EAGAIN)
 		return 0;
+	nfs4_sequence_free_slot(res->server, &res->seq_res);
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, &res->dir_attr);
 	return 1;
@@ -2855,11 +2873,13 @@ static void nfs4_proc_write_setup(struct nfs_write_data *data, struct rpc_messag
 static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
-	
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode)) == -EAGAIN) {
+	struct nfs_server *server = NFS_SERVER(inode);
+
+	if (nfs4_async_handle_error(task, server) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
+	nfs4_sequence_free_slot(server, &data->res.seq_res);
 	nfs_refresh_inode(inode, data->res.fattr);
 	return 0;
 }
@@ -3585,6 +3605,7 @@ static void nfs4_locku_release_calldata(void *data)
 static void nfs4_locku_done(struct rpc_task *task, void *data)
 {
 	struct nfs4_unlockdata *calldata = data;
+	const struct nfs_server *server = calldata->server;
 
 	if (RPC_ASSASSINATED(task))
 		return;
@@ -3593,15 +3614,16 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			memcpy(calldata->lsp->ls_stateid.data,
 					calldata->res.stateid.data,
 					sizeof(calldata->lsp->ls_stateid.data));
-			renew_lease(calldata->server, calldata->timestamp);
+			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server) == -EAGAIN)
+			if (nfs4_async_handle_error(task, server) == -EAGAIN)
 				rpc_restart_call(task);
 	}
+	nfs4_sequence_free_slot(server, &calldata->res.seq_res);
 }
 
 static void nfs4_locku_prepare(struct rpc_task *task, void *data)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 40d1798..8c2019c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -351,19 +351,23 @@ static void nfs_readpage_retry(struct rpc_task *task, struct nfs_read_data *data
 	struct nfs_readres *resp = &data->res;
 
 	if (resp->eof || resp->count == argp->count)
-		return;
+		goto out;
 
 	/* This is a short read! */
 	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
 	/* Has the server at least made some progress? */
 	if (resp->count == 0)
-		return;
+		goto out;
 
 	/* Yes, so retry the read at the end of the data */
 	argp->offset += resp->count;
 	argp->pgbase += resp->count;
 	argp->count -= resp->count;
 	rpc_restart_call(task);
+	return;
+out:
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode), &data->res.seq_res);
+	return;
 }
 
 /*
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 9f98458..361a61b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1171,6 +1171,7 @@ int nfs_writeback_done(struct rpc_task *task, struct nfs_write_data *data)
 		/* Can't do anything about it except throw an error. */
 		task->tk_status = -EIO;
 	}
+	nfs4_sequence_free_slot(NFS_SERVER(data->inode), &data->res.seq_res);
 	return 0;
 }
 
-- 
1.6.0.2

