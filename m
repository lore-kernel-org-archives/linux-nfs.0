Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f178.google.com ([209.85.160.178]:39922 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817Ab3GLQdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:33:40 -0400
Received: by mail-gh0-f178.google.com with SMTP id g15so3257913ghb.9
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:33:40 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id j63sm68999257yhh.17.2013.07.12.09.33.39
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:33:39 -0700 (PDT)
Subject: [PATCH v1 15/19] NFS: Add basic migration support to state manager
 thread
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:33:38 -0400
Message-ID: <20130712163338.1444.23823.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Migration recovery and state recovery must be serialized, so handle
both in the state manager thread.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h          |    2 
 fs/nfs/nfs4client.c       |    1 
 fs/nfs/nfs4state.c        |  186 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    6 +
 4 files changed, 195 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 66c34c4..6391b94 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -30,6 +30,7 @@ enum nfs4_client_state {
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 	NFS4CLNT_BLOCK_XPRT,
+	NFS4CLNT_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -348,6 +349,7 @@ extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
+extern int nfs4_schedule_migration_recovery(struct inode *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index dadd118..5050349 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -76,6 +76,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 		init_completion(&clp->cl_xpcomplete);
 		rpc_init_wait_queue(&clp->cl_xpwaitq, "NFSv4.0 xprt");
 	}
+	clp->cl_mig_gen = 1;
 	return clp;
 
 error:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ae482b2..4757188 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1210,6 +1210,54 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
 }
 EXPORT_SYMBOL_GPL(nfs4_schedule_lease_recovery);
 
+/**
+ * nfs4_schedule_migration_recovery - trigger migration recovery
+ *
+ * @inode: file residing on FSID that is migrating
+ *
+ * Returns zero if recovery has started, otherwise a negative NFS4ERR
+ * value is returned.
+ */
+int nfs4_schedule_migration_recovery(struct inode *inode)
+{
+	struct nfs_server *server;
+	struct nfs_client *clp;
+
+	if (inode == NULL) {
+		pr_err("%s: no inode for migration recovery\n",
+			__func__);
+		WARN_ON(1);
+		return -NFS4ERR_IO;
+	}
+ 	server = NFS_SERVER(inode);
+	clp = server->nfs_client;
+
+	if (test_bit(NFS_CS_MIGRATION, &clp->cl_flags) == 0) {
+		pr_err("NFS: migration not supported (server %s)\n",
+				clp->cl_hostname);
+		return -NFS4ERR_IO;
+	}
+
+	if (server->fh_expire_type != NFS4_FH_PERSISTENT) {
+		pr_err("NFS: volatile file handles not supported (server %s)\n",
+				clp->cl_hostname);
+		return -NFS4ERR_IO;
+	}
+
+	dprintk("%s: scheduling migration recovery for (%llx:%llx) on %s\n",
+			__func__,
+			(unsigned long long)server->fsid.major,
+			(unsigned long long)server->fsid.minor,
+			clp->cl_hostname);
+
+	set_bit(NFS_MIG_IN_TRANSITION, &server->mig_status);
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
@@ -1833,6 +1881,137 @@ static int nfs4_purge_lease(struct nfs_client *clp)
 	return 0;
 }
 
+#ifdef CONFIG_NFS_V4_1
+static int nfs4_begin_drain(struct nfs_client *clp)
+{
+	if (clp->cl_session == NULL)
+		return nfs4_begin_drain_xprt(clp);
+	return nfs4_begin_drain_session(clp);
+}
+
+static void nfs4_end_drain(struct nfs_client *clp)
+{
+	if (clp->cl_session == NULL)
+		nfs4_end_drain_xprt(clp);
+	else
+		nfs4_end_drain_session(clp);
+}
+#else	/* CONFIG_NFS_V4_1 */
+static int nfs4_begin_drain(struct nfs_client *clp)
+{
+	return nfs4_begin_drain_xprt(clp);
+}
+
+static void nfs4_end_drain(struct nfs_client *clp)
+{
+	nfs4_end_drain_xprt(clp);
+}
+#endif	/* CONFIG_NFS_V4_1 */
+
+/*
+ * Try remote migration of one FSID from a source server to a
+ * destination server.  The source server provides a list of
+ * potential destinations.
+ *
+ * Returns zero or a negative NFS4ERR status code.
+ */
+static int nfs4_try_migration(struct nfs_server *server)
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
+		goto out_err;
+	}
+
+	inode = server->super->s_root->d_inode;
+	result = nfs4_proc_get_locations(inode, locations, page);
+	if (result != NFS4_OK) {
+		dprintk("<-- %s: failed to retrieve fs_locations: %d\n",
+			__func__, result);
+		goto out_err;
+	}
+	if (!(locations->fattr.valid & NFS_ATTR_FATTR_V4_LOCATIONS)) {
+		dprintk("<-- %s: No fs_locations data available, "
+			"migration skipped\n", __func__);
+		goto out_err;
+	}
+
+	status = nfs4_begin_drain(clp);
+	if (status != 0) {
+		dprintk("<-- %s: failed to drain transport: %d\n",
+			__func__, status);
+		nfs4_end_drain(clp);
+		goto out_err;
+	}
+
+	status = nfs4_replace_transport(server, locations);
+	nfs4_end_drain(clp);
+	if (status != 0) {
+		dprintk("<-- %s: failed to replace transport: %d\n",
+			__func__, status);
+		goto out_err;
+	}
+
+	dprintk("<-- %s: migration succeeded\n", __func__);
+
+out_err:
+	if (page != NULL)
+		__free_page(page);
+	kfree(locations);
+	return result;
+}
+
+/*
+ * Returns zero or a negative NFS4ERR status code.
+ */
+static int nfs4_handle_migration(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	dprintk("--> %s: migration reported on \"%s\"\n", __func__,
+			clp->cl_hostname);
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
+		status = nfs4_try_migration(server);
+		if (status < 0) {
+			dprintk("<-- %s: %d\n", __func__, status);
+			return status;
+		}
+		goto restart;
+	}
+	rcu_read_unlock();
+
+	dprintk("<-- %s\n", __func__);
+	return 0;
+}
+
 /**
  * nfs4_discover_server_trunking - Detect server IP address trunking
  *
@@ -2163,6 +2342,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			status = nfs4_check_lease(clp);
 			if (status < 0)
 				goto out_error;
+		}
+
+		if (test_and_clear_bit(NFS4CLNT_MOVED, &clp->cl_state)) {
+			section = "migration";
+			status = nfs4_handle_migration(clp);
+			if (status < 0)
+				goto out_error;
 			continue;
 		}
 
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 84d8f0c..4cfc58a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -77,6 +77,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
+	unsigned long		cl_mig_gen;
 
 	atomic_t		cl_xppending;
 	struct completion	cl_xpcomplete;
@@ -174,6 +175,11 @@ struct nfs_server {
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
+
+	unsigned long		mig_gen;
+	unsigned long		mig_status;
+#define NFS_MIG_IN_TRANSITION		(1)
+
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */

