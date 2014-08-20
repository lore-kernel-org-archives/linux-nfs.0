Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:38049 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbaHTJxi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 05:53:38 -0400
Message-ID: <53F47006.1090005@gmail.com>
Date: Wed, 20 Aug 2014 17:53:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jeff.layton@primarydata.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: [PATCH 2/6 v5] locks: Rename __locks_copy_lock() to locks_copy_conflock()
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com> <20140809065112.700e0ecc@tlielax.poochiereds.net> <53E791F1.40802@gmail.com> <53ED5093.6000308@gmail.com> <53F36CB5.2030707@gmail.com>
In-Reply-To: <53F36CB5.2030707@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff advice, " Right now __locks_copy_lock is only used to copy 
conflocks. It would be good to rename that to something more 
distinct (i.e.locks_copy_conflock), to make it clear that we're
generating a conflock there."

v5: change order from 3/6 to 2/6
v4: new patch only renaming function name

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/locks.c         | 10 +++++-----
 include/linux/fs.h |  4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index cb66fb0..49ce390 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -281,7 +281,7 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
 /*
  * Initialize a new lock from an existing file_lock structure.
  */
-void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
+void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
 {
 	new->fl_owner = fl->fl_owner;
 	new->fl_pid = fl->fl_pid;
@@ -293,14 +293,14 @@ void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
 	new->fl_ops = NULL;
 	new->fl_lmops = NULL;
 }
-EXPORT_SYMBOL(__locks_copy_lock);
+EXPORT_SYMBOL(locks_copy_conflock);
 
 void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
 {
 	/* "new" must be a freshly-initialized lock */
 	WARN_ON_ONCE(new->fl_ops);
 
-	__locks_copy_lock(new, fl);
+	locks_copy_conflock(new, fl);
 	new->fl_file = fl->fl_file;
 	new->fl_ops = fl->fl_ops;
 	new->fl_lmops = fl->fl_lmops;
@@ -735,7 +735,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
 			break;
 	}
 	if (cfl) {
-		__locks_copy_lock(fl, cfl);
+		locks_copy_conflock(fl, cfl);
 		if (cfl->fl_nspid)
 			fl->fl_pid = pid_vnr(cfl->fl_nspid);
 	} else
@@ -941,7 +941,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			if (!posix_locks_conflict(request, fl))
 				continue;
 			if (conflock)
-				__locks_copy_lock(conflock, fl);
+				locks_copy_conflock(conflock, fl);
 			error = -EAGAIN;
 			if (!(request->fl_flags & FL_SLEEP))
 				goto out;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 908af4f..5ab86f4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -966,7 +966,7 @@ void locks_free_lock(struct file_lock *fl);
 extern void locks_init_lock(struct file_lock *);
 extern struct file_lock * locks_alloc_lock(void);
 extern void locks_copy_lock(struct file_lock *, struct file_lock *);
-extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
+extern void locks_copy_conflock(struct file_lock *, struct file_lock *);
 extern void locks_remove_posix(struct file *, fl_owner_t);
 extern void locks_remove_file(struct file *);
 extern void locks_release_private(struct file_lock *);
@@ -1026,7 +1026,7 @@ static inline void locks_init_lock(struct file_lock *fl)
 	return;
 }
 
-static inline void __locks_copy_lock(struct file_lock *new, struct file_lock *fl)
+static inline void locks_copy_conflock(struct file_lock *new, struct file_lock *fl)
 {
 	return;
 }
-- 
1.9.3

