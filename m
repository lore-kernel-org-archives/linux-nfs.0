Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757663Ab3FADIN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
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
Subject: [PATCH v1 07/11] locks: only pull entries off of blocked_list when they are really unblocked
Date: Fri, 31 May 2013 23:07:30 -0400
Message-Id: <1370056054-25449-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, when there is a lot of lock contention the kernel spends an
inordinate amount of time taking blocked locks off of the global
blocked_list and then putting them right back on again. When all of this
code was protected by a single lock, then it didn't matter much, but now
it means a lot of file_lock_lock thrashing.

Optimize this a bit by deferring the removal from the blocked_list until
we're either applying or cancelling the lock. By doing this, and using a
lockless list_empty check, we can avoid taking the file_lock_lock in
many cases.

Because the fl_link check is lockless, we must ensure that only the task
that "owns" the request manipulates the fl_link. Also, with this change,
it's possible that we'll see an entry on the blocked_list that has a
NULL fl_next pointer. In that event, just ignore it and continue walking
the list.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 055c06c..fc35b9e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -520,7 +520,6 @@ locks_delete_global_locks(struct file_lock *waiter)
 static void __locks_delete_block(struct file_lock *waiter)
 {
 	list_del_init(&waiter->fl_block);
-	locks_delete_global_blocked(waiter);
 	waiter->fl_next = NULL;
 }
 
@@ -704,13 +703,16 @@ EXPORT_SYMBOL(posix_test_lock);
 /* Find a lock that the owner of the given block_fl is blocking on. */
 static struct file_lock *what_owner_is_waiting_for(struct file_lock *block_fl)
 {
-	struct file_lock *fl;
+	struct file_lock *fl, *ret = NULL;
 
 	list_for_each_entry(fl, &blocked_list, fl_link) {
-		if (posix_same_owner(fl, block_fl))
-			return fl->fl_next;
+		if (posix_same_owner(fl, block_fl)) {
+			ret = fl->fl_next;
+			if (likely(ret))
+				break;
+		}
 	}
-	return NULL;
+	return ret;
 }
 
 static int posix_locks_deadlock(struct file_lock *caller_fl,
@@ -865,7 +867,8 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 				goto out;
 			error = FILE_LOCK_DEFERRED;
 			locks_insert_block(fl, request);
-			locks_insert_global_blocked(request);
+			if (list_empty(&request->fl_link))
+				locks_insert_global_blocked(request);
 			goto out;
   		}
   	}
@@ -876,6 +879,16 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
 		goto out;
 
 	/*
+	 * Now that we know the request is no longer blocked, we can take it
+	 * off the global list. Some callers send down partially initialized
+	 * requests, so we only do this if FL_SLEEP is set. Also, avoid taking
+	 * the lock if the list is empty, as that indicates a request that
+	 * never blocked.
+	 */
+	if ((request->fl_flags & FL_SLEEP) && !list_empty(&request->fl_link))
+		locks_delete_global_blocked(request);
+
+	/*
 	 * Find the first old lock with the same owner as the new lock.
 	 */
 	
@@ -1069,6 +1082,7 @@ int posix_lock_file_wait(struct file *filp, struct file_lock *fl)
 			continue;
 
 		locks_delete_block(fl);
+		locks_delete_global_blocked(fl);
 		break;
 	}
 	return error;
@@ -1147,6 +1161,7 @@ int locks_mandatory_area(int read_write, struct inode *inode,
 		}
 
 		locks_delete_block(&fl);
+		locks_delete_global_blocked(&fl);
 		break;
 	}
 
@@ -1859,6 +1874,7 @@ static int do_lock_file_wait(struct file *filp, unsigned int cmd,
 			continue;
 
 		locks_delete_block(fl);
+		locks_delete_global_blocked(fl);
 		break;
 	}
 
@@ -2160,6 +2176,7 @@ posix_unblock_lock(struct file *filp, struct file_lock *waiter)
 	else
 		status = -ENOENT;
 	spin_unlock(&inode->i_lock);
+	locks_delete_global_blocked(waiter);
 	return status;
 }
 
-- 
1.7.1

