Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f170.google.com ([209.85.160.170]:34674 "EHLO
	mail-gh0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968218Ab3HIQwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:52:14 -0400
Received: by mail-gh0-f170.google.com with SMTP id z10so1286923ghb.29
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:52:13 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id v68sm20682690yhn.22.2013.08.09.09.52.03
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:52:12 -0700 (PDT)
Subject: [PATCH v2 29/33] NFS: Implement support for NFS4ERR_LEASE_MOVED in
 state manager
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:52:02 -0400
Message-ID: <20130809165202.5362.18066.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To recover from NFS4ERR_LEASE_MOVED, check each FSID for that server
to see if it is still present.  Invoke nfs4_try_migration() if the
FSID is no longer present on the server.

The FSID presence check also informs servers that this client has
recognized the LEASE_MOVED condition and that therefore the server
should no longer assert LEASE_MOVED for that client.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4_fs.h   |    2 ++
 fs/nfs/nfs4state.c |   64 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 65 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b4d7559..5c14712 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -30,6 +30,7 @@ enum nfs4_client_state {
 	NFS4CLNT_PURGE_STATE,
 	NFS4CLNT_BIND_CONN_TO_SESSION,
 	NFS4CLNT_MOVED,
+	NFS4CLNT_LEASE_MOVED,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -359,6 +360,7 @@ extern void nfs4_schedule_state_manager(struct nfs_client *);
 extern void nfs4_schedule_path_down_recovery(struct nfs_client *clp);
 extern int nfs4_schedule_stateid_recovery(const struct nfs_server *, struct nfs4_state *);
 extern int nfs4_schedule_migration_recovery(const struct nfs_server *);
+extern void nfs4_schedule_lease_moved_recovery(struct nfs_client *);
 extern void nfs41_handle_sequence_flag_errors(struct nfs_client *clp, u32 flags);
 extern void nfs41_handle_server_scope(struct nfs_client *,
 				      struct nfs41_server_scope **);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 9443b67..175c0c7 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1231,6 +1231,22 @@ int nfs4_schedule_migration_recovery(const struct nfs_server *server)
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
@@ -1660,7 +1676,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 			nfs4_state_end_reclaim_reboot(clp);
 			break;
 		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_LEASE_MOVED:
 			set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 			nfs4_state_clear_reclaim_reboot(clp);
 			nfs4_state_start_reclaim_reboot(clp);
@@ -1962,6 +1977,45 @@ restart:
 	return 0;
 }
 
+/*
+ * Test each nfs_server on the clp's cl_superblocks list to see
+ * if it's moved to another server.  Stop when the server no longer
+ * returns NFS4ERR_LEASE_MOVED.
+ */
+static int nfs4_handle_lease_moved(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+
+	dprintk("%s: lease moved reported on \"%s\"\n", __func__,
+			clp->cl_hostname);
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
+
+out:
+	return 0;
+}
+
 /**
  * nfs4_discover_server_trunking - Detect server IP address trunking
  *
@@ -2300,6 +2354,14 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			continue;
 		}
 
+		if (test_and_clear_bit(NFS4CLNT_LEASE_MOVED, &clp->cl_state)) {
+			section = "lease moved";
+			status = nfs4_handle_lease_moved(clp);
+			if (status < 0)
+				goto out_error;
+			continue;
+		}
+
 		/* First recover reboot state... */
 		if (test_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state)) {
 			section = "reclaim reboot";

