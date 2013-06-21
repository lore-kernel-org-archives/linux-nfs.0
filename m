Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965835Ab3FUM6z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Jun 2013 08:58:55 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v4 06/14] locks: encapsulate the fl_link list handling
Date: Fri, 21 Jun 2013 08:58:14 -0400
Message-Id: <1371819502-26363-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
References: <1371819502-26363-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the fl_link list handling routines into a separate set of helpers.
Also ensure that locks and requests are always put on global lists
last (after fully initializing them) and are taken off before unintializing
them.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |   45 ++++++++++++++++++++++++++++++++++++---------
 1 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 1d6cb28..89d898b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -153,13 +153,15 @@ int lease_break_time = 45;
 #define for_each_lock(inode, lockp) \
 	for (lockp = &inode->i_flock; *lockp != NULL; lockp = &(*lockp)->fl_next)
 
+/* The global file_lock_list is only used for displaying /proc/locks. */
 static LIST_HEAD(file_lock_list);
+
+/* The blocked_list is used to find POSIX lock loops for deadlock detection. */
 static LIST_HEAD(blocked_list);
+
+/* Protects the two list heads above, plus the inode->i_flock list */
 static DEFINE_SPINLOCK(file_lock_lock);
 
-/*
- * Protects the two list heads above, plus the inode->i_flock list
- */
 void lock_flocks(void)
 {
 	spin_lock(&file_lock_lock);
@@ -484,13 +486,37 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 	return fl1->fl_owner == fl2->fl_owner;
 }
 
+static inline void
+locks_insert_global_locks(struct file_lock *fl)
+{
+	list_add_tail(&fl->fl_link, &file_lock_list);
+}
+
+static inline void
+locks_delete_global_locks(struct file_lock *fl)
+{
+	list_del_init(&fl->fl_link);
+}
+
+static inline void
+locks_insert_global_blocked(struct file_lock *waiter)
+{
+	list_add(&waiter->fl_link, &blocked_list);
+}
+
+static inline void
+locks_delete_global_blocked(struct file_lock *waiter)
+{
+	list_del_init(&waiter->fl_link);
+}
+
 /* Remove waiter from blocker's block list.
  * When blocker ends up pointing to itself then the list is empty.
  */
 static void __locks_delete_block(struct file_lock *waiter)
 {
+	locks_delete_global_blocked(waiter);
 	list_del_init(&waiter->fl_block);
-	list_del_init(&waiter->fl_link);
 	waiter->fl_next = NULL;
 }
 
@@ -512,10 +538,10 @@ static void locks_insert_block(struct file_lock *blocker,
 			       struct file_lock *waiter)
 {
 	BUG_ON(!list_empty(&waiter->fl_block));
-	list_add_tail(&waiter->fl_block, &blocker->fl_block);
 	waiter->fl_next = blocker;
+	list_add_tail(&waiter->fl_block, &blocker->fl_block);
 	if (IS_POSIX(blocker))
-		list_add(&waiter->fl_link, &blocked_list);
+		locks_insert_global_blocked(request);
 }
 
 /*
@@ -543,13 +569,13 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
  */
 static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 {
-	list_add(&fl->fl_link, &file_lock_list);
-
 	fl->fl_nspid = get_pid(task_tgid(current));
 
 	/* insert into file's list */
 	fl->fl_next = *pos;
 	*pos = fl;
+
+	locks_insert_global_locks(fl);
 }
 
 /*
@@ -562,9 +588,10 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 {
 	struct file_lock *fl = *thisfl_p;
 
+	locks_delete_global_locks(fl);
+
 	*thisfl_p = fl->fl_next;
 	fl->fl_next = NULL;
-	list_del_init(&fl->fl_link);
 
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
-- 
1.7.1

