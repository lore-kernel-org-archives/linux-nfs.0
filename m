Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:45325 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab2F2S6W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jun 2012 14:58:22 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so3043977ggl.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jun 2012 11:58:21 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v3 10/17] vfs: fix symlinkat to retry on ESTALE errors
Date: Fri, 29 Jun 2012 14:57:53 -0400
Message-Id: <1340996280-27123-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
References: <1340996280-27123-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index dec5713..a2d691a 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3033,33 +3033,42 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
 		int, newdfd, const char __user *, newname)
 {
 	int error;
-	char *from;
+	char *from, *to;
 	struct dentry *dentry;
 	struct path path;
+	unsigned int try = 0;
 
 	from = getname(oldname);
 	if (IS_ERR(from))
 		return PTR_ERR(from);
 
-	dentry = user_path_create(newdfd, newname, &path, 0);
-	error = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		goto out_putname;
+	to = getname(newname);
+	if (IS_ERR(to)) {
+		putname(from);
+		return PTR_ERR(to);
+	}
 
-	error = mnt_want_write(path.mnt);
-	if (error)
-		goto out_dput;
-	error = security_path_symlink(&path, dentry, from);
-	if (error)
-		goto out_drop_write;
-	error = vfs_symlink(path.dentry->d_inode, dentry, from);
+	do {
+		dentry = kern_path_create(newdfd, to, &path, 0, try);
+		error = PTR_ERR(dentry);
+		if (IS_ERR(dentry))
+			break;
+
+		error = mnt_want_write(path.mnt);
+		if (error)
+			goto out_dput;
+		error = security_path_symlink(&path, dentry, from);
+		if (error)
+			goto out_drop_write;
+		error = vfs_symlink(path.dentry->d_inode, dentry, from);
 out_drop_write:
-	mnt_drop_write(path.mnt);
+		mnt_drop_write(path.mnt);
 out_dput:
-	dput(dentry);
-	mutex_unlock(&path.dentry->d_inode->i_mutex);
-	path_put(&path);
-out_putname:
+		dput(dentry);
+		mutex_unlock(&path.dentry->d_inode->i_mutex);
+		path_put(&path);
+	} while (retry_estale(error, try++));
+	putname(to);
 	putname(from);
 	return error;
 }
-- 
1.7.7.6

