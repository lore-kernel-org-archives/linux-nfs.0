From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] lockd: eliminate duplicate calls to nlmsvc_lookup_host in nlmsvc_lock and nlmsvc_testlock
Date: Sat, 12 Jul 2008 09:17:10 -0400
Message-ID: <1215868630-28201-1-git-send-email-jlayton@redhat.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbYGLNRe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Jul 2008 09:17:34 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both nlmsvc_lock and nlmsvc_testlock call nlmsvc_lookup_host to find a
nlm_host struct. All the callers of these functions, however, call
nlmsvc_retrieve_args or nlm4svc_retrieve_args which also return a
nlm_host struct.

Change nlmsvc_lock and nlmsvc_testlock to take a host arg instead of
calling nlmsvc_lookup_host themselves and change the callers to pass
a pointer to the nlm_host they've already found.

Also, get rid of some unneeded nlm_host NULL checks.

I think I've got the reference counting right with this patch, but
I wouldn't mind someone sanity checking it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc4proc.c         |    7 +++----
 fs/lockd/svclock.c          |   26 +++++++-------------------
 fs/lockd/svcproc.c          |    7 +++----
 include/linux/lockd/lockd.h |    6 ++++--
 4 files changed, 17 insertions(+), 29 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 2e27176..3994446 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -58,8 +58,7 @@ nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	if (host)
-		nlm_release_host(host);
+	nlm_release_host(host);
  	if (error)
 		return error;	
 	return nlm_lck_denied_nolocks;
@@ -100,7 +99,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
+	resp->status = nlmsvc_testlock(rqstp, file, host, &argp->lock, &resp->lock, &resp->cookie);
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
@@ -146,7 +145,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 #endif
 
 	/* Now try to lock the file */
-	resp->status = nlmsvc_lock(rqstp, file, &argp->lock,
+	resp->status = nlmsvc_lock(rqstp, file, host, &argp->lock,
 					argp->block, &argp->cookie);
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 56a08ab..6680715 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -358,10 +358,10 @@ nlmsvc_defer_lock_rqst(struct svc_rqst *rqstp, struct nlm_block *block)
  */
 __be32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
-			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
+	    struct nlm_host *host, struct nlm_lock *lock, int wait,
+	    struct nlm_cookie *cookie)
 {
 	struct nlm_block	*block = NULL;
-	struct nlm_host		*host;
 	int			error;
 	__be32			ret;
 
@@ -373,11 +373,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 				(long long)lock->fl.fl_end,
 				wait);
 
-	/* Create host handle for callback */
-	host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
-	if (host == NULL)
-		return nlm_lck_denied_nolocks;
-
 	/* Lock file against concurrent access */
 	mutex_lock(&file->f_mutex);
 	/* Get existing block (in case client is busy-waiting)
@@ -386,7 +381,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
 		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
-				lock, cookie);
+					    lock, cookie);
 		ret = nlm_lck_denied_nolocks;
 		if (block == NULL)
 			goto out;
@@ -450,7 +445,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 out:
 	mutex_unlock(&file->f_mutex);
 	nlmsvc_release_block(block);
-	nlm_release_host(host);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
 }
@@ -460,8 +454,8 @@ out:
  */
 __be32
 nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
-		struct nlm_lock *lock, struct nlm_lock *conflock,
-		struct nlm_cookie *cookie)
+		struct nlm_host *host, struct nlm_lock *lock,
+		struct nlm_lock *conflock, struct nlm_cookie *cookie)
 {
 	struct nlm_block 	*block = NULL;
 	int			error;
@@ -479,17 +473,11 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 
 	if (block == NULL) {
 		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
-		struct nlm_host	*host;
 
 		if (conf == NULL)
 			return nlm_granted;
-		/* Create host handle for callback */
-		host = nlmsvc_lookup_host(rqstp, lock->caller, lock->len);
-		if (host == NULL) {
-			kfree(conf);
-			return nlm_lck_denied_nolocks;
-		}
-		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
+		block = nlmsvc_create_block(rqstp, nlm_get_host(host), file,
+					    lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
 			return nlm_granted;
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index ce6952b..76019d2 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -87,8 +87,7 @@ nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
 	return 0;
 
 no_locks:
-	if (host)
-		nlm_release_host(host);
+	nlm_release_host(host);
 	if (error)
 		return error;
 	return nlm_lck_denied_nolocks;
@@ -129,7 +128,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie));
+	resp->status = cast_status(nlmsvc_testlock(rqstp, file, host, &argp->lock, &resp->lock, &resp->cookie));
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
@@ -176,7 +175,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 #endif
 
 	/* Now try to lock the file */
-	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
+	resp->status = cast_status(nlmsvc_lock(rqstp, file, host, &argp->lock,
 					       argp->block, &argp->cookie));
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 102d928..f81f9dd 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -200,10 +200,12 @@ typedef int	  (*nlm_host_match_fn_t)(void *cur, struct nlm_host *ref);
  * Server-side lock handling
  */
 __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
-					struct nlm_lock *, int, struct nlm_cookie *);
+			      struct nlm_host *, struct nlm_lock *, int,
+			      struct nlm_cookie *);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
 __be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
-			struct nlm_lock *, struct nlm_lock *, struct nlm_cookie *);
+			struct nlm_host *, struct nlm_lock *,
+			struct nlm_lock *, struct nlm_cookie *);
 __be32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
 unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
-- 
1.5.5.1

