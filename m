Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:22887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755685Ab3FADIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 May 2013 23:08:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v1 05/11] locks: encapsulate the fl_link list handling
Date: Fri, 31 May 2013 23:07:28 -0400
Message-Id: <1370056054-25449-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the fl_link list handling routines into a separate set of helpers.
Also move the global list handling out of locks_insert_block, and into
the caller that ends up triggering it as that allows us to eliminate the
IS_POSIX check there.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |   34 +++++++++++++++++++++++++++++-----
 1 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index cef0e04..caca466 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -494,13 +494,38 @@ static int posix_same_owner(struct file_lock *fl1, struct file_lock *fl2)
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
 	list_del_init(&waiter->fl_block);
-	list_del_init(&waiter->fl_link);
+	locks_delete_global_blocked(waiter);
 	waiter->fl_next = NULL;
 }
 
@@ -524,8 +549,6 @@ static void locks_insert_block(struct file_lock *blocker,
 	BUG_ON(!list_empty(&waiter->fl_block));
 	list_add_tail(&waiter->fl_block, &blocker->fl_block);
 	waiter->fl_next = blocker;
-	if (IS_POSIX(blocker))
-		list_add(&waiter->fl_link, &blocked_list);
 }
 
 /* Wake up processes blocked waiting for blocker.
@@ -552,7 +575,7 @@ static void locks_wake_up_blocks(struct file_lock *blocker)
  */
 static void locks_insert_lock(struct file_lock **pos, struct file_lock *fl)
 {
-	list_add(&fl->fl_link, &file_lock_list);
+	locks_insert_global_locks(fl);
 
 	fl->fl_nspid = get_pid(task_tgid(current));
 
@@ -573,7 +596,7 @@ static void locks_delete_lock(struct file_lock **thisfl_p)
 
 	*thisfl_p = fl->fl_next;
 	fl->fl_next = NULL;
-	list_del_init(&fl->fl_link);
+	locks_delete_global_locks(fl);
 
 	if (fl->fl_nspid) {
 		put_pid(fl->fl_nspid);
@@ -839,6 +862,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				goto out;
 			error = FILE_LOCK_DEFERRED;
 			locks_insert_block(fl, request);
+			locks_insert_global_blocked(request);
 			goto out;
   		}
   	}
-- 
1.7.1

