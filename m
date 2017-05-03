Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752863AbdECQFJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:05:09 -0400
Subject: [PATCH 3/9] VFS: Introduce a mount context
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, dhowells@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 17:04:59 +0100
Message-ID: <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a mount context concept.  This is allocated at the beginning of
the mount procedure and into it is placed:

 (1) Filesystem type.

 (2) Namespaces.

 (3) Device name.

 (4) Superblock flags (MS_*) and mount flags (MNT_*).

 (5) Security details.

 (6) Filesystem-specific data, as set by the mount options.

It also gives a place in which to hang an error message for later retrieval
(see the mount-by-fd syscall later in this series).

Rather than calling fs_type->mount(), a mount_context struct is created and
fs_type->fsopen() is called to set it up.  fs_type->mc_size says how much
should be added on to the mount context for the filesystem's use.

A set of operations have to be set by ->fsopen() to provide freeing,
duplication, option parsing, binary data parsing, validation, mounting and
superblock filling.

It should be noted that, whilst this patch adds a lot of lines of code,
there is quite a bit of duplication with existing code that can be
eliminated should all filesystems be converted over.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/mounting.txt |  445 ++++++++++++++++++++++++++++++++
 fs/Makefile                            |    3 
 fs/internal.h                          |    2 
 fs/mount.h                             |    3 
 fs/mount_context.c                     |  343 +++++++++++++++++++++++++
 fs/namespace.c                         |  270 +++++++++++++++++--
 fs/super.c                             |   50 +++-
 include/linux/fs.h                     |   11 +
 include/linux/lsm_hooks.h              |   37 +++
 include/linux/mount.h                  |   67 +++++
 include/linux/security.h               |   29 ++
 security/security.c                    |   32 ++
 security/selinux/hooks.c               |  179 +++++++++++++
 13 files changed, 1435 insertions(+), 36 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/mount_context.c

diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
new file mode 100644
index 000000000000..a942ccd08376
--- /dev/null
+++ b/Documentation/filesystems/mounting.txt
@@ -0,0 +1,445 @@
+			      ===================
+			      FILESYSTEM MOUNTING
+			      ===================
+
+CONTENTS
+
+ (1) Overview.
+
+ (2) The mount context.
+
+ (3) The mount context operations.
+
+ (4) Mount context security.
+
+ (5) VFS mount context operations.
+
+
+========
+OVERVIEW
+========
+
+The creation of new mounts is now to be done in a multistep process:
+
+ (1) Create a mount context.
+
+ (2) Parse the options and attach them to the mount context.  Options may be
+     passed individually from userspace.
+
+ (3) Validate and pre-process the mount context.
+
+ (4) Perform the mount.
+
+ (5) Return an error message attached to the mount context.
+
+ (6) Destroy the mount context.
+
+To support this, the file_system_type struct gains two new fields:
+
+	unsigned short mc_size;
+
+which indicates how much space the filesystem would like tacked onto the end of
+the mount_context struct for its own purposes, and:
+
+	int (*fsopen)(struct mount_context *mc, struct super_block *src_sb);
+
+which is invoked to set up the filesystem-specific parts of a mount context,
+including the additional space.  The src_sb parameter is used to convey the
+superblock from which the filesystem may draw extra information (such as
+namespaces), for submount (MS_SUBMOUNT) or remount (MS_REMOUNT) purposes or it
+will be NULL.
+
+Note that security initialisation is done *after* the filesystem is called so
+that the namespaces may be adjusted first.
+
+And the super_operations struct gains one:
+
+	int (*remount_fs_mc) (struct super_block *, struct mount_context *);
+
+This shadows the ->remount_fs() operation and takes a prepared mount context
+instead of the mount flags and data page.  It may modify the ms_flags in the
+context for the caller to pick up.
+
+[NOTE] remount_fs_mc is intended as a replacement for remount_fs.
+
+
+=================
+THE MOUNT CONTEXT
+=================
+
+The mount process is governed by a mount context.  This is represented by the
+mount_context structure:
+
+	struct mount_context {
+		const struct mount_context_operations *ops;
+		struct file_system_type *fs;
+		struct user_namespace	*user_ns;
+		struct mnt_namespace	*mnt_ns;
+		struct pid_namespace	*pid_ns;
+		struct net		*net_ns;
+		const struct cred	*cred;
+		char			*device;
+		char			*root_path;
+		void			*security;
+		const char		*error;
+		unsigned int		ms_flags;
+		unsigned int		mnt_flags;
+		bool			mounted;
+		bool			sloppy;
+		bool			silent;
+		enum mount_type		mount_type : 8;
+	};
+
+When allocated, the mount_context struct is extended by ->mc_size bytes as
+specified by the specified file_system_type struct.  This is for use by the
+filesystem.  The filesystem should wrap the struct in its own, e.g.:
+
+	struct nfs_mount_context {
+		struct mount_context mc;
+		...
+	};
+
+placing the mount_context struct first.  container_of() can then be used.
+
+The mount_context fields are as follows:
+
+ (*) const struct mount_context_operations *ops
+
+     These are operations that can be done on a mount context.  See below.
+     This must be set by the ->fsopen() file_system_type operation.
+
+ (*) struct file_system_type *fs
+
+     A pointer to the file_system_type of the filesystem that is being
+     mounted.  This retains a ref on the type owner.
+
+ (*) struct user_namespace *user_ns
+ (*) struct mnt_namespace *mnt_ns
+ (*) struct pid_namespace *pid_ns
+ (*) struct net *net_ns
+
+     This is a subset of the namespaces in use by the invoking process.  This
+     retains a ref on each namespace.  The subscribed namespaces may be
+     replaced by the filesystem to reflect other sources, such as the parent
+     mount superblock on an automount.
+
+ (*) struct cred *cred
+
+     The mounter's credentials.  This retains a ref on the credentials.
+
+ (*) char *device
+
+     This is the device to be mounted.  It may be a block device
+     (e.g. /dev/sda1) or something more exotic, such as the "host:/path" that
+     NFS desires.
+
+ (*) char *root_path
+
+     A path to the place inside the filesystem to actually mount.  This allows
+     a mount and bind-mount to be combined.
+
+     [NOTE] This isn't implemented yet, but NFS has the code to do this which
+     could be moved to the VFS.
+
+ (*) void *security
+
+     A place for the LSMs to hang their security data for the mount.  The
+     relevant security operations are described below.
+
+ (*) const char *error
+
+     A place for the VFS and the filesystem to hang an error message.  This
+     should be in the form of a static string that doesn't need deallocation
+     and the pointer to which can just be overwritten.  Under some
+     circumstances, this can be retrieved by userspace.
+
+     Note that the existence of the error string is expected to be guaranteed
+     by the reference on the file_system_type object held by ->fs or any
+     filesystem-specific reference held in the filesystem context until the
+     ->free() operation is called.
+
+ (*) unsigned int ms_flags
+ (*) unsigned int mnt_flags
+
+     These hold the mount flags.  ms_flags holds MS_* flags and mnt_flags holds
+     MNT_* flags.
+
+ (*) bool mounted
+
+     This is set to true once a mount attempt is made.  This causes an error to
+     be given on subsequent mount attempts with the same context and prevents
+     multiple mount attempts.
+
+ (*) bool sloppy
+ (*) bool silent
+
+     These are set if the sloppy or silent mount options are given.
+
+     [NOTE] sloppy is probably unnecessary when userspace passes over one
+     option at a time since the error can just be ignored if userspace deems it
+     to be unimportant.
+
+     [NOTE] silent is probably redundant with ms_flags & MS_SILENT.
+
+ (*) enum mount_type
+
+     This indicates the type of mount operation.  The available values are:
+
+	MOUNT_TYPE_NEW		-- New mount
+	MOUNT_TYPE_SUBMOUNT	-- New automatic submount of extant mount
+	MOUNT_TYPE_REMOUNT	-- Change an existing mount
+
+The mount context is created by calling __vfs_fsopen(), vfs_fsopen(),
+vfs_mntopen() or vfs_dup_mount_context() and is destroyed with
+put_mount_context().  Note that the structure is not refcounted.
+
+VFS, security and filesystem mount options are set individually with
+vfs_mount_option() or in bulk with generic_monolithic_mount_data().
+
+When mounting, the filesystem is allowed to take data from any of the pointers
+and attach it to the superblock (or whatever), provided it clears the pointer
+in the mount context.
+
+The filesystem is also allowed to allocate resources and pin them with the
+mount context.  For instance, NFS might pin the appropriate protocol version
+module.
+
+
+============================
+THE MOUNT CONTEXT OPERATIONS
+============================
+
+The mount context points to a table of operations:
+
+	struct mount_context_operations {
+		void (*free)(struct mount_context *mc);
+		int (*dup)(struct mount_context *mc, struct mount_context *src);
+		int (*option)(struct mount_context *mc, char *p);
+		int (*monolithic_mount_data)(struct mount_context *mc, void *data);
+		int (*validate)(struct mount_context *mc);
+		struct dentry *(*mount)(struct mount_context *mc);
+		int (*fill_super)(struct super_block *s, struct mount_context *mc);
+	};
+
+These operations are invoked by the various stages of the mount procedure to
+manage the mount context.  They are as follows:
+
+ (*) void (*free)(struct mount_context *mc);
+
+     Called to clean up the filesystem-specific part of the mount context when
+     the context is destroyed.  It should be aware that parts of the context
+     may have been removed and NULL'd out by ->mount().
+
+ (*) int (*dup)(struct mount_context *mc, struct mount_context *src);
+
+     Called when a mount context has been duplicated to get any refs or copy
+     any non-referenced resources held in the filesystem-specific part of the
+     mount context.  An error may be returned to indicate failure to do this.
+
+     [!] Note that if this fails, put_mount_context() will be called
+     	 immediately thereafter, so ->dup() *must* make the
+     	 filesystem-specific part safe for ->free().
+
+ (*) int (*option)(struct mount_context *mc, char *p);
+
+     Called when an option is to be added to the mount context.  p points to
+     the option string, likely in "key[=val]" format.  VFS-specific options
+     will have been weeded out and mc->ms_flags and mc->mnt_flags updated in
+     the context.  Security options will also have been weeded out and
+     mc->security updated.
+
+     If successful, 0 should be returned and a negative error code otherwise.
+     If an ambiguous error (such as -EINVAL) is returned, mc->error should be
+     set in the context to a string that provides more information.
+
+ (*) int (*monolithic_mount_data)(struct mount_context *mc, void *data);
+
+     Called when the mount(2) system call is invoked to pass the entire data
+     page in one go.  If this is expected to be just a list of "key[=val]"
+     items separated by commas, then this may be set to NULL.
+
+     The return value is as for ->option().
+
+     If the filesystem (eg. NFS) needs to examine the data first and then
+     finds it's the standard key-val list then it may pass it off to:
+
+	int generic_monolithic_mount_data(struct mount_context *mc, void *data);
+
+ (*) int (*validate)(struct mount_context *mc);
+
+     Called when all the options have been applied and the mount is about to
+     take place.  It is should check for inconsistencies from mount options
+     and it is also allowed to do preliminary resource acquisition.  For
+     instance, the core NFS module could load the NFS protocol module here.
+
+     Note that if mc->mount_type == MOUNT_TYPE_REMOUNT, some of the options
+     necessary for a new mount may not be set.
+
+     The return value is as for ->option().
+
+ (*) struct dentry *(*mount)(struct mount_context *mc);
+
+     Called to effect a new mount or new submount using the information stored
+     in the mount context (remounts go via a different vector).  It may detach
+     any resources it desires from the mount context and transfer them to the
+     superblock it creates.
+
+     On success it should return the dentry that's at the root of the mount.
+     In future, mc->root_path will then be applied to this.
+
+     In the case of an error, it should return a negative error code and set
+     mc->error.
+
+ (*) int (*fill_super)(struct super_block *s, struct mount_context *mc);
+
+     This is available to be used by things like mount_ns_mc() that are called
+     by ->mount() to transfer information/resources from the mount context to
+     the superblock.
+
+
+======================
+MOUNT CONTEXT SECURITY
+======================
+
+The mount context contains a security points that the LSMs can use for
+building up a security context for the superblock to be mounted.  There are a
+number of operations used by the new mount code for this purpose:
+
+ (*) int security_mount_ctx_alloc(struct mount_context *mc,
+				  struct super_block *src_sb);
+
+     Called to initialise mc->security (which is preset to NULL) and allocate
+     any resources needed.  It should return 0 on success and a negative error
+     code on failure.
+
+     src_sb is non-NULL in the case of a remount (MS_REMOUNT) in which case it
+     indicates the superblock to be remounted or in the case of a submount
+     (MS_SUBMOUNT) in which case it indicates the parent superblock.
+
+ (*) int security_mount_ctx_dup(struct mount_context *mc,
+				struct mount_context *src_mc);
+
+     Called to initialise mc->security (which is preset to NULL) and allocate
+     any resources needed.  The original mount context is pointed to by src_mc
+     and may be used for reference.  It should return 0 on success and a
+     negative error code on failure.
+
+ (*) void security_mount_ctx_free(struct mount_context *mc);
+
+     Called to clean up anything attached to mc->security.  Note that the
+     contents may have been transferred to a superblock and the pointer NULL'd
+     out during mount.
+
+ (*) int security_mount_ctx_option(struct mount_context *mc, char *opt);
+
+     Called for each mount option.  The mount options are in "key[=val]"
+     form.  An active LSM may reject one with an error, pass one over and
+     return 0 or consume one and return 1.  If consumed, the option isn't
+     passed on to the filesystem.
+
+     If it returns an error, it should set mc->error if the error is
+     ambiguous.
+
+ (*) int security_mount_ctx_kern_mount(struct mount_context *mc,
+				       struct super_block *sb);
+
+     Called during mount to verify that the specified superblock is allowed to
+     be mounted and to transfer the security data there.
+
+     On success, it should return 0; otherwise it should return an error and
+     set mc->error to indicate the problem.  It should not return -ENOMEM as
+     this should be taken care of in advance.
+
+     [NOTE] Should I add a security_mount_ctx_validate() operation so that the
+     LSM has the opportunity to allocate stuff and check the options as a
+     whole?
+
+
+============================
+VFS MOUNT CONTEXT OPERATIONS
+============================
+
+There are four operations for creating a mount context and one for destroying
+a context:
+
+ (*) struct mount_context *__vfs_fsopen(struct file_system_type *fs_type,
+					struct super_block *src_sb;
+					unsigned int ms_flags,
+					unsigned int mnt_flags);
+
+     Create a mount context given a filesystem type pointer.  This allocates
+     the mount context, sets the flags, initialises the security and calls
+     fs_type->fsopen() to initialise the filesystem context.
+
+     src_sb can be NULL or it may indicate a superblock that is going to be
+     remounted (MS_REMOUNT) or a superblock that is the parent of a submount
+     (MS_SUBMOUNT).  This superblock is provided as a source of namespace
+     information.
+
+ (*) struct mount_context *vfs_mntopen(struct vfsmount *mnt,
+				       unsigned int ms_flags,
+				       unsigned int mnt_flags);
+
+     Create a mount context from the same filesystem as an extant mount and
+     initialise the mount parameters from the superblock underlying that
+     mount.  This is used by remount.
+
+ (*) struct mount_context *vfs_fsopen(const char *fs_name);
+
+     Create a mount context given a filesystem name.  It is assumed that the
+     mount flags will be passed in as text options later.  This is intended to
+     be called from sys_fsopen().  This copies current's namespaces to the
+     mount context.
+
+ (*) struct mount_context *vfs_dup_mount_context(struct mount_context *src);
+
+     Duplicate a mount context, copying any options noted and duplicating or
+     additionally referencing any resources held therein.  This is available
+     for use where a filesystem has to get a mount within a mount, such as
+     NFS4 does by internally mounting the root of the target server and then
+     doing a private pathwalk to the target directory.
+
+ (*) void put_mount_context(struct mount_context *ctx);
+
+     Destroy a mount context, releasing any resources it holds.  This calls
+     the ->free() operation.  This is intended to be called by anyone who
+     created a mount context.
+
+     [!] Mount contexts are not refcounted, so this causes unconditional
+     	 destruction.
+
+In all the above operations, apart from the put op, the return is a mount
+context pointer or a negative error code.  No error string is saved as the
+error string is only guaranteed as long as the file_system_type is pinned (and
+thus the module).
+
+In the remaining operations, if an error occurs, a negative error code is
+returned and, if not obvious, mc->error should be set to point to a useful
+string.  The string should not be freed.
+
+ (*) struct vfsmount *vfs_kern_mount_mc(struct mount_context *mc);
+
+     Create a mount given the parameters in the specified mount context.  This
+     invokes the ->validate() op and then the ->mount() op.
+
+ (*) struct vfsmount *vfs_submount_mc(const struct dentry *mountpoint,
+				      struct mount_context *mc);
+
+     Create a mount given a mount context and set MS_SUBMOUNT on it.  A
+     wrapper around vfs_kern_mount_mc().  This is intended to be called from
+     filesystems that have automount points (NFS, AFS, ...).
+
+ (*) int vfs_mount_option(struct mount_context *mc, char *data);
+
+     Supply a single mount option to the mount context.  The mount option
+     should likely be in a "key[=val]" string form.  The option is first
+     checked to see if it corresponds to a standard mount flag (in which case
+     it is used to mark an MS_xxx flag and consumed) or a security option (in
+     which case the LSM consumes it) before it is passed on to the filesystem.
+
+ (*) int generic_monolithic_mount_data(struct mount_context *ctx, void *data);
+
+     Parse a sys_mount() data page, assuming the form to be a text list
+     consisting of key[=val] options separated by commas.  Each item in the
+     list is passed to vfs_mount_option().  This is the default when the
+     ->monolithic_mount_data() operation is NULL.
diff --git a/fs/Makefile b/fs/Makefile
index 7bbaca9c67b1..308a104a9a07 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,8 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
+		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
+		mount_context.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/internal.h b/fs/internal.h
index 076751d90ba2..ef8c5e93f364 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -87,7 +87,7 @@ extern struct file *get_empty_filp(void);
 /*
  * super.c
  */
-extern int do_remount_sb(struct super_block *, int, void *, int);
+extern int do_remount_sb(struct super_block *, int, void *, int, struct mount_context *);
 extern bool trylock_super(struct super_block *sb);
 extern struct dentry *mount_fs(struct file_system_type *,
 			       int, const char *, void *);
diff --git a/fs/mount.h b/fs/mount.h
index 2826543a131d..b1e99b38f2ee 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -108,9 +108,10 @@ static inline void detach_mounts(struct dentry *dentry)
 	__detach_mounts(dentry);
 }
 
-static inline void get_mnt_ns(struct mnt_namespace *ns)
+static inline struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns)
 {
 	atomic_inc(&ns->count);
+	return ns;
 }
 
 extern seqlock_t mount_lock;
diff --git a/fs/mount_context.c b/fs/mount_context.c
new file mode 100644
index 000000000000..7d765c100bf1
--- /dev/null
+++ b/fs/mount_context.c
@@ -0,0 +1,343 @@
+/* Provide a way to create a mount context within the kernel that can be
+ * configured before mounting.
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
+static const match_table_t common_set_mount_options = {
+	{ MS_DIRSYNC,		"dirsync" },
+	{ MS_I_VERSION,		"iversion" },
+	{ MS_LAZYTIME,		"lazytime" },
+	{ MS_MANDLOCK,		"mand" },
+	{ MS_NOATIME,		"noatime" },
+	{ MS_NODEV,		"nodev" },
+	{ MS_NODIRATIME,	"nodiratime" },
+	{ MS_NOEXEC,		"noexec" },
+	{ MS_NOSUID,		"nosuid" },
+	{ MS_POSIXACL,		"posixacl" },
+	{ MS_RDONLY,		"ro" },
+	{ MS_REC,		"rec" },
+	{ MS_RELATIME,		"relatime" },
+	{ MS_STRICTATIME,	"strictatime" },
+	{ MS_SYNCHRONOUS,	"sync" },
+	{ MS_VERBOSE,		"verbose" },
+	{ },
+};
+
+static const match_table_t common_clear_mount_options = {
+	{ MS_LAZYTIME,		"nolazytime" },
+	{ MS_MANDLOCK,		"nomand" },
+	{ MS_NODEV,		"dev" },
+	{ MS_NOEXEC,		"exec" },
+	{ MS_NOSUID,		"suid" },
+	{ MS_RDONLY,		"rw" },
+	{ MS_RELATIME,		"norelatime" },
+	{ MS_SILENT,		"silent" },
+	{ MS_STRICTATIME,	"nostrictatime" },
+	{ MS_SYNCHRONOUS,	"async" },
+	{ },
+};
+
+static const match_table_t forbidden_mount_options = {
+	{ MS_BIND,		"bind" },
+	{ MS_KERNMOUNT,		"ro" },
+	{ MS_MOVE,		"move" },
+	{ MS_PRIVATE,		"private" },
+	{ MS_REMOUNT,		"remount" },
+	{ MS_SHARED,		"shared" },
+	{ MS_SLAVE,		"slave" },
+	{ MS_UNBINDABLE,	"unbindable" },
+	{ },
+};
+
+/*
+ * Check for a common mount option.
+ */
+static noinline int vfs_common_mount_option(struct mount_context *mc, char *data)
+{
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int token;
+
+	token = match_token(data, common_set_mount_options, args);
+	if (token) {
+		mc->ms_flags |= token;
+		return 1;
+	}
+
+	token = match_token(data, common_clear_mount_options, args);
+	if (token) {
+		mc->ms_flags &= ~token;
+		return 1;
+	}
+
+	token = match_token(data, forbidden_mount_options, args);
+	if (token) {
+		mc->error = "Mount option, not superblock option";
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
+ * vfs_mount_option - Add a single mount option to a mount context
+ * @mc: The mount context to modify
+ * @option: The option to apply.
+ *
+ * A single mount option in string form is applied to the mount being set up in
+ * the mount context.  Certain standard options (for example "ro") are
+ * translated into flag bits without going to the filesystem.  The active
+ * security module allowed to observe and poach options.  Any other options are
+ * passed over to the filesystem to parse.
+ *
+ * This may be called multiple times for a context.
+ *
+ * Returns 0 on success and a negative error code on failure.  In the event of
+ * failure, mc->error may have been set to a non-allocated string that gives
+ * more information.
+ */
+int vfs_mount_option(struct mount_context *mc, char *data)
+{
+	int ret;
+
+	if (mc->mounted)
+		return -EBUSY;
+
+	ret = vfs_common_mount_option(mc, data);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	ret = security_mount_ctx_option(mc, data);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	return mc->ops->option(mc, data);
+}
+EXPORT_SYMBOL(vfs_mount_option);
+
+/**
+ * generic_monolithic_mount_data - Parse key[=val][,key[=val]]* mount data
+ * @mc: The mount context to populate
+ * @data: The data to parse
+ *
+ * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
+ * called from the ->monolithic_mount_data() mount context operation.
+ *
+ * Returns 0 on success or the error returned by the ->option() mount context
+ * operation on failure.
+ */
+int generic_monolithic_mount_data(struct mount_context *ctx, void *data)
+{
+	char *options = data, *p;
+	int ret;
+
+	if (!options)
+		return 0;
+
+	while ((p = strsep(&options, ",")) != NULL) {
+		if (*p) {
+			ret = vfs_mount_option(ctx, p);
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
+ * __vfs_fsopen - Open a filesystem and create a mount context
+ * @fs_type: The filesystem type
+ * @src_sb: A superblock from which this one derives (or NULL)
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @mnt_flags: Mountpoint flags, such as MNT_READONLY
+ * @mount_type: Type of mount
+ *
+ * Open a filesystem and create a mount context.  The mount context is
+ * initialised with the supplied flags and, if a submount/automount from
+ * another superblock (@src_sb), may have parameters such as namespaces copied
+ * across from that superblock.
+ */
+struct mount_context *__vfs_fsopen(struct file_system_type *fs_type,
+				   struct super_block *src_sb,
+				   unsigned int ms_flags, unsigned int mnt_flags,
+				   enum mount_type mount_type)
+{
+	struct mount_context *mc;
+	int ret;
+
+	if (fs_type->fsopen && fs_type->mc_size < sizeof(*mc))
+		BUG();
+
+	mc = kzalloc(max_t(size_t, fs_type->mc_size, sizeof(*mc)), GFP_KERNEL);
+	if (!mc)
+		return ERR_PTR(-ENOMEM);
+
+	mc->mount_type = mount_type;
+	mc->ms_flags = ms_flags;
+	mc->mnt_flags = mnt_flags;
+	mc->fs_type = fs_type;
+	get_filesystem(fs_type);
+	mc->mnt_ns = get_mnt_ns(current->nsproxy->mnt_ns);
+	mc->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	mc->net_ns = get_net(current->nsproxy->net_ns);
+	mc->user_ns = get_user_ns(current_user_ns());
+	mc->cred = get_current_cred();
+
+
+	/* TODO: Make all filesystems support this unconditionally */
+	if (mc->fs_type->fsopen) {
+		ret = mc->fs_type->fsopen(mc, src_sb);
+		if (ret < 0)
+			goto err_mc;
+	}
+
+	/* Do the security check last because ->fsopen may change the
+	 * namespace subscriptions.
+	 */
+	ret = security_mount_ctx_alloc(mc, src_sb);
+	if (ret < 0)
+		goto err_mc;
+
+	return mc;
+
+err_mc:
+	put_mount_context(mc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(__vfs_fsopen);
+
+/**
+ * vfs_fsopen - Open a filesystem and create a mount context
+ * @fs_name: The name of the filesystem
+ *
+ * Open a filesystem and create a mount context that will hold the mount
+ * options, device name, security details, etc..  Note that the caller should
+ * check the ->ops pointer in the returned context to determine whether the
+ * filesystem actually supports the mount context itself.
+ */
+struct mount_context *vfs_fsopen(const char *fs_name)
+{
+	struct file_system_type *fs_type;
+	struct mount_context *mc;
+
+	fs_type = get_fs_type(fs_name);
+	if (!fs_type)
+		return ERR_PTR(-ENODEV);
+
+	mc = __vfs_fsopen(fs_type, NULL, 0, 0, MOUNT_TYPE_NEW);
+	put_filesystem(fs_type);
+	return mc;
+}
+EXPORT_SYMBOL(vfs_fsopen);
+
+/**
+ * vfs_mntopen - Create a mount context and initialise it from an extant mount
+ * @mnt: The mountpoint to open
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @mnt_flags: Mountpoint flags, such as MNT_READONLY
+ * @mount_type: Type of mount
+ *
+ * Open a mounted filesystem and create a mount context such that a remount can
+ * be effected.
+ */
+struct mount_context *vfs_mntopen(struct vfsmount *mnt,
+				  unsigned int ms_flags,
+				  unsigned int mnt_flags,
+				  enum mount_type mount_type)
+{
+	return __vfs_fsopen(mnt->mnt_sb->s_type, mnt->mnt_sb,
+			    ms_flags, mnt_flags, mount_type);
+}
+
+/**
+ * vfs_dup_mount_context: Duplicate a mount context.
+ * @src: The mount context to copy.
+ */
+struct mount_context *vfs_dup_mount_context(struct mount_context *src)
+{
+	struct mount_context *mc;
+	int ret;
+
+	if (!src->ops->dup)
+		return ERR_PTR(-ENOTSUPP);
+
+	mc = kmemdup(src, src->fs_type->mc_size, GFP_KERNEL);
+	if (!mc)
+		return ERR_PTR(-ENOMEM);
+
+	mc->device	= NULL;
+	mc->root_path	= NULL;
+	mc->security	= NULL;
+	mc->error	= NULL;
+	get_filesystem(mc->fs_type);
+	get_mnt_ns(mc->mnt_ns);
+	get_pid_ns(mc->pid_ns);
+	get_net(mc->net_ns);
+	get_user_ns(mc->user_ns);
+	get_cred(mc->cred);
+
+	/* Can't call put until we've called ->dup */
+	ret = mc->ops->dup(mc, src);
+	if (ret < 0)
+		goto err_mc;
+
+	ret = security_mount_ctx_dup(mc, src);
+	if (ret < 0)
+		goto err_mc;
+	return mc;
+
+err_mc:
+	put_mount_context(mc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vfs_dup_mount_context);
+
+/*
+ * Dispose of a mount context.
+ */
+void put_mount_context(struct mount_context *mc)
+{
+	if (mc->ops && mc->ops->free)
+		mc->ops->free(mc);
+	security_mount_ctx_free(mc);
+	if (mc->mnt_ns)
+		put_mnt_ns(mc->mnt_ns);
+	if (mc->pid_ns)
+		put_pid_ns(mc->pid_ns);
+	if (mc->net_ns)
+		put_net(mc->net_ns);
+	put_user_ns(mc->user_ns);
+	if (mc->cred)
+		put_cred(mc->cred);
+	put_filesystem(mc->fs_type);
+	kfree(mc->device);
+	kfree(mc->root_path);
+	kfree(mc);
+}
+EXPORT_SYMBOL(put_mount_context);
diff --git a/fs/namespace.c b/fs/namespace.c
index db034b6afd43..e0edab9af308 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -25,6 +25,7 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/file.h>
 #include <linux/sched/task.h>
 
 #include "pnode.h"
@@ -783,9 +784,14 @@ static void put_mountpoint(struct mountpoint *mp)
 	}
 }
 
+static inline int __check_mnt(struct mount *mnt, struct mnt_namespace *mnt_ns)
+{
+	return mnt->mnt_ns == mnt_ns;
+}
+
 static inline int check_mnt(struct mount *mnt)
 {
-	return mnt->mnt_ns == current->nsproxy->mnt_ns;
+	return __check_mnt(mnt, current->nsproxy->mnt_ns);
 }
 
 /*
@@ -1596,7 +1602,7 @@ static int do_umount(struct mount *mnt, int flags)
 			return -EPERM;
 		down_write(&sb->s_umount);
 		if (!(sb->s_flags & MS_RDONLY))
-			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0);
+			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0, NULL);
 		up_write(&sb->s_umount);
 		return retval;
 	}
@@ -2279,6 +2285,26 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 }
 
 /*
+ * Parse the monolithic page of mount data given to sys_mount().
+ */
+static int parse_monolithic_mount_data(struct mount_context *mc, void *data)
+{
+	int (*monolithic_mount_data)(struct mount_context *, void *);
+	int ret;
+
+	monolithic_mount_data = mc->ops->monolithic_mount_data;
+	if (!monolithic_mount_data)
+		monolithic_mount_data = generic_monolithic_mount_data;
+
+	ret = monolithic_mount_data(mc, data);
+	if (ret < 0)
+		return ret;
+	if (mc->ops->validate)
+		return mc->ops->validate(mc);
+	return 0;
+}
+
+/*
  * change filesystem flags. dir should be a physical root of filesystem.
  * If you've mounted a non-root directory somewhere and want to do remount
  * on it - tough luck.
@@ -2286,13 +2312,14 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 static int do_remount(struct path *path, int flags, int mnt_flags,
 		      void *data)
 {
+	struct mount_context *mc = NULL;
 	int err;
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);
+	struct file_system_type *type = sb->s_type;
 
 	if (!check_mnt(mnt))
 		return -EINVAL;
-
 	if (path->dentry != path->mnt->mnt_root)
 		return -EINVAL;
 
@@ -2323,9 +2350,19 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		return -EPERM;
 	}
 
-	err = security_sb_remount(sb, data);
-	if (err)
-		return err;
+	if (type->fsopen) {
+		mc = vfs_mntopen(path->mnt, flags, mnt_flags, MOUNT_TYPE_REMOUNT);
+		if (IS_ERR(mc))
+			return PTR_ERR(mc);
+
+		err = parse_monolithic_mount_data(mc, data);
+		if (err < 0)
+			goto err_mc;
+	} else {
+		err = security_sb_remount(sb, data);
+		if (err)
+			return err;
+	}
 
 	down_write(&sb->s_umount);
 	if (flags & MS_BIND)
@@ -2333,7 +2370,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	else if (!capable(CAP_SYS_ADMIN))
 		err = -EPERM;
 	else
-		err = do_remount_sb(sb, flags, data, 0);
+		err = do_remount_sb(sb, flags, data, 0, mc);
 	if (!err) {
 		lock_mount_hash();
 		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
@@ -2342,6 +2379,9 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		unlock_mount_hash();
 	}
 	up_write(&sb->s_umount);
+err_mc:
+	if (mc)
+		put_mount_context(mc);
 	return err;
 }
 
@@ -2451,7 +2491,8 @@ static struct vfsmount *fs_set_subtype(struct vfsmount *mnt, const char *fstype)
 /*
  * add a mount into a namespace's mount tree
  */
-static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
+static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags,
+			struct mnt_namespace *mnt_ns)
 {
 	struct mountpoint *mp;
 	struct mount *parent;
@@ -2465,7 +2506,7 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 
 	parent = real_mount(path->mnt);
 	err = -EINVAL;
-	if (unlikely(!check_mnt(parent))) {
+	if (unlikely(!__check_mnt(parent, mnt_ns))) {
 		/* that's acceptable only for automounts done in private ns */
 		if (!(mnt_flags & MNT_SHRINKABLE))
 			goto unlock;
@@ -2493,42 +2534,73 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 }
 
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
+static int do_new_mount_mc(struct mount_context *mc, struct path *mountpoint,
+			   unsigned int mnt_flags);
 
 /*
  * create a new mount for userspace and request it to be added into the
  * namespace's tree
  */
-static int do_new_mount(struct path *path, const char *fstype, int flags,
+static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
-	struct file_system_type *type;
+	struct mount_context *mc;
 	struct vfsmount *mnt;
 	int err;
 
 	if (!fstype)
 		return -EINVAL;
 
-	type = get_fs_type(fstype);
-	if (!type)
-		return -ENODEV;
+	mc = vfs_fsopen(fstype);
+	if (IS_ERR(mc))
+		return PTR_ERR(mc);
+	mc->ms_flags = flags;
+	mc->mnt_flags = mnt_flags;
 
-	mnt = vfs_kern_mount(type, flags, name, data);
-	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype)
-		mnt = fs_set_subtype(mnt, fstype);
+	err = -ENOMEM;
+	mc->device = kstrdup(name, GFP_KERNEL);
+	if (!mc->device)
+		goto err_mc;
 
-	put_filesystem(type);
-	if (IS_ERR(mnt))
-		return PTR_ERR(mnt);
+	if (mc->ops) {
+		err = parse_monolithic_mount_data(mc, data);
+		if (err < 0)
+			goto err_mc;
 
-	if (mount_too_revealing(mnt, &mnt_flags)) {
-		mntput(mnt);
-		return -EPERM;
+		err = do_new_mount_mc(mc, mountpoint, mnt_flags);
+		if (err)
+			goto err_mc;
+
+	} else {
+		mnt = vfs_kern_mount(mc->fs_type, flags, name, data);
+		if (!IS_ERR(mnt) && (mc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+		    !mnt->mnt_sb->s_subtype)
+			mnt = fs_set_subtype(mnt, fstype);
+
+		if (IS_ERR(mnt)) {
+			err = PTR_ERR(mnt);
+			goto err_mc;
+		}
+
+		err = -EPERM;
+		if (mount_too_revealing(mnt, &mnt_flags))
+			goto err_mnt;
+
+		err = do_add_mount(real_mount(mnt), mountpoint, mnt_flags,
+				   mc->mnt_ns);
+		if (err)
+			goto err_mnt;
 	}
 
-	err = do_add_mount(real_mount(mnt), path, mnt_flags);
-	if (err)
-		mntput(mnt);
+	put_mount_context(mc);
+	return 0;
+
+err_mnt:
+	mntput(mnt);
+err_mc:
+	if (mc->error)
+		pr_info("Mount failed: %s\n", mc->error);
+	put_mount_context(mc);
 	return err;
 }
 
@@ -2547,7 +2619,8 @@ int finish_automount(struct vfsmount *m, struct path *path)
 		goto fail;
 	}
 
-	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE);
+	err = do_add_mount(mnt, path, path->mnt->mnt_flags | MNT_SHRINKABLE,
+			   current->nsproxy->mnt_ns);
 	if (!err)
 		return 0;
 fail:
@@ -3061,6 +3134,130 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
+static struct dentry *__do_mount_mc(struct mount_context *mc)
+{
+	struct super_block *sb;
+	struct dentry *root;
+	int ret;
+
+	root = mc->ops->mount(mc);
+	if (IS_ERR(root))
+		return root;
+
+	sb = root->d_sb;
+	BUG_ON(!sb);
+	WARN_ON(!sb->s_bdi);
+	sb->s_flags |= MS_BORN;
+
+	ret = security_mount_ctx_kern_mount(mc, sb);
+	if (ret < 0)
+		goto err_sb;
+
+	/*
+	 * filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
+	 * but s_maxbytes was an unsigned long long for many releases. Throw
+	 * this warning for a little while to try and catch filesystems that
+	 * violate this rule.
+	 */
+	WARN((sb->s_maxbytes < 0), "%s set sb->s_maxbytes to "
+		"negative value (%lld)\n", mc->fs_type->name, sb->s_maxbytes);
+
+	up_write(&sb->s_umount);
+	return root;
+
+err_sb:
+	dput(root);
+	deactivate_locked_super(sb);
+	return ERR_PTR(ret);
+}
+
+struct vfsmount *vfs_kern_mount_mc(struct mount_context *mc)
+{
+	struct dentry *root;
+	struct mount *mnt;
+	int ret;
+
+	if (mc->ops->validate) {
+		ret = mc->ops->validate(mc);
+		if (ret < 0)
+			return ERR_PTR(ret);
+	}
+
+	mnt = alloc_vfsmnt(mc->device ?: "none");
+	if (!mnt)
+		return ERR_PTR(-ENOMEM);
+
+	if (mc->ms_flags & MS_KERNMOUNT)
+		mnt->mnt.mnt_flags = MNT_INTERNAL;
+
+	root = __do_mount_mc(mc);
+	if (IS_ERR(root)) {
+		mnt_free_id(mnt);
+		free_vfsmnt(mnt);
+		return ERR_CAST(root);
+	}
+
+	mnt->mnt.mnt_root	= root;
+	mnt->mnt.mnt_sb		= root->d_sb;
+	mnt->mnt_mountpoint	= mnt->mnt.mnt_root;
+	mnt->mnt_parent		= mnt;
+	lock_mount_hash();
+	list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
+	unlock_mount_hash();
+	return &mnt->mnt;
+}
+EXPORT_SYMBOL_GPL(vfs_kern_mount_mc);
+
+struct vfsmount *
+vfs_submount_mc(const struct dentry *mountpoint, struct mount_context *mc)
+{
+	/* Until it is worked out how to pass the user namespace
+	 * through from the parent mount to the submount don't support
+	 * unprivileged mounts with submounts.
+	 */
+	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
+		return ERR_PTR(-EPERM);
+
+	mc->ms_flags = MS_SUBMOUNT;
+	return vfs_kern_mount_mc(mc);
+}
+EXPORT_SYMBOL_GPL(vfs_submount_mc);
+
+static int do_new_mount_mc(struct mount_context *mc, struct path *mountpoint,
+			   unsigned int mnt_flags)
+{
+	struct vfsmount *mnt;
+	int ret;
+
+	mnt = vfs_kern_mount_mc(mc);
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+
+	if ((mc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !mnt->mnt_sb->s_subtype) {
+		mnt = fs_set_subtype(mnt, mc->fs_type->name);
+		if (IS_ERR(mnt))
+			return PTR_ERR(mnt);
+	}
+
+	ret = -EPERM;
+	if (mount_too_revealing(mnt, &mnt_flags)) {
+		mc->error = "VFS: Mount too revealing";
+		goto err_mnt;
+	}
+
+	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags, mc->mnt_ns);
+	if (ret < 0) {
+		mc->error = "VFS: Failed to add mount";
+		goto err_mnt;
+	}
+	return ret;
+
+err_mnt:
+	mntput(mnt);
+	return ret;
+}
+
 /*
  * Return true if path is reachable from root
  *
@@ -3302,6 +3499,23 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
 }
 EXPORT_SYMBOL_GPL(kern_mount_data);
 
+struct vfsmount *kern_mount_data_mc(struct mount_context *mc)
+{
+	struct vfsmount *mnt;
+
+	mc->ms_flags = MS_KERNMOUNT;
+	mnt = vfs_kern_mount_mc(mc);
+	if (!IS_ERR(mnt)) {
+		/*
+		 * it is a longterm mount, don't release mnt until
+		 * we unmount before file sys is unregistered
+		*/
+		real_mount(mnt)->mnt_ns = MNT_NS_INTERNAL;
+	}
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(kern_mount_data_mc);
+
 void kern_unmount(struct vfsmount *mnt)
 {
 	/* release long term mount so mount point can be released */
diff --git a/fs/super.c b/fs/super.c
index adb0c0de428c..6e7b86520337 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -805,10 +805,13 @@ struct super_block *user_get_super(dev_t dev)
  *	@flags:	numeric part of options
  *	@data:	the rest of options
  *      @force: whether or not to force the change
+ *	@mc:	the mount context for filesystems that support it
+ *		(NULL if called from emergency or umount)
  *
  *	Alters the mount options of a mounted file system.
  */
-int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
+int do_remount_sb(struct super_block *sb, int flags, void *data, int force,
+		  struct mount_context *mc)
 {
 	int retval;
 	int remount_ro;
@@ -850,8 +853,14 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 		}
 	}
 
-	if (sb->s_op->remount_fs) {
-		retval = sb->s_op->remount_fs(sb, &flags, data);
+	if (sb->s_op->remount_fs_mc ||
+	    sb->s_op->remount_fs) {
+		if (sb->s_op->remount_fs_mc) {
+		    retval = sb->s_op->remount_fs_mc(sb, mc);
+		    flags = mc->ms_flags;
+		} else {
+			retval = sb->s_op->remount_fs(sb, &flags, data);
+		}
 		if (retval) {
 			if (!force)
 				goto cancel_readonly;
@@ -898,7 +907,7 @@ static void do_emergency_remount(struct work_struct *work)
 			/*
 			 * What lock protects sb->s_flags??
 			 */
-			do_remount_sb(sb, MS_RDONLY, NULL, 1);
+			do_remount_sb(sb, MS_RDONLY, NULL, 1, NULL);
 		}
 		up_write(&sb->s_umount);
 		spin_lock(&sb_lock);
@@ -1048,6 +1057,37 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(mount_ns);
 
+struct dentry *mount_ns_mc(struct mount_context *mc, void *ns)
+{
+	struct super_block *sb;
+
+	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
+	 * over the namespace.
+	 */
+	if (!(mc->ms_flags & MS_KERNMOUNT) &&
+	    !ns_capable(mc->user_ns, CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	sb = sget_userns(mc->fs_type, ns_test_super, ns_set_super,
+			 mc->ms_flags, mc->user_ns, ns);
+	if (IS_ERR(sb))
+		return ERR_CAST(sb);
+
+	if (!sb->s_root) {
+		int err;
+		err = mc->ops->fill_super(sb, mc);
+		if (err) {
+			deactivate_locked_super(sb);
+			return ERR_PTR(err);
+		}
+
+		sb->s_flags |= MS_ACTIVE;
+	}
+
+	return dget(sb->s_root);
+}
+EXPORT_SYMBOL(mount_ns_mc);
+
 #ifdef CONFIG_BLOCK
 static int set_bdev_super(struct super_block *s, void *data)
 {
@@ -1196,7 +1236,7 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 		}
 		s->s_flags |= MS_ACTIVE;
 	} else {
-		do_remount_sb(s, flags, data, 0);
+		do_remount_sb(s, flags, data, 0, NULL);
 	}
 	return dget(s->s_root);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 30e5c14bd743..40fe5c5054ec 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -55,6 +55,7 @@ struct workqueue_struct;
 struct iov_iter;
 struct fscrypt_info;
 struct fscrypt_operations;
+struct mount_context;
 
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
@@ -1786,6 +1792,7 @@ struct super_operations {
 	int (*unfreeze_fs) (struct super_block *);
 	int (*statfs) (struct dentry *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
+	int (*remount_fs_mc) (struct super_block *, struct mount_context *);
 	void (*umount_begin) (struct super_block *);
 
 	int (*show_options)(struct seq_file *, struct dentry *);
@@ -2020,8 +2027,10 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+	unsigned short mc_size;		/* Size of mount context to allocate */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
+	int (*fsopen)(struct mount_context *, struct super_block *);
 	void (*kill_sb) (struct super_block *);
 	struct module *owner;
 	struct file_system_type * next;
@@ -2039,6 +2048,7 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
+extern struct dentry *mount_ns_mc(struct mount_context *mc, void *ns);
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
@@ -2105,6 +2115,7 @@ extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
 #define kern_mount(type) kern_mount_data(type, NULL)
+extern struct vfsmount *kern_mount_data_mc(struct mount_context *);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index e29d4c62a3c8..f6aa68b8e68e 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -75,6 +75,32 @@
  *	should enable secure mode.
  *	@bprm contains the linux_binprm structure.
  *
+ * Security hooks for mount using fd context.
+ *
+ * @mount_ctx_alloc:
+ *	Allocate and attach a security structure to mc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@mc indicates the new mount context.
+ *	@src_sb indicates the source superblock of a submount.
+ * @mount_ctx_dup:
+ *	Allocate and attach a security structure to mc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@mc indicates the new mount context.
+ *	@src_mc indicates the original mount context.
+ * @mount_ctx_free:
+ *	Clean up a mount context.
+ *	@mc indicates the mount context.
+ * @mount_ctx_option:
+ *	Userspace provided an option to configure a mount.  The LSM may reject
+ *	it with an error and may use it for itself, in which case it should
+ *	return 1; otherwise it should return 0 to pass it on to the filesystem.
+ *	@mc indicates the mount context.
+ *	@p indicates the option in "key[=val]" form.
+ * @mount_ctx_kern_mount:
+ *	Equivalent of sb_kern_mount, but with a mount_context.
+ *	@mc indicates the mount context.
+ *	@src_sb indicates the new superblock.
+ *
  * Security hooks for filesystem operations.
  *
  * @sb_alloc_security:
@@ -1358,6 +1384,12 @@ union security_list_options {
 	void (*bprm_committing_creds)(struct linux_binprm *bprm);
 	void (*bprm_committed_creds)(struct linux_binprm *bprm);
 
+	int (*mount_ctx_alloc)(struct mount_context *mc, struct super_block *src_sb);
+	int (*mount_ctx_dup)(struct mount_context *mc, struct mount_context *src_mc);
+	void (*mount_ctx_free)(struct mount_context *mc);
+	int (*mount_ctx_option)(struct mount_context *mc, char *opt);
+	int (*mount_ctx_kern_mount)(struct mount_context *mc, struct super_block *sb);
+
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
@@ -1666,6 +1698,11 @@ struct security_hook_heads {
 	struct list_head bprm_secureexec;
 	struct list_head bprm_committing_creds;
 	struct list_head bprm_committed_creds;
+	struct list_head mount_ctx_alloc;
+	struct list_head mount_ctx_dup;
+	struct list_head mount_ctx_free;
+	struct list_head mount_ctx_option;
+	struct list_head mount_ctx_kern_mount;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 8e0352af06b7..cf2583406986 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -69,6 +69,56 @@ struct vfsmount {
 	int mnt_flags;
 };
 
+struct mount_context;
+struct mount_context_operations {
+	void (*free)(struct mount_context *mc);
+	int (*dup)(struct mount_context *mc, struct mount_context *src);
+	/* An option has been specified. */
+	int (*option)(struct mount_context *mc, char *p);
+	/* Parse monolithic mount data. */
+	int (*monolithic_mount_data)(struct mount_context *mc, void *data);
+	/* Validate the mount options */
+	int (*validate)(struct mount_context *mc);
+	/* Perform the mount. */
+	struct dentry *(*mount)(struct mount_context *mc);
+	/* Fill in a superblock */
+	int (*fill_super)(struct super_block *s, struct mount_context *mc);
+};
+
+enum mount_type {
+	MOUNT_TYPE_NEW,		/* New mount made directly */
+	MOUNT_TYPE_SUBMOUNT,	/* New mount made automatically */
+	MOUNT_TYPE_REMOUNT,	/* Change of an existing mount */
+};
+
+/*
+ * Mount context as allocated and constructed by fsopen().  The filesystem must
+ * support the ->ctx_*() operations.  The size of the object allocated is in
+ * struct file_system_type::mount_context_size; this must be embedded as the
+ * fist thing in the filesystem's own context.
+ */
+struct mount_context {
+	const struct mount_context_operations *ops;
+	struct file_system_type	*fs_type;
+	struct user_namespace	*user_ns;	/* The user namespace for this mount */
+	struct mnt_namespace	*mnt_ns;	/* The mount namespace for this mount */
+	struct pid_namespace	*pid_ns;	/* The process ID namespace for this mount */
+	struct net		*net_ns;	/* The network namespace for this mount */
+	const struct cred	*cred;		/* The mounter's credentials */
+	char			*device;	/* The device name or mount target */
+	char			*root_path;	/* The path within the mount to mount */
+	void			*security;	/* The LSM context */
+	const char		*error;		/* Error string to be read by read() */
+	unsigned int		ms_flags;	/* The superblock flags (MS_*) */
+	unsigned int		mnt_flags;	/* The mount flags (MNT_*) */
+	bool			mounted;	/* Set when mounted */
+	bool			sloppy;		/* Unrecognised options are okay */
+	bool			silent;
+	enum mount_type		mount_type : 8;
+};
+
+extern const struct file_operations fs_fs_fops;
+
 struct file; /* forward dec */
 struct path;
 
@@ -90,9 +140,26 @@ struct file_system_type;
 extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 				      int flags, const char *name,
 				      void *data);
+extern struct vfsmount *vfs_kern_mount_mc(struct mount_context *mc);
 extern struct vfsmount *vfs_submount(const struct dentry *mountpoint,
 				     struct file_system_type *type,
 				     const char *name, void *data);
+extern struct vfsmount *vfs_submount_mc(const struct dentry *mountpoint,
+					struct mount_context *mc);
+extern struct mount_context *vfs_fsopen(const char *fs_name);
+extern struct mount_context *__vfs_fsopen(struct file_system_type *fs_type,
+					  struct super_block *src_sb,
+					  unsigned int ms_flags,
+					  unsigned int mnt_flags,
+					  enum mount_type mount_type);
+extern struct mount_context *vfs_mntopen(struct vfsmount *mnt,
+					 unsigned int ms_flags,
+					 unsigned int mnt_flags,
+					 enum mount_type mount_type);
+extern struct mount_context *vfs_dup_mount_context(struct mount_context *src);
+extern int vfs_mount_option(struct mount_context *mc, char *data);
+extern int generic_monolithic_mount_data(struct mount_context *ctx, void *data);
+extern void put_mount_context(struct mount_context *ctx);
 
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
diff --git a/include/linux/security.h b/include/linux/security.h
index 96899fad7016..91efe3039bff 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -55,6 +55,7 @@ struct msg_queue;
 struct xattr;
 struct xfrm_sec_ctx;
 struct mm_struct;
+struct mount_context;
 
 /* If capable should audit the security request */
 #define SECURITY_CAP_NOAUDIT 0
@@ -220,6 +221,11 @@ int security_bprm_check(struct linux_binprm *bprm);
 void security_bprm_committing_creds(struct linux_binprm *bprm);
 void security_bprm_committed_creds(struct linux_binprm *bprm);
 int security_bprm_secureexec(struct linux_binprm *bprm);
+int security_mount_ctx_alloc(struct mount_context *mc, struct super_block *sb);
+int security_mount_ctx_dup(struct mount_context *mc, struct mount_context *src);
+void security_mount_ctx_free(struct mount_context *mc);
+int security_mount_ctx_option(struct mount_context *mc, char *opt);
+int security_mount_ctx_kern_mount(struct mount_context *mc, struct super_block *sb);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -513,6 +519,29 @@ static inline int security_bprm_secureexec(struct linux_binprm *bprm)
 	return cap_bprm_secureexec(bprm);
 }
 
+static inline int security_mount_ctx_alloc(struct mount_context *mc,
+					   struct super_block *src_sb)
+{
+	return 0;
+}
+static inline int security_mount_ctx_dup(struct mount_context *mc,
+					 struct mount_context *src)
+{
+	return 0;
+}
+static inline void security_mount_ctx_free(struct mount_context *mc)
+{
+}
+static inline int security_mount_ctx_option(struct mount_context *mc, char *opt)
+{
+	return 0;
+}
+static inline int security_mount_ctx_kern_mount(struct mount_context *mc,
+						struct super_block *sb)
+{
+	return 0;
+}
+
 static inline int security_sb_alloc(struct super_block *sb)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index 23555c5504f6..2e522361df66 100644
--- a/security/security.c
+++ b/security/security.c
@@ -309,6 +309,31 @@ int security_bprm_secureexec(struct linux_binprm *bprm)
 	return call_int_hook(bprm_secureexec, 0, bprm);
 }
 
+int security_mount_ctx_alloc(struct mount_context *mc, struct super_block *src_sb)
+{
+	return call_int_hook(mount_ctx_alloc, 0, mc, src_sb);
+}
+
+int security_mount_ctx_dup(struct mount_context *mc, struct mount_context *src_mc)
+{
+	return call_int_hook(mount_ctx_dup, 0, mc, src_mc);
+}
+
+void security_mount_ctx_free(struct mount_context *mc)
+{
+	call_void_hook(mount_ctx_free, mc);
+}
+
+int security_mount_ctx_option(struct mount_context *mc, char *opt)
+{
+	return call_int_hook(mount_ctx_option, 0, mc, opt);
+}
+
+int security_mount_ctx_kern_mount(struct mount_context *mc, struct super_block *sb)
+{
+	return call_int_hook(mount_ctx_kern_mount, 0, mc, sb);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
@@ -1659,6 +1684,13 @@ struct security_hook_heads security_hook_heads = {
 		LIST_HEAD_INIT(security_hook_heads.bprm_committing_creds),
 	.bprm_committed_creds =
 		LIST_HEAD_INIT(security_hook_heads.bprm_committed_creds),
+	.mount_ctx_alloc = LIST_HEAD_INIT(security_hook_heads.mount_ctx_alloc),
+	.mount_ctx_dup = LIST_HEAD_INIT(security_hook_heads.mount_ctx_dup),
+	.mount_ctx_free = LIST_HEAD_INIT(security_hook_heads.mount_ctx_free),
+	.mount_ctx_option =
+		LIST_HEAD_INIT(security_hook_heads.mount_ctx_option),
+	.mount_ctx_kern_mount =
+		LIST_HEAD_INIT(security_hook_heads.mount_ctx_kern_mount),
 	.sb_alloc_security =
 		LIST_HEAD_INIT(security_hook_heads.sb_alloc_security),
 	.sb_free_security =
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 0c2ac318aa7f..cf38db840f71 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2826,6 +2826,179 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
 				   FILESYSTEM__UNMOUNT, NULL);
 }
 
+/* fsopen mount context operations */
+
+static int selinux_mount_ctx_alloc(struct mount_context *mc,
+				   struct super_block *src_sb)
+{
+	struct security_mnt_opts *opts;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+
+	mc->security = opts;
+	return 0;
+}
+
+static int selinux_mount_ctx_dup(struct mount_context *mc,
+				 struct mount_context *src_mc)
+{
+	const struct security_mnt_opts *src = src_mc->security;
+	struct security_mnt_opts *opts;
+	int i, n;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+	mc->security = opts;
+
+	if (!src || !src->num_mnt_opts)
+		return 0;
+	n = opts->num_mnt_opts = src->num_mnt_opts;
+
+	if (opts->mnt_opts) {
+		opts->mnt_opts = kcalloc(n, sizeof(char *), GFP_KERNEL);
+		if (!opts->mnt_opts)
+			return -ENOMEM;
+
+		for (i = 0; i < n; i++) {
+			if (src->mnt_opts[i]) {
+				opts->mnt_opts[i] = kstrdup(src->mnt_opts[i],
+							    GFP_KERNEL);
+				if (!opts->mnt_opts[i])
+					return -ENOMEM;
+			}
+		}
+	}
+
+	if (src->mnt_opts_flags) {
+		opts->mnt_opts_flags = kmemdup(src->mnt_opts_flags,
+					       n * sizeof(int), GFP_KERNEL);
+		if (!opts->mnt_opts_flags)
+			return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void selinux_mount_ctx_free(struct mount_context *mc)
+{
+	struct security_mnt_opts *opts = mc->security;
+
+	security_free_mnt_opts(opts);
+	mc->security = NULL;
+}
+
+static int selinux_mount_ctx_option(struct mount_context *mc, char *opt)
+{
+	struct security_mnt_opts *opts = mc->security;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int have;
+	char *c, **oo;
+	void *old;
+	int token, ctx, i;
+
+	token = match_token(opt, tokens, args);
+	if (token == Opt_error)
+		return 0; /* Doesn't belong to us. */
+
+	have = 0;
+	for (i = 0; i < opts->num_mnt_opts; i++)
+		have |= 1 << opts->mnt_opts_flags[i];
+	if (have & (1 << token)) {
+		mc->error = "SELinux: Duplicate mount options";
+		return -EINVAL;
+	}
+
+	switch (token) {
+	case Opt_context:
+		if (have & (1 << Opt_defcontext))
+			goto incompatible;
+		ctx = CONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_fscontext:
+		ctx = FSCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_rootcontext:
+		ctx = ROOTCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_defcontext:
+		if (have & (1 << Opt_context))
+			goto incompatible;
+		ctx = DEFCONTEXT_MNT;
+		goto copy_context_string;
+
+	case Opt_labelsupport:
+		return 1;
+
+	default:
+		mc->error = "SELinux: Unknown mount option";
+		return -EINVAL;
+	}
+
+copy_context_string:
+	if (opts->num_mnt_opts > 3) {
+		mc->error = "SELinux: Too many options";
+		return -EINVAL;
+	}
+	if (!opts->mnt_opts_flags) {
+		opts->mnt_opts_flags = kcalloc(3, sizeof(int), GFP_KERNEL);
+		if (!opts->mnt_opts_flags)
+			return -ENOMEM;
+	}
+
+	if (opts->mnt_opts) {
+		oo = kmalloc((opts->num_mnt_opts + 1) * sizeof(char *),
+			     GFP_KERNEL);
+		if (!oo)
+			return -ENOMEM;
+		memcpy(oo, opts->mnt_opts, opts->num_mnt_opts * sizeof(char *));
+		oo[opts->num_mnt_opts] = NULL;
+		old = opts->mnt_opts;
+		opts->mnt_opts = oo;
+		kfree(old);
+	}
+
+	c = match_strdup(&args[0]);
+	if (!c)
+		return -ENOMEM;
+	opts->mnt_opts[opts->num_mnt_opts] = c;
+	opts->mnt_opts_flags[opts->num_mnt_opts] = ctx;
+	opts->num_mnt_opts++;
+	return 1;
+
+incompatible:
+	mc->error = "SELinux: Incompatible mount options";
+	return -EINVAL;
+}
+
+static int selinux_mount_ctx_kern_mount(struct mount_context *mc,
+					struct super_block *sb)
+{
+	const struct cred *cred = current_cred();
+	struct common_audit_data ad;
+	int rc;
+
+	rc = selinux_set_mnt_opts(sb, mc->security, 0, NULL);
+	if (rc)
+		return rc;
+
+	/* Allow all mounts performed by the kernel */
+	if (mc->ms_flags & MS_KERNMOUNT)
+		return 0;
+
+	ad.type = LSM_AUDIT_DATA_DENTRY;
+	ad.u.dentry = sb->s_root;
+	rc = superblock_has_perm(cred, sb, FILESYSTEM__MOUNT, &ad);
+	if (rc < 0)
+		mc->error = "SELinux: Mount of superblock not permitted";
+	return rc;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6131,6 +6304,12 @@ static struct security_hook_list selinux_hooks[] = {
 	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
 	LSM_HOOK_INIT(bprm_secureexec, selinux_bprm_secureexec),
 
+	LSM_HOOK_INIT(mount_ctx_alloc, selinux_mount_ctx_alloc),
+	LSM_HOOK_INIT(mount_ctx_dup, selinux_mount_ctx_dup),
+	LSM_HOOK_INIT(mount_ctx_free, selinux_mount_ctx_free),
+	LSM_HOOK_INIT(mount_ctx_option, selinux_mount_ctx_option),
+	LSM_HOOK_INIT(mount_ctx_kern_mount, selinux_mount_ctx_kern_mount),
+
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),

