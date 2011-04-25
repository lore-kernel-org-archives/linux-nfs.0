Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:41311 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758842Ab1DYSpn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:45:43 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so2054039iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:45:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/15] NFS: Implement support for NFS4ERR_LEASE_MOVED
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:45:40 -0400
Message-ID: <20110425184540.5669.7973.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To recover from NFS4ERR_LEASE_MOVED, walk the cl_superblocks list and
invoke nfs4_try_migration() on each server's root file handle.
nfs4_try_migration() should automatically determine whether that file
system has migrated, and then perform recovery for it.

The per-filesystem migration probe also informs minor version zero
servers that this client should no longer receive NFS4ERR_LEASE_MOVED.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    2 +
 fs/nfs/nfs4proc.c         |   11 ++++++++
 fs/nfs/nfs4state.c        |   63 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    2 +
 5 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index eb5cf55..f32f9b0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -188,6 +188,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	if (cl_init->long_clientid != NULL)
 		clp->cl_cached_clientid = kstrdup(cl_init->long_clientid,
 							GFP_KERNEL);
+	clp->cl_mig_counter = 1;
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 153e69d..ebb3c5e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -50,6 +50,7 @@ enum nfs4_client_state {
 	NFS4CLNT_UPDATE_CALLBACK,
 	NFS4CLNT_CLONED_CLIENT,
 	NFS4CLNT_MOVED,
+	NFS4CLNT_LEASE_MOVED,
 };
 
 enum nfs4_session_state {
@@ -350,6 +351,7 @@ extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
 extern void nfs4_schedule_migration_recovery(struct nfs_server *);
+extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4e6afc7..75c1221 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -296,6 +296,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode,
 		case -NFS4ERR_MOVED:
 			nfs4_schedule_migration_recovery(server);
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -3693,6 +3696,14 @@ static int nfs4_async_handle_error(struct rpc_task *task,
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
 									task);
 			goto restart_call;
+		case -NFS4ERR_LEASE_MOVED:
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+			nfs4_schedule_lease_moved_recovery(clp);
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
+							&clp->cl_state) == 0)
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
+									task);
+			goto restart_call;
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 6819e92..4a44a29 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1049,7 +1049,32 @@ void nfs4_schedule_migration_recovery(struct nfs_server *server)
 	dprintk("<-- %s\n", __func__);
 }
 
-static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
+/**
+ * nfs4_schedule_lease_moved_recovery - start lease moved recovery
+ *
+ * @clp: nfs_client of server that may have migrated file systems
+ *
+ */
+void nfs4_schedule_lease_moved_recovery(struct nfs_client *clp)
+{
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
+	if (test_and_set_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state) == 0)
+		nfs4_schedule_state_manager(clp);
+
+	dprintk("<-- %s\n", __func__);
+}
+
+/**
+ * nfs4_state_mark_reclaim_reboot - Mark nfs_client for reboot recovery
+ * @clp: nfs_client of server that may have rebooted
+ * @state: state flags to test
+ *
+ * Returns 1 if reboot recovery is needed.
+ */
+int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp,
+				   struct nfs4_state *state)
 {
 
 	set_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);
@@ -1362,7 +1387,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			nfs4_state_end_reclaim_reboot(clp);
 			return 0;
 		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
@@ -1575,6 +1599,37 @@ out_err:
 	kfree(locations);
 }
 
+static void nfs4_handle_lease_moved(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
+	/*
+	 * rcu_read_lock() must be dropped before trying each individual
+	 * migration.  cl_mig_counter is used to skip servers that have
+	 * already been visited for this lease_moved event when the list
+	 * walk is restarted.
+	 */
+	clp->cl_mig_counter++;
+
+restart:
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		if (server->mig_counter != clp->cl_mig_counter) {
+			server->mig_counter = clp->cl_mig_counter;
+			rcu_read_unlock();
+			nfs4_try_migration(server);
+			/* Ask the server if there's more work to do */
+			if (nfs4_check_lease(clp) == NFS4ERR_LEASE_MOVED)
+				goto restart;
+			break;
+		}
+	rcu_read_unlock();
+	dprintk("<-- %s\n", __func__);
+}
+
 #ifdef CONFIG_NFS_V4_1
 void nfs4_schedule_session_recovery(struct nfs4_session *session)
 {
@@ -1789,6 +1844,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			nfs4_try_migration(clp->cl_moved_server);
 			continue;
 		}
+		if (test_and_clear_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state)) {
+			nfs4_handle_lease_moved(clp);
+			continue;
+		}
 
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 56c1ad7..c0eb3da 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -59,6 +59,7 @@ struct nfs_client {
 
 	/* accessed only when NFS4CLNT_MOVED bit is set */
 	struct nfs_server *	cl_moved_server;
+	unsigned long		cl_mig_counter;
 
 	/* used for the setclientid verifier */
 	struct timespec		cl_boot_time;
@@ -155,6 +156,7 @@ struct nfs_server {
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
 	struct nfs_fh		*rootfh;
+	unsigned long		mig_counter;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

