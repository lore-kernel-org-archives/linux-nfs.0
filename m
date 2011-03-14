Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:52145 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1CNM5v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:57:51 -0400
Received: by mail-iy0-f174.google.com with SMTP id 26so4900509iyb.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:57:51 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] NFS: Add basic migration support to state manager thread
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:57:48 -0400
Message-ID: <20110314125748.2413.23771.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Migration recovery will be handled separately from the normal
synchronous and asynchronous NFS processes, much like the existing
state manager thread.  In fact state and migration recovery will
have to be serialized.

The best approach, then, is to add migration recovery support to
the existing state manager infrastructure, reusing its rendevous
mechanism and finite state machine.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4_fs.h          |    2 +
 fs/nfs/nfs4state.c        |   96 ++++++++++++++++++++++++++++++++++++++++++---
 include/linux/nfs_fs_sb.h |    3 +
 3 files changed, 94 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b746a51..8049c62 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -48,6 +48,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_UPDATE_CLIENTID,
+	NFS4CLNT_MOVED,
 };
 
 enum nfs4_session_state {
@@ -311,6 +312,7 @@ extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
+extern void nfs4_schedule_migration_recovery(struct nfs_server *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e6742b5..a4e69c3 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -56,6 +56,8 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
@@ -1013,9 +1015,32 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
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
 
 int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
@@ -1435,6 +1460,67 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
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
+		goto out;
+	}
+
+	status = nfs4_proc_get_mig_status(server, locations, page);
+	if (status != 0) {
+		dprintk("<-- %s: get migration status: %d\n",
+			__func__, status);
+		goto out;
+	}
+	if (!(locations->fattr.valid & NFS_ATTR_FATTR_V4_LOCATIONS)) {
+		dprintk("<-- %s: No fs_locations data available, "
+			"migration skipped\n", __func__);
+		goto out;
+	}
+
+	status = nfs4_replace_transport(server, locations);
+	if (status != 0) {
+		dprintk("<-- %s: failed to replace transport: %d\n",
+			__func__, status);
+		goto out;
+	}
+
+	/* XXX: Update pieces of our client ID.  NB: The cl_ipaddr is still
+	 * in the nfs_client... maybe it needs to be moved to the nfs_server? */
+
+	/* Force an update of our callback info on the destination server */
+	set_bit(NFS4CLNT_UPDATE_CLIENTID, &clp->cl_state);
+
+	/* XXX: would like to update /proc/mounts, but that's entirely
+	 *      optional. */
+
+	dprintk("<-- %s: migration succeeded\n", __func__);
+
+out:
+	if (page != NULL)
+		__free_page(page);
+	kfree(locations);
+}
+
 #ifdef CONFIG_NFS_V4_1
 void nfs41_handle_recall_slot(struct nfs_client *clp)
 {
@@ -1624,6 +1710,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state))
+			nfs4_try_migration(clp->cl_moved_server);
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			status = nfs4_do_reclaim(clp,
@@ -1664,7 +1753,6 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
-
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
 		if (clp->cl_state == 0)
@@ -1690,9 +1778,3 @@ static int nfs4_run_state_manager(void *ptr)
 	module_put_and_exit(0);
 	return 0;
 }
-
-/*
- * Local variables:
- *  c-basic-offset: 8
- * End:
- */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 961ee85..3741928 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -55,6 +55,9 @@ struct nfs_client {
 
 	struct rpc_wait_queue	cl_rpcwaitq;
 
+	/* accessed only when NFS4CLNT_MOVED bit is set */
+	struct nfs_server *	cl_moved_server;
+
 	/* used for the setclientid verifier */
 	struct timespec		cl_boot_time;
 

