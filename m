Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:58276 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbaHFNi6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Aug 2014 09:38:58 -0400
Message-ID: <53E22FDD.4090900@gmail.com>
Date: Wed, 06 Aug 2014 21:38:37 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 3/3 RFC] fs/locks.c: Copy all infomation for conflock
References: <53BAAAC5.9000106@gmail.com> <53E22EA5.70708@gmail.com> <53E22F2C.8070900@gmail.com>
In-Reply-To: <53E22F2C.8070900@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure copy the private information by fl_copy_lock()
in struct file_lock_operations, use locks_copy_lock copying
all information for conflock.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/lockd/svclock.c |  2 +-
 fs/locks.c         | 27 ++++++---------------------
 include/linux/fs.h |  6 ------
 3 files changed, 7 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index ab798a8..e1f209c 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -677,7 +677,7 @@ nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
 		block->b_flags |= B_TIMED_OUT;
 	if (conf) {
 		if (block->b_fl)
-			__locks_copy_lock(block->b_fl, conf);
+			locks_copy_lock(block->b_fl, conf);
 	}
 }
 
diff --git a/fs/locks.c b/fs/locks.c
index 717fbc4..5547b3f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -266,35 +266,20 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
 		new->fl_lmops = fl->fl_lmops;
 }
 
-/*
- * Initialize a new lock from an existing file_lock structure.
- */
-void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
+void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 {
+	locks_release_private(new);
+
 	new->fl_owner = fl->fl_owner;
 	new->fl_pid = fl->fl_pid;
-	new->fl_file = NULL;
+	new->fl_file = fl->fl_file;
 	new->fl_flags = fl->fl_flags;
 	new->fl_type = fl->fl_type;
 	new->fl_start = fl->fl_start;
 	new->fl_end = fl->fl_end;
-	new->fl_ops = NULL;
-	new->fl_lmops = NULL;
-}
-EXPORT_SYMBOL(__locks_copy_lock);
-
-void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
-{
-	locks_release_private(new);
-
-	__locks_copy_lock(new, fl);
-	new->fl_file = fl->fl_file;
-	new->fl_ops = fl->fl_ops;
-	new->fl_lmops = fl->fl_lmops;
 
 	locks_copy_private(new, fl);
 }
-
 EXPORT_SYMBOL(locks_copy_lock);
 
 static inline int flock_translate_cmd(int cmd) {
@@ -718,7 +703,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 			break;
 	}
 	if (cfl) {
-		__locks_copy_lock(fl, cfl);
+		locks_copy_lock(fl, cfl);
 		if (cfl->fl_nspid)
 			fl->fl_pid = pid_vnr(cfl->fl_nspid);
 	} else
@@ -921,7 +906,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			if (!posix_locks_conflict(request, fl))
 				continue;
 			if (conflock)
-				__locks_copy_lock(conflock, fl);
+				locks_copy_lock(conflock, fl);
 			error = -EAGAIN;
 			if (!(request->fl_flags & FL_SLEEP))
 				goto out;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 4d40097..0d2c491 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -942,7 +942,6 @@ void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
 extern struct file_lock * locks_alloc_lock(void);
 extern void locks_copy_lock(struct file_lock *, struct file_lock *);
-extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
 extern void locks_remove_posix(struct file *, fl_owner_t);
 extern void locks_remove_file(struct file *);
 extern void locks_release_private(struct file_lock *);
@@ -1002,11 +1001,6 @@ static inline void locks_init_lock(struct file_lock *fl)
 	return;
 }
 
-static inline void __locks_copy_lock(struct file_lock *new, struct file_lock *fl)
-{
-	return;
-}
-
 static inline void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 {
 	return;
-- 
1.9.3

