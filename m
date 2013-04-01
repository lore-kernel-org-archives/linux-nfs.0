Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:31014 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759682Ab3DAUBl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Apr 2013 16:01:41 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4: Clean up delegation recall error handling
Date: Mon,  1 Apr 2013 16:01:33 -0400
Message-Id: <1364846493-11145-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1364846493-11145-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1364846493-11145-1-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-2-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-3-git-send-email-Trond.Myklebust@netapp.com>
 <1364846493-11145-4-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unify the error handling in nfs4_open_delegation_recall and
nfs4_lock_delegation_recall.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c |  6 ++--
 fs/nfs/delegation.h |  2 +-
 fs/nfs/nfs4proc.c   | 79 +++++++++++++++++------------------------------------
 3 files changed, 29 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 6390a4b..fc8a213 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -64,7 +64,7 @@ int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 	return ret;
 }
 
-static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state)
+static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
@@ -83,7 +83,7 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 		if (nfs_file_open_context(fl->fl_file) != ctx)
 			continue;
 		unlock_flocks();
-		status = nfs4_lock_delegation_recall(state, fl);
+		status = nfs4_lock_delegation_recall(fl, state, stateid);
 		if (status < 0)
 			goto out;
 		lock_flocks();
@@ -120,7 +120,7 @@ again:
 		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 		err = nfs4_open_delegation_recall(ctx, state, stateid);
 		if (!err)
-			err = nfs_delegation_claim_locks(ctx, state);
+			err = nfs_delegation_claim_locks(ctx, state, stateid);
 		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			err = -EAGAIN;
 		mutex_unlock(&sp->so_delegreturn_mutex);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index d54d4fc..88573d1 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -53,7 +53,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
 /* NFSv4 delegation-related procedures */
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid);
-int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
+int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid);
 bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b5ebf8c..e3b8848 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1379,19 +1379,8 @@ static int nfs4_open_reclaim(struct nfs4_state_owner *sp, struct nfs4_state *sta
 	return ret;
 }
 
-int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
+static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct nfs4_state *state, const nfs4_stateid *stateid, int err)
 {
-	struct nfs_server *server = NFS_SERVER(state->inode);
-	struct nfs4_opendata *opendata;
-	int err;
-
-	opendata = nfs4_open_recoverdata_alloc(ctx, state,
-			NFS4_OPEN_CLAIM_DELEG_CUR_FH);
-	if (IS_ERR(opendata))
-		return PTR_ERR(opendata);
-	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
-	err = nfs4_open_recover(opendata, state);
-	nfs4_opendata_put(opendata);
 	switch (err) {
 		default:
 			printk(KERN_ERR "NFS: %s: unhandled error "
@@ -1418,20 +1407,40 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 		case -NFS4ERR_DELEG_REVOKED:
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OPENMODE:
 			nfs_inode_find_state_and_recover(state->inode,
 					stateid);
 			nfs4_schedule_stateid_recovery(server, state);
-		case -ENOMEM:
 			return 0;
 		case -NFS4ERR_DELAY:
 		case -NFS4ERR_GRACE:
 			set_bit(NFS_DELEGATED_STATE, &state->flags);
 			ssleep(1);
 			return -EAGAIN;
+		case -ENOMEM:
+		case -NFS4ERR_DENIED:
+			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
+			return 0;
 	}
 	return err;
 }
 
+int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
+{
+	struct nfs_server *server = NFS_SERVER(state->inode);
+	struct nfs4_opendata *opendata;
+	int err;
+
+	opendata = nfs4_open_recoverdata_alloc(ctx, state,
+			NFS4_OPEN_CLAIM_DELEG_CUR_FH);
+	if (IS_ERR(opendata))
+		return PTR_ERR(opendata);
+	nfs4_stateid_copy(&opendata->o_arg.u.delegation, stateid);
+	err = nfs4_open_recover(opendata, state);
+	nfs4_opendata_put(opendata);
+	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
+}
+
 static void nfs4_open_confirm_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_opendata *data = calldata;
@@ -5147,54 +5156,16 @@ nfs4_proc_lock(struct file *filp, int cmd, struct file_lock *request)
 	return status;
 }
 
-int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
+int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state, const nfs4_stateid *stateid)
 {
 	struct nfs_server *server = NFS_SERVER(state->inode);
 	int err;
 
 	err = nfs4_set_lock_state(state, fl);
 	if (err != 0)
-		goto out;
+		return err;
 	err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
-	switch (err) {
-		default:
-			printk(KERN_ERR "NFS: %s: unhandled error "
-				"%d.\n", __func__, err);
-		case 0:
-		case -ESTALE:
-			goto out;
-		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_STALE_STATEID:
-			set_bit(NFS_DELEGATED_STATE, &state->flags);
-		case -NFS4ERR_EXPIRED:
-			nfs4_schedule_lease_recovery(server->nfs_client);
-			return -EAGAIN;
-		case -NFS4ERR_BADSESSION:
-		case -NFS4ERR_BADSLOT:
-		case -NFS4ERR_BAD_HIGH_SLOT:
-		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
-		case -NFS4ERR_DEADSESSION:
-			set_bit(NFS_DELEGATED_STATE, &state->flags);
-			nfs4_schedule_session_recovery(server->nfs_client->cl_session, err);
-			return -EAGAIN;
-		case -NFS4ERR_DELEG_REVOKED:
-		case -NFS4ERR_ADMIN_REVOKED:
-		case -NFS4ERR_BAD_STATEID:
-		case -NFS4ERR_OPENMODE:
-			nfs4_schedule_stateid_recovery(server, state);
-			return 0;
-		case -NFS4ERR_DELAY:
-		case -NFS4ERR_GRACE:
-			set_bit(NFS_DELEGATED_STATE, &state->flags);
-			ssleep(1);
-			return -EAGAIN;
-		case -ENOMEM:
-		case -NFS4ERR_DENIED:
-			/* kill_proc(fl->fl_pid, SIGLOST, 1); */
-			return 0;
-	}
-out:
-	return err;
+	return nfs4_handle_delegation_recall_error(server, state, stateid, err);
 }
 
 struct nfs_release_lockowner_data {
-- 
1.8.1.4

