Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9649 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172Ab0I3SQM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:12 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 09/17] autofs4: add d_automount() dentry operation
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:15:41 +0100
Message-ID: <20100930181541.30939.62503.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

Add a function to use the newly defined ->d_automount() dentry operation
for triggering mounts instead of doing the user space callback in ->lookup()
and ->d_revalidate().

Note, to be useful the subsequent patch to add the ->d_manage() dentry
operation is also needed so the discussion of functionality is deferred to
that patch.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/autofs_i.h |   30 ++++++
 fs/autofs4/expire.c   |    6 +
 fs/autofs4/inode.c    |    4 +
 fs/autofs4/root.c     |  262 ++++++++++++++++++++++++++++---------------------
 4 files changed, 190 insertions(+), 112 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index 08af160..079206c 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -215,6 +215,36 @@ extern const struct inode_operations autofs4_direct_root_inode_operations;
 extern const struct file_operations autofs4_dir_operations;
 extern const struct file_operations autofs4_root_operations;
 
+/* Operations methods */
+
+struct vfsmount *autofs4_d_automount(struct path *);
+
+/* VFS automount flags management functions */
+
+static inline void __managed_dentry_set_automount(struct dentry *dentry)
+{
+	dentry->d_managed |= DMANAGED_AUTOMOUNT;
+}
+
+static inline void managed_dentry_set_automount(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_set_automount(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
+static inline void __managed_dentry_clear_automount(struct dentry *dentry)
+{
+	dentry->d_managed &= ~DMANAGED_AUTOMOUNT;
+}
+
+static inline void managed_dentry_clear_automount(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_clear_automount(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
 /* Initializing function */
 
 int autofs4_fill_super(struct super_block *, void *, int);
diff --git a/fs/autofs4/expire.c b/fs/autofs4/expire.c
index 47feba9..c366dac 100644
--- a/fs/autofs4/expire.c
+++ b/fs/autofs4/expire.c
@@ -279,6 +279,7 @@ struct dentry *autofs4_expire_direct(struct super_block *sb,
 			root->d_managed--;
 		}
 		ino->flags |= AUTOFS_INF_EXPIRING;
+		managed_dentry_set_automount(root);
 		init_completion(&ino->expire_complete);
 		spin_unlock(&sbi->fs_lock);
 		return root;
@@ -406,6 +407,7 @@ found:
 		expired, (int)expired->d_name.len, expired->d_name.name);
 	ino = autofs4_dentry_ino(expired);
 	ino->flags |= AUTOFS_INF_EXPIRING;
+	managed_dentry_set_automount(expired);
 	init_completion(&ino->expire_complete);
 	spin_unlock(&sbi->fs_lock);
 	spin_lock(&dcache_lock);
@@ -473,6 +475,8 @@ int autofs4_expire_run(struct super_block *sb,
 	spin_lock(&sbi->fs_lock);
 	ino = autofs4_dentry_ino(dentry);
 	ino->flags &= ~AUTOFS_INF_EXPIRING;
+	if (!d_unhashed(dentry))
+		managed_dentry_clear_automount(dentry);
 	complete_all(&ino->expire_complete);
 	spin_unlock(&sbi->fs_lock);
 
@@ -503,6 +507,8 @@ int autofs4_do_expire_multi(struct super_block *sb, struct vfsmount *mnt,
 			ino->flags &= ~AUTOFS_INF_MOUNTPOINT;
 		}
 		ino->flags &= ~AUTOFS_INF_EXPIRING;
+		if (ret)
+			managed_dentry_clear_automount(dentry);
 		complete_all(&ino->expire_complete);
 		spin_unlock(&sbi->fs_lock);
 		dput(dentry);
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 821b2b9..41b7ad1 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -252,6 +252,7 @@ static struct autofs_info *autofs4_mkroot(struct autofs_sb_info *sbi)
 }
 
 static const struct dentry_operations autofs4_sb_dentry_operations = {
+	.d_automount	= autofs4_d_automount,
 	.d_release      = autofs4_dentry_release,
 };
 
@@ -320,6 +321,9 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 		goto fail_dput;
 	}
 
+	if (autofs_type_trigger(sbi->type))
+		__managed_dentry_set_automount(root);
+
 	root_inode->i_fop = &autofs4_root_operations;
 	root_inode->i_op = autofs_type_trigger(sbi->type) ?
 			&autofs4_direct_root_inode_operations :
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 7dd218b..22dc4c0 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -31,7 +31,6 @@ static long autofs4_root_ioctl(struct file *,unsigned int,unsigned long);
 static long autofs4_root_compat_ioctl(struct file *,unsigned int,unsigned long);
 static int autofs4_dir_open(struct inode *inode, struct file *file);
 static struct dentry *autofs4_lookup(struct inode *,struct dentry *, struct nameidata *);
-static void *autofs4_follow_link(struct dentry *, struct nameidata *);
 
 #define TRIGGER_FLAGS   (LOOKUP_CONTINUE | LOOKUP_DIRECTORY)
 #define TRIGGER_INTENTS (LOOKUP_OPEN | LOOKUP_CREATE)
@@ -69,7 +68,6 @@ const struct inode_operations autofs4_direct_root_inode_operations = {
 	.unlink		= autofs4_dir_unlink,
 	.mkdir		= autofs4_dir_mkdir,
 	.rmdir		= autofs4_dir_rmdir,
-	.follow_link	= autofs4_follow_link,
 };
 
 const struct inode_operations autofs4_dir_inode_operations = {
@@ -399,13 +397,12 @@ void autofs4_dentry_release(struct dentry *de)
 
 /* For dentries of directories in the root dir */
 static const struct dentry_operations autofs4_root_dentry_operations = {
-	.d_revalidate	= autofs4_revalidate,
 	.d_release	= autofs4_dentry_release,
 };
 
 /* For other dentries */
 static const struct dentry_operations autofs4_dentry_operations = {
-	.d_revalidate	= autofs4_revalidate,
+	.d_automount	= autofs4_d_automount,
 	.d_release	= autofs4_dentry_release,
 };
 
@@ -519,50 +516,176 @@ next:
 	return NULL;
 }
 
+static int autofs4_mount_wait(struct dentry *dentry)
+{
+	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
+	struct autofs_info *ino = autofs4_dentry_ino(dentry);
+	int status;
+
+	if (ino->flags & AUTOFS_INF_PENDING) {
+		DPRINTK("waiting for mount name=%.*s",
+			dentry->d_name.len, dentry->d_name.name);
+		status = autofs4_wait(sbi, dentry, NFY_MOUNT);
+		DPRINTK("mount wait done status=%d", status);
+		ino->last_used = jiffies;
+		return status;
+	}
+	return 0;
+}
+
+static int do_expire_wait(struct dentry *dentry)
+{
+	struct dentry *expiring;
+
+	expiring = autofs4_lookup_expiring(dentry);
+	if (!expiring)
+		return autofs4_expire_wait(dentry);
+	else {
+		/*
+		 * If we are racing with expire the request might not
+		 * be quite complete, but the directory has been removed
+		 * so it must have been successful, just wait for it.
+		 */
+		autofs4_expire_wait(expiring);
+		autofs4_del_expiring(expiring);
+		dput(expiring);
+	}
+	return 0;
+}
+
+static struct dentry *autofs4_mountpoint_changed(struct path *path)
+{
+	struct dentry *dentry = path->dentry;
+	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
+
+	/*
+	 * If this is an indirect mount the dentry could have gone away
+	 * as a result of an expire and a new one created.
+	 */
+	if (autofs_type_indirect(sbi->type) && d_unhashed(dentry)) {
+		struct dentry *parent = dentry->d_parent;
+		struct dentry *new = d_lookup(parent, &dentry->d_name);
+		if (!new)
+			return NULL;
+		dput(path->dentry);
+		path->dentry = new;
+	}
+	return path->dentry;
+}
+
+struct vfsmount *autofs4_d_automount(struct path *path)
+{
+	struct dentry *dentry = path->dentry;
+	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
+	struct autofs_info *ino = autofs4_dentry_ino(dentry);
+	int status;
+
+	DPRINTK("dentry=%p %.*s",
+		dentry, dentry->d_name.len, dentry->d_name.name);
+
+	/* The daemon never triggers a mount. */
+	if (autofs4_oz_mode(sbi))
+		return NULL;
+
+	/*
+	 * If an expire request is pending everyone must wait.
+	 * If the expire fails we're still mounted so continue
+	 * the follow and return. A return of -EAGAIN (which only
+	 * happens with indirect mounts) means the expire completed
+	 * and the directory was removed, so just go ahead and try
+	 * the mount.
+	 */
+	status = do_expire_wait(dentry);
+	if (status && status != -EAGAIN)
+		return NULL;
+
+	/* Callback to the daemon to perform the mount or wait */
+	spin_lock(&sbi->fs_lock);
+	if (ino->flags & AUTOFS_INF_PENDING) {
+		spin_unlock(&sbi->fs_lock);
+		status = autofs4_mount_wait(dentry);
+		if (status)
+			return ERR_PTR(status);
+		spin_lock(&sbi->fs_lock);
+		goto done;
+	}
+
+	/*
+	 * If the dentry is a symlink it's equivalent to a directory
+	 * having d_mounted() true, so there's no need to call back
+	 * to the daemon.
+	 */
+	if (dentry->d_inode && S_ISLNK(dentry->d_inode->i_mode))
+		goto done;
+	spin_lock(&dcache_lock);
+	if (!d_mountpoint(dentry) && list_empty(&dentry->d_subdirs)) {
+		ino->flags |= AUTOFS_INF_PENDING;
+		spin_unlock(&dcache_lock);
+		spin_unlock(&sbi->fs_lock);
+		status = autofs4_mount_wait(dentry);
+		if (status)
+			return ERR_PTR(status);
+		spin_lock(&sbi->fs_lock);
+		ino->flags &= ~AUTOFS_INF_PENDING;
+		goto done;
+	}
+	spin_unlock(&dcache_lock);
+done:
+	/*
+	 * Any needed mounting has been completed and the path updated
+	 * so turn this into a normal dentry so we don't continually
+	 * call ->d_automount().
+	 */
+	managed_dentry_clear_automount(dentry);
+	spin_unlock(&sbi->fs_lock);
+
+	/* Mount succeeded, check if we ended up with a new dentry */
+	dentry = autofs4_mountpoint_changed(path);
+	if (!dentry)
+		return ERR_PTR(-ENOENT);
+
+	return NULL;
+}
+
 /* Lookups in the root directory */
 static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
 	struct autofs_sb_info *sbi;
 	struct autofs_info *ino;
-	struct dentry *expiring, *active;
-	int oz_mode;
+	struct dentry *active;
 
-	DPRINTK("name = %.*s",
-		dentry->d_name.len, dentry->d_name.name);
+	DPRINTK("name = %.*s", dentry->d_name.len, dentry->d_name.name);
 
 	/* File name too long to exist */
 	if (dentry->d_name.len > NAME_MAX)
 		return ERR_PTR(-ENAMETOOLONG);
 
 	sbi = autofs4_sbi(dir->i_sb);
-	oz_mode = autofs4_oz_mode(sbi);
 
 	DPRINTK("pid = %u, pgrp = %u, catatonic = %d, oz_mode = %d",
 		 current->pid, task_pgrp_nr(current), sbi->catatonic, oz_mode);
 
 	active = autofs4_lookup_active(dentry);
-	if (active) {
-		dentry = active;
-		ino = autofs4_dentry_ino(dentry);
-	} else {
-		/*
-		 * Mark the dentry incomplete but don't hash it. We do this
-		 * to serialize our inode creation operations (symlink and
-		 * mkdir) which prevents deadlock during the callback to
-		 * the daemon. Subsequent user space lookups for the same
-		 * dentry are placed on the wait queue while the daemon
-		 * itself is allowed passage unresticted so the create
-		 * operation itself can then hash the dentry. Finally,
-		 * we check for the hashed dentry and return the newly
-		 * hashed dentry.
-		 */
+	if (active)
+		return active;
+	else {
 		dentry->d_op = &autofs4_root_dentry_operations;
 
 		/*
-		 * And we need to ensure that the same dentry is used for
-		 * all following lookup calls until it is hashed so that
-		 * the dentry flags are persistent throughout the request.
+		 * A dentry that is not within the root can never trigger
+		 * a mount operation, unless the directory already exists,
+		 * so we can return fail immediately. The daemon however
+		 * does need to create directories within the file system.
 		 */
+		if (!autofs4_oz_mode(sbi) && !IS_ROOT(dentry->d_parent))
+			return ERR_PTR(-ENOENT);
+
+		/* Mark entries in the root as mount triggers */
+		if (autofs_type_indirect(sbi->type) && IS_ROOT(dentry->d_parent)) {
+			dentry->d_op = &autofs4_dentry_operations;
+			managed_dentry_set_automount(dentry);
+		}
+
 		ino = autofs4_init_ino(NULL, sbi, 0555);
 		if (!ino)
 			return ERR_PTR(-ENOMEM);
@@ -575,81 +698,6 @@ static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, s
 		d_instantiate(dentry, NULL);
 	}
 
-	if (!oz_mode) {
-		mutex_unlock(&dir->i_mutex);
-		expiring = autofs4_lookup_expiring(dentry);
-		if (expiring) {
-			/*
-			 * If we are racing with expire the request might not
-			 * be quite complete but the directory has been removed
-			 * so it must have been successful, so just wait for it.
-			 */
-			autofs4_expire_wait(expiring);
-			autofs4_del_expiring(expiring);
-			dput(expiring);
-		}
-
-		spin_lock(&sbi->fs_lock);
-		ino->flags |= AUTOFS_INF_PENDING;
-		spin_unlock(&sbi->fs_lock);
-		if (dentry->d_op && dentry->d_op->d_revalidate)
-			(dentry->d_op->d_revalidate)(dentry, nd);
-		mutex_lock(&dir->i_mutex);
-	}
-
-	/*
-	 * If we are still pending, check if we had to handle
-	 * a signal. If so we can force a restart..
-	 */
-	if (ino->flags & AUTOFS_INF_PENDING) {
-		/* See if we were interrupted */
-		if (signal_pending(current)) {
-			sigset_t *sigset = &current->pending.signal;
-			if (sigismember (sigset, SIGKILL) ||
-			    sigismember (sigset, SIGQUIT) ||
-			    sigismember (sigset, SIGINT)) {
-			    if (active)
-				dput(active);
-			    return ERR_PTR(-ERESTARTNOINTR);
-			}
-		}
-		if (!oz_mode) {
-			spin_lock(&sbi->fs_lock);
-			ino->flags &= ~AUTOFS_INF_PENDING;
-			spin_unlock(&sbi->fs_lock);
-		}
-	}
-
-	/*
-	 * If this dentry is unhashed, then we shouldn't honour this
-	 * lookup.  Returning ENOENT here doesn't do the right thing
-	 * for all system calls, but it should be OK for the operations
-	 * we permit from an autofs.
-	 */
-	if (!oz_mode && d_unhashed(dentry)) {
-		/*
-		 * A user space application can (and has done in the past)
-		 * remove and re-create this directory during the callback.
-		 * This can leave us with an unhashed dentry, but a
-		 * successful mount!  So we need to perform another
-		 * cached lookup in case the dentry now exists.
-		 */
-		struct dentry *parent = dentry->d_parent;
-		struct dentry *new = d_lookup(parent, &dentry->d_name);
-		if (new != NULL)
-			dentry = new;
-		else
-			dentry = ERR_PTR(-ENOENT);
-
-		if (active)
-			dput(active);
-
-		return dentry;
-	}
-
-	if (active)
-		return active;
-
 	return NULL;
 }
 
@@ -694,11 +742,6 @@ static int autofs4_dir_symlink(struct inode *dir,
 	}
 	d_add(dentry, inode);
 
-	if (dir == dir->i_sb->s_root->d_inode)
-		dentry->d_op = &autofs4_root_dentry_operations;
-	else
-		dentry->d_op = &autofs4_dentry_operations;
-
 	dentry->d_fsdata = ino;
 	ino->dentry = dget(dentry);
 	atomic_inc(&ino->count);
@@ -825,11 +868,6 @@ static int autofs4_dir_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	}
 	d_add(dentry, inode);
 
-	if (dir == dir->i_sb->s_root->d_inode)
-		dentry->d_op = &autofs4_root_dentry_operations;
-	else
-		dentry->d_op = &autofs4_dentry_operations;
-
 	dentry->d_fsdata = ino;
 	ino->dentry = dget(dentry);
 	atomic_inc(&ino->count);

