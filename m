Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464Ab3FQPOm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 11/13] locks: give the blocked_hash its own spinlock
Date: Mon, 17 Jun 2013 11:13:54 -0400
Message-Id: <1371482036-15958-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no reason we have to protect the blocked_hash and file_lock_list
with the same spinlock. With the tests I have, breaking it in two gives
a barely measurable performance benefit, but it seems reasonable to make
this locking as granular as possible.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/Locking |   16 ++++++++--------
 fs/locks.c                        |   33 ++++++++++++++++++---------------
 2 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index dfeb01b..cf04448 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -359,20 +359,20 @@ prototypes:
 
 locking rules:
 
-			inode->i_lock	file_lock_lock	may block
-lm_compare_owner:	yes[1]		maybe		no
-lm_owner_key		yes[1]		yes		no
-lm_notify:		yes		yes		no
-lm_grant:		no		no		no
-lm_break:		yes		no		no
-lm_change		yes		no		no
+			inode->i_lock	blocked_lock_lock	may block
+lm_compare_owner:	yes[1]		maybe			no
+lm_owner_key		yes[1]		yes			no
+lm_notify:		yes		yes			no
+lm_grant:		no		no			no
+lm_break:		yes		no			no
+lm_change		yes		no			no
 
 [1]:	->lm_compare_owner and ->lm_owner_key are generally called with
 *an* inode->i_lock held. It may not be the i_lock of the inode
 associated with either file_lock argument! This is the case with deadlock
 detection, since the code has to chase down the owners of locks that may
 be entirely unrelated to the one on which the lock is being acquired.
-For deadlock detection however, the file_lock_lock is also held. The
+For deadlock detection however, the blocked_lock_lock is also held. The
 fact that these locks are held ensures that the file_locks do not
 disappear out from under you while doing the comparison or generating an
 owner key.
diff --git a/fs/locks.c b/fs/locks.c
index 55f3af7..5db80c7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -159,10 +159,11 @@ int lease_break_time = 45;
  * by the file_lock_lock.
  */
 static HLIST_HEAD(file_lock_list);
+static DEFINE_SPINLOCK(file_lock_lock);
 
 /*
  * The blocked_hash is used to find POSIX lock loops for deadlock detection.
- * It is protected by file_lock_lock.
+ * It is protected by blocked_lock_lock.
  *
  * We hash locks by lockowner in order to optimize searching for the lock a
  * particular lockowner is waiting on.
@@ -174,8 +175,8 @@ static HLIST_HEAD(file_lock_list);
 #define BLOCKED_HASH_BITS	7
 static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
 
-/* Protects the file_lock_list, the blocked_hash and fl->fl_block list */
-static DEFINE_SPINLOCK(file_lock_lock);
+/* protects blocked_hash and fl->fl_block list */
+static DEFINE_SPINLOCK(blocked_lock_lock);
 
 static struct kmem_cache *filelock_cache __read_mostly;
 
@@ -528,7 +529,7 @@ locks_delete_global_blocked(struct file_lock *waiter)
 /* Remove waiter from blocker's block list.
  * When blocker ends up pointing to itself then the list is empty.
  *
- * Must be called with file_lock_lock held.
+ * Must be called with blocked_lock_lock held.
  */
 static void __locks_delete_block(struct file_lock *waiter)
 {
@@ -539,9 +540,9 @@ static void __locks_delete_block(struct file_lock *waiter)
 
 static void locks_delete_block(struct file_lock *waiter)
 {
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_lock_lock);
 	__locks_delete_block(waiter);
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_lock_lock);
 }
 
 /* Insert waiter into blocker's block list.
@@ -549,9 +550,9 @@ static void locks_delete_block(struct file_lock *waiter)
  * the order they blocked. The documentation doesn't require this but
  * it seems like the reasonable thing to do.
  *
- * Must be called with both the i_lock and file_lock_lock held. The fl_block
+ * Must be called with both the i_lock and blocked_lock_lock held. The fl_block
  * list itself is protected by the file_lock_list, but by ensuring that the
- * i_lock is also held on insertions we can avoid taking the file_lock_lock
+ * i_lock is also held on insertions we can avoid taking the blocked_lock_lock
  * in some cases when we see that the fl_block list is empty.
  */
 static void __locks_insert_block(struct file_lock *blocker,
@@ -568,9 +569,9 @@ static void __locks_insert_block(struct file_lock *blocker,
 static void locks_insert_block(struct file_lock *blocker,
 					struct file_lock *waiter)
 {
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_lock_lock);
 	__locks_insert_block(blocker, waiter);
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_lock_lock);
 }
 
 /*
@@ -588,7 +589,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 	if (list_empty(&blocker->fl_block))
 		return;
 
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_lock_lock);
 	do {
 		struct file_lock *waiter;
 
@@ -600,7 +601,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
 		else
 			wake_up(&waiter->fl_wait);
 	} while (!list_empty(&blocker->fl_block));
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_lock_lock);
 }
 
 /* Insert file lock fl into an inode's lock list at the position indicated
@@ -754,7 +755,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 	return NULL;
 }
 
-/* Must be called with the file_lock_lock held! */
+/* Must be called with the blocked_lock_lock held! */
 static int posix_locks_deadlock(struct file_lock *caller_fl,
 				struct file_lock *block_fl)
 {
@@ -902,12 +903,12 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 			 * locks list must be done while holding the same lock!
 			 */
 			error = -EDEADLK;
-			spin_lock(&file_lock_lock);
+			spin_lock(&blocked_lock_lock);
 			if (likely(!posix_locks_deadlock(request, fl))) {
 				error = FILE_LOCK_DEFERRED;
 				__locks_insert_block(fl, request);
 			}
-			spin_unlock(&file_lock_lock);
+			spin_unlock(&blocked_lock_lock);
 			goto out;
   		}
   	}
@@ -2317,6 +2318,7 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
 	loff_t *p = f->private;
 
 	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_lock_lock);
 	*p = (*pos + 1);
 	return seq_hlist_start(&file_lock_list, *pos);
 }
@@ -2330,6 +2332,7 @@ static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
 
 static void locks_stop(struct seq_file *f, void *v)
 {
+	spin_unlock(&blocked_lock_lock);
 	spin_unlock(&file_lock_lock);
 }
 
-- 
1.7.1

