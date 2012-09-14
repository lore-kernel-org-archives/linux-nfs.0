Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:55468 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755345Ab2INVLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 17:11:34 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/5] SUNRPC handle EKEYEXPIRED in call_refreshresult
Date: Fri, 14 Sep 2012 17:11:45 -0400
Message-Id: <1347657109-2180-2-git-send-email-andros@netapp.com>
In-Reply-To: <1347657109-2180-1-git-send-email-andros@netapp.com>
References: <1347657109-2180-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Currently, when an RPCSEC_GSS context has expired or is non-existent
and the users (Kerberos) credentials have also expired or are non-existent,
the client receives the -EKEYEXPIRED error and tries to refresh the context
forever.  If an application is performing I/O, or other work against the share,
the application hangs, and the user is not prompted to refresh/establish their
credentials. This can result in a denial of service for other users.

Users are expected to manage their Kerberos credential lifetimes to mitigate
this issue.

Move the -EKEYEXPIRED handling into the RPC layer. Try tk_cred_retry number
of times to refresh the gss_context, and then return -EACCES to the application.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs3proc.c       |    6 +++---
 fs/nfs/nfs4filelayout.c |    1 -
 fs/nfs/nfs4proc.c       |   18 ------------------
 fs/nfs/nfs4state.c      |   22 ----------------------
 fs/nfs/proc.c           |   43 -------------------------------------------
 net/sunrpc/clnt.c       |    1 +
 6 files changed, 4 insertions(+), 87 deletions(-)

diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 6932209..70efb63 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -24,14 +24,14 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
-/* A wrapper to handle the EJUKEBOX and EKEYEXPIRED error messages */
+/* A wrapper to handle the EJUKEBOX error messages */
 static int
 nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 {
 	int res;
 	do {
 		res = rpc_call_sync(clnt, msg, flags);
-		if (res != -EJUKEBOX && res != -EKEYEXPIRED)
+		if (res != -EJUKEBOX)
 			break;
 		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
 		res = -ERESTARTSYS;
@@ -44,7 +44,7 @@ nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
 static int
 nfs3_async_handle_jukebox(struct rpc_task *task, struct inode *inode)
 {
-	if (task->tk_status != -EJUKEBOX && task->tk_status != -EKEYEXPIRED)
+	if (task->tk_status != -EJUKEBOX)
 		return 0;
 	if (task->tk_status == -EJUKEBOX)
 		nfs_inc_stats(inode, NFSIOS_DELAY);
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 53f94d9..000e01e 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -169,7 +169,6 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		break;
 	case -NFS4ERR_DELAY:
 	case -NFS4ERR_GRACE:
-	case -EKEYEXPIRED:
 		rpc_delay(task, FILELAYOUT_POLL_RETRY_MAX);
 		break;
 	case -NFS4ERR_RETRY_UNCACHED_REP:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1e50326..16c5b18 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -344,7 +344,6 @@ static int nfs4_handle_exception(struct nfs_server *server, int errorcode, struc
 			}
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
-		case -EKEYEXPIRED:
 			ret = nfs4_delay(server->client, &exception->timeout);
 			if (ret != 0)
 				break;
@@ -1374,13 +1373,6 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state
 				nfs_inode_find_state_and_recover(state->inode,
 						stateid);
 				nfs4_schedule_stateid_recovery(server, state);
-			case -EKEYEXPIRED:
-				/*
-				 * User RPCSEC_GSS context has expired.
-				 * We cannot recover this stateid now, so
-				 * skip it and allow recovery thread to
-				 * proceed.
-				 */
 			case -ENOMEM:
 				err = 0;
 				goto out;
@@ -3970,7 +3962,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server,
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
 		case -NFS4ERR_GRACE:
-		case -EKEYEXPIRED:
 			rpc_delay(task, NFS4_POLL_RETRY_MAX);
 			task->tk_status = 0;
 			return -EAGAIN;
@@ -4944,15 +4935,6 @@ int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl)
 				nfs4_schedule_stateid_recovery(server, state);
 				err = 0;
 				goto out;
-			case -EKEYEXPIRED:
-				/*
-				 * User RPCSEC_GSS context has expired.
-				 * We cannot recover this stateid now, so
-				 * skip it and allow recovery thread to
-				 * proceed.
-				 */
-				err = 0;
-				goto out;
 			case -ENOMEM:
 			case -NFS4ERR_DENIED:
 				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 55148de..8e7207e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1315,14 +1315,6 @@ restart:
 				/* Mark the file as being 'closed' */
 				state->state = 0;
 				break;
-			case -EKEYEXPIRED:
-				/*
-				 * User RPCSEC_GSS context has expired.
-				 * We cannot recover this stateid now, so
-				 * skip it and allow recovery thread to
-				 * proceed.
-				 */
-				break;
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_BAD_STATEID:
@@ -1475,14 +1467,6 @@ static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
 	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
 }
 
-static void nfs4_warn_keyexpired(const char *s)
-{
-	printk_ratelimited(KERN_WARNING "Error: state manager"
-			" encountered RPCSEC_GSS session"
-			" expired against NFSv4 server %s.\n",
-			s);
-}
-
 static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 {
 	switch (error) {
@@ -1516,10 +1500,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
 		case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
 			set_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
 			break;
-		case -EKEYEXPIRED:
-			/* Nothing we can do */
-			nfs4_warn_keyexpired(clp->cl_hostname);
-			break;
 		default:
 			dprintk("%s: failed to handle error %d for server %s\n",
 					__func__, error, clp->cl_hostname);
@@ -1632,8 +1612,6 @@ static int nfs4_handle_reclaim_lease_error(struct nfs_client *clp, int status)
 		dprintk("%s: exit with error %d for server %s\n",
 				__func__, -EPROTONOSUPPORT, clp->cl_hostname);
 		return -EPROTONOSUPPORT;
-	case -EKEYEXPIRED:
-		nfs4_warn_keyexpired(clp->cl_hostname);
 	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
 				 * in nfs4_exchange_id */
 	default:
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 50a88c3..f084dac 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -47,39 +47,6 @@
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
 /*
- * wrapper to handle the -EKEYEXPIRED error message. This should generally
- * only happen if using krb5 auth and a user's TGT expires. NFSv2 doesn't
- * support the NFSERR_JUKEBOX error code, but we handle this situation in the
- * same way that we handle that error with NFSv3.
- */
-static int
-nfs_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
-{
-	int res;
-	do {
-		res = rpc_call_sync(clnt, msg, flags);
-		if (res != -EKEYEXPIRED)
-			break;
-		freezable_schedule_timeout_killable(NFS_JUKEBOX_RETRY_TIME);
-		res = -ERESTARTSYS;
-	} while (!fatal_signal_pending(current));
-	return res;
-}
-
-#define rpc_call_sync(clnt, msg, flags)	nfs_rpc_wrapper(clnt, msg, flags)
-
-static int
-nfs_async_handle_expired_key(struct rpc_task *task)
-{
-	if (task->tk_status != -EKEYEXPIRED)
-		return 0;
-	task->tk_status = 0;
-	rpc_restart_call(task);
-	rpc_delay(task, NFS_JUKEBOX_RETRY_TIME);
-	return 1;
-}
-
-/*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
 static int
@@ -364,8 +331,6 @@ static void nfs_proc_unlink_rpc_prepare(struct rpc_task *task, struct nfs_unlink
 
 static int nfs_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
-	if (nfs_async_handle_expired_key(task))
-		return 0;
 	nfs_mark_for_revalidate(dir);
 	return 1;
 }
@@ -385,8 +350,6 @@ static int
 nfs_proc_rename_done(struct rpc_task *task, struct inode *old_dir,
 		     struct inode *new_dir)
 {
-	if (nfs_async_handle_expired_key(task))
-		return 0;
 	nfs_mark_for_revalidate(old_dir);
 	nfs_mark_for_revalidate(new_dir);
 	return 1;
@@ -642,9 +605,6 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct inode *inode = data->header->inode;
 
-	if (nfs_async_handle_expired_key(task))
-		return -EAGAIN;
-
 	nfs_invalidate_atime(inode);
 	if (task->tk_status >= 0) {
 		nfs_refresh_inode(inode, data->res.fattr);
@@ -671,9 +631,6 @@ static int nfs_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->header->inode;
 
-	if (nfs_async_handle_expired_key(task))
-		return -EAGAIN;
-
 	if (task->tk_status >= 0)
 		nfs_post_op_update_inode_force_wcc(inode, data->res.fattr);
 	return 0;
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index fa48c60..a15b96c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1343,6 +1343,7 @@ call_refreshresult(struct rpc_task *task)
 		return;
 	case -ETIMEDOUT:
 		rpc_delay(task, 3*HZ);
+	case -EKEYEXPIRED:
 	case -EAGAIN:
 		status = -EACCES;
 		if (!task->tk_cred_retry)
-- 
1.7.7.6

