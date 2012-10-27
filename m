Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:53867 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072Ab2J0MeK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:34:10 -0400
Received: by mail-gg0-f174.google.com with SMTP id k5so690907ggd.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:34:10 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v8 10/32] vfs: make rmdir retry on ESTALE errors
Date: Sat, 27 Oct 2012 08:33:17 -0400
Message-Id: <1351341219-17837-11-git-send-email-jlayton@redhat.com>
In-Reply-To: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c | 81 ++++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 44 insertions(+), 37 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 47b6016..7c9bb50 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -3344,49 +3344,56 @@ static long do_rmdir(int dfd, const char __user *pathname)
 	struct filename *name;
 	struct dentry *dentry;
 	struct nameidata nd;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
-	name = user_path_parent(dfd, pathname, &nd, 0);
-	if (IS_ERR(name))
-		return PTR_ERR(name);
-
-	switch(nd.last_type) {
-	case LAST_DOTDOT:
-		error = -ENOTEMPTY;
-		goto exit1;
-	case LAST_DOT:
-		error = -EINVAL;
-		goto exit1;
-	case LAST_ROOT:
-		error = -EBUSY;
-		goto exit1;
-	}
+	do {
+		name = user_path_parent(dfd, pathname, &nd, try);
+		if (IS_ERR(name))
+			return PTR_ERR(name);
+
+		switch (nd.last_type) {
+		case LAST_DOTDOT:
+			error = -ENOTEMPTY;
+			goto exit1;
+		case LAST_DOT:
+			error = -EINVAL;
+			goto exit1;
+		case LAST_ROOT:
+			error = -EBUSY;
+			goto exit1;
+		}
 
-	nd.flags &= ~LOOKUP_PARENT;
-	error = mnt_want_write(nd.path.mnt);
-	if (error)
-		goto exit1;
+		nd.flags &= ~LOOKUP_PARENT;
+		error = mnt_want_write(nd.path.mnt);
+		if (error)
+			goto exit1;
 
-	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
-	dentry = lookup_hash(&nd);
-	error = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		goto exit2;
-	if (!dentry->d_inode) {
-		error = -ENOENT;
-		goto exit3;
-	}
-	error = security_path_rmdir(&nd.path, dentry);
-	if (error)
-		goto exit3;
-	error = vfs_rmdir(nd.path.dentry->d_inode, dentry);
+		mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex,
+					I_MUTEX_PARENT);
+		dentry = lookup_hash(&nd);
+		if (IS_ERR(dentry)) {
+			error = PTR_ERR(dentry);
+			goto exit2;
+		}
+		if (!dentry->d_inode) {
+			error = -ENOENT;
+			goto exit3;
+		}
+		error = security_path_rmdir(&nd.path, dentry);
+		if (error)
+			goto exit3;
+		error = vfs_rmdir(nd.path.dentry->d_inode, dentry);
 exit3:
-	dput(dentry);
+		dput(dentry);
 exit2:
-	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
-	mnt_drop_write(nd.path.mnt);
+		mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
+		mnt_drop_write(nd.path.mnt);
 exit1:
-	path_put(&nd.path);
-	putname(name);
+		path_put(&nd.path);
+		lookup_flags |= LOOKUP_REVAL;
+		putname(name);
+	} while (retry_estale(error, try++));
 	return error;
 }
 
-- 
1.7.11.7

