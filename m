Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49188 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab1FIXQH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jun 2011 19:16:07 -0400
Date: Thu, 9 Jun 2011 19:16:06 -0400
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110609231606.GB22215@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The lease code behavior during the lease-breaking process is strange.
Fixing it completely would be complicated by the fact that the current
code allows a lease break to downgrade the lease instead of necessarily
removing it.

But I can't see what the point of that feature is.  And googling around
and looking at the Samba code, I can't see any evidence that anyone uses
it.  Think we could just do away with removing the ability to downgrade
to satisfy a lease break?

--b.

commit 70fc3ee9d3e9d61203d4310db4a8128886747272
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Jun 9 09:31:30 2011 -0400

    locks: breaking read lease should not block read open
    
    Currently read opens block while a lease break is in progress, even if
    the lease being broken was only a read lease.
    
    This is an annoyance for v4, since clients may need to do read opens
    before they can return a delegation.
    
    This happens because we use fl_type on a breaking lease to track the
    type it will have when the break is finished (F_RDLCK or F_UNLCK) as
    opposed to the type it had before the break started, so we no longer
    even know at that point whether it was a write lease or a read lease.
    
    The only reason we do that is to allow a write lease broken by a read
    open to be downgraded to a read lease instead of removed completely.
    
    However, that doesn't seem like a useful feature--as far as I can tell,
    nobody uses it or likely ever will.
    
    So, just keep the original lease type in fl_type.
    
    Reported-by: Casey Bodley <cbodley@citi.umich.edu>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/locks.c b/fs/locks.c
index 0a4f50d..171391f 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1158,9 +1158,9 @@ static void time_out_leases(struct inode *inode)
 			before = &fl->fl_next;
 			continue;
 		}
-		lease_modify(before, fl->fl_type & ~F_INPROGRESS);
-		if (fl == *before)	/* lease_modify may have freed fl */
-			before = &fl->fl_next;
+		lease_modify(before, F_UNLCK);
+		/* lease_modify has freed fl */
+		before = &fl->fl_next;
 	}
 }
 
@@ -1176,7 +1176,7 @@ static void time_out_leases(struct inode *inode)
  */
 int __break_lease(struct inode *inode, unsigned int mode)
 {
-	int error = 0, future;
+	int error = 0;
 	struct file_lock *new_fl, *flock;
 	struct file_lock *fl;
 	unsigned long break_time;
@@ -1197,19 +1197,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 		if (fl->fl_owner == current->files)
 			i_have_this_lease = 1;
 
-	if (want_write) {
-		/* If we want write access, we have to revoke any lease. */
-		future = F_UNLCK | F_INPROGRESS;
-	} else if (flock->fl_type & F_INPROGRESS) {
-		/* If the lease is already being broken, we just leave it */
-		future = flock->fl_type;
-	} else if (flock->fl_type & F_WRLCK) {
-		/* Downgrade the exclusive lease to a read-only lease. */
-		future = F_RDLCK | F_INPROGRESS;
-	} else {
-		/* the existing lease was read-only, so we can read too. */
-		goto out;
-	}
+	if (!want_write && !(flock->fl_type & F_WRLCK))
+		goto out; /* no conflict */
 
 	if (IS_ERR(new_fl) && !i_have_this_lease
 			&& ((mode & O_NONBLOCK) == 0)) {
@@ -1225,8 +1214,8 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	}
 
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
-		if (fl->fl_type != future) {
-			fl->fl_type = future;
+		if (!(fl->fl_type & F_INPROGRESS)) {
+			fl->fl_type |= F_INPROGRESS;
 			fl->fl_break_time = break_time;
 			/* lease must have lmops break callback */
 			fl->fl_lmops->fl_break(fl);
@@ -1254,10 +1243,10 @@ restart:
 	if (error >= 0) {
 		if (error == 0)
 			time_out_leases(inode);
-		/* Wait for the next lease that has not been broken yet */
+		/* Wait for the next lease that conflicts */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (flock->fl_type & F_INPROGRESS)
+			if (want_write || flock->fl_type & F_WRLCK)
 				goto restart;
 		}
 		error = 0;
@@ -1390,11 +1379,10 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 			before = &fl->fl_next) {
 		if (fl->fl_file == filp)
 			my_before = before;
-		else if (fl->fl_type == (F_INPROGRESS | F_UNLCK))
+		else if (fl->fl_type & F_INPROGRESS)
 			/*
-			 * Someone is in the process of opening this
-			 * file for writing so we may not take an
-			 * exclusive lease on it.
+			 * Don't allow new leases while any lease is
+			 * being broken:
 			 */
 			wrlease_count++;
 		else
