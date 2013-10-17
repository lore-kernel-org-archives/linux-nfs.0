Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:22975 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758877Ab3JQSND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:13:03 -0400
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by userp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id r9HID2d6013270
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:03 GMT
Received: from nfsvm18.us.oracle.com (nfsvm18.us.oracle.com [10.135.198.118])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id r9HID2GU011464
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 18:13:02 GMT
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/21] NFS: Add basic migration support to state manager thread
Date: Thu, 17 Oct 2013 14:13:02 -0400
Message-Id: <20131017181302.1073.19351.stgit@nfsvm18.us.oracle.com>
In-Reply-To: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
References: <20131017180630.1073.18400.stgit@nfsvm18.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Migration recovery and state recovery must be serialized, so handle
both in the state manager thread.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h          |    2 +
 fs/nfs/nfs4client.c       |    1 
 fs/nfs/nfs4state.c        |  161 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_fs_sb.h |    7 ++
 4 files changed, 168 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index e59d3b4..94e783f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -29,6 +29,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
+	NFS4CLNT_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -421,6 +422,7 @@ extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
+extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b19c94f..b510f4f 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -197,6 +197,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	clp->cl_mig_gen = 1;
 	return clp;
 
 error:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index cc14cbb..b66163f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -239,8 +239,6 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
-#if defined(CONFIG_NFS_V4_1)
-
 static int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
 {
 	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
@@ -270,6 +268,8 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 	return nfs4_drain_slot_tbl(&ses->fc_slot_table);
 }
 
+#if defined(CONFIG_NFS_V4_1)
+
 static int nfs41_setup_state_renewal(struct nfs_client *clp)
 {
 	int status;
@@ -1197,6 +1197,42 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_lease_recovery);
 
+/**
+ * nfs4_schedule_migration_recovery - trigger migration recovery
+ *
+ * @server: FSID that is migrating
+ *
+ * Returns zero if recovery has started, otherwise a negative NFS4ERR
+ * value is returned.
+ */
+int nfs4_schedule_migration_recovery(const struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+
+	if (server->fh_expire_type != NFS4_FH_PERSISTENT) {
+		pr_err("NFS: volatile file handles not supported (server %s)\n",
+				clp->cl_hostname);
+		return -NFS4ERR_IO;
+	}
+
+	if (test_bit(NFS_MIG_FAILED, &server->mig_status))
+		return -NFS4ERR_IO;
+
+	dprintk("%s: scheduling migration recovery for (%llx:%llx) on %s\n",
+			__func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			clp->cl_hostname);
+
+	set_bit(NFS_MIG_IN_TRANSITION,
+			&((struct nfs_server *)server)->mig_status);
+	set_bit(NFS4CLNT_MOVED, &clp->cl_state);
+
+	nfs4_schedule_state_manager(clp);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nfs4_schedule_migration_recovery);
+
 int nfs4_wait_clnt_recover(struct nfs_client *clp)
 {
 	int res;
@@ -1829,6 +1865,119 @@ static int nfs4_purge_lease(struct nfs_client *clp)
 	return 0;
 }
 
+/*
+ * Try remote migration of one FSID from a source server to a
+ * destination server.  The source server provides a list of
+ * potential destinations.
+ *
+ * Returns zero or a negative NFS4ERR status code.
+ */
+static int nfs4_try_migration(struct nfs_server *server, struct rpc_cred *cred)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_fs_locations *locations = NULL;
+	struct inode *inode;
+	struct page *page;
+	int status, result;
+
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			clp->cl_hostname);
+
+	result = 0;
+	page = alloc_page(GFP_KERNEL);
+	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (page == NULL || locations == NULL) {
+		dprintk("<-- %s: no memory\n", __func__);
+		goto out;
+	}
+
+	inode = server->super->s_root->d_inode;
+	result = nfs4_proc_get_locations(inode, locations, page, cred);
+	if (result) {
+		dprintk("<-- %s: failed to retrieve fs_locations: %d\n",
+			__func__, result);
+		goto out;
+	}
+
+	result = -NFS4ERR_NXIO;
+	if (!(locations->fattr.valid & NFS_ATTR_FATTR_V4_LOCATIONS)) {
+		dprintk("<-- %s: No fs_locations data, migration skipped\n",
+			__func__);
+		goto out;
+	}
+
+	nfs4_begin_drain_session(clp);
+
+	status = nfs4_replace_transport(server, locations);
+	if (status != 0) {
+		dprintk("<-- %s: failed to replace transport: %d\n",
+			__func__, status);
+		goto out;
+	}
+
+	result = 0;
+	dprintk("<-- %s: migration succeeded\n", __func__);
+
+out:
+	if (page != NULL)
+		__free_page(page);
+	kfree(locations);
+	if (result) {
+		pr_err("NFS: migration recovery failed (server %s)\n",
+				clp->cl_hostname);
+		set_bit(NFS_MIG_FAILED, &server->mig_status);
+	}
+	return result;
+}
+
+/*
+ * Returns zero or a negative NFS4ERR status code.
+ */
+static int nfs4_handle_migration(struct nfs_client *clp)
+{
+	const struct nfs4_state_maintenance_ops *ops =
+				clp->cl_mvops->state_renewal_ops;
+	struct nfs_server *server;
+	struct rpc_cred *cred;
+
+	dprintk("%s: migration reported on \"%s\"\n", __func__,
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
+		int status;
+
+		if (server->mig_gen == clp->cl_mig_gen)
+			continue;
+		server->mig_gen = clp->cl_mig_gen;
+
+		if (!test_and_clear_bit(NFS_MIG_IN_TRANSITION,
+						&server->mig_status))
+			continue;
+
+		rcu_read_unlock();
+		status = nfs4_try_migration(server, cred);
+		if (status < 0) {
+			put_rpccred(cred);
+			return status;
+		}
+		goto restart;
+	}
+	rcu_read_unlock();
+	put_rpccred(cred);
+	return 0;
+}
+
 /**
  * nfs4_discover_server_trunking - Detect server IP address trunking
  *
@@ -2157,7 +2306,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			status = nfs4_check_lease(clp);
 			if (status < 0)
 				goto out_error;
-			continue;
+		}
+
+		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
+			section = "migration";
+			status = nfs4_handle_migration(clp);
+			if (status < 0)
+				goto out_error;
 		}
 
 		/* First recover reboot state... */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index a1c80a2..c7a11bc 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -78,6 +78,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
+	unsigned long		cl_mig_gen;
 
 	/* NFSv4.0 transport blocking */
 	struct nfs4_slot_table	*cl_slot_tbl;
@@ -188,6 +189,12 @@ struct nfs_server {
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
+
+	unsigned long		mig_gen;
+	unsigned long		mig_status;
+#define NFS_MIG_IN_TRANSITION		(1)
+#define NFS_MIG_FAILED			(2)
+
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */

