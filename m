Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46506 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753258Ab3BCQbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 3 Feb 2013 11:31:37 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/12] namei: minor vfs_unlink cleanup
Date: Sun,  3 Feb 2013 11:31:27 -0500
Message-Id: <1359909092-24857-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1359909092-24857-1-git-send-email-bfields@redhat.com>
References: <1359909092-24857-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We'll be using dentry->d_inode in one more place.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/namei.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 6ca5b11..bd38624 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3397,6 +3397,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 
 int vfs_unlink(struct inode *dir, struct dentry *dentry)
 {
+	struct inode *target = dentry->d_inode;
 	int error = may_delete(dir, dentry, 0);
 
 	if (error)
@@ -3405,7 +3406,7 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
 	if (!dir->i_op->unlink)
 		return -EPERM;
 
-	mutex_lock(&dentry->d_inode->i_mutex);
+	mutex_lock(&target->i_mutex);
 	if (d_mountpoint(dentry))
 		error = -EBUSY;
 	else {
@@ -3416,11 +3417,11 @@ int vfs_unlink(struct inode *dir, struct dentry *dentry)
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

