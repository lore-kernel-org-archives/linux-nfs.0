Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:42122 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932872Ab2KEPWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 10:22:36 -0500
Received: by mail-gg0-f174.google.com with SMTP id k5so1001863ggd.19
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2012 07:22:36 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v9 08/34] vfs: fix linkat to retry on ESTALE errors
Date: Mon,  5 Nov 2012 10:21:47 -0500
Message-Id: <1352128933-28526-9-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
References: <1352128933-28526-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 46 ++++++++++++++++++++++++++--------------------
 1 file changed, 26 insertions(+), 20 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index af1b473..28d70cd 100644
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
+						false, try);
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

