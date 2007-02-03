From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 12/14] lockd: always preallocate block in nlmsvc_lock()
Date: Sat,  3 Feb 2007 00:34:08 -0500
Message-ID: <35028.7191490226$1170484087@news.gmane.org>
References: 11704806552464-git-send-email- <11704808501171-git-send-email-> <11704808502512-git-send-email-> <11704808513862-git-send-email-> <1170480851972-git-send-email-> <11704808513070-git-send-email-> <117048085185-git-send-email-> <11704808513263-git-send-email-> <11704808513185-git-send-email-> <11704808511238-git-send-email-> <11704808513085-git-send-email-> <11704808521765-git-send-email->
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11704808521765-git-send-email->
Message-Id: <ed8e1981069ef91a62c19a16b37d51c819a5196f.1170479265.git.bfields@citi.umich.edu>
In-Reply-To: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
References: <ad8373acbb12f165b625f6065bc0ca86f3982b7f.1170479265.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: Marc Eshel <eshel@almaden.ibm.com> - unquoted

Normally we could skip ever having to allocate a block in the case where
the client asks for a non-blocking lock, or asks for a blocking lock that
succeeds immediately.

However we're going to want to always look up a block first in order to
check whether we're revisiting a deferred lock call, and to be prepared to
handle the case where the filesystem returns -EINPROGRESS--in that case we
want to make sure the lock we've given the filesystem is the one embedded
in the block that we'll use to track the deferred request.

Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/svclock.c |   34 +++++++++++-----------------------
 1 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 91690e3..32202fa 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -365,7 +365,7 @@ __be32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
-	struct nlm_block	*block, *newblock = NULL;
+	struct nlm_block	*block = NULL;
 	int			error;
 	__be32			ret;
 
@@ -378,17 +378,20 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 				wait);
 
 
-	lock->fl.fl_flags &= ~FL_SLEEP;
-again:
 	/* Lock file against concurrent access */
 	mutex_lock(&file->f_mutex);
-	/* Get existing block (in case client is busy-waiting) */
+	/* Get existing block (in case client is busy-waiting)
+	 * or create new block
+	 */
 	block = nlmsvc_lookup_block(file, lock);
 	if (block == NULL) {
-		if (newblock != NULL)
-			lock = &newblock->b_call->a_args.lock;
-	} else
+		block = nlmsvc_create_block(rqstp, file, lock, cookie);
+		ret = nlm_lck_denied_nolocks;
+		if (block == NULL)
+			goto out;
 		lock = &block->b_call->a_args.lock;
+	} else
+		lock->fl.fl_flags &= ~FL_SLEEP;
 
 	error = posix_lock_file(file->f_file, &lock->fl);
 	lock->fl.fl_flags &= ~FL_SLEEP;
@@ -414,26 +417,11 @@ again:
 		goto out;
 
 	ret = nlm_lck_blocked;
-	if (block != NULL)
-		goto out;
-
-	/* If we don't have a block, create and initialize it. Then
-	 * retry because we may have slept in kmalloc. */
-	/* We have to release f_mutex as nlmsvc_create_block may try to
-	 * to claim it while doing host garbage collection */
-	if (newblock == NULL) {
-		mutex_unlock(&file->f_mutex);
-		dprintk("lockd: blocking on this lock (allocating).\n");
-		if (!(newblock = nlmsvc_create_block(rqstp, file, lock, cookie)))
-			return nlm_lck_denied_nolocks;
-		goto again;
-	}
 
 	/* Append to list of blocked */
-	nlmsvc_insert_block(newblock, NLM_NEVER);
+	nlmsvc_insert_block(block, NLM_NEVER);
 out:
 	mutex_unlock(&file->f_mutex);
-	nlmsvc_release_block(newblock);
 	nlmsvc_release_block(block);
 	dprintk("lockd: nlmsvc_lock returned %u\n", ret);
 	return ret;
-- 
1.5.0.rc1.g72fe

