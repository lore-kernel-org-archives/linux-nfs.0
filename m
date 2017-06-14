Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752547AbdFNPQ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:16:59 -0400
Subject: [PATCH 10/27] VFS: Implement a filesystem superblock
 creation/configuration context [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:16:54 +0100
Message-ID: <149745341436.10897.6446274364664533484.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement a filesystem context concept to be used during superblock
creation for mount and superblock reconfiguration for remount.

The mounting procedure then becomes:

 (1) Allocate new fs_context context.

 (2) Configure the context.

 (3) Create superblock.

 (4) Mount the superblock any number of times.

 (5) Destroy the context.

Rather than calling fs_type->mount(), an fs_context struct is created and
fs_type->init_fs_context() is called to set it up.
fs_type->fs_context_size says how much space should be allocated for the
config context.  The fs_context struct is placed at the beginning and any
extra space is for the filesystem's use.

A set of operations has to be set by ->init_fs_context() to provide
freeing, duplication, option parsing, binary data parsing, validation,
mounting and superblock filling.

Legacy filesystems are supported by the provision of a set of legacy
fs_context operations that build up a list of mount options and then invoke
fs_type->mount() from within the fs_context ->get_tree() operation.  This
allows all filesystems to be accessed using fs_context.

It should be noted that, whilst this patch adds a lot of lines of code,
there is quite a bit of duplication with existing code that can be
eliminated should all filesystems be converted over.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/Makefile                |    3 
 fs/fs_context.c            |  501 ++++++++++++++++++++++++++++++++++++++++++++
 fs/internal.h              |    2 
 fs/libfs.c                 |   18 +-
 fs/namespace.c             |  399 ++++++++++++++++++++++++++---------
 fs/super.c                 |  158 ++++++++++++--
 include/linux/fs.h         |   17 +
 include/linux/fs_context.h |   12 +
 include/linux/mount.h      |    2 
 9 files changed, 992 insertions(+), 120 deletions(-)
 create mode 100644 fs/fs_context.c

diff --git a/fs/Makefile b/fs/Makefile
index 7bbaca9c67b1..ffe728cc15e1 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,8 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
+		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
+		fs_context.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/fs_context.c b/fs/fs_context.c
new file mode 100644
index 000000000000..98ba65d49b21
--- /dev/null
+++ b/fs/fs_context.c
@@ -0,0 +1,501 @@
+/* Provide a way to create a superblock configuration context within the kernel
+ * that allows a superblock to be set up prior to mounting.
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#include <linux/fs_context.h>
+#include <linux/fs.h>
+#include <linux/mount.h>
+#include <linux/nsproxy.h>
+#include <linux/slab.h>
+#include <linux/magic.h>
+#include <linux/security.h>
+#include <linux/parser.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/user_namespace.h>
+#include <net/net_namespace.h>
+#include "mount.h"
+
+struct legacy_fs_context {
+	struct fs_context	fc;
+	char			*legacy_data;	/* Data page for legacy filesystems */
+	char			*secdata;
+	unsigned int		data_usage;
+};
+
+static const struct fs_context_operations legacy_fs_context_ops;
+
+static const match_table_t common_set_mount_options = {
+	{ MS_DIRSYNC,		"dirsync" },
+	{ MS_I_VERSION,		"iversion" },
+	{ MS_LAZYTIME,		"lazytime" },
+	{ MS_MANDLOCK,		"mand" },
+	{ MS_POSIXACL,		"posixacl" },
+	{ MS_RDONLY,		"ro" },
+	{ MS_REC,		"rec" },
+	{ MS_SYNCHRONOUS,	"sync" },
+	{ MS_VERBOSE,		"verbose" },
+	{ },
+};
+
+static const match_table_t common_clear_mount_options = {
+	{ MS_LAZYTIME,		"nolazytime" },
+	{ MS_MANDLOCK,		"nomand" },
+	{ MS_RDONLY,		"rw" },
+	{ MS_SILENT,		"silent" },
+	{ MS_SYNCHRONOUS,	"async" },
+	{ },
+};
+
+static const match_table_t forbidden_mount_options = {
+	{ MS_BIND,		"bind" },
+	{ MS_MOVE,		"move" },
+	{ MS_PRIVATE,		"private" },
+	{ MS_REMOUNT,		"remount" },
+	{ MS_SHARED,		"shared" },
+	{ MS_SLAVE,		"slave" },
+	{ MS_UNBINDABLE,	"unbindable" },
+	{ MS_NOATIME,		"noatime" },
+	{ MS_RELATIME,		"relatime" },
+	{ MS_RELATIME,		"norelatime" },
+	{ MS_STRICTATIME,	"strictatime" },
+	{ MS_STRICTATIME,	"nostrictatime" },
+	{ MS_NODIRATIME,	"nodiratime" },
+	{ MS_NODEV,		"dev" },
+	{ MS_NODEV,		"nodev" },
+	{ MS_NOEXEC,		"exec" },
+	{ MS_NOEXEC,		"noexec" },
+	{ MS_NOSUID,		"suid" },
+	{ MS_NOSUID,		"nosuid" },
+	{ },
+};
+
+/*
+ * Check for a common mount option.
+ */
+static int vfs_parse_ms_mount_option(struct fs_context *fc, char *data)
+{
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int token;
+
+	token = match_token(data, common_set_mount_options, args);
+	if (token) {
+		fc->sb_flags |= token;
+		return 1;
+	}
+
+	token = match_token(data, common_clear_mount_options, args);
+	if (token) {
+		fc->sb_flags &= ~token;
+		return 1;
+	}
+
+	token = match_token(data, forbidden_mount_options, args);
+	if (token)
+		return invalf("VFS: Mount option, not superblock option");
+
+	return 0;
+}
+
+/**
+ * vfs_parse_mount_option - Add a single mount option to a superblock config
+ * @fc: The filesystem context to modify
+ * @p: The option to apply.
+ *
+ * A single mount option in string form is applied to the filesystem context
+ * being set up.  Certain standard options (for example "ro") are translated
+ * into flag bits without going to the filesystem.  The active security module
+ * is allowed to observe and poach options.  Any other options are passed over
+ * to the filesystem to parse.
+ *
+ * This may be called multiple times for a context.
+ *
+ * Returns 0 on success and a negative error code on failure.  In the event of
+ * failure, supplementary error information may have been set.
+ */
+int vfs_parse_mount_option(struct fs_context *fc, char *p)
+{
+	int ret;
+
+	ret = vfs_parse_ms_mount_option(fc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	ret = security_fs_context_parse_option(fc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	if (fc->ops->parse_option)
+		return fc->ops->parse_option(fc, p);
+
+	return invalf("VFS: FS takes no options");
+}
+EXPORT_SYMBOL(vfs_parse_mount_option);
+
+/**
+ * generic_monolithic_mount_data - Parse key[=val][,key[=val]]* mount data
+ * @mc: The superblock configuration to fill in.
+ * @data: The data to parse
+ *
+ * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
+ * called from the ->monolithic_mount_data() fs_context operation.
+ *
+ * Returns 0 on success or the error returned by the ->parse_option() fs_context
+ * operation on failure.
+ */
+int generic_monolithic_mount_data(struct fs_context *ctx, void *data)
+{
+	char *options = data, *p;
+	int ret;
+
+	if (!options)
+		return 0;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		if (*p) {
+			ret = vfs_parse_mount_option(ctx, p);
+			if (ret < 0)
+				return ret;
+		}
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(generic_monolithic_mount_data);
+
+/**
+ * vfs_new_fs_context - Create a filesystem context.
+ * @fs_type: The filesystem type.
+ * @src_sb: A superblock from which this one derives (or NULL)
+ * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @purpose: The purpose that this configuration shall be used for.
+ *
+ * Open a filesystem and create a mount context.  The mount context is
+ * initialised with the supplied flags and, if a submount/automount from
+ * another superblock (@src_sb), may have parameters such as namespaces copied
+ * across from that superblock.
+ */
+struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
+				      struct super_block *src_sb,
+				      unsigned int sb_flags,
+				      enum fs_context_purpose purpose)
+{
+	struct fs_context *fc;
+	size_t fc_size = fs_type->fs_context_size;
+	int ret;
+
+	BUG_ON(fs_type->init_fs_context && fc_size < sizeof(*fc));
+
+	if (!fs_type->init_fs_context)
+		fc_size = sizeof(struct legacy_fs_context);
+
+	fc = kzalloc(fc_size, GFP_KERNEL);
+	if (!fc)
+		return ERR_PTR(-ENOMEM);
+
+	fc->purpose	= purpose;
+	fc->sb_flags	= sb_flags;
+	fc->fs_type	= get_filesystem(fs_type);
+	fc->cred	= get_current_cred();
+
+	switch (purpose) {
+	case FS_CONTEXT_FOR_NEW:
+		fc->user_ns = get_user_ns(fc->cred->user_ns);
+		fc->net_ns = get_net(current->nsproxy->net_ns);
+		break;
+	case FS_CONTEXT_FOR_SUBMOUNT:
+		fc->user_ns = get_user_ns(src_sb->s_user_ns);
+		fc->net_ns = get_net(current->nsproxy->net_ns);
+		break;
+	case FS_CONTEXT_FOR_REMOUNT:
+		/* We don't pin any namespaces as the superblock's
+		 * subscriptions cannot be changed at this point.
+		 */
+		break;
+	}
+
+
+	/* TODO: Make all filesystems support this unconditionally */
+	if (fc->fs_type->init_fs_context) {
+		ret = fc->fs_type->init_fs_context(fc, src_sb);
+		if (ret < 0)
+			goto err_fc;
+	} else {
+		fc->ops = &legacy_fs_context_ops;
+	}
+
+	/* Do the security check last because ->init_fs_context may change the
+	 * namespace subscriptions.
+	 */
+	ret = security_fs_context_alloc(fc, src_sb);
+	if (ret < 0)
+		goto err_fc;
+
+	return fc;
+
+err_fc:
+	put_fs_context(fc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vfs_new_fs_context);
+
+/**
+ * vfs_sb_reconfig - Create a filesystem context for remount/reconfiguration
+ * @mnt: The mountpoint to open
+ * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ *
+ * Open a mounted filesystem and create a filesystem context such that a
+ * remount can be effected.
+ */
+struct fs_context *vfs_sb_reconfig(struct vfsmount *mnt,
+				   unsigned int sb_flags)
+{
+	return vfs_new_fs_context(mnt->mnt_sb->s_type, mnt->mnt_sb,
+				  sb_flags, FS_CONTEXT_FOR_REMOUNT);
+}
+
+/**
+ * vfs_dup_fc_config: Duplicate a filesytem context.
+ * @src_fc: The context to copy.
+ */
+struct fs_context *vfs_dup_fs_context(struct fs_context *src_fc)
+{
+	struct fs_context *fc;
+	size_t fc_size;
+	int ret;
+
+	if (!src_fc->ops->dup)
+		return ERR_PTR(-ENOTSUPP);
+
+	fc_size = src_fc->fs_type->fs_context_size;
+	if (!src_fc->fs_type->init_fs_context)
+		fc_size = sizeof(struct legacy_fs_context);
+
+	fc = kmemdup(src_fc, src_fc->fs_type->fs_context_size, GFP_KERNEL);
+	if (!fc)
+		return ERR_PTR(-ENOMEM);
+
+	fc->device	= NULL;
+	fc->security	= NULL;
+	get_filesystem(fc->fs_type);
+	get_net(fc->net_ns);
+	get_user_ns(fc->user_ns);
+	get_cred(fc->cred);
+
+	/* Can't call put until we've called ->dup */
+	ret = fc->ops->dup(fc, src_fc);
+	if (ret < 0)
+		goto err_fc;
+
+	ret = security_fs_context_dup(fc, src_fc);
+	if (ret < 0)
+		goto err_fc;
+	return fc;
+
+err_fc:
+	put_fs_context(fc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vfs_dup_fs_context);
+
+/**
+ * put_fs_context - Dispose of a superblock configuration context.
+ * @sc: The context to dispose of.
+ */
+void put_fs_context(struct fs_context *fc)
+{
+	struct super_block *sb;
+
+	if (fc->root) {
+		sb = fc->root->d_sb;
+		dput(fc->root);
+		fc->root = NULL;
+		deactivate_super(sb);
+	}
+
+	if (fc->ops && fc->ops->free)
+		fc->ops->free(fc);
+
+	security_fs_context_free(fc);
+	if (fc->net_ns)
+		put_net(fc->net_ns);
+	put_user_ns(fc->user_ns);
+	if (fc->cred)
+		put_cred(fc->cred);
+	kfree(fc->subtype);
+	put_filesystem(fc->fs_type);
+	kfree(fc->device);
+	kfree(fc);
+}
+EXPORT_SYMBOL(put_fs_context);
+
+/*
+ * Free the config for a filesystem that doesn't support fs_context.
+ */
+static void legacy_fs_context_free(struct fs_context *fc)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+
+	free_secdata(ctx->secdata);
+	kfree(ctx->legacy_data);
+}
+
+/*
+ * Duplicate a legacy config.
+ */
+static int legacy_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+	struct legacy_fs_context *src_ctx = container_of(src_fc, struct legacy_fs_context, fc);
+
+	ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	if (!ctx->legacy_data)
+		return -ENOMEM;
+	memcpy(ctx->legacy_data, src_ctx->legacy_data, sizeof(PAGE_SIZE));
+	return 0;
+}
+
+/*
+ * Add an option to a legacy config.  We build up a comma-separated list of
+ * options.
+ */
+static int legacy_parse_option(struct fs_context *fc, char *p)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+	unsigned int usage = ctx->data_usage;
+	size_t len = strlen(p);
+
+	if (len > PAGE_SIZE - 2 - usage)
+		return invalf("VFS: Insufficient data buffer space");
+	if (memchr(p, ',', len) != NULL)
+		return invalf("VFS: Options cannot contain commas");
+	if (!ctx->legacy_data) {
+		ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!ctx->legacy_data)
+			return -ENOMEM;
+	}
+
+	ctx->legacy_data[usage++] = ',';
+	memcpy(ctx->legacy_data + usage, p, len);
+	usage += len;
+	ctx->legacy_data[usage] = '\0';
+	ctx->data_usage = usage;
+	return 0;
+}
+
+/*
+ * Add monolithic mount data.
+ */
+static int legacy_monolithic_mount_data(struct fs_context *fc, void *data)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+
+	if (ctx->data_usage != 0)
+		return invalf("VFS: Can't mix monolithic and individual options");
+	if (!data)
+		return 0;
+	if (!ctx->legacy_data) {
+		ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
+		if (!ctx->legacy_data)
+			return -ENOMEM;
+	}
+
+	memcpy(ctx->legacy_data, data, PAGE_SIZE);
+	ctx->data_usage = PAGE_SIZE;
+	return 0;
+}
+
+/*
+ * Use the legacy mount validation step to strip out and process security
+ * config options.
+ */
+static int legacy_validate(struct fs_context *fc)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+
+	if (!ctx->legacy_data || ctx->fc.fs_type->fs_flags & FS_BINARY_MOUNTDATA)
+		return 0;
+
+	ctx->secdata = alloc_secdata();
+	if (!ctx->secdata)
+		return -ENOMEM;
+
+	return security_sb_copy_data(ctx->legacy_data, ctx->secdata);
+}
+
+/*
+ * Determine the superblock subtype.
+ */
+static int legacy_set_subtype(struct fs_context *fc)
+{
+	const char *subtype = strchr(fc->fs_type->name, '.');
+
+	if (subtype) {
+		subtype++;
+		if (!subtype[0])
+			return -EINVAL;
+	} else {
+		subtype = "";
+	}
+
+	fc->subtype = kstrdup(subtype, GFP_KERNEL);
+	if (!fc->subtype)
+		return -ENOMEM;
+	return 0;
+}
+
+/*
+ * Get a mountable root with the legacy mount command.
+ */
+static int legacy_get_tree(struct fs_context *fc)
+{
+	struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
+	struct super_block *sb;
+	struct dentry *root;
+	int ret;
+
+	root = ctx->fc.fs_type->mount(ctx->fc.fs_type, ctx->fc.sb_flags,
+				      ctx->fc.device, ctx->legacy_data);
+	if (IS_ERR(root))
+		return PTR_ERR(root);
+
+	sb = root->d_sb;
+	BUG_ON(!sb);
+
+	if ((ctx->fc.fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !fc->subtype) {
+		ret = legacy_set_subtype(fc);
+		if (ret < 0)
+			goto err_sb;
+	}
+
+	ctx->fc.root = root;
+	return 0;
+
+err_sb:
+	dput(root);
+	deactivate_locked_super(sb);
+	return ret;
+}
+
+static const struct fs_context_operations legacy_fs_context_ops = {
+	.free			= legacy_fs_context_free,
+	.dup			= legacy_fs_context_dup,
+	.parse_option		= legacy_parse_option,
+	.monolithic_mount_data	= legacy_monolithic_mount_data,
+	.validate		= legacy_validate,
+	.get_tree		= legacy_get_tree,
+};
diff --git a/fs/internal.h b/fs/internal.h
index 9676fe11c093..08d7816f8686 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -87,7 +87,7 @@ extern struct file *get_empty_filp(void);
 /*
  * super.c
  */
-extern int do_remount_sb(struct super_block *, int, void *, int);
+extern int do_remount_sb(struct super_block *, int, void *, int, struct fs_context *);
 extern bool trylock_super(struct super_block *sb);
 extern struct dentry *mount_fs(struct file_system_type *,
 			       int, const char *, void *);
diff --git a/fs/libfs.c b/fs/libfs.c
index 32c159ed33dd..21d1e6231707 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -9,6 +9,7 @@
 #include <linux/slab.h>
 #include <linux/cred.h>
 #include <linux/mount.h>
+#include <linux/fs_context.h>
 #include <linux/vfs.h>
 #include <linux/quotaops.h>
 #include <linux/mutex.h>
@@ -574,13 +575,28 @@ static DEFINE_SPINLOCK(pin_fs_lock);
 
 int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *count)
 {
+	struct fs_context *fc;
 	struct vfsmount *mnt = NULL;
+	int ret;
+
 	spin_lock(&pin_fs_lock);
 	if (unlikely(!*mount)) {
 		spin_unlock(&pin_fs_lock);
-		mnt = vfs_kern_mount(type, SB_KERNMOUNT, type->name, NULL);
+
+		fc = vfs_new_fs_context(type, NULL, SB_KERNMOUNT,
+					FS_CONTEXT_FOR_NEW);
+		if (IS_ERR(fc))
+			return PTR_ERR(fc);
+
+		ret = vfs_get_tree(fc);
+		if (ret < 0)
+			return ret;
+
+		mnt = vfs_kern_mount_fc(fc);
+		put_fs_context(fc);
 		if (IS_ERR(mnt))
 			return PTR_ERR(mnt);
+
 		spin_lock(&pin_fs_lock);
 		if (!*mount)
 			*mount = mnt;
diff --git a/fs/namespace.c b/fs/namespace.c
index 9a7dbf7b716f..cd44283dee99 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -25,7 +25,9 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/file.h>
 #include <linux/sched/task.h>
+#include <linux/fs_context.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -957,55 +959,6 @@ static struct mount *skip_mnt_tree(struct mount *p)
 	return p;
 }
 
-struct vfsmount *
-vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
-{
-	struct mount *mnt;
-	struct dentry *root;
-
-	if (!type)
-		return ERR_PTR(-ENODEV);
-
-	mnt = alloc_vfsmnt(name);
-	if (!mnt)
-		return ERR_PTR(-ENOMEM);
-
-	if (flags & SB_KERNMOUNT)
-		mnt->mnt.mnt_flags = MNT_INTERNAL;
-
-	root = mount_fs(type, flags, name, data);
-	if (IS_ERR(root)) {
-		mnt_free_id(mnt);
-		free_vfsmnt(mnt);
-		return ERR_CAST(root);
-	}
-
-	mnt->mnt.mnt_root = root;
-	mnt->mnt.mnt_sb = root->d_sb;
-	mnt->mnt_mountpoint = mnt->mnt.mnt_root;
-	mnt->mnt_parent = mnt;
-	lock_mount_hash();
-	list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
-	unlock_mount_hash();
-	return &mnt->mnt;
-}
-EXPORT_SYMBOL_GPL(vfs_kern_mount);
-
-struct vfsmount *
-vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
-	     const char *name, void *data)
-{
-	/* Until it is worked out how to pass the user namespace
-	 * through from the parent mount to the submount don't support
-	 * unprivileged mounts with submounts.
-	 */
-	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
-		return ERR_PTR(-EPERM);
-
-	return vfs_kern_mount(type, SB_SUBMOUNT, name, data);
-}
-EXPORT_SYMBOL_GPL(vfs_submount);
-
 static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 					int flag)
 {
@@ -1593,7 +1546,7 @@ static int do_umount(struct mount *mnt, int flags)
 			return -EPERM;
 		down_write(&sb->s_umount);
 		if (!(sb->s_flags & SB_RDONLY))
-			retval = do_remount_sb(sb, SB_RDONLY, NULL, 0);
+			retval = do_remount_sb(sb, SB_RDONLY, NULL, 0, NULL);
 		up_write(&sb->s_umount);
 		return retval;
 	}
@@ -2133,7 +2086,7 @@ static int graft_tree(struct mount *mnt, struct mount *p, struct mountpoint *mp)
 
 static int flags_to_propagation_type(int flags)
 {
-	int type = flags & ~(MS_REC | SB_SILENT);
+	int type = flags & ~(MS_REC | MS_SILENT);
 
 	/* Fail if any non-propagation flags are set */
 	if (type & ~(MS_SHARED | MS_PRIVATE | MS_SLAVE | MS_UNBINDABLE))
@@ -2276,6 +2229,20 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 }
 
 /*
+ * Parse the monolithic page of mount data given to sys_mount().
+ */
+static int parse_monolithic_mount_data(struct fs_context *fc, void *data)
+{
+	int (*monolithic_mount_data)(struct fs_context *, void *);
+
+	monolithic_mount_data = fc->ops->monolithic_mount_data;
+	if (!monolithic_mount_data)
+		monolithic_mount_data = generic_monolithic_mount_data;
+
+	return monolithic_mount_data(fc, data);
+}
+
+/*
  * change filesystem flags. dir should be a physical root of filesystem.
  * If you've mounted a non-root directory somewhere and want to do remount
  * on it - tough luck.
@@ -2283,9 +2250,11 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 static int do_remount(struct path *path, int flags, int mnt_flags,
 		      void *data)
 {
+	struct fs_context *fc = NULL;
 	int err;
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);
+	struct file_system_type *type = sb->s_type;
 
 	if (!check_mnt(mnt))
 		return -EINVAL;
@@ -2320,9 +2289,25 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		return -EPERM;
 	}
 
-	err = security_sb_remount(sb, data);
-	if (err)
-		return err;
+	if (type->init_fs_context) {
+		fc = vfs_sb_reconfig(path->mnt, flags);
+		if (IS_ERR(fc))
+			return PTR_ERR(fc);
+
+		err = parse_monolithic_mount_data(fc, data);
+		if (err < 0)
+			goto err_fc;
+
+		if (fc->ops->validate) {
+			err = fc->ops->validate(fc);
+			if (err < 0)
+				goto err_fc;
+		}
+	} else {
+		err = security_sb_remount(sb, data);
+		if (err)
+			return err;
+	}
 
 	down_write(&sb->s_umount);
 	if (flags & MS_BIND)
@@ -2330,7 +2315,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	else if (!capable(CAP_SYS_ADMIN))
 		err = -EPERM;
 	else
-		err = do_remount_sb(sb, flags, data, 0);
+		err = do_remount_sb(sb, flags, data, 0, fc);
 	if (!err) {
 		lock_mount_hash();
 		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
@@ -2339,6 +2324,9 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		unlock_mount_hash();
 	}
 	up_write(&sb->s_umount);
+err_fc:
+	if (fc)
+		put_fs_context(fc);
 	return err;
 }
 
@@ -2422,29 +2410,6 @@ static int do_move_mount(struct path *path, const char *old_name)
 	return err;
 }
 
-static struct vfsmount *fs_set_subtype(struct vfsmount *mnt, const char *fstype)
-{
-	int err;
-	const char *subtype = strchr(fstype, '.');
-	if (subtype) {
-		subtype++;
-		err = -EINVAL;
-		if (!subtype[0])
-			goto err;
-	} else
-		subtype = "";
-
-	mnt->mnt_sb->s_subtype = kstrdup(subtype, GFP_KERNEL);
-	err = -ENOMEM;
-	if (!mnt->mnt_sb->s_subtype)
-		goto err;
-	return mnt;
-
- err:
-	mntput(mnt);
-	return ERR_PTR(err);
-}
-
 /*
  * add a mount into a namespace's mount tree
  */
@@ -2492,40 +2457,91 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
 
 /*
- * create a new mount for userspace and request it to be added into the
- * namespace's tree
+ * Create a new mount using a superblock configuration and request it
+ * be added to the namespace tree.
  */
-static int do_new_mount(struct path *path, const char *fstype, int flags,
-			int mnt_flags, const char *name, void *data)
+static int do_new_mount_fc(struct fs_context *fc, struct path *mountpoint,
+			   unsigned int mnt_flags)
 {
-	struct file_system_type *type;
 	struct vfsmount *mnt;
-	int err;
-
-	if (!fstype)
-		return -EINVAL;
-
-	type = get_fs_type(fstype);
-	if (!type)
-		return -ENODEV;
+	int ret;
 
-	mnt = vfs_kern_mount(type, flags, name, data);
-	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype)
-		mnt = fs_set_subtype(mnt, fstype);
+	ret = security_sb_mountpoint(fc, mountpoint);
+	if (ret < 0)
+		return ret;;
 
-	put_filesystem(type);
+	mnt = vfs_kern_mount_fc(fc);
 	if (IS_ERR(mnt))
 		return PTR_ERR(mnt);
 
+	ret = -EPERM;
 	if (mount_too_revealing(mnt, &mnt_flags)) {
-		mntput(mnt);
-		return -EPERM;
+		errorf("VFS: Mount too revealing");
+		goto err_mnt;
 	}
 
-	err = do_add_mount(real_mount(mnt), path, mnt_flags);
+	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+	if (ret < 0) {
+		errorf("VFS: Failed to add mount");
+		goto err_mnt;
+	}
+	return ret;
+
+err_mnt:
+	mntput(mnt);
+	return ret;
+}
+
+/*
+ * create a new mount for userspace and request it to be added into the
+ * namespace's tree
+ */
+static int do_new_mount(struct path *mountpoint, const char *fstype,
+			int ms_flags, int mnt_flags, const char *name,
+			void *data)
+{
+	struct file_system_type *fs_type;
+	struct fs_context *fc;
+	int err = -EINVAL;
+
+	if (!fstype)
+		goto err;
+
+	err = -ENODEV;
+	fs_type = get_fs_type(fstype);
+	if (!fs_type)
+		goto err;
+
+	fc = vfs_new_fs_context(fs_type, NULL, ms_flags, FS_CONTEXT_FOR_NEW);
+	put_filesystem(fs_type);
+	if (IS_ERR(fc)) {
+		err = PTR_ERR(fc);
+		goto err;
+	}
+
+	err = -ENOMEM;
+	fc->device = kstrdup(name, GFP_KERNEL);
+	if (!fc->device)
+		goto err_fc;
+
+	err = parse_monolithic_mount_data(fc, data);
+	if (err < 0)
+		goto err_fc;
+
+	err = vfs_get_tree(fc);
+	if (err < 0)
+		goto err_fc;
+
+	err = do_new_mount_fc(fc, mountpoint, mnt_flags);
 	if (err)
-		mntput(mnt);
+		goto err_fc;
+
+	put_fs_context(fc);
+	return 0;
+
+err_fc:
+	put_fs_context(fc);
+err:
 	return err;
 }
 
@@ -3058,6 +3074,172 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
+/**
+ * vfs_get_tree - Get the mountable root
+ * @sc: The superblock configuration context.
+ *
+ * The filesystem is invoked to get or create a superblock which can then later
+ * be used for mounting.  The filesystem places a pointer to the root to be
+ * used for mounting in @fc->root.
+ */
+int vfs_get_tree(struct fs_context *fc)
+{
+	struct super_block *sb;
+	int ret;
+
+	if (fc->root)
+		return -EBUSY;
+
+	if (fc->ops->validate) {
+		ret = fc->ops->validate(fc);
+		if (ret < 0)
+			return ret;
+	}
+
+	/* The filesystem may transfer preallocated resources from the
+	 * configuration context to the superblock, thereby rendering the
+	 * config unusable for another attempt at creation if this one fails.
+	 */
+	if (fc->degraded)
+		return invalf("VFS: The config is degraded");
+
+	/* Get the mountable root in fc->root, with a ref on the root and a ref
+	 * on the superblock.
+	 */
+	ret = fc->ops->get_tree(fc);
+	if (ret < 0)
+		return ret;
+
+	BUG_ON(!fc->root);
+	sb = fc->root->d_sb;
+	WARN_ON(!sb->s_bdi);
+
+	ret = security_sb_get_tree(fc);
+	if (ret < 0)
+		goto err_sb;
+
+	ret = -ENOMEM;
+	if (fc->subtype && !sb->s_subtype) {
+		sb->s_subtype = kstrdup(fc->subtype, GFP_KERNEL);
+		if (!sb->s_subtype)
+			goto err_sb;
+	}
+
+	sb->s_flags |= MS_BORN;
+
+	/* Filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
+	 * but s_maxbytes was an unsigned long long for many releases.  Throw
+	 * this warning for a little while to try and catch filesystems that
+	 * violate this rule.
+	 */
+	WARN(sb->s_maxbytes < 0,
+	     "%s set sb->s_maxbytes to negative value (%lld)\n",
+	     fc->fs_type->name, sb->s_maxbytes);
+
+	up_write(&sb->s_umount);
+	return 0;
+
+err_sb:
+	dput(fc->root);
+	fc->root = NULL;
+	deactivate_locked_super(sb);
+	return ret;
+}
+EXPORT_SYMBOL(vfs_get_tree);
+
+/**
+ * vfs_kern_mount_fc - Create a mount for a configured superblock
+ * sc: The configuration context with the superblock attached
+ *
+ * Create a mount to an already configured superblock.  If necessary, the
+ * caller should invoke vfs_create_super() before calling this.
+ */
+struct vfsmount *vfs_kern_mount_fc(struct fs_context *fc)
+{
+	struct mount *mnt;
+
+	if (!fc->root)
+		return ERR_PTR(invalf("VFS: Root must be obtained before mount"));
+
+	mnt = alloc_vfsmnt(fc->device ?: "none");
+	if (!mnt)
+		return ERR_PTR(-ENOMEM);
+
+	if (fc->sb_flags & SB_KERNMOUNT)
+		mnt->mnt.mnt_flags = MNT_INTERNAL;
+
+	atomic_inc(&fc->root->d_sb->s_active);
+	mnt->mnt.mnt_sb		= fc->root->d_sb;
+	mnt->mnt.mnt_root	= dget(fc->root);
+	mnt->mnt_mountpoint	= mnt->mnt.mnt_root;
+	mnt->mnt_parent		= mnt;
+
+	lock_mount_hash();
+	list_add_tail(&mnt->mnt_instance, &mnt->mnt.mnt_sb->s_mounts);
+	unlock_mount_hash();
+	return &mnt->mnt;
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount_fc);
+
+struct vfsmount *vfs_kern_mount(struct file_system_type *type,
+				int flags, const char *name, void *data)
+{
+	struct fs_context *fc;
+	struct vfsmount *mnt;
+	int ret;
+
+	if (!type)
+		return ERR_PTR(-EINVAL);
+
+	fc = vfs_new_fs_context(type, NULL, flags, FS_CONTEXT_FOR_NEW);
+	if (IS_ERR(fc))
+		return ERR_CAST(fc);
+
+	if (name) {
+		ret = -ENOMEM;
+		fc->device = kstrdup(name, GFP_KERNEL);
+		if (!fc->device)
+			goto err_fc;
+	}
+
+	ret = parse_monolithic_mount_data(fc, data);
+	if (ret < 0)
+		goto err_fc;
+
+	ret = vfs_get_tree(fc);
+	if (ret < 0)
+		goto err_fc;
+
+	mnt = vfs_kern_mount_fc(fc);
+	if (IS_ERR(mnt)) {
+		ret = PTR_ERR(mnt);
+		goto err_fc;
+	}
+
+	put_fs_context(fc);
+	return mnt;
+
+err_fc:
+	put_fs_context(fc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount);
+
+struct vfsmount *
+vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
+	     const char *name, void *data)
+{
+	/* Until it is worked out how to pass the user namespace
+	 * through from the parent mount to the submount don't support
+	 * unprivileged mounts with submounts.
+	 */
+	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
+		return ERR_PTR(-EPERM);
+
+	return vfs_kern_mount(type, MS_SUBMOUNT, name, data);
+}
+EXPORT_SYMBOL_GPL(vfs_submount);
+
 /*
  * Return true if path is reachable from root
  *
@@ -3299,6 +3481,23 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
 }
 EXPORT_SYMBOL_GPL(kern_mount_data);
 
+struct vfsmount *kern_mount_data_fc(struct fs_context *fc)
+{
+	struct vfsmount *mnt;
+
+	fc->sb_flags = SB_KERNMOUNT;
+	mnt = vfs_kern_mount_fc(fc);
+	if (!IS_ERR(mnt)) {
+		/*
+		 * it is a longterm mount, don't release mnt until
+		 * we unmount before file sys is unregistered
+		*/
+		real_mount(mnt)->mnt_ns = MNT_NS_INTERNAL;
+	}
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(kern_mount_data_fc);
+
 void kern_unmount(struct vfsmount *mnt)
 {
 	/* release long term mount so mount point can be released */
diff --git a/fs/super.c b/fs/super.c
index e55911d31821..8ef5222d6932 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <linux/fs_context.h>
 #include "internal.h"
 
 
@@ -173,16 +174,13 @@ static void destroy_super(struct super_block *s)
 }
 
 /**
- *	alloc_super	-	create new superblock
- *	@type:	filesystem type superblock should belong to
- *	@flags: the mount flags
- *	@user_ns: User namespace for the super_block
+ *	alloc_super - Create new superblock
+ *	@sc: The filesystem configuration context
  *
  *	Allocates and initializes a new &struct super_block.  alloc_super()
  *	returns a pointer new superblock or %NULL if allocation had failed.
  */
-static struct super_block *alloc_super(struct file_system_type *type, int flags,
-				       struct user_namespace *user_ns)
+static struct super_block *alloc_super(struct fs_context *fc)
 {
 	struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
 	static const struct super_operations default_op;
@@ -192,7 +190,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		return NULL;
 
 	INIT_LIST_HEAD(&s->s_mounts);
-	s->s_user_ns = get_user_ns(user_ns);
+	s->s_user_ns = get_user_ns(fc->user_ns);
 
 	if (security_sb_alloc(s))
 		goto fail;
@@ -200,12 +198,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	for (i = 0; i < SB_FREEZE_LEVELS; i++) {
 		if (__percpu_init_rwsem(&s->s_writers.rw_sem[i],
 					sb_writers_name[i],
-					&type->s_writers_key[i]))
+					&fc->fs_type->s_writers_key[i]))
 			goto fail;
 	}
 	init_waitqueue_head(&s->s_writers.wait_unfrozen);
 	s->s_bdi = &noop_backing_dev_info;
-	s->s_flags = flags;
+	s->s_flags = fc->sb_flags;
 	if (s->s_user_ns != &init_user_ns)
 		s->s_iflags |= SB_I_NODEV;
 	INIT_HLIST_NODE(&s->s_instances);
@@ -222,7 +220,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 		goto fail;
 
 	init_rwsem(&s->s_umount);
-	lockdep_set_class(&s->s_umount, &type->s_umount_key);
+	lockdep_set_class(&s->s_umount, &fc->fs_type->s_umount_key);
 	/*
 	 * sget() can have s_umount recursion.
 	 *
@@ -242,7 +240,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 	s->s_count = 1;
 	atomic_set(&s->s_active, 1);
 	mutex_init(&s->s_vfs_rename_mutex);
-	lockdep_set_class(&s->s_vfs_rename_mutex, &type->s_vfs_rename_key);
+	lockdep_set_class(&s->s_vfs_rename_mutex, &fc->fs_type->s_vfs_rename_key);
 	mutex_init(&s->s_dquot.dqio_mutex);
 	s->s_maxbytes = MAX_NON_LFS;
 	s->s_op = &default_op;
@@ -455,6 +453,79 @@ void generic_shutdown_super(struct super_block *sb)
 EXPORT_SYMBOL(generic_shutdown_super);
 
 /**
+ *	sget_fc - Find or create a superblock
+ *	@fc:	Configuration context.
+ *	@test:	comparison callback
+ *	@set:	setup callback
+ */
+struct super_block *sget_fc(struct fs_context *fc,
+			    int (*test)(struct super_block *, struct fs_context *),
+			    int (*set)(struct super_block *, struct fs_context *))
+{
+	struct super_block *s = NULL;
+	struct super_block *old;
+	int err;
+
+	if (!(fc->sb_flags & MS_KERNMOUNT) &&
+	    fc->purpose != FS_CONTEXT_FOR_SUBMOUNT) {
+		if (!(fc->fs_type->fs_flags & FS_USERNS_MOUNT) &&
+		    !capable(CAP_SYS_ADMIN))
+			return ERR_PTR(-EPERM);
+		else if (!ns_capable(fc->user_ns, CAP_SYS_ADMIN))
+			return ERR_PTR(-EPERM);
+	}
+
+retry:
+	spin_lock(&sb_lock);
+	if (test) {
+		hlist_for_each_entry(old, &fc->fs_type->fs_supers, s_instances) {
+			if (!test(old, fc))
+				continue;
+			if (fc->user_ns != old->s_user_ns) {
+				spin_unlock(&sb_lock);
+				if (s) {
+					up_write(&s->s_umount);
+					destroy_super(s);
+				}
+				return ERR_PTR(-EBUSY);
+			}
+			if (!grab_super(old))
+				goto retry;
+			if (s) {
+				up_write(&s->s_umount);
+				destroy_super(s);
+				s = NULL;
+			}
+			return old;
+		}
+	}
+	if (!s) {
+		spin_unlock(&sb_lock);
+		s = alloc_super(fc);
+		if (!s)
+			return ERR_PTR(-ENOMEM);
+		goto retry;
+	}
+
+	err = set(s, fc);
+	if (err) {
+		spin_unlock(&sb_lock);
+		up_write(&s->s_umount);
+		destroy_super(s);
+		return ERR_PTR(err);
+	}
+	s->s_type = fc->fs_type;
+	strlcpy(s->s_id, s->s_type->name, sizeof(s->s_id));
+	list_add_tail(&s->s_list, &super_blocks);
+	hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
+	spin_unlock(&sb_lock);
+	get_filesystem(s->s_type);
+	register_shrinker(&s->s_shrink);
+	return s;
+}
+EXPORT_SYMBOL(sget_fc);
+
+/**
  *	sget_userns -	find or create a superblock
  *	@type:	filesystem type superblock should belong to
  *	@test:	comparison callback
@@ -503,7 +574,14 @@ struct super_block *sget_userns(struct file_system_type *type,
 	}
 	if (!s) {
 		spin_unlock(&sb_lock);
-		s = alloc_super(type, (flags & ~SB_SUBMOUNT), user_ns);
+		{
+			struct fs_context fc = {
+				.fs_type	= type,
+				.sb_flags	= flags & ~SB_SUBMOUNT,
+				.user_ns	= user_ns,
+			};
+			s = alloc_super(&fc);
+		}
 		if (!s)
 			return ERR_PTR(-ENOMEM);
 		goto retry;
@@ -805,10 +883,13 @@ struct super_block *user_get_super(dev_t dev)
  *	@flags:	MS_* flags translated into SB_* flags
  *	@data:	the rest of options
  *      @force: whether or not to force the change
+ *	@fc:	the superblock config for filesystems that support it
+ *		(NULL if called from emergency or umount)
  *
  *	Alters the mount options of a mounted file system.
  */
-int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
+int do_remount_sb(struct super_block *sb, int flags, void *data, int force,
+		  struct fs_context *fc)
 {
 	int retval;
 	int remount_ro;
@@ -850,8 +931,14 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 		}
 	}
 
-	if (sb->s_op->remount_fs) {
-		retval = sb->s_op->remount_fs(sb, &flags, data);
+	if (sb->s_op->remount_fs_fc ||
+	    sb->s_op->remount_fs) {
+		if (sb->s_op->remount_fs_fc) {
+		    retval = sb->s_op->remount_fs_fc(sb, fc);
+		    flags = fc->sb_flags;
+		} else {
+			retval = sb->s_op->remount_fs(sb, &flags, data);
+		}
 		if (retval) {
 			if (!force)
 				goto cancel_readonly;
@@ -898,7 +985,7 @@ static void do_emergency_remount(struct work_struct *work)
 			/*
 			 * What lock protects sb->s_flags??
 			 */
-			do_remount_sb(sb, SB_RDONLY, NULL, 1);
+			do_remount_sb(sb, SB_RDONLY, NULL, 1, NULL);
 		}
 		up_write(&sb->s_umount);
 		spin_lock(&sb_lock);
@@ -1048,6 +1135,43 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(mount_ns);
 
+int mount_ns_fc(struct fs_context *fc,
+		int (*fill_super)(struct super_block *sb, struct fs_context *fc),
+		void *ns)
+{
+	struct super_block *sb;
+
+	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
+	 * over the namespace.
+	 */
+	if (!(fc->sb_flags & SB_KERNMOUNT) &&
+	    !ns_capable(fc->user_ns, CAP_SYS_ADMIN))
+		return -EPERM;
+
+	sb = sget_userns(fc->fs_type, ns_test_super, ns_set_super,
+			 fc->sb_flags, fc->user_ns, ns);
+	if (IS_ERR(sb))
+		return PTR_ERR(sb);
+
+	if (!sb->s_root) {
+		int err;
+		err = fill_super(sb, fc);
+		if (err) {
+			deactivate_locked_super(sb);
+			return err;
+		}
+
+		sb->s_flags |= SB_ACTIVE;
+	}
+
+	if (!fc->root) {
+		fc->root = sb->s_root;
+		dget(sb->s_root);
+	}
+	return 0;
+}
+EXPORT_SYMBOL(mount_ns_fc);
+
 #ifdef CONFIG_BLOCK
 static int set_bdev_super(struct super_block *s, void *data)
 {
@@ -1196,7 +1320,7 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 		}
 		s->s_flags |= SB_ACTIVE;
 	} else {
-		do_remount_sb(s, flags, data, 0);
+		do_remount_sb(s, flags, data, 0, NULL);
 	}
 	return dget(s->s_root);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3138da4491da..9fd6555122da 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -54,6 +54,7 @@ struct workqueue_struct;
 struct iov_iter;
 struct fscrypt_info;
 struct fscrypt_operations;
+struct fs_context;
 
 extern void __init inode_init(void);
 extern void __init inode_init_early(void);
@@ -701,6 +702,11 @@ static inline void inode_unlock(struct inode *inode)
 	up_write(&inode->i_rwsem);
 }
 
+static inline int inode_lock_killable(struct inode *inode)
+{
+	return down_write_killable(&inode->i_rwsem);
+}
+
 static inline void inode_lock_shared(struct inode *inode)
 {
 	down_read(&inode->i_rwsem);
@@ -1814,6 +1820,7 @@ struct super_operations {
 	int (*unfreeze_fs) (struct super_block *);
 	int (*statfs) (struct dentry *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
+	int (*remount_fs_fc) (struct super_block *, struct fs_context *);
 	void (*umount_begin) (struct super_block *);
 
 	int (*show_options)(struct seq_file *, struct dentry *);
@@ -2048,8 +2055,10 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+	unsigned short fs_context_size;	/* Size of superblock config context to allocate */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
+	int (*init_fs_context)(struct fs_context *, struct super_block *);
 	void (*kill_sb) (struct super_block *);
 	struct module *owner;
 	struct file_system_type * next;
@@ -2067,6 +2076,10 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
+extern int mount_ns_fc(struct fs_context *fc,
+		       int (*fill_super)(struct super_block *sb,
+					 struct fs_context *fc),
+		       void *ns);
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
@@ -2089,6 +2102,9 @@ void deactivate_locked_super(struct super_block *sb);
 int set_anon_super(struct super_block *s, void *data);
 int get_anon_bdev(dev_t *);
 void free_anon_bdev(dev_t);
+struct super_block *sget_fc(struct fs_context *fc,
+			    int (*test)(struct super_block *, struct fs_context *),
+			    int (*set)(struct super_block *, struct fs_context *));
 struct super_block *sget_userns(struct file_system_type *type,
 			int (*test)(struct super_block *,void *),
 			int (*set)(struct super_block *,void *),
@@ -2133,6 +2149,7 @@ extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
 #define kern_mount(type) kern_mount_data(type, NULL)
+extern struct vfsmount *kern_mount_data_fc(struct fs_context *);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 429c40be2c9e..d29fb7b287fd 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -69,4 +69,16 @@ struct fs_context_operations {
 	int (*get_tree)(struct fs_context *fc);
 };
 
+extern struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
+					     struct super_block *src_sb,
+					     unsigned int ms_flags,
+					     enum fs_context_purpose purpose);
+extern struct fs_context *vfs_sb_reconfig(struct vfsmount *mnt,
+					  unsigned int ms_flags);
+extern struct fs_context *vfs_dup_fs_context(struct fs_context *src);
+extern int vfs_parse_mount_option(struct fs_context *fc, char *data);
+extern int generic_monolithic_mount_data(struct fs_context *fc, void *data);
+extern int vfs_get_tree(struct fs_context *fc);
+extern void put_fs_context(struct fs_context *fc);
+
 #endif /* _LINUX_FS_CONTEXT_H */
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 8e0352af06b7..c990906ccced 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -20,6 +20,7 @@ struct super_block;
 struct vfsmount;
 struct dentry;
 struct mnt_namespace;
+struct fs_context;
 
 #define MNT_NOSUID	0x01
 #define MNT_NODEV	0x02
@@ -90,6 +91,7 @@ struct file_system_type;
 extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 				      int flags, const char *name,
 				      void *data);
+extern struct vfsmount *vfs_kern_mount_fc(struct fs_context *fc);
 extern struct vfsmount *vfs_submount(const struct dentry *mountpoint,
 				     struct file_system_type *type,
 				     const char *name, void *data);

