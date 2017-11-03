Return-Path: <trondmy@gmail.com>
Sender: Trond Myklebust <trondmy@gmail.com>
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Benjamin Coddington <bcodding@redhat.com>,
	Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v5 06/10] NFSv4: Don't try to CLOSE if the stateid 'other' field has changed
Date: Fri,  3 Nov 2017 07:35:35 -0400
Message-Id: <20171103113539.5551-7-trond.myklebust@primarydata.com>
In-Reply-To: <20171103113539.5551-6-trond.myklebust@primarydata.com>
References: <20171103113539.5551-1-trond.myklebust@primarydata.com>
 <20171103113539.5551-2-trond.myklebust@primarydata.com>
 <20171103113539.5551-3-trond.myklebust@primarydata.com>
 <20171103113539.5551-4-trond.myklebust@primarydata.com>
 <20171103113539.5551-5-trond.myklebust@primarydata.com>
 <20171103113539.5551-6-trond.myklebust@primarydata.com>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

If the stateid is no longer recognised on the server, either due to a
restart, or due to a competing CLOSE call, then we do not have to
retry. Any open contexts that triggered a reopen of the file, will
also act as triggers for any CLOSE for the updated stateids.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4_fs.h   |  2 ++
 fs/nfs/nfs4proc.c  | 14 ++++----------
 fs/nfs/nfs4state.c |  9 +++++++--
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 84c3adc6bf96..cdab6e8dbacc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -463,6 +463,8 @@ extern int nfs4_select_rw_stateid(struct nfs4_state *, fmode_t,
 		struct rpc_cred **);
 extern bool nfs4_refresh_open_stateid(nfs4_stateid *dst,
 		struct nfs4_state *state);
+extern bool nfs4_copy_open_stateid(nfs4_stateid *dst,
+		struct nfs4_state *state);
 
 extern struct nfs_seqid *nfs_alloc_seqid(struct nfs_seqid_counter *counter, gfp_t gfp_mask);
 extern int nfs_wait_on_sequence(struct nfs_seqid *seqid, struct rpc_task *task);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 153e34c5b6e9..fe4a855dc965 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3214,14 +3214,7 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 					task->tk_msg.rpc_cred);
 			/* Fallthrough */
 		case -NFS4ERR_BAD_STATEID:
-			if (!nfs4_stateid_match(&calldata->arg.stateid,
-						&state->open_stateid)) {
-				rpc_restart_call_prepare(task);
-				goto out_release;
-			}
-			if (calldata->arg.fmode == 0)
-				break;
-			/* Fallthrough */
+			break;
 		default:
 			if (nfs4_async_handle_error(task, server, state, NULL) == -EAGAIN) {
 				rpc_restart_call_prepare(task);
@@ -3253,7 +3246,6 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 	is_rdwr = test_bit(NFS_O_RDWR_STATE, &state->flags);
 	is_rdonly = test_bit(NFS_O_RDONLY_STATE, &state->flags);
 	is_wronly = test_bit(NFS_O_WRONLY_STATE, &state->flags);
-	nfs4_stateid_copy(&calldata->arg.stateid, &state->open_stateid);
 	/* Calculate the change in open mode */
 	calldata->arg.fmode = 0;
 	if (state->n_rdwr == 0) {
@@ -3271,7 +3263,7 @@ static void nfs4_close_prepare(struct rpc_task *task, void *data)
 		calldata->arg.fmode |= FMODE_READ|FMODE_WRITE;
 
 	if (!nfs4_valid_open_stateid(state) ||
-	    test_bit(NFS_OPEN_STATE, &state->flags) == 0)
+	    !nfs4_refresh_open_stateid(&calldata->arg.stateid, state))
 		call_close = 0;
 	spin_unlock(&state->owner->so_lock);
 
@@ -3365,6 +3357,8 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	calldata->inode = state->inode;
 	calldata->state = state;
 	calldata->arg.fh = NFS_FH(state->inode);
+	if (!nfs4_copy_open_stateid(&calldata->arg.stateid, state))
+		goto out_free_calldata;
 	/* Serialization for the sequence id */
 	alloc_seqid = server->nfs_client->cl_mvops->alloc_seqid;
 	calldata->arg.seqid = alloc_seqid(&state->owner->so_seqid, gfp_mask);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 752b18e88266..d5d52f32e301 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1002,18 +1002,23 @@ bool nfs4_refresh_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 	return ret;
 }
 
-static void nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
+bool nfs4_copy_open_stateid(nfs4_stateid *dst, struct nfs4_state *state)
 {
+	bool ret;
 	const nfs4_stateid *src;
 	int seq;
 
 	do {
+		ret = false;
 		src = &zero_stateid;
 		seq = read_seqbegin(&state->seqlock);
-		if (test_bit(NFS_OPEN_STATE, &state->flags))
+		if (test_bit(NFS_OPEN_STATE, &state->flags)) {
 			src = &state->open_stateid;
+			ret = true;
+		}
 		nfs4_stateid_copy(dst, src);
 	} while (read_seqretry(&state->seqlock, seq));
+	return ret;
 }
 
 /*
-- 
2.13.6
