Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:45459 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212AbaIDMjT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:19 -0400
Received: by mail-qc0-f178.google.com with SMTP id x13so10240507qcv.37
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 14/17] locks: __break_lease cleanup in preparation of allowing direct removal of leases
Date: Thu,  4 Sep 2014 08:38:40 -0400
Message-Id: <1409834323-7171-15-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate an unneeded "flock" variable. We can use "fl" as a loop cursor
everywhere. Add a any_leases_conflict helper function as well to
consolidate a bit of code.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 011812490c92..246ba53650f7 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1351,6 +1351,20 @@ static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 	return locks_conflict(breaker, lease);
 }
 
+static bool
+any_leases_conflict(struct inode *inode, struct file_lock *breaker)
+{
+	struct file_lock *fl;
+
+	lockdep_assert_held(&inode->i_lock);
+
+	for (fl = inode->i_flock ; fl && IS_LEASE(fl); fl = fl->fl_next) {
+		if (leases_conflict(fl, breaker))
+			return true;
+	}
+	return false;
+}
+
 /**
  *	__break_lease	-	revoke all outstanding leases on file
  *	@inode: the inode of the file to return
@@ -1367,10 +1381,9 @@ static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
 int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	int error = 0;
-	struct file_lock *new_fl, *flock;
+	struct file_lock *new_fl;
 	struct file_lock *fl;
 	unsigned long break_time;
-	bool lease_conflict = false;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
 
@@ -1383,17 +1396,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 
 	time_out_leases(inode, &dispose);
 
-	flock = inode->i_flock;
-	if ((flock == NULL) || !IS_LEASE(flock))
-		goto out;
-
-	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
-		if (leases_conflict(fl, new_fl)) {
-			lease_conflict = true;
-			break;
-		}
-	}
-	if (!lease_conflict)
+	if (!any_leases_conflict(inode, new_fl))
 		goto out;
 
 	break_time = 0;
@@ -1403,7 +1406,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			break_time++;	/* so that 0 means no break time */
 	}
 
-	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+	for (fl = inode->i_flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
 		if (!leases_conflict(fl, new_fl))
 			continue;
 		if (want_write) {
@@ -1412,7 +1415,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			fl->fl_flags |= FL_UNLOCK_PENDING;
 			fl->fl_break_time = break_time;
 		} else {
-			if (lease_breaking(flock))
+			if (lease_breaking(inode->i_flock))
 				continue;
 			fl->fl_flags |= FL_DOWNGRADE_PENDING;
 			fl->fl_downgrade_time = break_time;
@@ -1427,12 +1430,12 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 	}
 
 restart:
-	break_time = flock->fl_break_time;
+	break_time = inode->i_flock->fl_break_time;
 	if (break_time != 0)
 		break_time -= jiffies;
 	if (break_time == 0)
 		break_time++;
-	locks_insert_block(flock, new_fl);
+	locks_insert_block(inode->i_flock, new_fl);
 	trace_break_lease_block(inode, new_fl);
 	spin_unlock(&inode->i_lock);
 	locks_dispose_list(&dispose);
@@ -1442,17 +1445,15 @@ restart:
 	trace_break_lease_unblock(inode, new_fl);
 	locks_delete_block(new_fl);
 	if (error >= 0) {
-		if (error == 0)
-			time_out_leases(inode, &dispose);
 		/*
 		 * Wait for the next conflicting lease that has not been
 		 * broken yet
 		 */
-		for (flock = inode->i_flock; flock && IS_LEASE(flock);
-				flock = flock->fl_next) {
-			if (leases_conflict(new_fl, flock))
-				goto restart;
-		}
+		if (error == 0)
+			time_out_leases(inode, &dispose);
+		if (any_leases_conflict(inode, new_fl))
+			goto restart;
+
 		error = 0;
 	}
 
-- 
1.9.3

