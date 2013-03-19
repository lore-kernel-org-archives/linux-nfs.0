Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19796 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389Ab3CSNHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Mar 2013 09:07:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/11] NFSv4: Fail I/O if the state recovery fails irrevocably
Date: Tue, 19 Mar 2013 09:07:33 -0400
Message-Id: <1363698463-3681-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If state recovery fails with an ESTALE or a ENOENT, then we shouldn't
keep retrying. Instead, mark the stateid as being invalid and
fail the I/O with an EIO error.
For other operations such as POSIX and BSD file locking, truncate
etc, fail with an EBADF to indicate that this file descriptor is no
longer valid.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h        |  8 +++++++-
 fs/nfs/nfs4filelayout.c | 12 +++++++++---
 fs/nfs/nfs4proc.c       | 37 +++++++++++++++++++++++++++++--------
 fs/nfs/nfs4state.c      | 19 ++++++++++++++-----
 fs/nfs/pnfs.c           |  2 ++
 5 files changed, 61 insertions(+), 17 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 944c9a5..9ce9013 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -149,6 +149,7 @@ enum {
 	NFS_STATE_RECLAIM_REBOOT,	/* OPEN stateid server rebooted */
 	NFS_STATE_RECLAIM_NOGRACE,	/* OPEN stateid needs to recover state */
 	NFS_STATE_POSIX_LOCKS,		/* Posix locks are supported */
+	NFS_STATE_RECOVERY_FAILED,	/* OPEN stateid state recovery failed */
 };
 
 struct nfs4_state {
@@ -347,7 +348,7 @@ extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
 extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
-extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
+extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
@@ -412,6 +413,11 @@ static inline bool nfs4_stateid_match(const nfs4_stateid *dst, const nfs4_statei
 	return memcmp(dst, src, sizeof(*dst)) == 0;
 }
 
+static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
+{
+	return test_bit(NFS_STATE_RECOVERY_FAILED, &state->flags) == 0;
+}
+
 #else
 
 #define nfs4_close_state(a, b) do { } while (0)
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 49eeb04..e4a29fb 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -159,11 +159,14 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 	case -NFS4ERR_OPENMODE:
 		if (state == NULL)
 			break;
-		nfs4_schedule_stateid_recovery(mds_server, state);
+		if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
+			goto out_bad_stateid;
 		goto wait_on_recovery;
 	case -NFS4ERR_EXPIRED:
-		if (state != NULL)
-			nfs4_schedule_stateid_recovery(mds_server, state);
+		if (state != NULL) {
+			if (nfs4_schedule_stateid_recovery(mds_server, state) < 0)
+				goto out_bad_stateid;
+		}
 		nfs4_schedule_lease_recovery(mds_client);
 		goto wait_on_recovery;
 	/* DS session errors */
@@ -227,6 +230,9 @@ reset:
 out:
 	task->tk_status = 0;
 	return -EAGAIN;
+out_bad_stateid:
+	task->tk_status = -EIO;
+	return 0;
 wait_on_recovery:
 	rpc_sleep_on(&mds_client->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &mds_client->cl_state) == 0)
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b2671cb..5a6b3c9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -295,7 +295,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			}
 			if (state == NULL)
 				break;
-			nfs4_schedule_stateid_recovery(server, state);
+			ret = nfs4_schedule_stateid_recovery(server, state);
+			if (ret < 0)
+				break;
 			goto wait_on_recovery;
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
@@ -303,11 +305,16 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			if (state == NULL)
 				break;
 			nfs_remove_bad_delegation(state->inode);
-			nfs4_schedule_stateid_recovery(server, state);
+			ret = nfs4_schedule_stateid_recovery(server, state);
+			if (ret < 0)
+				break;
 			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
-			if (state != NULL)
-				nfs4_schedule_stateid_recovery(server, state);
+			if (state != NULL) {
+				ret = nfs4_schedule_stateid_recovery(server, state);
+				if (ret < 0)
+					break;
+			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
@@ -2053,7 +2060,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 	nfs_fattr_init(fattr);
 
-	if (state != NULL) {
+	if (state != NULL && nfs4_valid_open_stateid(state)) {
 		struct nfs_lockowner lockowner = {
 			.l_owner = current->files,
 			.l_pid = current->tgid,
@@ -2201,6 +2208,8 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 			calldata->arg.fmode &= ~FMODE_WRITE;
 		}
 	}
+	if (!nfs4_valid_open_stateid(state))
+		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
 
 	if (!call_close) {
@@ -3980,11 +3989,14 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_OPENMODE:
 			if (state == NULL)
 				break;
-			nfs4_schedule_stateid_recovery(server, state);
+			if (nfs4_schedule_stateid_recovery(server, state) < 0)
+				goto stateid_invalid;
 			goto wait_on_recovery;
 		case -NFS4ERR_EXPIRED:
-			if (state != NULL)
-				nfs4_schedule_stateid_recovery(server, state);
+			if (state != NULL) {
+				if (nfs4_schedule_stateid_recovery(server, state) < 0)
+					goto stateid_invalid;
+			}
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_STALE_CLIENTID:
 			nfs4_schedule_lease_recovery(clp);
@@ -4016,6 +4028,9 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
+stateid_invalid:
+	task->tk_status = -EIO;
+	return 0;
 wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
@@ -4632,12 +4647,18 @@ static void nfs4_lock_prepare(struct rpc_task *task, void *calldata)
 		data->res.open_seqid = data->arg.open_seqid;
 	} else
 		data->arg.new_lock_owner = 0;
+	if (!nfs4_valid_open_stateid(state)) {
+		data->rpc_status = -EBADF;
+		task->tk_action = NULL;
+		goto out_release_open_seqid;
+	}
 	data->timestamp = jiffies;
 	if (nfs4_setup_sequence(data->server,
 				&data->arg.seq_args,
 				&data->res.seq_res,
 				task) == 0)
 		return;
+out_release_open_seqid:
 	nfs_release_seqid(data->arg.open_seqid);
 out_release_lock_seqid:
 	nfs_release_seqid(data->arg.lock_seqid);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6ace365..fec1c5b 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -699,6 +699,8 @@ __nfs4_find_state_byowner(struct inode *inode, struct nfs4_state_owner *owner)
 	list_for_each_entry(state, &nfsi->open_states, inode_states) {
 		if (state->owner != owner)
 			continue;
+		if (!nfs4_valid_open_stateid(state))
+			continue;
 		if (atomic_inc_not_zero(&state->count))
 			return state;
 	}
@@ -1286,14 +1288,17 @@ static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_s
 	return 1;
 }
 
-void nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_state *state)
+int nfs4_schedule_stateid_recovery(const struct nfs_server *server, struct nfs4_state *state)
 {
 	struct nfs_client *clp = server->nfs_client;
 
+	if (!nfs4_valid_open_stateid(state))
+		return -EBADF;
 	nfs4_state_mark_reclaim_nograce(clp, state);
 	dprintk("%s: scheduling stateid recovery for server %s\n", __func__,
 			clp->cl_hostname);
 	nfs4_schedule_state_manager(clp);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_stateid_recovery);
 
@@ -1323,6 +1328,11 @@ void nfs_inode_find_state_and_recover(struct inode *inode,
 		nfs4_schedule_state_manager(clp);
 }
 
+static void nfs4_state_mark_recovery_failed(struct nfs4_state *state, int error)
+{
+	set_bit(NFS_STATE_RECOVERY_FAILED, &state->flags);
+}
+
 
 static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_recovery_ops *ops)
 {
@@ -1398,6 +1408,8 @@ restart:
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
 			continue;
+		if (!nfs4_valid_open_stateid(state))
+			continue;
 		if (state->state == 0)
 			continue;
 		atomic_inc(&state->count);
@@ -1430,10 +1442,7 @@ restart:
 				 * Open state on this file cannot be recovered
 				 * All we can do is revert to using the zero stateid.
 				 */
-				memset(&state->stateid, 0,
-					sizeof(state->stateid));
-				/* Mark the file as being 'closed' */
-				state->state = 0;
+				nfs4_state_mark_recovery_failed(state, status);
 				break;
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_STALE_STATEID:
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 48ac5aa..e86e35f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -711,6 +711,8 @@ pnfs_choose_layoutget_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo,
 	spin_lock(&lo->plh_inode->i_lock);
 	if (pnfs_layoutgets_blocked(lo, 1)) {
 		status = -EAGAIN;
+	} else if (!nfs4_valid_open_stateid(open_state)) {
+		status = -EBADF;
 	} else if (list_empty(&lo->plh_segs)) {
 		int seq;
 
-- 
1.8.1.4

