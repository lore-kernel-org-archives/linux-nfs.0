Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52315 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758081Ab2EVOMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:46 -0400
Received: by yenm10 with SMTP id m10so5396862yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:46 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 12/15] vfs: make rmdir retry on ESTALE errors
Date: Tue, 22 May 2012 10:12:16 -0400
Message-Id: <1337695939-2741-13-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c |   82 +++++++++++++++++++++++++++++++++--------------------------
 1 files changed, 46 insertions(+), 36 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 402f469..a11fcc7 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2778,52 +2778,62 @@ out:
 static long do_rmdir(int dfd, const char __user *pathname)
 {
 	int error = 0;
-	char * name;
+	char *name;
 	struct dentry *dentry;
 	struct nameidata nd;
+	unsigned int try = 0;
+	unsigned int lookup_flags = LOOKUP_PARENT;
 
-	error = user_path_parent(dfd, pathname, &nd, &name);
-	if (error)
-		return error;
+	name = getname(pathname);
+	if (IS_ERR(name))
+		return PTR_ERR(name);
 
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
+		error = do_path_lookup(dfd, name, lookup_flags, &nd);
+		if (error)
+			break;
 
-	nd.flags &= ~LOOKUP_PARENT;
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
 
-	mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex, I_MUTEX_PARENT);
-	dentry = lookup_hash(&nd);
-	error = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		goto exit2;
-	if (!dentry->d_inode) {
-		error = -ENOENT;
-		goto exit3;
-	}
-	error = mnt_want_write(nd.path.mnt);
-	if (error)
-		goto exit3;
-	error = security_path_rmdir(&nd.path, dentry);
-	if (error)
-		goto exit4;
-	error = vfs_rmdir(nd.path.dentry->d_inode, dentry);
+		nd.flags &= ~LOOKUP_PARENT;
+
+		mutex_lock_nested(&nd.path.dentry->d_inode->i_mutex,
+							I_MUTEX_PARENT);
+		dentry = lookup_hash(&nd);
+		error = PTR_ERR(dentry);
+		if (IS_ERR(dentry))
+			goto exit2;
+		if (!dentry->d_inode) {
+			error = -ENOENT;
+			goto exit3;
+		}
+		error = mnt_want_write(nd.path.mnt);
+		if (error)
+			goto exit3;
+		error = security_path_rmdir(&nd.path, dentry);
+		if (error)
+			goto exit4;
+		error = vfs_rmdir(nd.path.dentry->d_inode, dentry);
 exit4:
-	mnt_drop_write(nd.path.mnt);
+		mnt_drop_write(nd.path.mnt);
 exit3:
-	dput(dentry);
+		dput(dentry);
 exit2:
-	mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
+		mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 exit1:
-	path_put(&nd.path);
+		path_put(&nd.path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
 	putname(name);
 	return error;
 }
-- 
1.7.7.6

