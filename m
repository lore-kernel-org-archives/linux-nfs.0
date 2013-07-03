Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39219 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932690Ab3GCUMp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jul 2013 16:12:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 09/12] locks: helper functions for delegation breaking
Date: Wed,  3 Jul 2013 16:12:33 -0400
Message-Id: <1372882356-14168-10-git-send-email-bfields@redhat.com>
In-Reply-To: <1372882356-14168-1-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We'll need the same logic for rename and link.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c         |   13 +++----------
 include/linux/fs.h |   33 +++++++++++++++++++++++++++++++--
 2 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index cba3db1..a9d4031 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3401,14 +3401,9 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry, struct inode **delegate
 	else {
 		error = security_inode_unlink(dir, dentry);
 		if (!error) {
-			error = break_deleg(target, O_WRONLY|O_NONBLOCK);
-			if (error) {
-				if (error == -EWOULDBLOCK && delegated_inode) {
-					*delegated_inode = target;
-					ihold(target);
-				}
+			error = try_break_deleg(target, delegated_inode);
+			if (error)
 				goto out;
-			}
 			error = dir->i_op->unlink(dir, dentry);
 			if (!error)
 				dont_mount(dentry);
@@ -3478,9 +3473,7 @@ exit2:
 		iput(inode);	/* truncate the inode here */
 	inode = NULL;
 	if (delegated_inode) {
-		error = break_deleg(delegated_inode, O_WRONLY);
-		iput(delegated_inode);
-		delegated_inode = NULL;
+		error = break_deleg_wait(&delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f951588..c37e463 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1894,6 +1894,9 @@ extern bool our_mnt(struct vfsmount *mnt);
 
 extern int current_umask(void);
 
+extern void ihold(struct inode * inode);
+extern void iput(struct inode *);
+
 /* /sys/fs */
 extern struct kobject *fs_kobj;
 
@@ -1962,6 +1965,28 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 	return 0;
 }
 
+static inline int try_break_deleg(struct inode *inode, struct inode **delegated_inode)
+{
+	int ret;
+
+	ret = break_deleg(inode, O_WRONLY|O_NONBLOCK);
+	if (ret == -EWOULDBLOCK && delegated_inode) {
+		*delegated_inode = inode;
+		ihold(inode);
+	}
+	return ret;
+}
+
+static inline int break_deleg_wait(struct inode **delegated_inode)
+{
+	int ret;
+
+	ret = break_deleg(*delegated_inode, O_WRONLY);
+	iput(*delegated_inode);
+	*delegated_inode = NULL;
+	return ret;
+}
+
 #else /* !CONFIG_FILE_LOCKING */
 static inline int locks_mandatory_locked(struct inode *inode)
 {
@@ -2005,6 +2030,12 @@ static inline int break_deleg(struct inode *inode, unsigned int mode)
 {
 	return 0;
 }
+
+static inline int try_break_deleg(struct inode *inode, struct delegated_inode **inode)
+{
+	return 0;
+}
+
 #endif /* CONFIG_FILE_LOCKING */
 
 /* fs/open.c */
@@ -2335,8 +2366,6 @@ extern loff_t vfs_llseek(struct file *file, loff_t offset, int whence);
 extern int inode_init_always(struct super_block *, struct inode *);
 extern void inode_init_once(struct inode *);
 extern void address_space_init_once(struct address_space *mapping);
-extern void ihold(struct inode * inode);
-extern void iput(struct inode *);
 extern struct inode * igrab(struct inode *);
 extern ino_t iunique(struct super_block *, ino_t);
 extern int inode_needs_sync(struct inode *inode);
-- 
1.7.9.5

