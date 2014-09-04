Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:40037 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbaIDMjU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:39:20 -0400
Received: by mail-qg0-f52.google.com with SMTP id z60so9819028qgd.39
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:39:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: [PATCH v2 15/17] locks: give lm_break a return value
Date: Thu,  4 Sep 2014 08:38:41 -0400
Message-Id: <1409834323-7171-16-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Christoph suggests:

   "Add a return value to lm_break so that the lock manager can tell the
    core code "you can delete this lease right now".  That gets rid of
    the games with the timeout which require all kinds of race avoidance
    code in the users."

Do that here and have the nfsd lease break routine use it when it detects
that there was a race between setting up the lease and it being broken.

Cc: Christoph Hellwig <hch@infradead.org>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c          | 17 +++++++++++++----
 fs/nfsd/nfs4state.c | 17 +++++++++--------
 include/linux/fs.h  |  2 +-
 3 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 246ba53650f7..5a97e7c4e7f2 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -427,9 +427,11 @@ static int flock_to_posix_lock(struct file *filp, struct file_lock *fl,
 }
 
 /* default lease lock manager operations */
-static void lease_break_callback(struct file_lock *fl)
+static bool
+lease_break_callback(struct file_lock *fl)
 {
 	kill_fasync(&fl->fl_fasync, SIGIO, POLL_MSG);
+	return false;
 }
 
 static void
@@ -1382,7 +1384,7 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 {
 	int error = 0;
 	struct file_lock *new_fl;
-	struct file_lock *fl;
+	struct file_lock *fl, **before;
 	unsigned long break_time;
 	int want_write = (mode & O_ACCMODE) != O_RDONLY;
 	LIST_HEAD(dispose);
@@ -1406,7 +1408,9 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			break_time++;	/* so that 0 means no break time */
 	}
 
-	for (fl = inode->i_flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
+	for (before = &inode->i_flock;
+			((fl = *before) != NULL) && IS_LEASE(fl);
+			before = &fl->fl_next) {
 		if (!leases_conflict(fl, new_fl))
 			continue;
 		if (want_write) {
@@ -1420,9 +1424,14 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
 			fl->fl_flags |= FL_DOWNGRADE_PENDING;
 			fl->fl_downgrade_time = break_time;
 		}
-		fl->fl_lmops->lm_break(fl);
+		if (fl->fl_lmops->lm_break(fl))
+			locks_delete_lock(before, &dispose);
 	}
 
+	fl = inode->i_flock;
+	if (!fl || !IS_LEASE(fl))
+		goto out;
+
 	if (mode & O_NONBLOCK) {
 		trace_break_lease_noblock(inode, new_fl);
 		error = -EWOULDBLOCK;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 44e04d6be676..8597fbeea3bb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3387,18 +3387,20 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 }
 
 /* Called from break_lease() with i_lock held. */
-static void nfsd_break_deleg_cb(struct file_lock *fl)
+static bool
+nfsd_break_deleg_cb(struct file_lock *fl)
 {
+	bool ret = false;
 	struct nfs4_file *fp = (struct nfs4_file *)fl->fl_owner;
 	struct nfs4_delegation *dp;
 
 	if (!fp) {
 		WARN(1, "(%p)->fl_owner NULL\n", fl);
-		return;
+		return ret;
 	}
 	if (fp->fi_had_conflict) {
 		WARN(1, "duplicate break on %p\n", fp);
-		return;
+		return ret;
 	}
 	/*
 	 * We don't want the locks code to timeout the lease for us;
@@ -3410,17 +3412,16 @@ static void nfsd_break_deleg_cb(struct file_lock *fl)
 	spin_lock(&fp->fi_lock);
 	fp->fi_had_conflict = true;
 	/*
-	 * If there are no delegations on the list, then we can't count on this
-	 * lease ever being cleaned up. Set the fl_break_time to jiffies so that
-	 * time_out_leases will do it ASAP. The fact that fi_had_conflict is now
-	 * true should keep any new delegations from being hashed.
+	 * If there are no delegations on the list, then return true
+	 * so that the lease code will go ahead and delete it.
 	 */
 	if (list_empty(&fp->fi_delegations))
-		fl->fl_break_time = jiffies;
+		ret = true;
 	else
 		list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
 			nfsd_break_one_deleg(dp);
 	spin_unlock(&fp->fi_lock);
+	return ret;
 }
 
 static int
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f419f718e447..ed4e1897099c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -872,7 +872,7 @@ struct lock_manager_operations {
 	void (*lm_put_owner)(struct file_lock *);
 	void (*lm_notify)(struct file_lock *);	/* unblock callback */
 	int (*lm_grant)(struct file_lock *, int);
-	void (*lm_break)(struct file_lock *);
+	bool (*lm_break)(struct file_lock *);
 	int (*lm_change)(struct file_lock **, int, struct list_head *);
 	void (*lm_setup)(struct file_lock *, void **);
 };
-- 
1.9.3

