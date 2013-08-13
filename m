Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:8875 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759239Ab3HMUhw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 16:37:52 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 6/7] nfs4.1: Add SP4_MACH_CRED write and commit support
Date: Tue, 13 Aug 2013 16:37:37 -0400
Message-ID: <1376426258-28244-7-git-send-email-dros@netapp.com>
In-Reply-To: <1376426258-28244-1-git-send-email-dros@netapp.com>
References: <1376426258-28244-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

WRITE and COMMIT can use the machine credential.

If WRITE is supported and COMMIT is not, make all (mach cred) writes FILE_SYNC4.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h          | 50 ++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4proc.c         | 10 ++++++++++
 fs/nfs/write.c            |  6 ++++++
 include/linux/nfs_fs_sb.h |  2 ++
 4 files changed, 59 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 77b5c9f..2a631aa 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -273,15 +273,9 @@ is_ds_client(struct nfs_client *clp)
 	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
 }
 
-/*
- * Function responsible for determining if an rpc_message should use the
- * machine cred under SP4_MACH_CRED and if so switching the credential and
- * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
- * Should be called before rpc_call_sync/rpc_call_async.
- */
-static inline void
-nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
-		   struct rpc_clnt **clntp, struct rpc_message *msg)
+static inline bool
+_nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
+		    struct rpc_clnt **clntp, struct rpc_message *msg)
 {
 	struct rpc_cred *newcred = NULL;
 	rpc_authflavor_t flavor;
@@ -299,7 +293,37 @@ nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 		WARN_ON(flavor != RPC_AUTH_GSS_KRB5I &&
 			flavor != RPC_AUTH_GSS_KRB5P);
 		*clntp = clp->cl_rpcclient;
+
+		return true;
 	}
+	return false;
+}
+
+/*
+ * Function responsible for determining if an rpc_message should use the
+ * machine cred under SP4_MACH_CRED and if so switching the credential and
+ * authflavor (using the nfs_client's rpc_clnt which will be krb5i/p).
+ * Should be called before rpc_call_sync/rpc_call_async.
+ */
+static inline void
+nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
+		   struct rpc_clnt **clntp, struct rpc_message *msg)
+{
+	_nfs4_state_protect(clp, sp4_mode, clntp, msg);
+}
+
+/*
+ * Special wrapper to nfs4_state_protect for write.
+ * If WRITE can use machine cred but COMMIT cannot, make sure all writes
+ * that use machine cred use NFS_FILE_SYNC.
+ */
+static inline void
+nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
+			 struct rpc_message *msg, struct nfs_write_data *wdata)
+{
+	if (_nfs4_state_protect(clp, NFS_SP4_MACH_CRED_WRITE, clntp, msg) &&
+	    !test_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags))
+		wdata->args.stable = NFS_FILE_SYNC;
 }
 #else /* CONFIG_NFS_v4_1 */
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
@@ -332,6 +356,12 @@ nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_flags,
 		   struct rpc_clnt **clntp, struct rpc_message *msg)
 {
 }
+
+static inline void
+nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
+			 struct rpc_message *msg, struct nfs_write_data *wdata)
+{
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
@@ -462,6 +492,8 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 
 #define nfs4_close_state(a, b) do { } while (0)
 #define nfs4_close_sync(a, b) do { } while (0)
+#define nfs4_state_protect(a, b, c, d) do { } while (0)
+#define nfs4_state_protect_write(a, b, c, d) do { } while (0)
 
 #endif /* CONFIG_NFS_V4 */
 #endif /* __LINUX_FS_NFS_NFS4_FS.H */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index b8e668a..1e8a4c0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6025,6 +6025,16 @@ static int nfs4_sp4_select_mode(struct nfs_client *clp,
 			dfprintk(MOUNT, "  stateid mode enabled\n");
 			set_bit(NFS_SP4_MACH_CRED_STATEID, &clp->cl_sp4_flags);
 		}
+
+		if (test_bit(OP_WRITE, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  write mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_WRITE, &clp->cl_sp4_flags);
+		}
+
+		if (test_bit(OP_COMMIT, sp->allow.u.longs)) {
+			dfprintk(MOUNT, "  commit mode enabled\n");
+			set_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags);
+		}
 	}
 
 	return 0;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index f1bdb72..0ff6dfe 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -993,6 +993,9 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		data->args.count,
 		(unsigned long long)data->args.offset);
 
+	nfs4_state_protect_write(NFS_SERVER(inode)->nfs_client,
+				 &task_setup_data.rpc_client, &msg, data);
+
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task)) {
 		ret = PTR_ERR(task);
@@ -1458,6 +1461,9 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
+	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
+
 	task = rpc_run_task(&task_setup_data);
 	if (IS_ERR(task))
 		return PTR_ERR(task);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 010feab..f2aa366 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -94,6 +94,8 @@ struct nfs_client {
 #define NFS_SP4_MACH_CRED_CLEANUP  2	/* CLOSE and LOCKU */
 #define NFS_SP4_MACH_CRED_SECINFO  3	/* SECINFO and SECINFO_NO_NAME */
 #define NFS_SP4_MACH_CRED_STATEID  4	/* TEST_STATEID and FREE_STATEID */
+#define NFS_SP4_MACH_CRED_WRITE    5	/* WRITE */
+#define NFS_SP4_MACH_CRED_COMMIT   6	/* COMMIT */
 #endif /* CONFIG_NFS_V4 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.12.4 (Apple Git-37)

