Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53199 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756208Ab1HSQH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 12:07:58 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-fsdevel@vger.kernel.org
Cc: Jeremy Allison <jra@samba.org>, samba-technical@lists.samba.org,
        linux-nfs@vger.kernel.org, Volker Lendecke <Volker.Lendecke@SerNet.DE>,
        Casey Bodley <cbodley@citi.umich.edu>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] locks: setlease cleanup
Date: Fri, 19 Aug 2011 12:07:51 -0400
Message-Id: <1313770071-353-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20110819160416.GC30856@fieldses.org>
References: <20110819160416.GC30856@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

There's an incorrect comment here.  Also clean up the logic: the
"rdlease" and "wrlease" locals are confusingly named, and don't really
add anything since we can make a decision as soon as we hit one of these
cases.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/locks.c |   33 +++++++++++++++++----------------
 1 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index c525aa4..9b8408e 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1368,7 +1368,7 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	struct file_lock *fl, **before, **my_before = NULL, *lease;
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
-	int error, rdlease_count = 0, wrlease_count = 0;
+	int error;
 
 	lease = *flp;
 
@@ -1404,27 +1404,28 @@ int generic_setlease(struct file *filp, long arg, struct file_lock **flp)
 	 * then the file is not open by anyone (including us)
 	 * except for this filp.
 	 */
+	error = -EAGAIN;
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
-		if (fl->fl_file == filp)
+		if (fl->fl_file == filp) {
 			my_before = before;
-		else if (fl->fl_flags & FL_UNLOCK_PENDING)
-			/*
-			 * Someone is in the process of opening this
-			 * file for writing so we may not take an
-			 * exclusive lease on it.
-			 */
-			wrlease_count++;
-		else
-			rdlease_count++;
+			continue;
+		}
+		/*
+		 * No exclusive leases if someone else has a lease on
+		 * this file:
+		 */
+		if (arg == F_WRLCK)
+			goto out;
+		/*
+		 * Modifying our existing lease is OK, but no getting a
+		 * new lease if someone else is opening for write:
+		 */
+		if (fl->fl_flags & FL_UNLOCK_PENDING)
+			goto out;
 	}
 
-	error = -EAGAIN;
-	if ((arg == F_RDLCK && (wrlease_count > 0)) ||
-	    (arg == F_WRLCK && ((rdlease_count + wrlease_count) > 0)))
-		goto out;
-
 	if (my_before != NULL) {
 		error = lease->fl_lmops->lm_change(my_before, arg);
 		if (!error)
-- 
1.7.4.1

