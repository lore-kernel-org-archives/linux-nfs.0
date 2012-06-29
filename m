Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:41418 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932727Ab2F2S6X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:23 -0400
Received: by mail-yx0-f174.google.com with SMTP id l2so3038059yen.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:23 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 11/17] vfs: fix linkat to retry on ESTALE errors
Date: Fri, 29 Jun 2012 14:57:54 -0400
Message-Id: <1340996280-27123-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   67 ++++++++++++++++++++++++++++++++++++++---------------------
 1 files changed, 43 insertions(+), 24 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index a2d691a..e902770 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3138,6 +3138,8 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	struct path old_path, new_path;
 	int how = 0;
 	int error;
+	char *old, *new;
+	unsigned int try = 0;
 
 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
@@ -3155,34 +3157,51 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	if (flags & AT_SYMLINK_FOLLOW)
 		how |= LOOKUP_FOLLOW;
 
-	error = user_path_at(olddfd, oldname, how, &old_path);
-	if (error)
-		return error;
+	old = getname_flags(oldname, how, NULL);
+	if (IS_ERR(old))
+		return PTR_ERR(old);
 
-	new_dentry = user_path_create(newdfd, newname, &new_path, 0);
-	error = PTR_ERR(new_dentry);
-	if (IS_ERR(new_dentry))
-		goto out;
+	new = getname(newname);
+	if (IS_ERR(new)) {
+		putname(old);
+		return PTR_ERR(new);
+	}
 
-	error = -EXDEV;
-	if (old_path.mnt != new_path.mnt)
-		goto out_dput;
-	error = mnt_want_write(new_path.mnt);
-	if (error)
-		goto out_dput;
-	error = security_path_link(old_path.dentry, &new_path, new_dentry);
-	if (error)
-		goto out_drop_write;
-	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry);
+	do {
+		error = kern_path_at(olddfd, old, how, &old_path);
+		if (error)
+			break;
+
+		new_dentry = kern_path_create(newdfd, new, &new_path, 0, try);
+		error = PTR_ERR(new_dentry);
+		if (IS_ERR(new_dentry)) {
+			path_put(&old_path);
+			break;
+		}
+
+		error = -EXDEV;
+		if (old_path.mnt != new_path.mnt)
+			goto out_dput;
+		error = mnt_want_write(new_path.mnt);
+		if (error)
+			goto out_dput;
+		error = security_path_link(old_path.dentry, &new_path,
+					new_dentry);
+		if (error)
+			goto out_drop_write;
+		error = vfs_link(old_path.dentry, new_path.dentry->d_inode,
+				new_dentry);
 out_drop_write:
-	mnt_drop_write(new_path.mnt);
+		mnt_drop_write(new_path.mnt);
 out_dput:
-	dput(new_dentry);
-	mutex_unlock(&new_path.dentry->d_inode->i_mutex);
-	path_put(&new_path);
-out:
-	path_put(&old_path);
-
+		dput(new_dentry);
+		mutex_unlock(&new_path.dentry->d_inode->i_mutex);
+		path_put(&new_path);
+		path_put(&old_path);
+		how |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
+	putname(new);
+	putname(old);
 	return error;
 }
 
-- 
1.7.7.6

