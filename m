Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:50484 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751893AbaIRGKD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Sep 2014 02:10:03 -0400
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 18 Sep 2014 16:09:27 +1000
Subject: [PATCH 1/2] NFSv4: use exponential retry on NFS4ERR_DELAY for async
 requests.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140918060927.24098.29694.stgit@notabene.brown>
In-Reply-To: <20140918060551.24098.72288.stgit@notabene.brown>
References: <20140918060551.24098.72288.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently asynchronous NFSv4 request will be retried with
exponential timeout (from 1/10 to 15 seconds), but async
requests will always use a 15second retry.

Some "async" requests are really synchronous though.  The
async mechanism is used to allow the request to continue if
the requesting process is killed.
In those cases, an exponential retry is appropriate.

For example, if two different clients both open a file and
get a READ delegation, and one client then unlinks the file
(while still holding an open file descriptor), that unlink
will used the "silly-rename" handling which is async.
The first rename will result in NFS4ERR_DELAY while the
delegation is reclaimed from the other client.  The rename
will not be retried for 15 seconds, causing an unlink to take
15 seconds rather than 100msec.

This patch only added exponential timeout for async unlink and
async rename.  Other async calls, such as 'close' are sometimes
waited for so they might benefit from exponential timeout too.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfs/nfs4proc.c       |   65 ++++++++++++++++++++++++++++++-----------------
 include/linux/nfs_xdr.h |    2 +
 2 files changed, 44 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ac2dd953fc18..882196adbfe7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -77,7 +77,7 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *, long *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
 static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
@@ -314,20 +314,30 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start);
 }
 
+static long nfs4_update_delay(long *timeout)
+{
+	long ret;
+	if (!timeout)
+		return NFS4_POLL_RETRY_MAX;
+	if (*timeout <= 0)
+		*timeout = NFS4_POLL_RETRY_MIN;
+	if (*timeout > NFS4_POLL_RETRY_MAX)
+		*timeout = NFS4_POLL_RETRY_MAX;
+	ret = *timeout;
+	*timeout <<= 1;
+	return ret;
+}
+
 static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 {
 	int res = 0;
 
 	might_sleep();
 
-	if (*timeout <= 0)
-		*timeout = NFS4_POLL_RETRY_MIN;
-	if (*timeout > NFS4_POLL_RETRY_MAX)
-		*timeout = NFS4_POLL_RETRY_MAX;
-	freezable_schedule_timeout_killable_unsafe(*timeout);
+	freezable_schedule_timeout_killable_unsafe(
+		nfs4_update_delay(timeout));
 	if (fatal_signal_pending(current))
 		res = -ERESTARTSYS;
-	*timeout <<= 1;
 	return res;
 }
 
@@ -2589,7 +2599,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			if (calldata->arg.fmode == 0)
 				break;
 		default:
-			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
+			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN) {
 				rpc_restart_call_prepare(task);
 				goto out_release;
 			}
@@ -3576,7 +3586,8 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
-	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL,
+				    &data->timeout) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
 	return 1;
@@ -3609,7 +3620,7 @@ static int nfs4_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 
 	if (!nfs4_sequence_done(task, &res->seq_res))
 		return 0;
-	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL, &data->timeout) == -EAGAIN)
 		return 0;
 
 	update_changeattr(old_dir, &res->old_cinfo);
@@ -4113,7 +4124,8 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_pgio_header *hdr)
 
 	trace_nfs4_read(hdr, task->tk_status);
 	if (nfs4_async_handle_error(task, server,
-				    hdr->args.context->state) == -EAGAIN) {
+				    hdr->args.context->state,
+				    NULL) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -4181,10 +4193,11 @@ static int nfs4_write_done_cb(struct rpc_task *task,
 			      struct nfs_pgio_header *hdr)
 {
 	struct inode *inode = hdr->inode;
-	
+
 	trace_nfs4_write(hdr, task->tk_status);
 	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
-				    hdr->args.context->state) == -EAGAIN) {
+				    hdr->args.context->state,
+				    NULL) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -4264,7 +4277,8 @@ static int nfs4_commit_done_cb(struct rpc_task *task, struct nfs_commit_data *da
 	struct inode *inode = data->inode;
 
 	trace_nfs4_commit(data, task->tk_status);
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode),
+				    NULL, NULL) == -EAGAIN) {
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
 	}
@@ -4817,7 +4831,8 @@ out:
 
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
+			struct nfs4_state *state, long *timeout)
 {
 	struct nfs_client *clp = server->nfs_client;
 
@@ -4867,6 +4882,8 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 #endif /* CONFIG_NFS_V4_1 */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
+			rpc_delay(task, nfs4_update_delay(timeout));
+			goto restart_call;
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 		case -NFS4ERR_RETRY_UNCACHED_REP:
@@ -5107,8 +5124,8 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 			pnfs_roc_set_barrier(data->inode, data->roc_barrier);
 		break;
 	default:
-		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
-				-EAGAIN) {
+		if (nfs4_async_handle_error(task, data->res.server,
+					    NULL, NULL) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -5372,7 +5389,8 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
+			if (nfs4_async_handle_error(task, calldata->server,
+						    NULL, NULL) == -EAGAIN)
 				rpc_restart_call_prepare(task);
 	}
 	nfs_release_seqid(calldata->arg.seqid);
@@ -5978,7 +5996,8 @@ static void nfs4_release_lockowner_done(struct rpc_task *task, void *calldata)
 		break;
 	case -NFS4ERR_LEASE_MOVED:
 	case -NFS4ERR_DELAY:
-		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		if (nfs4_async_handle_error(task, server,
+					    NULL, NULL) == -EAGAIN)
 			rpc_restart_call_prepare(task);
 	}
 }
@@ -7590,7 +7609,7 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
 			pnfs_free_lseg_list(&head);
 		}
 	}
-	if (nfs4_async_handle_error(task, server, state) == -EAGAIN)
+	if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN)
 		rpc_restart_call_prepare(task);
 out:
 	dprintk("<-- %s\n", __func__);
@@ -7750,7 +7769,7 @@ static void nfs4_layoutreturn_done(struct rpc_task *task, void *calldata)
 	case 0:
 		break;
 	case -NFS4ERR_DELAY:
-		if (nfs4_async_handle_error(task, server, NULL) != -EAGAIN)
+		if (nfs4_async_handle_error(task, server, NULL, NULL) != -EAGAIN)
 			break;
 		rpc_restart_call_prepare(task);
 		return;
@@ -7929,7 +7948,7 @@ nfs4_layoutcommit_done(struct rpc_task *task, void *calldata)
 	case 0:
 		break;
 	default:
-		if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN) {
+		if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN) {
 			rpc_restart_call_prepare(task);
 			return;
 		}
@@ -8225,7 +8244,7 @@ static void nfs41_free_stateid_done(struct rpc_task *task, void *calldata)
 
 	switch (task->tk_status) {
 	case -NFS4ERR_DELAY:
-		if (nfs4_async_handle_error(task, data->server, NULL) == -EAGAIN)
+		if (nfs4_async_handle_error(task, data->server, NULL, NULL) == -EAGAIN)
 			rpc_restart_call_prepare(task);
 	}
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 0040629894df..9e02174af87e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1346,6 +1346,7 @@ struct nfs_unlinkdata {
 	struct inode *dir;
 	struct rpc_cred	*cred;
 	struct nfs_fattr dir_attr;
+	long timeout;
 };
 
 struct nfs_renamedata {
@@ -1359,6 +1360,7 @@ struct nfs_renamedata {
 	struct dentry		*new_dentry;
 	struct nfs_fattr	new_fattr;
 	void (*complete)(struct rpc_task *, struct nfs_renamedata *);
+	long timeout;
 };
 
 struct nfs_access_entry;


