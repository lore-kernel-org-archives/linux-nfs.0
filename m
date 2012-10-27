Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:65280 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754889Ab2J0MeD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:03 -0400
Received: by mail-yh0-f46.google.com with SMTP id m54so690985yhm.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 08/32] vfs: fix linkat to retry on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:15 -0400
Message-Id: <1351341219-17837-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 7def44b..d542a19 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3613,6 +3613,7 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	struct path old_path, new_path;
 	int how = 0;
 	int error;
+	unsigned int try = 0;
 
 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
@@ -3630,30 +3631,35 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	if (flags & AT_SYMLINK_FOLLOW)
 		how |= LOOKUP_FOLLOW;
 
-	error = user_path_at(olddfd, oldname, how, &old_path);
-	if (error)
-		return error;
+	do {
+		error = user_path_at(olddfd, oldname, how, &old_path);
+		if (error)
+			break;
 
-	new_dentry = user_path_create(newdfd, newname, &new_path, false, false);
-	error = PTR_ERR(new_dentry);
-	if (IS_ERR(new_dentry))
-		goto out;
+		new_dentry = user_path_create(newdfd, newname, &new_path,
+						false, false);
+		error = PTR_ERR(new_dentry);
+		if (IS_ERR(new_dentry))
+			goto out;
 
-	error = -EXDEV;
-	if (old_path.mnt != new_path.mnt)
-		goto out_dput;
-	error = may_linkat(&old_path);
-	if (unlikely(error))
-		goto out_dput;
-	error = security_path_link(old_path.dentry, &new_path, new_dentry);
-	if (error)
-		goto out_dput;
-	error = vfs_link(old_path.dentry, new_path.dentry->d_inode, new_dentry);
+		error = -EXDEV;
+		if (old_path.mnt != new_path.mnt)
+			goto out_dput;
+		error = may_linkat(&old_path);
+		if (unlikely(error))
+			goto out_dput;
+		error = security_path_link(old_path.dentry, &new_path,
+						new_dentry);
+		if (error)
+			goto out_dput;
+		error = vfs_link(old_path.dentry, new_path.dentry->d_inode,
+						new_dentry);
 out_dput:
-	done_path_create(&new_path, new_dentry);
+		done_path_create(&new_path, new_dentry);
 out:
-	path_put(&old_path);
-
+		path_put(&old_path);
+		how |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

