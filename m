From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 8/10] lockd: always preallocate block in nlmsvc_lock()
Date: Wed,  6 Dec 2006 00:34:18 -0500
Message-ID: <11653832612071-git-send-email-bfields@fieldses.org>
References: <11653832602203-git-send-email-bfields@fieldses.org> <1165383260627-git-send-email-bfields@fieldses.org> <11653832603105-git-send-email-bfields@fieldses.org> <11653832601058-git-send-email-bfields@fieldses.org> <11653832601635-git-send-email-bfields@fieldses.org> <1165383260424-git-send-email-bfields@fieldses.org> <11653832601925-git-send-email-bfields@fieldses.org> <1165383260548-git-send-email-bfields@fieldses.org>
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <1165383260548-git-send-email-bfields@fieldses.org>
Message-Id: <aee338c430e7f0a9afe63ea80d0278b97b01eeee.1165380893.git.bfields@citi.umich.edu>
In-Reply-To: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu>
To: me <bfields@umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@fieldses.org>

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
index 21185a7..134a40e 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -471,7 +471,7 @@ __be32
 nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
 			struct nlm_lock *lock, int wait, struct nlm_cookie *cookie)
 {
-	struct nlm_block	*block, *newblock = NULL;
+	struct nlm_block	*block = NULL;
 	int			error;
 	__be32			ret;
 
@@ -484,17 +484,20 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
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
@@ -520,26 +523,11 @@ again:
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
1.4.4.1

