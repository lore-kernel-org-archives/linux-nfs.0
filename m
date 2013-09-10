Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14399 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751243Ab3IJS4H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 14:56:07 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 1/2] NFSv4.1: clean up after using machine cred
Date: Tue, 10 Sep 2013 14:55:57 -0400
Message-ID: <1378839358-10389-2-git-send-email-dros@netapp.com>
In-Reply-To: <1378839358-10389-1-git-send-email-dros@netapp.com>
References: <1378839358-10389-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Client calls get_rpccred when referencing the machine cred, so it must call
put_rpccred after passing cred to rpc layer.

This patch also moves nfs4_sp4_init (formerly nfs4_state_protect) to right
before the call to rpc_run_task (and wrappers of rpc_run_task) to minimize
error path cleanup code.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4_fs.h  | 58 ++++++++++++++++++++++++++++++++++++-------------------
 fs/nfs/nfs4proc.c | 52 +++++++++++++++++++++++++++++++++----------------
 fs/nfs/write.c    | 18 +++++++++++------
 3 files changed, 85 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f520a11..63e3936 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -269,9 +269,10 @@ is_ds_client(struct nfs_client *clp)
 	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
 }
 
-static inline bool
-_nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
-		    struct rpc_clnt **clntp, struct rpc_message *msg)
+static inline void
+_nfs4_sp4_init(struct nfs_client *clp, unsigned long sp4_mode,
+	       struct rpc_clnt **clntp, struct rpc_message *msg,
+	       bool *did_sp4)
 {
 	struct rpc_cred *newcred = NULL;
 	rpc_authflavor_t flavor;
@@ -290,9 +291,9 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 			flavor != RPC_AUTH_GSS_KRB5P);
 		*clntp = clp->cl_rpcclient;
 
-		return true;
-	}
-	return false;
+		*did_sp4 = true;
+	} else
+		*did_sp4 = false;
 }
 
 /*
@@ -302,25 +303,34 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
  * Should be called before rpc_call_sync/rpc_call_async.
  */
 static inline void
-nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
-		   struct rpc_clnt **clntp, struct rpc_message *msg)
+nfs4_sp4_init(struct nfs_client *clp, unsigned long sp4_mode,
+	      struct rpc_clnt **clntp, struct rpc_message *msg,
+	      bool *did_sp4)
 {
-	_nfs4_state_protect(clp, sp4_mode, clntp, msg);
+	_nfs4_sp4_init(clp, sp4_mode, clntp, msg, did_sp4);
 }
 
 /*
- * Special wrapper to nfs4_state_protect for write.
+ * Special wrapper to nfs4_sp4_init for write.
  * If WRITE can use machine cred but COMMIT cannot, make sure all writes
  * that use machine cred use NFS_FILE_SYNC.
  */
 static inline void
-nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
-			 struct rpc_message *msg, struct nfs_write_data *wdata)
+nfs4_sp4_write_init(struct nfs_client *clp, struct rpc_clnt **clntp,
+		    struct rpc_message *msg, struct nfs_write_data *wdata,
+		    bool *did_sp4)
 {
-	if (_nfs4_state_protect(clp, NFS_SP4_MACH_CRED_WRITE, clntp, msg) &&
-	    !test_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags))
+	_nfs4_sp4_init(clp, NFS_SP4_MACH_CRED_WRITE, clntp, msg, did_sp4);
+	if (*did_sp4 && !test_bit(NFS_SP4_MACH_CRED_COMMIT, &clp->cl_sp4_flags))
 		wdata->args.stable = NFS_FILE_SYNC;
 }
+
+static inline void
+nfs4_sp4_cleanup(struct rpc_message *msg, bool did_sp4)
+{
+	if (did_sp4)
+		put_rpccred(msg->rpc_cred);
+}
 #else /* CONFIG_NFS_v4_1 */
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
@@ -340,14 +350,20 @@ is_ds_client(struct nfs_client *clp)
 }
 
 static inline void
-nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_flags,
-		   struct rpc_clnt **clntp, struct rpc_message *msg)
+nfs4_sp4_init(struct nfs_client *clp, unsigned long sp4_flags,
+	      struct rpc_clnt **clntp, struct rpc_message *msg, bool *did_sp4)
+{
+}
+
+static inline void
+nfs4_sp4_write_init(struct nfs_client *clp, struct rpc_clnt **clntp,
+		    struct rpc_message *msg, struct nfs_write_data *wdata,
+		    bool *did_sp4)
 {
 }
 
 static inline void
-nfs4_state_protect_write(struct nfs_client *clp, struct rpc_clnt **clntp,
-			 struct rpc_message *msg, struct nfs_write_data *wdata)
+nfs4_sp4_cleanup(struct rpc_message *msg, bool did_sp4)
 {
 }
 #endif /* CONFIG_NFS_V4_1 */
@@ -485,8 +501,10 @@ static inline bool nfs4_valid_open_stateid(const struct nfs4_state *state)
 
 #define nfs4_close_state(a, b) do { } while (0)
 #define nfs4_close_sync(a, b) do { } while (0)
-#define nfs4_state_protect(a, b, c, d) do { } while (0)
-#define nfs4_state_protect_write(a, b, c, d) do { } while (0)
+/* nfs4_sp4_*_init sets bool "did_sp4" to avoid warning */
+#define nfs4_sp4_init(a, b, c, d, e) (*e = false)
+#define nfs4_sp4_write_init(a, b, c, d, e) (*e = false)
+#define nfs4_sp4_cleanup(a, b) do { } while (0)
 
 #endif /* CONFIG_NFS_V4 */
 #endif /* __LINUX_FS_NFS_NFS4_FS.H */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 39b6cf2..ee0d1eb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2615,9 +2615,7 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 		.flags = RPC_TASK_ASYNC,
 	};
 	int status = -ENOMEM;
-
-	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_CLEANUP,
-		&task_setup_data.rpc_client, &msg);
+	bool did_sp4;
 
 	calldata = kzalloc(sizeof(*calldata), gfp_mask);
 	if (calldata == NULL)
@@ -2642,7 +2640,12 @@ int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait)
 	msg.rpc_argp = &calldata->arg;
 	msg.rpc_resp = &calldata->res;
 	task_setup_data.callback_data = calldata;
+
+	nfs4_sp4_init(server->nfs_client, NFS_SP4_MACH_CRED_CLEANUP,
+		&task_setup_data.rpc_client, &msg, &did_sp4);
 	task = rpc_run_task(&task_setup_data);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	status = 0;
@@ -5242,9 +5245,8 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 		.workqueue = nfsiod_workqueue,
 		.flags = RPC_TASK_ASYNC,
 	};
-
-	nfs4_state_protect(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
-		NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg);
+	struct rpc_task *task;
+	bool did_sp4;
 
 	/* Ensure this is an unlock - when canceling a lock, the
 	 * canceled lock is passed in, and it won't be an unlock.
@@ -5261,7 +5263,14 @@ static struct rpc_task *nfs4_do_unlck(struct file_lock *fl,
 	msg.rpc_argp = &data->arg;
 	msg.rpc_resp = &data->res;
 	task_setup_data.callback_data = data;
-	return rpc_run_task(&task_setup_data);
+
+	nfs4_sp4_init(NFS_SERVER(lsp->ls_state->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_CLEANUP, &task_setup_data.rpc_client, &msg,
+		&did_sp4);
+	task = rpc_run_task(&task_setup_data);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
+	return task;
 }
 
 static int nfs4_proc_unlck(struct nfs4_state *state, int cmd, struct file_lock *request)
@@ -6001,6 +6010,7 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 		.rpc_resp = &res,
 	};
 	struct rpc_clnt *clnt = NFS_SERVER(dir)->client;
+	bool did_sp4;
 
 	if (use_integrity) {
 		clnt = NFS_SERVER(dir)->nfs_client->cl_rpcclient;
@@ -6009,11 +6019,12 @@ static int _nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct
 
 	dprintk("NFS call  secinfo %s\n", name->name);
 
-	nfs4_state_protect(NFS_SERVER(dir)->nfs_client,
-		NFS_SP4_MACH_CRED_SECINFO, &clnt, &msg);
-
+	nfs4_sp4_init(NFS_SERVER(dir)->nfs_client,
+		NFS_SP4_MACH_CRED_SECINFO, &clnt, &msg, &did_sp4);
 	status = nfs4_call_sync(clnt, NFS_SERVER(dir), &msg, &args.seq_args,
 				&res.seq_res, 0);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
 	dprintk("NFS reply  secinfo: %d\n", status);
 
 	if (msg.rpc_cred)
@@ -7609,15 +7620,18 @@ static int _nfs41_test_stateid(struct nfs_server *server,
 		.rpc_cred = cred,
 	};
 	struct rpc_clnt *rpc_client = server->client;
-
-	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
-		&rpc_client, &msg);
+	bool did_sp4;
 
 	dprintk("NFS call  test_stateid %p\n", stateid);
 	nfs4_init_sequence(&args.seq_args, &res.seq_res, 0);
 	nfs4_set_sequence_privileged(&args.seq_args);
+
+	nfs4_sp4_init(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
+		&rpc_client, &msg, &did_sp4);
 	status = nfs4_call_sync_sequence(rpc_client, server, &msg,
 			&args.seq_args, &res.seq_res);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
 	if (status != NFS_OK) {
 		dprintk("NFS reply test_stateid: failed, %d\n", status);
 		return status;
@@ -7707,9 +7721,8 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 		.flags = RPC_TASK_ASYNC,
 	};
 	struct nfs_free_stateid_data *data;
-
-	nfs4_state_protect(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
-		&task_setup.rpc_client, &msg);
+	struct rpc_task *task;
+	bool did_sp4;
 
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc(sizeof(*data), GFP_NOFS);
@@ -7726,7 +7739,12 @@ static struct rpc_task *_nfs41_free_stateid(struct nfs_server *server,
 	if (privileged)
 		nfs4_set_sequence_privileged(&data->args.seq_args);
 
-	return rpc_run_task(&task_setup);
+	nfs4_sp4_init(server->nfs_client, NFS_SP4_MACH_CRED_STATEID,
+		&task_setup.rpc_client, &msg, &did_sp4);
+	task = rpc_run_task(&task_setup);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
+	return task;
 }
 
 /**
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index ac1dc33..da306c0 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1010,6 +1010,7 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		.priority = priority,
 	};
 	int ret = 0;
+	bool did_sp4;
 
 	/* Set up the initial task struct.  */
 	NFS_PROTO(inode)->write_setup(data, &msg);
@@ -1022,10 +1023,11 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 		data->args.count,
 		(unsigned long long)data->args.offset);
 
-	nfs4_state_protect_write(NFS_SERVER(inode)->nfs_client,
-				 &task_setup_data.rpc_client, &msg, data);
-
+	nfs4_sp4_write_init(NFS_SERVER(inode)->nfs_client,
+			    &task_setup_data.rpc_client, &msg, data, &did_sp4);
 	task = rpc_run_task(&task_setup_data);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
 	if (IS_ERR(task)) {
 		ret = PTR_ERR(task);
 		goto out;
@@ -1486,15 +1488,19 @@ int nfs_initiate_commit(struct rpc_clnt *clnt, struct nfs_commit_data *data,
 		.flags = RPC_TASK_ASYNC | flags,
 		.priority = priority,
 	};
+	bool did_sp4;
+
 	/* Set up the initial task struct.  */
 	NFS_PROTO(data->inode)->commit_setup(data, &msg);
 
 	dprintk("NFS: %5u initiated commit call\n", data->task.tk_pid);
 
-	nfs4_state_protect(NFS_SERVER(data->inode)->nfs_client,
-		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg);
-
+	nfs4_sp4_init(NFS_SERVER(data->inode)->nfs_client,
+		NFS_SP4_MACH_CRED_COMMIT, &task_setup_data.rpc_client, &msg,
+		&did_sp4);
 	task = rpc_run_task(&task_setup_data);
+	nfs4_sp4_cleanup(&msg, did_sp4);
+
 	if (IS_ERR(task))
 		return PTR_ERR(task);
 	if (how & FLUSH_SYNC)
-- 
1.7.12.4 (Apple Git-37)

