Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21752 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757966Ab3FADIR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 23:08:17 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v1 11/11] locks: give the blocked_hash its own spinlock
Date: Fri, 31 May 2013 23:07:34 -0400
Message-Id: <1370056054-25449-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no reason we have to protect the blocked_hash and file_lock_list
with the same spinlock. With the tests I have, breaking it in two gives
a barely measurable performance benefit, but it seems reasonable to make
this locking as granular as possible.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 Documentation/filesystems/Locking |   16 ++++++++--------
 fs/locks.c                        |   17 ++++++++++-------
 2 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index ee351ac..8d8d040 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -359,20 +359,20 @@ prototypes:
 
 locking rules:
 
-			inode->i_lock	file_lock_lock	may block
-lm_compare_owner:	yes		maybe		no
-lm_owner_key		yes		yes		no
-lm_notify:		yes		no		no
-lm_grant:		no		no		no
-lm_break:		yes		no		no
-lm_change		yes		no		no
+			inode->i_lock	blocked_hash_lock	may block
+lm_compare_owner:	yes		maybe			no
+lm_owner_key		yes		yes			no
+lm_notify:		yes		no			no
+lm_grant:		no		no			no
+lm_break:		yes		no			no
+lm_change		yes		no			no
 
 	->lm_compare_owner and ->lm_owner_key are generally called with
 *an* inode->i_lock held. It may not be the i_lock of the inode
 associated with either file_lock argument! This is the case with deadlock
 detection, since the code has to chase down the owners of locks that may
 be entirely unrelated to the one on which the lock is being acquired.
-For deadlock detection however, the file_lock_lock is also held. The
+For deadlock detection however, the blocked_hash_lock is also held. The
 fact that these locks are held ensures that the file_locks do not
 disappear out from under you while doing the comparison or generating an
 owner key.
diff --git a/fs/locks.c b/fs/locks.c
index 8219187..520f32b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -172,12 +172,13 @@ int lease_break_time = 45;
  */
 #define BLOCKED_HASH_BITS	7
 
+static DEFINE_SPINLOCK(blocked_hash_lock);
 static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
 
+static DEFINE_SPINLOCK(file_lock_lock);
 static HLIST_HEAD(file_lock_list);
 
 /* Protects the file_lock_list and the blocked_hash */
-static DEFINE_SPINLOCK(file_lock_lock);
 
 static struct kmem_cache *filelock_cache __read_mostly;
 
@@ -503,17 +504,17 @@ posix_owner_key(struct file_lock *fl)
 static inline void
 locks_insert_global_blocked(struct file_lock *waiter)
 {
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_hash_lock);
 	hash_add(blocked_hash, &waiter->fl_link, posix_owner_key(waiter));
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_hash_lock);
 }
 
 static inline void
 locks_delete_global_blocked(struct file_lock *waiter)
 {
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_hash_lock);
 	hash_del(&waiter->fl_link);
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_hash_lock);
 }
 
 static inline void
@@ -739,7 +740,7 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
 	int i = 0;
 	int ret = 0;
 
-	spin_lock(&file_lock_lock);
+	spin_lock(&blocked_hash_lock);
 	while ((block_fl = what_owner_is_waiting_for(block_fl))) {
 		if (i++ > MAX_DEADLK_ITERATIONS)
 			break;
@@ -748,7 +749,7 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
 			break;
 		}
 	}
-	spin_unlock(&file_lock_lock);
+	spin_unlock(&blocked_hash_lock);
 	return ret;
 }
 
@@ -2300,10 +2301,12 @@ static int locks_show(struct seq_file *f, void *v)
 
 	lock_get_status(f, fl, *((loff_t *)f->private), "");
 
+	spin_lock(&blocked_hash_lock);
 	hash_for_each(blocked_hash, bkt, bfl, fl_link) {
 		if (bfl->fl_next == fl)
 			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
 	}
+	spin_unlock(&blocked_hash_lock);
 
 	return 0;
 }
-- 
1.7.1

