Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21510 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754004Ab1GHTyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 15:54:54 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Test and Free stateid improvements
Date: Fri,  8 Jul 2011 15:54:37 -0400
Message-Id: <1310154877-24025-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

This patch cleans up TEST_STATEID and FREE_STATEID to use the correct
lock or open stateid.  I also introduce sending SIGIO to applications,
rather than attempting recovery, if TEST_STATEID reports that a lock has
been lost.

Signed-off-by: Bryan Schumaker
---
 fs/nfs/nfs4_fs.h   |    2 ++
 fs/nfs/nfs4proc.c  |   44 ++++++++++++++++++++++++++++++--------------
 fs/nfs/nfs4state.c |   14 ++++++++++++++
 fs/nfs/write.c     |    7 +++++++
 4 files changed, 53 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index c30aed2..8fa02af 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -163,6 +163,7 @@ struct nfs4_lock_state {
 	struct list_head	ls_locks;	/* Other lock stateids */
 	struct nfs4_state *	ls_state;	/* Pointer to open state */
 #define NFS_LOCK_INITIALIZED 1
+#define NFS_LOCK_INVALID     2
 	int			ls_flags;
 	struct nfs_seqid_counter	ls_seqid;
 	struct rpc_sequence	ls_sequence;
@@ -346,6 +347,7 @@ extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
+extern int nfs4_validate_lock_stateid(struct nfs4_state *, struct nfs_lock_context *);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 93ef776..716bde0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -81,8 +81,8 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs4_state *state);
 #ifdef CONFIG_NFS_V4_1
-static int nfs41_test_stateid(struct nfs_server *, struct nfs4_state *);
-static int nfs41_free_stateid(struct nfs_server *, struct nfs4_state *);
+static int nfs41_test_stateid(struct nfs_server *, nfs4_stateid *);
+static int nfs41_free_stateid(struct nfs_server *, nfs4_stateid *);
 #endif
 /* Prevent leaks of NFSv4 errors into userland */
 static int nfs4_map_errors(int err)
@@ -1696,10 +1696,10 @@ static int nfs41_open_expired(struct nfs4_state_owner *sp, struct nfs4_state *st
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, &state->open_stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+	nfs41_free_stateid(server, &state->open_stateid);
 	return nfs4_open_expired(sp, state);
 }
 #endif
@@ -4462,17 +4462,33 @@ out:
 }
 
 #if defined(CONFIG_NFS_V4_1)
+bool enable_sigio = true;
+
 static int nfs41_lock_expired(struct nfs4_state *state, struct file_lock *request)
 {
 	int status;
 	struct nfs_server *server = NFS_SERVER(state->inode);
+	struct nfs4_lock_state *lock_state = request->fl_u.nfs4_fl.owner;
+	nfs4_stateid *stateid = &lock_state->ls_stateid;
 
-	status = nfs41_test_stateid(server, state);
+	status = nfs41_test_stateid(server, stateid);
 	if (status == NFS_OK)
 		return 0;
-	nfs41_free_stateid(server, state);
+
+	nfs41_free_stateid(server, stateid);
+	lock_state->ls_seqid.flags &= !NFS_SEQID_CONFIRMED;
+
+	if (enable_sigio) {
+		lock_state->ls_flags |= NFS_LOCK_INVALID;
+		kill_pid(request->fl_nspid, SIGIO, 1);
+		return 0;
+	}
 	return nfs4_lock_expired(state, request);
 }
+
+module_param(enable_sigio, bool, 0644);
+MODULE_PARM_DESC(enable_sigio, "Send SIGIO to an application when a lost lock "
+			"is detected instead of attempting recovery");
 #endif
 
 static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock *request)
@@ -6046,11 +6062,11 @@ out_freepage:
 out:
 	return err;
 }
-static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int _nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	int status;
 	struct nfs41_test_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_test_stateid_res res;
 	struct rpc_message msg = {
@@ -6063,23 +6079,23 @@ static int _nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *sta
 	return status;
 }
 
-static int nfs41_test_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs41_test_stateid(server, state),
+				_nfs41_test_stateid(server, stateid),
 				&exception);
 	} while (exception.retry);
 	return err;
 }
 
-static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int _nfs4_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	int status;
 	struct nfs41_free_stateid_args args = {
-		.stateid = &state->stateid,
+		.stateid = stateid,
 	};
 	struct nfs41_free_stateid_res res;
 	struct rpc_message msg = {
@@ -6093,13 +6109,13 @@ static int _nfs4_free_stateid(struct nfs_server *server, struct nfs4_state *stat
 	return status;
 }
 
-static int nfs41_free_stateid(struct nfs_server *server, struct nfs4_state *state)
+static int nfs41_free_stateid(struct nfs_server *server, nfs4_stateid *stateid)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
 		err = nfs4_handle_exception(server,
-				_nfs4_free_stateid(server, state),
+				_nfs4_free_stateid(server, stateid),
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5d744a5..101d9b4 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -725,6 +725,20 @@ __nfs4_find_lock_state(struct nfs4_state *state, fl_owner_t fl_owner, pid_t fl_p
 	return NULL;
 }
 
+int nfs4_validate_lock_stateid(struct nfs4_state *state, struct nfs_lock_context *lock_ctx)
+{
+	int valid = 1;
+	struct nfs4_lock_state *lock_state;
+
+	spin_lock(&state->state_lock);
+	lock_state = __nfs4_find_lock_state(state, lock_ctx->lockowner, lock_ctx->pid, NFS4_ANY_LOCK_TYPE);
+	if (lock_state != NULL)
+		valid = (lock_state->ls_flags & NFS_LOCK_INVALID) == 0;
+	spin_unlock(&state->state_lock);
+	nfs4_put_lock_state(lock_state);
+	return valid;
+}
+
 /*
  * Return a compatible lock_state. If no initialized lock_state structure
  * exists, return an uninitialized one.
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 7f8732e..f8da68d 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1114,7 +1114,14 @@ out:
 void nfs_write_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_write_data *data = calldata;
+	struct nfs4_state *state  = data->args.context->state;
+	struct nfs_lock_context *lock_context = data->args.lock_context;
 
+	if (!nfs4_validate_lock_stateid(state, lock_context)) {
+		task->tk_status = -EIO;
+		task->tk_action = NULL;
+		return;
+	}
 	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
 				&data->args.seq_args,
 				&data->res.seq_res, 1, task))
-- 
1.7.6

