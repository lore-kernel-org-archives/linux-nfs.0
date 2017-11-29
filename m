Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:16136 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751936AbdK2LQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 06:16:05 -0500
From: Elena Reshetova <elena.reshetova@intel.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, bfields@fieldses.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 4/4] lockd: convert nlm_rqst.a_count from atomic_t to refcount_t
Date: Wed, 29 Nov 2017 13:15:46 +0200
Message-Id: <1511954146-11793-5-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nlm_rqst.a_count is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

**Important note for maintainers:

Some functions from refcount_t API defined in lib/refcount.c
have different memory ordering guarantees than their atomic
counterparts.
The full comparison can be seen in
https://lkml.org/lkml/2017/11/15/57 and it is hopefully soon
in state to be merged to the documentation tree.
Normally the differences should not matter since refcount_t provides
enough guarantees to satisfy the refcounting use cases, but in
some rare cases it might matter.
Please double check that you don't have some undocumented
memory guarantees for this variable usage.

For the nlm_rqst.a_count it might make a difference
in following places:
 - nlmclnt_release_call() and nlmsvc_release_call(): decrement
   in refcount_dec_and_test() only
   provides RELEASE ordering and control dependency on success
   vs. fully ordered atomic counterpart

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/lockd/clntproc.c         | 8 ++++----
 fs/lockd/svcproc.c          | 2 +-
 include/linux/lockd/lockd.h | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index 112173d..a2c0dfc 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -204,7 +204,7 @@ struct nlm_rqst *nlm_alloc_call(struct nlm_host *host)
 	for(;;) {
 		call = kzalloc(sizeof(*call), GFP_KERNEL);
 		if (call != NULL) {
-			atomic_set(&call->a_count, 1);
+			refcount_set(&call->a_count, 1);
 			locks_init_lock(&call->a_args.lock.fl);
 			locks_init_lock(&call->a_res.lock.fl);
 			call->a_host = nlm_get_host(host);
@@ -222,7 +222,7 @@ void nlmclnt_release_call(struct nlm_rqst *call)
 {
 	const struct nlmclnt_operations *nlmclnt_ops = call->a_host->h_nlmclnt_ops;
 
-	if (!atomic_dec_and_test(&call->a_count))
+	if (!refcount_dec_and_test(&call->a_count))
 		return;
 	if (nlmclnt_ops && nlmclnt_ops->nlmclnt_release_call)
 		nlmclnt_ops->nlmclnt_release_call(call->a_callback_data);
@@ -678,7 +678,7 @@ nlmclnt_unlock(struct nlm_rqst *req, struct file_lock *fl)
 		goto out;
 	}
 
-	atomic_inc(&req->a_count);
+	refcount_inc(&req->a_count);
 	status = nlmclnt_async_call(nfs_file_cred(fl->fl_file), req,
 			NLMPROC_UNLOCK, &nlmclnt_unlock_ops);
 	if (status < 0)
@@ -769,7 +769,7 @@ static int nlmclnt_cancel(struct nlm_host *host, int block, struct file_lock *fl
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.block = block;
 
-	atomic_inc(&req->a_count);
+	refcount_inc(&req->a_count);
 	status = nlmclnt_async_call(nfs_file_cred(fl->fl_file), req,
 			NLMPROC_CANCEL, &nlmclnt_cancel_ops);
 	if (status == 0 && req->a_res.status == nlm_lck_denied)
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 0d670c5..ea77c66 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -295,7 +295,7 @@ static void nlmsvc_callback_exit(struct rpc_task *task, void *data)
 
 void nlmsvc_release_call(struct nlm_rqst *call)
 {
-	if (!atomic_dec_and_test(&call->a_count))
+	if (!refcount_dec_and_test(&call->a_count))
 		return;
 	nlmsvc_release_host(call->a_host);
 	kfree(call);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 86d012a..4fd95db 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -137,7 +137,7 @@ struct nlm_wait;
  */
 #define NLMCLNT_OHSIZE		((__NEW_UTS_LEN) + 10u)
 struct nlm_rqst {
-	atomic_t		a_count;
+	refcount_t		a_count;
 	unsigned int		a_flags;	/* initial RPC task flags */
 	struct nlm_host *	a_host;		/* host handle */
 	struct nlm_args		a_args;		/* arguments */
-- 
2.7.4

