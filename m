Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:54522 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751960Ab3AQQxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2013 11:53:17 -0500
From: Pavel Shilovsky <piastry@etersoft.ru>
To: linux-kernel@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Subject: [PATCH v2 1/8] locks: make flock_lock_file take is_conflict callback parm
Date: Thu, 17 Jan 2013 20:52:57 +0400
Message-Id: <1358441584-8783-1-git-send-email-piastry@etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This parm demetermines how to check if locks have conflicts.
This let us use flock_lock_file funtions further to add
O_DENY* flags support through flocks.

Signed-off-by: Pavel Shilovsky <piastry@etersoft.ru>
---
 fs/locks.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index a94e331..9edfec4 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -697,14 +697,20 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
 	return 0;
 }
 
-/* Try to create a FLOCK lock on filp. We always insert new FLOCK locks
+/*
+ * Try to create a FLOCK lock on filp. We always insert new FLOCK locks
  * after any leases, but before any posix locks.
  *
  * Note that if called with an FL_EXISTS argument, the caller may determine
  * whether or not a lock was successfully freed by testing the return
  * value for -ENOENT.
+ *
+ * Take @is_conflict callback that determines how to check if locks have
+ * conflicts or not.
  */
-static int flock_lock_file(struct file *filp, struct file_lock *request)
+static int
+flock_lock_file(struct file *filp, struct file_lock *request,
+		int (*is_conflict)(struct file_lock *, struct file_lock *))
 {
 	struct file_lock *new_fl = NULL;
 	struct file_lock **before;
@@ -760,7 +766,7 @@ find_conflict:
 			break;
 		if (IS_LEASE(fl))
 			continue;
-		if (!flock_locks_conflict(request, fl))
+		if (!is_conflict(request, fl))
 			continue;
 		error = -EAGAIN;
 		if (!(request->fl_flags & FL_SLEEP))
@@ -1589,7 +1595,7 @@ int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
 	int error;
 	might_sleep();
 	for (;;) {
-		error = flock_lock_file(filp, fl);
+		error = flock_lock_file(filp, fl, flock_locks_conflict);
 		if (error != FILE_LOCK_DEFERRED)
 			break;
 		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
-- 
1.8.1.1

