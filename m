From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [RFC PATCH 1/2] VFS: Add a VFS helper function
 vfs_remote_path_lookup()
Date: Mon, 09 Feb 2009 13:45:34 -0500
Message-ID: <20090209184534.23040.82657.stgit@heimdal.trondhjem.org>
References: <20090209184534.23040.82605.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55904 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbZBITTz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 14:19:55 -0500
In-Reply-To: <20090209184534.23040.82605.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The purpose of this patch is to improve the mount path lookup support for
filesystems such as NFSv4, which require you to look up a mount path
string in a remote server's namespace.

Traversing such a path is pretty much identical to walking a local path,
in that it may involve following symlinks and even following referrals to
volumes that reside on other servers. Since the standard VFS path lookup
code already supports all these features (using in-kernel automounts for
following referrals) it would be nice to be able to reuse that code rather
than special case the mount path lookup in the NFS client.

This patch therefore defines a VFS helper function that sets up a temporary
mount namespace to represent the server namespace, and has the current
task pivot into that prior to doing the path lookup. Upon completion, it
pivots back into the original namespace, and destroys the private one.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/namei.c                    |   75 ++++++++++++++++++++++++++++++++++++++++-
 fs/namespace.c                |   56 ++++++++++++++++++++++++++-----
 include/linux/mnt_namespace.h |    2 +
 include/linux/namei.h         |    2 +
 include/linux/nsproxy.h       |    1 +
 kernel/nsproxy.c              |   11 ++++++
 6 files changed, 138 insertions(+), 9 deletions(-)


diff --git a/fs/namei.c b/fs/namei.c
index bbc15c2..9280299 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -25,7 +25,7 @@
 #include <linux/personality.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
-#include <linux/mount.h>
+#include <linux/mnt_namespace.h>
 #include <linux/audit.h>
 #include <linux/capability.h>
 #include <linux/file.h>
@@ -1119,6 +1119,79 @@ int vfs_path_lookup(struct dentry *dentry, struct vfsmount *mnt,
 }
 
 /**
+ * vfs_remote_path_lookup - look up a path in a remote server namespace
+ * @dentry:  pointer to dentry of the base directory
+ * @mnt: pointer to vfs mount of the base directory
+ * @name: pointer to file name
+ * @flags: lookup flags
+ * @nd: pointer to nameidata
+ *
+ * This function creates a private mount namespace and sets 'mnt' as the
+ * root volume before looking up the path 'name'.
+ * It is intended for use by filesystems like NFSv4, which has a mount
+ * path that is relative to a remote server's namespace, and where walking
+ * that path may involve following referrals/links to volumes that reside
+ * on yet other servers. The resulting in-kernel automount can now be
+ * done safely as it affects the private namespace only.
+ */
+int vfs_remote_path_lookup(struct dentry *dentry,
+		struct vfsmount *mnt, const char *name,
+		unsigned int flags, struct nameidata *nd)
+{
+	struct nsproxy *new_nsproxy, *orig_nsproxy;
+	struct mnt_namespace *new_mnt_ns;
+	struct fs_struct *new_fs, *orig_fs;
+	int error = -ENOMEM;
+
+	new_fs = copy_fs_struct(current->fs);
+	if (new_fs == NULL)
+		goto out_err;
+
+	new_mnt_ns = create_private_mnt_ns(mnt, new_fs);
+	if (new_mnt_ns == NULL)
+		goto out_put_fs_struct;
+
+	/* Create a private copy of current->nsproxy */
+	new_nsproxy = unshare_current_nsproxy();
+	error = PTR_ERR(new_nsproxy);
+	if (IS_ERR(new_nsproxy))
+		goto out_put_mnt_ns;
+
+	/* ...and substitute the private mount namespace */
+	put_mnt_ns(new_nsproxy->mnt_ns);
+	new_nsproxy->mnt_ns = new_mnt_ns;
+	get_mnt_ns(new_mnt_ns);
+
+	/* Save the old nsproxy */
+	orig_nsproxy = current->nsproxy;
+	get_nsproxy(orig_nsproxy);
+
+	/* Pivot into the new mount namespace */
+	switch_task_namespaces(current, new_nsproxy);
+	task_lock(current);
+	orig_fs = current->fs;
+	current->fs = new_fs;
+	task_unlock(current);
+
+	error = vfs_path_lookup(dentry, mnt, name, flags, nd);
+
+	/* Pivot back into the original namespace */
+	task_lock(current);
+	current->fs = orig_fs;
+	task_unlock(current);
+	switch_task_namespaces(current, orig_nsproxy);
+
+out_put_mnt_ns:
+	put_mnt_ns(new_mnt_ns);
+
+out_put_fs_struct:
+	put_fs_struct(new_fs);
+out_err:
+	return error;
+}
+EXPORT_SYMBOL_GPL(vfs_remote_path_lookup);
+
+/**
  * path_lookup_open - lookup a file path with open intent
  * @dfd: the directory to use as base, or AT_FDCWD
  * @name: pointer to file name
diff --git a/fs/namespace.c b/fs/namespace.c
index 228d8c4..72f20a6 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1963,6 +1963,21 @@ dput_out:
 	return retval;
 }
 
+static struct mnt_namespace *alloc_mnt_ns(void)
+{
+	struct mnt_namespace *new_ns;
+
+	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
+	if (!new_ns)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&new_ns->count, 1);
+	new_ns->root = NULL;
+	INIT_LIST_HEAD(&new_ns->list);
+	init_waitqueue_head(&new_ns->poll);
+	new_ns->event = 0;
+	return new_ns;
+}
+
 /*
  * Allocate a new namespace structure and populate it with contents
  * copied from the namespace of the passed in task structure.
@@ -1974,14 +1989,9 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
 	struct vfsmount *rootmnt = NULL, *pwdmnt = NULL;
 	struct vfsmount *p, *q;
 
-	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
-	if (!new_ns)
-		return ERR_PTR(-ENOMEM);
-
-	atomic_set(&new_ns->count, 1);
-	INIT_LIST_HEAD(&new_ns->list);
-	init_waitqueue_head(&new_ns->poll);
-	new_ns->event = 0;
+	new_ns = alloc_mnt_ns();
+	if (IS_ERR(new_ns))
+		return new_ns;
 
 	down_write(&namespace_sem);
 	/* First pass: copy the tree topology */
@@ -2045,6 +2055,36 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
 	return new_ns;
 }
 
+struct mnt_namespace *create_private_mnt_ns(struct vfsmount *mnt_root,
+		struct fs_struct *fs)
+{
+	struct mnt_namespace *new_ns;
+
+	new_ns = alloc_mnt_ns();
+	if (IS_ERR(new_ns))
+		return new_ns;
+
+	/* We're starting a completely fresh namespace, so we shouldn't need
+	 * to lock
+	 */
+	mnt_root->mnt_ns = new_ns;
+	new_ns->root = mnt_root;
+	list_add(&new_ns->list, &new_ns->root->mnt_list);
+
+	/* Also assume that the fs_struct is private, hence no locks... */
+	if (fs) {
+		dput(fs->pwd.dentry);
+		mntput(fs->pwd.mnt);
+		dput(fs->root.dentry);
+		mntput(fs->root.mnt);
+		fs->root.mnt = mntget(new_ns->root);
+		fs->root.dentry = dget(new_ns->root->mnt_root);
+		fs->pwd.mnt = mntget(new_ns->root);
+		fs->pwd.dentry = dget(new_ns->root->mnt_root);
+	}
+	return new_ns;
+}
+
 SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 		char __user *, type, unsigned long, flags, void __user *, data)
 {
diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
index 830bbcd..e81c076 100644
--- a/include/linux/mnt_namespace.h
+++ b/include/linux/mnt_namespace.h
@@ -22,6 +22,8 @@ struct proc_mounts {
 	int event;
 };
 
+extern struct mnt_namespace *create_private_mnt_ns(struct vfsmount *,
+		struct fs_struct *);
 extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
 		struct fs_struct *);
 extern void __put_mnt_ns(struct mnt_namespace *ns);
diff --git a/include/linux/namei.h b/include/linux/namei.h
index fc2e035..b9c0d1e 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -68,6 +68,8 @@ extern int kern_path(const char *, unsigned, struct path *);
 extern int path_lookup(const char *, unsigned, struct nameidata *);
 extern int vfs_path_lookup(struct dentry *, struct vfsmount *,
 			   const char *, unsigned int, struct nameidata *);
+extern int vfs_remote_path_lookup(struct dentry *, struct vfsmount *,
+		const char *, unsigned int , struct nameidata *);
 
 extern int path_lookup_open(int dfd, const char *name, unsigned lookup_flags, struct nameidata *, int open_flags);
 extern struct file *lookup_instantiate_filp(struct nameidata *nd, struct dentry *dentry,
diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index afad7de..3c12b79 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -67,6 +67,7 @@ void switch_task_namespaces(struct task_struct *tsk, struct nsproxy *new);
 void free_nsproxy(struct nsproxy *ns);
 int unshare_nsproxy_namespaces(unsigned long, struct nsproxy **,
 	struct fs_struct *);
+struct nsproxy *unshare_current_nsproxy(void);
 
 static inline void put_nsproxy(struct nsproxy *ns)
 {
diff --git a/kernel/nsproxy.c b/kernel/nsproxy.c
index 63598dc..05ea102 100644
--- a/kernel/nsproxy.c
+++ b/kernel/nsproxy.c
@@ -169,6 +169,17 @@ void free_nsproxy(struct nsproxy *ns)
 }
 
 /*
+ * Unshare just the current->nsproxy itself.
+ */
+struct nsproxy *unshare_current_nsproxy(void)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	return create_new_namespaces(0, current, current->fs);
+}
+
+/*
  * Called from unshare. Unshare all the namespaces part of nsproxy.
  * On success, returns the new nsproxy.
  */

