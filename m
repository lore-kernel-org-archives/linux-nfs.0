Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50973 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753662Ab1CJRas (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:30:48 -0500
Received: by mail-iy0-f174.google.com with SMTP id 26so1753948iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:30:48 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] NFS: Implement support for NFS4ERR_LEASE_MOVED
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:30:46 -0500
Message-ID: <20110310173046.8878.58550.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

To recover from NFS4ERR_LEASE_MOVED, walk the cl_superblocks list and
invoke nfs4_handle_migration() on each server's root file handle.
nfs4_handle_migration() should automatically determine whether that
file system has migrated, and then perform recovery for it.

The per-filesystem migration probe also informs minor version zero
servers that this client should no longer receive NFS4ERR_LEASE_MOVED.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    1 +
 fs/nfs/nfs4_fs.h          |    2 ++
 fs/nfs/nfs4proc.c         |   10 ++++++++
 fs/nfs/nfs4state.c        |   56 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    2 ++
 5 files changed, 70 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a2f016a..f628526 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -179,6 +179,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	clp->cl_mig_counter = 1;
 #endif
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d8724bf..dc976bd 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_MOVED,
+	NFS4CLNT_LEASE_MOVED,
 };
 
 enum nfs4_session_state {
@@ -312,6 +313,7 @@ extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
 extern void nfs4_schedule_migration_recovery(struct nfs_server *);
+extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 711b8ce..e139778 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -288,6 +288,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode,
 		case -NFS4ERR_MOVED:
 			nfs4_schedule_migration_recovery(server);
 			goto recovery_wait;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto recovery_wait;
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -3557,6 +3560,13 @@ static int nfs4_async_handle_error(struct rpc_task *task,
 							&clp->cl_state) == 0)
 				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
 			goto restart_call;
+		case -NFS4ERR_LEASE_MOVED:
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+			nfs4_schedule_lease_moved_recovery(clp);
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
+							&clp->cl_state) == 0)
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+			goto restart_call;
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a788ec9..e2a83e8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -60,6 +60,8 @@
 
 #define OPENOWNER_POOL_SIZE	8
 
+static void nfs4_handle_lease_moved(struct nfs_client *clp);
+
 const nfs4_stateid zero_stateid;
 
 static LIST_HEAD(nfs4_clientid_list);
@@ -1044,6 +1046,23 @@ void nfs4_schedule_migration_recovery(struct nfs_server *server)
 	dprintk("<-- %s\n", __func__);
 }
 
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
 int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
 {
 
@@ -1349,11 +1368,13 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			nfs4_state_end_reclaim_reboot(clp);
 			return 0;
 		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
 			break;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_handle_lease_moved(clp);
+			return 0;
 		case -NFS4ERR_EXPIRED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_start_reclaim_nograce(clp);
@@ -1519,6 +1540,34 @@ out:
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
+restart:
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		if (server->mig_counter != clp->cl_mig_counter) {
+			server->mig_counter = clp->cl_mig_counter;
+			rcu_read_unlock();
+			nfs4_try_migration(server);
+			goto restart;
+		}
+	rcu_read_unlock();
+
+	dprintk("<-- %s\n", __func__);
+}
+
 #ifdef CONFIG_NFS_V4_1
 void nfs41_handle_recall_slot(struct nfs_client *clp)
 {
@@ -1748,6 +1797,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state)) {
+			nfs4_handle_lease_moved(clp);
+			continue;
+		}
+
 		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
 			nfs4_try_migration(clp->cl_moved_server);
 			continue;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 3741928..0ce4aad 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -57,6 +57,7 @@ struct nfs_client {
 
 	/* accessed only when NFS4CLNT_MOVED bit is set */
 	struct nfs_server *	cl_moved_server;
+	unsigned long		cl_mig_counter;
 
 	/* used for the setclientid verifier */
 	struct timespec		cl_boot_time;
@@ -157,6 +158,7 @@ struct nfs_server {
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
 	struct nfs_fh		*rootfh;
+	unsigned long		mig_counter;
 
 	atomic_t active; /* Keep trace of any activity to this server */
 

