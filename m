Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:42641 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751920AbdFNSCf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 14:02:35 -0400
Subject: Re: [PATCH 08/27] VFS: Introduce the structs and doc for a filesystem
 context [ver #5]
To: David Howells <dhowells@redhat.com>, mszeredi@redhat.com,
        viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <1cafb81d-7e72-bc1c-56fa-7ca171dca578@infradead.org>
Date: Wed, 14 Jun 2017 11:02:30 -0700
MIME-Version: 1.0
In-Reply-To: <149745339478.10897.13154531822843514976.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/14/17 08:16, David Howells wrote:
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
>  Documentation/filesystems/mounting.txt |  436 ++++++++++++++++++++++++++++++++
>  include/linux/fs_context.h             |   72 +++++
>  2 files changed, 508 insertions(+)
>  create mode 100644 Documentation/filesystems/mounting.txt
>  create mode 100644 include/linux/fs_context.h
> 
> diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
> new file mode 100644
> index 000000000000..315a5a4ff5cc
> --- /dev/null
> +++ b/Documentation/filesystems/mounting.txt
> @@ -0,0 +1,436 @@
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
> +
> + (3) Validate and pre-process the context.
> +
> + (4) Get or create a superblock and mountable root.
> +
> + (5) Perform the mount.
> +
> + (6) Return an error message attached to the context.
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
> +(such as namespaces), for submount (FS_CONTEXT_FOR_SUBMOUNT) or remount

                       ;

> +(FS_CONTEXT_FOR_REMOUNT) purposes or it will be NULL.
> +
> +Note that security initialisation is done *after* the filesystem is called so
> +that the namespaces may be adjusted first.
> +
> +And the super_operations struct gains one:

                                         one field:

> +
> +	int (*remount_fs_fc) (struct super_block *, struct fs_context *);
> +
> +This shadows the ->remount_fs() operation and takes a prepared filesystem
> +context instead of the mount flags and data page.  It may modify the ms_flags
> +in the context for the caller to pick up.
> +
> +[NOTE] remount_fs_fc is intended as a replacement for remount_fs.
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
> +		void			*security;
> +		unsigned int		sb_flags;
> +		bool			sloppy;
> +		bool			silent;
> +		bool			degraded;
> +		enum fs_context_purpose	purpose : 8;
> +	};
> +
> +When the VFS creates this, it allocates ->fs_context_size bytes (as specified
> +by the file_system_type object) to hold both the fs_context struct and any
> +extra data required by the filesystem.  The fs_context struct is placed at the
> +beginning of this space.  Any extra space beyond that is for use by the
> +filesystem.  The filesystem should wrap the struct in its own, e.g.:
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
> +     constructed or reconfigured.  This retains a ref on the type owner.

s/ref/reference/

> +
> + (*) struct dentry *root
> +
> +     A pointer to the root of the mountable tree (and indirectly, the
> +     superblock thereof).  This is filled in by the ->get_tree() op.
> +
> + (*) struct user_namespace *user_ns
> + (*) struct net *net_ns
> +
> +     This is a subset of the namespaces in use by the invoking process.  This

	These are                                                           They

> +     retains a ref on each namespace.  The subscribed namespaces may be

	retain a reference

> +     replaced by the filesystem to reflect other sources, such as the parent
> +     mount superblock on an automount.
> +
> + (*) struct cred *cred
> +
> +     The mounter's credentials.  This retains a ref on the credentials.

s/ref/reference/

> +
> + (*) char *device
> +
> +     This is the device to be mounted.  It may be a block device
> +     (e.g. /dev/sda1) or something more exotic, such as the "host:/path" that
> +     NFS desires.
> +
> + (*) void *security
> +
> +     A place for the LSMs to hang their security data for the superblock.  The
> +     relevant security operations are described below.
> +
> + (*) unsigned int sb_flags
> +
> +     This holds the MS_* flags mount flags.
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
> +     [NOTE] silent is probably redundant with ms_flags & MS_SILENT.
> +
> + (*) bool degraded
> +
> +     This is set if any preallocated resources in the context have been used
> +     up, thereby rendering it unreusable for the ->get_tree() op.
> +
> + (*) enum fs_context_purpose
> +
> +     This indicates the purpose for which the context is intended.  The
> +     available values are:
> +
> +	FS_CONTEXT_FOR_NEW	-- New mount
> +	FS_CONTEXT_FOR_SUBMOUNT	-- New automatic submount of extant mount
> +	FS_CONTEXT_FOR_REMOUNT	-- Change an existing mount
> +
> +The mount context is created by calling vfs_new_fs_context(), vfs_sb_reconfig()
> +or vfs_dup_fs_context() and is destroyed with put_fs_context().  Note that the
> +structure is not refcounted.
> +
> +VFS, security and filesystem mount options are set individually with
> +vfs_parse_mount_option().  Options provided by the old mount(2) system call as
> +a page of data can be parsed with generic_monolithic_mount_data().
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
> +		int (*parse_option)(struct fs_context *fc, char *p);
> +		int (*monolithic_mount_data)(struct fs_context *fc, void *data);
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
> + (*) int (*parse_option)(struct fs_context *fc, char *p);
> +
> +     Called when an option is to be added to the filesystem context.  p points
> +     to the option string, likely in "key[=val]" format.  VFS-specific options
> +     will have been weeded out and fc->sb_flags updated in the context.
> +     Security options will also have been weeded out and fc->security updated.
> +
> +     If successful, 0 should be returned and a negative error code otherwise.
> +     If an ambiguous error (such as -EINVAL) is returned, sb_cfg_error() or
> +     sb_cfg_inval() should be used to provide a string that provides more
> +     information.
> +
> + (*) int (*monolithic_mount_data)(struct fs_context *fc, void *data);
> +
> +     Called when the mount(2) system call is invoked to pass the entire data
> +     page in one go.  If this is expected to be just a list of "key[=val]"
> +     items separated by commas, then this may be set to NULL.
> +
> +     The return value is as for ->parse_option().
> +
> +     If the filesystem (eg. NFS) needs to examine the data first and then finds
> +     it's the standard key-val list then it may pass it off to
> +     generic_monolithic_mount_data().
> +
> + (*) int (*validate)(struct fs_context *fc);
> +
> +     Called when all the options have been applied and the mount is about to
> +     take place.  It is should check for inconsistencies from mount options and
> +     it is also allowed to do preliminary resource acquisition.  For instance,
> +     the core NFS module could load the NFS protocol module here.
> +
> +     Note that if fc->mount_type == FS_CONTEXT_FOR_REMOUNT, some of the options
> +     necessary for a new mount may not be set.
> +
> +     The return value is as for ->parse_option().
> +
> + (*) int (*get_tree)(struct fs_context *fc);
> +
> +     Called to get or create the mountable root and superblock, using the
> +     information stored in the filesystem context (remounts go
> +     via a different vector).  It may detach any resources it desires from the
> +     filesystem context and transfer them to the superblock it
> +     creates.
> +
> +     On success it should set fc->root to the mountable root.
> +
> +     In the case of an error, it should return a negative error code and
> +     consider invoking sb_cfg_inval() or sb_cfg_error().
> +
> +
> +=========================================
> +FILESYSTEM CONTEXT SECURITY
> +========================================
> +
> +The filesystem context contains a security points that the LSMs

                                              point or pointer ?

> +can use for building up a security context for the superblock to be mounted.
> +There are a number of operations used by the new mount code for this purpose:


-- 
~Randy
