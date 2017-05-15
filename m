Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965772AbdEOPTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:19:17 -0400
Subject: [PATCH 06/21] VFS: Introduce a superblock configuration context
 [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:19:08 +0100
Message-ID: <149486154888.23956.10260643844119198576.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
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

It also gives a place in which to hang an error message for later retrieval
(see the mount-by-fd syscall later in this series).

Rather than calling fs_type->mount(), an sb_config struct is created and
fs_type->init_sb_config() is called to set it up.  fs_type->sb_config_size
says how much space should be allocated for the config context.  The
sb_config struct is placed at the beginning and any extra space is for the
filesystem's use.

A set of operations have to be set by ->init_sb_config() to provide
freeing, duplication, option parsing, binary data parsing, validation,
mounting and superblock filling.

It should be noted that, whilst this patch adds a lot of lines of code,
there is quite a bit of duplication with existing code that can be
eliminated should all filesystems be converted over.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/filesystems/mounting.txt |  456 ++++++++++++++++++++++++++++++++
 fs/Makefile                            |    3 
 fs/internal.h                          |    2 
 fs/libfs.c                             |    1 
 fs/namespace.c                         |  256 ++++++++++++++++--
 fs/nfs/nfs4super.c                     |    1 
 fs/proc/root.c                         |    1 
 fs/sb_config.c                         |  326 +++++++++++++++++++++++
 fs/super.c                             |   54 +++-
 include/linux/fs.h                     |   14 +
 include/linux/lsm_hooks.h              |   38 +++
 include/linux/mount.h                  |    4 
 include/linux/sb_config.h              |   93 +++++++
 include/linux/security.h               |   29 ++
 security/security.c                    |   25 ++
 security/selinux/hooks.c               |  170 ++++++++++++
 16 files changed, 1442 insertions(+), 31 deletions(-)
 create mode 100644 Documentation/filesystems/mounting.txt
 create mode 100644 fs/sb_config.c
 create mode 100644 include/linux/sb_config.h

diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
new file mode 100644
index 000000000000..03e9086f754d
--- /dev/null
+++ b/Documentation/filesystems/mounting.txt
@@ -0,0 +1,456 @@
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
+		struct user_namespace	*user_ns;
+		struct net		*net_ns;
+		const struct cred	*cred;
+		char			*device;
+		void			*security;
+		const char		*error_msg;
+		unsigned int		ms_flags;
+		bool			mounted;
+		bool			sloppy;
+		bool			silent;
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
+		struct dentry *(*mount)(struct sb_config *sc);
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
+     	 immediately thereafter, so ->dup() *must* make the filesystem-specific
+     	 part safe for ->free().
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
+ (*) struct dentry *(*mount)(struct sb_config *sc);
+
+     Called to effect a new mount or new submount using the information stored
+     in the superblock configuration context (remounts go via a different
+     vector).  It may detach any resources it desires from the superblock
+     configuration context and transfer them to the superblock it creates.
+
+     On success it should return the dentry that's at the root of the mount.
+     In future, sc->root_path will then be applied to this.
+
+     In the case of an error, it should return a negative error code and invoke
+     sb_cfg_inval() or sb_cfg_error().
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
+ (*) struct sb_config *vfs_fsopen(const char *fs_name);
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
+     	 unconditional destruction.
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
+ (*) struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
+
+     Create a mount given the parameters in the specified superblock
+     configuration context.  This invokes the ->validate() op and then the
+     ->mount() op.
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
diff --git a/fs/Makefile b/fs/Makefile
index 7bbaca9c67b1..8f5142525866 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -11,7 +11,8 @@ obj-y :=	open.o read_write.o file_table.o super.o \
 		attr.o bad_inode.o file.o filesystems.o namespace.o \
 		seq_file.o xattr.o libfs.o fs-writeback.o \
 		pnode.o splice.o sync.o utimes.o \
-		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
+		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
+		sb_config.o
 
 ifeq ($(CONFIG_BLOCK),y)
 obj-y +=	buffer.o block_dev.o direct-io.o mpage.o
diff --git a/fs/internal.h b/fs/internal.h
index 9676fe11c093..39121a99d930 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -87,7 +87,7 @@ extern struct file *get_empty_filp(void);
 /*
  * super.c
  */
-extern int do_remount_sb(struct super_block *, int, void *, int);
+extern int do_remount_sb(struct super_block *, int, void *, int, struct sb_config *);
 extern bool trylock_super(struct super_block *sb);
 extern struct dentry *mount_fs(struct file_system_type *,
 			       int, const char *, void *);
diff --git a/fs/libfs.c b/fs/libfs.c
index a04395334bb1..8ef519709ee3 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -9,6 +9,7 @@
 #include <linux/slab.h>
 #include <linux/cred.h>
 #include <linux/mount.h>
+#include <linux/sb_config.h>
 #include <linux/vfs.h>
 #include <linux/quotaops.h>
 #include <linux/mutex.h>
diff --git a/fs/namespace.c b/fs/namespace.c
index c076787871e7..91f8a07532cd 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -25,7 +25,9 @@
 #include <linux/magic.h>
 #include <linux/bootmem.h>
 #include <linux/task_work.h>
+#include <linux/file.h>
 #include <linux/sched/task.h>
+#include <linux/sb_config.h>
 
 #include "pnode.h"
 #include "internal.h"
@@ -1593,7 +1595,7 @@ static int do_umount(struct mount *mnt, int flags)
 			return -EPERM;
 		down_write(&sb->s_umount);
 		if (!(sb->s_flags & MS_RDONLY))
-			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0);
+			retval = do_remount_sb(sb, MS_RDONLY, NULL, 0, NULL);
 		up_write(&sb->s_umount);
 		return retval;
 	}
@@ -2276,6 +2278,26 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 }
 
 /*
+ * Parse the monolithic page of mount data given to sys_mount().
+ */
+static int parse_monolithic_mount_data(struct sb_config *sc, void *data)
+{
+	int (*monolithic_mount_data)(struct sb_config *, void *);
+	int ret;
+
+	monolithic_mount_data = sc->ops->monolithic_mount_data;
+	if (!monolithic_mount_data)
+		monolithic_mount_data = generic_monolithic_mount_data;
+
+	ret = monolithic_mount_data(sc, data);
+	if (ret < 0)
+		return ret;
+	if (sc->ops->validate)
+		return sc->ops->validate(sc);
+	return 0;
+}
+
+/*
  * change filesystem flags. dir should be a physical root of filesystem.
  * If you've mounted a non-root directory somewhere and want to do remount
  * on it - tough luck.
@@ -2283,13 +2305,14 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
 static int do_remount(struct path *path, int flags, int mnt_flags,
 		      void *data)
 {
+	struct sb_config *sc = NULL;
 	int err;
 	struct super_block *sb = path->mnt->mnt_sb;
 	struct mount *mnt = real_mount(path->mnt);
+	struct file_system_type *type = sb->s_type;
 
 	if (!check_mnt(mnt))
 		return -EINVAL;
-
 	if (path->dentry != path->mnt->mnt_root)
 		return -EINVAL;
 
@@ -2320,9 +2343,19 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		return -EPERM;
 	}
 
-	err = security_sb_remount(sb, data);
-	if (err)
-		return err;
+	if (type->init_sb_config) {
+		sc = vfs_sb_reconfig(path->mnt, flags);
+		if (IS_ERR(sc))
+			return PTR_ERR(sc);
+
+		err = parse_monolithic_mount_data(sc, data);
+		if (err < 0)
+			goto err_sc;
+	} else {
+		err = security_sb_remount(sb, data);
+		if (err)
+			return err;
+	}
 
 	down_write(&sb->s_umount);
 	if (flags & MS_BIND)
@@ -2330,7 +2363,7 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 	else if (!capable(CAP_SYS_ADMIN))
 		err = -EPERM;
 	else
-		err = do_remount_sb(sb, flags, data, 0);
+		err = do_remount_sb(sb, flags, data, 0, sc);
 	if (!err) {
 		lock_mount_hash();
 		mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
@@ -2339,6 +2372,9 @@ static int do_remount(struct path *path, int flags, int mnt_flags,
 		unlock_mount_hash();
 	}
 	up_write(&sb->s_umount);
+err_sc:
+	if (sc)
+		put_sb_config(sc);
 	return err;
 }
 
@@ -2492,40 +2528,106 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
 static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
 
 /*
+ * Create a new mount using a superblock configuration and request it
+ * be added to the namespace tree.
+ */
+static int do_new_mount_sc(struct sb_config *sc, struct path *mountpoint,
+			   unsigned int mnt_flags)
+{
+	struct vfsmount *mnt;
+	int ret;
+
+	mnt = vfs_kern_mount_sc(sc);
+	if (IS_ERR(mnt))
+		return PTR_ERR(mnt);
+
+	if ((sc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+	    !mnt->mnt_sb->s_subtype) {
+		mnt = fs_set_subtype(mnt, sc->fs_type->name);
+		if (IS_ERR(mnt))
+			return PTR_ERR(mnt);
+	}
+
+	ret = -EPERM;
+	if (mount_too_revealing(mnt, &mnt_flags)) {
+		sb_cfg_error(sc, "VFS: Mount too revealing");
+		goto err_mnt;
+	}
+
+	ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+	if (ret < 0) {
+		sb_cfg_error(sc, "VFS: Failed to add mount");
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
  * create a new mount for userspace and request it to be added into the
  * namespace's tree
  */
-static int do_new_mount(struct path *path, const char *fstype, int flags,
+static int do_new_mount(struct path *mountpoint, const char *fstype, int flags,
 			int mnt_flags, const char *name, void *data)
 {
-	struct file_system_type *type;
+	struct sb_config *sc;
 	struct vfsmount *mnt;
 	int err;
 
 	if (!fstype)
 		return -EINVAL;
 
-	type = get_fs_type(fstype);
-	if (!type)
-		return -ENODEV;
+	sc = vfs_new_sb_config(fstype);
+	if (IS_ERR(sc))
+		return PTR_ERR(sc);
+	sc->ms_flags = flags;
 
-	mnt = vfs_kern_mount(type, flags, name, data);
-	if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
-	    !mnt->mnt_sb->s_subtype)
-		mnt = fs_set_subtype(mnt, fstype);
+	err = -ENOMEM;
+	sc->device = kstrdup(name, GFP_KERNEL);
+	if (!sc->device)
+		goto err_sc;
 
-	put_filesystem(type);
-	if (IS_ERR(mnt))
-		return PTR_ERR(mnt);
+	if (sc->ops) {
+		err = parse_monolithic_mount_data(sc, data);
+		if (err < 0)
+			goto err_sc;
 
-	if (mount_too_revealing(mnt, &mnt_flags)) {
-		mntput(mnt);
-		return -EPERM;
+		err = do_new_mount_sc(sc, mountpoint, mnt_flags);
+		if (err)
+			goto err_sc;
+
+	} else {
+		mnt = vfs_kern_mount(sc->fs_type, flags, name, data);
+		if (!IS_ERR(mnt) && (sc->fs_type->fs_flags & FS_HAS_SUBTYPE) &&
+		    !mnt->mnt_sb->s_subtype)
+			mnt = fs_set_subtype(mnt, fstype);
+
+		if (IS_ERR(mnt)) {
+			err = PTR_ERR(mnt);
+			goto err_sc;
+		}
+
+		err = -EPERM;
+		if (mount_too_revealing(mnt, &mnt_flags))
+			goto err_mnt;
+
+		err = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
+		if (err)
+			goto err_mnt;
 	}
 
-	err = do_add_mount(real_mount(mnt), path, mnt_flags);
-	if (err)
-		mntput(mnt);
+	put_sb_config(sc);
+	return 0;
+
+err_mnt:
+	mntput(mnt);
+err_sc:
+	if (sc->error_msg)
+		pr_info("Mount failed: %s\n", sc->error_msg);
+	put_sb_config(sc);
 	return err;
 }
 
@@ -3058,6 +3160,95 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
 	return ret;
 }
 
+static struct dentry *__do_mount_sc(struct sb_config *sc)
+{
+	struct super_block *sb;
+	struct dentry *root;
+	int ret;
+
+	root = sc->ops->mount(sc);
+	if (IS_ERR(root))
+		return root;
+
+	sb = root->d_sb;
+	BUG_ON(!sb);
+	WARN_ON(!sb->s_bdi);
+	sb->s_flags |= MS_BORN;
+
+	ret = security_sb_config_kern_mount(sc, sb);
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
+		"negative value (%lld)\n", sc->fs_type->name, sb->s_maxbytes);
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
+struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc)
+{
+	struct dentry *root;
+	struct mount *mnt;
+	int ret;
+
+	if (sc->ops->validate) {
+		ret = sc->ops->validate(sc);
+		if (ret < 0)
+			return ERR_PTR(ret);
+	}
+
+	mnt = alloc_vfsmnt(sc->device ?: "none");
+	if (!mnt)
+		return ERR_PTR(-ENOMEM);
+
+	if (sc->ms_flags & MS_KERNMOUNT)
+		mnt->mnt.mnt_flags = MNT_INTERNAL;
+
+	root = __do_mount_sc(sc);
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
+EXPORT_SYMBOL_GPL(vfs_kern_mount_sc);
+
+struct vfsmount *
+vfs_submount_sc(const struct dentry *mountpoint, struct sb_config *sc)
+{
+	/* Until it is worked out how to pass the user namespace
+	 * through from the parent mount to the submount don't support
+	 * unprivileged mounts with submounts.
+	 */
+	if (mountpoint->d_sb->s_user_ns != &init_user_ns)
+		return ERR_PTR(-EPERM);
+
+	sc->ms_flags = MS_SUBMOUNT;
+	return vfs_kern_mount_sc(sc);
+}
+EXPORT_SYMBOL_GPL(vfs_submount_sc);
+
 /*
  * Return true if path is reachable from root
  *
@@ -3299,6 +3490,23 @@ struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
 }
 EXPORT_SYMBOL_GPL(kern_mount_data);
 
+struct vfsmount *kern_mount_data_sc(struct sb_config *sc)
+{
+	struct vfsmount *mnt;
+
+	sc->ms_flags = MS_KERNMOUNT;
+	mnt = vfs_kern_mount_sc(sc);
+	if (!IS_ERR(mnt)) {
+		/*
+		 * it is a longterm mount, don't release mnt until
+		 * we unmount before file sys is unregistered
+		*/
+		real_mount(mnt)->mnt_ns = MNT_NS_INTERNAL;
+	}
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(kern_mount_data_sc);
+
 void kern_unmount(struct vfsmount *mnt)
 {
 	/* release long term mount so mount point can be released */
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 6fb7cb6b3f4b..967fa04d5c76 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -3,6 +3,7 @@
  */
 #include <linux/init.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/nfs4_mount.h>
 #include <linux/nfs_fs.h>
 #include "delegation.h"
diff --git a/fs/proc/root.c b/fs/proc/root.c
index deecb397daa3..3c47399bd095 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -19,6 +19,7 @@
 #include <linux/bitops.h>
 #include <linux/user_namespace.h>
 #include <linux/mount.h>
+#include <linux/sb_config.h>
 #include <linux/pid_namespace.h>
 #include <linux/parser.h>
 #include <linux/cred.h>
diff --git a/fs/sb_config.c b/fs/sb_config.c
new file mode 100644
index 000000000000..9c45e269b3cc
--- /dev/null
+++ b/fs/sb_config.c
@@ -0,0 +1,326 @@
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
+#include <linux/sb_config.h>
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
+static int vfs_parse_ms_mount_option(struct sb_config *sc, char *data)
+{
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int token;
+
+	token = match_token(data, common_set_mount_options, args);
+	if (token) {
+		sc->ms_flags |= token;
+		return 1;
+	}
+
+	token = match_token(data, common_clear_mount_options, args);
+	if (token) {
+		sc->ms_flags &= ~token;
+		return 1;
+	}
+
+	token = match_token(data, forbidden_mount_options, args);
+	if (token)
+		return sb_cfg_inval(sc, "Mount option, not superblock option");
+
+	return 0;
+}
+
+/**
+ * vfs_parse_mount_option - Add a single mount option to a superblock config
+ * @mc: The superblock configuration to modify
+ * @p: The option to apply.
+ *
+ * A single mount option in string form is applied to the superblock
+ * configuration being set up.  Certain standard options (for example "ro") are
+ * translated into flag bits without going to the filesystem.  The active
+ * security module is allowed to observe and poach options.  Any other options
+ * are passed over to the filesystem to parse.
+ *
+ * This may be called multiple times for a context.
+ *
+ * Returns 0 on success and a negative error code on failure.  In the event of
+ * failure, sc->error may have been set to a non-allocated string that gives
+ * more information.
+ */
+int vfs_parse_mount_option(struct sb_config *sc, char *p)
+{
+	int ret;
+
+	if (sc->mounted)
+		return -EBUSY;
+
+	ret = vfs_parse_ms_mount_option(sc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	ret = security_sb_config_parse_option(sc, p);
+	if (ret < 0)
+		return ret;
+	if (ret == 1)
+		return 0;
+
+	return sc->ops->parse_option(sc, p);
+}
+EXPORT_SYMBOL(vfs_parse_mount_option);
+
+/**
+ * generic_monolithic_mount_data - Parse key[=val][,key[=val]]* mount data
+ * @mc: The superblock configuration to fill in.
+ * @data: The data to parse
+ *
+ * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
+ * called from the ->monolithic_mount_data() sb_config operation.
+ *
+ * Returns 0 on success or the error returned by the ->parse_option() sb_config
+ * operation on failure.
+ */
+int generic_monolithic_mount_data(struct sb_config *ctx, void *data)
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
+ * __vfs_new_sb_config - Create a superblock config.
+ * @fs_type: The filesystem type.
+ * @src_sb: A superblock from which this one derives (or NULL)
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ * @purpose: The purpose that this configuration shall be used for.
+ *
+ * Open a filesystem and create a mount context.  The mount context is
+ * initialised with the supplied flags and, if a submount/automount from
+ * another superblock (@src_sb), may have parameters such as namespaces copied
+ * across from that superblock.
+ */
+struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
+				      struct super_block *src_sb,
+				      unsigned int ms_flags,
+				      enum sb_config_purpose purpose)
+{
+	struct sb_config *sc;
+	int ret;
+
+	BUG_ON(fs_type->init_sb_config &&
+	       fs_type->sb_config_size < sizeof(*sc));
+
+	sc = kzalloc(max_t(size_t, fs_type->sb_config_size, sizeof(*sc)),
+		     GFP_KERNEL);
+	if (!sc)
+		return ERR_PTR(-ENOMEM);
+
+	sc->purpose	= purpose;
+	sc->ms_flags	= ms_flags;
+	sc->fs_type	= get_filesystem(fs_type);
+	sc->net_ns	= get_net(current->nsproxy->net_ns);
+	sc->user_ns	= get_user_ns(current_user_ns());
+	sc->cred	= get_current_cred();
+
+	/* TODO: Make all filesystems support this unconditionally */
+	if (sc->fs_type->init_sb_config) {
+		ret = sc->fs_type->init_sb_config(sc, src_sb);
+		if (ret < 0)
+			goto err_sc;
+	}
+
+	/* Do the security check last because ->fsopen may change the
+	 * namespace subscriptions.
+	 */
+	ret = security_sb_config_alloc(sc, src_sb);
+	if (ret < 0)
+		goto err_sc;
+
+	return sc;
+
+err_sc:
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(__vfs_new_sb_config);
+
+/**
+ * vfs_new_sb_config - Create a superblock config for a new mount.
+ * @fs_name: The name of the filesystem
+ *
+ * Open a filesystem and create a superblock config context for a new mount
+ * that will hold the mount options, device name, security details, etc..  Note
+ * that the caller should check the ->ops pointer in the returned context to
+ * determine whether the filesystem actually supports the superblock context
+ * itself.
+ */
+struct sb_config *vfs_new_sb_config(const char *fs_name)
+{
+	struct file_system_type *fs_type;
+	struct sb_config *sc;
+
+	fs_type = get_fs_type(fs_name);
+	if (!fs_type)
+		return ERR_PTR(-ENODEV);
+
+	sc = __vfs_new_sb_config(fs_type, NULL, 0, SB_CONFIG_FOR_NEW);
+	put_filesystem(fs_type);
+	return sc;
+}
+EXPORT_SYMBOL(vfs_new_sb_config);
+
+/**
+ * vfs_sb_reconfig - Create a superblock config for remount/reconfiguration
+ * @mnt: The mountpoint to open
+ * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
+ *
+ * Open a mounted filesystem and create a mount context such that a remount can
+ * be effected.
+ */
+struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
+				  unsigned int ms_flags)
+{
+	return __vfs_new_sb_config(mnt->mnt_sb->s_type, mnt->mnt_sb,
+				   ms_flags, SB_CONFIG_FOR_REMOUNT);
+}
+
+/**
+ * vfs_dup_sc_config: Duplicate a superblock configuration context.
+ * @src_sc: The context to copy.
+ */
+struct sb_config *vfs_dup_sb_config(struct sb_config *src_sc)
+{
+	struct sb_config *sc;
+	int ret;
+
+	if (!src_sc->ops->dup)
+		return ERR_PTR(-ENOTSUPP);
+
+	sc = kmemdup(src_sc, src_sc->fs_type->sb_config_size, GFP_KERNEL);
+	if (!sc)
+		return ERR_PTR(-ENOMEM);
+
+	sc->device	= NULL;
+	sc->security	= NULL;
+	sc->error_msg	= NULL;
+	get_filesystem(sc->fs_type);
+	get_net(sc->net_ns);
+	get_user_ns(sc->user_ns);
+	get_cred(sc->cred);
+
+	/* Can't call put until we've called ->dup */
+	ret = sc->ops->dup(sc, src_sc);
+	if (ret < 0)
+		goto err_sc;
+
+	ret = security_sb_config_dup(sc, src_sc);
+	if (ret < 0)
+		goto err_sc;
+	return sc;
+
+err_sc:
+	put_sb_config(sc);
+	return ERR_PTR(ret);
+}
+EXPORT_SYMBOL(vfs_dup_sb_config);
+
+/**
+ * put_sb_config - Dispose of a superblock configuration context.
+ * @sc: The context to dispose of.
+ */
+void put_sb_config(struct sb_config *sc)
+{
+	if (sc->ops && sc->ops->free)
+		sc->ops->free(sc);
+	security_sb_config_free(sc);
+	if (sc->net_ns)
+		put_net(sc->net_ns);
+	put_user_ns(sc->user_ns);
+	if (sc->cred)
+		put_cred(sc->cred);
+	put_filesystem(sc->fs_type);
+	kfree(sc->device);
+	kfree(sc);
+}
+EXPORT_SYMBOL(put_sb_config);
diff --git a/fs/super.c b/fs/super.c
index adb0c0de428c..4d923a775bd0 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -34,6 +34,7 @@
 #include <linux/fsnotify.h>
 #include <linux/lockdep.h>
 #include <linux/user_namespace.h>
+#include <linux/sb_config.h>
 #include "internal.h"
 
 
@@ -805,10 +806,13 @@ struct super_block *user_get_super(dev_t dev)
  *	@flags:	numeric part of options
  *	@data:	the rest of options
  *      @force: whether or not to force the change
+ *	@sc:	the superblock config for filesystems that support it
+ *		(NULL if called from emergency or umount)
  *
  *	Alters the mount options of a mounted file system.
  */
-int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
+int do_remount_sb(struct super_block *sb, int flags, void *data, int force,
+		  struct sb_config *sc)
 {
 	int retval;
 	int remount_ro;
@@ -850,8 +854,14 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 		}
 	}
 
-	if (sb->s_op->remount_fs) {
-		retval = sb->s_op->remount_fs(sb, &flags, data);
+	if (sb->s_op->remount_fs_sc ||
+	    sb->s_op->remount_fs) {
+		if (sb->s_op->remount_fs_sc) {
+		    retval = sb->s_op->remount_fs_sc(sb, sc);
+		    flags = sc->ms_flags;
+		} else {
+			retval = sb->s_op->remount_fs(sb, &flags, data);
+		}
 		if (retval) {
 			if (!force)
 				goto cancel_readonly;
@@ -898,7 +908,7 @@ static void do_emergency_remount(struct work_struct *work)
 			/*
 			 * What lock protects sb->s_flags??
 			 */
-			do_remount_sb(sb, MS_RDONLY, NULL, 1);
+			do_remount_sb(sb, MS_RDONLY, NULL, 1, NULL);
 		}
 		up_write(&sb->s_umount);
 		spin_lock(&sb_lock);
@@ -1048,6 +1058,40 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
 
 EXPORT_SYMBOL(mount_ns);
 
+struct dentry *mount_ns_sc(struct sb_config *sc,
+			   int (*fill_super)(struct super_block *sb,
+					     struct sb_config *sc),
+			   void *ns)
+{
+	struct super_block *sb;
+
+	/* Don't allow mounting unless the caller has CAP_SYS_ADMIN
+	 * over the namespace.
+	 */
+	if (!(sc->ms_flags & MS_KERNMOUNT) &&
+	    !ns_capable(sc->user_ns, CAP_SYS_ADMIN))
+		return ERR_PTR(-EPERM);
+
+	sb = sget_userns(sc->fs_type, ns_test_super, ns_set_super,
+			 sc->ms_flags, sc->user_ns, ns);
+	if (IS_ERR(sb))
+		return ERR_CAST(sb);
+
+	if (!sb->s_root) {
+		int err;
+		err = fill_super(sb, sc);
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
+EXPORT_SYMBOL(mount_ns_sc);
+
 #ifdef CONFIG_BLOCK
 static int set_bdev_super(struct super_block *s, void *data)
 {
@@ -1196,7 +1240,7 @@ struct dentry *mount_single(struct file_system_type *fs_type,
 		}
 		s->s_flags |= MS_ACTIVE;
 	} else {
-		do_remount_sb(s, flags, data, 0);
+		do_remount_sb(s, flags, data, 0, NULL);
 	}
 	return dget(s->s_root);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bc0c054894b9..cd6cafcdd2ff 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -54,6 +54,7 @@ struct workqueue_struct;
 struct iov_iter;
 struct fscrypt_info;
 struct fscrypt_operations;
+struct sb_config;
 
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
@@ -1787,6 +1793,7 @@ struct super_operations {
 	int (*unfreeze_fs) (struct super_block *);
 	int (*statfs) (struct dentry *, struct kstatfs *);
 	int (*remount_fs) (struct super_block *, int *, char *);
+	int (*remount_fs_sc) (struct super_block *, struct sb_config *);
 	void (*umount_begin) (struct super_block *);
 
 	int (*show_options)(struct seq_file *, struct dentry *);
@@ -2021,8 +2028,10 @@ struct file_system_type {
 #define FS_HAS_SUBTYPE		4
 #define FS_USERNS_MOUNT		8	/* Can be mounted by userns root */
 #define FS_RENAME_DOES_D_MOVE	32768	/* FS will handle d_move() during rename() internally. */
+	unsigned short sb_config_size;	/* Size of superblock config context to allocate */
 	struct dentry *(*mount) (struct file_system_type *, int,
 		       const char *, void *);
+	int (*init_sb_config)(struct sb_config *, struct super_block *);
 	void (*kill_sb) (struct super_block *);
 	struct module *owner;
 	struct file_system_type * next;
@@ -2040,6 +2049,10 @@ struct file_system_type {
 
 #define MODULE_ALIAS_FS(NAME) MODULE_ALIAS("fs-" NAME)
 
+extern struct dentry *mount_ns_sc(struct sb_config *mc,
+				  int (*fill_super)(struct super_block *sb,
+						    struct sb_config *sc),
+				  void *ns);
 extern struct dentry *mount_ns(struct file_system_type *fs_type,
 	int flags, void *data, void *ns, struct user_namespace *user_ns,
 	int (*fill_super)(struct super_block *, void *, int));
@@ -2106,6 +2119,7 @@ extern int register_filesystem(struct file_system_type *);
 extern int unregister_filesystem(struct file_system_type *);
 extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
 #define kern_mount(type) kern_mount_data(type, NULL)
+extern struct vfsmount *kern_mount_data_sc(struct sb_config *);
 extern void kern_unmount(struct vfsmount *mnt);
 extern int may_umount_tree(struct vfsmount *);
 extern int may_umount(struct vfsmount *);
diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 080f34e66017..48bfd49666bc 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -75,6 +75,33 @@
  *	should enable secure mode.
  *	@bprm contains the linux_binprm structure.
  *
+ * Security hooks for mount using fd context.
+ *
+ * @sb_config_alloc:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@sc indicates the new superblock configuration context.
+ *	@src_sb indicates the source superblock of a submount.
+ * @sb_config_dup:
+ *	Allocate and attach a security structure to sc->security.  This pointer
+ *	is initialised to NULL by the caller.
+ *	@sc indicates the new superblock configuration context.
+ *	@src_sc indicates the original superblock configuration context.
+ * @sb_config_free:
+ *	Clean up a superblock configuration context.
+ *	@sc indicates the superblock configuration context.
+ * @sb_config_parse_option:
+ *	Userspace provided an option to configure a superblock.  The LSM may
+ *	reject it with an error and may use it for itself, in which case it
+ *	should return 1; otherwise it should return 0 to pass it on to the
+ *	filesystem.
+ *	@sc indicates the superblock configuration context.
+ *	@p indicates the option in "key[=val]" form.
+ * @sb_config_kern_mount:
+ *	Equivalent of sb_kern_mount, but with a superblock configuration context.
+ *	@sc indicates the superblock configuration context.
+ *	@src_sb indicates the new superblock.
+ *
  * Security hooks for filesystem operations.
  *
  * @sb_alloc_security:
@@ -1372,6 +1399,12 @@ union security_list_options {
 	void (*bprm_committing_creds)(struct linux_binprm *bprm);
 	void (*bprm_committed_creds)(struct linux_binprm *bprm);
 
+	int (*sb_config_alloc)(struct sb_config *sc, struct super_block *src_sb);
+	int (*sb_config_dup)(struct sb_config *sc, struct sb_config *src_sc);
+	void (*sb_config_free)(struct sb_config *sc);
+	int (*sb_config_parse_option)(struct sb_config *sc, char *opt);
+	int (*sb_config_kern_mount)(struct sb_config *sc, struct super_block *sb);
+
 	int (*sb_alloc_security)(struct super_block *sb);
 	void (*sb_free_security)(struct super_block *sb);
 	int (*sb_copy_data)(char *orig, char *copy);
@@ -1683,6 +1716,11 @@ struct security_hook_heads {
 	struct list_head bprm_secureexec;
 	struct list_head bprm_committing_creds;
 	struct list_head bprm_committed_creds;
+	struct list_head sb_config_alloc;
+	struct list_head sb_config_dup;
+	struct list_head sb_config_free;
+	struct list_head sb_config_parse_option;
+	struct list_head sb_config_kern_mount;
 	struct list_head sb_alloc_security;
 	struct list_head sb_free_security;
 	struct list_head sb_copy_data;
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 8e0352af06b7..a5dca6abc4d5 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -20,6 +20,7 @@ struct super_block;
 struct vfsmount;
 struct dentry;
 struct mnt_namespace;
+struct sb_config;
 
 #define MNT_NOSUID	0x01
 #define MNT_NODEV	0x02
@@ -90,9 +91,12 @@ struct file_system_type;
 extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 				      int flags, const char *name,
 				      void *data);
+extern struct vfsmount *vfs_kern_mount_sc(struct sb_config *sc);
 extern struct vfsmount *vfs_submount(const struct dentry *mountpoint,
 				     struct file_system_type *type,
 				     const char *name, void *data);
+extern struct vfsmount *vfs_submount_sc(const struct dentry *mountpoint,
+					struct sb_config *sc);
 
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
diff --git a/include/linux/sb_config.h b/include/linux/sb_config.h
new file mode 100644
index 000000000000..0b21e381d9f0
--- /dev/null
+++ b/include/linux/sb_config.h
@@ -0,0 +1,93 @@
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
+ * See Documentation/filesystems/mounting.txt
+ */
+struct sb_config {
+	const struct sb_config_operations *ops;
+	struct file_system_type	*fs_type;
+	struct user_namespace	*user_ns;	/* The user namespace for this mount */
+	struct net		*net_ns;	/* The network namespace for this mount */
+	const struct cred	*cred;		/* The mounter's credentials */
+	char			*device;	/* The device name or mount target */
+	void			*security;	/* The LSM context */
+	const char		*error_msg;	/* Error string to be read by read() */
+	unsigned int		ms_flags;	/* The superblock flags (MS_*) */
+	bool			mounted;	/* Set when mounted */
+	bool			sloppy;		/* Unrecognised options are okay */
+	bool			silent;
+	enum sb_config_purpose 	purpose : 8;
+};
+
+struct sb_config_operations {
+	void (*free)(struct sb_config *sc);
+	int (*dup)(struct sb_config *sc, struct sb_config *src);
+	int (*parse_option)(struct sb_config *sc, char *p);
+	int (*monolithic_mount_data)(struct sb_config *sc, void *data);
+	int (*validate)(struct sb_config *sc);
+	struct dentry *(*mount)(struct sb_config *sc);
+};
+
+extern const struct file_operations fs_fs_fops;
+
+extern struct sb_config *vfs_new_sb_config(const char *fs_name);
+extern struct sb_config *__vfs_new_sb_config(struct file_system_type *fs_type,
+					     struct super_block *src_sb,
+					     unsigned int ms_flags,
+					     enum sb_config_purpose purpose);
+extern struct sb_config *vfs_sb_reconfig(struct vfsmount *mnt,
+					 unsigned int ms_flags);
+extern struct sb_config *vfs_dup_sb_config(struct sb_config *src);
+extern int vfs_parse_mount_option(struct sb_config *sc, char *data);
+extern int generic_monolithic_mount_data(struct sb_config *sc, void *data);
+extern void put_sb_config(struct sb_config *sc);
+
+static inline void sb_cfg_error(struct sb_config *sc, const char *msg)
+{
+	sc->error_msg = msg;
+}
+
+static inline int sb_cfg_inval(struct sb_config *sc, const char *msg)
+{
+	sb_cfg_error(sc, msg);
+	return -EINVAL;
+}
+
+#endif /* _LINUX_SB_CONFIG_H */
diff --git a/include/linux/security.h b/include/linux/security.h
index af675b576645..36b3a6779986 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -55,6 +55,7 @@ struct msg_queue;
 struct xattr;
 struct xfrm_sec_ctx;
 struct mm_struct;
+struct sb_config;
 
 /* If capable should audit the security request */
 #define SECURITY_CAP_NOAUDIT 0
@@ -224,6 +225,11 @@ int security_bprm_check(struct linux_binprm *bprm);
 void security_bprm_committing_creds(struct linux_binprm *bprm);
 void security_bprm_committed_creds(struct linux_binprm *bprm);
 int security_bprm_secureexec(struct linux_binprm *bprm);
+int security_sb_config_alloc(struct sb_config *sc, struct super_block *sb);
+int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc);
+void security_sb_config_free(struct sb_config *sc);
+int security_sb_config_parse_option(struct sb_config *sc, char *opt);
+int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb);
 int security_sb_alloc(struct super_block *sb);
 void security_sb_free(struct super_block *sb);
 int security_sb_copy_data(char *orig, char *copy);
@@ -520,6 +526,29 @@ static inline int security_bprm_secureexec(struct linux_binprm *bprm)
 	return cap_bprm_secureexec(bprm);
 }
 
+static inline int security_sb_config_alloc(struct sb_config *sc,
+					   struct super_block *src_sb)
+{
+	return 0;
+}
+static inline int security_sb_config_dup(struct sb_config *sc,
+					 struct sb_config *src_sc)
+{
+	return 0;
+}
+static inline void security_sb_config_free(struct sb_config *sc)
+{
+}
+static inline int security_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	return 0;
+}
+static inline int security_sb_config_kern_mount(struct sb_config *sc,
+						struct super_block *sb)
+{
+	return 0;
+}
+
 static inline int security_sb_alloc(struct super_block *sb)
 {
 	return 0;
diff --git a/security/security.c b/security/security.c
index b9fea3999cf8..3735fad91543 100644
--- a/security/security.c
+++ b/security/security.c
@@ -316,6 +316,31 @@ int security_bprm_secureexec(struct linux_binprm *bprm)
 	return call_int_hook(bprm_secureexec, 0, bprm);
 }
 
+int security_sb_config_alloc(struct sb_config *sc, struct super_block *src_sb)
+{
+	return call_int_hook(sb_config_alloc, 0, sc, src_sb);
+}
+
+int security_sb_config_dup(struct sb_config *sc, struct sb_config *src_sc)
+{
+	return call_int_hook(sb_config_dup, 0, sc, src_sc);
+}
+
+void security_sb_config_free(struct sb_config *sc)
+{
+	call_void_hook(sb_config_free, sc);
+}
+
+int security_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	return call_int_hook(sb_config_parse_option, 0, sc, opt);
+}
+
+int security_sb_config_kern_mount(struct sb_config *sc, struct super_block *sb)
+{
+	return call_int_hook(sb_config_kern_mount, 0, sc, sb);
+}
+
 int security_sb_alloc(struct super_block *sb)
 {
 	return call_int_hook(sb_alloc_security, 0, sb);
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index e67a526d1f30..286207bced52 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -47,6 +47,7 @@
 #include <linux/fdtable.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/sb_config.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
@@ -2826,6 +2827,169 @@ static int selinux_umount(struct vfsmount *mnt, int flags)
 				   FILESYSTEM__UNMOUNT, NULL);
 }
 
+/* fsopen mount context operations */
+
+static int selinux_sb_config_alloc(struct sb_config *sc,
+				   struct super_block *src_sb)
+{
+	struct security_mnt_opts *opts;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+
+	sc->security = opts;
+	return 0;
+}
+
+static int selinux_sb_config_dup(struct sb_config *sc,
+				 struct sb_config *src_sc)
+{
+	const struct security_mnt_opts *src = src_sc->security;
+	struct security_mnt_opts *opts;
+	int i, n;
+
+	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
+	if (!opts)
+		return -ENOMEM;
+	sc->security = opts;
+
+	if (!src || !src->num_mnt_opts)
+		return 0;
+	n = opts->num_mnt_opts = src->num_mnt_opts;
+
+	if (src->mnt_opts) {
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
+static void selinux_sb_config_free(struct sb_config *sc)
+{
+	struct security_mnt_opts *opts = sc->security;
+
+	security_free_mnt_opts(opts);
+	sc->security = NULL;
+}
+
+static int selinux_sb_config_parse_option(struct sb_config *sc, char *opt)
+{
+	struct security_mnt_opts *opts = sc->security;
+	substring_t args[MAX_OPT_ARGS];
+	unsigned int have;
+	char *c, **oo;
+	int token, ctx, i, *of;
+
+	token = match_token(opt, tokens, args);
+	if (token == Opt_error)
+		return 0; /* Doesn't belong to us. */
+
+	have = 0;
+	for (i = 0; i < opts->num_mnt_opts; i++)
+		have |= 1 << opts->mnt_opts_flags[i];
+	if (have & (1 << token))
+		return sb_cfg_inval(sc, "SELinux: Duplicate mount options");
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
+		return sb_cfg_inval(sc, "SELinux: Unknown mount option");
+	}
+
+copy_context_string:
+	if (opts->num_mnt_opts > 3)
+		return sb_cfg_inval(sc, "SELinux: Too many options");
+	
+	of = krealloc(opts->mnt_opts_flags,
+		      (opts->num_mnt_opts + 1) * sizeof(int), GFP_KERNEL);
+	if (!of)
+		return -ENOMEM;
+	of[opts->num_mnt_opts] = 0;
+	opts->mnt_opts_flags = of;
+
+	oo = krealloc(opts->mnt_opts,
+		      (opts->num_mnt_opts + 1) * sizeof(char *), GFP_KERNEL);
+	if (!oo)
+		return -ENOMEM;
+	oo[opts->num_mnt_opts] = NULL;
+	opts->mnt_opts = oo;
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
+	return sb_cfg_inval(sc, "SELinux: Incompatible mount options");
+}
+
+static int selinux_sb_config_kern_mount(struct sb_config *sc,
+					struct super_block *sb)
+{
+	const struct cred *cred = current_cred();
+	struct common_audit_data ad;
+	int rc;
+
+	rc = selinux_set_mnt_opts(sb, sc->security, 0, NULL);
+	if (rc)
+		return rc;
+
+	/* Allow all mounts performed by the kernel */
+	if (sc->ms_flags & MS_KERNMOUNT)
+		return 0;
+
+	ad.type = LSM_AUDIT_DATA_DENTRY;
+	ad.u.dentry = sb->s_root;
+	rc = superblock_has_perm(cred, sb, FILESYSTEM__MOUNT, &ad);
+	if (rc < 0)
+		sb_cfg_error(sc, "SELinux: Mount of superblock not permitted");
+	return rc;
+}
+
 /* inode security operations */
 
 static int selinux_inode_alloc_security(struct inode *inode)
@@ -6154,6 +6318,12 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
 	LSM_HOOK_INIT(bprm_committed_creds, selinux_bprm_committed_creds),
 	LSM_HOOK_INIT(bprm_secureexec, selinux_bprm_secureexec),
 
+	LSM_HOOK_INIT(sb_config_alloc, selinux_sb_config_alloc),
+	LSM_HOOK_INIT(sb_config_dup, selinux_sb_config_dup),
+	LSM_HOOK_INIT(sb_config_free, selinux_sb_config_free),
+	LSM_HOOK_INIT(sb_config_parse_option, selinux_sb_config_parse_option),
+	LSM_HOOK_INIT(sb_config_kern_mount, selinux_sb_config_kern_mount),
+
 	LSM_HOOK_INIT(sb_alloc_security, selinux_sb_alloc_security),
 	LSM_HOOK_INIT(sb_free_security, selinux_sb_free_security),
 	LSM_HOOK_INIT(sb_copy_data, selinux_sb_copy_data),

