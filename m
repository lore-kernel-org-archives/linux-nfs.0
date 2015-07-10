Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:34863 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933512AbbGJUdp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 16:33:45 -0400
Received: by ykee186 with SMTP id e186so72313039yke.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 13:33:44 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, william@gandi.net, bfields@fieldses.org
Subject: [RFC PATCH 2/4] locks: have flock_lock_file take an inode pointer instead of a filp
Date: Fri, 10 Jul 2015 16:33:32 -0400
Message-Id: <1436560414-26306-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
References: <1436560414-26306-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and rename it to better describe how it works.

In order to fix a use-after-free in NFS, we need to be able to remove
locks from an inode after the filp associated with them may have already
been freed. flock_lock_file already only dereferences the filp to get to
the inode, so just change it so the callers do that.

All of the callers already pass in a lock request that has the fl_file
set properly, so we don't need to pass it in individually. With that
change it now only dereferences the filp to get to the inode, so just
push that out to the callers.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/locks.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 653faabb07f4..4366b7c54e6d 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -862,12 +862,11 @@ static int posix_locks_deadlock(struct file_lock *caller_fl,
  * whether or not a lock was successfully freed by testing the return
  * value for -ENOENT.
  */
-static int flock_lock_file(struct file *filp, struct file_lock *request)
+static int flock_lock_inode(struct inode *inode, struct file_lock *request)
 {
 	struct file_lock *new_fl = NULL;
 	struct file_lock *fl;
 	struct file_lock_context *ctx;
-	struct inode *inode = file_inode(filp);
 	int error = 0;
 	bool found = false;
 	LIST_HEAD(dispose);
@@ -890,7 +889,7 @@ static int flock_lock_file(struct file *filp, struct file_lock *request)
 		goto find_conflict;
 
 	list_for_each_entry(fl, &ctx->flc_flock, fl_list) {
-		if (filp != fl->fl_file)
+		if (request->fl_file != fl->fl_file)
 			continue;
 		if (request->fl_type == fl->fl_type)
 			goto out;
@@ -1862,7 +1861,7 @@ int flock_lock_file_wait(struct file *filp, struct file_lock *fl)
 	int error;
 	might_sleep();
 	for (;;) {
-		error = flock_lock_file(filp, fl);
+		error = flock_lock_inode(file_inode(filp), fl);
 		if (error != FILE_LOCK_DEFERRED)
 			break;
 		error = wait_event_interruptible(fl->fl_wait, !fl->fl_next);
@@ -2401,7 +2400,8 @@ locks_remove_flock(struct file *filp)
 		.fl_type = F_UNLCK,
 		.fl_end = OFFSET_MAX,
 	};
-	struct file_lock_context *flctx = file_inode(filp)->i_flctx;
+	struct inode *inode = file_inode(filp);
+	struct file_lock_context *flctx = inode->i_flctx;
 
 	if (list_empty(&flctx->flc_flock))
 		return;
@@ -2409,7 +2409,7 @@ locks_remove_flock(struct file *filp)
 	if (filp->f_op->flock)
 		filp->f_op->flock(filp, F_SETLKW, &fl);
 	else
-		flock_lock_file(filp, &fl);
+		flock_lock_inode(inode, &fl);
 
 	if (fl.fl_ops && fl.fl_ops->fl_release_private)
 		fl.fl_ops->fl_release_private(&fl);
-- 
2.4.3

