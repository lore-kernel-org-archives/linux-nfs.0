Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f174.google.com ([209.85.160.174]:61482 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757928Ab2EVOMn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:43 -0400
Received: by mail-gh0-f174.google.com with SMTP id r11so777867ghr.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 10/15] vfs: fix symlinkat to retry on ESTALE errors
Date: Tue, 22 May 2012 10:12:14 -0400
Message-Id: <1337695939-2741-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   43 ++++++++++++++++++++++++++-----------------
 1 files changed, 26 insertions(+), 17 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 812b978..5c8ceb9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2966,33 +2966,42 @@ SYSCALL_DEFINE3(symlinkat, const char __user *, oldname,
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

