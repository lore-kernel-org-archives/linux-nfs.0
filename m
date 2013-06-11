Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754625Ab3FKLJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 07:09:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v2 05/14] locks: encapsulate the fl_link list handling
Date: Tue, 11 Jun 2013 07:08:59 -0400
Message-Id: <1370948948-31784-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the fl_link list handling routines into a separate set of helpers.
Also move the global list handling out of locks_insert_block, and into
the caller that ends up triggering it as that allows us to eliminate the
IS_POSIX check there.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Acked-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/locks.c |   37 +++++++++++++++++++++++++++++++------
 1 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c186649..e451d18 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -484,13 +484,38 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
 	return fl1->fl_owner == fl2->fl_owner;
 }
 
+/* Remove a blocker or lock from one of the global lists */
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
+static inline void
+locks_insert_global_locks(struct file_lock *waiter)
+{
+	list_add_tail(&waiter->fl_link, &file_lock_list);
+}
+
+static inline void
+locks_delete_global_locks(struct file_lock *waiter)
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
 
@@ -514,8 +539,6 @@ static void locks_insert_block(struct file_lock *blocker,
 	BUG_ON(!list_empty(&waiter->fl_block));
 	list_add_tail(&waiter->fl_block, &blocker->fl_block);
 	waiter->fl_next = blocker;
-	if (IS_POSIX(blocker))
-		list_add(&waiter->fl_link, &blocked_list);
 }
 
 /*
@@ -543,13 +566,13 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
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
@@ -562,9 +585,10 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 {
 	struct file_lock *fl = *thisfl_p;
 
+	locks_delete_global_locks(fl);
+
 	*thisfl_p = fl->fl_next;
 	fl->fl_next = NULL;
-	list_del_init(&fl->fl_link);
 
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
@@ -830,6 +854,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				goto out;
 			error = FILE_LOCK_DEFERRED;
 			locks_insert_block(fl, request);
+			locks_insert_global_blocked(request);
 			goto out;
   		}
   	}
-- 
1.7.1

