From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 26/69] NFS: Remove the unnecessary argument to
 nfs4_wait_clnt_recover()
Date: Tue, 23 Dec 2008 18:02:13 -0500
Message-ID: <20081223230212.13743.52305.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17668 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYLWXXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:44 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsa006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and move some code around in order to clear out an unnecessary
forward declaration.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |  151 ++++++++++++++++++++++++++---------------------------
 1 files changed, 75 insertions(+), 76 deletions(-)


diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 019c8d6..660c5dc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -63,8 +63,6 @@ struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static int nfs4_async_handle_error(struct rpc_task *, const struct nfs_server *);
-static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception);
-static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp);
 static int _nfs4_proc_lookup(struct inode *dir, const struct qstr *name, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr);
 
@@ -195,6 +193,80 @@ static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dent
 	kunmap_atomic(start, KM_USER0);
 }
 
+static int nfs4_wait_bit_killable(void *word)
+{
+	if (fatal_signal_pending(current))
+		return -ERESTARTSYS;
+	schedule();
+	return 0;
+}
+
+static int nfs4_wait_clnt_recover(struct nfs_client *clp)
+{
+	int res;
+
+	might_sleep();
+
+	rwsem_acquire(&clp->cl_sem.dep_map, 0, 0, _RET_IP_);
+
+	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
+			nfs4_wait_bit_killable, TASK_KILLABLE);
+
+	rwsem_release(&clp->cl_sem.dep_map, 1, _RET_IP_);
+	return res;
+}
+
+static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
+{
+	int res = 0;
+
+	might_sleep();
+
+	if (*timeout <= 0)
+		*timeout = NFS4_POLL_RETRY_MIN;
+	if (*timeout > NFS4_POLL_RETRY_MAX)
+		*timeout = NFS4_POLL_RETRY_MAX;
+	schedule_timeout_killable(*timeout);
+	if (fatal_signal_pending(current))
+		res = -ERESTARTSYS;
+	*timeout <<= 1;
+	return res;
+}
+
+/* This is the error handling routine for processes that are allowed
+ * to sleep.
+ */
+static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
+{
+	struct nfs_client *clp = server->nfs_client;
+	int ret = errorcode;
+
+	exception->retry = 0;
+	switch(errorcode) {
+		case 0:
+			return 0;
+		case -NFS4ERR_STALE_CLIENTID:
+		case -NFS4ERR_STALE_STATEID:
+		case -NFS4ERR_EXPIRED:
+			nfs4_schedule_state_recovery(clp);
+			ret = nfs4_wait_clnt_recover(clp);
+			if (ret == 0)
+				exception->retry = 1;
+			break;
+		case -NFS4ERR_FILE_OPEN:
+		case -NFS4ERR_GRACE:
+		case -NFS4ERR_DELAY:
+			ret = nfs4_delay(server->client, &exception->timeout);
+			if (ret != 0)
+				break;
+		case -NFS4ERR_OLD_STATEID:
+			exception->retry = 1;
+	}
+	/* We failed to handle the error */
+	return nfs4_map_errors(ret);
+}
+
+
 static void renew_lease(const struct nfs_server *server, unsigned long timestamp)
 {
 	struct nfs_client *clp = server->nfs_client;
@@ -981,7 +1053,7 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 	int ret;
 
 	for (;;) {
-		ret = nfs4_wait_clnt_recover(server->client, clp);
+		ret = nfs4_wait_clnt_recover(clp);
 		if (ret != 0)
 			return ret;
 		if (!test_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) &&
@@ -2799,79 +2871,6 @@ nfs4_async_handle_error(struct rpc_task *task, const struct nfs_server *server)
 	return 0;
 }
 
-static int nfs4_wait_bit_killable(void *word)
-{
-	if (fatal_signal_pending(current))
-		return -ERESTARTSYS;
-	schedule();
-	return 0;
-}
-
-static int nfs4_wait_clnt_recover(struct rpc_clnt *clnt, struct nfs_client *clp)
-{
-	int res;
-
-	might_sleep();
-
-	rwsem_acquire(&clp->cl_sem.dep_map, 0, 0, _RET_IP_);
-
-	res = wait_on_bit(&clp->cl_state, NFS4CLNT_STATE_RECOVER,
-			nfs4_wait_bit_killable, TASK_KILLABLE);
-
-	rwsem_release(&clp->cl_sem.dep_map, 1, _RET_IP_);
-	return res;
-}
-
-static int nfs4_delay(struct rpc_clnt *clnt, long *timeout)
-{
-	int res = 0;
-
-	might_sleep();
-
-	if (*timeout <= 0)
-		*timeout = NFS4_POLL_RETRY_MIN;
-	if (*timeout > NFS4_POLL_RETRY_MAX)
-		*timeout = NFS4_POLL_RETRY_MAX;
-	schedule_timeout_killable(*timeout);
-	if (fatal_signal_pending(current))
-		res = -ERESTARTSYS;
-	*timeout <<= 1;
-	return res;
-}
-
-/* This is the error handling routine for processes that are allowed
- * to sleep.
- */
-static int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct nfs4_exception *exception)
-{
-	struct nfs_client *clp = server->nfs_client;
-	int ret = errorcode;
-
-	exception->retry = 0;
-	switch(errorcode) {
-		case 0:
-			return 0;
-		case -NFS4ERR_STALE_CLIENTID:
-		case -NFS4ERR_STALE_STATEID:
-		case -NFS4ERR_EXPIRED:
-			nfs4_schedule_state_recovery(clp);
-			ret = nfs4_wait_clnt_recover(server->client, clp);
-			if (ret == 0)
-				exception->retry = 1;
-			break;
-		case -NFS4ERR_FILE_OPEN:
-		case -NFS4ERR_GRACE:
-		case -NFS4ERR_DELAY:
-			ret = nfs4_delay(server->client, &exception->timeout);
-			if (ret != 0)
-				break;
-		case -NFS4ERR_OLD_STATEID:
-			exception->retry = 1;
-	}
-	/* We failed to handle the error */
-	return nfs4_map_errors(ret);
-}
-
 int nfs4_proc_setclientid(struct nfs_client *clp, u32 program, unsigned short port, struct rpc_cred *cred)
 {
 	nfs4_verifier sc_verifier;

