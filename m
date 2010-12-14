Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65049 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0LNPFq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 10:05:46 -0500
Received: by gyb11 with SMTP id 11so380746gyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 07:05:46 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/11] lockd: Split nlm_release_call()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 10:05:42 -0500
Message-ID: <20101214150542.2736.84066.stgit@matisse.1015granger.net>
In-Reply-To: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
References: <20101214150036.2736.98254.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The nlm_release_call() function is invoked from both the server and
the client side.  We're about to introduce a distinct server- and
client-side nlm_release_host(), so nlm_release_call() must first be
split into a client-side and a server-side version.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c         |   12 ++++++------
 fs/lockd/svc4proc.c         |    4 ++--
 fs/lockd/svclock.c          |    4 ++--
 fs/lockd/svcproc.c          |   12 ++++++++++--
 include/linux/lockd/lockd.h |    3 ++-
 5 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 332c54c..fbc6617 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -211,7 +211,7 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 	return NULL;
 }
 
-void nlm_release_call(struct nlm_rqst *call)
+void nlmclnt_release_call(struct nlm_rqst *call)
 {
 	if (!atomic_dec_and_test(&call->a_count))
 		return;
@@ -222,7 +222,7 @@ void nlm_release_call(struct nlm_rqst *call)
 
 static void nlmclnt_rpc_release(void *data)
 {
-	nlm_release_call(data);
+	nlmclnt_release_call(data);
 }
 
 static int nlm_wait_on_grace(wait_queue_head_t *queue)
@@ -436,7 +436,7 @@ nlmclnt_test(struct nlm_rqst *req, struct file_lock *fl)
 			status = nlm_stat_to_errno(req->a_res.status);
 	}
 out:
-	nlm_release_call(req);
+	nlmclnt_release_call(req);
 	return status;
 }
 
@@ -593,7 +593,7 @@ again:
 out_unblock:
 	nlmclnt_finish_block(block);
 out:
-	nlm_release_call(req);
+	nlmclnt_release_call(req);
 	return status;
 out_unlock:
 	/* Fatal error: ensure that we remove the lock altogether */
@@ -694,7 +694,7 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 	/* What to do now? I'm out of my depth... */
 	status = -ENOLCK;
 out:
-	nlm_release_call(req);
+	nlmclnt_release_call(req);
 	return status;
 }
 
@@ -755,7 +755,7 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 			NLMPROC_CANCEL, &nlmclnt_cancel_ops);
 	if (status == 0 && req->a_res.status == nlm_lck_denied)
 		status = -ENOLCK;
-	nlm_release_call(req);
+	nlmclnt_release_call(req);
 	return status;
 }
 
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 38d2611..c187422 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -229,7 +229,7 @@ static void nlm4svc_callback_exit(struct rpc_task *task, void *data)
 
 static void nlm4svc_callback_release(void *data)
 {
-	nlm_release_call(data);
+	nlmsvc_release_call(data);
 }
 
 static const struct rpc_call_ops nlm4svc_callback_ops = {
@@ -261,7 +261,7 @@ static __be32 nlm4svc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 
 	stat = func(rqstp, argp, &call->a_res);
 	if (stat != 0) {
-		nlm_release_call(call);
+		nlmsvc_release_call(call);
 		return stat;
 	}
 
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 9266c46..6e31695 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -234,7 +234,7 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
 failed_free:
 	kfree(block);
 failed:
-	nlm_release_call(call);
+	nlmsvc_release_call(call);
 	return NULL;
 }
 
@@ -267,7 +267,7 @@ static void nlmsvc_free_block(struct kref *kref)
 	mutex_unlock(&file->f_mutex);
 
 	nlmsvc_freegrantargs(block->b_call);
-	nlm_release_call(block->b_call);
+	nlmsvc_release_call(block->b_call);
 	nlm_release_file(block->b_file);
 	kfree(block->b_fl);
 	kfree(block);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 0caea53..0df65ec 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -257,9 +257,17 @@ static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
 			-task->tk_status);
 }
 
+void nlmsvc_release_call(struct nlm_rqst *call)
+{
+	if (!atomic_dec_and_test(&call->a_count))
+		return;
+	nlm_release_host(call->a_host);
+	kfree(call);
+}
+
 static void nlmsvc_callback_release(void *data)
 {
-	nlm_release_call(data);
+	nlmsvc_release_call(data);
 }
 
 static const struct rpc_call_ops nlmsvc_callback_ops = {
@@ -291,7 +299,7 @@ static __be32 nlmsvc_callback(struct svc_rqst *rqstp, u32 proc, struct nlm_args
 
 	stat = func(rqstp, argp, &call->a_res);
 	if (stat != 0) {
-		nlm_release_call(call);
+		nlmsvc_release_call(call);
 		return stat;
 	}
 
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 2dee05e..a32ba62 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -202,9 +202,9 @@ extern u32			nsm_local_state;
  * Lockd client functions
  */
 struct nlm_rqst * nlm_alloc_call(struct nlm_host *host);
-void		  nlm_release_call(struct nlm_rqst *);
 int		  nlm_async_call(struct nlm_rqst *, u32, const struct rpc_call_ops *);
 int		  nlm_async_reply(struct nlm_rqst *, u32, const struct rpc_call_ops *);
+void		  nlmclnt_release_call(struct nlm_rqst *);
 struct nlm_wait * nlmclnt_prepare_block(struct nlm_host *host, struct file_lock *fl);
 void		  nlmclnt_finish_block(struct nlm_wait *block);
 int		  nlmclnt_block(struct nlm_wait *block, struct nlm_rqst *req, long timeout);
@@ -267,6 +267,7 @@ unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
 					nlm_host_match_fn_t match);
 void		  nlmsvc_grant_reply(struct nlm_cookie *, __be32);
+void		  nlmsvc_release_call(struct nlm_rqst *);
 
 /*
  * File handling for the server personality

