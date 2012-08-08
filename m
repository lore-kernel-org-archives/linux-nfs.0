Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61865 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758468Ab2HHNWD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:22:03 -0400
Received: by yenl2 with SMTP id l2so730912yen.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:22:03 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 11/19] vfs: fix linkat to retry on ESTALE errors
Date: Wed,  8 Aug 2012 09:21:34 -0400
Message-Id: <1344432102-22312-12-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 60 ++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 20 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 9986117..d6e9754 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3565,6 +3565,8 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
 	struct path old_path, new_path;
 	int how = 0;
 	int error;
+	char *old, *new;
+	unsigned int try = 0;
 
 	if ((flags & ~(AT_SYMLINK_FOLLOW | AT_EMPTY_PATH)) != 0)
 		return -EINVAL;
@@ -3582,30 +3584,48 @@ SYSCALL_DEFINE5(linkat, int, olddfd, const char __user *, oldname,
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
-	error = may_linkat(&old_path);
-	if (unlikely(error))
-		goto out_dput;
-	error = security_path_link(old_path.dentry, &new_path, new_dentry);
-	if (error)
-		goto out_dput;
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
+	putname(new);
+	putname(old);
 	return error;
 }
 
-- 
1.7.11.2

