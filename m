Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50066 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932212Ab0I3SQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:32 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/17] autofs4: cleanup dentry operations
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:16:02 +0100
Message-ID: <20100930181602.30939.21192.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

There are now two distinct dentry operations uses. One for dentrys
that trigger mounts and one for dentrys that do not.

Rationalize the use of these dentry operations and rename them to
reflect their function.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/autofs_i.h |    7 ++-----
 fs/autofs4/inode.c    |   12 ++++--------
 fs/autofs4/root.c     |   36 ++++++++++++++++++++----------------
 3 files changed, 26 insertions(+), 29 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index 8710878..8b1c0bc 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -203,11 +203,8 @@ extern const struct inode_operations autofs4_symlink_inode_operations;
 extern const struct inode_operations autofs4_dir_inode_operations;
 extern const struct file_operations autofs4_dir_operations;
 extern const struct file_operations autofs4_root_operations;
-
-/* Operations methods */
-
-struct vfsmount *autofs4_d_automount(struct path *);
-int autofs4_d_manage(struct path *, bool);
+extern const struct dentry_operations autofs4_dentry_operations;
+extern const struct dentry_operations autofs4_mount_dentry_operations;
 
 /* VFS automount flags management functions */
 
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 80cdffd..8eaa723 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -251,12 +251,6 @@ static struct autofs_info *autofs4_mkroot(struct autofs_sb_info *sbi)
 	return ino;
 }
 
-static const struct dentry_operations autofs4_sb_dentry_operations = {
-	.d_automount	= autofs4_d_automount,
-	.d_manage	= autofs4_d_manage,
-	.d_release      = autofs4_dentry_release,
-};
-
 int autofs4_fill_super(struct super_block *s, void *data, int silent)
 {
 	struct inode * root_inode;
@@ -311,7 +305,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 		goto fail_iput;
 	pipe = NULL;
 
-	root->d_op = &autofs4_sb_dentry_operations;
+	root->d_op = &autofs4_dentry_operations;
 	root->d_fsdata = ino;
 
 	/* Can this call block? */
@@ -322,8 +316,10 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 		goto fail_dput;
 	}
 
-	if (autofs_type_trigger(sbi->type))
+	if (autofs_type_trigger(sbi->type)) {
+		root->d_op = &autofs4_mount_dentry_operations;
 		__managed_dentry_set_managed(root);
+	}
 
 	root_inode->i_fop = &autofs4_root_operations;
 	root_inode->i_op = &autofs4_dir_inode_operations;
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 2856a0c..cb168ba 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -31,6 +31,8 @@ static long autofs4_root_ioctl(struct file *,unsigned int,unsigned long);
 static long autofs4_root_compat_ioctl(struct file *,unsigned int,unsigned long);
 static int autofs4_dir_open(struct inode *inode, struct file *file);
 static struct dentry *autofs4_lookup(struct inode *,struct dentry *, struct nameidata *);
+static struct vfsmount *autofs4_d_automount(struct path *);
+static int autofs4_d_manage(struct path *, bool);
 
 const struct file_operations autofs4_root_operations = {
 	.open		= dcache_dir_open,
@@ -60,6 +62,18 @@ const struct inode_operations autofs4_dir_inode_operations = {
 	.rmdir		= autofs4_dir_rmdir,
 };
 
+/* For dentries that don't initiate mounting */
+const struct dentry_operations autofs4_dentry_operations = {
+	.d_release	= autofs4_dentry_release,
+};
+
+/* For dentries that do initiate mounting */
+const struct dentry_operations autofs4_mount_dentry_operations = {
+	.d_automount	= autofs4_d_automount,
+	.d_manage	= autofs4_d_manage,
+	.d_release	= autofs4_dentry_release,
+};
+
 static void autofs4_add_active(struct dentry *dentry)
 {
 	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
@@ -151,18 +165,6 @@ void autofs4_dentry_release(struct dentry *de)
 	}
 }
 
-/* For dentries of directories in the root dir */
-static const struct dentry_operations autofs4_root_dentry_operations = {
-	.d_release	= autofs4_dentry_release,
-};
-
-/* For other dentries */
-static const struct dentry_operations autofs4_dentry_operations = {
-	.d_automount	= autofs4_d_automount,
-	.d_manage	= autofs4_d_manage,
-	.d_release	= autofs4_dentry_release,
-};
-
 static struct dentry *autofs4_lookup_active(struct dentry *dentry)
 {
 	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
@@ -330,7 +332,7 @@ static struct dentry *autofs4_mountpoint_changed(struct path *path)
 	return path->dentry;
 }
 
-struct vfsmount *autofs4_d_automount(struct path *path)
+static struct vfsmount *autofs4_d_automount(struct path *path)
 {
 	struct dentry *dentry = path->dentry;
 	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
@@ -499,7 +501,7 @@ static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, s
 	if (active)
 		return active;
 	else {
-		dentry->d_op = &autofs4_root_dentry_operations;
+		dentry->d_op = &autofs4_dentry_operations;
 
 		/*
 		 * A dentry that is not within the root can never trigger
@@ -512,7 +514,7 @@ static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, s
 
 		/* Mark entries in the root as mount triggers */
 		if (autofs_type_indirect(sbi->type) && IS_ROOT(dentry->d_parent)) {
-			dentry->d_op = &autofs4_dentry_operations;
+			dentry->d_op = &autofs4_mount_dentry_operations;
 			__managed_dentry_set_managed(dentry);
 		}
 
@@ -572,6 +574,8 @@ static int autofs4_dir_symlink(struct inode *dir,
 	}
 	d_add(dentry, inode);
 
+	dentry->d_op = &autofs4_dentry_operations;
+
 	dentry->d_fsdata = ino;
 	ino->dentry = dget(dentry);
 	atomic_inc(&ino->count);
@@ -786,7 +790,7 @@ static inline int autofs4_ask_umount(struct vfsmount *mnt, int __user *p)
 int is_autofs4_dentry(struct dentry *dentry)
 {
 	return dentry && dentry->d_inode &&
-		(dentry->d_op == &autofs4_root_dentry_operations ||
+		(dentry->d_op == &autofs4_mount_dentry_operations ||
 		 dentry->d_op == &autofs4_dentry_operations) &&
 		dentry->d_fsdata != NULL;
 }

