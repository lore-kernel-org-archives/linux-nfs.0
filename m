Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:56166 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbaHUPp4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2014 11:45:56 -0400
Received: by mail-qc0-f178.google.com with SMTP id x3so9622483qcv.9
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2014 08:45:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: cluster-devel@redhat.com, Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] lockd: rip out deferred lock handling from testlock codepath
Date: Thu, 21 Aug 2014 11:45:48 -0400
Message-Id: <1408635948-30481-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As Kinglong points out, the nlm_block->b_fl field is no longer used at
all. Also, vfs_test_lock in the generic locking code will only return
FILE_LOCK_DEFERRED if FL_SLEEP is set, and it isn't here.

The only other place that returns that value is the DLM lock code, but
it only does that in dlm_posix_lock, never in dlm_posix_get.

Remove all of the deferred locking code from the testlock codepath
since it doesn't appear to ever be used anyway.

I do have a small concern that this might cause a behavior change in the
case where you have a block already sitting on the list when the
testlock request comes in, but that looks like it doesn't really work
properly anyway. I think it's best to just pass that down to
vfs_test_lock and let the filesystem report that instead of trying to
infer what's going on with the lock by looking at an existing block.

Cc: cluster-devel@redhat.com
Reported-by: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svclock.c          | 55 +++++----------------------------------------
 include/linux/lockd/lockd.h |  1 -
 2 files changed, 6 insertions(+), 50 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index acfa94d5b489..13db95f54176 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -245,7 +245,6 @@ nlmsvc_create_block(struct svc_rqst *rqstp, struct nlm_host *host,
 	block->b_daemon = rqstp->rq_server;
 	block->b_host   = host;
 	block->b_file   = file;
-	block->b_fl = NULL;
 	file->f_count++;
 
 	/* Add to file's list of blocks */
@@ -295,7 +294,6 @@ static void nlmsvc_free_block(struct kref *kref)
 	nlmsvc_freegrantargs(block->b_call);
 	nlmsvc_release_call(block->b_call);
 	nlm_release_file(block->b_file);
-	kfree(block->b_fl);
 	kfree(block);
 }
 
@@ -508,7 +506,6 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 		struct nlm_host *host, struct nlm_lock *lock,
 		struct nlm_lock *conflock, struct nlm_cookie *cookie)
 {
-	struct nlm_block 	*block = NULL;
 	int			error;
 	__be32			ret;
 
@@ -519,63 +516,26 @@ nlmsvc_testlock(struct svc_rqst *rqstp, struct nlm_file *file,
 				(long long)lock->fl.fl_start,
 				(long long)lock->fl.fl_end);
 
-	/* Get existing block (in case client is busy-waiting) */
-	block = nlmsvc_lookup_block(file, lock);
-
-	if (block == NULL) {
-		struct file_lock *conf = kzalloc(sizeof(*conf), GFP_KERNEL);
-
-		if (conf == NULL)
-			return nlm_granted;
-		block = nlmsvc_create_block(rqstp, host, file, lock, cookie);
-		if (block == NULL) {
-			kfree(conf);
-			return nlm_granted;
-		}
-		block->b_fl = conf;
-	}
-	if (block->b_flags & B_QUEUED) {
-		dprintk("lockd: nlmsvc_testlock deferred block %p flags %d fl %p\n",
-			block, block->b_flags, block->b_fl);
-		if (block->b_flags & B_TIMED_OUT) {
-			nlmsvc_unlink_block(block);
-			ret = nlm_lck_denied;
-			goto out;
-		}
-		if (block->b_flags & B_GOT_CALLBACK) {
-			nlmsvc_unlink_block(block);
-			if (block->b_fl != NULL
-					&& block->b_fl->fl_type != F_UNLCK) {
-				lock->fl = *block->b_fl;
-				goto conf_lock;
-			} else {
-				ret = nlm_granted;
-				goto out;
-			}
-		}
-		ret = nlm_drop_reply;
-		goto out;
-	}
-
 	if (locks_in_grace(SVC_NET(rqstp))) {
 		ret = nlm_lck_denied_grace_period;
 		goto out;
 	}
+
 	error = vfs_test_lock(file->f_file, &lock->fl);
-	if (error == FILE_LOCK_DEFERRED) {
-		ret = nlmsvc_defer_lock_rqst(rqstp, block);
-		goto out;
-	}
 	if (error) {
+		/* We can't currently deal with deferred test requests */
+		if (error == FILE_LOCK_DEFERRED)
+			WARN_ON_ONCE(1);
+
 		ret = nlm_lck_denied_nolocks;
 		goto out;
 	}
+
 	if (lock->fl.fl_type == F_UNLCK) {
 		ret = nlm_granted;
 		goto out;
 	}
 
-conf_lock:
 	dprintk("lockd: conflicting lock(ty=%d, %Ld-%Ld)\n",
 		lock->fl.fl_type, (long long)lock->fl.fl_start,
 		(long long)lock->fl.fl_end);
@@ -589,8 +549,6 @@ conf_lock:
 	locks_release_private(&lock->fl);
 	ret = nlm_lck_denied;
 out:
-	if (block)
-		nlmsvc_release_block(block);
 	return ret;
 }
 
@@ -661,7 +619,6 @@ nlmsvc_cancel_blocked(struct net *net, struct nlm_file *file, struct nlm_lock *l
  * This is a callback from the filesystem for VFS file lock requests.
  * It will be used if lm_grant is defined and the filesystem can not
  * respond to the request immediately.
- * For GETLK request it will copy the reply to the nlm_block.
  * For SETLK or SETLKW request it will get the local posix lock.
  * In all cases it will move the block to the head of nlm_blocked q where
  * nlmsvc_retry_blocked() can send back a reply for SETLKW or revisit the
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 219d79627c05..ff82a32871b5 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -178,7 +178,6 @@ struct nlm_block {
 	unsigned char		b_granted;	/* VFS granted lock */
 	struct nlm_file *	b_file;		/* file in question */
 	struct cache_req *	b_cache_req;	/* deferred request handling */
-	struct file_lock *	b_fl;		/* set for GETLK */
 	struct cache_deferred_req * b_deferred_req;
 	unsigned int		b_flags;	/* block flags */
 #define B_QUEUED		1	/* lock queued */
-- 
1.9.3

