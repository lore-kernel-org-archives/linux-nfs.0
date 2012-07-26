Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:40413 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab2GZLzc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jul 2012 07:55:32 -0400
Received: by mail-gg0-f174.google.com with SMTP id u4so1821110ggl.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jul 2012 04:55:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v4 03/17] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Thu, 26 Jul 2012 07:55:06 -0400
Message-Id: <1343303720-11199-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
References: <1343303720-11199-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         |  2 +-
 fs/stat.c          | 21 ++++++++++++++++-----
 include/linux/fs.h |  1 +
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b6fbe3d..1ab4400 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -117,7 +117,7 @@
  * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
  * PATH_MAX includes the nul terminator --RR.
  */
-static char *getname_flags(const char __user *filename, int flags, int *empty)
+char *getname_flags(const char __user *filename, int flags, int *empty)
 {
 	char *result = __getname(), *err;
 	int len;
diff --git a/fs/stat.c b/fs/stat.c
index b6ff118..5afeb37 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -72,9 +72,11 @@ EXPORT_SYMBOL(vfs_fstat);
 int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 		int flag)
 {
+	char *name;
 	struct path path;
 	int error = -EINVAL;
-	int lookup_flags = 0;
+	unsigned int try = 0;
+	unsigned int lookup_flags = 0;
 
 	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
 		      AT_EMPTY_PATH)) != 0)
@@ -85,12 +87,21 @@ int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
 	if (flag & AT_EMPTY_PATH)
 		lookup_flags |= LOOKUP_EMPTY;
 
-	error = user_path_at(dfd, filename, lookup_flags, &path);
-	if (error)
+	name = getname_flags(filename, lookup_flags, NULL);
+	if (IS_ERR(name)) {
+		error = PTR_ERR(name);
 		goto out;
+	}
+	do {
+		error = kern_path_at(dfd, name, lookup_flags, &path);
+		if (error)
+			break;
 
-	error = vfs_getattr(path.mnt, path.dentry, stat);
-	path_put(&path);
+		error = vfs_getattr(path.mnt, path.dentry, stat);
+		path_put(&path);
+		lookup_flags |= LOOKUP_REVAL;
+	} while (retry_estale(error, try++));
+	putname(name);
 out:
 	return error;
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 138d93a..00db714 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2062,6 +2062,7 @@ extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 				   const char *, int);
 extern struct file * dentry_open(const struct path *, int, const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
+extern char *getname_flags(const char __user *, int, int *);
 extern char * getname(const char __user *);
 enum {
 	FILE_CREATED = 1,
-- 
1.7.11.2

