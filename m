Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56060 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757760AbdEVQX2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:28 -0400
Subject: [PATCH 7/9] Make fsopen() able to initiate mounting into a container
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:23:24 +0100
Message-ID: <149547020471.10599.11508819428565274044.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it possible for fsopen() to mount into a specified container, using
the namespaces associated with that container to cover UID translation,
networking and filesystem content.  This involves modifying the fsopen()
syscall to use the reserved parameter:

	int mfd = fsopen(const char *fsname, int containerfd,
			 int open_flags);

where containerfd can be -1 to use the current process's namespaces (as
before) or a file descriptor created by container_create() to mount into
that container.

For example:

	containerfd = container_create("fred", CONTAINER_NEW_FS_NS);

	mfd = fsopen("nfs4", containerfd, 0);
	write(mfd, "d warthog:/data", ...);
	write(mfd, "o fsc", ...);
	write(mfd, "o sync", ...);
	write(mfd, "o intr", ...);
	write(mfd, "o vers=4.2", ...);
	write(mfd, "o addr=192.168.1.1", ...);
	write(mfd, "o clientaddr=192.168.1.2", ...);
	fsmount(mfd, container_fd, "/mnt", AT_NO_FOLLOW, 0);

Any upcalls the mount makes, say to access DNS services, will be made
inside the container.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fsopen.c               |   33 ++++++++++++++++++++++++++-------
 fs/libfs.c                |    3 ++-
 fs/namespace.c            |   23 ++++++++++++++++-------
 fs/nfs/namespace.c        |    2 +-
 fs/nfs/nfs4namespace.c    |    4 ++--
 fs/proc/root.c            |   13 ++++++++++---
 fs/sb_config.c            |   29 ++++++++++++++++++++++-------
 include/linux/container.h |    1 +
 include/linux/mount.h     |    2 +-
 include/linux/pid.h       |    5 ++++-
 include/linux/proc_ns.h   |    3 ++-
 include/linux/sb_config.h |    5 ++++-
 kernel/container.c        |    4 ++++
 kernel/fork.c             |    2 +-
 kernel/pid.c              |    4 ++--
 15 files changed, 98 insertions(+), 35 deletions(-)

diff --git a/fs/fsopen.c b/fs/fsopen.c
index cbede77158ba..65278b7f5a45 100644
--- a/fs/fsopen.c
+++ b/fs/fsopen.c
@@ -13,6 +13,8 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
+#include <linux/fs.h>
+#include <linux/container.h>
 #include <linux/file.h>
 #include <linux/magic.h>
 #include <linux/syscalls.h>
@@ -219,30 +221,44 @@ fs_initcall(init_fs_fs);
  * opened, thereby indicating which namespaces will be used (notably, which
  * network namespace will be used for network filesystems).
  */
-SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
+SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, containerfd,
 		unsigned int, flags)
 {
+	struct container *container = NULL;
 	struct sb_config *sc;
 	struct file *file;
 	const char *fs_name;
 	int fd, ret;
 
-	if (flags & ~O_CLOEXEC || reserved != -1)
+	if (flags & ~O_CLOEXEC)
 		return -EINVAL;
 
 	fs_name = strndup_user(_fs_name, PAGE_SIZE);
 	if (IS_ERR(fs_name))
 		return PTR_ERR(fs_name);
 
-	sc = vfs_new_sb_config(fs_name);
+	if (containerfd != -1) {
+		struct fd f = fdget(containerfd);
+
+		ret = -EBADF;
+		if (!f.file)
+			goto err_fs_name;
+		ret = -EINVAL;
+		if (is_container_file(f.file)) {
+			container = get_container(f.file->private_data);
+			ret = 0;
+		}
+		fdput(f);
+		if (ret < 0)
+			goto err_fs_name;
+	}
+
+	sc = vfs_new_sb_config(fs_name, container);
 	kfree(fs_name);
+	put_container(container);
 	if (IS_ERR(sc))
 		return PTR_ERR(sc);
 
-	ret = -ENOTSUPP;
-	if (!sc->ops)
-		goto err_sc;
-
 	file = create_fs_file(sc);
 	if (IS_ERR(file)) {
 		ret = PTR_ERR(file);
@@ -264,4 +280,7 @@ SYSCALL_DEFINE3(fsopen, const char __user *, _fs_name, int, reserved,
 err_sc:
 	put_sb_config(sc);
 	return ret;
+err_fs_name:
+	kfree(fs_name);
+	return ret;
 }
diff --git a/fs/libfs.c b/fs/libfs.c
index e8787adf0363..d59dae7a9bd0 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -583,7 +583,8 @@ int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *c
 	if (unlikely(!*mount)) {
 		spin_unlock(&pin_fs_lock);
 
-		sc = __vfs_new_sb_config(type, NULL, MS_KERNMOUNT, SB_CONFIG_FOR_NEW);
+		sc = __vfs_new_sb_config(type, NULL, NULL, MS_KERNMOUNT,
+					 SB_CONFIG_FOR_NEW);
 		if (IS_ERR(sc))
 			return PTR_ERR(sc);
 
diff --git a/fs/namespace.c b/fs/namespace.c
index 7e2d5fe5728b..9ca8b9f49f80 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -783,9 +783,16 @@ static void put_mountpoint(struct mountpoint *mp)
 	}
 }
 
+static inline int __check_mnt(struct mount *mnt, struct mnt_namespace *mnt_ns)
+{
+	if (!mnt_ns)
+		mnt_ns = current->nsproxy->mnt_ns;
+	return mnt->mnt_ns == mnt_ns;
+}
+
 static inline int check_mnt(struct mount *mnt)
 {
-	return mnt->mnt_ns == current->nsproxy->mnt_ns;
+	return __check_mnt(mnt, NULL);
 }
 
 /*
@@ -2408,7 +2415,8 @@ static int do_move_mount(struct path *path, const char *old_name)
 /*
  * add a mount into a namespace's mount tree
  */
-static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
+static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags,
+			struct mnt_namespace *mnt_ns)
 {
 	struct mountpoint *mp;
 	struct mount *parent;
@@ -2422,7 +2430,7 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 
 	parent = real_mount(path->mnt);
 	err = -EINVAL;
-	if (unlikely(!check_mnt(parent))) {
+	if (unlikely(!__check_mnt(parent, mnt_ns))) {
 		/* that's acceptable only for automounts done in private ns */
 		if (!(mnt_flags & MNT_SHRINKABLE))
 			goto unlock;
@@ -2471,7 +2479,8 @@ static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
 		goto err_mnt;
 	}
 
-	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags,
+			   sc->container ? sc->container->ns->mnt_ns : NULL);
 	if (ret < 0) {
 		errorf("VFS: Failed to add mount");
 		goto err_mnt;
@@ -2496,7 +2505,7 @@ static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 	if (!fstype)
 		return -EINVAL;
 
-	sc = vfs_new_sb_config(fstype);
+	sc = vfs_new_sb_config(fstype, NULL);
 	if (IS_ERR(sc)) {
 		err = PTR_ERR(sc);
 		goto err;
@@ -2544,7 +2553,7 @@ int finish_automount(struct vfsmount *m, struct path *path)
 		goto fail;
 	}
 
-	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE);
+	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE, NULL);
 	if (!err)
 		return 0;
 fail:
@@ -3175,7 +3184,7 @@ struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 	if (!type)
 		return ERR_PTR(-EINVAL);
 
-	sc = __vfs_new_sb_config(type, NULL, flags, SB_CONFIG_FOR_NEW);
+	sc = __vfs_new_sb_config(type, NULL, NULL, flags, SB_CONFIG_FOR_NEW);
 	if (IS_ERR(sc))
 		return ERR_CAST(sc);
 
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index e95e669e4db8..2dcb0c3b4cbb 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -239,7 +239,7 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 	/* Open a new mount context, transferring parameters from the parent
 	 * superblock, including the network namespace.
 	 */
-	sc = __vfs_new_sb_config(&nfs_fs_type, dentry->d_sb, 0,
+	sc = __vfs_new_sb_config(&nfs_fs_type, dentry->d_sb, NULL, 0,
 				 SB_CONFIG_FOR_SUBMOUNT);
 	if (IS_ERR(sc))
 		return ERR_CAST(sc);
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 60b711aa0618..5e49684faf79 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -346,8 +346,8 @@ static struct vfsmount *nfs_follow_referral(struct dentry *dentry,
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;
-
-	sc = __vfs_new_sb_config(&nfs4_fs_type, dentry->d_sb, 0,
+ 
+	sc = __vfs_new_sb_config(&nfs4_fs_type, dentry->d_sb, NULL, 0,
 				 SB_CONFIG_FOR_SUBMOUNT);
 	if (IS_ERR(sc)) {
 		mnt = ERR_CAST(sc);
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 9878b62e874c..70e52b060873 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -17,6 +17,7 @@
 #include <linux/sched/stat.h>
 #include <linux/module.h>
 #include <linux/bitops.h>
+#include <linux/container.h>
 #include <linux/user_namespace.h>
 #include <linux/sb_config.h>
 #include <linux/pid_namespace.h>
@@ -171,8 +172,14 @@ static const struct sb_config_operations proc_sb_config_ops = {
 static int proc_init_sb_config(struct sb_config *sc, struct super_block *src_sb)
 {
 	struct proc_sb_config *cfg = container_of(sc, struct proc_sb_config, sc);
+	struct pid_namespace *pid_ns;
 
-	cfg->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	if (cfg->sc.container)
+		pid_ns = cfg->sc.container->pid_ns;
+	else
+		pid_ns = task_active_pid_ns(current);
+
+	cfg->pid_ns = get_pid_ns(pid_ns);
 	cfg->sc.ops = &proc_sb_config_ops;
 	return 0;
 }
@@ -292,14 +299,14 @@ struct proc_dir_entry proc_root = {
 	.name		= "/proc",
 };
 
-int pid_ns_prepare_proc(struct pid_namespace *ns)
+int pid_ns_prepare_proc(struct pid_namespace *ns, struct container *container)
 {
 	struct proc_sb_config *cfg;
 	struct sb_config *sc;
 	struct vfsmount *mnt;
 	int ret;
 
-	sc = __vfs_new_sb_config(&proc_fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	sc = __vfs_new_sb_config(&proc_fs_type, NULL, container, 0, SB_CONFIG_FOR_NEW);
 	if (IS_ERR(sc))
 		return PTR_ERR(sc);
 
diff --git a/fs/sb_config.c b/fs/sb_config.c
index 4d9bfb982d41..c1ea2a98bd8d 100644
--- a/fs/sb_config.c
+++ b/fs/sb_config.c
@@ -19,6 +19,7 @@
 #include <linux/magic.h>
 #include <linux/security.h>
 #include <linux/parser.h>
+#include <linux/container.h>
 #include <linux/mnt_namespace.h>
 #include <linux/pid_namespace.h>
 #include <linux/user_namespace.h>
@@ -108,7 +109,7 @@ static int vfs_parse_ms_mount_option(struct sb_config *sc, char *data)
 
 /**
  * vfs_parse_mount_option - Add a single mount option to a superblock config
- * @mc: The superblock configuration to modify
+ * @sc: The superblock configuration to modify
  * @p: The option to apply.
  *
  * A single mount option in string form is applied to the superblock
@@ -148,7 +149,7 @@ EXPORT_SYMBOL(vfs_parse_mount_option);
 
 /**
  * generic_monolithic_mount_data - Parse key[=val][,key[=val]]* mount data
- * @mc: The superblock configuration to fill in.
+ * @sc: The superblock configuration to fill in.
  * @data: The data to parse
  *
  * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
@@ -181,6 +182,7 @@ EXPORT_SYMBOL(generic_monolithic_mount_data);
  * __vfs_new_sb_config - Create a superblock config.
  * @fs_type: The filesystem type.
  * @src_sb: A superblock from which this one derives (or NULL)
+ * @c: The container that will be opened in (or NULL)
  * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
  * @purpose: The purpose that this configuration shall be used for.
  *
@@ -191,6 +193,7 @@ EXPORT_SYMBOL(generic_monolithic_mount_data);
  */
 struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 				      struct super_block *src_sb,
+				      struct container *c,
 				      unsigned int ms_flags,
 				      enum sb_config_purpose purpose)
 {
@@ -210,10 +213,17 @@ struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 	sc->purpose	= purpose;
 	sc->ms_flags	= ms_flags;
 	sc->fs_type	= get_filesystem(fs_type);
-	sc->net_ns	= get_net(current->nsproxy->net_ns);
-	sc->user_ns	= get_user_ns(current_user_ns());
 	sc->cred	= get_current_cred();
 
+	if (!c) {
+		sc->net_ns = get_net(current->nsproxy->net_ns);
+		sc->user_ns = get_user_ns(current_user_ns());
+	} else {
+		sc->container = get_container(c);
+		sc->net_ns = get_net(c->ns->net_ns);
+		sc->user_ns = get_user_ns(c->cred->user_ns);
+	}
+
 	/* TODO: Make all filesystems support this unconditionally */
 	if (sc->fs_type->init_sb_config) {
 		ret = sc->fs_type->init_sb_config(sc, src_sb);
@@ -241,6 +251,7 @@ EXPORT_SYMBOL(__vfs_new_sb_config);
 /**
  * vfs_new_sb_config - Create a superblock config for a new mount.
  * @fs_name: The name of the filesystem
+ * @container: The container to create in (or NULL)
  *
  * Open a filesystem and create a superblock config context for a new mount
  * that will hold the mount options, device name, security details, etc..  Note
@@ -248,7 +259,8 @@ EXPORT_SYMBOL(__vfs_new_sb_config);
  * determine whether the filesystem actually supports the superblock context
  * itself.
  */
-struct sb_config *vfs_new_sb_config(const char *fs_name)
+struct sb_config *vfs_new_sb_config(const char *fs_name,
+				    struct container *c)
 {
 	struct file_system_type *fs_type;
 	struct sb_config *sc;
@@ -257,7 +269,7 @@ struct sb_config *vfs_new_sb_config(const char *fs_name)
 	if (!fs_type)
 		return ERR_PTR(-ENODEV);
 
-	sc = __vfs_new_sb_config(fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	sc = __vfs_new_sb_config(fs_type, NULL, c, 0, SB_CONFIG_FOR_NEW);
 	put_filesystem(fs_type);
 	return sc;
 }
@@ -275,7 +287,7 @@ struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
 				  unsigned int ms_flags)
 {
 	return __vfs_new_sb_config(mnt->mnt_sb->s_type, mnt->mnt_sb,
-				   ms_flags, SB_CONFIG_FOR_REMOUNT);
+				   NULL, ms_flags, SB_CONFIG_FOR_REMOUNT);
 }
 
 /**
@@ -302,6 +314,8 @@ struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc)
 	sc->device	= NULL;
 	sc->security	= NULL;
 	get_filesystem(sc->fs_type);
+	if (sc->container)
+		get_container(sc->container);
 	get_net(sc->net_ns);
 	get_user_ns(sc->user_ns);
 	get_cred(sc->cred);
@@ -347,6 +361,7 @@ void put_sb_config(struct sb_config *sc)
 	if (sc->cred)
 		put_cred(sc->cred);
 	kfree(sc->subtype);
+	put_container(sc->container);
 	put_filesystem(sc->fs_type);
 	kfree(sc->device);
 	kfree(sc);
diff --git a/include/linux/container.h b/include/linux/container.h
index 084ea9982fe6..073674fab160 100644
--- a/include/linux/container.h
+++ b/include/linux/container.h
@@ -36,6 +36,7 @@ struct container {
 	struct path		root;		/* The root of the container's fs namespace */
 	struct task_struct	*init;		/* The 'init' task for this container */
 	struct container	*parent;	/* Parent of this container. */
+	struct pid_namespace	*pid_ns;	/* The process ID namespace for this container */
 	void			*security;	/* LSM data */
 	struct list_head	members;	/* Member processes, guarded with ->lock */
 	struct list_head	child_link;	/* Link in parent->children */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index a5dca6abc4d5..265e9aa2ab0b 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -70,7 +70,7 @@ struct vfsmount {
 	int mnt_flags;
 };
 
-struct file; /* forward dec */
+ struct file; /* forward dec */
 struct path;
 
 extern int mnt_want_write(struct vfsmount *mnt);
diff --git a/include/linux/pid.h b/include/linux/pid.h
index 4d179316e431..ac429dea2f84 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -79,6 +79,8 @@ static inline struct pid *get_pid(struct pid *pid)
 	return pid;
 }
 
+struct container;
+
 extern void put_pid(struct pid *pid);
 extern struct task_struct *pid_task(struct pid *pid, enum pid_type);
 extern struct task_struct *get_pid_task(struct pid *pid, enum pid_type);
@@ -117,7 +119,8 @@ extern struct pid *find_get_pid(int nr);
 extern struct pid *find_ge_pid(int nr, struct pid_namespace *);
 int next_pidmap(struct pid_namespace *pid_ns, unsigned int last);
 
-extern struct pid *alloc_pid(struct pid_namespace *ns);
+extern struct pid *alloc_pid(struct pid_namespace *ns,
+			     struct container *container);
 extern void free_pid(struct pid *pid);
 extern void disable_pid_allocation(struct pid_namespace *ns);
 
diff --git a/include/linux/proc_ns.h b/include/linux/proc_ns.h
index 58ab28d81fc2..52f0b2db5dda 100644
--- a/include/linux/proc_ns.h
+++ b/include/linux/proc_ns.h
@@ -46,7 +46,8 @@ enum {
 
 #ifdef CONFIG_PROC_FS
 
-extern int pid_ns_prepare_proc(struct pid_namespace *ns);
+extern int pid_ns_prepare_proc(struct pid_namespace *ns,
+			       struct container *container);
 extern void pid_ns_release_proc(struct pid_namespace *ns);
 extern int proc_alloc_inum(unsigned int *pino);
 extern void proc_free_inum(unsigned int inum);
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
index 144258d82fa1..8bc7ac70b11a 100644
--- a/include/linux/sb_config.h
+++ b/include/linux/sb_config.h
@@ -46,6 +46,7 @@ enum sb_config_purpose {
 struct sb_config {
 	const struct sb_config_operations *ops;
 	struct file_system_type	*fs_type;
+	struct container	*container;	/* The container in which the mount will exist */
 	struct dentry		*root;		/* The root and superblock */
 	struct user_namespace	*user_ns;	/* The user namespace for this mount */
 	struct net		*net_ns;	/* The network namespace for this mount */
@@ -69,9 +70,11 @@ struct sb_config_operations {
 	int (*get_tree)(struct sb_config *sc);
 };
 
-extern struct sb_config *vfs_new_sb_config(const char *fs_name);
+extern struct sb_config *vfs_new_sb_config(const char *fs_name,
+					   struct container *c);
 extern struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
 					     struct super_block *src_sb,
+					     struct container *c,
 					     unsigned int ms_flags,
 					     enum sb_config_purpose purpose);
 extern struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
diff --git a/kernel/container.c b/kernel/container.c
index d5849c07a76b..5ebbf548f01a 100644
--- a/kernel/container.c
+++ b/kernel/container.c
@@ -31,6 +31,7 @@ struct container init_container = {
 	.cred		= &init_cred,
 	.ns		= &init_nsproxy,
 	.init		= &init_task,
+	.pid_ns		= &init_pid_ns,
 	.members.next	= &init_task.container_link,
 	.members.prev	= &init_task.container_link,
 	.children	= LIST_HEAD_INIT(init_container.children),
@@ -52,6 +53,8 @@ void put_container(struct container *c)
 
 	while (c && refcount_dec_and_test(&c->usage)) {
 		BUG_ON(!list_empty(&c->members));
+		if (c->pid_ns)
+			put_pid_ns(c->pid_ns);
 		if (c->ns)
 			put_nsproxy(c->ns);
 		path_put(&c->root);
@@ -491,6 +494,7 @@ static struct container *create_container(const char *name, unsigned int flags)
 	}
 
 	c->ns = ns;
+	c->pid_ns = get_pid_ns(c->ns->pid_ns_for_children);
 	c->root = fs->root;
 	c->seq = fs->seq;
 	fs->root.mnt = NULL;
diff --git a/kernel/fork.c b/kernel/fork.c
index d185c13820d7..68cd7367fcd5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1764,7 +1764,7 @@ static __latent_entropy struct task_struct *copy_process(
 		goto bad_fork_cleanup_io;
 
 	if (pid != &init_struct_pid) {
-		pid = alloc_pid(p->nsproxy->pid_ns_for_children);
+		pid = alloc_pid(p->nsproxy->pid_ns_for_children, container);
 		if (IS_ERR(pid)) {
 			retval = PTR_ERR(pid);
 			goto bad_fork_cleanup_thread;
diff --git a/kernel/pid.c b/kernel/pid.c
index fd1cde1e4576..adc65cdc2613 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -293,7 +293,7 @@ void free_pid(struct pid *pid)
 	call_rcu(&pid->rcu, delayed_put_pid);
 }
 
-struct pid *alloc_pid(struct pid_namespace *ns)
+struct pid *alloc_pid(struct pid_namespace *ns, struct container *container)
 {
 	struct pid *pid;
 	enum pid_type type;
@@ -321,7 +321,7 @@ struct pid *alloc_pid(struct pid_namespace *ns)
 	}
 
 	if (unlikely(is_child_reaper(pid))) {
-		if (pid_ns_prepare_proc(ns)) {
+		if (pid_ns_prepare_proc(ns, container)) {
 			disable_pid_allocation(ns);
 			goto out_free;
 		}

