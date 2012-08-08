Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36202 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758438Ab2HHNV4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:21:56 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so724688yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:21:56 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 06/19] vfs: turn "empty" arg in getname_flags into a bool
Date: Wed,  8 Aug 2012 09:21:29 -0400
Message-Id: <1344432102-22312-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...it's just used as a flag.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/namei.c         | 4 ++--
 fs/stat.c          | 2 +-
 include/linux/fs.h | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index dc58de9..f0463bc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -117,7 +117,7 @@
  * POSIX.1 2.4: an empty pathname is invalid (ENOENT).
  * PATH_MAX includes the nul terminator --RR.
  */
-char *getname_flags(const char __user *filename, int flags, int *empty)
+char *getname_flags(const char __user *filename, int flags, bool *empty)
 {
 	char *result = __getname(), *err;
 	int len;
@@ -133,7 +133,7 @@ char *getname_flags(const char __user *filename, int flags, int *empty)
 	/* The empty path is special. */
 	if (unlikely(!len)) {
 		if (empty)
-			*empty = 1;
+			*empty = true;
 		err = ERR_PTR(-ENOENT);
 		if (!(flags & LOOKUP_EMPTY))
 			goto error;
diff --git a/fs/stat.c b/fs/stat.c
index c9d88f7..4f8b6bc 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -306,7 +306,7 @@ SYSCALL_DEFINE4(readlinkat, int, dfd, const char __user *, pathname,
 {
 	struct path path;
 	int error;
-	int empty = 0;
+	bool empty = false;
 	char *name;
 	unsigned int try = 0;
 	unsigned int lookup_flags = LOOKUP_EMPTY;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f2e7371..55b3cc3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2201,7 +2201,7 @@ extern struct file *file_open_root(struct dentry *, struct vfsmount *,
 				   const char *, int);
 extern struct file * dentry_open(const struct path *, int, const struct cred *);
 extern int filp_close(struct file *, fl_owner_t id);
-extern char *getname_flags(const char __user *, int, int *);
+extern char *getname_flags(const char __user *, int, bool *);
 extern char * getname(const char __user *);
 enum {
 	FILE_CREATED = 1,
-- 
1.7.11.2

