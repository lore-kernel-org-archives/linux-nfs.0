Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39104 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680Ab3ISUuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Sep 2013 16:50:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com, Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/13] namei: minor vfs_unlink cleanup
Date: Thu, 19 Sep 2013 16:50:31 -0400
Message-Id: <1379623837-30798-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1379623837-30798-1-git-send-email-bfields@redhat.com>
References: <1379623837-30798-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We'll be using dentry->d_inode in one more place.

Acked-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7bafc66..5450e9b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3638,6 +3638,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 
 int vfs_unlink(struct inode *dir, struct dentry *dentry)
 {
+	struct inode *target = dentry->d_inode;
 	int error = may_delete(dir, dentry, 0);
 
 	if (error)
@@ -3646,7 +3647,7 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
 	if (!dir->i_op->unlink)
 		return -EPERM;
 
-	mutex_lock(&dentry->d_inode->i_mutex);
+	mutex_lock(&target->i_mutex);
 	if (d_mountpoint(dentry))
 		error = -EBUSY;
 	else {
@@ -3657,11 +3658,11 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
 				dont_mount(dentry);
 		}
 	}
-	mutex_unlock(&dentry->d_inode->i_mutex);
+	mutex_unlock(&target->i_mutex);
 
 	/* We don't d_delete() NFS sillyrenamed files--they still exist. */
 	if (!error && !(dentry->d_flags & DCACHE_NFSFS_RENAMED)) {
-		fsnotify_link_count(dentry->d_inode);
+		fsnotify_link_count(target);
 		d_delete(dentry);
 	}
 
-- 
1.7.9.5

