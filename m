From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 8/8] NLM/lockd: Ensure client locking calls use correct
	credentials
Date: Thu, 03 Apr 2008 18:39:23 -0400
Message-ID: <20080403223922.12713.37190.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080403223921.12713.71396.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13124 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751923AbYDCW6D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2008 18:58:03 -0400
In-Reply-To: <20080403223921.12713.71396.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've added the 'generic' credentials (that are independent of the
rpc_client) to the nfs_open_context, we can use those in the NLM client to
ensure that the lock/unlock requests are authenticated to whoever
originally opened the file.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 37d1aa2..40b16f2 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -247,7 +247,7 @@ static int nlm_wait_on_grace(wait_queue_head_t *queue)
  * Generic NLM call
  */
 static int
-nlmclnt_call(struct nlm_rqst *req, u32 proc)
+nlmclnt_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc)
 {
 	struct nlm_host	*host = req->a_host;
 	struct rpc_clnt	*clnt;
@@ -256,6 +256,7 @@ nlmclnt_call(struct nlm_rqst *req, u32 proc)
 	struct rpc_message msg = {
 		.rpc_argp	= argp,
 		.rpc_resp	= resp,
+		.rpc_cred	= cred,
 	};
 	int		status;
 
@@ -390,11 +391,12 @@ int nlm_async_reply(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *t
  *      completion in order to be able to correctly track the lock
  *      state.
  */
-static int nlmclnt_async_call(struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
+static int nlmclnt_async_call(struct rpc_cred *cred, struct nlm_rqst *req, u32 proc, const struct rpc_call_ops *tk_ops)
 {
 	struct rpc_message msg = {
 		.rpc_argp	= &req->a_args,
 		.rpc_resp	= &req->a_res,
+		.rpc_cred	= cred,
 	};
 	struct rpc_task *task;
 	int err;
@@ -415,7 +417,7 @@ nlmclnt_test(struct nlm_rqst *req, struct file_lock *fl)
 {
 	int	status;
 
-	status = nlmclnt_call(req, NLMPROC_TEST);
+	status = nlmclnt_call(nfs_file_cred(fl->fl_file), req, NLMPROC_TEST);
 	if (status < 0)
 		goto out;
 
@@ -506,6 +508,7 @@ static int do_vfs_lock(struct file_lock *fl)
 static int
 nlmclnt_lock(struct nlm_rqst *req, struct file_lock *fl)
 {
+	struct rpc_cred *cred = nfs_file_cred(fl->fl_file);
 	struct nlm_host	*host = req->a_host;
 	struct nlm_res	*resp = &req->a_res;
 	struct nlm_wait *block = NULL;
@@ -534,7 +537,7 @@ again:
 	for(;;) {
 		/* Reboot protection */
 		fl->fl_u.nfs_fl.state = host->h_state;
-		status = nlmclnt_call(req, NLMPROC_LOCK);
+		status = nlmclnt_call(cred, req, NLMPROC_LOCK);
 		if (status < 0)
 			break;
 		/* Did a reclaimer thread notify us of a server reboot? */
@@ -595,7 +598,7 @@ out_unlock:
 	up_read(&host->h_rwsem);
 	fl->fl_type = fl_type;
 	fl->fl_flags = fl_flags;
-	nlmclnt_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
+	nlmclnt_async_call(cred, req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
 	return status;
 }
 
@@ -619,8 +622,8 @@ nlmclnt_reclaim(struct nlm_host *host, struct file_lock *fl)
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.reclaim = 1;
 
-	if ((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0
-	 && req->a_res.status == nlm_granted)
+	status = nlmclnt_call(nfs_file_cred(fl->fl_file), req, NLMPROC_LOCK);
+	if (status >= 0 && req->a_res.status == nlm_granted)
 		return 0;
 
 	printk(KERN_WARNING "lockd: failed to reclaim lock for pid %d "
@@ -669,7 +672,8 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	}
 
 	atomic_inc(&req->a_count);
-	status = nlmclnt_async_call(req, NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
+	status = nlmclnt_async_call(nfs_file_cred(fl->fl_file), req,
+			NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
 	if (status < 0)
 		goto out;
 
@@ -738,7 +742,8 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 	req->a_args.block = block;
 
 	atomic_inc(&req->a_count);
-	status = nlmclnt_async_call(req, NLMPROC_CANCEL, &nlmclnt_cancel_ops);
+	status = nlmclnt_async_call(nfs_file_cred(fl->fl_file), req,
+			NLMPROC_CANCEL, &nlmclnt_cancel_ops);
 	if (status == 0 && req->a_res.status == nlm_lck_denied)
 		status = -ENOLCK;
 	nlm_release_call(req);

