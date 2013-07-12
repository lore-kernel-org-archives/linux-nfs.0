Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f42.google.com ([209.85.213.42]:33849 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964817Ab3GLQli (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:41:38 -0400
Received: by mail-yh0-f42.google.com with SMTP id c41so3774620yho.1
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:41:37 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id o32sm69037743yhi.5.2013.07.12.09.33.47
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:33:48 -0700 (PDT)
Subject: [PATCH v1 16/19] NFS: Add migration recovery callouts in nfs4proc.c
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:33:47 -0400
Message-ID: <20130712163347.1444.7637.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When the server returns NFS4ERR_MOVED, trigger the new migration
recovery logic in the state manager.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |   56 +++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 45 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c849721..b75629a 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -275,10 +275,17 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
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
@@ -338,6 +345,11 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			nfs4_schedule_session_recovery(clp->cl_session, errorcode);
 			goto wait_on_recovery;
 #endif /* defined(CONFIG_NFS_V4_1) */
+		case -NFS4ERR_MOVED:
+			ret = nfs4_schedule_migration_recovery(inode);
+			if (ret < 0)
+				break;
+			goto wait_on_recovery;
 		case -NFS4ERR_FILE_OPEN:
 			if (exception->timeout > HZ) {
 				/* We have retried a decent amount, time to
@@ -2763,11 +2775,16 @@ static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
 	status = nfs4_proc_fs_locations(client, dir, name, locations, page);
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
 		dprintk("%s: server did not return a different fsid for"
 			" a referral at %s\n", __func__, name->name);
-		status = -EIO;
+		status = -NFS4ERR_MOVED;
 		goto out;
 	}
 	/* Fixup attributes for the nfs_lookup() call to nfs_fhget() */
@@ -4263,8 +4280,18 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
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
+				   const struct nfs_server *server,
+				   struct nfs4_state *state)
 {
 	struct nfs_client *clp = server->nfs_client;
 
@@ -4306,16 +4333,22 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 			task->tk_status = 0;
 			return -EAGAIN;
 #endif /* CONFIG_NFS_V4_1 */
+		case -NFS4ERR_MOVED:
+			rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
+			if (nfs4_schedule_migration_recovery(state->inode) < 0)
+				goto stateid_invalid;
+			if (test_bit(NFS4CLNT_MANAGER_RUNNING,
+							&clp->cl_state) == 0)
+				rpc_wake_up_queued_task(&clp->cl_rpcwaitq,
+									task);
+			goto restart_call;
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
-			task->tk_status = 0;
-			return -EAGAIN;
 		case -NFS4ERR_RETRY_UNCACHED_REP:
 		case -NFS4ERR_OLD_STATEID:
-			task->tk_status = 0;
-			return -EAGAIN;
+			goto restart_call;
 	}
 	task->tk_status = nfs4_map_errors(task->tk_status);
 	return 0;
@@ -4326,6 +4359,7 @@ wait_on_recovery:
 	rpc_sleep_on(&clp->cl_rpcwaitq, task, NULL);
 	if (test_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) == 0)
 		rpc_wake_up_queued_task(&clp->cl_rpcwaitq, task);
+restart_call:
 	task->tk_status = 0;
 	return -EAGAIN;
 }

