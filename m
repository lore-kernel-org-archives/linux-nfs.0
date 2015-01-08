Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:55531 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757262AbbAHSep (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2015 13:34:45 -0500
Received: by mail-qc0-f182.google.com with SMTP id r5so3706872qcx.13
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jan 2015 10:34:45 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        hch@infradead.org
Subject: [PATCH v2 02/10] locks: have locks_release_file use flock_lock_file to release generic flock locks
Date: Thu,  8 Jan 2015 10:34:17 -0800
Message-Id: <1420742065-28423-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of open-coding it and removing flock locks directly. This
simplifies some coming interim changes in the following patches when
we have different file_lock types protected by different spinlocks.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index fba8bc7af6d3..cec00425bfb6 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2360,6 +2360,30 @@ void locks_remove_posix(struct file *filp, fl_owner_t owner)
 
 EXPORT_SYMBOL(locks_remove_posix);
 
+static void
+locks_remove_flock(struct file *filp)
+{
+	struct file_lock fl = {
+		.fl_owner = filp,
+		.fl_pid = current->tgid,
+		.fl_file = filp,
+		.fl_flags = FL_FLOCK,
+		.fl_type = F_UNLCK,
+		.fl_end = OFFSET_MAX,
+	};
+
+	if (!file_inode(filp)->i_flock)
+		return;
+
+	if (filp->f_op->flock)
+		filp->f_op->flock(filp, F_SETLKW, &fl);
+	else
+		flock_lock_file(filp, &fl);
+
+	if (fl.fl_ops && fl.fl_ops->fl_release_private)
+		fl.fl_ops->fl_release_private(&fl);
+}
+
 /*
  * This function is called on the last close of an open file.
  */
@@ -2370,24 +2394,14 @@ void locks_remove_file(struct file *filp)
 	struct file_lock **before;
 	LIST_HEAD(dispose);
 
-	if (!inode->i_flock)
-		return;
-
+	/* remove any OFD locks */
 	locks_remove_posix(filp, filp);
 
-	if (filp->f_op->flock) {
-		struct file_lock fl = {
-			.fl_owner = filp,
-			.fl_pid = current->tgid,
-			.fl_file = filp,
-			.fl_flags = FL_FLOCK,
-			.fl_type = F_UNLCK,
-			.fl_end = OFFSET_MAX,
-		};
-		filp->f_op->flock(filp, F_SETLKW, &fl);
-		if (fl.fl_ops && fl.fl_ops->fl_release_private)
-			fl.fl_ops->fl_release_private(&fl);
-	}
+	/* remove flock locks */
+	locks_remove_flock(filp);
+
+	if (!inode->i_flock)
+		return;
 
 	spin_lock(&inode->i_lock);
 	before = &inode->i_flock;
@@ -2407,8 +2421,7 @@ void locks_remove_file(struct file *filp)
 			 * some info about it and then just remove it from
 			 * the list.
 			 */
-			WARN(!IS_FLOCK(fl),
-				"leftover lock: dev=%u:%u ino=%lu type=%hhd flags=0x%x start=%lld end=%lld\n",
+			WARN(1, "leftover lock: dev=%u:%u ino=%lu type=%hhd flags=0x%x start=%lld end=%lld\n",
 				MAJOR(inode->i_sb->s_dev),
 				MINOR(inode->i_sb->s_dev), inode->i_ino,
 				fl->fl_type, fl->fl_flags,
-- 
2.1.0

