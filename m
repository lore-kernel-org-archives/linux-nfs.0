Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756009Ab1G2C3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 22:29:44 -0400
Date: Thu, 28 Jul 2011 22:29:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: [PATCH 2/3] locks: move F_INPROGRESS from fl_type to fl_flags field
Message-ID: <20110729022941.GB23194@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110721001542.GA15644@samba2>
 <20110721163520.GC1114@fieldses.org>
 <20110729022758.GC20317@fieldses.org>
 <20110729022911.GA23194@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729022911.GA23194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

F_INPROGRESS isn't exposed to userspace.  To me it makes more sense in
fl_flags....

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 arch/alpha/include/asm/fcntl.h |    2 --
 fs/locks.c                     |   14 ++++++++------
 include/asm-generic/fcntl.h    |    5 -----
 include/linux/fs.h             |    3 ++-
 4 files changed, 10 insertions(+), 14 deletions(-)

diff --git a/arch/alpha/include/asm/fcntl.h b/arch/alpha/include/asm/fcntl.h
index 1b71ca7..6d9e805 100644
--- a/arch/alpha/include/asm/fcntl.h
+++ b/arch/alpha/include/asm/fcntl.h
@@ -51,8 +51,6 @@
 #define F_EXLCK		16	/* or 3 */
 #define F_SHLCK		32	/* or 4 */
 
-#define F_INPROGRESS	64
-
 #include <asm-generic/fcntl.h>
 
 #endif
diff --git a/fs/locks.c b/fs/locks.c
index c528522..c421541 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -135,7 +135,7 @@
 
 static bool lease_breaking(struct file_lock *fl)
 {
-	return fl->fl_type & F_INPROGRESS;
+	return fl->fl_flags & FL_INPROGRESS;
 }
 
 int leases_enable = 1;
@@ -1132,6 +1132,7 @@ int lease_modify(struct file_lock **before, int arg)
 
 	if (error)
 		return error;
+	fl->fl_flags &= ~FL_INPROGRESS;
 	locks_wake_up_blocks(fl);
 	if (arg == F_UNLCK)
 		locks_delete_lock(before);
@@ -1152,7 +1153,7 @@ static void time_out_leases(struct inode *inode)
 			before = &fl->fl_next;
 			continue;
 		}
-		lease_modify(before, fl->fl_type & ~F_INPROGRESS);
+		lease_modify(before, fl->fl_type);
 		if (fl == *before)	/* lease_modify may have freed fl */
 			before = &fl->fl_next;
 	}
@@ -1193,13 +1194,13 @@ int __break_lease(struct inode *inode, unsigned int mode)
 
 	if (want_write) {
 		/* If we want write access, we have to revoke any lease. */
-		future = F_UNLCK | F_INPROGRESS;
+		future = F_UNLCK;
 	} else if (lease_breaking(flock)) {
 		/* If the lease is already being broken, we just leave it */
 		future = flock->fl_type;
 	} else if (flock->fl_type & F_WRLCK) {
 		/* Downgrade the exclusive lease to a read-only lease. */
-		future = F_RDLCK | F_INPROGRESS;
+		future = F_RDLCK;
 	} else {
 		/* the existing lease was read-only, so we can read too. */
 		goto out;
@@ -1221,6 +1222,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	for (fl = flock; fl && IS_LEASE(fl); fl = fl->fl_next) {
 		if (fl->fl_type != future) {
 			fl->fl_type = future;
+			fl->fl_flags |= FL_INPROGRESS;
 			fl->fl_break_time = break_time;
 			/* lease must have lmops break callback */
 			fl->fl_lmops->lm_break(fl);
@@ -1319,7 +1321,7 @@ int fcntl_getlease(struct file *filp)
 	for (fl = filp->f_path.dentry->d_inode->i_flock; fl && IS_LEASE(fl);
 			fl = fl->fl_next) {
 		if (fl->fl_file == filp) {
-			type = fl->fl_type & ~F_INPROGRESS;
+			type = fl->fl_type;
 			break;
 		}
 	}
@@ -1384,7 +1386,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 			before = &fl->fl_next) {
 		if (fl->fl_file == filp)
 			my_before = before;
-		else if (fl->fl_type == (F_INPROGRESS | F_UNLCK))
+		else if ((fl->fl_type == F_UNLCK) && lease_breaking(fl))
 			/*
 			 * Someone is in the process of opening this
 			 * file for writing so we may not take an
diff --git a/include/asm-generic/fcntl.h b/include/asm-generic/fcntl.h
index 84793c7..9e5b035 100644
--- a/include/asm-generic/fcntl.h
+++ b/include/asm-generic/fcntl.h
@@ -145,11 +145,6 @@ struct f_owner_ex {
 #define F_SHLCK		8	/* or 4 */
 #endif
 
-/* for leases */
-#ifndef F_INPROGRESS
-#define F_INPROGRESS	16
-#endif
-
 /* operations for bsd flock(), also used by the kernel implementation */
 #define LOCK_SH		1	/* shared lock */
 #define LOCK_EX		2	/* exclusive lock */
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f23bcb7..f0b692c 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1050,6 +1050,7 @@ static inline int file_check_writeable(struct file *filp)
 #define FL_LEASE	32	/* lease held on this file */
 #define FL_CLOSE	64	/* unlock on close */
 #define FL_SLEEP	128	/* A blocking lock */
+#define FL_INPROGRESS	256	/* Lease is being broken */
 
 /*
  * Special return value from posix_lock_file() and vfs_lock_file() for
@@ -1096,7 +1097,7 @@ struct file_lock {
 	struct list_head fl_link;	/* doubly linked list of all locks */
 	struct list_head fl_block;	/* circular list of blocked processes */
 	fl_owner_t fl_owner;
-	unsigned char fl_flags;
+	unsigned int fl_flags;
 	unsigned char fl_type;
 	unsigned int fl_pid;
 	struct pid *fl_nspid;
-- 
1.7.4.1

