Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:23285 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762199Ab3JQSNh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:37 -0400
Received: from ucsinet21.oracle.com (ucsinet21.oracle.com [156.151.31.93])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HIDaFh013739
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:36 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by ucsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HIDZHr007447
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:36 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/21] NFS: Support NFS4ERR_LEASE_MOVED recovery in state manager
Date: Thu, 17 Oct 2013 14:13:35 -0400
Message-Id: <20131017181335.1073.50738.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A migration on the FSID in play for the current NFS operation
is reported via the error status code NFS4ERR_MOVED.

"Lease moved" means that a migration has occurred on some other
FSID than the one for the current operation.  It's a signal that
the client should take action immediately to handle a migration
that it may not have noticed otherwise.  This is so that the
client's lease does not expire unnoticed on the destination server.

In NFSv4.0, a moved lease is reported with the NFS4ERR_LEASE_MOVED
error status code.

To recover from NFS4ERR_LEASE_MOVED, check each FSID for that server
to see if it is still present.  Invoke nfs4_try_migration() if the
FSID is no longer present on the server.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h   |    2 +
 fs/nfs/nfs4state.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 74 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 2f0f8c2..210e44e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -30,6 +30,7 @@ enum nfs4_client_state {
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 	NFS4CLNT_MOVED,
+	NFS4CLNT_LEASE_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -425,6 +426,7 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
+extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b66163f..3fbce1f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1233,6 +1233,22 @@ int nfs4_schedule_migration_recovery(const struct nfs_server *server)
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
@@ -1664,7 +1680,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			nfs4_state_end_reclaim_reboot(clp);
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
@@ -1978,6 +1993,55 @@ restart:
 	return 0;
 }
 
+/*
+ * Test each nfs_server on the clp's cl_superblocks list to see
+ * if it's moved to another server.  Stop when the server no longer
+ * returns NFS4ERR_LEASE_MOVED.
+ */
+static int nfs4_handle_lease_moved(struct nfs_client *clp)
+{
+	const struct nfs4_state_maintenance_ops *ops =
+				clp->cl_mvops->state_renewal_ops;
+	struct nfs_server *server;
+	struct rpc_cred *cred;
+
+	dprintk("%s: lease moved reported on \"%s\"\n", __func__,
+			clp->cl_hostname);
+
+	spin_lock(&clp->cl_lock);
+	cred = ops->get_state_renewal_cred_locked(clp);
+	spin_unlock(&clp->cl_lock);
+	if (cred == NULL)
+		return -NFS4ERR_NOENT;
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
+		status = nfs4_proc_fsid_present(inode, cred);
+		if (status != -NFS4ERR_MOVED)
+			goto restart;	/* wasn't this one */
+		if (nfs4_try_migration(server, cred) == -NFS4ERR_LEASE_MOVED)
+			goto restart;	/* there are more */
+		goto out;
+	}
+	rcu_read_unlock();
+
+out:
+	put_rpccred(cred);
+	return 0;
+}
+
 /**
  * nfs4_discover_server_trunking - Detect server IP address trunking
  *
@@ -2315,6 +2379,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				goto out_error;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state)) {
+			section = "lease moved";
+			status = nfs4_handle_lease_moved(clp);
+			if (status < 0)
+				goto out_error;
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			section = "reclaim reboot";

