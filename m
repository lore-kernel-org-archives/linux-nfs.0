Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754627Ab3FKLJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
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
Subject: [PATCH v2 03/14] locks: comment cleanups and clarifications
Date: Tue, 11 Jun 2013 07:08:57 -0400
Message-Id: <1370948948-31784-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c         |   21 +++++++++++++--------
 include/linux/fs.h |   18 ++++++++++++++++++
 2 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index e3140b8..1e6301b 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -518,9 +518,10 @@ static void locks_insert_block(struct file_lock *blocker,
 		list_add(&waiter->fl_link, &blocked_list);
 }
 
-/* Wake up processes blocked waiting for blocker.
- * If told to wait then schedule the processes until the block list
- * is empty, otherwise empty the block list ourselves.
+/*
+ * Wake up processes blocked waiting for blocker.
+ *
+ * Must be called with the file_lock_lock held!
  */
 static void locks_wake_up_blocks(struct file_lock *blocker)
 {
@@ -806,6 +807,11 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	}
 
 	lock_flocks();
+	/*
+	 * New lock request. Walk all POSIX locks and look for conflicts. If
+	 * there are any, either return error or put the request on the
+	 * blocker's list of waiters and the global blocked_list.
+	 */
 	if (request->fl_type != F_UNLCK) {
 		for_each_lock(inode, before) {
 			fl = *before;
@@ -844,7 +850,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		before = &fl->fl_next;
 	}
 
-	/* Process locks with this owner.  */
+	/* Process locks with this owner. */
 	while ((fl = *before) && posix_same_owner(request, fl)) {
 		/* Detect adjacent or overlapping regions (if same lock type)
 		 */
@@ -930,10 +936,9 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 	}
 
 	/*
-	 * The above code only modifies existing locks in case of
-	 * merging or replacing.  If new lock(s) need to be inserted
-	 * all modifications are done bellow this, so it's safe yet to
-	 * bail out.
+	 * The above code only modifies existing locks in case of merging or
+	 * replacing. If new lock(s) need to be inserted all modifications are
+	 * done below this, so it's safe yet to bail out.
 	 */
 	error = -ENOLCK; /* "no luck" */
 	if (right && left == right && !new_fl2)
diff --git a/include/linux/fs.h b/include/linux/fs.h
index b9d7816..94105d2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -926,6 +926,24 @@ int locks_in_grace(struct net *);
 /* that will die - we need it for nfs_lock_info */
 #include <linux/nfs_fs_i.h>
 
+/*
+ * struct file_lock represents a generic "file lock". It's used to represent
+ * POSIX byte range locks, BSD (flock) locks, and leases. It's important to
+ * note that the same struct is used to represent both a request for a lock and
+ * the lock itself, but the same object is never used for both.
+ *
+ * FIXME: should we create a separate "struct lock_request" to help distinguish
+ * these two uses?
+ *
+ * The i_flock list is ordered by:
+ *
+ * 1) lock type -- FL_LEASEs first, then FL_FLOCK, and finally FL_POSIX
+ * 2) lock owner
+ * 3) lock range start
+ * 4) lock range end
+ *
+ * Obviously, the last two criteria only matter for POSIX locks.
+ */
 struct file_lock {
 	struct file_lock *fl_next;	/* singly linked list for this inode  */
 	struct list_head fl_link;	/* doubly linked list of all locks */
-- 
1.7.1

