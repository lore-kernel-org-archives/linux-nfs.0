Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21523 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab3FQPOd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Jun 2013 11:14:33 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v3 08/13] locks: convert fl_link to a hlist_node
Date: Mon, 17 Jun 2013 11:13:51 -0400
Message-Id: <1371482036-15958-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
References: <1371482036-15958-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Testing has shown that iterating over the blocked_list for deadlock
detection turns out to be a bottleneck. In order to alleviate that,
begin the process of turning it into a hashtable. We start by turning
the fl_link into a hlist_node and the global lists into hlists. A later
patch will do the conversion of the blocked_list to a hashtable.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c         |   24 ++++++++++++------------
 include/linux/fs.h |    2 +-
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index a8f3b33..32826ed 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -157,13 +157,13 @@ int lease_break_time = 45;
  * The global file_lock_list is only used for displaying /proc/locks. Protected
  * by the file_lock_lock.
  */
-static LIST_HEAD(file_lock_list);
+static HLIST_HEAD(file_lock_list);
 
 /*
  * The blocked_list is used to find POSIX lock loops for deadlock detection.
  * Protected by file_lock_lock.
  */
-static LIST_HEAD(blocked_list);
+static HLIST_HEAD(blocked_list);
 
 /* Protects the two list heads above, and fl->fl_block list. */
 static DEFINE_SPINLOCK(file_lock_lock);
@@ -172,7 +172,7 @@ static struct kmem_cache *filelock_cache __read_mostly;
 
 static void locks_init_lock_heads(struct file_lock *fl)
 {
-	INIT_LIST_HEAD(&fl->fl_link);
+	INIT_HLIST_NODE(&fl->fl_link);
 	INIT_LIST_HEAD(&fl->fl_block);
 	init_waitqueue_head(&fl->fl_wait);
 }
@@ -206,7 +206,7 @@ void locks_free_lock(struct file_lock *fl)
 {
 	BUG_ON(waitqueue_active(&fl->fl_wait));
 	BUG_ON(!list_empty(&fl->fl_block));
-	BUG_ON(!list_empty(&fl->fl_link));
+	BUG_ON(!hlist_unhashed(&fl->fl_link));
 
 	locks_release_private(fl);
 	kmem_cache_free(filelock_cache, fl);
@@ -484,7 +484,7 @@ static inline void
 locks_insert_global_locks(struct file_lock *waiter)
 {
 	spin_lock(&file_lock_lock);
-	list_add_tail(&waiter->fl_link, &file_lock_list);
+	hlist_add_head(&waiter->fl_link, &file_lock_list);
 	spin_unlock(&file_lock_lock);
 }
 
@@ -492,20 +492,20 @@ static inline void
 locks_delete_global_locks(struct file_lock *waiter)
 {
 	spin_lock(&file_lock_lock);
-	list_del_init(&waiter->fl_link);
+	hlist_del_init(&waiter->fl_link);
 	spin_unlock(&file_lock_lock);
 }
 
 static inline void
 locks_insert_global_blocked(struct file_lock *waiter)
 {
-	list_add(&waiter->fl_link, &blocked_list);
+	hlist_add_head(&waiter->fl_link, &blocked_list);
 }
 
 static inline void
 locks_delete_global_blocked(struct file_lock *waiter)
 {
-	list_del_init(&waiter->fl_link);
+	hlist_del_init(&waiter->fl_link);
 }
 
 /* Remove waiter from blocker's block list.
@@ -730,7 +730,7 @@ static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 {
 	struct file_lock *fl;
 
-	list_for_each_entry(fl, &blocked_list, fl_link) {
+	hlist_for_each_entry(fl, &blocked_list, fl_link) {
 		if (posix_same_owner(fl, block_fl))
 			return fl->fl_next;
 	}
@@ -2285,7 +2285,7 @@ static int locks_show(struct seq_file *f, void *v)
 {
 	struct file_lock *fl, *bfl;
 
-	fl = list_entry(v, struct file_lock, fl_link);
+	fl = hlist_entry(v, struct file_lock, fl_link);
 
 	lock_get_status(f, fl, *((loff_t *)f->private), "");
 
@@ -2301,14 +2301,14 @@ static void *locks_start(struct seq_file *f, loff_t *pos)
 
 	spin_lock(&file_lock_lock);
 	*p = (*pos + 1);
-	return seq_list_start(&file_lock_list, *pos);
+	return seq_hlist_start(&file_lock_list, *pos);
 }
 
 static void *locks_next(struct seq_file *f, void *v, loff_t *pos)
 {
 	loff_t *p = f->private;
 	++*p;
-	return seq_list_next(v, &file_lock_list, pos);
+	return seq_hlist_next(v, &file_lock_list, pos);
 }
 
 static void locks_stop(struct seq_file *f, void *v)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index e2f896d..3b340f7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -946,7 +946,7 @@ int locks_in_grace(struct net *);
  */
 struct file_lock {
 	struct file_lock *fl_next;	/* singly linked list for this inode  */
-	struct list_head fl_link;	/* doubly linked list of all locks */
+	struct hlist_node fl_link;	/* node in global lists */
 	struct list_head fl_block;	/* circular list of blocked processes */
 	fl_owner_t fl_owner;
 	unsigned int fl_flags;
-- 
1.7.1

