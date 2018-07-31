Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35870 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725886AbeGaWxV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 18:53:21 -0400
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org, Mark Fasheh <mfasheh@suse.de>
Subject: [PATCH 4/4] locks: map correct ino/dev pairs when exporting to userspace
Date: Tue, 31 Jul 2018 14:10:45 -0700
Message-Id: <20180731211045.5671-5-mfasheh@suse.de>
In-Reply-To: <20180731211045.5671-1-mfasheh@suse.de>
References: <20180731211045.5671-1-mfasheh@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

/proc/locks does not always print the correct inode number/device pair.
Update lock_get_status() to use vfs_map_unique_ino_dev() to get the real,
unique values for userspace.

Signed-off-by: Mark Fasheh <mfasheh@suse.de>
---
 fs/locks.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index db7b6917d9c5..3a012df87fd8 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2621,6 +2621,7 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 			    loff_t id, char *pfx)
 {
 	struct inode *inode = NULL;
+	struct dentry *dentry;
 	unsigned int fl_pid;
 	struct pid_namespace *proc_pidns = file_inode(f->file)->i_sb->s_fs_info;
 
@@ -2633,8 +2634,10 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 	if (fl_pid == 0)
 		return;
 
-	if (fl->fl_file != NULL)
+	if (fl->fl_file != NULL) {
 		inode = locks_inode(fl->fl_file);
+		dentry = file_dentry(fl->fl_file);
+	}
 
 	seq_printf(f, "%lld:%s ", id, pfx);
 	if (IS_POSIX(fl)) {
@@ -2681,10 +2684,13 @@ static void lock_get_status(struct seq_file *f, struct file_lock *fl,
 			       : (fl->fl_type == F_WRLCK) ? "WRITE" : "READ ");
 	}
 	if (inode) {
+		__u64 ino;
+		dev_t dev;
+
+		vfs_map_unique_ino_dev(dentry, &ino, &dev);
 		/* userspace relies on this representation of dev_t */
 		seq_printf(f, "%d %02x:%02x:%ld ", fl_pid,
-				MAJOR(inode->i_sb->s_dev),
-				MINOR(inode->i_sb->s_dev), inode->i_ino);
+				MAJOR(dev), MINOR(dev), inode->i_ino);
 	} else {
 		seq_printf(f, "%d <none>:0 ", fl_pid);
 	}
-- 
2.15.1

