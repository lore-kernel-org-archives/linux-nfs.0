Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab3FQPOe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:34 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 09/13] locks: turn the blocked_list into a hashtable
Date: Mon, 17 Jun 2013 11:13:52 -0400
Message-Id: <1371482036-15958-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Break up the blocked_list into a hashtable, using the fl_owner as a key.
This speeds up searching the hash chains, which is especially significant
for deadlock detection.

Note that the initial implementation assumes that hashing on fl_owner is
sufficient. In most cases it should be, with the notable exception being
server-side lockd, which compares ownership using a tuple of the
nlm_host and the pid sent in the lock request. So, this may degrade to a
single hash bucket when you only have a single NFS client. That will be
addressed in a later patch.

The careful observer may note that this patch leaves the file_lock_list
alone. There's much less of a case for turning the file_lock_list into a
hashtable. The only user of that list is the code that generates
/proc/locks, and it always walks the entire list.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 32826ed..d93b291 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -126,6 +126,7 @@
 #include <linux/time.h>
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
+#include <linux/hashtable.h>
 
 #include <asm/uaccess.h>
 
@@ -160,12 +161,20 @@ int lease_break_time = 45;
 static HLIST_HEAD(file_lock_list);
 
 /*
- * The blocked_list is used to find POSIX lock loops for deadlock detection.
- * Protected by file_lock_lock.
+ * The blocked_hash is used to find POSIX lock loops for deadlock detection.
+ * It is protected by file_lock_lock.
+ *
+ * We hash locks by lockowner in order to optimize searching for the lock a
+ * particular lockowner is waiting on.
+ *
+ * FIXME: make this value scale via some heuristic? We generally will want more
+ * buckets when we have more lockowners holding locks, but that's a little
+ * difficult to determine without knowing what the workload will look like.
  */
-static HLIST_HEAD(blocked_list);
+#define BLOCKED_HASH_BITS	7
+static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
 
-/* Protects the two list heads above, and fl->fl_block list. */
+/* Protects the file_lock_list, the blocked_hash and fl->fl_block list */
 static DEFINE_SPINLOCK(file_lock_lock);
 
 static struct kmem_cache *filelock_cache __read_mostly;
@@ -499,13 +508,13 @@ locks_delete_global_locks(struct file_lock *waiter)
 static inline void
 locks_insert_global_blocked(struct file_lock *waiter)
 {
-	hlist_add_head(&waiter->fl_link, &blocked_list);
+	hash_add(blocked_hash, &waiter->fl_link, (unsigned long)waiter->fl_owner);
 }
 
 static inline void
 locks_delete_global_blocked(struct file_lock *waiter)
 {
-	hlist_del_init(&waiter->fl_link);
+	hash_del(&waiter->fl_link);
 }
 
 /* Remove waiter from blocker's block list.
@@ -730,7 +739,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 {
 	struct file_lock *fl;
 
-	hlist_for_each_entry(fl, &blocked_list, fl_link) {
+	hash_for_each_possible(blocked_hash, fl, fl_link, (unsigned long)block_fl->fl_owner) {
 		if (posix_same_owner(fl, block_fl))
 			return fl->fl_next;
 	}
@@ -866,7 +875,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	/*
 	 * New lock request. Walk all POSIX locks and look for conflicts. If
 	 * there are any, either return error or put the request on the
-	 * blocker's list of waiters and the global blocked_list.
+	 * blocker's list of waiters and the global blocked_hash.
 	 */
 	if (request->fl_type != F_UNLCK) {
 		for_each_lock(inode, before) {
-- 
1.7.1

