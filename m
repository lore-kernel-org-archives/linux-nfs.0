From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: make recall callback an asynchronous rpc
Date: Sun,  3 May 2009 14:16:39 -0400
Message-ID: <1241374599-20348-14-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
 <1241374599-20348-9-git-send-email-bfields@fieldses.org>
 <1241374599-20348-10-git-send-email-bfields@fieldses.org>
 <1241374599-20348-11-git-send-email-bfields@fieldses.org>
 <1241374599-20348-12-git-send-email-bfields@fieldses.org>
 <1241374599-20348-13-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58619 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754294AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-13-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

As with the probe, this removes the need for another kthread.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |   74 +++++++++++++++++++++++++++++++----------------
 fs/nfsd/nfs4state.c    |   28 ++----------------
 2 files changed, 52 insertions(+), 50 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index b88b207..753184e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -494,6 +494,49 @@ nfsd4_probe_callback(struct nfs4_client *clp)
 	do_probe_callback(clp);
 }
 
+static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
+{
+	struct nfs4_delegation *dp = calldata;
+	struct nfs4_client *clp = dp->dl_client;
+
+	switch (task->tk_status) {
+		case -EIO:
+			/* Network partition? */
+			atomic_set(&clp->cl_cb_conn.cb_set, 0);
+			warn_no_callback_path(clp, task->tk_status);
+		case -EBADHANDLE:
+		case -NFS4ERR_BAD_STATEID:
+			/* Race: client probably got cb_recall
+			 * before open reply granting delegation */
+			break;
+		default:
+			/* success, or error we can't handle */
+			return;
+	}
+	if (dp->dl_retries--) {
+		rpc_delay(task, 2*HZ);
+		task->tk_status = 0;
+		rpc_restart_call(task);
+	} else {
+		atomic_set(&clp->cl_cb_conn.cb_set, 0);
+		warn_no_callback_path(clp, task->tk_status);
+	}
+}
+
+static void nfsd4_cb_recall_release(void *calldata)
+{
+	struct nfs4_delegation *dp = calldata;
+	struct nfs4_client *clp = dp->dl_client;
+
+	nfs4_put_delegation(dp);
+	put_nfs4_client(clp);
+}
+
+static const struct rpc_call_ops nfsd4_cb_recall_ops = {
+	.rpc_call_done = nfsd4_cb_recall_done,
+	.rpc_release = nfsd4_cb_recall_release,
+};
+
 /*
  * called with dp->dl_count inc'ed.
  */
@@ -507,32 +550,13 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 		.rpc_argp = dp,
 		.rpc_cred = clp->cl_cb_conn.cb_cred
 	};
-	int status = 0;
+	int status;
 
 	dp->dl_retries = 1;
-	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
-	while (dp->dl_retries--) {
-		switch (status) {
-			case -EIO:
-				/* Network partition? */
-				atomic_set(&clp->cl_cb_conn.cb_set, 0);
-			case -EBADHANDLE:
-			case -NFS4ERR_BAD_STATEID:
-				/* Race: client probably got cb_recall
-				 * before open reply granting delegation */
-				break;
-			default:
-				goto out_put_cred;
-		}
-		ssleep(2);
-		status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
+	status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
+				&nfsd4_cb_recall_ops, dp);
+	if (status) {
+		put_nfs4_client(clp);
+		nfs4_put_delegation(dp);
 	}
-out_put_cred:
-	/*
-	 * Success or failure, now we're either waiting for lease expiration
-	 * or deleg_return.
-	 */
-	put_nfs4_client(clp);
-	nfs4_put_delegation(dp);
-	return;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cbb16e1..a4bdf25 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2060,19 +2060,6 @@ nfs4_file_downgrade(struct file *filp, unsigned int share_access)
 }
 
 /*
- * Recall a delegation
- */
-static int
-do_recall(void *__dp)
-{
-	struct nfs4_delegation *dp = __dp;
-
-	dp->dl_file->fi_had_conflict = true;
-	nfsd4_cb_recall(dp);
-	return 0;
-}
-
-/*
  * Spawn a thread to perform a recall on the delegation represented
  * by the lease (file_lock)
  *
@@ -2083,8 +2070,7 @@ do_recall(void *__dp)
 static
 void nfsd_break_deleg_cb(struct file_lock *fl)
 {
-	struct nfs4_delegation *dp=  (struct nfs4_delegation *)fl->fl_owner;
-	struct task_struct *t;
+	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
 
 	dprintk("NFSD nfsd_break_deleg_cb: dp %p fl %p\n",dp,fl);
 	if (!dp)
@@ -2112,16 +2098,8 @@ void nfsd_break_deleg_cb(struct file_lock *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	t = kthread_run(do_recall, dp, "%s", "nfs4_cb_recall");
-	if (IS_ERR(t)) {
-		struct nfs4_client *clp = dp->dl_client;
-
-		printk(KERN_INFO "NFSD: Callback thread failed for "
-			"for client (clientid %08x/%08x)\n",
-			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
-		put_nfs4_client(dp->dl_client);
-		nfs4_put_delegation(dp);
-	}
+	dp->dl_file->fi_had_conflict = true;
+	nfsd4_cb_recall(dp);
 }
 
 /*
-- 
1.6.0.4

