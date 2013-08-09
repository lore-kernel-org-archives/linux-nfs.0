Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f169.google.com ([209.85.213.169]:54696 "EHLO
	mail-ye0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968210Ab3HIQvT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:51:19 -0400
Received: by mail-ye0-f169.google.com with SMTP id r13so1309192yen.28
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:51:19 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id f67sm20692582yhh.9.2013.08.09.09.51.18
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:51:18 -0700 (PDT)
Subject: [PATCH v2 24/33] NFS: Add basic migration support to state manager
 thread
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:51:17 -0400
Message-ID: <20130809165117.5362.64435.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
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
 fs/nfs/nfs4state.c        |  150 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    7 ++
 4 files changed, 160 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 3495c66..2920746 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -29,6 +29,7 @@ enum nfs4_client_state {
 	NFS4CLNT_SERVER_SCOPE_MISMATCH,
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
+	NFS4CLNT_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -355,6 +356,7 @@ extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
+extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 55d4ff5..f6eacb4 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -81,6 +81,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+	clp->cl_mig_gen = 1;
 	return clp;
 
 error:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index d816d93..9443b67 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1189,6 +1189,48 @@ void nfs4_schedule_lease_recovery(struct nfs_client *clp)
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
@@ -1819,6 +1861,107 @@ static int nfs4_purge_lease(struct nfs_client *clp)
 	return 0;
 }
 
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
+		goto out;
+	}
+
+	inode = server->super->s_root->d_inode;
+	result = nfs4_proc_get_locations(inode, locations, page);
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
+	struct nfs_server *server;
+
+	dprintk("%s: migration reported on \"%s\"\n", __func__,
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
+		if (status < 0)
+			return status;
+		goto restart;
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
 /**
  * nfs4_discover_server_trunking - Detect server IP address trunking
  *
@@ -2147,6 +2290,13 @@ static void nfs4_state_manager(struct nfs_client *clp)
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
index 8064980..557f96c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -77,6 +77,7 @@ struct nfs_client {
 	char			cl_ipaddr[48];
 	u32			cl_cb_ident;	/* v4.0 callback identifier */
 	const struct nfs4_minor_version_ops *cl_mvops;
+	unsigned long		cl_mig_gen;
 
 	/* NFSv4.0 transport blocking */
 	struct nfs4_slot_table	*cl_slot_tbl;
@@ -178,6 +179,12 @@ struct nfs_server {
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

