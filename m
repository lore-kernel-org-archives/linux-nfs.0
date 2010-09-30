Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32285 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755486Ab0I3SQV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Sep 2010 14:16:21 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 10/17] autofs4: add d_manage() dentry operation
To: viro@ftp.linux.org.uk, jmoyer@redhat.com
Cc: linux-fs@vger.kernel.org, autofs@linux.kernel.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>
Date: Thu, 30 Sep 2010 19:15:46 +0100
Message-ID: <20100930181546.30939.47177.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
References: <20100930181455.30939.53914.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Ian Kent <raven@themaw.net>

This patch required a previous patch to add the ->d_automount()
dentry operation.

Add a function to use the newly defined ->d_manage() dentry operation
for blocking during mount and expire.

Whether the VFS calls the dentry operations d_automount() and d_manage()
is controled by the DMANAGED_AUTOMOUNT and DMANAGED_TRANSIT flags. autofs
uses the d_automount() operation to callback to user space to request
mount operations and the d_manage() operation to block walks into mounts
that are under construction or destruction.

In order to prevent these functions from being called unnecessarily the
DMANAGED_* flags are cleared for cases which would cause this. In the
common case the DMANAGED_AUTOMOUNT and DMANAGED_TRANSIT flags are both
set for dentrys waiting to be mounted. The DMANAGED_TRANSIT flag is
cleared upon successful mount request completion and set during expire
runs, both during the dentry expire check, and if selected for expire,
is left set until a subsequent successful mount request completes.

The exception to this is the so-called rootless multi-mount which has
no actual mount at its base. In this case the DMANAGED_AUTOMOUNT flag
is cleared upon successful mount request completion as well and set
again after a successful expire.

Signed-off-by: Ian Kent <raven@themaw.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs4/autofs_i.h |   50 ++++++++++++++++++++++++-
 fs/autofs4/expire.c   |   42 +++++++++++++--------
 fs/autofs4/inode.c    |    3 +
 fs/autofs4/root.c     |  100 +++++++++++++++++++++++++++++++++++++++++++------
 4 files changed, 164 insertions(+), 31 deletions(-)

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index 079206c..48f8248 100644
--- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -96,7 +96,6 @@ struct autofs_info {
 };
 
 #define AUTOFS_INF_EXPIRING	(1<<0) /* dentry is in the process of expiring */
-#define AUTOFS_INF_MOUNTPOINT	(1<<1) /* mountpoint status for direct expire */
 #define AUTOFS_INF_PENDING	(1<<2) /* dentry pending mount */
 
 struct autofs_wait_queue {
@@ -218,6 +217,7 @@ extern const struct file_operations autofs4_root_operations;
 /* Operations methods */
 
 struct vfsmount *autofs4_d_automount(struct path *);
+int autofs4_d_manage(struct path *, bool);
 
 /* VFS automount flags management functions */
 
@@ -245,6 +245,54 @@ static inline void managed_dentry_clear_automount(struct dentry *dentry)
 	spin_unlock(&dentry->d_lock);
 }
 
+static inline void __managed_dentry_set_transit(struct dentry *dentry)
+{
+	dentry->d_managed |= DMANAGED_TRANSIT;
+}
+
+static inline void managed_dentry_set_transit(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_set_transit(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
+static inline void __managed_dentry_clear_transit(struct dentry *dentry)
+{
+	dentry->d_managed &= ~DMANAGED_TRANSIT;
+}
+
+static inline void managed_dentry_clear_transit(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_clear_transit(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
+static inline void __managed_dentry_set_managed(struct dentry *dentry)
+{
+	dentry->d_managed |= (DMANAGED_AUTOMOUNT|DMANAGED_TRANSIT);
+}
+
+static inline void managed_dentry_set_managed(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_set_managed(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
+static inline void __managed_dentry_clear_managed(struct dentry *dentry)
+{
+	dentry->d_managed &= ~(DMANAGED_AUTOMOUNT|DMANAGED_TRANSIT);
+}
+
+static inline void managed_dentry_clear_managed(struct dentry *dentry)
+{
+	spin_lock(&dentry->d_lock);
+	__managed_dentry_clear_managed(dentry);
+	spin_unlock(&dentry->d_lock);
+}
+
 /* Initializing function */
 
 int autofs4_fill_super(struct super_block *, void *, int);
diff --git a/fs/autofs4/expire.c b/fs/autofs4/expire.c
index c366dac..5901da5 100644
--- a/fs/autofs4/expire.c
+++ b/fs/autofs4/expire.c
@@ -26,10 +26,6 @@ static inline int autofs4_can_expire(struct dentry *dentry,
 	if (ino == NULL)
 		return 0;
 
-	/* No point expiring a pending mount */
-	if (ino->flags & AUTOFS_INF_PENDING)
-		return 0;
-
 	if (!do_now) {
 		/* Too young to die */
 		if (!timeout || time_after(ino->last_used + timeout, now))
@@ -264,6 +260,7 @@ struct dentry *autofs4_expire_direct(struct super_block *sb,
 	unsigned long timeout;
 	struct dentry *root = dget(sb->s_root);
 	int do_now = how & AUTOFS_EXP_IMMEDIATE;
+	struct autofs_info *ino;
 
 	if (!root)
 		return NULL;
@@ -272,18 +269,21 @@ struct dentry *autofs4_expire_direct(struct super_block *sb,
 	timeout = sbi->exp_timeout;
 
 	spin_lock(&sbi->fs_lock);
+	ino = autofs4_dentry_ino(root);
+	/* No point expiring a pending mount */
+	if (ino->flags & AUTOFS_INF_PENDING) {
+		spin_unlock(&sbi->fs_lock);
+		return NULL;
+	}
+	managed_dentry_set_transit(root);
 	if (!autofs4_direct_busy(mnt, root, timeout, do_now)) {
 		struct autofs_info *ino = autofs4_dentry_ino(root);
-		if (d_mountpoint(root)) {
-			ino->flags |= AUTOFS_INF_MOUNTPOINT;
-			root->d_managed--;
-		}
 		ino->flags |= AUTOFS_INF_EXPIRING;
-		managed_dentry_set_automount(root);
 		init_completion(&ino->expire_complete);
 		spin_unlock(&sbi->fs_lock);
 		return root;
 	}
+	managed_dentry_clear_transit(root);
 	spin_unlock(&sbi->fs_lock);
 	dput(root);
 
@@ -335,6 +335,10 @@ struct dentry *autofs4_expire_indirect(struct super_block *sb,
 
 		spin_lock(&sbi->fs_lock);
 		ino = autofs4_dentry_ino(dentry);
+		/* No point expiring a pending mount */
+		if (ino->flags & AUTOFS_INF_PENDING)
+			goto cont;
+		managed_dentry_set_transit(dentry);
 
 		/*
 		 * Case 1: (i) indirect mount or top level pseudo direct mount
@@ -394,6 +398,8 @@ struct dentry *autofs4_expire_indirect(struct super_block *sb,
 			}
 		}
 next:
+		managed_dentry_clear_transit(dentry);
+cont:
 		spin_unlock(&sbi->fs_lock);
 		dput(dentry);
 		spin_lock(&dcache_lock);
@@ -407,7 +413,6 @@ found:
 		expired, (int)expired->d_name.len, expired->d_name.name);
 	ino = autofs4_dentry_ino(expired);
 	ino->flags |= AUTOFS_INF_EXPIRING;
-	managed_dentry_set_automount(expired);
 	init_completion(&ino->expire_complete);
 	spin_unlock(&sbi->fs_lock);
 	spin_lock(&dcache_lock);
@@ -476,7 +481,7 @@ int autofs4_expire_run(struct super_block *sb,
 	ino = autofs4_dentry_ino(dentry);
 	ino->flags &= ~AUTOFS_INF_EXPIRING;
 	if (!d_unhashed(dentry))
-		managed_dentry_clear_automount(dentry);
+		managed_dentry_clear_transit(dentry);
 	complete_all(&ino->expire_complete);
 	spin_unlock(&sbi->fs_lock);
 
@@ -502,13 +507,18 @@ int autofs4_do_expire_multi(struct super_block *sb, struct vfsmount *mnt,
 		ret = autofs4_wait(sbi, dentry, NFY_EXPIRE);
 
 		spin_lock(&sbi->fs_lock);
-		if (ino->flags & AUTOFS_INF_MOUNTPOINT) {
-			sb->s_root->d_managed++;
-			ino->flags &= ~AUTOFS_INF_MOUNTPOINT;
-		}
 		ino->flags &= ~AUTOFS_INF_EXPIRING;
+		spin_lock(&dentry->d_lock);
 		if (ret)
-			managed_dentry_clear_automount(dentry);
+			__managed_dentry_clear_transit(dentry);
+		else {
+			if ((IS_ROOT(dentry) ||
+			    (autofs_type_indirect(sbi->type) &&
+			     IS_ROOT(dentry->d_parent))) &&
+			    !(dentry->d_managed & DMANAGED_AUTOMOUNT))
+				__managed_dentry_set_automount(dentry);
+		}
+		spin_unlock(&dentry->d_lock);
 		complete_all(&ino->expire_complete);
 		spin_unlock(&sbi->fs_lock);
 		dput(dentry);
diff --git a/fs/autofs4/inode.c b/fs/autofs4/inode.c
index 41b7ad1..c6e75b3 100644
--- a/fs/autofs4/inode.c
+++ b/fs/autofs4/inode.c
@@ -253,6 +253,7 @@ static struct autofs_info *autofs4_mkroot(struct autofs_sb_info *sbi)
 
 static const struct dentry_operations autofs4_sb_dentry_operations = {
 	.d_automount	= autofs4_d_automount,
+	.d_manage	= autofs4_d_manage,
 	.d_release      = autofs4_dentry_release,
 };
 
@@ -322,7 +323,7 @@ int autofs4_fill_super(struct super_block *s, void *data, int silent)
 	}
 
 	if (autofs_type_trigger(sbi->type))
-		__managed_dentry_set_automount(root);
+		__managed_dentry_set_managed(root);
 
 	root_inode->i_fop = &autofs4_root_operations;
 	root_inode->i_op = autofs_type_trigger(sbi->type) ?
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index 22dc4c0..3e71e4c 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -403,6 +403,7 @@ static const struct dentry_operations autofs4_root_dentry_operations = {
 /* For other dentries */
 static const struct dentry_operations autofs4_dentry_operations = {
 	.d_automount	= autofs4_d_automount,
+	.d_manage	= autofs4_d_manage,
 	.d_release	= autofs4_dentry_release,
 };
 
@@ -583,6 +584,20 @@ struct vfsmount *autofs4_d_automount(struct path *path)
 	DPRINTK("dentry=%p %.*s",
 		dentry, dentry->d_name.len, dentry->d_name.name);
 
+	/*
+	 * Someone may have manually umounted this or it was a submount
+	 * that has gone away.
+	 */
+	spin_lock(&dcache_lock);
+	if (!d_mountpoint(dentry) && list_empty(&dentry->d_subdirs)) {
+		spin_lock(&dentry->d_lock);
+		if (!(dentry->d_managed & DMANAGED_TRANSIT) &&
+		     (dentry->d_managed & DMANAGED_AUTOMOUNT))
+			__managed_dentry_set_transit(path->dentry);
+		spin_unlock(&dentry->d_lock);
+	}
+	spin_unlock(&dcache_lock);
+
 	/* The daemon never triggers a mount. */
 	if (autofs4_oz_mode(sbi))
 		return NULL;
@@ -612,31 +627,65 @@ struct vfsmount *autofs4_d_automount(struct path *path)
 
 	/*
 	 * If the dentry is a symlink it's equivalent to a directory
-	 * having d_mounted() true, so there's no need to call back
+	 * having d_mountpoint() true, so there's no need to call back
 	 * to the daemon.
 	 */
 	if (dentry->d_inode && S_ISLNK(dentry->d_inode->i_mode))
 		goto done;
-	spin_lock(&dcache_lock);
-	if (!d_mountpoint(dentry) && list_empty(&dentry->d_subdirs)) {
+	if (!d_mountpoint(dentry)) {
+		/*
+		 * It's possible that user space hasn't removed directories
+		 * after umounting a rootless multi-mount, although it
+		 * should. For v5 have_submounts() is sufficient to handle
+		 * this because the leaves of the directory tree under the
+		 * mount never trigger mounts themselves (they have an autofs
+		 * trigger mount mounted on them). But v4 pseudo direct mounts
+		 * do need the leaves to to trigger mounts. In this case we
+		 * have no choice but to use the list_empty() check and
+		 * require user space behave.
+		 */
+		if (sbi->version > 4) {
+			if (have_submounts(dentry))
+				goto done;
+		} else {
+			spin_lock(&dcache_lock);
+			if (!list_empty(&dentry->d_subdirs)) {
+				spin_unlock(&dcache_lock);
+				goto done;
+			}
+			spin_unlock(&dcache_lock);
+		}
 		ino->flags |= AUTOFS_INF_PENDING;
-		spin_unlock(&dcache_lock);
 		spin_unlock(&sbi->fs_lock);
 		status = autofs4_mount_wait(dentry);
 		if (status)
 			return ERR_PTR(status);
 		spin_lock(&sbi->fs_lock);
 		ino->flags &= ~AUTOFS_INF_PENDING;
-		goto done;
 	}
-	spin_unlock(&dcache_lock);
 done:
-	/*
-	 * Any needed mounting has been completed and the path updated
-	 * so turn this into a normal dentry so we don't continually
-	 * call ->d_automount().
-	 */
-	managed_dentry_clear_automount(dentry);
+	if (!(ino->flags & AUTOFS_INF_EXPIRING)) {
+		/*
+		 * Any needed mounting has been completed and the path updated
+		 * so turn this into a normal dentry so we don't continually
+		 * call ->d_automount() and ->d_manage().
+		 */
+		spin_lock(&dcache_lock);
+		spin_lock(&dentry->d_lock);
+		__managed_dentry_clear_transit(dentry);
+		/*
+		 * Only clear DMANAGED_AUTOMOUNT for rootless multi-mounts and
+		 * symlinks as in all other cases the dentry will be covered by
+		 * an actual mount so ->d_automount() won't be called during
+		 * the follow.
+		 */
+		if ((!d_mountpoint(dentry) &&
+		    !list_empty(&dentry->d_subdirs)) ||
+		    (dentry->d_inode && S_ISLNK(dentry->d_inode->i_mode)))
+			__managed_dentry_clear_automount(dentry);
+		spin_unlock(&dentry->d_lock);
+		spin_unlock(&dcache_lock);
+	}
 	spin_unlock(&sbi->fs_lock);
 
 	/* Mount succeeded, check if we ended up with a new dentry */
@@ -647,6 +696,31 @@ done:
 	return NULL;
 }
 
+int autofs4_d_manage(struct path *path, bool mounting_here)
+{
+	struct dentry *dentry = path->dentry;
+	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
+
+	DPRINTK("dentry=%p %.*s",
+		dentry, dentry->d_name.len, dentry->d_name.name);
+
+	/* The daemon never waits. */
+	if (autofs4_oz_mode(sbi) || mounting_here) {
+		if (!d_mountpoint(dentry))
+			return -EISDIR;
+		return 0;
+	}
+
+	/* Wait for pending expires */
+	do_expire_wait(dentry);
+
+	/*
+	 * This dentry may be under construction so wait on mount
+	 * completion.
+	 */
+	return autofs4_mount_wait(dentry);
+}
+
 /* Lookups in the root directory */
 static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, struct nameidata *nd)
 {
@@ -683,7 +757,7 @@ static struct dentry *autofs4_lookup(struct inode *dir, struct dentry *dentry, s
 		/* Mark entries in the root as mount triggers */
 		if (autofs_type_indirect(sbi->type) && IS_ROOT(dentry->d_parent)) {
 			dentry->d_op = &autofs4_dentry_operations;
-			managed_dentry_set_automount(dentry);
+			__managed_dentry_set_managed(dentry);
 		}
 
 		ino = autofs4_init_ino(NULL, sbi, 0555);

