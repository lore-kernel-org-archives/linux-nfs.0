From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/4] lockd: eliminate duplicate nlmsvc_lookup_host call from nlmsvc_lock
Date: Tue, 15 Jul 2008 14:48:12 -0400
Message-ID: <1216147693-23881-3-git-send-email-bfields@citi.umich.edu>
References: <20080715184554.GD21590@fieldses.org>
 <1216147693-23881-1-git-send-email-bfields@citi.umich.edu>
 <1216147693-23881-2-git-send-email-bfields@citi.umich.edu>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39562 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486AbYGOSs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:48:29 -0400
In-Reply-To: <1216147693-23881-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

nlmsvc_lock calls nlmsvc_lookup_host to find a nlm_host struct. The
callers of this function, however, call nlmsvc_retrieve_args or
nlm4svc_retrieve_args, which also return a nlm_host struct.

Change nlmsvc_lock to take a host arg instead of calling
nlmsvc_lookup_host itself and change the callers to pass a pointer to
the nlm_host they've already found.

Since nlmsvc_testlock() now just uses the caller's reference, we no
longer need to get or release it.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svclock.c          |   12 +++---------
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    3 ++-
 4 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 8cfb9da..189b2ce 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -145,7 +145,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 #endif
 
 	/* Now try to lock the file */
-	resp->status = nlmsvc_lock(rqstp, file, &argp->lock,
+	resp->status = nlmsvc_lock(rqstp, file, host, &argp->lock,
 					argp->block, &argp->cookie);
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index f40afb3..a6d3ed0 100644
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
@@ -450,7 +445,6 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 out:
 	mutex_unlock(&file->f_mutex);
 	nlmsvc_release_block(block);
-	nlm_release_host(host);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
 }
@@ -483,7 +477,7 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		if (conf == NULL)
 			return nlm_granted;
 		nlm_get_host(host);
-		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
+		block = nlmsvc_create_block(rqstp, file, lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
 			return nlm_granted;
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index e099f58..82dc908 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -175,7 +175,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp, struct nlm_args *argp,
 #endif
 
 	/* Now try to lock the file */
-	resp->status = cast_status(nlmsvc_lock(rqstp, file, &argp->lock,
+	resp->status = cast_status(nlmsvc_lock(rqstp, file, host, &argp->lock,
 					       argp->block, &argp->cookie));
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index b279670..f81f9dd 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -200,7 +200,8 @@ typedef int	  (*nlm_host_match_fn_t)(void *cur, struct nlm_host *ref);
  * Server-side lock handling
  */
 __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
-					struct nlm_lock *, int, struct nlm_cookie *);
+			      struct nlm_host *, struct nlm_lock *, int,
+			      struct nlm_cookie *);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
 __be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
 			struct nlm_host *, struct nlm_lock *,
-- 
1.5.5.rc1

