Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932360Ab1AKQVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:44 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 07/14] nfsd4: keep finer-grained callback status
Date: Tue, 11 Jan 2011 11:21:27 -0500
Message-Id: <1294762894-21371-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

Distinguish between when the callback channel is known to be down, and
when it is not yet confirmed.  This will be useful in the 4.1 case.

Also, we don't seem to be using the fact that this field is atomic.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   26 ++++++++++++++------------
 fs/nfsd/nfs4state.c    |    8 ++++----
 fs/nfsd/state.h        |    5 ++++-
 3 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 18b740b..d32f49d 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -470,8 +470,6 @@ static int max_cb_time(void)
 	return max(nfsd4_lease/10, (time_t)1) * HZ;
 }
 
-/* Reference counting, callback cleanup, etc., all look racy as heck.
- * And why is cl_cb_set an atomic? */
 
 static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *conn, struct nfsd4_session *ses)
 {
@@ -526,14 +524,20 @@ static void warn_no_callback_path(struct nfs4_client *clp, int reason)
 		(int)clp->cl_name.len, clp->cl_name.data, reason);
 }
 
+static void nfsd4_mark_cb_down(struct nfs4_client *clp, int reason)
+{
+	clp->cl_cb_state = NFSD4_CB_DOWN;
+	warn_no_callback_path(clp, reason);
+}
+
 static void nfsd4_cb_probe_done(struct rpc_task *task, void *calldata)
 {
 	struct nfs4_client *clp = container_of(calldata, struct nfs4_client, cl_cb_null);
 
 	if (task->tk_status)
-		warn_no_callback_path(clp, task->tk_status);
+		nfsd4_mark_cb_down(clp, task->tk_status);
 	else
-		atomic_set(&clp->cl_cb_set, 1);
+		clp->cl_cb_state = NFSD4_CB_UP;
 }
 
 static const struct rpc_call_ops nfsd4_cb_probe_ops = {
@@ -579,14 +583,15 @@ static void do_probe_callback(struct nfs4_client *clp)
  */
 void nfsd4_probe_callback(struct nfs4_client *clp)
 {
+	/* XXX: atomicity?  Also, should we be using cl_cb_flags? */
+	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	set_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_cb_flags);
 	do_probe_callback(clp);
 }
 
 void nfsd4_change_callback(struct nfs4_client *clp, struct nfs4_cb_conn *conn)
 {
-	BUG_ON(atomic_read(&clp->cl_cb_set));
-
+	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	spin_lock(&clp->cl_lock);
 	memcpy(&clp->cl_cb_conn, conn, sizeof(struct nfs4_cb_conn));
 	spin_unlock(&clp->cl_lock);
@@ -693,8 +698,7 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		break;
 	default:
 		/* Network partition? */
-		atomic_set(&clp->cl_cb_set, 0);
-		warn_no_callback_path(clp, task->tk_status);
+		nfsd4_mark_cb_down(clp, task->tk_status);
 		if (current_rpc_client != task->tk_client) {
 			/* queue a callback on the new connection: */
 			atomic_inc(&dp->dl_count);
@@ -707,10 +711,8 @@ static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
 		task->tk_status = 0;
 		rpc_restart_call_prepare(task);
 		return;
-	} else {
-		atomic_set(&clp->cl_cb_set, 0);
-		warn_no_callback_path(clp, task->tk_status);
-	}
+	} else
+		nfsd4_mark_cb_down(clp, task->tk_status);
 }
 
 static void nfsd4_cb_recall_release(void *calldata)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 290370b..919ad25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1071,7 +1071,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_refcount, 0);
-	atomic_set(&clp->cl_cb_set, 0);
+	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_openowners);
@@ -2003,7 +2003,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		if (!same_creds(&conf->cl_cred, &unconf->cl_cred))
 			status = nfserr_clid_inuse;
 		else {
-			atomic_set(&conf->cl_cb_set, 0);
 			nfsd4_change_callback(conf, &unconf->cl_cb_conn);
 			nfsd4_probe_callback(conf);
 			expire_client(unconf);
@@ -2633,7 +2632,8 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_sta
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
-	int cb_up = atomic_read(&sop->so_client->cl_cb_set);
+	/* XXX: or unknown and nfsv4.1: */
+	int cb_up = (sop->so_client->cl_cb_state == NFSD4_CB_UP);
 	struct file_lock *fl;
 	int status, flag = 0;
 
@@ -2823,7 +2823,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	renew_client(clp);
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
-			&& !atomic_read(&clp->cl_cb_set))
+			&& clp->cl_cb_state != NFSD4_CB_UP)
 		goto out;
 	status = nfs_ok;
 out:
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 442f6d8..32ff615 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -242,7 +242,10 @@ struct nfs4_client {
 	unsigned long		cl_cb_flags;
 	struct rpc_clnt		*cl_cb_client;
 	u32			cl_cb_ident;
-	atomic_t		cl_cb_set;
+#define NFSD4_CB_UP		0
+#define NFSD4_CB_UNKNOWN	1
+#define NFSD4_CB_DOWN		2
+	int			cl_cb_state;
 	struct nfsd4_callback	cl_cb_null;
 	struct nfsd4_session	*cl_cb_session;
 
-- 
1.7.1

