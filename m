Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754743Ab3FKLJx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 07:09:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v2 08/14] locks: ensure that deadlock detection is atomic with respect to blocked_list modification
Date: Tue, 11 Jun 2013 07:09:02 -0400
Message-Id: <1370948948-31784-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sound deadlock detection requires that we hold the file-lock state
steady while checking for them, and also ensure that updates to that
state are atomic with respect to those checks.

For the checking and insertion side, push the acquisition of the
global lock into __posix_lock_file and ensure that checking and update
of the global lists are done without dropping the lock in between.

On the removal side, when waking up blocked POSIX lock waiters, take
the global lock before walking the blocked list and dequeue the waiters
from the global list prior to removal from the i_flock list.

With this, deadlock detection should be race free while we minimize
excessive file_lock_lock thrashing.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |   71 +++++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 52 insertions(+), 19 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index d7342a3..b8cd1b1 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -475,16 +475,20 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 static inline void
 locks_insert_global_blocked(struct file_lock *waiter)
 {
-	spin_lock(&file_lock_lock);
 	list_add(&waiter->fl_link, &blocked_list);
-	spin_unlock(&file_lock_lock);
+}
+
+static inline void
+__locks_delete_global_blocked(struct file_lock *waiter)
+{
+	list_del_init(&waiter->fl_link);
 }
 
 static inline void
 locks_delete_global_blocked(struct file_lock *waiter)
 {
 	spin_lock(&file_lock_lock);
-	list_del_init(&waiter->fl_link);
+	__locks_delete_global_blocked(waiter);
 	spin_unlock(&file_lock_lock);
 }
 
@@ -509,7 +513,6 @@ locks_delete_global_locks(struct file_lock *waiter)
  */
 static void __locks_delete_block(struct file_lock *waiter)
 {
-	locks_delete_global_blocked(waiter);
 	list_del_init(&waiter->fl_block);
 	waiter->fl_next = NULL;
 }
@@ -558,6 +561,30 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 	}
 }
 
+/*
+ * Wake up processes blocked waiting for blocker. In the FL_POSIX case, we must
+ * also take the global file_lock_lock and dequeue it from the global blocked
+ * list as we wake the processes.
+ *
+ * Must be called with the inode->i_lock of the blocker held!
+ */
+static void locks_wake_up_posix_blocks(struct file_lock *blocker)
+{
+	spin_lock(&file_lock_lock);
+	while (!list_empty(&blocker->fl_block)) {
+		struct file_lock *waiter;
+
+		waiter = list_first_entry(&blocker->fl_block,
+				struct file_lock, fl_block);
+		__locks_delete_global_blocked(waiter);
+		__locks_delete_block(waiter);
+		if (waiter->fl_lmops && waiter->fl_lmops->lm_notify)
+			waiter->fl_lmops->lm_notify(waiter);
+		else
+			wake_up(&waiter->fl_wait);
+	}
+	spin_unlock(&file_lock_lock);
+}
 /* Insert file lock fl into an inode's lock list at the position indicated
  * by pos. At the same time add the lock to the global file lock list.
  */
@@ -592,7 +619,11 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 		fl->fl_nspid = NULL;
 	}
 
-	locks_wake_up_blocks(fl);
+	if (IS_POSIX(fl))
+		locks_wake_up_posix_blocks(fl);
+	else
+		locks_wake_up_blocks(fl);
+
 	locks_free_lock(fl);
 }
 
@@ -705,6 +736,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 	return NULL;
 }
 
+/* Must be called with the file_lock_lock held! */
 static int posix_locks_deadlock(struct file_lock *caller_fl,
 				struct file_lock *block_fl)
 {
@@ -848,17 +880,13 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			if (!(request->fl_flags & FL_SLEEP))
 				goto out;
 			error = -EDEADLK;
-			/*
-			 * XXX: potential race here. We should be adding the
-			 * file_lock to the global list before releasing lock.
-			 */
 			spin_lock(&file_lock_lock);
-			if (posix_locks_deadlock(request, fl))
-				goto out;
+			if (likely(!posix_locks_deadlock(request, fl))) {
+				error = FILE_LOCK_DEFERRED;
+				locks_insert_block(fl, request);
+				locks_insert_global_blocked(request);
+			}
 			spin_unlock(&file_lock_lock);
-			error = FILE_LOCK_DEFERRED;
-			locks_insert_block(fl, request);
-			locks_insert_global_blocked(request);
 			goto out;
   		}
   	}
@@ -949,7 +977,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				 * as the change in lock type might satisfy
 				 * their needs.
 				 */
-				locks_wake_up_blocks(fl);
+				locks_wake_up_posix_blocks(fl);
 				fl->fl_start = request->fl_start;
 				fl->fl_end = request->fl_end;
 				fl->fl_type = request->fl_type;
@@ -1001,11 +1029,11 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			locks_insert_lock(before, left);
 		}
 		right->fl_start = request->fl_end + 1;
-		locks_wake_up_blocks(right);
+		locks_wake_up_posix_blocks(right);
 	}
 	if (left) {
 		left->fl_end = request->fl_start - 1;
-		locks_wake_up_blocks(left);
+		locks_wake_up_posix_blocks(left);
 	}
  out:
 	spin_unlock(&inode->i_lock);
@@ -1061,6 +1089,7 @@ int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
 		if (!error)
 			continue;
 
+		locks_delete_global_blocked(fl);
 		locks_delete_block(fl);
 		break;
 	}
@@ -1139,6 +1168,7 @@ int locks_mandatory_area(int read_write, struct inode *inode,
 				continue;
 		}
 
+		locks_delete_global_blocked(&fl);
 		locks_delete_block(&fl);
 		break;
 	}
@@ -1851,6 +1881,7 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
 		if (!error)
 			continue;
 
+		locks_delete_global_blocked(fl);
 		locks_delete_block(fl);
 		break;
 	}
@@ -2148,10 +2179,12 @@ posix_unblock_lock(struct file *filp, struct file_lock *waiter)
 	int status = 0;
 
 	spin_lock(&inode->i_lock);
-	if (waiter->fl_next)
+	if (waiter->fl_next) {
+		locks_delete_global_blocked(waiter);
 		__locks_delete_block(waiter);
-	else
+	} else {
 		status = -ENOENT;
+	}
 	spin_unlock(&inode->i_lock);
 	return status;
 }
-- 
1.7.1

