Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8477 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751829AbdFNPTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:19:35 -0400
Subject: [PATCH 27/27] kernfs, sysfs, cgroup: Support fs_context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org
Date: Wed, 14 Jun 2017 16:19:19 +0100
Message-ID: <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make kernfs support superblock creation/mount/remount with fs_context.

This requires that sysfs and cgroup, which are built on kernfs, be made to
support fs_context also.

Notes:

 (1) A kernfs_fs_context struct is created to wrap fs_context and the
     kernfs mount parameters are moved in here (or are in fs_context).

 (2) kernfs_mount{,_ns}() are made into kernfs_get_tree().  The extra
     namespace tag parameter is passed in the context if desired

 (3) kernfs_free_fs_context() is provided as a destructor for the
     kernfs_fs_context struct, but for the moment it does nothing except
     get called in the right places.

 (4) sysfs doesn't wrap kernfs_fs_context since it has no parameters to
     pass, but possibly this should be done anyway in case someone wants to
     add a parameter in future.

 (5) A cgroup_fs_context struct is created to wrap kernfs_fs_context and
     the cgroup v1 and v2 mount parameters are all moved there.

 (6) cgroup1 parameter parsing error messages are now handled by invalf(),
     which allows userspace to collect them directly.

 (7) cgroup1 parameter cleanup is now done in the context destructor rather
     than in the mount/get_tree and remount functions.

Weirdies:

 (*) cgroup_do_get_tree() calls cset_cgroup_from_root() with locks held,
     but then uses the resulting pointer after dropping the locks.  I'm
     told this is okay and needs commenting.

 (*) The cgroup refcount web.  This really needs documenting.

 (*) cgroup2 only has one root?

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
cc: Tejun Heo <tj@kernel.org>
cc: Li Zefan <lizefan@huawei.com>
cc: Johannes Weiner <hannes@cmpxchg.org>
cc: cgroups@vger.kernel.org
---

 fs/kernfs/mount.c               |   88 ++++++------
 fs/sysfs/mount.c                |   59 +++++---
 include/linux/cgroup.h          |    3 
 include/linux/kernfs.h          |   37 +++--
 kernel/cgroup/cgroup-internal.h |   42 +++---
 kernel/cgroup/cgroup-v1.c       |  291 ++++++++++++++++++---------------------
 kernel/cgroup/cgroup.c          |  172 +++++++++++++++--------
 7 files changed, 383 insertions(+), 309 deletions(-)

diff --git a/fs/kernfs/mount.c b/fs/kernfs/mount.c
index f1e0b15015b7..4391e68e9cac 100644
--- a/fs/kernfs/mount.c
+++ b/fs/kernfs/mount.c
@@ -21,13 +21,14 @@
 
 struct kmem_cache *kernfs_node_cache;
 
-static int kernfs_sop_remount_fs(struct super_block *sb, int *flags, char *data)
+static int kernfs_sop_remount_fs(struct super_block *sb, struct fs_context *fc)
 {
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
 	struct kernfs_root *root = kernfs_info(sb)->root;
 	struct kernfs_syscall_ops *scops = root->syscall_ops;
 
 	if (scops && scops->remount_fs)
-		return scops->remount_fs(root, flags, data);
+		return scops->remount_fs(root, kfc);
 	return 0;
 }
 
@@ -59,7 +60,7 @@ const struct super_operations kernfs_sops = {
 	.drop_inode	= generic_delete_inode,
 	.evict_inode	= kernfs_evict_inode,
 
-	.remount_fs	= kernfs_sop_remount_fs,
+	.remount_fs_fc	= kernfs_sop_remount_fs,
 	.show_options	= kernfs_sop_show_options,
 	.show_path	= kernfs_sop_show_path,
 };
@@ -145,7 +146,7 @@ struct dentry *kernfs_node_dentry(struct kernfs_node *kn,
 	} while (true);
 }
 
-static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
+static int kernfs_fill_super(struct super_block *sb, struct kernfs_fs_context *kfc)
 {
 	struct kernfs_super_info *info = kernfs_info(sb);
 	struct inode *inode;
@@ -156,7 +157,7 @@ static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 	sb->s_iflags |= SB_I_NOEXEC | SB_I_NODEV;
 	sb->s_blocksize = PAGE_SIZE;
 	sb->s_blocksize_bits = PAGE_SHIFT;
-	sb->s_magic = magic;
+	sb->s_magic = kfc->magic;
 	sb->s_op = &kernfs_sops;
 	sb->s_xattr = kernfs_xattr_handlers;
 	sb->s_time_gran = 1;
@@ -183,20 +184,25 @@ static int kernfs_fill_super(struct super_block *sb, unsigned long magic)
 	return 0;
 }
 
-static int kernfs_test_super(struct super_block *sb, void *data)
+static int kernfs_test_super(struct super_block *sb, struct fs_context *fc)
 {
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
 	struct kernfs_super_info *sb_info = kernfs_info(sb);
-	struct kernfs_super_info *info = data;
+	struct kernfs_super_info *info = kfc->info;
 
 	return sb_info->root == info->root && sb_info->ns == info->ns;
 }
 
-static int kernfs_set_super(struct super_block *sb, void *data)
+static int kernfs_set_super(struct super_block *sb, struct fs_context *fc)
 {
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
 	int error;
-	error = set_anon_super(sb, data);
-	if (!error)
-		sb->s_fs_info = data;
+
+	error = set_anon_super(sb, kfc->info);
+	if (!error) {
+		sb->s_fs_info = kfc->info;
+		kfc->info = NULL;
+	}
 	return error;
 }
 
@@ -214,24 +220,15 @@ const void *kernfs_super_ns(struct super_block *sb)
 }
 
 /**
- * kernfs_mount_ns - kernfs mount helper
- * @fs_type: file_system_type of the fs being mounted
- * @flags: mount flags specified for the mount
- * @root: kernfs_root of the hierarchy being mounted
- * @magic: file system specific magic number
- * @new_sb_created: tell the caller if we allocated a new superblock
- * @ns: optional namespace tag of the mount
- *
- * This is to be called from each kernfs user's file_system_type->mount()
- * implementation, which should pass through the specified @fs_type and
- * @flags, and specify the hierarchy and namespace tag to mount via @root
- * and @ns, respectively.
+ * kernfs_get_tree - kernfs filesystem access/retrieval helper
+ * @kfc: The filesystem context.
  *
- * The return value can be passed to the vfs layer verbatim.
+ * This is to be called from each kernfs user's fs_context->ops->get_tree()
+ * implementation, which should set the specified ->@fs_type and ->@flags, and
+ * specify the hierarchy and namespace tag to mount via ->@root and ->@ns,
+ * respectively.
  */
-struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-				struct kernfs_root *root, unsigned long magic,
-				bool *new_sb_created, const void *ns)
+int kernfs_get_tree(struct kernfs_fs_context *kfc)
 {
 	struct super_block *sb;
 	struct kernfs_super_info *info;
@@ -239,37 +236,42 @@ struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info)
-		return ERR_PTR(-ENOMEM);
-
-	info->root = root;
-	info->ns = ns;
+		return -ENOMEM;
 
-	sb = sget_userns(fs_type, kernfs_test_super, kernfs_set_super, flags,
-			 &init_user_ns, info);
-	if (IS_ERR(sb) || sb->s_fs_info != info)
-		kfree(info);
+	info->root = kfc->root;
+	info->ns = kfc->ns_tag;
+
+	kfc->info = info;
+	sb = sget_fc(&kfc->fc, kernfs_test_super, kernfs_set_super);
+	if (kfc->info) {
+		kfree(kfc->info);
+		kfc->info = NULL;
+	} else {
+		kfc->ns_tag = NULL;
+		kfc->fc.degraded = true;
+	}
 	if (IS_ERR(sb))
-		return ERR_CAST(sb);
-
-	if (new_sb_created)
-		*new_sb_created = !sb->s_root;
+		return PTR_ERR(sb);
 
 	if (!sb->s_root) {
 		struct kernfs_super_info *info = kernfs_info(sb);
 
-		error = kernfs_fill_super(sb, magic);
+		kfc->new_sb_created = true;
+
+		error = kernfs_fill_super(sb, kfc);
 		if (error) {
 			deactivate_locked_super(sb);
-			return ERR_PTR(error);
+			return error;
 		}
 		sb->s_flags |= SB_ACTIVE;
 
 		mutex_lock(&kernfs_mutex);
-		list_add(&info->node, &root->supers);
+		list_add(&info->node, &info->root->supers);
 		mutex_unlock(&kernfs_mutex);
 	}
 
-	return dget(sb->s_root);
+	kfc->fc.root = dget(sb->s_root);
+	return 0;
 }
 
 /**
diff --git a/fs/sysfs/mount.c b/fs/sysfs/mount.c
index fb49510c5dcf..cfe900d43663 100644
--- a/fs/sysfs/mount.c
+++ b/fs/sysfs/mount.c
@@ -23,27 +23,45 @@
 static struct kernfs_root *sysfs_root;
 struct kernfs_node *sysfs_root_kn;
 
-static struct dentry *sysfs_mount(struct file_system_type *fs_type,
-	int flags, const char *dev_name, void *data)
+static int sysfs_get_tree(struct fs_context *fc)
 {
-	struct dentry *root;
-	void *ns;
-	bool new_sb;
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
+	int ret;
 
-	if (!(flags & SB_KERNMOUNT)) {
+	ret = kernfs_get_tree(kfc);
+	if (kfc->new_sb_created)
+		fc->root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE;
+	return 0;
+}
+
+static void sysfs_fs_context_free(struct fs_context *fc)
+{
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
+
+	if (kfc->ns_tag)
+		kobj_ns_drop(KOBJ_NS_TYPE_NET, kfc->ns_tag);
+	kernfs_free_fs_context(kfc);
+}
+
+static const struct fs_context_operations sysfs_fs_context_ops = {
+	.free		= sysfs_fs_context_free,
+	.get_tree	= sysfs_get_tree,
+};
+
+static int sysfs_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct kernfs_fs_context *kfc = container_of(fc, struct kernfs_fs_context, fc);
+
+	if (!(fc->sb_flags & SB_KERNMOUNT)) {
 		if (!kobj_ns_current_may_mount(KOBJ_NS_TYPE_NET))
-			return ERR_PTR(-EPERM);
+			return -EPERM;
 	}
 
-	ns = kobj_ns_grab_current(KOBJ_NS_TYPE_NET);
-	root = kernfs_mount_ns(fs_type, flags, sysfs_root,
-				SYSFS_MAGIC, &new_sb, ns);
-	if (IS_ERR(root) || !new_sb)
-		kobj_ns_drop(KOBJ_NS_TYPE_NET, ns);
-	else if (new_sb)
-		root->d_sb->s_iflags |= SB_I_USERNS_VISIBLE;
-
-	return root;
+	kfc->ns_tag = kobj_ns_grab_current(KOBJ_NS_TYPE_NET);
+	kfc->root = sysfs_root;
+	kfc->magic = SYSFS_MAGIC;
+	kfc->fc.ops = &sysfs_fs_context_ops;
+	return 0;
 }
 
 static void sysfs_kill_sb(struct super_block *sb)
@@ -55,10 +73,11 @@ static void sysfs_kill_sb(struct super_block *sb)
 }
 
 static struct file_system_type sysfs_fs_type = {
-	.name		= "sysfs",
-	.mount		= sysfs_mount,
-	.kill_sb	= sysfs_kill_sb,
-	.fs_flags	= FS_USERNS_MOUNT,
+	.name			= "sysfs",
+	.fs_context_size	= sizeof(struct kernfs_fs_context),
+	.init_fs_context	= sysfs_init_fs_context,
+	.kill_sb		= sysfs_kill_sb,
+	.fs_flags		= FS_USERNS_MOUNT,
 };
 
 int __init sysfs_init(void)
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 710a005c6b7a..d5b5d9ae373c 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -713,10 +713,11 @@ copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
 
 #endif /* !CONFIG_CGROUPS */
 
-static inline void get_cgroup_ns(struct cgroup_namespace *ns)
+static inline struct cgroup_namespace *get_cgroup_ns(struct cgroup_namespace *ns)
 {
 	if (ns)
 		refcount_inc(&ns->count);
+	return ns;
 }
 
 static inline void put_cgroup_ns(struct cgroup_namespace *ns)
diff --git a/include/linux/kernfs.h b/include/linux/kernfs.h
index a9b11b8d06f2..c137eef5b31f 100644
--- a/include/linux/kernfs.h
+++ b/include/linux/kernfs.h
@@ -16,6 +16,7 @@
 #include <linux/rbtree.h>
 #include <linux/atomic.h>
 #include <linux/wait.h>
+#include <linux/fs_context.h>
 
 struct file;
 struct dentry;
@@ -25,6 +26,7 @@ struct vm_area_struct;
 struct super_block;
 struct file_system_type;
 
+struct kernfs_fs_context;
 struct kernfs_open_node;
 struct kernfs_iattrs;
 
@@ -145,7 +147,7 @@ struct kernfs_node {
  * kernfs_node parameter.
  */
 struct kernfs_syscall_ops {
-	int (*remount_fs)(struct kernfs_root *root, int *flags, char *data);
+	int (*remount_fs)(struct kernfs_root *root, struct kernfs_fs_context *kfc);
 	int (*show_options)(struct seq_file *sf, struct kernfs_root *root);
 
 	int (*mkdir)(struct kernfs_node *parent, const char *name,
@@ -245,6 +247,20 @@ struct kernfs_ops {
 #endif
 };
 
+/*
+ * The kernfs superblock creation/mount parameter context.
+ */
+struct kernfs_fs_context {
+	struct fs_context	fc;
+	struct kernfs_root	*root;		/* Root of the hierarchy being mounted */
+	void			*ns_tag;	/* Namespace tag of the mount (or NULL) */
+	unsigned long		magic;		/* File system specific magic number */
+
+	/* The following are set/used by kernfs_mount() */
+	struct kernfs_super_info *info;		/* The new superblock info */
+	bool			new_sb_created;	/* Set to T if we allocated a new sb */
+};
+
 #ifdef CONFIG_KERNFS
 
 static inline enum kernfs_node_type kernfs_type(struct kernfs_node *kn)
@@ -328,9 +344,7 @@ int kernfs_setattr(struct kernfs_node *kn, const struct iattr *iattr);
 void kernfs_notify(struct kernfs_node *kn);
 
 const void *kernfs_super_ns(struct super_block *sb);
-struct dentry *kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-			       struct kernfs_root *root, unsigned long magic,
-			       bool *new_sb_created, const void *ns);
+int kernfs_get_tree(struct kernfs_fs_context *fc);
 void kernfs_kill_sb(struct super_block *sb);
 struct super_block *kernfs_pin_sb(struct kernfs_root *root, const void *ns);
 
@@ -430,11 +444,8 @@ static inline void kernfs_notify(struct kernfs_node *kn) { }
 static inline const void *kernfs_super_ns(struct super_block *sb)
 { return NULL; }
 
-static inline struct dentry *
-kernfs_mount_ns(struct file_system_type *fs_type, int flags,
-		struct kernfs_root *root, unsigned long magic,
-		bool *new_sb_created, const void *ns)
-{ return ERR_PTR(-ENOSYS); }
+static inline int kernfs_get_tree(struct kernfs_fs_context *fc)
+{ return -ENOSYS; }
 
 static inline void kernfs_kill_sb(struct super_block *sb) { }
 
@@ -511,13 +522,9 @@ static inline int kernfs_rename(struct kernfs_node *kn,
 	return kernfs_rename_ns(kn, new_parent, new_name, NULL);
 }
 
-static inline struct dentry *
-kernfs_mount(struct file_system_type *fs_type, int flags,
-		struct kernfs_root *root, unsigned long magic,
-		bool *new_sb_created)
+static inline void kernfs_free_fs_context(struct kernfs_fs_context *kfc)
 {
-	return kernfs_mount_ns(fs_type, flags, root,
-				magic, new_sb_created, NULL);
+	/* Note that we don't deal with kfc->ns_tag here. */
 }
 
 #endif	/* __LINUX_KERNFS_H */
diff --git a/kernel/cgroup/cgroup-internal.h b/kernel/cgroup/cgroup-internal.h
index 00f4d6bf048f..a74e5f0d523a 100644
--- a/kernel/cgroup/cgroup-internal.h
+++ b/kernel/cgroup/cgroup-internal.h
@@ -8,6 +8,26 @@
 #include <linux/refcount.h>
 
 /*
+ * The cgroup filesystem superblock creation/mount context.
+ */
+struct cgroup_fs_context {
+	struct kernfs_fs_context kfc;
+	struct cgroup_root	*root;
+	struct cgroup_namespace	*ns;
+	u8		version;		/* cgroups version */
+
+	/* cgroup1 bits */
+	bool		cpuset_clone_children;
+	bool		none;			/* User explicitly requested empty subsystem */
+	bool		all_ss;			/* Seen 'all' option */
+	bool		one_ss;			/* Seen 'none' option */
+	u16		subsys_mask;		/* Selected subsystems */
+	unsigned int	flags;			/* CGRP_ROOT_* flags */
+	char		*name;			/* Hierarchy name */
+	char		*release_agent;		/* Path for release notifications */
+};
+
+/*
  * A cgroup can be associated with multiple css_sets as different tasks may
  * belong to different cgroups on different hierarchies.  In the other
  * direction, a css_set is naturally associated with multiple cgroups.
@@ -85,16 +105,6 @@ struct cgroup_mgctx {
 #define DEFINE_CGROUP_MGCTX(name)						\
 	struct cgroup_mgctx name = CGROUP_MGCTX_INIT(name)
 
-struct cgroup_sb_opts {
-	u16 subsys_mask;
-	unsigned int flags;
-	char *release_agent;
-	bool cpuset_clone_children;
-	char *name;
-	/* User explicitly requested empty subsystem */
-	bool none;
-};
-
 extern struct mutex cgroup_mutex;
 extern spinlock_t css_set_lock;
 extern struct cgroup_subsys *cgroup_subsys[];
@@ -163,12 +173,10 @@ int cgroup_path_ns_locked(struct cgroup *cgrp, char *buf, size_t buflen,
 			  struct cgroup_namespace *ns);
 
 void cgroup_free_root(struct cgroup_root *root);
-void init_cgroup_root(struct cgroup_root *root, struct cgroup_sb_opts *opts);
+void init_cgroup_root(struct cgroup_fs_context *ctx);
 int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask, int ref_flags);
 int rebind_subsystems(struct cgroup_root *dst_root, u16 ss_mask);
-struct dentry *cgroup_do_mount(struct file_system_type *fs_type, int flags,
-			       struct cgroup_root *root, unsigned long magic,
-			       struct cgroup_namespace *ns);
+int cgroup_do_get_tree(struct cgroup_fs_context *ctx);
 
 bool cgroup_may_migrate_to(struct cgroup *dst_cgrp);
 void cgroup_migrate_finish(struct cgroup_mgctx *mgctx);
@@ -208,8 +216,8 @@ bool cgroup1_ssid_disabled(int ssid);
 void cgroup1_pidlist_destroy_all(struct cgroup *cgrp);
 void cgroup1_release_agent(struct work_struct *work);
 void cgroup1_check_for_release(struct cgroup *cgrp);
-struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
-			     void *data, unsigned long magic,
-			     struct cgroup_namespace *ns);
+int cgroup1_parse_option(struct cgroup_fs_context *ctx, char *p);
+int cgroup1_validate(struct cgroup_fs_context *ctx);
+int cgroup1_get_tree(struct cgroup_fs_context *ctx);
 
 #endif /* __CGROUP_INTERNAL_H */
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index 85d75152402d..050d4a0e8e5a 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -864,164 +864,160 @@ static int cgroup1_show_options(struct seq_file *seq, struct kernfs_root *kf_roo
 	return 0;
 }
 
-static int parse_cgroupfs_options(char *data, struct cgroup_sb_opts *opts)
+int cgroup1_parse_option(struct cgroup_fs_context *ctx, char *token)
 {
-	char *token, *o = data;
-	bool all_ss = false, one_ss = false;
-	u16 mask = U16_MAX;
 	struct cgroup_subsys *ss;
-	int nr_opts = 0;
 	int i;
 
-#ifdef CONFIG_CPUSETS
-	mask = ~((u16)1 << cpuset_cgrp_id);
-#endif
-
-	memset(opts, 0, sizeof(*opts));
-
-	while ((token = strsep(&o, ",")) != NULL) {
-		nr_opts++;
+	if (!strcmp(token, "none")) {
+		/* Explicitly have no subsystems */
+		ctx->none = true;
+		return 0;
+	}
+	if (!strcmp(token, "all")) {
+		/* Mutually exclusive option 'all' + subsystem name */
+		if (ctx->one_ss)
+			return invalf("cgroup1: all conflicts with subsys name");
+		ctx->all_ss = true;
+		return 0;
+	}
+	if (!strcmp(token, "noprefix")) {
+		ctx->flags |= CGRP_ROOT_NOPREFIX;
+		return 0;
+	}
+	if (!strcmp(token, "clone_children")) {
+		ctx->cpuset_clone_children = true;
+		return 0;
+	}
+	if (!strcmp(token, "xattr")) {
+		ctx->flags |= CGRP_ROOT_XATTR;
+		return 0;
+	}
+	if (!strncmp(token, "release_agent=", 14)) {
+		/* Specifying two release agents is forbidden */
+		if (ctx->release_agent)
+			return invalf("cgroup1: release_agent respecified");
+		ctx->release_agent =
+			kstrndup(token + 14, PATH_MAX - 1, GFP_KERNEL);
+		if (!ctx->release_agent)
+			return -ENOMEM;
+		return 0;
+	}
 
-		if (!*token)
-			return -EINVAL;
-		if (!strcmp(token, "none")) {
-			/* Explicitly have no subsystems */
-			opts->none = true;
-			continue;
-		}
-		if (!strcmp(token, "all")) {
-			/* Mutually exclusive option 'all' + subsystem name */
-			if (one_ss)
-				return -EINVAL;
-			all_ss = true;
-			continue;
-		}
-		if (!strcmp(token, "noprefix")) {
-			opts->flags |= CGRP_ROOT_NOPREFIX;
-			continue;
+	if (!strncmp(token, "name=", 5)) {
+		const char *name = token + 5;
+		/* Can't specify an empty name */
+		if (!strlen(name))
+			return invalf("cgroup1: Empty name");
+		/* Must match [\w.-]+ */
+		for (i = 0; i < strlen(name); i++) {
+			char c = name[i];
+			if (isalnum(c))
+				continue;
+			if ((c == '.') || (c == '-') || (c == '_'))
+				continue;
+			return invalf("cgroup1: Invalid name");
 		}
-		if (!strcmp(token, "clone_children")) {
-			opts->cpuset_clone_children = true;
+		/* Specifying two names is forbidden */
+		if (ctx->name)
+			return invalf("cgroup1: name respecified");
+		ctx->name = kstrndup(name,
+				     MAX_CGROUP_ROOT_NAMELEN - 1,
+				     GFP_KERNEL);
+		if (!ctx->name)
+			return -ENOMEM;
+
+		return 0;
+	}
+
+	for_each_subsys(ss, i) {
+		if (strcmp(token, ss->legacy_name))
 			continue;
-		}
-		if (!strcmp(token, "xattr")) {
-			opts->flags |= CGRP_ROOT_XATTR;
+		if (!cgroup_ssid_enabled(i))
 			continue;
-		}
-		if (!strncmp(token, "release_agent=", 14)) {
-			/* Specifying two release agents is forbidden */
-			if (opts->release_agent)
-				return -EINVAL;
-			opts->release_agent =
-				kstrndup(token + 14, PATH_MAX - 1, GFP_KERNEL);
-			if (!opts->release_agent)
-				return -ENOMEM;
+		if (cgroup1_ssid_disabled(i))
 			continue;
-		}
-		if (!strncmp(token, "name=", 5)) {
-			const char *name = token + 5;
-			/* Can't specify an empty name */
-			if (!strlen(name))
-				return -EINVAL;
-			/* Must match [\w.-]+ */
-			for (i = 0; i < strlen(name); i++) {
-				char c = name[i];
-				if (isalnum(c))
-					continue;
-				if ((c == '.') || (c == '-') || (c == '_'))
-					continue;
-				return -EINVAL;
-			}
-			/* Specifying two names is forbidden */
-			if (opts->name)
-				return -EINVAL;
-			opts->name = kstrndup(name,
-					      MAX_CGROUP_ROOT_NAMELEN - 1,
-					      GFP_KERNEL);
-			if (!opts->name)
-				return -ENOMEM;
 
-			continue;
-		}
+		/* Mutually exclusive option 'all' + subsystem name */
+		if (ctx->all_ss)
+			return invalf("cgroup1: subsys name conflicts with all");
+		ctx->subsys_mask |= (1 << i);
+		ctx->one_ss = true;
+		return 0;
+	}
 
-		for_each_subsys(ss, i) {
-			if (strcmp(token, ss->legacy_name))
-				continue;
-			if (!cgroup_ssid_enabled(i))
-				continue;
-			if (cgroup1_ssid_disabled(i))
-				continue;
+	if (i == CGROUP_SUBSYS_COUNT)
+		return -ENOENT;
+
+	return 0;
+}
 
-			/* Mutually exclusive option 'all' + subsystem name */
-			if (all_ss)
-				return -EINVAL;
-			opts->subsys_mask |= (1 << i);
-			one_ss = true;
+/*
+ * Validate the options that have been parsed.
+ */
+int cgroup1_validate(struct cgroup_fs_context *ctx)
+{
+	struct cgroup_subsys *ss;
+	u16 mask = U16_MAX;
+	int i;
 
-			break;
-		}
-		if (i == CGROUP_SUBSYS_COUNT)
-			return -ENOENT;
-	}
+#ifdef CONFIG_CPUSETS
+	mask = ~((u16)1 << cpuset_cgrp_id);
+#endif
 
 	/*
 	 * If the 'all' option was specified select all the subsystems,
 	 * otherwise if 'none', 'name=' and a subsystem name options were
 	 * not specified, let's default to 'all'
 	 */
-	if (all_ss || (!one_ss && !opts->none && !opts->name))
+	if (ctx->all_ss || (!ctx->one_ss && !ctx->none && !ctx->name))
 		for_each_subsys(ss, i)
 			if (cgroup_ssid_enabled(i) && !cgroup1_ssid_disabled(i))
-				opts->subsys_mask |= (1 << i);
+				ctx->subsys_mask |= (1 << i);
 
 	/*
 	 * We either have to specify by name or by subsystems. (So all
 	 * empty hierarchies must have a name).
 	 */
-	if (!opts->subsys_mask && !opts->name)
-		return -EINVAL;
+	if (!ctx->subsys_mask && !ctx->name)
+		return invalf("cgroup1: Need name or subsystem set");
 
 	/*
 	 * Option noprefix was introduced just for backward compatibility
 	 * with the old cpuset, so we allow noprefix only if mounting just
 	 * the cpuset subsystem.
 	 */
-	if ((opts->flags & CGRP_ROOT_NOPREFIX) && (opts->subsys_mask & mask))
-		return -EINVAL;
+	if ((ctx->flags & CGRP_ROOT_NOPREFIX) && (ctx->subsys_mask & mask))
+		return invalf("cgroup1: noprefix used incorrectly");
 
 	/* Can't specify "none" and some subsystems */
-	if (opts->subsys_mask && opts->none)
-		return -EINVAL;
+	if (ctx->subsys_mask && ctx->none)
+		return invalf("cgroup1: none used incorrectly");
 
 	return 0;
 }
 
-static int cgroup1_remount(struct kernfs_root *kf_root, int *flags, char *data)
+static int cgroup1_remount(struct kernfs_root *kf_root, struct kernfs_fs_context *kfc)
 {
-	int ret = 0;
+	struct cgroup_fs_context *ctx = container_of(kfc, struct cgroup_fs_context, kfc);
 	struct cgroup_root *root = cgroup_root_from_kf(kf_root);
-	struct cgroup_sb_opts opts;
 	u16 added_mask, removed_mask;
+	int ret = 0;
 
 	cgroup_lock_and_drain_offline(&cgrp_dfl_root.cgrp);
 
-	/* See what subsystems are wanted */
-	ret = parse_cgroupfs_options(data, &opts);
-	if (ret)
-		goto out_unlock;
-
-	if (opts.subsys_mask != root->subsys_mask || opts.release_agent)
+	if (ctx->subsys_mask != root->subsys_mask || ctx->release_agent)
 		pr_warn("option changes via remount are deprecated (pid=%d comm=%s)\n",
 			task_tgid_nr(current), current->comm);
 
-	added_mask = opts.subsys_mask & ~root->subsys_mask;
-	removed_mask = root->subsys_mask & ~opts.subsys_mask;
+	added_mask = ctx->subsys_mask & ~root->subsys_mask;
+	removed_mask = root->subsys_mask & ~ctx->subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
-	if ((opts.flags ^ root->flags) ||
-	    (opts.name && strcmp(opts.name, root->name))) {
-		pr_err("option or name mismatch, new: 0x%x \"%s\", old: 0x%x \"%s\"\n",
-		       opts.flags, opts.name ?: "", root->flags, root->name);
+	if ((ctx->flags ^ root->flags) ||
+	    (ctx->name && strcmp(ctx->name, root->name))) {
+		invalf("option or name mismatch, new: 0x%x \"%s\", old: 0x%x \"%s\"",
+		       ctx->flags, ctx->name ?: "", root->flags, root->name);
 		ret = -EINVAL;
 		goto out_unlock;
 	}
@@ -1038,17 +1034,15 @@ static int cgroup1_remount(struct kernfs_root *kf_root, int *flags, char *data)
 
 	WARN_ON(rebind_subsystems(&cgrp_dfl_root, removed_mask));
 
-	if (opts.release_agent) {
+	if (ctx->release_agent) {
 		spin_lock(&release_agent_path_lock);
-		strcpy(root->release_agent_path, opts.release_agent);
+		strcpy(root->release_agent_path, ctx->release_agent);
 		spin_unlock(&release_agent_path_lock);
 	}
 
 	trace_cgroup_remount(root);
 
  out_unlock:
-	kfree(opts.release_agent);
-	kfree(opts.name);
 	mutex_unlock(&cgroup_mutex);
 	return ret;
 }
@@ -1062,25 +1056,19 @@ struct kernfs_syscall_ops cgroup1_kf_syscall_ops = {
 	.show_path		= cgroup_show_path,
 };
 
-struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
-			     void *data, unsigned long magic,
-			     struct cgroup_namespace *ns)
+/*
+ * Find or create a v1 cgroups superblock.
+ */
+int cgroup1_get_tree(struct cgroup_fs_context *ctx)
 {
 	struct super_block *pinned_sb = NULL;
-	struct cgroup_sb_opts opts;
 	struct cgroup_root *root;
 	struct cgroup_subsys *ss;
-	struct dentry *dentry;
 	int i, ret;
 	bool new_root = false;
 
 	cgroup_lock_and_drain_offline(&cgrp_dfl_root.cgrp);
 
-	/* First find the desired set of subsystems */
-	ret = parse_cgroupfs_options(data, &opts);
-	if (ret)
-		goto out_unlock;
-
 	/*
 	 * Destruction of cgroup root is asynchronous, so subsystems may
 	 * still be dying after the previous unmount.  Let's drain the
@@ -1089,15 +1077,13 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 	 * starting.  Testing ref liveliness is good enough.
 	 */
 	for_each_subsys(ss, i) {
-		if (!(opts.subsys_mask & (1 << i)) ||
+		if (!(ctx->subsys_mask & (1 << i)) ||
 		    ss->root == &cgrp_dfl_root)
 			continue;
 
 		if (!percpu_ref_tryget_live(&ss->root->cgrp.self.refcnt)) {
 			mutex_unlock(&cgroup_mutex);
-			msleep(10);
-			ret = restart_syscall();
-			goto out_free;
+			goto err_restart;
 		}
 		cgroup_put(&ss->root->cgrp);
 	}
@@ -1113,8 +1099,8 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 		 * name matches but sybsys_mask doesn't, we should fail.
 		 * Remember whether name matched.
 		 */
-		if (opts.name) {
-			if (strcmp(opts.name, root->name))
+		if (ctx->name) {
+			if (strcmp(ctx->name, root->name))
 				continue;
 			name_match = true;
 		}
@@ -1123,15 +1109,15 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 		 * If we asked for subsystems (or explicitly for no
 		 * subsystems) then they must match.
 		 */
-		if ((opts.subsys_mask || opts.none) &&
-		    (opts.subsys_mask != root->subsys_mask)) {
+		if ((ctx->subsys_mask || ctx->none) &&
+		    (ctx->subsys_mask != root->subsys_mask)) {
 			if (!name_match)
 				continue;
 			ret = -EBUSY;
-			goto out_unlock;
+			goto err_unlock;
 		}
 
-		if (root->flags ^ opts.flags)
+		if (root->flags ^ ctx->flags)
 			pr_warn("new mount options do not match the existing superblock, will be ignored\n");
 
 		/*
@@ -1152,9 +1138,7 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 			mutex_unlock(&cgroup_mutex);
 			if (!IS_ERR_OR_NULL(pinned_sb))
 				deactivate_super(pinned_sb);
-			msleep(10);
-			ret = restart_syscall();
-			goto out_free;
+			goto err_restart;
 		}
 
 		ret = 0;
@@ -1166,41 +1150,35 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 	 * specification is allowed for already existing hierarchies but we
 	 * can't create new one without subsys specification.
 	 */
-	if (!opts.subsys_mask && !opts.none) {
-		ret = -EINVAL;
-		goto out_unlock;
+	if (!ctx->subsys_mask && !ctx->none) {
+		ret = invalf("cgroup1: No subsys list or none specified");
+		goto err_unlock;
 	}
 
 	/* Hierarchies may only be created in the initial cgroup namespace. */
-	if (ns != &init_cgroup_ns) {
+	if (ctx->ns != &init_cgroup_ns) {
 		ret = -EPERM;
-		goto out_unlock;
+		goto err_unlock;
 	}
 
 	root = kzalloc(sizeof(*root), GFP_KERNEL);
 	if (!root) {
 		ret = -ENOMEM;
-		goto out_unlock;
+		goto err_unlock;
 	}
 	new_root = true;
+	ctx->root = root;
 
-	init_cgroup_root(root, &opts);
+	init_cgroup_root(ctx);
 
-	ret = cgroup_setup_root(root, opts.subsys_mask, PERCPU_REF_INIT_DEAD);
+	ret = cgroup_setup_root(root, ctx->subsys_mask, PERCPU_REF_INIT_DEAD);
 	if (ret)
 		cgroup_free_root(root);
 
 out_unlock:
 	mutex_unlock(&cgroup_mutex);
-out_free:
-	kfree(opts.release_agent);
-	kfree(opts.name);
-
-	if (ret)
-		return ERR_PTR(ret);
 
-	dentry = cgroup_do_mount(&cgroup_fs_type, flags, root,
-				 CGROUP_SUPER_MAGIC, ns);
+	ret = cgroup_do_get_tree(ctx);
 
 	/*
 	 * There's a race window after we release cgroup_mutex and before
@@ -1221,7 +1199,14 @@ struct dentry *cgroup1_mount(struct file_system_type *fs_type, int flags,
 	if (pinned_sb)
 		deactivate_super(pinned_sb);
 
-	return dentry;
+	return ret;
+
+err_restart:
+	msleep(10);
+	return restart_syscall();
+err_unlock:
+	mutex_unlock(&cgroup_mutex);
+	return ret;
 }
 
 static int __init cgroup1_wq_init(void)
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 8d4e85eae42c..4cbf8ef26577 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -1542,10 +1542,9 @@ int cgroup_show_path(struct seq_file *sf, struct kernfs_node *kf_node,
 	return len;
 }
 
-static int cgroup_remount(struct kernfs_root *kf_root, int *flags, char *data)
+static int cgroup_remount(struct kernfs_root *kf_root, struct kernfs_fs_context *kfc)
 {
-	pr_err("remount is not allowed\n");
-	return -EINVAL;
+	return invalf("cgroup2: Remount is not allowed");
 }
 
 /*
@@ -1626,8 +1625,9 @@ static void init_cgroup_housekeeping(struct cgroup *cgrp)
 	INIT_WORK(&cgrp->release_agent_work, cgroup1_release_agent);
 }
 
-void init_cgroup_root(struct cgroup_root *root, struct cgroup_sb_opts *opts)
+void init_cgroup_root(struct cgroup_fs_context *ctx)
 {
+	struct cgroup_root *root = ctx->root;
 	struct cgroup *cgrp = &root->cgrp;
 
 	INIT_LIST_HEAD(&root->root_list);
@@ -1636,12 +1636,12 @@ void init_cgroup_root(struct cgroup_root *root, struct cgroup_sb_opts *opts)
 	init_cgroup_housekeeping(cgrp);
 	idr_init(&root->cgroup_idr);
 
-	root->flags = opts->flags;
-	if (opts->release_agent)
-		strcpy(root->release_agent_path, opts->release_agent);
-	if (opts->name)
-		strcpy(root->name, opts->name);
-	if (opts->cpuset_clone_children)
+	root->flags = ctx->flags;
+	if (ctx->release_agent)
+		strcpy(root->release_agent_path, ctx->release_agent);
+	if (ctx->name)
+		strcpy(root->name, ctx->name);
+	if (ctx->cpuset_clone_children)
 		set_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->cgrp.flags);
 }
 
@@ -1742,56 +1742,49 @@ int cgroup_setup_root(struct cgroup_root *root, u16 ss_mask, int ref_flags)
 	return ret;
 }
 
-struct dentry *cgroup_do_mount(struct file_system_type *fs_type, int flags,
-			       struct cgroup_root *root, unsigned long magic,
-			       struct cgroup_namespace *ns)
+int cgroup_do_get_tree(struct cgroup_fs_context *ctx)
 {
-	struct dentry *dentry;
-	bool new_sb;
+	int ret;
 
-	dentry = kernfs_mount(fs_type, flags, root->kf_root, magic, &new_sb);
+	ctx->kfc.root = ctx->root->kf_root;
+	
+	ret = kernfs_get_tree(&ctx->kfc);
+	if (ret < 0)
+		goto out_cgrp;
 
 	/*
 	 * In non-init cgroup namespace, instead of root cgroup's dentry,
 	 * we return the dentry corresponding to the cgroupns->root_cgrp.
 	 */
-	if (!IS_ERR(dentry) && ns != &init_cgroup_ns) {
+	if (ctx->ns != &init_cgroup_ns) {
 		struct dentry *nsdentry;
 		struct cgroup *cgrp;
 
 		mutex_lock(&cgroup_mutex);
 		spin_lock_irq(&css_set_lock);
 
-		cgrp = cset_cgroup_from_root(ns->root_cset, root);
+		cgrp = cset_cgroup_from_root(ctx->ns->root_cset, ctx->root);
 
 		spin_unlock_irq(&css_set_lock);
 		mutex_unlock(&cgroup_mutex);
 
-		nsdentry = kernfs_node_dentry(cgrp->kn, dentry->d_sb);
-		dput(dentry);
-		dentry = nsdentry;
+		nsdentry = kernfs_node_dentry(cgrp->kn, ctx->kfc.fc.root->d_sb);
+		dput(ctx->kfc.fc.root);
+		ctx->kfc.fc.root = nsdentry;
 	}
 
-	if (IS_ERR(dentry) || !new_sb)
-		cgroup_put(&root->cgrp);
+	ret = 0;
+	if (ctx->kfc.new_sb_created)
+		goto out_cgrp;
+	return 0;
 
-	return dentry;
+out_cgrp:
+	return ret;
 }
 
-static struct dentry *cgroup_mount(struct file_system_type *fs_type,
-			 int flags, const char *unused_dev_name,
-			 void *data)
+static int cgroup_get_tree(struct fs_context *fc)
 {
-	struct cgroup_namespace *ns = current->nsproxy->cgroup_ns;
-	struct dentry *dentry;
-
-	get_cgroup_ns(ns);
-
-	/* Check if the caller has permission to mount. */
-	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN)) {
-		put_cgroup_ns(ns);
-		return ERR_PTR(-EPERM);
-	}
+	struct cgroup_fs_context *ctx = container_of(fc, struct cgroup_fs_context, kfc.fc);
 
 	/*
 	 * The first time anyone tries to mount a cgroup, enable the list
@@ -1800,24 +1793,80 @@ static struct dentry *cgroup_mount(struct file_system_type *fs_type,
 	if (!use_task_css_set_links)
 		cgroup_enable_task_cg_lists();
 
-	if (fs_type == &cgroup2_fs_type) {
-		if (data) {
-			pr_err("cgroup2: unknown option \"%s\"\n", (char *)data);
-			put_cgroup_ns(ns);
-			return ERR_PTR(-EINVAL);
-		}
+	switch (ctx->version) {
+	case 1:
+		return cgroup1_get_tree(ctx);
+
+	case 2:
 		cgrp_dfl_visible = true;
 		cgroup_get_live(&cgrp_dfl_root.cgrp);
 
-		dentry = cgroup_do_mount(&cgroup2_fs_type, flags, &cgrp_dfl_root,
-					 CGROUP2_SUPER_MAGIC, ns);
-	} else {
-		dentry = cgroup1_mount(&cgroup_fs_type, flags, data,
-				       CGROUP_SUPER_MAGIC, ns);
+		ctx->root = &cgrp_dfl_root;
+		return cgroup_do_get_tree(ctx);
+
+	default:
+		BUG();
 	}
+}
+
+static int cgroup_parse_option(struct fs_context *fc, char *p)
+{
+	struct cgroup_fs_context *ctx = container_of(fc, struct cgroup_fs_context, kfc.fc);
+
+	if (ctx->version == 1)
+		return cgroup1_parse_option(ctx, p);
+
+	return invalf("cgroup2: Options not supported");
+}
 
-	put_cgroup_ns(ns);
-	return dentry;
+static int cgroup_validate(struct fs_context *fc)
+{
+	struct cgroup_fs_context *ctx = container_of(fc, struct cgroup_fs_context, kfc.fc);
+
+	if (ctx->version)
+		return cgroup1_validate(ctx);
+	return 0;
+}
+
+/*
+ * Destroy a cgroup filesystem context.
+ */
+static void cgroup_fs_context_free(struct fs_context *fc)
+{
+	struct cgroup_fs_context *ctx = container_of(fc, struct cgroup_fs_context, kfc.fc);
+
+	kfree(ctx->name);
+	kfree(ctx->release_agent);
+	cgroup_put(&ctx->root->cgrp);
+	put_cgroup_ns(ctx->ns);
+	kernfs_free_fs_context(&ctx->kfc);
+}
+
+static const struct fs_context_operations cgroup_fs_context_ops = {
+	.free		= cgroup_fs_context_free,
+	.parse_option	= cgroup_parse_option,
+	.validate	= cgroup_validate,
+	.get_tree	= cgroup_get_tree,
+};
+
+/*
+ * Initialise the cgroup filesystem creation/reconfiguration context.  Notably,
+ * we select the namespace we're going to use.
+ */
+static int cgroup_init_fs_context(struct fs_context *fc, struct super_block *src_sb)
+{
+	struct cgroup_fs_context *ctx = container_of(fc, struct cgroup_fs_context, kfc.fc);
+	struct cgroup_namespace *ns = current->nsproxy->cgroup_ns;
+
+	/* Check if the caller has permission to mount. */
+	if (!ns_capable(ns->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	ctx->ns = get_cgroup_ns(ns);
+	ctx->version = (fc->fs_type == &cgroup2_fs_type) ? 2 : 1;
+	ctx->kfc.magic = (ctx->version == 2) ? CGROUP2_SUPER_MAGIC : CGROUP_SUPER_MAGIC;
+	ctx->kfc.fc.ops = &cgroup_fs_context_ops;
+	return 0;
 }
 
 static void cgroup_kill_sb(struct super_block *sb)
@@ -1842,17 +1891,19 @@ static void cgroup_kill_sb(struct super_block *sb)
 }
 
 struct file_system_type cgroup_fs_type = {
-	.name = "cgroup",
-	.mount = cgroup_mount,
-	.kill_sb = cgroup_kill_sb,
-	.fs_flags = FS_USERNS_MOUNT,
+	.name			= "cgroup",
+	.fs_context_size	= sizeof(struct cgroup_fs_context),
+	.init_fs_context	= cgroup_init_fs_context,
+	.kill_sb		= cgroup_kill_sb,
+	.fs_flags		= FS_USERNS_MOUNT,
 };
 
 static struct file_system_type cgroup2_fs_type = {
-	.name = "cgroup2",
-	.mount = cgroup_mount,
-	.kill_sb = cgroup_kill_sb,
-	.fs_flags = FS_USERNS_MOUNT,
+	.name			= "cgroup2",
+	.fs_context_size	= sizeof(struct cgroup_fs_context),
+	.init_fs_context	= cgroup_init_fs_context,
+	.kill_sb		= cgroup_kill_sb,
+	.fs_flags		= FS_USERNS_MOUNT,
 };
 
 int cgroup_path_ns_locked(struct cgroup *cgrp, char *buf, size_t buflen,
@@ -4460,11 +4511,12 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss, bool early)
  */
 int __init cgroup_init_early(void)
 {
-	static struct cgroup_sb_opts __initdata opts;
+	static struct cgroup_fs_context __initdata ctx;
 	struct cgroup_subsys *ss;
 	int i;
 
-	init_cgroup_root(&cgrp_dfl_root, &opts);
+	ctx.root = &cgrp_dfl_root;
+	init_cgroup_root(&ctx);
 	cgrp_dfl_root.cgrp.self.flags |= CSS_NO_REF;
 
 	RCU_INIT_POINTER(init_task.cgroups, &init_css_set);

