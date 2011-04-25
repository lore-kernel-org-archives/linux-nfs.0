Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60958 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788Ab1DYSpO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:45:14 -0400
Received: by iwn34 with SMTP id 34so2051386iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:45:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/15] NFS: Add basic migration support to state manager thread
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:45:11 -0400
Message-ID: <20110425184511.5669.83830.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Migration recovery will be handled separately from the normal
synchronous and asynchronous NFS processes, much like the existing
state manager thread.  In fact state and migration recovery will
have to be serialized.

Therefore add migration recovery support to the existing state manager
infrastructure, reusing its rendevous mechanism and finite state
machine.

Additional debugging is added so that, while we continue to shape our
migration recovery implementation, the operation of the state manager
is visible.  If the extra clutter is objectionable, it can be removed
once we are confident of the migration recovery implementation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h          |    3 +
 fs/nfs/nfs4state.c        |  149 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    3 +
 3 files changed, 153 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index eba7791..153e69d 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,8 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_UPDATE_CALLBACK,
+	NFS4CLNT_CLONED_CLIENT,
+	NFS4CLNT_MOVED,
 };
 
 enum nfs4_session_state {
@@ -347,6 +349,7 @@ extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
+extern void nfs4_schedule_migration_recovery(struct nfs_server *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 09181b0..6819e92 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -56,6 +56,8 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
@@ -1019,9 +1021,32 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 {
 	if (!clp)
 		return;
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
 	if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		set_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 	nfs4_schedule_state_manager(clp);
+	dprintk("<-- %s\n", __func__);
+}
+
+/**
+ * nfs4_schedule_migration_recovery - start background migration recovery
+ *
+ * @server: nfs_server representing remote file system that is migrating
+ *
+ */
+void nfs4_schedule_migration_recovery(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+
+	dprintk("--> %s(%llx:%llx)\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor);
+	if (test_and_set_bit(NFS4CLNT_MOVED, &clp->cl_state) == 0) {
+		clp->cl_moved_server = server;
+		nfs4_schedule_state_manager(clp);
+	}
+	dprintk("<-- %s\n", __func__);
 }
 
 static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
@@ -1371,6 +1396,9 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
 	struct rb_node *pos;
 	int status = 0;
 
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
@@ -1400,6 +1428,7 @@ restart:
 		spin_unlock(&clp->cl_lock);
 	}
 	rcu_read_unlock();
+	dprintk("<-- %s: %d\n", __func__, status);
 	return status;
 }
 
@@ -1410,6 +1439,9 @@ static int nfs4_check_lease(struct nfs_client *clp)
 		clp->cl_mvops->state_renewal_ops;
 	int status = -NFS4ERR_EXPIRED;
 
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
 	/* Is the client already known to have an expired lease? */
 	if (test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state))
 		return 0;
@@ -1424,7 +1456,9 @@ static int nfs4_check_lease(struct nfs_client *clp)
 	status = ops->renew_lease(clp, cred);
 	put_rpccred(cred);
 out:
-	return nfs4_recovery_handle_error(clp, status);
+	status = nfs4_recovery_handle_error(clp, status);
+	dprintk("<-- %s: %d\n", __func__, status);
+	return status;
 }
 
 static int nfs4_reclaim_lease(struct nfs_client *clp)
@@ -1434,6 +1468,9 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 		clp->cl_mvops->reboot_recovery_ops;
 	int status = -ENOENT;
 
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
 	cred = ops->get_clid_cred(clp);
 	if (cred != NULL) {
 		status = ops->establish_clid(clp, cred);
@@ -1446,9 +1483,98 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
 		if (status == -NFS4ERR_MINOR_VERS_MISMATCH)
 			status = -EPROTONOSUPPORT;
 	}
+	dprintk("<-- %s: %d\n", __func__, status);
+	return status;
+}
+
+/*
+ * If cloning got us a shiny new nfs_client, a RENEW/SETCLIENTID sequence
+ * is needed.  Kick off a state manager thread for the new nfs_client to
+ * handle this, and wait for it to finish.
+ */
+static int nfs4_init_cloned_client(struct nfs_client *clp)
+{
+	int status = 0;
+
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
+	if (test_and_set_bit(NFS4CLNT_CLONED_CLIENT, &clp->cl_state) == 0) {
+		clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		nfs4_schedule_state_manager(clp);
+		status = wait_on_bit(&clp->cl_state, NFS4CLNT_MANAGER_RUNNING,
+				nfs_wait_bit_killable, TASK_KILLABLE);
+	}
+
+	dprintk("<-- %s: %d\n", __func__, status);
 	return status;
 }
 
+/*
+ * Try remote migration of one FSID from a source server to a
+ * destination server.  The source server provides a list of
+ * potential destinations.
+ */
+static void nfs4_try_migration(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_fs_locations *locations = NULL;
+	struct page *page;
+	int status;
+
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			clp->cl_hostname);
+
+	status = -ENOMEM;
+	page = alloc_page(GFP_KERNEL);
+	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (page == NULL || locations == NULL) {
+		dprintk("<-- %s: no memory\n", __func__);
+		goto out_err;
+	}
+
+	status = nfs4_proc_get_mig_status(server, locations, page);
+	if (status != 0) {
+		dprintk("<-- %s: get migration status: %d\n",
+			__func__, status);
+		goto out_err;
+	}
+	if (!(locations->fattr.valid & NFS_ATTR_FATTR_V4_LOCATIONS)) {
+		dprintk("<-- %s: No fs_locations data available, "
+			"migration skipped\n", __func__);
+		goto out_err;
+	}
+
+	/* NB: if successful, nfs4_replace_transport() replaces
+	 *     server->nfs_client with the cloned nfs_client */
+	status = nfs4_replace_transport(server, locations);
+	if (status != 0) {
+		dprintk("<-- %s: failed to replace transport: %d\n",
+			__func__, status);
+		goto out_err;
+	}
+
+	if (server->nfs_client->cl_clientid == 0) {
+		server->nfs_client->cl_clientid = clp->cl_clientid;
+
+		status = nfs4_init_cloned_client(server->nfs_client);
+		if (status != 0) {
+			dprintk("<-- %s: failed to init nfs_client: %d\n",
+				__func__, status);
+			goto out_err;
+		}
+	}
+
+	dprintk("<-- %s: migration succeeded\n", __func__);
+
+out_err:
+	if (page != NULL)
+		__free_page(page);
+	kfree(locations);
+}
+
 #ifdef CONFIG_NFS_V4_1
 void nfs4_schedule_session_recovery(struct nfs4_session *session)
 {
@@ -1606,8 +1732,22 @@ static void nfs4_state_manager(struct nfs_client *clp)
 {
 	int status = 0;
 
+	dprintk("--> %s: \"%s\" (client ID %llx) state: %08lx\n",
+		__func__, clp->cl_hostname, clp->cl_clientid, clp->cl_state);
+
 	/* Ensure exclusive access to NFSv4 state */
 	for(;;) {
+		if (test_and_clear_bit(NFS4CLNT_CLONED_CLIENT,
+							&clp->cl_state)) {
+			/* If the server still recognizes the short-form
+			 * client ID, ensure that the next SETCLIENTID doesn't
+			 * cause the server to drop all that state */
+			if (nfs4_check_lease(clp) == 0)
+				set_bit(NFS4CLNT_UPDATE_CALLBACK,
+							&clp->cl_state);
+			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
+		}
+
 		if (test_and_clear_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state)) {
 			/* We're going to have to re-establish a clientid */
 			status = nfs4_reclaim_lease(clp);
@@ -1645,6 +1785,11 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
+			nfs4_try_migration(clp->cl_moved_server);
+			continue;
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
@@ -1685,7 +1830,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
-
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
 		if (clp->cl_state == 0)
@@ -1693,6 +1837,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			break;
 	}
+	dprintk("<-- %s\n", __func__);
 	return;
 out_error:
 	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 4a4940c..56c1ad7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -57,6 +57,9 @@ struct nfs_client {
 
 	struct rpc_wait_queue	cl_rpcwaitq;
 
+	/* accessed only when NFS4CLNT_MOVED bit is set */
+	struct nfs_server *	cl_moved_server;
+
 	/* used for the setclientid verifier */
 	struct timespec		cl_boot_time;
 

