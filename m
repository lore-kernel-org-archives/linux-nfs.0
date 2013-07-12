Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f180.google.com ([209.85.160.180]:48444 "EHLO
	mail-gh0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817Ab3GLQeG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:34:06 -0400
Received: by mail-gh0-f180.google.com with SMTP id f18so3239986ghb.39
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:34:06 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id v68sm69001404yhn.22.2013.07.12.09.34.05
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:34:05 -0700 (PDT)
Subject: [PATCH v1 18/19] NFS: Implement support for NFS4ERR_LEASE_MOVED
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:34:04 -0400
Message-ID: <20130712163404.1444.39607.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To recover from NFS4ERR_LEASE_MOVED, walk the cl_superblocks list and
invoke nfs4_try_migration() on each server's root file handle if that
FSID is no longer present on the server.  The FSID presence check also
informs servers that this client has recognized the LEASE_MOVED
condition and therefore should no longer receive NFS4ERR_LEASE_MOVED.

Minor version 1 servers set a bit flag to signal LEASE_MOVED rather
than returning an NFS4ERR status code, as minor version 0 servers do.
Our client must recognize this flag and kick off migration recovery.
The flag is detected when processing the SEQUENCE reply in each mv1
compound.

Note also that with minor version 0, the asynchronous lease RENEW
heartbeat can return NFS4ERR_LEASE_MOVED.  Error recovery logic for
async RENEW is a separate code path from the generic NFS proc paths,
so it must be updated to handle LEASE_MOVED as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h   |    2 +
 fs/nfs/nfs4proc.c  |   19 +++++++++++++-
 fs/nfs/nfs4state.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 87 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 77313db..9f2fe35 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -31,6 +31,7 @@ enum nfs4_client_state {
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 	NFS4CLNT_BLOCK_XPRT,
 	NFS4CLNT_MOVED,
+	NFS4CLNT_LEASE_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -352,6 +353,7 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern int nfs4_schedule_migration_recovery(struct inode *);
+extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a870a59..80afb9f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -350,6 +350,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode,
 			if (ret < 0)
 				break;
 			goto wait_on_recovery;
+		case -NFS4ERR_LEASE_MOVED:
+			nfs4_schedule_lease_moved_recovery(clp);
+			goto wait_on_recovery;
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -3937,7 +3940,13 @@ static void nfs4_renew_done(struct rpc_task *task, void *calldata)
 	struct nfs_client *clp = data->client;
 	unsigned long timestamp = data->timestamp;
 
-	if (task->tk_status < 0) {
+	switch (task->tk_status) {
+	case 0:
+		break;
+	case -NFS4ERR_LEASE_MOVED:
+		nfs4_schedule_lease_moved_recovery(clp);
+		break;
+	default:
 		/* Unless we're shutting down, schedule state recovery! */
 		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) == 0)
 			return;
@@ -4342,6 +4351,14 @@ static int nfs4_async_handle_error(struct rpc_task *task,
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
index 4757188..ce2b51d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1258,6 +1258,22 @@ int nfs4_schedule_migration_recovery(struct inode *inode)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_migration_recovery);
 
+/**
+ * nfs4_schedule_lease_moved_recovery - start lease-moved recovery
+ *
+ * @clp: server to check for moved leases
+ *
+ */
+void nfs4_schedule_lease_moved_recovery(struct nfs_client *clp)
+{
+	dprintk("%s: scheduling lease-moved recovery for client ID %llx on %s\n",
+		__func__, clp->cl_clientid, clp->cl_hostname);
+
+	set_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state);
+	nfs4_schedule_state_manager(clp);
+}
+EXPORT_SYMBOL_GPL(nfs4_schedule_lease_moved_recovery);
+
 int nfs4_wait_clnt_recover(struct nfs_client *clp)
 {
 	int res;
@@ -1680,7 +1696,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			nfs4_state_end_reclaim_reboot(clp);
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
@@ -2007,7 +2022,46 @@ restart:
 		goto restart;
 	}
 	rcu_read_unlock();
+	dprintk("<-- %s\n", __func__);
+	return 0;
+}
+
+/*
+ * Test each nfs_server on the clp's cl_superblocks list to see
+ * if it's moved to another server.  Stop when the server no longer
+ * returns NFS4ERR_LEASE_MOVED.
+ */
+static int nfs4_handle_lease_moved(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	dprintk("--> %s: \"%s\" (client ID %llx)\n",
+		__func__, clp->cl_hostname, clp->cl_clientid);
+
+	clp->cl_mig_gen++;
+restart:
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		struct inode *inode;
+		int status;
+
+		if (server->mig_gen == clp->cl_mig_gen)
+			continue;
+		server->mig_gen = clp->cl_mig_gen;
+
+		rcu_read_unlock();
+
+		inode = server->super->s_root->d_inode;
+		status = nfs4_proc_fsid_present(inode);
+		if (status != -NFS4ERR_MOVED)
+			goto restart;	/* wasn't this one */
+		if (nfs4_try_migration(server) == -NFS4ERR_LEASE_MOVED)
+			goto restart;	/* there are more */
+		goto out;
+	}
+	rcu_read_unlock();
 
+out:
 	dprintk("<-- %s\n", __func__);
 	return 0;
 }
@@ -2201,9 +2255,10 @@ void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags)
 		nfs41_handle_server_reboot(clp);
 	if (flags & (SEQ4_STATUS_EXPIRED_ALL_STATE_REVOKED |
 			    SEQ4_STATUS_EXPIRED_SOME_STATE_REVOKED |
-			    SEQ4_STATUS_ADMIN_STATE_REVOKED |
-			    SEQ4_STATUS_LEASE_MOVED))
+			    SEQ4_STATUS_ADMIN_STATE_REVOKED))
 		nfs41_handle_state_revoked(clp);
+	if (flags & SEQ4_STATUS_LEASE_MOVED)
+		nfs4_schedule_lease_moved_recovery(clp);
 	if (flags & SEQ4_STATUS_RECALLABLE_STATE_REVOKED)
 		nfs41_handle_recallable_state_revoked(clp);
 	if (flags & SEQ4_STATUS_BACKCHANNEL_FAULT)
@@ -2352,6 +2407,15 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state)) {
+			section = "lease moved";
+			status = nfs4_handle_lease_moved(clp);
+			if (status < 0)
+				goto out_error;
+			clear_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state);
+			continue;
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			section = "reclaim reboot";

