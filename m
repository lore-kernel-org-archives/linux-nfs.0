Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:39403 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757431Ab2EVOMb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:12:31 -0400
Received: by mail-yx0-f174.google.com with SMTP id m10so5396471yen.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 07:12:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: inux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, miklos@szeredi.hu, hch@infradead.org,
        michael.brantley@deshaw.com, pstaubach@exagrid.com
Subject: [PATCH v2 03/15] vfs: make fstatat retry on ESTALE errors from getattr call
Date: Tue, 22 May 2012 10:12:07 -0400
Message-Id: <1337695939-2741-4-git-send-email-jlayton@redhat.com>
In-Reply-To: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
References: <1337695939-2741-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         |    2 +-
 fs/stat.c          |   21 ++++++++++++++++-----
 include/linux/fs.h |    3 ++-
 3 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index c63242f..516be34 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -116,7 +116,7 @@
  * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
  * PATH_MAX includes the nul terminator --RR.
  */
-static char *getname_flags(const char __user *filename, int flags, int *empty)
+char *getname_flags(const char __user *filename, int flags, int *empty)
 {
 	char *result = __getname(), *err;
 	int len;
diff --git a/fs/stat.c b/fs/stat.c
index 0cef336..60a8813 100644
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
index 0b8003b..2f92b93 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2024,7 +2024,8 @@ extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 extern struct file * dentry_open(struct dentry *, struct vfsmount *, int,
 				 const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
-extern char * getname(const char __user *);
+extern char *getname_flags(const char __user *, int, int *);
+extern char *getname(const char __user *);
 
 /**
  * retry_estale - determine whether the caller should retry an operation
-- 
1.7.7.6

