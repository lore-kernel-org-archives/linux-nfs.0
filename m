Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:45358 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134AbaHLOsX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2014 10:48:23 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so9643788qga.36
        for <linux-nfs@vger.kernel.org>; Tue, 12 Aug 2014 07:48:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] locks: defer freeing locks in locks_delete_lock until after i_lock has been dropped
Date: Tue, 12 Aug 2014 10:48:11 -0400
Message-Id: <1407854893-2698-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
References: <1407854893-2698-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In commit 72f98e72551fa (locks: turn lock_flocks into a spinlock), we
moved from using the BKL to a global spinlock. With this change, we lost
the ability to block in the fl_release_private operation.

This is problematic for NFS (and probably some other filesystems as
well). Add a new list_head argument to locks_delete_lock. If that
argument is non-NULL, then queue any locks that we want to free to the
list instead of freeing them.

Then, add a new locks_dispose_list function that will walk such a list
and call locks_free_lock on them after the i_lock has been dropped.

Finally, change all of the callers of locks_delete_lock to pass in a
list_head, except for lease_modify. That function can be called long
after the i_lock has been acquired. Deferring the freeing of a lease
after unlocking it in that function is non-trivial until we overhaul
some of the spinlocking in the lease code.

Currently though, no filesystem that sets fl_release_private supports
leases, so this is not currently a problem. We'll eventually want to
make the same change in the lease code, but it needs a lot more work
before we can reasonably do so.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 38 ++++++++++++++++++++++++++++++--------
 1 file changed, 30 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 7dd4defb4d8d..4ce087cca501 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -247,6 +247,18 @@ void locks_free_lock(struct file_lock *fl)
 }
 EXPORT_SYMBOL(locks_free_lock);
 
+static void
+locks_dispose_list(struct list_head *dispose)
+{
+	struct file_lock *fl;
+
+	while (!list_empty(dispose)) {
+		fl = list_first_entry(dispose, struct file_lock, fl_block);
+		list_del_init(&fl->fl_block);
+		locks_free_lock(fl);
+	}
+}
+
 void locks_init_lock(struct file_lock *fl)
 {
 	memset(fl, 0, sizeof(struct file_lock));
@@ -651,12 +663,16 @@ static void locks_unlink_lock(struct file_lock **thisfl_p)
  *
  * Must be called with i_lock held!
  */
-static void locks_delete_lock(struct file_lock **thisfl_p)
+static void locks_delete_lock(struct file_lock **thisfl_p,
+			      struct list_head *dispose)
 {
 	struct file_lock *fl = *thisfl_p;
 
 	locks_unlink_lock(thisfl_p);
-	locks_free_lock(fl);
+	if (dispose)
+		list_add(&fl->fl_block, dispose);
+	else
+		locks_free_lock(fl);
 }
 
 /* Determine if lock sys_fl blocks lock caller_fl. Common functionality
@@ -812,6 +828,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 	struct inode * inode = file_inode(filp);
 	int error = 0;
 	int found = 0;
+	LIST_HEAD(dispose);
 
 	if (!(request->fl_flags & FL_ACCESS) && (request->fl_type != F_UNLCK)) {
 		new_fl = locks_alloc_lock();
@@ -834,7 +851,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 		if (request->fl_type == fl->fl_type)
 			goto out;
 		found = 1;
-		locks_delete_lock(before);
+		locks_delete_lock(before, &dispose);
 		break;
 	}
 
@@ -881,6 +898,7 @@ out:
 	spin_unlock(&inode->i_lock);
 	if (new_fl)
 		locks_free_lock(new_fl);
+	locks_dispose_list(&dispose);
 	return error;
 }
 
@@ -894,6 +912,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	struct file_lock **before;
 	int error;
 	bool added = false;
+	LIST_HEAD(dispose);
 
 	/*
 	 * We may need two file_lock structures for this operation,
@@ -989,7 +1008,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			else
 				request->fl_end = fl->fl_end;
 			if (added) {
-				locks_delete_lock(before);
+				locks_delete_lock(before, &dispose);
 				continue;
 			}
 			request = fl;
@@ -1019,7 +1038,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				 * one (This may happen several times).
 				 */
 				if (added) {
-					locks_delete_lock(before);
+					locks_delete_lock(before, &dispose);
 					continue;
 				}
 				/*
@@ -1035,7 +1054,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				locks_copy_lock(new_fl, request);
 				request = new_fl;
 				new_fl = NULL;
-				locks_delete_lock(before);
+				locks_delete_lock(before, &dispose);
 				locks_insert_lock(before, request);
 				added = true;
 			}
@@ -1097,6 +1116,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		locks_free_lock(new_fl);
 	if (new_fl2)
 		locks_free_lock(new_fl2);
+	locks_dispose_list(&dispose);
 	return error;
 }
 
@@ -1272,7 +1292,7 @@ int lease_modify(struct file_lock **before, int arg)
 			printk(KERN_ERR "locks_delete_lock: fasync == %p\n", fl->fl_fasync);
 			fl->fl_fasync = NULL;
 		}
-		locks_delete_lock(before);
+		locks_delete_lock(before, NULL);
 	}
 	return 0;
 }
@@ -2324,6 +2344,7 @@ void locks_remove_file(struct file *filp)
 	struct inode * inode = file_inode(filp);
 	struct file_lock *fl;
 	struct file_lock **before;
+	LIST_HEAD(dispose);
 
 	if (!inode->i_flock)
 		return;
@@ -2369,12 +2390,13 @@ void locks_remove_file(struct file *filp)
 				fl->fl_type, fl->fl_flags,
 				fl->fl_start, fl->fl_end);
 
-			locks_delete_lock(before);
+			locks_delete_lock(before, &dispose);
 			continue;
  		}
 		before = &fl->fl_next;
 	}
 	spin_unlock(&inode->i_lock);
+	locks_dispose_list(&dispose);
 }
 
 /**
-- 
1.9.3

