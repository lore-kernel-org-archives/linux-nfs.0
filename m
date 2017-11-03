Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v6 05/10] NFSv4: Retry CLOSE and DELEGRETURN on NFS4ERR_OLD_STATEID.
Date: Fri,  3 Nov 2017 12:53:49 -0400
Message-Id: <20171103165354.15997-6-trond.myklebust@primarydata.com>
In-Reply-To: <20171103165354.15997-5-trond.myklebust@primarydata.com>
References: <20171103165354.15997-1-trond.myklebust@primarydata.com>
 <20171103165354.15997-2-trond.myklebust@primarydata.com>
 <20171103165354.15997-3-trond.myklebust@primarydata.com>
 <20171103165354.15997-4-trond.myklebust@primarydata.com>
 <20171103165354.15997-5-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

If we're racing with an OPEN, then retry the operation instead of
declaring it a success.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 27 +++++++++++++++++++++++++++
 fs/nfs/delegation.h |  1 +
 fs/nfs/nfs4_fs.h    |  2 ++
 fs/nfs/nfs4proc.c   | 21 +++++++++++++++++++--
 fs/nfs/nfs4state.c  | 16 ++++++++++++++++
 5 files changed, 65 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 606dd3871f66..ade44ca0c66c 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -1041,6 +1041,33 @@ int nfs_delegations_present(struct nfs_client *clp)
 }
 
 /**
+ * nfs4_refresh_delegation_stateid - Update delegation stateid seqid
+ * @dst: stateid to refresh
+ * @inode: inode to check
+ *
+ * Returns "true" and updates "dst->seqid" * if inode had a delegation
+ * that matches our delegation stateid. Otherwise "false" is returned.
+ */
+bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
+{
+	struct nfs_delegation *delegation;
+	bool ret = false;
+	if (!inode)
+		goto out;
+
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation != NULL &&
+	    nfs4_stateid_match_other(dst, &delegation->stateid)) {
+		dst->seqid = delegation->stateid.seqid;
+		return ret;
+	}
+	rcu_read_unlock();
+out:
+	return ret;
+}
+
+/**
  * nfs4_copy_delegation_stateid - Copy inode's state ID information
  * @inode: inode to check
  * @flags: delegation type requirement
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index ddaf2644cf13..185a09f37a89 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -62,6 +62,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid, fmode_t type);
 int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid);
 bool nfs4_copy_delegation_stateid(struct inode *inode, fmode_t flags, nfs4_stateid *dst, struct rpc_cred **cred);
+bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs4_have_delegation(struct inode *inode, fmode_t flags);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b07124ae5be1..84c3adc6bf96 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -461,6 +461,8 @@ extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
 		const struct nfs_lock_context *, nfs4_stateid *,
 		struct rpc_cred **);
+extern bool nfs4_refresh_open_stateid(nfs4_stateid *dst,
+		struct nfs4_state *state);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a0bdd1e1e2c1..153e34c5b6e9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3198,13 +3198,21 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 
 			}
 			break;
+		case -NFS4ERR_OLD_STATEID:
+			/* Did we race with OPEN? */
+			if (nfs4_refresh_open_stateid(&calldata->arg.stateid,
+						state)) {
+				task->tk_status = 0;
+				rpc_restart_call_prepare(task);
+			}
+			goto out_release;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
 			nfs4_free_revoked_stateid(server,
 					&calldata->arg.stateid,
 					task->tk_msg.rpc_cred);
-		case -NFS4ERR_OLD_STATEID:
+			/* Fallthrough */
 		case -NFS4ERR_BAD_STATEID:
 			if (!nfs4_stateid_match(&calldata->arg.stateid,
 						&state->open_stateid)) {
@@ -3213,6 +3221,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			}
 			if (calldata->arg.fmode == 0)
 				break;
+			/* Fallthrough */
 		default:
 			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN) {
 				rpc_restart_call_prepare(task);
@@ -5809,11 +5818,19 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
 		nfs4_free_revoked_stateid(data->res.server,
 				data->args.stateid,
 				task->tk_msg.rpc_cred);
+		/* Fallthrough */
 	case -NFS4ERR_BAD_STATEID:
-	case -NFS4ERR_OLD_STATEID:
 	case -NFS4ERR_STALE_STATEID:
 		task->tk_status = 0;
 		break;
+	case -NFS4ERR_OLD_STATEID:
+		if (nfs4_refresh_delegation_stateid(&data->stateid, data->inode)) {
+			task->tk_status = 0;
+			rpc_restart_call_prepare(task);
+			return;
+		}
+		task->tk_status = 0;
+		break;
 	case -NFS4ERR_ACCESS:
 		if (data->args.bitmask) {
 			data->args.bitmask = NULL;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d615b7cdfa8f..752b18e88266 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -986,6 +986,22 @@ static int nfs4_copy_lock_stateid(nfs4_stateid *dst,
 	return ret;
 }
 
+bool nfs4_refresh_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+{
+	bool ret;
+	int seq;
+
+	do {
+		ret = false;
+		seq = read_seqbegin(&state->seqlock);
+		if (nfs4_state_match_open_stateid_other(state, dst)) {
+			dst->seqid = state->stateid.seqid;
+			ret = true;
+		}
+	} while (read_seqretry(&state->seqlock, seq));
+	return ret;
+}
+
 static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
 	const nfs4_stateid *src;
-- 
2.13.6
