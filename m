Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42542 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758734AbdEVPw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 11:52:56 -0400
Subject: [PATCH 07/23] VFS: Introduce the structs and doc for a superblock
 configuration context [ver #4]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 22 May 2017 16:52:34 +0100
Message-ID: <149546835474.9289.14335424847927754343.stgit@warthog.procyon.org.uk>
In-Reply-To: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
References: <149546825563.9289.9065118651584207610.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a superblock configuration context concept to be used during
superblock creation for mount and superblock reconfiguration for remount.
This is allocated at the beginning of the mount procedure and into it is
placed:

 (1) Filesystem type.

 (2) Namespaces.

 (3) Device name.

 (4) Superblock flags (MS_*).

 (5) Security details.

 (6) Filesystem-specific data, as set by the mount options.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/mounting.txt |  470 ++++++++++++++++++++++++++++++++
 include/linux/sb_config.h              |   72 +++++
 2 files changed, 542 insertions(+)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 include/linux/sb_config.h

diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
new file mode 100644
index 000000000000..077ac8352323
--- /dev/null
+++ b/Documentation/filesystems/mounting.txt
@@ -0,0 +1,470 @@
+			      ===================
+			      FILESYSTEM MOUNTING
+			      ===================
+
+CONTENTS
+
+ (1) Overview.
+
+ (2) The superblock configuration context.
+
+ (3) The superblock config operations.
+
+ (4) Superblock config security.
+
+ (5) VFS superblock config operations.
+
+
+========
+OVERVIEW
+========
+
+The creation of new mounts is now to be done in a multistep process:
+
+ (1) Create a superblock configuration context.
+
+ (2) Parse the options and attach them to the context.  Options may be passed
+     individually from userspace.
+
+ (3) Validate and pre-process the context.
+
+ (4) Get or create a superblock and mountable root.
+
+ (5) Perform the mount.
+
+ (6) Return an error message attached to the context.
+
+ (7) Destroy the context.
+
+To support this, the file_system_type struct gains two new fields:
+
+	unsigned short sb_config_size;
+
+which indicates the total amount of space that should be allocated for context
+data (see the Superblock Configuration Context section), and:
+
+	int (*init_sb_config)(struct sb_config *sc, struct super_block *src_sb);
+
+which is invoked to set up the filesystem-specific parts of a superblock
+configuration context, including the additional space.  The src_sb parameter is
+used to convey the superblock from which the filesystem may draw extra
+information (such as namespaces), for submount (SB_CONFIG_FOR_SUBMOUNT) or
+remount (SB_CONFIG_FOR_REMOUNT) purposes or it will be NULL.
+
+Note that security initialisation is done *after* the filesystem is called so
+that the namespaces may be adjusted first.
+
+And the super_operations struct gains one:
+
+	int (*remount_fs_sc) (struct super_block *, struct sb_config *);
+
+This shadows the ->remount_fs() operation and takes a prepared superblock
+configuration context instead of the mount flags and data page.  It may modify
+the ms_flags in the context for the caller to pick up.
+
+[NOTE] remount_fs_sc is intended as a replacement for remount_fs.
+
+
+====================================
+THE SUPERBLOCK CONFIGURATION CONTEXT
+====================================
+
+The creation and reconfiguration of a superblock is governed by a superblock
+configuration context.  This is represented by the sb_config structure:
+
+	struct sb_config {
+		const struct sb_config_operations *ops;
+		struct file_system_type *fs;
+		struct dentry		*root;
+		struct user_namespace	*user_ns;
+		struct net		*net_ns;
+		const struct cred	*cred;
+		char			*device;
+		void			*security;
+		const char		*error_msg;
+		unsigned int		ms_flags;
+		bool			sloppy;
+		bool			silent;
+		bool			degraded;
+		enum mount_type		mount_type : 8;
+	};
+
+When the VFS creates this, it allocates ->sb_config_size bytes (as specified by
+the file_system_type object) to hold both the sb_config struct and any extra
+data required by the filesystem.  The sb_config struct is placed at the
+beginning of this space.  Any extra space beyond that is for use by the
+filesystem.  The filesystem should wrap the struct in its own, e.g.:
+
+	struct nfs_sb_config {
+		struct sb_config sc;
+		...
+	};
+
+placing the sb_config struct first.  container_of() can then be used.  The
+file_system_type would be initialised thus:
+
+	struct file_system_type nfs = {
+		...
+		.sb_config_size	= sizeof(struct nfs_sb_config),
+		.init_sb_config	= nfs_init_sb_config,
+		...
+	};
+
+The sb_config fields are as follows:
+
+ (*) const struct sb_config_operations *ops
+
+     These are operations that can be done on a superblock configuration
+     context (see below).  This must be set by the ->init_sb_config()
+     file_system_type operation.
+
+ (*) struct file_system_type *fs
+
+     A pointer to the file_system_type of the filesystem that is being
+     constructed or reconfigured.  This retains a ref on the type owner.
+
+ (*) struct dentry *root
+
+     A pointer to the root of the mountable tree (and indirectly, the
+     superblock thereof).  This is filled in by the ->get_tree() op.
+
+ (*) struct user_namespace *user_ns
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
+ (*) void *security
+
+     A place for the LSMs to hang their security data for the superblock.  The
+     relevant security operations are described below.
+
+ (*) const char *error_msg
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
+     Use sb_cfg_error() and sb_cfg_inval() to set this rather than setting it
+     directly.
+
+ (*) unsigned int ms_flags
+
+     This holds the MS_* flags mount flags.
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
+ (*) bool degraded
+
+     This is set if any preallocated resources in the configuration have been
+     used up, thereby rendering the configuration unreusable for the
+     ->get_tree() op.
+
+ (*) enum mount_type
+
+     This indicates the type of mount operation.  The available values are:
+
+	SB_CONFIG_FOR_NEW	-- New mount
+	SB_CONFIG_FOR_SUBMOUNT	-- New automatic submount of extant mount
+	SB_CONFIG_FOR_REMOUNT	-- Change an existing mount
+
+The mount context is created by calling __vfs_new_sb_config(),
+vfs_new_sb_config(), vfs_sb_reconfig() or vfs_dup_sb_config() and is destroyed
+with put_sb_config().  Note that the structure is not refcounted.
+
+VFS, security and filesystem mount options are set individually with
+vfs_parse_mount_option() or in bulk with generic_monolithic_mount_data().
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
+================================
+THE SUPERBLOCK CONFIG OPERATIONS
+================================
+
+The superblock configuration context points to a table of operations:
+
+	struct sb_config_operations {
+		void (*free)(struct sb_config *sc);
+		int (*dup)(struct sb_config *sc, struct sb_config *src_sc);
+		int (*parse_option)(struct sb_config *sc, char *p);
+		int (*monolithic_mount_data)(struct sb_config *sc, void *data);
+		int (*validate)(struct sb_config *sc);
+		int (*get_tree)(struct sb_config *sc);
+	};
+
+These operations are invoked by the various stages of the mount procedure to
+manage the superblock configuration context.  They are as follows:
+
+ (*) void (*free)(struct sb_config *sc);
+
+     Called to clean up the filesystem-specific part of the superblock
+     configuration context when the context is destroyed.  It should be aware
+     that parts of the context may have been removed and NULL'd out by
+     ->mount().
+
+ (*) int (*dup)(struct sb_config *sc, struct sb_config *src_sc);
+
+     Called when a superblock configuration context has been duplicated to get
+     any refs or copy any non-referenced resources held in the
+     filesystem-specific part of the superblock configuration context.  An
+     error may be returned to indicate failure to do this.
+
+     [!] Note that even if this fails, put_sb_config() will be called
+	 immediately thereafter, so ->dup() *must* make the filesystem-specific
+	 part safe for ->free().
+
+ (*) int (*parse_option)(struct sb_config *sc, char *p);
+
+     Called when an option is to be added to the superblock configuration
+     context.  p points to the option string, likely in "key[=val]" format.
+     VFS-specific options will have been weeded out and sc->ms_flags updated in
+     the context.  Security options will also have been weeded out and
+     sc->security updated.
+
+     If successful, 0 should be returned and a negative error code otherwise.
+     If an ambiguous error (such as -EINVAL) is returned, sb_cfg_error() or
+     sb_cfg_inval() should be used to provide a string that provides more
+     information.
+
+ (*) int (*monolithic_mount_data)(struct sb_config *sc, void *data);
+
+     Called when the mount(2) system call is invoked to pass the entire data
+     page in one go.  If this is expected to be just a list of "key[=val]"
+     items separated by commas, then this may be set to NULL.
+
+     The return value is as for ->parse_option().
+
+     If the filesystem (eg. NFS) needs to examine the data first and then
+     finds it's the standard key-val list then it may pass it off to:
+
+	int generic_monolithic_mount_data(struct sb_config *sc, void *data);
+
+ (*) int (*validate)(struct sb_config *sc);
+
+     Called when all the options have been applied and the mount is about to
+     take place.  It is should check for inconsistencies from mount options
+     and it is also allowed to do preliminary resource acquisition.  For
+     instance, the core NFS module could load the NFS protocol module here.
+
+     Note that if sc->mount_type == SB_CONFIG_FOR_REMOUNT, some of the options
+     necessary for a new mount may not be set.
+
+     The return value is as for ->parse_option().
+
+ (*) int (*get_tree)(struct sb_config *sc);
+
+     Called to get or create the mountable root and superblock, using the
+     information stored in the superblock configuration context (remounts go
+     via a different vector).  It may detach any resources it desires from the
+     superblock configuration context and transfer them to the superblock it
+     creates.
+
+     On success it should set sc->root to the mountable root.
+
+     In the case of an error, it should return a negative error code and
+     consider invoking sb_cfg_inval() or sb_cfg_error().
+
+
+=========================================
+SUPERBLOCK CONFIGURATION CONTEXT SECURITY
+========================================
+
+The superblock configuration context contains a security points that the LSMs can use for
+building up a security context for the superblock to be mounted.  There are a
+number of operations used by the new mount code for this purpose:
+
+ (*) int security_sb_config_alloc(struct sb_config *sc,
+				  struct super_block *src_sb);
+
+     Called to initialise sc->security (which is preset to NULL) and allocate
+     any resources needed.  It should return 0 on success and a negative error
+     code on failure.
+
+     src_sb is non-NULL in the case of a remount (SB_CONFIG_FOR_REMOUNT) in
+     which case it indicates the superblock to be remounted or in the case of a
+     submount (SB_CONFIG_FOR_SUBMOUNT) in which case it indicates the parent
+     superblock.
+
+ (*) int security_sb_config_dup(struct sb_config *sc,
+				struct sb_config *src_mc);
+
+     Called to initialise sc->security (which is preset to NULL) and allocate
+     any resources needed.  The original superblock configuration context is pointed to by src_mc
+     and may be used for reference.  It should return 0 on success and a
+     negative error code on failure.
+
+ (*) void security_sb_config_free(struct sb_config *sc);
+
+     Called to clean up anything attached to sc->security.  Note that the
+     contents may have been transferred to a superblock and the pointer NULL'd
+     out during mount.
+
+ (*) int security_sb_config_parse_option(struct sb_config *sc, char *opt);
+
+     Called for each mount option.  The mount options are in "key[=val]"
+     form.  An active LSM may reject one with an error, pass one over and
+     return 0 or consume one and return 1.  If consumed, the option isn't
+     passed on to the filesystem.
+
+     If it returns an error, more information can be returned with
+     sb_cfg_inval() or sb_cfg_error().
+
+ (*) int security_sb_get_tree(struct sb_config *sc);
+
+     Called during the mount procedure to verify that the specified superblock
+     is allowed to be mounted and to transfer the security data there.
+
+     On success, it should return 0; otherwise it should return an error and
+     perhaps call sb_cfg_inval() or sb_cfg_error() to indicate the problem.  It
+     should not return -ENOMEM as this should be taken care of in advance.
+
+     [NOTE] Should I add a security_sb_config_validate() operation so that the
+     LSM has the opportunity to allocate stuff and check the options as a
+     whole?
+
+
+================================
+VFS SUPERBLOCK CONFIG OPERATIONS
+================================
+
+There are four operations for creating a superblock configuration context and
+one for destroying a context:
+
+ (*) struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
+					   struct super_block *src_sb;
+					   unsigned int ms_flags);
+
+     Create a superblock configuration context given a filesystem type pointer.
+     This allocates the superblock configuration context, sets the flags,
+     initialises the security and calls fs_type->init_sb_config() to initialise
+     the filesystem context.
+
+     src_sb can be NULL or it may indicate a superblock that is going to be
+     remounted (SB_CONFIG_FOR_REMOUNT) or a superblock that is the parent of a
+     submount (SB_CONFIG_FOR_SUBMOUNT).  This superblock is provided as a
+     source of namespace information.
+
+ (*) struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
+				       unsigned int ms_flags);
+
+     Create a superblock configuration context from the same filesystem as an
+     extant mount and initialise the mount parameters from the superblock
+     underlying that mount.  This is for use by remount.
+
+ (*) struct sb_config *vfs_new_sb_config(const char *fs_name);
+
+     Create a superblock configuration context given a filesystem name.  It is
+     assumed that the mount flags will be passed in as text options or set
+     directly later.  This is intended to be called from sys_mount() or
+     sys_fsopen().  This copies current's namespaces to the superblock
+     configuration context.
+
+ (*) struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc);
+
+     Duplicate a superblock configuration context, copying any options noted
+     and duplicating or additionally referencing any resources held therein.
+     This is available for use where a filesystem has to get a mount within a
+     mount, such as NFS4 does by internally mounting the root of the target
+     server and then doing a private pathwalk to the target directory.
+
+ (*) void put_sb_config(struct sb_config *sc);
+
+     Destroy a superblock configuration context, releasing any resources it
+     holds.  This calls the ->free() operation.  This is intended to be called
+     by anyone who created a superblock configuration context.
+
+     [!] superblock configuration contexts are not refcounted, so this causes
+	 unconditional destruction.
+
+In all the above operations, apart from the put op, the return is a mount
+context pointer or a negative error code.  No error string is saved as the
+error string is only guaranteed as long as the file_system_type is pinned (and
+thus the module).
+
+The next operations can be used to cache an error message in the context for
+the caller to collect.
+
+ (*) void sb_cfg_error(struct sb_config *sc, const char *msg);
+
+     Set an error message for the caller to pick up.  For lifetime rules, see
+     the ->error_msg member description.
+
+ (*) void sb_cfg_inval(struct sb_config *sc, const char *msg);
+
+     As sb_cfg_error(), but returns -EINVAL for use with tail calling.
+
+In the remaining operations, if an error occurs, a negative error code is
+returned and, if not obvious, sc->error_msg may have been set to point to a
+useful string.  This string should not be freed.
+
+ (*) int vfs_get_tree(struct sb_config *sc);
+
+     Get or create the mountable root and superblock, using the parameters in
+     the parsed configuration to select/configure the superblock.  This invokes
+     the ->validate() op and then the ->get_tree() op.
+
+     [NOTE] ->validate() can probably be rolled into ->get_tree() and
+     ->remount_fs_sc().
+
+ (*) struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
+
+     Create a mount given the parameters in the specified superblock
+     configuration context.
+
+ (*) struct vfsmount *vfs_submount_sc(const struct dentry *mountpoint,
+				      struct sb_config *sc);
+
+     Create a mount given a superblock configuration context and set
+     MS_SUBMOUNT on it.  A wrapper around vfs_kern_mount_sc().  This is
+     intended to be called from filesystems that have automount points (NFS,
+     AFS, ...).
+
+ (*) int vfs_parse_mount_option(struct sb_config *sc, char *data);
+
+     Supply a single mount option to the superblock configuration context.  The
+     mount option should likely be in a "key[=val]" string form.  The option is
+     first checked to see if it corresponds to a standard mount flag (in which
+     case it is used to mark an MS_xxx flag and consumed) or a security option
+     (in which case the LSM consumes it) before it is passed on to the
+     filesystem.
+
+ (*) int generic_monolithic_mount_data(struct sb_config *sc, void *data);
+
+     Parse a sys_mount() data page, assuming the form to be a text list
+     consisting of key[=val] options separated by commas.  Each item in the
+     list is passed to vfs_mount_option().  This is the default when the
+     ->monolithic_mount_data() operation is NULL.
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
new file mode 100644
index 000000000000..d2af7342a082
--- /dev/null
+++ b/include/linux/sb_config.h
@@ -0,0 +1,72 @@
+/* Superblock configuration and creation handling.
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
+#ifndef _LINUX_SB_CONFIG_H
+#define _LINUX_SB_CONFIG_H
+
+#include <linux/kernel.h>
+#include <linux/errno.h>
+
+struct cred;
+struct dentry;
+struct file_operations;
+struct file_system_type;
+struct mnt_namespace;
+struct net;
+struct pid_namespace;
+struct super_block;
+struct user_namespace;
+struct vfsmount;
+
+enum sb_config_purpose {
+	SB_CONFIG_FOR_NEW,	/* New superblock for direct mount */
+	SB_CONFIG_FOR_SUBMOUNT,	/* New superblock for automatic submount */
+	SB_CONFIG_FOR_REMOUNT,	/* Superblock reconfiguration for remount */
+};
+
+/*
+ * Superblock configuration context as allocated and constructed by the
+ * ->init_sb_config() file_system_type operation.  The size of the object
+ * allocated is specified in struct file_system_type::sb_config_size and this
+ * must include sufficient space for the sb_config struct.
+ *
+ * Superblock creation fills in ->root whereas reconfiguration begins with this
+ * already set.
+ *
+ * See Documentation/filesystems/mounting.txt
+ */
+struct sb_config {
+	const struct sb_config_operations *ops;
+	struct file_system_type	*fs_type;
+	struct dentry		*root;		/* The root and superblock */
+	struct user_namespace	*user_ns;	/* The user namespace for this mount */
+	struct net		*net_ns;	/* The network namespace for this mount */
+	const struct cred	*cred;		/* The mounter's credentials */
+	char			*device;	/* The device name or mount target */
+	char			*subtype;	/* The subtype to set on the superblock */
+	void			*security;	/* The LSM context */
+	unsigned int		ms_flags;	/* The superblock flags (MS_*) */
+	bool			sloppy;		/* Unrecognised options are okay */
+	bool			silent;
+	bool			degraded;	/* True if the config can't be reused */
+	enum sb_config_purpose 	purpose : 8;
+};
+
+struct sb_config_operations {
+	void (*free)(struct sb_config *sc);
+	int (*dup)(struct sb_config *sc, struct sb_config *src);
+	int (*parse_option)(struct sb_config *sc, char *p);
+	int (*monolithic_mount_data)(struct sb_config *sc, void *data);
+	int (*validate)(struct sb_config *sc);
+	int (*get_tree)(struct sb_config *sc);
+};
+
+#endif /* _LINUX_SB_CONFIG_H */

