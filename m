Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35807 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754851AbdEHPF2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 May 2017 11:05:28 -0400
Received: by mail-wm0-f43.google.com with SMTP id b84so58091245wmh.0
        for <linux-nfs@vger.kernel.org>; Mon, 08 May 2017 08:05:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Mon, 8 May 2017 17:05:25 +0200
Message-ID: <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 3, 2017 at 6:04 PM, David Howells <dhowells@redhat.com> wrote:
> Introduce a mount context concept.  This is allocated at the beginning of
> the mount procedure and into it is placed:
>
>  (1) Filesystem type.
>
>  (2) Namespaces.
>
>  (3) Device name.
>
>  (4) Superblock flags (MS_*) and mount flags (MNT_*).
>
>  (5) Security details.
>
>  (6) Filesystem-specific data, as set by the mount options.
>
> It also gives a place in which to hang an error message for later retrieval
> (see the mount-by-fd syscall later in this series).
>
> Rather than calling fs_type->mount(), a mount_context struct is created and
> fs_type->fsopen() is called to set it up.  fs_type->mc_size says how much
> should be added on to the mount context for the filesystem's use.
>
> A set of operations have to be set by ->fsopen() to provide freeing,
> duplication, option parsing, binary data parsing, validation, mounting and
> superblock filling.
>
> It should be noted that, whilst this patch adds a lot of lines of code,
> there is quite a bit of duplication with existing code that can be
> eliminated should all filesystems be converted over.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  Documentation/filesystems/mounting.txt |  445 ++++++++++++++++++++++++++++++++
>  fs/Makefile                            |    3
>  fs/internal.h                          |    2
>  fs/mount.h                             |    3
>  fs/mount_context.c                     |  343 +++++++++++++++++++++++++
>  fs/namespace.c                         |  270 +++++++++++++++++--
>  fs/super.c                             |   50 +++-
>  include/linux/fs.h                     |   11 +
>  include/linux/lsm_hooks.h              |   37 +++
>  include/linux/mount.h                  |   67 +++++
>  include/linux/security.h               |   29 ++
>  security/security.c                    |   32 ++
>  security/selinux/hooks.c               |  179 +++++++++++++
>  13 files changed, 1435 insertions(+), 36 deletions(-)
>  create mode 100644 Documentation/filesystems/mounting.txt
>  create mode 100644 fs/mount_context.c
>
> diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
> new file mode 100644
> index 000000000000..a942ccd08376
> --- /dev/null
> +++ b/Documentation/filesystems/mounting.txt
> @@ -0,0 +1,445 @@
> +                             ===================
> +                             FILESYSTEM MOUNTING
> +                             ===================
> +
> +CONTENTS
> +
> + (1) Overview.
> +
> + (2) The mount context.
> +
> + (3) The mount context operations.
> +
> + (4) Mount context security.
> +
> + (5) VFS mount context operations.
> +
> +
> +========
> +OVERVIEW
> +========
> +
> +The creation of new mounts is now to be done in a multistep process:
> +
> + (1) Create a mount context.
> +
> + (2) Parse the options and attach them to the mount context.  Options may be
> +     passed individually from userspace.
> +
> + (3) Validate and pre-process the mount context.

(3.5) Create super block

I think this need to be triggered by something like a "commit" command
from userspace.  Basically this is where the options are atomically
set on the new (create) or existing (reconfigure) superblock.

> +
> + (4) Perform the mount.
> +
> + (5) Return an error message attached to the mount context.

Swap the order of the above.  There's no fs specific actions performed
at fsmount() time, and normal errno reporting should be perfectly
fine.

> +
> + (6) Destroy the mount context.
> +
> +To support this, the file_system_type struct gains two new fields:
> +
> +       unsigned short mc_size;
> +
> +which indicates how much space the filesystem would like tacked onto the end of
> +the mount_context struct for its own purposes, and:
> +
> +       int (*fsopen)(struct mount_context *mc, struct super_block *src_sb);
> +
> +which is invoked to set up the filesystem-specific parts of a mount context,
> +including the additional space.  The src_sb parameter is used to convey the
> +superblock from which the filesystem may draw extra information (such as
> +namespaces), for submount (MS_SUBMOUNT) or remount (MS_REMOUNT) purposes or it
> +will be NULL.

I think reconfigure (don't call it remount, there's no "mounting"
going on there) should start out with a context populated with with
the current state of the superblock.  User can then reset and start
over or individually add/remove options.   This should be a good place
to allow querying the options as well, as Karel suggested.  Then when
the configuration is finished the changes are committed to the
superblock.

> +
> +Note that security initialisation is done *after* the filesystem is called so
> +that the namespaces may be adjusted first.
> +
> +And the super_operations struct gains one:
> +
> +       int (*remount_fs_mc) (struct super_block *, struct mount_context *);
> +
> +This shadows the ->remount_fs() operation and takes a prepared mount context
> +instead of the mount flags and data page.  It may modify the ms_flags in the
> +context for the caller to pick up.
> +
> +[NOTE] remount_fs_mc is intended as a replacement for remount_fs.
> +
> +
> +=================
> +THE MOUNT CONTEXT
> +=================
> +
> +The mount process is governed by a mount context.  This is represented by the
> +mount_context structure:
> +
> +       struct mount_context {
> +               const struct mount_context_operations *ops;
> +               struct file_system_type *fs;
> +               struct user_namespace   *user_ns;
> +               struct mnt_namespace    *mnt_ns;
> +               struct pid_namespace    *pid_ns;
> +               struct net              *net_ns;
> +               const struct cred       *cred;
> +               char                    *device;
> +               char                    *root_path;
> +               void                    *security;
> +               const char              *error;
> +               unsigned int            ms_flags;
> +               unsigned int            mnt_flags;
> +               bool                    mounted;
> +               bool                    sloppy;
> +               bool                    silent;
> +               enum mount_type         mount_type : 8;
> +       };
> +
> +When allocated, the mount_context struct is extended by ->mc_size bytes as
> +specified by the specified file_system_type struct.  This is for use by the
> +filesystem.  The filesystem should wrap the struct in its own, e.g.:
> +
> +       struct nfs_mount_context {
> +               struct mount_context mc;
> +               ...
> +       };
> +
> +placing the mount_context struct first.  container_of() can then be used.
> +
> +The mount_context fields are as follows:
> +
> + (*) const struct mount_context_operations *ops
> +
> +     These are operations that can be done on a mount context.  See below.
> +     This must be set by the ->fsopen() file_system_type operation.
> +
> + (*) struct file_system_type *fs
> +
> +     A pointer to the file_system_type of the filesystem that is being
> +     mounted.  This retains a ref on the type owner.
> +
> + (*) struct user_namespace *user_ns
> + (*) struct mnt_namespace *mnt_ns
> + (*) struct pid_namespace *pid_ns
> + (*) struct net *net_ns
> +
> +     This is a subset of the namespaces in use by the invoking process.  This
> +     retains a ref on each namespace.  The subscribed namespaces may be
> +     replaced by the filesystem to reflect other sources, such as the parent
> +     mount superblock on an automount.
> +
> + (*) struct cred *cred
> +
> +     The mounter's credentials.  This retains a ref on the credentials.
> +
> + (*) char *device
> +
> +     This is the device to be mounted.  It may be a block device
> +     (e.g. /dev/sda1) or something more exotic, such as the "host:/path" that
> +     NFS desires.
> +
> + (*) char *root_path
> +
> +     A path to the place inside the filesystem to actually mount.  This allows
> +     a mount and bind-mount to be combined.
> +
> +     [NOTE] This isn't implemented yet, but NFS has the code to do this which
> +     could be moved to the VFS.
> +
> + (*) void *security
> +
> +     A place for the LSMs to hang their security data for the mount.  The
> +     relevant security operations are described below.
> +
> + (*) const char *error
> +
> +     A place for the VFS and the filesystem to hang an error message.  This
> +     should be in the form of a static string that doesn't need deallocation
> +     and the pointer to which can just be overwritten.  Under some
> +     circumstances, this can be retrieved by userspace.
> +
> +     Note that the existence of the error string is expected to be guaranteed
> +     by the reference on the file_system_type object held by ->fs or any
> +     filesystem-specific reference held in the filesystem context until the
> +     ->free() operation is called.
> +
> + (*) unsigned int ms_flags
> + (*) unsigned int mnt_flags
> +
> +     These hold the mount flags.  ms_flags holds MS_* flags and mnt_flags holds
> +     MNT_* flags.
> +
> + (*) bool mounted
> +
> +     This is set to true once a mount attempt is made.  This causes an error to
> +     be given on subsequent mount attempts with the same context and prevents
> +     multiple mount attempts.

No point.  A context is mountable if the superblock is non-NULL.
Don't even need to have the context committed, if not, it would simply
mount the sb in the previous state.

I'd hope some simplifications would fall out from this model.

Thanks,
Miklos
