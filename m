Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58278 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab1G2C3N (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2011 22:29:13 -0400
Date: Thu, 28 Jul 2011 22:29:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeremy Allison <jra@samba.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: [PATCH 1/3] locks: minor lease cleanup
Message-ID: <20110729022911.GA23194@fieldses.org>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
 <20110721001542.GA15644@samba2>
 <20110721163520.GC1114@fieldses.org>
 <20110729022758.GC20317@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729022758.GC20317@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@redhat.com>

Use a helper function, to simplify upcoming changes.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 703f545..c528522 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -133,6 +133,11 @@
 #define IS_FLOCK(fl)	(fl->fl_flags & FL_FLOCK)
 #define IS_LEASE(fl)	(fl->fl_flags & FL_LEASE)
 
+static bool lease_breaking(struct file_lock *fl)
+{
+	return fl->fl_type & F_INPROGRESS;
+}
+
 int leases_enable = 1;
 int lease_break_time = 45;
 
@@ -1141,7 +1146,7 @@ static void time_out_leases(struct inode *inode)
 	struct file_lock *fl;
 
 	before = &inode->i_flock;
-	while ((fl = *before) && IS_LEASE(fl) && (fl->fl_type & F_INPROGRESS)) {
+	while ((fl = *before) && IS_LEASE(fl) && lease_breaking(fl)) {
 		if ((fl->fl_break_time == 0)
 				|| time_before(jiffies, fl->fl_break_time)) {
 			before = &fl->fl_next;
@@ -1189,7 +1194,7 @@ int __break_lease(struct inode *inode, unsigned int mode)
 	if (want_write) {
 		/* If we want write access, we have to revoke any lease. */
 		future = F_UNLCK | F_INPROGRESS;
-	} else if (flock->fl_type & F_INPROGRESS) {
+	} else if (lease_breaking(flock)) {
 		/* If the lease is already being broken, we just leave it */
 		future = flock->fl_type;
 	} else if (flock->fl_type & F_WRLCK) {
@@ -1246,7 +1251,7 @@ restart:
 		/* Wait for the next lease that has not been broken yet */
 		for (flock = inode->i_flock; flock && IS_LEASE(flock);
 				flock = flock->fl_next) {
-			if (flock->fl_type & F_INPROGRESS)
+			if (lease_breaking(flock))
 				goto restart;
 		}
 		error = 0;
@@ -2126,7 +2131,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 		}
 	} else if (IS_LEASE(fl)) {
 		seq_printf(f, "LEASE  ");
-		if (fl->fl_type & F_INPROGRESS)
+		if (lease_breaking(fl))
 			seq_printf(f, "BREAKING  ");
 		else if (fl->fl_file)
 			seq_printf(f, "ACTIVE    ");
@@ -2142,7 +2147,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 			       : (fl->fl_type & LOCK_WRITE) ? "WRITE" : "NONE ");
 	} else {
 		seq_printf(f, "%s ",
-			       (fl->fl_type & F_INPROGRESS)
+			       (lease_breaking(fl))
 			       ? (fl->fl_type & F_UNLCK) ? "UNLCK" : "READ "
 			       : (fl->fl_type & F_WRLCK) ? "WRITE" : "READ ");
 	}
-- 
1.7.4.1

