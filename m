From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 29/69] NFSv4: Add recovery for individual stateids
Date: Tue, 23 Dec 2008 18:02:14 -0500
Message-ID: <20081223230213.13743.30643.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbYLWXXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:49 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFx006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:44 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 defines a number of state errors which the client does not currently
handle. Among those we should worry about are:
  NFS4ERR_ADMIN_REVOKED - the server's administrator revoked our locks
  			  and/or delegations.
  NFS4ERR_BAD_STATEID - the client and server are out of sync, possibly
                        due to a delegation return racing with an OPEN
			request.
  NFS4ERR_OPENMODE - the client attempted to do something not sanctioned
  		     by the open mode of the stateid. Should normally just
		     occur as a result of a delegation return race.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4_fs.h   |    2 ++
 fs/nfs/nfs4proc.c  |   37 ++++++++++++++++++++++++++++---------
 fs/nfs/nfs4state.c |    2 +-
 3 files changed, 31 insertions(+), 10 deletions(-)


diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a4e7b3f..46cbc0c 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -169,6 +169,7 @@ struct nfs4_state {
 struct nfs4_exception {
 	long timeout;
 	int retry;
+	struct nfs4_state *state;
 };
 
 struct nfs4_state_recovery_ops {
@@ -226,6 +227,7 @@ extern void nfs4_close_state(struct path *, struct nfs4_state *, mode_t);
 extern void nfs4_close_sync(struct path *, struct nfs4_state *, mode_t);
 extern void nfs4_state_set_mode_locked(struct nfs4_state *, mode_t);
 extern void nfs4_schedule_state_recovery(struct nfs_client *);
+extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state);
 extern void nfs4_put_lock_state(struct nfs4_lock_state *lsp);
 extern int nfs4_set_lock_state(struct nfs4_state *state, struct file_lock *fl);
 extern void nfs4_copy_stateid(nfs4_stateid *, struct nfs4_state *, fl_owner_t);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 26dcd77..8a2dee9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -62,7 +62,7 @@
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
-static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *);
+static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *, struct nfs4_state *);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
@@ -235,12 +235,19 @@ static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
 static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
 {
 	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_state *state = exception->state;
 	int ret = errorcode;
 
 	exception->retry = 0;
 	switch(errorcode) {
 		case 0:
 			return 0;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OPENMODE:
+			if (state == NULL)
+				break;
+			nfs4_state_mark_reclaim_nograce(clp, state);
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
@@ -1320,10 +1327,13 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
 			renew_lease(server, calldata->timestamp);
 			break;
 		case -NFS4ERR_STALE_STATEID:
+		case -NFS4ERR_OLD_STATEID:
+		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_EXPIRED:
-			break;
+			if (calldata->arg.open_flags == 0)
+				break;
 		default:
-			if (nfs4_async_handle_error(task, server) == -EAGAIN) {
+			if (nfs4_async_handle_error(task, server, state) == -EAGAIN) {
 				rpc_restart_call(task);
 				return;
 			}
@@ -1418,6 +1428,7 @@ int nfs4_do_close(struct path *path, struct nfs4_state *state, int wait)
 	calldata->arg.seqid = nfs_alloc_seqid(&state->owner->so_seqid);
 	if (calldata->arg.seqid == NULL)
 		goto out_free_calldata;
+	calldata->arg.open_flags = 0;
 	calldata->arg.bitmask = server->attr_bitmask;
 	calldata->res.fattr = &calldata->fattr;
 	calldata->res.seqid = calldata->arg.seqid;
@@ -2064,7 +2075,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
 {
 	struct nfs_removeres *res = task->tk_msg.rpc_resp;
 
-	if (nfs4_async_handle_error(task, res->server) == -EAGAIN)
+	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
 		return 0;
 	update_changeattr(dir, &res->cinfo);
 	nfs_post_op_update_inode(dir, &res->dir_attr);
@@ -2492,7 +2503,7 @@ static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	if (nfs4_async_handle_error(task, server) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, server, data->args.context->state) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
@@ -2513,7 +2524,7 @@ static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode)) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), data->args.context->state) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
@@ -2539,7 +2550,7 @@ static int nfs4_commit_done(struct rpc_task *task, struct nfs_write_data *data)
 {
 	struct inode *inode = data->inode;
 	
-	if (nfs4_async_handle_error(task, NFS_SERVER(inode)) == -EAGAIN) {
+	if (nfs4_async_handle_error(task, NFS_SERVER(inode), NULL) == -EAGAIN) {
 		rpc_restart_call(task);
 		return -EAGAIN;
 	}
@@ -2832,13 +2843,19 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 }
 
 static int
-nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
+nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server, struct nfs4_state *state)
 {
 	struct nfs_client *clp = server->nfs_client;
 
 	if (!clp || task->tk_status >= 0)
 		return 0;
 	switch(task->tk_status) {
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OPENMODE:
+			if (state == NULL)
+				break;
+			nfs4_state_mark_reclaim_nograce(clp, state);
 		case -NFS4ERR_STALE_CLIENTID:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
@@ -3195,11 +3212,13 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 					sizeof(calldata->lsp->ls_stateid.data));
 			renew_lease(calldata->server, calldata->timestamp);
 			break;
+		case -NFS4ERR_BAD_STATEID:
+		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_STALE_STATEID:
 		case -NFS4ERR_EXPIRED:
 			break;
 		default:
-			if (nfs4_async_handle_error(task, calldata->server) == -EAGAIN)
+			if (nfs4_async_handle_error(task, calldata->server, NULL) == -EAGAIN)
 				rpc_restart_call(task);
 	}
 }
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ec0cbe0..3d78706 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -824,7 +824,7 @@ static int nfs4_state_mark_reclaim_reboot(struct nfs_client *clp, struct nfs4_st
 	return 1;
 }
 
-static int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
+int nfs4_state_mark_reclaim_nograce(struct nfs_client *clp, struct nfs4_state *state)
 {
 	set_bit(NFS_STATE_RECLAIM_NOGRACE, &state->flags);
 	clear_bit(NFS_STATE_RECLAIM_REBOOT, &state->flags);

