From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/4] lockd: eliminate duplicate nlmsvc_lookup_host call from nlmsvc_testlock
Date: Tue, 15 Jul 2008 14:48:11 -0400
Message-ID: <1216147693-23881-2-git-send-email-bfields@citi.umich.edu>
References: <20080715184554.GD21590@fieldses.org>
 <1216147693-23881-1-git-send-email-bfields@citi.umich.edu>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39561 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754084AbYGOSs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:48:29 -0400
In-Reply-To: <1216147693-23881-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

nlmsvc_testlock calls nlmsvc_lookup_host to find a nlm_host struct. The
callers of this functions, however, call nlmsvc_retrieve_args or
nlm4svc_retrieve_args, which also return a nlm_host struct.

Change nlmsvc_testlock to take a host arg instead of calling
nlmsvc_lookup_host itself and change the callers to pass a pointer to
the nlm_host they've already found.

We take a reference to host in the place where nlmsvc_testlock()
previous did a new lookup, so the reference counting is unchanged from
before.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svclock.c          |   12 +++---------
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    3 ++-
 4 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index 006a832..8cfb9da 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -99,7 +99,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
+	resp->status = nlmsvc_testlock(rqstp, file, host, &argp->lock, &resp->lock, &resp->cookie);
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 81aca85..f40afb3 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -460,8 +460,8 @@ out:
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
@@ -479,16 +479,10 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 
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
+		nlm_get_host(host);
 		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
 		if (block == NULL) {
 			kfree(conf);
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index fce3d70..e099f58 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -128,7 +128,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie));
+	resp->status = cast_status(nlmsvc_testlock(rqstp, file, host, &argp->lock, &resp->lock, &resp->cookie));
 	if (resp->status == nlm_drop_reply)
 		rc = rpc_drop_reply;
 	else
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 102d928..b279670 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -203,7 +203,8 @@ __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
 					struct nlm_lock *, int, struct nlm_cookie *);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
 __be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
-			struct nlm_lock *, struct nlm_lock *, struct nlm_cookie *);
+			struct nlm_host *, struct nlm_lock *,
+			struct nlm_lock *, struct nlm_cookie *);
 __be32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
 unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
-- 
1.5.5.rc1

