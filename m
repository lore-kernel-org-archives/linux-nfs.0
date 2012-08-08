Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36554 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758433Ab2HHNV6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 09:21:58 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so724654yhm.19
        for <linux-nfs@vger.kernel.org>; Wed, 08 Aug 2012 06:21:57 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, michael.brantley@deshaw.com,
        hch@infradead.org, miklos@szeredi.hu, pstaubach@exagrid.com
Subject: [PATCH v5 07/19] vfs: add new "reval" argument to kern_path_create
Date: Wed,  8 Aug 2012 09:21:30 -0400
Message-Id: <1344432102-22312-8-git-send-email-jlayton@redhat.com>
In-Reply-To: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
References: <1344432102-22312-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...for now, all of the callers pass in "false". Eventually, we'll set
that to "true" when we retry the lookup after getting back an ESTALE on
a call.

While we're at it, change the is_dir arg to a bool since that's how it's
used currently.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 drivers/base/devtmpfs.c |  7 ++++---
 fs/namei.c              | 12 +++++++++---
 include/linux/namei.h   |  2 +-
 net/unix/af_unix.c      |  2 +-
 4 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/drivers/base/devtmpfs.c b/drivers/base/devtmpfs.c
index deb4a45..2124437 100644
--- a/drivers/base/devtmpfs.c
+++ b/drivers/base/devtmpfs.c
@@ -148,7 +148,7 @@ static int dev_mkdir(const char *name, umode_t mode)
 	struct path path;
 	int err;
 
-	dentry = kern_path_create(AT_FDCWD, name, &path, 1);
+	dentry = kern_path_create(AT_FDCWD, name, &path, true, false);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
@@ -193,10 +193,11 @@ static int handle_create(const char *nodename, umode_t mode, struct device *dev)
 	struct path path;
 	int err;
 
-	dentry = kern_path_create(AT_FDCWD, nodename, &path, 0);
+	dentry = kern_path_create(AT_FDCWD, nodename, &path, false, false);
 	if (dentry == ERR_PTR(-ENOENT)) {
 		create_path(nodename);
-		dentry = kern_path_create(AT_FDCWD, nodename, &path, 0);
+		dentry = kern_path_create(AT_FDCWD, nodename, &path,
+								false, false);
 	}
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
diff --git a/fs/namei.c b/fs/namei.c
index f0463bc..f04ba14 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2972,12 +2972,18 @@ struct file *do_file_open_root(struct dentry *dentry, struct vfsmount *mnt,
 	return file;
 }
 
-struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, int is_dir)
+struct dentry *kern_path_create(int dfd, const char *pathname, struct path *path, bool is_dir, bool reval)
 {
 	struct dentry *dentry = ERR_PTR(-EEXIST);
 	struct nameidata nd;
 	int err2;
-	int error = do_path_lookup(dfd, pathname, LOOKUP_PARENT, &nd);
+	int error;
+	unsigned int lookup_flags = LOOKUP_PARENT;
+
+	if (reval)
+		lookup_flags |= LOOKUP_REVAL;
+
+	error = do_path_lookup(dfd, pathname, lookup_flags, &nd);
 	if (error)
 		return ERR_PTR(error);
 
@@ -3047,7 +3053,7 @@ struct dentry *user_path_create(int dfd, const char __user *pathname, struct pat
 	struct dentry *res;
 	if (IS_ERR(tmp))
 		return ERR_CAST(tmp);
-	res = kern_path_create(dfd, tmp, path, is_dir);
+	res = kern_path_create(dfd, tmp, path, (bool)is_dir, false);
 	putname(tmp);
 	return res;
 }
diff --git a/include/linux/namei.h b/include/linux/namei.h
index 491fb48..24c4962 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -65,7 +65,7 @@ extern int user_path_at(int, const char __user *, unsigned, struct path *);
 
 extern int kern_path(const char *, unsigned, struct path *);
 
-extern struct dentry *kern_path_create(int, const char *, struct path *, int);
+extern struct dentry *kern_path_create(int, const char *, struct path *, bool, bool);
 extern struct dentry *user_path_create(int, const char __user *, struct path *, int);
 extern void done_path_create(struct path *, struct dentry *);
 extern struct dentry *kern_path_locked(const char *, struct path *);
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e4768c1..3f61f4c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -832,7 +832,7 @@ static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
 	 * Get the parent directory, calculate the hash for last
 	 * component.
 	 */
-	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
+	dentry = kern_path_create(AT_FDCWD, sun_path, &path, false, false);
 	err = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		return err;
-- 
1.7.11.2

