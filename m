Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:64943 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754199Ab1EITiq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:38:46 -0400
Received: by gwaa18 with SMTP id a18so1910407gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:38:46 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/16] NFS: Add migration recovery callouts in nfs4proc.c
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:38:43 -0400
Message-ID: <20110509193843.16568.66482.stgit@matisse.1015granger.net>
In-Reply-To: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
References: <20110509192522.16568.59082.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Finally, to enable support for migration, insert migration recovery
callouts in the synchronous and asynchronous error handling paths for
NFSv4 procedures.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4proc.c |   67 +++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1168bb2..a545d46 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -72,10 +72,11 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
-static int _nfs4_proc_lookup(struct rpc_clnt *client, struct inode *dir,
-			     const struct qstr *name, struct nfs_fh *fhandle,
-			     struct nfs_fattr *fattr);
+static int nfs4_async_handle_error(struct rpc_task *, struct nfs_server *,
+				struct nfs4_state *);
+static int _nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir,
+		const struct qstr *name, struct nfs_fh *fhandle,
+		struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
@@ -247,10 +248,17 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 	return res;
 }
 
-/* This is the error handling routine for processes that are allowed
- * to sleep.
+/**
+ * nfs4_handle_exception - Common error handling for callers allowed to sleep
+ *
+ * @server: local state context for the server
+ * @errorcode: NFS4ERR value returned from the server
+ * @exception: exception handling state
+ *
+ * Returns zero on success, or a negative errno value.
  */
-static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+static int nfs4_handle_exception(struct nfs_server *server, int errorcode,
+				 struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state *state = exception->state;
@@ -286,6 +294,9 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			exception->retry = 1;
 			break;
 #endif /* defined(CONFIG_NFS_V4_1) */
+		case -NFS4ERR_MOVED:
+			nfs4_schedule_migration_recovery(server);
+			goto wait_on_recovery;
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -2283,10 +2294,14 @@ static int nfs4_get_referral(struct inode *dir, const struct qstr *name, struct
 	status = nfs4_proc_fs_locations(dir, name, locations, page);
 	if (status != 0)
 		goto out;
-	/* Make sure server returned a different fsid for the referral */
+
+	/*
+	 * If the fsid didn't change, this is a migration event, not a
+	 * referral.  Cause us to drop into the exception handler, which
+	 * will kick off migration recovery.
+	 */
 	if (nfs_fsid_equal(&NFS_SERVER(dir)->fsid, &locations->fattr.fsid)) {
-		dprintk("%s: server did not return a different fsid for a referral at %s\n", __func__, name->name);
-		status = -EIO;
+		status = -NFS4ERR_MOVED;
 		goto out;
 	}
 
@@ -3655,8 +3670,18 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 	return err;
 }
 
-static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
+/**
+ * nfs4_async_handle_error - Common error handling for callers who cannot sleep
+ *
+ * @task: active RPC task
+ * @server: local state for the server
+ * @state: NFSv4 state for active operation
+ *
+ * Returns zero on success, or a negative errno value.
+ */
+static int nfs4_async_handle_error(struct rpc_task *task,
+				   struct nfs_server *server,
+				   struct nfs4_state *state)
 {
 	struct nfs_client *clp = server->nfs_client;
 
@@ -3686,19 +3711,24 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			dprintk("%s ERROR %d, Reset session\n", __func__,
 				task->tk_status);
 			nfs4_schedule_session_recovery(clp->cl_session);
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 #endif /* CONFIG_NFS_V4_1 */
+		case -NFS4ERR_MOVED:
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+			nfs4_schedule_migration_recovery(server);
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
+							&clp->cl_state) == 0)
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
+									task);
+			goto restart_call;
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 		case -NFS4ERR_OLD_STATEID:
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
@@ -3706,6 +3736,7 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;
 }

