Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754693Ab1G2Caj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 22:30:39 -0400
Date: Thu, 28 Jul 2011 22:30:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: [PATCH 3/3] locks: fix tracking of inprogress lease breaks
Message-ID: <20110729023036.GC23194@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110721001542.GA15644@samba2>
 <20110721163520.GC1114@fieldses.org>
 <20110729022758.GC20317@fieldses.org>
 <20110729022911.GA23194@fieldses.org>
 <20110729022941.GB23194@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729022941.GB23194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

We currently use a bit in fl_flags to record whether a lease is being
broken, and set fl_type to the type (RDLCK or UNLCK) that it will
eventually have.  This means that once the lease break starts, we forget
what the lease's type *used* to be.  Breaking a read lease will then
result in blocking read opens, even though there's no conflict--because
the lease type is now F_UNLCK and we can no longer tell whether it was
previously a read or write lease.

So, instead keep fl_type as the original type (the type which we
enforce), and keep track of whether we're unlocking or merely
downgrading by replacing the single FL_INPROGRESS flag by
FL_UNLOCK_PENDING and FL_DOWNGRADE_PENDING flags.

To get this right we also need to track separate downgrade and break
times, to handle the case where a write-leased file gets conflicting
opens first for read, then later for write.

(I first considered just eliminating the downgrade behavior
completely--nfsv4 doesn't need it, and nobody as far as I can tell
actually uses it currently--but Jeremy Allison tells me that Windows
oplocks do behave this way, so Samba will probably use this some day.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c         |   70 +++++++++++++++++++++++++++++++++++++--------------
 include/linux/fs.h |    7 +++-
 2 files changed, 56 insertions(+), 21 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c421541..d7089a8 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -135,7 +135,16 @@
 
 static bool lease_breaking(struct file_lock *fl)
 {
-	return fl->fl_flags & FL_INPROGRESS;
+	return fl->fl_flags & (FL_UNLOCK_PENDING | FL_DOWNGRADE_PENDING);
+}
+
+static int target_leasetype(struct file_lock *fl)
+{
+	if (fl->fl_flags & FL_UNLOCK_PENDING)
+		return F_UNLCK;
+	if (fl->fl_flags & FL_DOWNGRADE_PENDING)
+		return F_RDLCK;
+	return fl->fl_type;
 }
 
 int leases_enable = 1;
@@ -1124,6 +1133,17 @@ int locks_mandatory_area(int read_write, struct inode *inode,
 
 EXPORT_SYMBOL(locks_mandatory_area);
 
+int lease_clear_pending(struct file_lock *fl, int arg)
+{
+	switch (arg) {
+	case F_UNLCK:
+		fl->fl_flags &= ~FL_UNLOCK_PENDING;
+		/* fall through: */
+	case F_RDLCK:
+		fl->fl_flags &= ~FL_DOWNGRADE_PENDING;
+	}
+}
+
 /* We already had a lease on this file; just change its type */
 int lease_modify(struct file_lock **before, int arg)
 {
@@ -1132,7 +1152,7 @@ int lease_modify(struct file_lock **before, int arg)
 
 	if (error)
 		return error;
-	fl->fl_flags &= ~FL_INPROGRESS;
+	lease_clear_pending(fl, arg);
 	locks_wake_up_blocks(fl);
 	if (arg == F_UNLCK)
 		locks_delete_lock(before);
@@ -1141,6 +1161,14 @@ int lease_modify(struct file_lock **before, int arg)
 
 EXPORT_SYMBOL(lease_modify);
 
+static bool past_time(unsigned long then)
+{
+	if (!then)
+		/* 0 is a special value meaning "this never expires": */
+		return false;
+	return time_after(jiffies, then);
+}
+
 static void time_out_leases(struct inode *inode)
 {
 	struct file_lock **before;
@@ -1148,12 +1176,10 @@ static void time_out_leases(struct inode *inode)
 
 	before = &inode->i_flock;
 	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
-		if ((fl->fl_break_time == 0)
-				|| time_before(jiffies, fl->fl_break_time)) {
-			before = &fl->fl_next;
-			continue;
-		}
-		lease_modify(before, fl->fl_type);
+		if (past_time(fl->fl_downgrade_time))
+			lease_modify(before, F_RDLCK);
+		if (past_time(fl->fl_break_time))
+			lease_modify(before, F_UNLCK);
 		if (fl == *before)	/* lease_modify may have freed fl */
 			before = &fl->fl_next;
 	}
@@ -1194,13 +1220,13 @@ int __break_lease(struct inode *inode, unsigned int mode)
 
 	if (want_write) {
 		/* If we want write access, we have to revoke any lease. */
-		future = F_UNLCK;
+		future = FL_UNLOCK_PENDING;
 	} else if (lease_breaking(flock)) {
 		/* If the lease is already being broken, we just leave it */
-		future = flock->fl_type;
+		future = 0;
 	} else if (flock->fl_type & F_WRLCK) {
 		/* Downgrade the exclusive lease to a read-only lease. */
-		future = F_RDLCK;
+		future = FL_DOWNGRADE_PENDING;
 	} else {
 		/* the existing lease was read-only, so we can read too. */
 		goto out;
@@ -1220,10 +1246,12 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	}
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
-		if (fl->fl_type != future) {
-			fl->fl_type = future;
-			fl->fl_flags |= FL_INPROGRESS;
-			fl->fl_break_time = break_time;
+		if (!(fl->fl_flags & future)) {
+			fl->fl_flags |= future;
+			if (future == FL_UNLOCK_PENDING)
+				fl->fl_break_time = break_time;
+			else /* FL_DOWNGRADE_PENDING */
+				fl->fl_downgrade_time = break_time;
 			/* lease must have lmops break callback */
 			fl->fl_lmops->lm_break(fl);
 		}
@@ -1250,10 +1278,14 @@ restart:
 	if (error >= 0) {
 		if (error == 0)
 			time_out_leases(inode);
-		/* Wait for the next lease that has not been broken yet */
+		/*
+		 * Wait for the next conflicting lease that has not been
+		 * broken yet
+		 */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (lease_breaking(flock))
+			if ((want_write && flock->fl_type == F_RDLCK)
+			    || flock->fl_type == F_WRLCK)
 				goto restart;
 		}
 		error = 0;
@@ -1321,7 +1353,7 @@ int fcntl_getlease(struct file *filp)
 	for (fl = filp->f_path.dentry->d_inode->i_flock; fl && IS_LEASE(fl);
 			fl = fl->fl_next) {
 		if (fl->fl_file == filp) {
-			type = fl->fl_type;
+			type = target_leasetype(fl);
 			break;
 		}
 	}
@@ -1386,7 +1418,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 			before = &fl->fl_next) {
 		if (fl->fl_file == filp)
 			my_before = before;
-		else if ((fl->fl_type == F_UNLCK) && lease_breaking(fl))
+		else if (fl->fl_flags & FL_UNLOCK_PENDING)
 			/*
 			 * Someone is in the process of opening this
 			 * file for writing so we may not take an
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f0b692c..225676c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1050,7 +1050,8 @@ static inline int file_check_writeable(struct file *filp)
 #define FL_LEASE	32	/* lease held on this file */
 #define FL_CLOSE	64	/* unlock on close */
 #define FL_SLEEP	128	/* A blocking lock */
-#define FL_INPROGRESS	256	/* Lease is being broken */
+#define FL_UNLOCK_PENDING	256 /* Lease is being broken */
+#define FL_DOWNGRADE_PENDING	512 /* Lease is being downgraded */
 
 /*
  * Special return value from posix_lock_file() and vfs_lock_file() for
@@ -1107,7 +1108,9 @@ struct file_lock {
 	loff_t fl_end;
 
 	struct fasync_struct *	fl_fasync; /* for lease break notifications */
-	unsigned long fl_break_time;	/* for nonblocking lease breaks */
+	/* for lease breaks: */
+	unsigned long fl_break_time;
+	unsigned long fl_downgrade_time;
 
 	const struct file_lock_operations *fl_ops;	/* Callbacks for filesystems */
 	const struct lock_manager_operations *fl_lmops;	/* Callbacks for lockmanagers */
-- 
1.7.4.1

