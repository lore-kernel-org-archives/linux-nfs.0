From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/3] lockd: move grace period checks to common code
Date: Mon, 29 Sep 2008 22:44:02 -0400
Message-ID: <1222742643-31541-3-git-send-email-bfields@citi.umich.edu>
References: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu>
 <1222742643-31541-2-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47560 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbYI3CoS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 22:44:18 -0400
In-Reply-To: <1222742643-31541-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do all the grace period checks in svclock.c.  This simplifies the code a
bit, and will ease some later changes.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c         |   15 ++-------------
 fs/lockd/svclock.c          |   14 +++++++++++++-
 fs/lockd/svcproc.c          |   15 ++-------------
 include/linux/lockd/lockd.h |    2 +-
 4 files changed, 18 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 7ca6173..f6f18fa 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -88,12 +88,6 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	dprintk("lockd: TEST4        called\n");
 	resp->cookie = argp->cookie;
 
-	/* Don't accept test requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rc;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -122,12 +116,6 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rc;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -146,7 +134,8 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	/* Now try to lock the file */
 	resp->status = nlmsvc_lock(rqstp, file, host, &argp->lock,
-					argp->block, &argp->cookie);
+					argp->block, &argp->cookie,
+					argp->reclaim);
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index cf0d5c2..808d246 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -360,7 +360,7 @@ nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
 __be32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	    struct nlm_host *host, struct nlm_lock *lock, int wait,
-	    struct nlm_cookie *cookie)
+	    struct nlm_cookie *cookie, int reclaim)
 {
 	struct nlm_block	*block = NULL;
 	int			error;
@@ -406,6 +406,11 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
+	if (locks_in_grace() && !reclaim) {
+		ret = nlm_lck_denied_grace_period;
+		goto out;
+	}
+
 	if (!wait)
 		lock->fl.fl_flags &= ~FL_SLEEP;
 	error = vfs_lock_file(file->f_file, F_SETLK, &lock->fl, NULL);
@@ -502,6 +507,10 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		goto out;
 	}
 
+	if (locks_in_grace()) {
+		ret = nlm_lck_denied_grace_period;
+		goto out;
+	}
 	error = vfs_test_lock(file->f_file, &lock->fl);
 	if (error == FILE_LOCK_DEFERRED) {
 		ret = nlmsvc_defer_lock_rqst(rqstp, block);
@@ -582,6 +591,9 @@ nlmsvc_cancel_blocked(struct nlm_file *file, struct nlm_lock *lock)
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
+	if (locks_in_grace())
+		return nlm_lck_denied_grace_period;
+
 	mutex_lock(&file->f_mutex);
 	block = nlmsvc_lookup_block(file, lock);
 	mutex_unlock(&file->f_mutex);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 1b013e1..a587b81 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -117,12 +117,6 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 	dprintk("lockd: TEST          called\n");
 	resp->cookie = argp->cookie;
 
-	/* Don't accept test requests during grace period */
-	if (locks_in_grace()) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rc;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -152,12 +146,6 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	resp->cookie = argp->cookie;
 
-	/* Don't accept new lock requests during grace period */
-	if (locks_in_grace() && !argp->reclaim) {
-		resp->status = nlm_lck_denied_grace_period;
-		return rc;
-	}
-
 	/* Obtain client and file */
 	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
@@ -176,7 +164,8 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 
 	/* Now try to lock the file */
 	resp->status = cast_status(nlmsvc_lock(rqstp, file, host, &argp->lock,
-					       argp->block, &argp->cookie));
+					       argp->block, &argp->cookie,
+					       argp->reclaim));
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ec8af11..973ab1d 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -242,7 +242,7 @@ typedef int	  (*nlm_host_match_fn_t)(void *cur, struct nlm_host *ref);
  */
 __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
 			      struct nlm_host *, struct nlm_lock *, int,
-			      struct nlm_cookie *);
+			      struct nlm_cookie *, int);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
 __be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
 			struct nlm_host *, struct nlm_lock *,
-- 
1.5.5.rc1

