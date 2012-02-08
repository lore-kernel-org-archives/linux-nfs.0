Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16208 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756092Ab2BHVSM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:18:12 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 08/17] VFS: Make more complete truncate operation available to
 CacheFiles
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:18:03 +0000
Message-ID: <20120208211802.15607.46621.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make a more complete truncate operation available to CacheFiles (including
security checks and suchlike) so that it can use this to clear invalidated
cache files.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/open.c          |   50 +++++++++++++++++++++++++++-----------------------
 include/linux/fs.h |    1 +
 2 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index 77becc0..7535620 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -61,33 +61,22 @@ int do_truncate(struct dentry *dentry, loff_t length, unsigned int time_attrs,
 	return ret;
 }
 
-static long do_sys_truncate(const char __user *pathname, loff_t length)
+long vfs_truncate(struct path *path, loff_t length)
 {
-	struct path path;
 	struct inode *inode;
-	int error;
-
-	error = -EINVAL;
-	if (length < 0)	/* sorry, but loff_t says... */
-		goto out;
+	long error;
 
-	error = user_path(pathname, &path);
-	if (error)
-		goto out;
-	inode = path.dentry->d_inode;
+	inode = path->dentry->d_inode;
 
 	/* For directories it's -EISDIR, for other non-regulars - -EINVAL */
-	error = -EISDIR;
 	if (S_ISDIR(inode->i_mode))
-		goto dput_and_out;
-
-	error = -EINVAL;
+		return -EISDIR;
 	if (!S_ISREG(inode->i_mode))
-		goto dput_and_out;
+		return -EINVAL;
 
-	error = mnt_want_write(path.mnt);
+	error = mnt_want_write(path->mnt);
 	if (error)
-		goto dput_and_out;
+		goto out;
 
 	error = inode_permission(inode, MAY_WRITE);
 	if (error)
@@ -111,19 +100,34 @@ static long do_sys_truncate(const char __user *pathname, loff_t length)
 
 	error = locks_verify_truncate(inode, NULL, length);
 	if (!error)
-		error = security_path_truncate(&path);
+		error = security_path_truncate(path);
 	if (!error)
-		error = do_truncate(path.dentry, length, 0, NULL);
+		error = do_truncate(path->dentry, length, 0, NULL);
 
 put_write_and_out:
 	put_write_access(inode);
 mnt_drop_write_and_out:
-	mnt_drop_write(path.mnt);
-dput_and_out:
-	path_put(&path);
+	mnt_drop_write(path->mnt);
 out:
 	return error;
 }
+EXPORT_SYMBOL_GPL(vfs_truncate);
+
+static long do_sys_truncate(const char __user *pathname, loff_t length)
+{
+	struct path path;
+	int error;
+
+	if (length < 0)	/* sorry, but loff_t says... */
+		return -EINVAL;
+
+	error = user_path(pathname, &path);
+	if (!error) {
+		error = vfs_truncate(&path, length);
+		path_put(&path);
+	}
+	return error;
+}
 
 SYSCALL_DEFINE2(truncate, const char __user *, path, long, length)
 {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 386da09..79449e4 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2014,6 +2014,7 @@ static inline int break_lease(struct inode *inode, unsigned int mode)
 
 /* fs/open.c */
 
+extern long vfs_truncate(struct path *, loff_t);
 extern int do_truncate(struct dentry *, loff_t start, unsigned int time_attrs,
 		       struct file *filp);
 extern int do_fallocate(struct file *file, int mode, loff_t offset,

