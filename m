Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:44332 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753934AbeDWDg0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Apr 2018 23:36:26 -0400
Subject: Re: [PATCH 03/24] VFS: Introduce the structs and doc for a filesystem
 context [ver #7]
To: David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
 <152414468332.23902.3065751107691714414.stgit@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <05034a85-013b-30b6-ce17-4c95d4cab195@infradead.org>
Date: Sun, 22 Apr 2018 20:36:22 -0700
MIME-Version: 1.0
In-Reply-To: <152414468332.23902.3065751107691714414.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

On 04/19/18 06:31, David Howells wrote:
> Introduce a filesystem context concept to be used during superblock
> creation for mount and superblock reconfiguration for remount.  This is
> allocated at the beginning of the mount procedure and into it is placed:
> 
>  (1) Filesystem type.
> 
>  (2) Namespaces.
> 
>  (3) Device name.
> 
>  (4) Superblock flags (MS_*).
> 
>  (5) Security details.
> 
>  (6) Filesystem-specific data, as set by the mount options.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
> 
>  Documentation/filesystems/mounting.txt |  445 ++++++++++++++++++++++++++++++++
>  include/linux/fs_context.h             |   76 +++++
>  2 files changed, 521 insertions(+)
>  create mode 100644 Documentation/filesystems/mounting.txt
>  create mode 100644 include/linux/fs_context.h

> diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
> new file mode 100644
> index 000000000000..805135a66b64
> --- /dev/null
> +++ b/Documentation/filesystems/mounting.txt
> @@ -0,0 +1,445 @@
> +			      ===================
> +			      FILESYSTEM MOUNTING
> +			      ===================
> +
> +CONTENTS
> +
> + (1) Overview.
> +
> + (2) The filesystem context.
> +
> + (3) The filesystem context operations.
> +
> + (4) Filesystem context security.
> +
> + (5) VFS filesystem context operations.
> +
> +
> +========
> +OVERVIEW
> +========
> +
> +The creation of new mounts is now to be done in a multistep process:
> +
> + (1) Create a filesystem context.
> +
> + (2) Parse the options and attach them to the context.  Options may be passed
> +     individually from userspace.

Does this say that step (2) can be multiple small steps? How does step (2) know
when userspace has completed sending individual options?


> +
> + (3) Validate and pre-process the context.
> +
> + (4) Get or create a superblock and mountable root.
> +
> + (5) Perform the mount.
> +
> + (6) Return an error message attached to the context.

where/how is this done?

> +
> + (7) Destroy the context.
> +
> +To support this, the file_system_type struct gains two new fields:
> +
> +	unsigned short fs_context_size;
> +
> +which indicates the total amount of space that should be allocated for context
> +data (see the Filesystem Context section), and:
> +
> +	int (*init_fs_context)(struct fs_context *fc, struct super_block *src_sb);
> +
> +which is invoked to set up the filesystem-specific parts of a filesystem
> +context, including the additional space.  The src_sb parameter is used to
> +convey the superblock from which the filesystem may draw extra information
> +(such as namespaces) for submount (FS_CONTEXT_FOR_SUBMOUNT) or reconfiguration
> +(FS_CONTEXT_FOR_RECONFIGURE) purposes - otherwise it will be NULL.
> +
> +Note that security initialisation is done *after* the filesystem is called so
> +that the namespaces may be adjusted first.
> +
> +And the super_operations struct gains one field:
> +
> +	int (*reconfigure) (struct super_block *, struct fs_context *);
> +
> +This shadows the ->reconfigure() operation and takes a prepared filesystem
> +context instead of the mount flags and data page.  It may modify the sb_flags
> +in the context for the caller to pick up.
> +
> +[NOTE] reconfigure is intended as a replacement for remount_fs.
> +
> +
> +======================
> +THE FILESYSTEM CONTEXT
> +======================
> +
> +The creation and reconfiguration of a superblock is governed by a filesystem
> +context.  This is represented by the fs_context structure:
> +
> +	struct fs_context {
> +		const struct fs_context_operations *ops;
> +		struct file_system_type *fs;
> +		struct dentry		*root;
> +		struct user_namespace	*user_ns;
> +		struct net		*net_ns;
> +		const struct cred	*cred;
> +		char			*device;
> +		char			*subtype;
> +		void			*security;
> +		void			*s_fs_info;
> +		unsigned int		sb_flags;
> +		bool			sloppy;
> +		bool			silent;
> +		bool			degraded;
> +		bool			drop_sb;
> +		enum fs_context_purpose	purpose : 8;
> +	};
> +
> +When the VFS creates this, it allocates ->fs_context_size bytes (as specified
> +by the file_system_type object) to hold both the fs_context struct and any
> +extra data required by the filesystem.  The fs_context struct is placed at the
> +beginning of this space.  Any extra space beyond that is for use by the
> +filesystem.  The filesystem should wrap the struct in its own, e.g.:

                                                      in its own struct, e.g.:

> +
> +	struct nfs_fs_context {
> +		struct fs_context fc;
> +		...
> +	};
> +
> +placing the fs_context struct first.  container_of() can then be used.  The
> +file_system_type would be initialised thus:
> +
> +	struct file_system_type nfs = {
> +		...
> +		.fs_context_size	= sizeof(struct nfs_fs_context),
> +		.init_fs_context	= nfs_init_fs_context,
> +		...
> +	};
> +
> +The fs_context fields are as follows:
> +
> + (*) const struct fs_context_operations *ops
> +
> +     These are operations that can be done on a filesystem context (see
> +     below).  This must be set by the ->init_fs_context() file_system_type
> +     operation.
> +
> + (*) struct file_system_type *fs
> +
> +     A pointer to the file_system_type of the filesystem that is being
> +     constructed or reconfigured.  This retains a reference on the type owner.
> +
> + (*) struct dentry *root
> +
> +     A pointer to the root of the mountable tree (and indirectly, the
> +     superblock thereof).  This is filled in by the ->get_tree() op.
> +
> + (*) struct user_namespace *user_ns
> + (*) struct net *net_ns
> +
> +     There are a subset of the namespaces in use by the invoking process.  They
> +     retain references on each namespace.  The subscribed namespaces may be
> +     replaced by the filesystem to reflect other sources, such as the parent
> +     mount superblock on an automount.
> +
> + (*) struct cred *cred
> +
> +     The mounter's credentials.  This retains a reference on the credentials.
> +
> + (*) char *device
> +
> +     This is the device to be mounted.  It may be a block device
> +     (e.g. /dev/sda1) or something more exotic, such as the "host:/path" that
> +     NFS desires.
> +
> + (*) char *subtype
> +
> +     This is a string to be added to the type displayed in /proc/mounts to
> +     qualify it (used by FUSE).  This is available for the filesystem to set if
> +     desired.
> +
> + (*) void *security
> +
> +     A place for the LSMs to hang their security data for the superblock.  The
> +     relevant security operations are described below.
> +
> + (*) void *s_fs_info
> +
> +     The proposed s_fs_info for a new superblock, set in the superblock by
> +     sget_fc().  This can be used to distinguish superblocks.
> +
> + (*) unsigned int sb_flags
> +
> +     This holds the SB_* flags to be set in super_block::s_flags.
> +
> + (*) bool sloppy
> + (*) bool silent
> +
> +     These are set if the sloppy or silent mount options are given.
> +
> +     [NOTE] sloppy is probably unnecessary when userspace passes over one
> +     option at a time since the error can just be ignored if userspace deems it
> +     to be unimportant.
> +
> +     [NOTE] silent is probably redundant with sb_flags & SB_SILENT.
> +
> + (*) bool degraded
> +
> +     This is set if any preallocated resources in the context have been used
> +     up, thereby rendering it unreusable for the ->get_tree() op.
> +
> + (*) bool drop_sb
> +
> +     This is set if a superblock reference needs to be deactivated when the
> +     context is put.
> +
> + (*) enum fs_context_purpose
> +
> +     This indicates the purpose for which the context is intended.  The
> +     available values are:
> +
> +	FS_CONTEXT_FOR_USER_MOUNT,	-- New superblock for user-specified mount
> +	FS_CONTEXT_FOR_KERNEL_MOUNT,	-- New superblock for kernel-internal mount
> +	FS_CONTEXT_FOR_SUBMOUNT		-- New automatic submount of extant mount
> +	FS_CONTEXT_FOR_RECONFIGURE	-- Change an existing mount
> +
> +The mount context is created by calling vfs_new_fs_context(), vfs_sb_reconfig()
> +or vfs_dup_fs_context() and is destroyed with put_fs_context().  Note that the
> +structure is not refcounted.
> +
> +VFS, security and filesystem mount options are set individually with
> +vfs_parse_mount_option().  Options provided by the old mount(2) system call as
> +a page of data can be parsed with generic_parse_monolithic().
> +
> +When mounting, the filesystem is allowed to take data from any of the pointers
> +and attach it to the superblock (or whatever), provided it clears the pointer
> +in the mount context.
> +
> +The filesystem is also allowed to allocate resources and pin them with the
> +mount context.  For instance, NFS might pin the appropriate protocol version
> +module.
> +
> +
> +=================================
> +THE FILESYSTEM CONTEXT OPERATIONS
> +=================================
> +
> +The filesystem context points to a table of operations:
> +
> +	struct fs_context_operations {
> +		void (*free)(struct fs_context *fc);
> +		int (*dup)(struct fs_context *fc, struct fs_context *src_fc);
> +		int (*parse_source)(struct fs_context *fc);
> +		int (*parse_option)(struct fs_context *fc, char *opt);
> +		int (*parse_monolithic)(struct fs_context *fc, void *data);
> +		int (*validate)(struct fs_context *fc);
> +		int (*get_tree)(struct fs_context *fc);
> +	};
> +
> +These operations are invoked by the various stages of the mount procedure to
> +manage the filesystem context.  They are as follows:
> +
> + (*) void (*free)(struct fs_context *fc);
> +
> +     Called to clean up the filesystem-specific part of the filesystem context
> +     when the context is destroyed.  It should be aware that parts of the
> +     context may have been removed and NULL'd out by ->get_tree().
> +
> + (*) int (*dup)(struct fs_context *fc, struct fs_context *src_fc);
> +
> +     Called when a filesystem context has been duplicated to get any refs or
> +     copy any non-referenced resources held in the filesystem-specific part of
> +     the filesystem context.  An error may be returned to indicate failure to
> +     do this.
> +
> +     [!] Note that even if this fails, put_fs_context() will be called
> +	 immediately thereafter, so ->dup() *must* make the
> +	 filesystem-specific part safe for ->free().
> +
> + (*) int (*parse_source)(struct fs_context *fc);
> +
> +     Called when the source or device is specified for a filesystem context.
> +     The string will have been stored in fc->source prior to calling.  If

"source" is called "device" above but "source" in the header file.
Please change one of them to be consistent.

> +     successful, 0 should be returned and a negative error code otherwise.

	                                 or a

> +
> + (*) int (*parse_option)(struct fs_context *fc, char *p);
> +
> +     Called when an option is to be added to the filesystem context.  p points
> +     to the option string, likely in "key[=val]" format.  VFS-specific options
> +     will have been weeded out and fc->sb_flags updated in the context.
> +     Security options will also have been weeded out and fc->security updated.
> +
> +     If successful, 0 should be returned and a negative error code otherwise.

	                                    or a

> +
> + (*) int (*parse_monolithic)(struct fs_context *fc, void *data);
> +
> +     Called when the mount(2) system call is invoked to pass the entire data
> +     page in one go.  If this is expected to be just a list of "key[=val]"
> +     items separated by commas, then this may be set to NULL.
> +
> +     The return value is as for ->parse_option().
> +
> +     If the filesystem (eg. NFS) needs to examine the data first and then finds

	                   e.g.

> +     it's the standard key-val list then it may pass it off to
> +     generic_parse_monolithic().
> +
> + (*) int (*validate)(struct fs_context *fc);
> +
> +     Called when all the options have been applied and the mount is about to
> +     take place.  It is should check for inconsistencies from mount options and
> +     it is also allowed to do preliminary resource acquisition.  For instance,
> +     the core NFS module could load the NFS protocol module here.
> +
> +     Note that if fc->purpose == FS_CONTEXT_FOR_RECONFIGURE, some of the
> +     options necessary for a new mount may not be set.
> +
> +     The return value is as for ->parse_option().
> +
> + (*) int (*get_tree)(struct fs_context *fc);
> +
> +     Called to get or create the mountable root and superblock, using the
> +     information stored in the filesystem context (reconfiguration goes via a
> +     different vector).  It may detach any resources it desires from the
> +     filesystem context and transfer them to the superblock it creates.
> +
> +     On success it should set fc->root to the mountable root and return 0.  In
> +     the case of an error, it should return a negative error code.
> +
> +
> +===========================
> +FILESYSTEM CONTEXT SECURITY
> +===========================
> +
> +The filesystem context contains a security pointer that the LSMs can use for
> +building up a security context for the superblock to be mounted.  There are a
> +number of operations used by the new mount code for this purpose:
> +
> + (*) int security_fs_context_alloc(struct fs_context *fc,
> +				   struct super_block *src_sb);
> +
> +     Called to initialise fc->security (which is preset to NULL) and allocate
> +     any resources needed.  It should return 0 on success and a negative error

	                                                     or a

> +     code on failure.
> +
> +     src_sb is non-NULL in the case of reconfiguration
> +     (FS_CONTEXT_FOR_RECONFIGURE) in which case it indicates the superblock to
> +     be reconfigured or in the case of a submount (FS_CONTEXT_FOR_SUBMOUNT) in
> +     which case it indicates the parent superblock.

I seem to recall that you were going to rewrite that long sentence above.
-ETOOMANYCASES

> +
> + (*) int security_fs_context_dup(struct fs_context *fc,
> +				 struct fs_context *src_fc);
> +
> +     Called to initialise fc->security (which is preset to NULL) and allocate
> +     any resources needed.  The original filesystem context is pointed to by
> +     src_fc and may be used for reference.  It should return 0 on success and a

	                                                                     or a

> +     negative error code on failure.
> +
> + (*) void security_fs_context_free(struct fs_context *fc);
> +
> +     Called to clean up anything attached to fc->security.  Note that the
> +     contents may have been transferred to a superblock and the pointer NULL'd
> +     out during mount.

[Here we have evidence that in English any noun can be verbed.]   :)

> +
> + (*) int security_fs_context_parse_option(struct fs_context *fc, char *opt);	
> +
> +     Called for each mount option.  The arguments are as for the
> +     ->parse_option() method.  An active LSM may reject one with an error, pass
> +     one over and return 0 or consume one and return 1.  If consumed, the

What does "pass one over" mean?

> +     option isn't passed on to the filesystem.
> +
> + (*) int security_sb_get_tree(struct fs_context *fc);
> +
> +     Called during the mount procedure to verify that the specified superblock
> +     is allowed to be mounted and to transfer the security data there.  It
> +     should return 0 or a negative error code.
> +
> +     [NOTE] Should I add a security_fs_context_validate() operation so that the
> +     LSM has the opportunity to allocate stuff and check the options as a
> +     whole?
> +
> + (*) int security_sb_mountpoint(struct fs_context *fc, struct path *mountpoint)

	end line with ';' like the other prototypes.

> +
> +     Called during the mount procedure to verify that the root dentry attached
> +     to the context is permitted to be attached to the specified mountpoint.
> +     It should return 0 on success and a negative error code on failure.

	                              or a

> +
> +
> +=================================
> +VFS FILESYSTEM CONTEXT OPERATIONS
> +=================================
> +
> +There are four operations for creating a filesystem context and
> +one for destroying a context:
> +
> + (*) struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
> +					   struct super_block *src_sb;

				s/;/,/ above

> +					   unsigned int sb_flags);
> +
> +     Create a filesystem context for a given filesystem type.  This allocates
> +     the filesystem context, sets the flags, initialises the security and calls
> +     fs_type->init_fs_context() to initialise the filesystem context.
> +
> +     src_sb can be NULL or it may indicate a superblock that is going to be
> +     reconfigured (FS_CONTEXT_FOR_RECONFIGURE) or a superblock that is the
> +     parent of a submount (FS_CONTEXT_FOR_SUBMOUNT).  This superblock is
> +     provided as a source of namespace information.
> +
> + (*) struct fs_context *vfs_sb_reconfigure(struct vfsmount *mnt,
> +					   unsigned int sb_flags);
> +
> +     Create a filesystem context from the same filesystem as an extant mount
> +     and initialise the mount parameters from the superblock underlying that
> +     mount.  This is for use by superblock parameter reconfiguration.
> +
> + (*) struct fs_context *vfs_dup_fs_context(struct fs_context *src_fc);
> +
> +     Duplicate a filesystem context, copying any options noted and duplicating
> +     or additionally referencing any resources held therein.  This is available
> +     for use where a filesystem has to get a mount within a mount, such as NFS4
> +     does by internally mounting the root of the target server and then doing a
> +     private pathwalk to the target directory.
> +
> + (*) void put_fs_context(struct fs_context *fc);
> +
> +     Destroy a filesystem context, releasing any resources it holds.  This
> +     calls the ->free() operation.  This is intended to be called by anyone who
> +     created a filesystem context.
> +
> +     [!] filesystem contexts are not refcounted, so this causes unconditional
> +	 destruction.
> +
> +In all the above operations, apart from the put op, the return is a mount
> +context pointer or a negative error code.
> +
> +For the remaining operations, if an error occurs, a negative error code will be
> +returned.
> +
> + (*) int vfs_get_tree(struct fs_context *fc);
> +
> +     Get or create the mountable root and superblock, using the parameters in
> +     the filesystem context to select/configure the superblock.  This invokes
> +     the ->validate() op and then the ->get_tree() op.
> +
> +     [NOTE] ->validate() could perhaps be rolled into ->get_tree() and
> +     ->reconfigure().
> +
> + (*) struct vfsmount *vfs_create_mount(struct fs_context *fc);
> +
> +     Create a mount given the parameters in the specified filesystem context.
> +     Note that this does not attach the mount to anything.
> +
> + (*) int vfs_set_fs_source(struct fs_context *fc, char *source);
> +
> +     Supply the source name or device name for the mount.  This may cause the
> +     filesystem to access the device.
> +
> + (*) int vfs_parse_fs_option(struct fs_context *fc, char *data);
> +
> +     Supply a single mount option to the filesystem context.  The mount option
> +     should likely be in a "key[=val]" string form.  The option is first
> +     checked to see if it corresponds to a standard mount flag (in which case
> +     it is used to set an SB_xxx flag and consumed) or a security option (in
> +     which case the LSM consumes it) before it is passed on to the filesystem.
> +
> + (*) int generic_parse_monolithic(struct fs_context *fc, void *data);
> +
> +     Parse a sys_mount() data page, assuming the form to be a text list
> +     consisting of key[=val] options separated by commas.  Each item in the
> +     list is passed to vfs_mount_option().  This is the default when the
> +     ->parse_monolithic() operation is NULL.

> diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
> new file mode 100644
> index 000000000000..732a11898242
> --- /dev/null
> +++ b/include/linux/fs_context.h
> @@ -0,0 +1,76 @@
> +/* Filesystem superblock creation and reconfiguration context.
> + *
> + * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
> + * Written by David Howells (dhowells@redhat.com)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public Licence
> + * as published by the Free Software Foundation; either version
> + * 2 of the Licence, or (at your option) any later version.
> + */
> +
> +#ifndef _LINUX_FS_CONTEXT_H
> +#define _LINUX_FS_CONTEXT_H
> +
> +#include <linux/kernel.h>
> +#include <linux/errno.h>
> +
> +struct cred;
> +struct dentry;
> +struct file_operations;
> +struct file_system_type;
> +struct mnt_namespace;
> +struct net;
> +struct pid_namespace;
> +struct super_block;
> +struct user_namespace;
> +struct vfsmount;
> +
> +enum fs_context_purpose {
> +	FS_CONTEXT_FOR_USER_MOUNT,	/* New superblock for user-specified mount */
> +	FS_CONTEXT_FOR_KERNEL_MOUNT,	/* New superblock for kernel-internal mount */
> +	FS_CONTEXT_FOR_SUBMOUNT,	/* New superblock for automatic submount */
> +	FS_CONTEXT_FOR_RECONFIGURE,	/* Superblock reconfiguration (remount) */
> +};
> +
> +/*
> + * Filesystem context as allocated and constructed by the ->init_fs_context()
> + * file_system_type operation.  The size of the object allocated is specified
> + * in struct file_system_type::fs_context_size and this must include sufficient
> + * space for the fs_context struct.
> + *
> + * Superblock creation fills in ->root whereas reconfiguration begins with this
> + * already set.
> + *
> + * See Documentation/filesystems/mounting.txt
> + */
> +struct fs_context {
> +	const struct fs_context_operations *ops;
> +	struct file_system_type	*fs_type;
> +	struct dentry		*root;		/* The root and superblock */
> +	struct user_namespace	*user_ns;	/* The user namespace for this mount */
> +	struct net		*net_ns;	/* The network namespace for this mount */
> +	const struct cred	*cred;		/* The mounter's credentials */
> +	char			*source;	/* The source name (eg. device) */
> +	char			*subtype;	/* The subtype to set on the superblock */
> +	void			*security;	/* The LSM context */
> +	void			*s_fs_info;	/* Proposed s_fs_info */
> +	unsigned int		sb_flags;	/* Proposed superblock flags (SB_*) */
> +	bool			sloppy;		/* Unrecognised options are okay */
> +	bool			silent;
> +	bool			degraded;	/* True if the context can't be reused */
> +	bool			drop_sb;	/* T if need to drop an SB reference */

s/T /True /

> +	enum fs_context_purpose	purpose : 8;
> +};
> +
> +struct fs_context_operations {
> +	void (*free)(struct fs_context *fc);
> +	int (*dup)(struct fs_context *fc, struct fs_context *src_fc);
> +	int (*parse_source)(struct fs_context *fc);
> +	int (*parse_option)(struct fs_context *fc, char *opt, size_t len);
> +	int (*parse_monolithic)(struct fs_context *fc, void *data);
> +	int (*validate)(struct fs_context *fc);
> +	int (*get_tree)(struct fs_context *fc);
> +};
> +
> +#endif /* _LINUX_FS_CONTEXT_H */
> 


-- 
~Randy
