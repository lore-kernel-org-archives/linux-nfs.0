From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 10/14] lockd: pass cookie in nlmsvc_testlock
Date: Sat,  3 Feb 2007 00:34:06 -0500
Message-ID: <26597.1916880973$1170482966@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email-> <1170480851972-git-send-email-> <11704808513070-git-send-email-> <117048085185-git-send-email-> <11704808513263-git-send-email-> <11704808513185-git-send-email-> <11704808511238-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808511238-git-send-email->
Message-Id: <19e4ad761534f2afd8045321c950a9336c6b1fc2.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Change NLM internal interface to pass more information for test lock; we
need this to make sure the cookie information is pushed down to the place
where we do request deferral, which is handled for testlock by the
following patch.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svc4proc.c         |    2 +-
 fs/lockd/svclock.c          |    5 +++--
 fs/lockd/svcproc.c          |    2 +-
 include/linux/lockd/lockd.h |    4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index f67146a..9d4067a 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -99,7 +99,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = nlmsvc_testlock(file, &argp->lock, &resp->lock);
+	resp->status = nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie);
 
 	dprintk("lockd: TEST4          status %d\n", ntohl(resp->status));
 	nlm_release_host(host);
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index a558360..93f1bc8 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -443,8 +443,9 @@ out:
  * Test for presence of a conflicting lock.
  */
 __be32
-nlmsvc_testlock(struct nlm_file *file, struct nlm_lock *lock,
-				       struct nlm_lock *conflock)
+nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
+		struct nlm_lock *lock, struct nlm_lock *conflock,
+		struct nlm_cookie *cookie)
 {
 	dprintk("lockd: nlmsvc_testlock(%s/%ld, ty=%d, %Ld-%Ld)\n",
 				file->f_file->f_path.dentry->d_inode->i_sb->s_id,
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index 3707c3a..73b5c4f 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -127,7 +127,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp, struct nlm_args *argp,
 		return resp->status == nlm_drop_reply ? rpc_drop_reply :rpc_success;
 
 	/* Now check for conflicting locks */
-	resp->status = cast_status(nlmsvc_testlock(file, &argp->lock, &resp->lock));
+	resp->status = cast_status(nlmsvc_testlock(rqstp, file, &argp->lock, &resp->lock, &resp->cookie));
 
 	dprintk("lockd: TEST          status %d vers %d\n",
 		ntohl(resp->status), rqstp->rq_vers);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 1df10d7..f79ac52 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -195,8 +195,8 @@ typedef int	  (*nlm_host_match_fn_t)(struct nlm_host *cur, struct nlm_host *ref)
 __be32		  nlmsvc_lock(struct svc_rqst *, struct nlm_file *,
 					struct nlm_lock *, int, struct nlm_cookie *);
 __be32		  nlmsvc_unlock(struct nlm_file *, struct nlm_lock *);
-__be32		  nlmsvc_testlock(struct nlm_file *, struct nlm_lock *,
-					struct nlm_lock *);
+__be32		  nlmsvc_testlock(struct svc_rqst *, struct nlm_file *,
+			struct nlm_lock *, struct nlm_lock *, struct nlm_cookie *);
 __be32		  nlmsvc_cancel_blocked(struct nlm_file *, struct nlm_lock *);
 unsigned long	  nlmsvc_retry_blocked(void);
 void		  nlmsvc_traverse_blocks(struct nlm_host *, struct nlm_file *,
-- 
1.5.0.rc1.g72fe

