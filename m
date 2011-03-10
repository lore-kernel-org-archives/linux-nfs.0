Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50973 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab1CJRaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Mar 2011 12:30:20 -0500
Received: by mail-iy0-f174.google.com with SMTP id 26so1753948iyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Mar 2011 09:30:20 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFS: Add basic migration support to state manager thread
To: linux-nfs@vger.kernel.org
Date: Thu, 10 Mar 2011 12:30:18 -0500
Message-ID: <20110310173018.8878.71092.stgit@matisse.1015granger.net>
In-Reply-To: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
References: <20110310171345.8878.25548.stgit@matisse.1015granger.net>
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
 fs/nfs/nfs4state.c        |   94 ++++++++++++++++++++++++++++++++++++++++++---
 include/linux/nfs_fs_sb.h |    3 +
 3 files changed, 93 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 253156e..d8724bf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -47,6 +47,7 @@ enum nfs4_client_state {
 	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
+	NFS4CLNT_MOVED,
 };
 
 enum nfs4_session_state {
@@ -310,6 +311,7 @@ extern void nfs4_close_state(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, fmode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, fmode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
+extern void nfs4_schedule_migration_recovery(struct nfs_server *);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e6742b5..a788ec9 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -56,6 +56,8 @@
 #include "internal.h"
 #include "pnfs.h"
 
+#define NFSDBG_FACILITY		NFSDBG_CLIENT
+
 #define OPENOWNER_POOL_SIZE	8
 
 const nfs4_stateid zero_stateid;
@@ -1013,9 +1015,33 @@ void nfs4_schedule_state_recovery(struct nfs_client *clp)
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
+		set_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+		clp->cl_moved_server = server;
+		nfs4_schedule_state_manager(clp);
+	}
+	dprintk("<-- %s\n", __func__);
 }
 
 int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_state *state)
@@ -1435,6 +1461,64 @@ static int nfs4_reclaim_lease(struct nfs_client *clp)
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
+	/* Force an update of our callback info on the destination server */
+	set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
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
@@ -1664,6 +1748,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
+			nfs4_try_migration(clp->cl_moved_server);
+			continue;
+		}
 
 		nfs4_clear_state_manager_bit(clp);
 		/* Did we race with an attempt to give us more work? */
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
 

