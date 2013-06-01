Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4912 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757526Ab3FADIN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 23:08:13 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v1 09/11] locks: turn the blocked_list into a hashtable
Date: Fri, 31 May 2013 23:07:32 -0400
Message-Id: <1370056054-25449-10-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
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
---
 fs/locks.c |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 5ed056b..0d030ce 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -126,6 +126,7 @@
 #include <linux/time.h>
 #include <linux/rcupdate.h>
 #include <linux/pid_namespace.h>
+#include <linux/hashtable.h>
 
 #include <asm/uaccess.h>
 
@@ -163,10 +164,19 @@ int lease_break_time = 45;
 #define for_each_lock(inode, lockp) \
 	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
 
+/*
+ * By breaking up the blocked locks list into a hashtable, we speed up the
+ * deadlock detection.
+ *
+ * FIXME: make this value scale via some heuristic?
+ */
+#define BLOCKED_HASH_BITS	7
+
+static DEFINE_HASHTABLE(blocked_hash, BLOCKED_HASH_BITS);
+
 static HLIST_HEAD(file_lock_list);
-static HLIST_HEAD(blocked_list);
 
-/* Protects the two list heads above */
+/* Protects the file_lock_list and the blocked_hash */
 static DEFINE_SPINLOCK(file_lock_lock);
 
 static struct kmem_cache *filelock_cache __read_mostly;
@@ -486,7 +496,8 @@ static inline void
 locks_insert_global_blocked(struct file_lock *waiter)
 {
 	spin_lock(&file_lock_lock);
-	hlist_add_head(&waiter->fl_link, &blocked_list);
+	hash_add(blocked_hash, &waiter->fl_link,
+				(unsigned long)waiter->fl_owner);
 	spin_unlock(&file_lock_lock);
 }
 
@@ -494,7 +505,7 @@ static inline void
 locks_delete_global_blocked(struct file_lock *waiter)
 {
 	spin_lock(&file_lock_lock);
-	hlist_del_init(&waiter->fl_link);
+	hash_del(&waiter->fl_link);
 	spin_unlock(&file_lock_lock);
 }
 
@@ -705,7 +716,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 {
 	struct file_lock *fl, *ret = NULL;
 
-	hlist_for_each_entry(fl, &blocked_list, fl_link) {
+	hash_for_each_possible(blocked_hash, fl, fl_link, (unsigned long)block_fl->fl_owner) {
 		if (posix_same_owner(fl, block_fl)) {
 			ret = fl->fl_next;
 			if (likely(ret))
@@ -2275,13 +2286,14 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 
 static int locks_show(struct seq_file *f, void *v)
 {
+	int bkt;
 	struct file_lock *fl, *bfl;
 
 	fl = hlist_entry(v, struct file_lock, fl_link);
 
 	lock_get_status(f, fl, *((loff_t *)f->private), "");
 
-	hlist_for_each_entry(bfl, &blocked_list, fl_link) {
+	hash_for_each(blocked_hash, bkt, bfl, fl_link) {
 		if (bfl->fl_next == fl)
 			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
 	}
-- 
1.7.1

