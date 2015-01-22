Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.231]:16302 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753061AbbAVO2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Jan 2015 09:28:01 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: linux-fsdevel@vger.kernel.org
Cc: Christoph Hellwig <hch@infradead.org>,
        Sasha Levin <sasha.levin@oracle.com>,
        David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: [PATCH v3 02/13] locks: have locks_release_file use flock_lock_file to release generic flock locks
Date: Thu, 22 Jan 2015 09:27:46 -0500
Message-Id: <1421936877-27529-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
References: <1421936877-27529-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@primarydata.com>

...instead of open-coding it and removing flock locks directly. This
helps consolidate the flock lock removal logic into a single spot.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/locks.c | 49 +++++++++++++++++++++++++++++++------------------
 1 file changed, 31 insertions(+), 18 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index bfe5f17401de..ae1e7cf721d6 100644
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

