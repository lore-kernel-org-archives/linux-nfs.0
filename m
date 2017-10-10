Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:54396 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752207AbdJJHtz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Oct 2017 03:49:55 -0400
Received: by mail-qt0-f173.google.com with SMTP id z19so3186464qtg.11
        for <linux-nfs@vger.kernel.org>; Tue, 10 Oct 2017 00:49:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 10 Oct 2017 09:49:52 +0200
Message-ID: <CAOssrKfNtKLskdPWS_p87uFzDsZCoN+4L+_bcWBvX18mRVVf_Q@mail.gmail.com>
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 6, 2017 at 5:49 PM, David Howells <dhowells@redhat.com> wrote:
> Implement a filesystem context concept to be used during superblock
> creation for mount and superblock reconfiguration for remount.
>
> The mounting procedure then becomes:
>
>  (1) Allocate new fs_context context.
>
>  (2) Configure the context.
>
>  (3) Create superblock.
>
>  (4) Mount the superblock any number of times.
>
>  (5) Destroy the context.
>
> Rather than calling fs_type->mount(), an fs_context struct is created and
> fs_type->init_fs_context() is called to set it up.
> fs_type->fs_context_size says how much space should be allocated for the
> config context.  The fs_context struct is placed at the beginning and any
> extra space is for the filesystem's use.
>
> A set of operations has to be set by ->init_fs_context() to provide
> freeing, duplication, option parsing, binary data parsing, validation,
> mounting and superblock filling.
>
> Legacy filesystems are supported by the provision of a set of legacy
> fs_context operations that build up a list of mount options and then invoke
> fs_type->mount() from within the fs_context ->get_tree() operation.  This
> allows all filesystems to be accessed using fs_context.
>
> It should be noted that, whilst this patch adds a lot of lines of code,
> there is quite a bit of duplication with existing code that can be
> eliminated should all filesystems be converted over.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>
>  Documentation/filesystems/mounting.txt |    7
>  fs/Makefile                            |    3
>  fs/fs_context.c                        |  526 ++++++++++++++++++++++++++++++++
>  fs/internal.h                          |    2
>  fs/libfs.c                             |   17 +
>  fs/namespace.c                         |  337 ++++++++++++++-------
>  fs/super.c                             |  294 +++++++++++++++++-
>  include/linux/fs.h                     |   16 +
>  include/linux/fs_context.h             |   37 ++
>  include/linux/lsm_hooks.h              |    6
>  include/linux/mount.h                  |    2
>  security/security.c                    |    4
>  security/selinux/hooks.c               |    6
>  13 files changed, 1107 insertions(+), 150 deletions(-)
>  create mode 100644 fs/fs_context.c
>
> diff --git a/Documentation/filesystems/mounting.txt b/Documentation/filesystems/mounting.txt
> index 8c0b0351e949..ba73066c151c 100644
> --- a/Documentation/filesystems/mounting.txt
> +++ b/Documentation/filesystems/mounting.txt
> @@ -192,7 +192,7 @@ structure is not refcounted.
>
>  VFS, security and filesystem mount options are set individually with
>  vfs_parse_mount_option().  Options provided by the old mount(2) system call as
> -a page of data can be parsed with generic_monolithic_mount_data().
> +a page of data can be parsed with generic_parse_monolithic().
>
>  When mounting, the filesystem is allowed to take data from any of the pointers
>  and attach it to the superblock (or whatever), provided it clears the pointer
> @@ -264,7 +264,7 @@ manage the filesystem context.  They are as follows:
>
>       If the filesystem (eg. NFS) needs to examine the data first and then finds
>       it's the standard key-val list then it may pass it off to
> -     generic_monolithic_mount_data().
> +     generic_parse_monolithic().
>
>   (*) int (*validate)(struct fs_context *fc);
>
> @@ -407,9 +407,10 @@ returned.
>       [NOTE] ->validate() could perhaps be rolled into ->get_tree() and
>       ->remount_fs_fc().
>
> - (*) struct vfsmount *vfs_kern_mount_fc(struct fs_context *fc);
> + (*) struct vfsmount *vfs_create_mount(struct fs_context *fc);
>
>       Create a mount given the parameters in the specified filesystem context.
> +     Note that this does not attach the mount to anything.
>
>   (*) int vfs_set_fs_source(struct fs_context *fc, char *source);
>
> diff --git a/fs/Makefile b/fs/Makefile
> index 7bbaca9c67b1..ffe728cc15e1 100644
> --- a/fs/Makefile
> +++ b/fs/Makefile
> @@ -11,7 +11,8 @@ obj-y :=      open.o read_write.o file_table.o super.o \
>                 attr.o bad_inode.o file.o filesystems.o namespace.o \
>                 seq_file.o xattr.o libfs.o fs-writeback.o \
>                 pnode.o splice.o sync.o utimes.o \
> -               stack.o fs_struct.o statfs.o fs_pin.o nsfs.o
> +               stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
> +               fs_context.o
>
>  ifeq ($(CONFIG_BLOCK),y)
>  obj-y +=       buffer.o block_dev.o direct-io.o mpage.o
> diff --git a/fs/fs_context.c b/fs/fs_context.c
> new file mode 100644
> index 000000000000..a3a7ccb4323d
> --- /dev/null
> +++ b/fs/fs_context.c
> @@ -0,0 +1,526 @@
> +/* Provide a way to create a superblock configuration context within the kernel
> + * that allows a superblock to be set up prior to mounting.
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
> +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> +#include <linux/fs_context.h>
> +#include <linux/fs.h>
> +#include <linux/mount.h>
> +#include <linux/nsproxy.h>
> +#include <linux/slab.h>
> +#include <linux/magic.h>
> +#include <linux/security.h>
> +#include <linux/parser.h>
> +#include <linux/mnt_namespace.h>
> +#include <linux/pid_namespace.h>
> +#include <linux/user_namespace.h>
> +#include <net/net_namespace.h>
> +#include "mount.h"
> +
> +struct legacy_fs_context {
> +       struct fs_context       fc;
> +       char                    *legacy_data;   /* Data page for legacy filesystems */
> +       char                    *secdata;
> +       unsigned int            data_usage;
> +};
> +
> +static const struct fs_context_operations legacy_fs_context_ops;
> +
> +static const match_table_t common_set_sb_flag = {
> +       { SB_DIRSYNC,           "dirsync" },
> +       { SB_LAZYTIME,          "lazytime" },
> +       { SB_MANDLOCK,          "mand" },
> +       { SB_POSIXACL,          "posixacl" },
> +       { SB_RDONLY,            "ro" },
> +       { SB_SYNCHRONOUS,       "sync" },
> +       { },
> +};
> +
> +static const match_table_t common_clear_sb_flag = {
> +       { SB_LAZYTIME,          "nolazytime" },
> +       { SB_MANDLOCK,          "nomand" },
> +       { SB_RDONLY,            "rw" },
> +       { SB_SILENT,            "silent" },
> +       { SB_SYNCHRONOUS,       "async" },
> +       { },
> +};
> +
> +static const match_table_t forbidden_sb_flag = {
> +       { 0,    "bind" },
> +       { 0,    "move" },
> +       { 0,    "private" },
> +       { 0,    "remount" },
> +       { 0,    "shared" },
> +       { 0,    "slave" },
> +       { 0,    "unbindable" },
> +       { 0,    "rec" },
> +       { 0,    "noatime" },
> +       { 0,    "relatime" },
> +       { 0,    "norelatime" },
> +       { 0,    "strictatime" },
> +       { 0,    "nostrictatime" },
> +       { 0,    "nodiratime" },
> +       { 0,    "dev" },
> +       { 0,    "nodev" },
> +       { 0,    "exec" },
> +       { 0,    "noexec" },
> +       { 0,    "suid" },
> +       { 0,    "nosuid" },
> +       { },
> +};
> +
> +/*
> + * Check for a common mount option that manipulates s_flags.
> + */
> +static int vfs_parse_sb_flag_option(struct fs_context *fc, char *data)
> +{
> +       substring_t args[MAX_OPT_ARGS];
> +       unsigned int token;
> +
> +       token = match_token(data, common_set_sb_flag, args);
> +       if (token) {
> +               fc->sb_flags |= token;
> +               return 1;
> +       }
> +
> +       token = match_token(data, common_clear_sb_flag, args);
> +       if (token) {
> +               fc->sb_flags &= ~token;
> +               return 1;
> +       }
> +
> +       token = match_token(data, forbidden_sb_flag, args);
> +       if (token)
> +               return -EINVAL;
> +
> +       return 0;
> +}
> +
> +/**
> + * vfs_parse_mount_option - Add a single mount option to a superblock config

Mount options are those that refer to the mount
(nosuid,nodev,noatime,etc..); this function is not parsing those,
AFAICT.

How about vfs_parse_fs_option()?

> + * @fc: The filesystem context to modify
> + * @p: The option to apply.
> + *
> + * A single mount option in string form is applied to the filesystem context
> + * being set up.  Certain standard options (for example "ro") are translated
> + * into flag bits without going to the filesystem.  The active security module
> + * is allowed to observe and poach options.  Any other options are passed over
> + * to the filesystem to parse.
> + *
> + * This may be called multiple times for a context.
> + *
> + * Returns 0 on success and a negative error code on failure.  In the event of
> + * failure, supplementary error information may have been set.
> + */
> +int vfs_parse_mount_option(struct fs_context *fc, char *p)
> +{
> +       int ret;
> +
> +       ret = vfs_parse_sb_flag_option(fc, p);
> +       if (ret < 0)
> +               return ret;

We probably also need a "reset" type of option that clears all bits
and is also passed onto the filesystem's parsing routine so it can
reset all options as well.

The set/clear behavior should also be documented very clearly, because
I see lots of confusion regarding this, and it's something that legacy
option parsing cannot even handle consistently.

So what are the rules?

1/a) New sb:
    - start with zero sb_flags and set/clear specified ones
    - filesystems starts with default set of options and set/clear
specified ones

1/b) New sb for legacy mount(2)
    - same as 1/a.

2/a) Shared sb:
    - this is tricky, I think it would be correct to require a
matching config (sb_flags as well as filesystem options) and error out
in case of a mismatch.  But AFAICS this patchset doesn't have anything
related to this.

2/b) Shared sb for legacy mount(2)
    - same as 1/a and ignore if sb_flags don't match - except for "ro" error out
    - ignore any filesystem options (mount_bdev() does that, at least).

3/a) Reconfig
    - start with current sb_flags and set/clear specified ones, reset
to zero on reset
    - start wth current filesystem options and set/clear specified
ones, reset to default on reset

3/b) Reconfig for legacy mount(2) (i.e. MS_REMOUNT)
   - reset sb_flags to newly specified ones
   - most fs then go on to set/clear/modify specified ones from
current set of options, but there are probably exceptions.  And if
there are, then we are in trouble becuase we must convert those
filesystems up-front, before the new interface comes live, and handle
those exceptions in some way (e.g. FS_CONTEXT_LEGACY flag)


> +       if (ret == 1)
> +               return 0;
> +
> +       ret = security_fs_context_parse_option(fc, p);
> +       if (ret < 0)
> +               return ret;
> +       if (ret == 1)
> +               return 0;
> +
> +       if (fc->ops->parse_option)
> +               return fc->ops->parse_option(fc, p);
> +
> +       return -EINVAL;
> +}
> +EXPORT_SYMBOL(vfs_parse_mount_option);
> +
> +/**
> + * vfs_set_fs_source - Set the source/device name in a filesystem context
> + * @fc: The filesystem context to alter
> + * @source: The name of the source
> + * @slen: Length of @source string
> + */
> +int vfs_set_fs_source(struct fs_context *fc, const char *source, size_t slen)
> +{
> +       if (fc->source)
> +               return -EINVAL;
> +       if (source) {
> +               fc->source = kmemdup_nul(source, slen, GFP_KERNEL);
> +               if (!fc->source)
> +                       return -ENOMEM;
> +       }
> +
> +       if (fc->ops->parse_source)
> +               return fc->ops->parse_source(fc);
> +       return 0;
> +}
> +EXPORT_SYMBOL(vfs_set_fs_source);
> +
> +/**
> + * generic_parse_monolithic - Parse key[=val][,key[=val]]* mount data
> + * @mc: The superblock configuration to fill in.
> + * @data: The data to parse
> + *
> + * Parse a blob of data that's in key[=val][,key[=val]]* form.  This can be
> + * called from the ->monolithic_mount_data() fs_context operation.
> + *
> + * Returns 0 on success or the error returned by the ->parse_option() fs_context
> + * operation on failure.
> + */
> +int generic_parse_monolithic(struct fs_context *ctx, void *data)
> +{
> +       char *options = data, *p;
> +       int ret;
> +
> +       if (!options)
> +               return 0;
> +
> +       while ((p = strsep(&options, ",")) != NULL) {
> +               if (*p) {
> +                       ret = vfs_parse_mount_option(ctx, p);

Monolithic option block is the legacy thing.  It shouldn't be parsing
the common flags.  It should instead be treating them as forbidden
(although it probably doesn't really matter, since no filesystem will
accept these anyway).

So probably best to expand vfs_parse_mount_option() here and skip the
sb flag parsing part.

> +                       if (ret < 0)
> +                               return ret;
> +               }
> +       }
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(generic_parse_monolithic);
> +
> +/**
> + * vfs_new_fs_context - Create a filesystem context.
> + * @fs_type: The filesystem type.
> + * @src_sb: A superblock from which this one derives (or NULL)
> + * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)

I'm confused: MS_REMOUNT in sb_flags and FS_CONTEXT_FOR_REMOUNT in purpose?

I hope that's just a stale comment, sb_flags should really be just the
superblock flags and not any op flags.

Also, can FS_CONTEXT_FOR_REMOUNT be renamed to ..._RECONFIG?

> + * @purpose: The purpose that this configuration shall be used for.
> + *
> + * Open a filesystem and create a mount context.  The mount context is
> + * initialised with the supplied flags and, if a submount/automount from
> + * another superblock (@src_sb), may have parameters such as namespaces copied
> + * across from that superblock.
> + */
> +struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
> +                                     struct super_block *src_sb,
> +                                     unsigned int sb_flags,
> +                                     enum fs_context_purpose purpose)
> +{
> +       struct fs_context *fc;
> +       size_t fc_size = fs_type->fs_context_size;
> +       int ret;
> +
> +       BUG_ON(fs_type->init_fs_context && fc_size < sizeof(*fc));
> +
> +       if (!fs_type->init_fs_context)
> +               fc_size = sizeof(struct legacy_fs_context);
> +
> +       fc = kzalloc(fc_size, GFP_KERNEL);
> +       if (!fc)
> +               return ERR_PTR(-ENOMEM);
> +
> +       fc->purpose     = purpose;
> +       fc->sb_flags    = sb_flags;
> +       fc->fs_type     = get_filesystem(fs_type);
> +       fc->cred        = get_current_cred();
> +
> +       switch (purpose) {
> +       case FS_CONTEXT_FOR_KERNEL_MOUNT:
> +               fc->sb_flags |= SB_KERNMOUNT;
> +               /* Fallthrough */
> +       case FS_CONTEXT_FOR_USER_MOUNT:
> +               fc->user_ns = get_user_ns(fc->cred->user_ns);
> +               fc->net_ns = get_net(current->nsproxy->net_ns);
> +               break;
> +       case FS_CONTEXT_FOR_SUBMOUNT:
> +               fc->user_ns = get_user_ns(src_sb->s_user_ns);
> +               fc->net_ns = get_net(current->nsproxy->net_ns);
> +               break;
> +       case FS_CONTEXT_FOR_REMOUNT:
> +               /* We don't pin any namespaces as the superblock's
> +                * subscriptions cannot be changed at this point.
> +                */
> +               break;
> +       }
> +
> +
> +       /* TODO: Make all filesystems support this unconditionally */
> +       if (fc->fs_type->init_fs_context) {
> +               ret = fc->fs_type->init_fs_context(fc, src_sb);
> +               if (ret < 0)
> +                       goto err_fc;
> +       } else {
> +               fc->ops = &legacy_fs_context_ops;
> +       }
> +
> +       /* Do the security check last because ->init_fs_context may change the
> +        * namespace subscriptions.
> +        */
> +       ret = security_fs_context_alloc(fc, src_sb);
> +       if (ret < 0)
> +               goto err_fc;
> +
> +       return fc;
> +
> +err_fc:
> +       put_fs_context(fc);
> +       return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL(vfs_new_fs_context);
> +
> +/**
> + * vfs_sb_reconfig - Create a filesystem context for remount/reconfiguration
> + * @mnt: The mountpoint to open
> + * @sb_flags: Superblock flags and op flags (such as MS_REMOUNT)

Here again op flags make no sense.

Also it should be made clear that the old sb flags will be overridden
with these.  As such new code should probably be calling this with
current flags (sb->s_flags?) and let the option parsing override them
with new ones.

> + *
> + * Open a mounted filesystem and create a filesystem context such that a
> + * remount can be effected.
> + */
> +struct fs_context *vfs_sb_reconfig(struct vfsmount *mnt,
> +                                  unsigned int sb_flags)
> +{
> +       return vfs_new_fs_context(mnt->mnt_sb->s_type, mnt->mnt_sb,
> +                                 sb_flags, FS_CONTEXT_FOR_REMOUNT);
> +}
> +
> +/**
> + * vfs_dup_fc_config: Duplicate a filesytem context.
> + * @src_fc: The context to copy.
> + */

Can we introduce these before they actually get used.

> +struct fs_context *vfs_dup_fs_context(struct fs_context *src_fc)
> +{
> +       struct fs_context *fc;
> +       size_t fc_size;
> +       int ret;
> +
> +       if (!src_fc->ops->dup)
> +               return ERR_PTR(-ENOTSUPP);
> +
> +       fc_size = src_fc->fs_type->fs_context_size;
> +       if (!src_fc->fs_type->init_fs_context)
> +               fc_size = sizeof(struct legacy_fs_context);
> +
> +       fc = kmemdup(src_fc, src_fc->fs_type->fs_context_size, GFP_KERNEL);
> +       if (!fc)
> +               return ERR_PTR(-ENOMEM);
> +
> +       fc->source      = NULL;
> +       fc->security    = NULL;
> +       get_filesystem(fc->fs_type);
> +       get_net(fc->net_ns);
> +       get_user_ns(fc->user_ns);
> +       get_cred(fc->cred);
> +
> +       /* Can't call put until we've called ->dup */
> +       ret = fc->ops->dup(fc, src_fc);
> +       if (ret < 0)
> +               goto err_fc;
> +
> +       ret = security_fs_context_dup(fc, src_fc);
> +       if (ret < 0)
> +               goto err_fc;
> +       return fc;
> +
> +err_fc:
> +       put_fs_context(fc);
> +       return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL(vfs_dup_fs_context);
> +
> +/**
> + * put_fs_context - Dispose of a superblock configuration context.
> + * @sc: The context to dispose of.
> + */
> +void put_fs_context(struct fs_context *fc)
> +{
> +       struct super_block *sb;
> +
> +       if (fc->root) {
> +               sb = fc->root->d_sb;
> +               dput(fc->root);
> +               fc->root = NULL;
> +               deactivate_super(sb);
> +       }
> +
> +       if (fc->ops && fc->ops->free)
> +               fc->ops->free(fc);
> +
> +       security_fs_context_free(fc);
> +       if (fc->net_ns)
> +               put_net(fc->net_ns);
> +       put_user_ns(fc->user_ns);
> +       if (fc->cred)
> +               put_cred(fc->cred);
> +       kfree(fc->subtype);
> +       put_filesystem(fc->fs_type);
> +       kfree(fc->source);
> +       kfree(fc);
> +}
> +EXPORT_SYMBOL(put_fs_context);
> +
> +/*
> + * Free the config for a filesystem that doesn't support fs_context.
> + */
> +static void legacy_fs_context_free(struct fs_context *fc)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +
> +       free_secdata(ctx->secdata);
> +       kfree(ctx->legacy_data);
> +}
> +
> +/*
> + * Duplicate a legacy config.
> + */
> +static int legacy_fs_context_dup(struct fs_context *fc, struct fs_context *src_fc)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +       struct legacy_fs_context *src_ctx = container_of(src_fc, struct legacy_fs_context, fc);
> +
> +       ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +       if (!ctx->legacy_data)
> +               return -ENOMEM;
> +       memcpy(ctx->legacy_data, src_ctx->legacy_data, sizeof(PAGE_SIZE));
> +       return 0;
> +}
> +
> +/*
> + * Add an option to a legacy config.  We build up a comma-separated list of
> + * options.
> + */
> +static int legacy_parse_option(struct fs_context *fc, char *p)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +       unsigned int usage = ctx->data_usage;
> +       size_t len = strlen(p);
> +
> +       if (len > PAGE_SIZE - 2 - usage)
> +               return -EINVAL;
> +       if (memchr(p, ',', len) != NULL)
> +               return -EINVAL;
> +       if (!ctx->legacy_data) {
> +               ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +               if (!ctx->legacy_data)
> +                       return -ENOMEM;
> +       }
> +
> +       ctx->legacy_data[usage++] = ',';
> +       memcpy(ctx->legacy_data + usage, p, len);
> +       usage += len;
> +       ctx->legacy_data[usage] = '\0';
> +       ctx->data_usage = usage;
> +       return 0;
> +}
> +
> +/*
> + * Add monolithic mount data.
> + */
> +static int legacy_parse_monolithic(struct fs_context *fc, void *data)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +
> +       if (ctx->data_usage != 0) {
> +               pr_warn("VFS: Can't mix monolithic and individual options\n");
> +               return -EINVAL;
> +       }
> +       if (!data)
> +               return 0;
> +       if (!ctx->legacy_data) {
> +               ctx->legacy_data = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +               if (!ctx->legacy_data)
> +                       return -ENOMEM;
> +       }
> +
> +       memcpy(ctx->legacy_data, data, PAGE_SIZE);
> +       ctx->data_usage = PAGE_SIZE;
> +       return 0;
> +}
> +
> +/*
> + * Use the legacy mount validation step to strip out and process security
> + * config options.
> + */
> +static int legacy_validate(struct fs_context *fc)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +
> +       if (!ctx->legacy_data || ctx->fc.fs_type->fs_flags & FS_BINARY_MOUNTDATA)
> +               return 0;
> +
> +       ctx->secdata = alloc_secdata();
> +       if (!ctx->secdata)
> +               return -ENOMEM;
> +
> +       return security_sb_copy_data(ctx->legacy_data, ctx->secdata);
> +}
> +
> +/*
> + * Determine the superblock subtype.
> + */
> +static int legacy_set_subtype(struct fs_context *fc)
> +{
> +       const char *subtype = strchr(fc->fs_type->name, '.');
> +
> +       if (subtype) {
> +               subtype++;
> +               if (!subtype[0])
> +                       return -EINVAL;
> +       } else {
> +               subtype = "";
> +       }
> +
> +       fc->subtype = kstrdup(subtype, GFP_KERNEL);
> +       if (!fc->subtype)
> +               return -ENOMEM;
> +       return 0;
> +}
> +
> +/*
> + * Get a mountable root with the legacy mount command.
> + */
> +static int legacy_get_tree(struct fs_context *fc)
> +{
> +       struct legacy_fs_context *ctx = container_of(fc, struct legacy_fs_context, fc);
> +       struct super_block *sb;
> +       struct dentry *root;
> +       int ret;
> +
> +       root = ctx->fc.fs_type->mount(ctx->fc.fs_type, ctx->fc.sb_flags,
> +                                     ctx->fc.source, ctx->legacy_data);
> +       if (IS_ERR(root))
> +               return PTR_ERR(root);
> +
> +       sb = root->d_sb;
> +       BUG_ON(!sb);
> +
> +       if ((ctx->fc.fs_type->fs_flags & FS_HAS_SUBTYPE) &&
> +           !fc->subtype) {
> +               ret = legacy_set_subtype(fc);
> +               if (ret < 0)
> +                       goto err_sb;
> +       }
> +
> +       ctx->fc.root = root;
> +       return 0;
> +
> +err_sb:
> +       dput(root);
> +       deactivate_locked_super(sb);
> +       return ret;
> +}
> +
> +static const struct fs_context_operations legacy_fs_context_ops = {
> +       .free                   = legacy_fs_context_free,
> +       .dup                    = legacy_fs_context_dup,
> +       .parse_option           = legacy_parse_option,
> +       .parse_monolithic       = legacy_parse_monolithic,
> +       .validate               = legacy_validate,
> +       .get_tree               = legacy_get_tree,
> +};
> diff --git a/fs/internal.h b/fs/internal.h
> index 48cee21b4f14..e7fb460e7ca4 100644
> --- a/fs/internal.h
> +++ b/fs/internal.h
> @@ -89,7 +89,7 @@ extern struct file *get_empty_filp(void);
>  /*
>   * super.c
>   */
> -extern int do_remount_sb(struct super_block *, int, void *, int);
> +extern int do_remount_sb(struct super_block *, int, void *, int, struct fs_context *);
>  extern bool trylock_super(struct super_block *sb);
>  extern struct dentry *mount_fs(struct file_system_type *,
>                                int, const char *, void *);
> diff --git a/fs/libfs.c b/fs/libfs.c
> index 7ff3cb904acd..756e552709fa 100644
> --- a/fs/libfs.c
> +++ b/fs/libfs.c
> @@ -9,6 +9,7 @@
>  #include <linux/slab.h>
>  #include <linux/cred.h>
>  #include <linux/mount.h>
> +#include <linux/fs_context.h>
>  #include <linux/vfs.h>
>  #include <linux/quotaops.h>
>  #include <linux/mutex.h>
> @@ -574,13 +575,27 @@ static DEFINE_SPINLOCK(pin_fs_lock);
>
>  int simple_pin_fs(struct file_system_type *type, struct vfsmount **mount, int *count)
>  {
> +       struct fs_context *fc;
>         struct vfsmount *mnt = NULL;
> +       int ret;
> +
>         spin_lock(&pin_fs_lock);
>         if (unlikely(!*mount)) {
>                 spin_unlock(&pin_fs_lock);
> -               mnt = vfs_kern_mount(type, SB_KERNMOUNT, type->name, NULL);
> +
> +               fc = vfs_new_fs_context(type, NULL, 0, FS_CONTEXT_FOR_KERNEL_MOUNT);
> +               if (IS_ERR(fc))
> +                       return PTR_ERR(fc);
> +
> +               ret = vfs_get_tree(fc);
> +               if (ret < 0)
> +                       return ret;
> +
> +               mnt = vfs_create_mount(fc);
> +               put_fs_context(fc);
>                 if (IS_ERR(mnt))
>                         return PTR_ERR(mnt);
> +
>                 spin_lock(&pin_fs_lock);
>                 if (!*mount)
>                         *mount = mnt;
> diff --git a/fs/namespace.c b/fs/namespace.c
> index a6508e4c0a90..d6b0b0067f6d 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -25,8 +25,10 @@
>  #include <linux/magic.h>
>  #include <linux/bootmem.h>
>  #include <linux/task_work.h>
> +#include <linux/file.h>
>  #include <linux/sched/task.h>
>  #include <uapi/linux/mount.h>
> +#include <linux/fs_context.h>
>
>  #include "pnode.h"
>  #include "internal.h"
> @@ -1017,55 +1019,6 @@ static struct mount *skip_mnt_tree(struct mount *p)
>         return p;
>  }
>
> -struct vfsmount *
> -vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void *data)
> -{
> -       struct mount *mnt;
> -       struct dentry *root;
> -
> -       if (!type)
> -               return ERR_PTR(-ENODEV);
> -
> -       mnt = alloc_vfsmnt(name);
> -       if (!mnt)
> -               return ERR_PTR(-ENOMEM);
> -
> -       if (flags & SB_KERNMOUNT)
> -               mnt->mnt.mnt_flags = MNT_INTERNAL;
> -
> -       root = mount_fs(type, flags, name, data);
> -       if (IS_ERR(root)) {
> -               mnt_free_id(mnt);
> -               free_vfsmnt(mnt);
> -               return ERR_CAST(root);
> -       }
> -
> -       mnt->mnt.mnt_root = root;
> -       mnt->mnt.mnt_sb = root->d_sb;
> -       mnt->mnt_mountpoint = mnt->mnt.mnt_root;
> -       mnt->mnt_parent = mnt;
> -       lock_mount_hash();
> -       list_add_tail(&mnt->mnt_instance, &root->d_sb->s_mounts);
> -       unlock_mount_hash();
> -       return &mnt->mnt;
> -}
> -EXPORT_SYMBOL_GPL(vfs_kern_mount);
> -
> -struct vfsmount *
> -vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
> -            const char *name, void *data)
> -{
> -       /* Until it is worked out how to pass the user namespace
> -        * through from the parent mount to the submount don't support
> -        * unprivileged mounts with submounts.
> -        */
> -       if (mountpoint->d_sb->s_user_ns != &init_user_ns)
> -               return ERR_PTR(-EPERM);
> -
> -       return vfs_kern_mount(type, SB_SUBMOUNT, name, data);
> -}
> -EXPORT_SYMBOL_GPL(vfs_submount);
> -
>  static struct mount *clone_mnt(struct mount *old, struct dentry *root,
>                                         int flag)
>  {
> @@ -1592,7 +1545,7 @@ static int do_umount(struct mount *mnt, int flags)
>                         return -EPERM;
>                 down_write(&sb->s_umount);
>                 if (!sb_rdonly(sb))
> -                       retval = do_remount_sb(sb, SB_RDONLY, NULL, 0);
> +                       retval = do_remount_sb(sb, SB_RDONLY, NULL, 0, NULL);
>                 up_write(&sb->s_umount);
>                 return retval;
>         }
> @@ -2275,6 +2228,20 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
>  }
>
>  /*
> + * Parse the monolithic page of mount data given to sys_mount().
> + */
> +static int parse_monolithic_mount_data(struct fs_context *fc, void *data)
> +{
> +       int (*monolithic_mount_data)(struct fs_context *, void *);
> +
> +       monolithic_mount_data = fc->ops->parse_monolithic;
> +       if (!monolithic_mount_data)
> +               monolithic_mount_data = generic_parse_monolithic;
> +
> +       return monolithic_mount_data(fc, data);
> +}
> +
> +/*
>   * change filesystem flags. dir should be a physical root of filesystem.
>   * If you've mounted a non-root directory somewhere and want to do remount
>   * on it - tough luck.
> @@ -2282,9 +2249,11 @@ static int change_mount_flags(struct vfsmount *mnt, int ms_flags)
>  static int do_remount(struct path *path, int ms_flags, int sb_flags,
>                       int mnt_flags, void *data)
>  {
> +       struct fs_context *fc = NULL;
>         int err;
>         struct super_block *sb = path->mnt->mnt_sb;
>         struct mount *mnt = real_mount(path->mnt);
> +       struct file_system_type *type = sb->s_type;
>
>         if (!check_mnt(mnt))
>                 return -EINVAL;
> @@ -2319,9 +2288,25 @@ static int do_remount(struct path *path, int ms_flags, int sb_flags,
>                 return -EPERM;
>         }
>
> -       err = security_sb_remount(sb, data);
> -       if (err)
> -               return err;
> +       if (type->init_fs_context) {
> +               fc = vfs_sb_reconfig(path->mnt, sb_flags);
> +               if (IS_ERR(fc))
> +                       return PTR_ERR(fc);
> +
> +               err = parse_monolithic_mount_data(fc, data);
> +               if (err < 0)
> +                       goto err_fc;
> +
> +               if (fc->ops->validate) {
> +                       err = fc->ops->validate(fc);
> +                       if (err < 0)
> +                               goto err_fc;
> +               }
> +       } else {
> +               err = security_sb_remount(sb, data);
> +               if (err)
> +                       return err;
> +       }
>
>         down_write(&sb->s_umount);
>         if (ms_flags & MS_BIND)
> @@ -2329,7 +2314,7 @@ static int do_remount(struct path *path, int ms_flags, int sb_flags,
>         else if (!capable(CAP_SYS_ADMIN))
>                 err = -EPERM;
>         else
> -               err = do_remount_sb(sb, sb_flags, data, 0);
> +               err = do_remount_sb(sb, sb_flags, data, 0, fc);
>         if (!err) {
>                 lock_mount_hash();
>                 mnt_flags |= mnt->mnt.mnt_flags & ~MNT_USER_SETTABLE_MASK;
> @@ -2338,6 +2323,9 @@ static int do_remount(struct path *path, int ms_flags, int sb_flags,
>                 unlock_mount_hash();
>         }
>         up_write(&sb->s_umount);
> +err_fc:
> +       if (fc)
> +               put_fs_context(fc);
>         return err;
>  }
>
> @@ -2421,29 +2409,6 @@ static int do_move_mount(struct path *path, const char *old_name)
>         return err;
>  }
>
> -static struct vfsmount *fs_set_subtype(struct vfsmount *mnt, const char *fstype)
> -{
> -       int err;
> -       const char *subtype = strchr(fstype, '.');
> -       if (subtype) {
> -               subtype++;
> -               err = -EINVAL;
> -               if (!subtype[0])
> -                       goto err;
> -       } else
> -               subtype = "";
> -
> -       mnt->mnt_sb->s_subtype = kstrdup(subtype, GFP_KERNEL);
> -       err = -ENOMEM;
> -       if (!mnt->mnt_sb->s_subtype)
> -               goto err;
> -       return mnt;
> -
> - err:
> -       mntput(mnt);
> -       return ERR_PTR(err);
> -}
> -
>  /*
>   * add a mount into a namespace's mount tree
>   */
> @@ -2491,40 +2456,89 @@ static int do_add_mount(struct mount *newmnt, struct path *path, int mnt_flags)
>  static bool mount_too_revealing(struct vfsmount *mnt, int *new_mnt_flags);
>
>  /*
> - * create a new mount for userspace and request it to be added into the
> - * namespace's tree
> + * Create a new mount using a superblock configuration and request it
> + * be added to the namespace tree.
>   */
> -static int do_new_mount(struct path *path, const char *fstype, int sb_flags,
> -                       int mnt_flags, const char *name, void *data)
> +static int do_new_mount_fc(struct fs_context *fc, struct path *mountpoint,
> +                          unsigned int mnt_flags)
>  {
> -       struct file_system_type *type;
>         struct vfsmount *mnt;
> -       int err;
> -
> -       if (!fstype)
> -               return -EINVAL;
> -
> -       type = get_fs_type(fstype);
> -       if (!type)
> -               return -ENODEV;
> +       int ret;
>
> -       mnt = vfs_kern_mount(type, sb_flags, name, data);
> -       if (!IS_ERR(mnt) && (type->fs_flags & FS_HAS_SUBTYPE) &&
> -           !mnt->mnt_sb->s_subtype)
> -               mnt = fs_set_subtype(mnt, fstype);
> +       ret = security_sb_mountpoint(fc, mountpoint);
> +       if (ret < 0)
> +               return ret;;
>
> -       put_filesystem(type);
> +       mnt = vfs_create_mount(fc);
>         if (IS_ERR(mnt))
>                 return PTR_ERR(mnt);
>
> +       ret = -EPERM;
>         if (mount_too_revealing(mnt, &mnt_flags)) {
> -               mntput(mnt);
> -               return -EPERM;
> +               pr_warn("VFS: Mount too revealing\n");
> +               goto err_mnt;
> +       }
> +
> +       ret = do_add_mount(real_mount(mnt), mountpoint, mnt_flags);
> +       if (ret < 0)
> +               goto err_mnt;
> +       return ret;
> +
> +err_mnt:
> +       mntput(mnt);
> +       return ret;
> +}
> +
> +/*
> + * create a new mount for userspace and request it to be added into the
> + * namespace's tree
> + */
> +static int do_new_mount(struct path *mountpoint, const char *fstype,
> +                       int sb_flags, int mnt_flags, const char *name,
> +                       void *data)
> +{
> +       struct file_system_type *fs_type;
> +       struct fs_context *fc;
> +       int err = -EINVAL;
> +
> +       if (!fstype)
> +               goto err;
> +
> +       err = -ENODEV;
> +       fs_type = get_fs_type(fstype);
> +       if (!fs_type)
> +               goto err;
> +
> +       fc = vfs_new_fs_context(fs_type, NULL, sb_flags,
> +                               FS_CONTEXT_FOR_USER_MOUNT);
> +       put_filesystem(fs_type);
> +       if (IS_ERR(fc)) {
> +               err = PTR_ERR(fc);
> +               goto err;
>         }
>
> -       err = do_add_mount(real_mount(mnt), path, mnt_flags);
> +       err = vfs_set_fs_source(fc, name, name ? strlen(name) : 0);
> +       if (err < 0)
> +               goto err_fc;
> +
> +       err = parse_monolithic_mount_data(fc, data);
> +       if (err < 0)
> +               goto err_fc;
> +
> +       err = vfs_get_tree(fc);
> +       if (err < 0)
> +               goto err_fc;
> +
> +       err = do_new_mount_fc(fc, mountpoint, mnt_flags);
>         if (err)
> -               mntput(mnt);
> +               goto err_fc;
> +
> +       put_fs_context(fc);
> +       return 0;
> +
> +err_fc:
> +       put_fs_context(fc);
> +err:
>         return err;
>  }
>
> @@ -3063,6 +3077,116 @@ SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
>         return ret;
>  }
>
> +/**
> + * vfs_create_mount - Create a mount for a configured superblock
> + * fc: The configuration context with the superblock attached
> + *
> + * Create a mount to an already configured superblock.  If necessary, the
> + * caller should invoke vfs_get_tree() before calling this.
> + *
> + * Note that this does not attach the mount to anything.
> + */
> +struct vfsmount *vfs_create_mount(struct fs_context *fc)
> +{
> +       struct mount *mnt;
> +
> +       if (!fc->root)
> +               return ERR_PTR(-EINVAL);
> +
> +       mnt = alloc_vfsmnt(fc->source ?: "none");
> +       if (!mnt)
> +               return ERR_PTR(-ENOMEM);
> +
> +       if (fc->purpose == FS_CONTEXT_FOR_KERNEL_MOUNT)
> +               /* It's a longterm mount, don't release mnt until we unmount
> +                * before file sys is unregistered
> +                */
> +               mnt->mnt.mnt_flags = MNT_INTERNAL;
> +
> +       atomic_inc(&fc->root->d_sb->s_active);
> +       mnt->mnt.mnt_sb         = fc->root->d_sb;
> +       mnt->mnt.mnt_root       = dget(fc->root);
> +       mnt->mnt_mountpoint     = mnt->mnt.mnt_root;
> +       mnt->mnt_parent         = mnt;
> +
> +       lock_mount_hash();
> +       list_add_tail(&mnt->mnt_instance, &mnt->mnt.mnt_sb->s_mounts);
> +       unlock_mount_hash();
> +       return &mnt->mnt;
> +}
> +EXPORT_SYMBOL(vfs_create_mount);
> +
> +struct vfsmount *vfs_kern_mount(struct file_system_type *type,
> +                               int sb_flags, const char *devname, void *data)
> +{
> +       struct fs_context *fc;
> +       struct vfsmount *mnt;
> +       int ret;
> +
> +       if (!type)
> +               return ERR_PTR(-EINVAL);
> +
> +       fc = vfs_new_fs_context(type, NULL, sb_flags,
> +                               sb_flags & SB_KERNMOUNT ?
> +                               FS_CONTEXT_FOR_KERNEL_MOUNT :
> +                               FS_CONTEXT_FOR_USER_MOUNT);
> +       if (IS_ERR(fc))
> +               return ERR_CAST(fc);
> +
> +       ret = vfs_set_fs_source(fc, devname, devname ? strlen(devname) : 0);
> +       if (ret < 0)
> +               goto err_fc;
> +
> +       ret = parse_monolithic_mount_data(fc, data);
> +       if (ret < 0)
> +               goto err_fc;
> +
> +       ret = vfs_get_tree(fc);
> +       if (ret < 0)
> +               goto err_fc;
> +
> +       mnt = vfs_create_mount(fc);
> +       if (IS_ERR(mnt)) {
> +               ret = PTR_ERR(mnt);
> +               goto err_fc;
> +       }
> +
> +       put_fs_context(fc);
> +       return mnt;
> +
> +err_fc:
> +       put_fs_context(fc);
> +       return ERR_PTR(ret);
> +}
> +EXPORT_SYMBOL_GPL(vfs_kern_mount);
> +
> +struct vfsmount *
> +vfs_submount(const struct dentry *mountpoint, struct file_system_type *type,
> +            const char *name, void *data)
> +{
> +       /* Until it is worked out how to pass the user namespace
> +        * through from the parent mount to the submount don't support
> +        * unprivileged mounts with submounts.
> +        */
> +       if (mountpoint->d_sb->s_user_ns != &init_user_ns)
> +               return ERR_PTR(-EPERM);
> +
> +       return vfs_kern_mount(type, MS_SUBMOUNT, name, data);
> +}
> +EXPORT_SYMBOL_GPL(vfs_submount);
> +
> +struct vfsmount *kern_mount(struct file_system_type *type)
> +{
> +       return vfs_kern_mount(type, SB_KERNMOUNT, type->name, NULL);
> +}
> +EXPORT_SYMBOL_GPL(kern_mount);
> +
> +struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
> +{
> +       return vfs_kern_mount(type, SB_KERNMOUNT, type->name, data);
> +}
> +EXPORT_SYMBOL_GPL(kern_mount_data);
> +
>  /*
>   * Return true if path is reachable from root
>   *
> @@ -3283,21 +3407,6 @@ void put_mnt_ns(struct mnt_namespace *ns)
>         free_mnt_ns(ns);
>  }
>
> -struct vfsmount *kern_mount_data(struct file_system_type *type, void *data)
> -{
> -       struct vfsmount *mnt;
> -       mnt = vfs_kern_mount(type, SB_KERNMOUNT, type->name, data);
> -       if (!IS_ERR(mnt)) {
> -               /*
> -                * it is a longterm mount, don't release mnt until
> -                * we unmount before file sys is unregistered
> -               */
> -               real_mount(mnt)->mnt_ns = MNT_NS_INTERNAL;
> -       }
> -       return mnt;
> -}
> -EXPORT_SYMBOL_GPL(kern_mount_data);
> -
>  void kern_unmount(struct vfsmount *mnt)
>  {
>         /* release long term mount so mount point can be released */
> diff --git a/fs/super.c b/fs/super.c
> index 02da00410de8..e7d411d1d435 100644
> --- a/fs/super.c
> +++ b/fs/super.c
> @@ -35,6 +35,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/user_namespace.h>
>  #include <uapi/linux/mount.h>
> +#include <linux/fs_context.h>
>  #include "internal.h"
>
>
> @@ -173,16 +174,13 @@ static void destroy_super(struct super_block *s)
>  }
>
>  /**
> - *     alloc_super     -       create new superblock
> - *     @type:  filesystem type superblock should belong to
> - *     @flags: the mount flags
> - *     @user_ns: User namespace for the super_block
> + *     alloc_super - Create new superblock
> + *     @fc: The filesystem configuration context
>   *
>   *     Allocates and initializes a new &struct super_block.  alloc_super()
>   *     returns a pointer new superblock or %NULL if allocation had failed.
>   */
> -static struct super_block *alloc_super(struct file_system_type *type, int flags,
> -                                      struct user_namespace *user_ns)
> +static struct super_block *alloc_super(struct fs_context *fc)
>  {
>         struct super_block *s = kzalloc(sizeof(struct super_block),  GFP_USER);
>         static const struct super_operations default_op;
> @@ -192,7 +190,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>                 return NULL;
>
>         INIT_LIST_HEAD(&s->s_mounts);
> -       s->s_user_ns = get_user_ns(user_ns);
> +       s->s_user_ns = get_user_ns(fc->user_ns);
>
>         if (security_sb_alloc(s))
>                 goto fail;
> @@ -200,12 +198,12 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>         for (i = 0; i < SB_FREEZE_LEVELS; i++) {
>                 if (__percpu_init_rwsem(&s->s_writers.rw_sem[i],
>                                         sb_writers_name[i],
> -                                       &type->s_writers_key[i]))
> +                                       &fc->fs_type->s_writers_key[i]))
>                         goto fail;
>         }
>         init_waitqueue_head(&s->s_writers.wait_unfrozen);
>         s->s_bdi = &noop_backing_dev_info;
> -       s->s_flags = flags;
> +       s->s_flags = fc->sb_flags;
>         if (s->s_user_ns != &init_user_ns)
>                 s->s_iflags |= SB_I_NODEV;
>         INIT_HLIST_NODE(&s->s_instances);
> @@ -222,7 +220,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>                 goto fail;
>
>         init_rwsem(&s->s_umount);
> -       lockdep_set_class(&s->s_umount, &type->s_umount_key);
> +       lockdep_set_class(&s->s_umount, &fc->fs_type->s_umount_key);
>         /*
>          * sget() can have s_umount recursion.
>          *
> @@ -242,7 +240,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
>         s->s_count = 1;
>         atomic_set(&s->s_active, 1);
>         mutex_init(&s->s_vfs_rename_mutex);
> -       lockdep_set_class(&s->s_vfs_rename_mutex, &type->s_vfs_rename_key);
> +       lockdep_set_class(&s->s_vfs_rename_mutex, &fc->fs_type->s_vfs_rename_key);
>         init_rwsem(&s->s_dquot.dqio_sem);
>         s->s_maxbytes = MAX_NON_LFS;
>         s->s_op = &default_op;
> @@ -455,6 +453,96 @@ void generic_shutdown_super(struct super_block *sb)
>  EXPORT_SYMBOL(generic_shutdown_super);
>
>  /**
> + * sget_fc - Find or create a superblock
> + * @fc:        Filesystem context.
> + * @test: Comparison callback
> + * @set: Setup callback
> + *
> + * Find or create a superblock using the parameters stored in the filesystem
> + * context and the two callback functions.
> + *
> + * If an extant superblock is matched, then that will be returned with an
> + * elevated reference count that the caller must transfer or discard.
> + *
> + * If no match is made, a new superblock will be allocated and basic
> + * initialisation will be performed (s_type, s_fs_info and s_id will be set and
> + * the set() callback will be invoked), the superblock will be published and it
> + * will be returned in a partially constructed state with SB_BORN and SB_ACTIVE
> + * as yet unset.
> + */
> +struct super_block *sget_fc(struct fs_context *fc,
> +                           int (*test)(struct super_block *, struct fs_context *),
> +                           int (*set)(struct super_block *, struct fs_context *))
> +{
> +       struct super_block *s = NULL;
> +       struct super_block *old;
> +       int err;
> +
> +       if (!(fc->sb_flags & SB_KERNMOUNT) &&
> +           fc->purpose != FS_CONTEXT_FOR_SUBMOUNT) {
> +               /* Don't allow mounting unless the caller has CAP_SYS_ADMIN
> +                * over the namespace.
> +                */
> +               if (!(fc->fs_type->fs_flags & FS_USERNS_MOUNT) &&
> +                   !capable(CAP_SYS_ADMIN))
> +                       return ERR_PTR(-EPERM);
> +               else if (!ns_capable(fc->user_ns, CAP_SYS_ADMIN))
> +                       return ERR_PTR(-EPERM);
> +       }
> +
> +retry:
> +       spin_lock(&sb_lock);
> +       if (test) {
> +               hlist_for_each_entry(old, &fc->fs_type->fs_supers, s_instances) {
> +                       if (!test(old, fc))
> +                               continue;
> +                       if (fc->user_ns != old->s_user_ns) {
> +                               spin_unlock(&sb_lock);
> +                               if (s) {
> +                                       up_write(&s->s_umount);
> +                                       destroy_super(s);
> +                               }
> +                               return ERR_PTR(-EBUSY);
> +                       }
> +                       if (!grab_super(old))
> +                               goto retry;
> +                       if (s) {
> +                               up_write(&s->s_umount);
> +                               destroy_super(s);
> +                               s = NULL;
> +                       }
> +                       return old;
> +               }
> +       }
> +       if (!s) {
> +               spin_unlock(&sb_lock);
> +               s = alloc_super(fc);
> +               if (!s)
> +                       return ERR_PTR(-ENOMEM);
> +               goto retry;
> +       }
> +
> +       s->s_fs_info = fc->s_fs_info;
> +       err = set(s, fc);
> +       if (err) {
> +               s->s_fs_info = NULL;
> +               spin_unlock(&sb_lock);
> +               up_write(&s->s_umount);
> +               destroy_super(s);
> +               return ERR_PTR(err);
> +       }
> +       s->s_type = fc->fs_type;
> +       strlcpy(s->s_id, s->s_type->name, sizeof(s->s_id));
> +       list_add_tail(&s->s_list, &super_blocks);
> +       hlist_add_head(&s->s_instances, &s->s_type->fs_supers);
> +       spin_unlock(&sb_lock);
> +       get_filesystem(s->s_type);
> +       register_shrinker(&s->s_shrink);
> +       return s;
> +}
> +EXPORT_SYMBOL(sget_fc);
> +
> +/**
>   *     sget_userns -   find or create a superblock
>   *     @type:  filesystem type superblock should belong to
>   *     @test:  comparison callback
> @@ -503,7 +591,14 @@ struct super_block *sget_userns(struct file_system_type *type,
>         }
>         if (!s) {
>                 spin_unlock(&sb_lock);
> -               s = alloc_super(type, (flags & ~SB_SUBMOUNT), user_ns);
> +               {
> +                       struct fs_context fc = {
> +                               .fs_type        = type,
> +                               .sb_flags       = flags & ~SB_SUBMOUNT,
> +                               .user_ns        = user_ns,
> +                       };
> +                       s = alloc_super(&fc);
> +               }
>                 if (!s)
>                         return ERR_PTR(-ENOMEM);
>                 goto retry;
> @@ -805,10 +900,13 @@ struct super_block *user_get_super(dev_t dev)
>   *     @sb_flags: revised superblock flags
>   *     @data:  the rest of options
>   *      @force: whether or not to force the change
> + *     @fc:    the superblock config for filesystems that support it
> + *             (NULL if called from emergency or umount)
>   *
>   *     Alters the mount options of a mounted file system.
>   */
> -int do_remount_sb(struct super_block *sb, int sb_flags, void *data, int force)
> +int do_remount_sb(struct super_block *sb, int sb_flags, void *data, int force,
> +                 struct fs_context *fc)
>  {
>         int retval;
>         int remount_ro;
> @@ -850,8 +948,14 @@ int do_remount_sb(struct super_block *sb, int sb_flags, void *data, int force)
>                 }
>         }
>
> -       if (sb->s_op->remount_fs) {
> -               retval = sb->s_op->remount_fs(sb, &sb_flags, data);
> +       if (sb->s_op->remount_fs_fc ||
> +           sb->s_op->remount_fs) {
> +               if (sb->s_op->remount_fs_fc) {
> +                   retval = sb->s_op->remount_fs_fc(sb, fc);
> +                   sb_flags = fc->sb_flags;
> +               } else {
> +                       retval = sb->s_op->remount_fs(sb, &sb_flags, data);
> +               }
>                 if (retval) {
>                         if (!force)
>                                 goto cancel_readonly;
> @@ -898,7 +1002,7 @@ static void do_emergency_remount(struct work_struct *work)
>                         /*
>                          * What lock protects sb->s_flags??
>                          */
> -                       do_remount_sb(sb, SB_RDONLY, NULL, 1);
> +                       do_remount_sb(sb, SB_RDONLY, NULL, 1, NULL);
>                 }
>                 up_write(&sb->s_umount);
>                 spin_lock(&sb_lock);
> @@ -1048,6 +1152,89 @@ struct dentry *mount_ns(struct file_system_type *fs_type,
>
>  EXPORT_SYMBOL(mount_ns);
>
> +static int set_anon_super_fc(struct super_block *sb, struct fs_context *fc)
> +{
> +       return set_anon_super(sb, NULL);
> +}
> +
> +static int test_keyed_super(struct super_block *sb, struct fs_context *fc)
> +{
> +       return sb->s_fs_info == fc->s_fs_info;
> +}
> +
> +static int test_single_super(struct super_block *s, struct fs_context *fc)
> +{
> +       return 1;
> +}
> +
> +/**
> + * vfs_get_super - Get a superblock with a search key set in s_fs_info.
> + * @fc: The filesystem context holding the parameters
> + * @keying: How to distinguish superblocks
> + * @fill_super: Helper to initialise a new superblock
> + *
> + * Search for a superblock and create a new one if not found.  The search
> + * criterion is controlled by @keying.  If the search fails, a new superblock
> + * is created and @fill_super() is called to initialise it.
> + *
> + * @keying can take one of a number of values:
> + *
> + * (1) vfs_get_single_super - Only one superblock of this type may exist on the
> + *     system.  This is typically used for special system filesystems.
> + *
> + * (2) vfs_get_keyed_super - Multiple superblocks may exist, but they must have
> + *     distinct keys (where the key is in s_fs_info).  Searching for the same
> + *     key again will turn up the superblock for that key.
> + *
> + * (3) vfs_get_independent_super - Multiple superblocks may exist and are
> + *     unkeyed.  Each call will get a new superblock.
> + *
> + * A permissions check is made by sget_fc() unless we're getting a superblock
> + * for a kernel-internal mount or a submount.
> + */
> +int vfs_get_super(struct fs_context *fc,
> +                 enum vfs_get_super_keying keying,
> +                 int (*fill_super)(struct super_block *sb,
> +                                   struct fs_context *fc))
> +{
> +       int (*test)(struct super_block *, struct fs_context *);
> +       struct super_block *sb;
> +
> +       switch (keying) {
> +       case vfs_get_single_super:
> +               test = test_single_super;
> +               break;
> +       case vfs_get_keyed_super:
> +               test = test_keyed_super;
> +               break;
> +       case vfs_get_independent_super:
> +               test = NULL;
> +               break;
> +       default:
> +               BUG();
> +       }
> +
> +       sb = sget_fc(fc, test, set_anon_super_fc);
> +       if (IS_ERR(sb))
> +               return PTR_ERR(sb);
> +
> +       if (!sb->s_root) {
> +               int err;
> +               err = fill_super(sb, fc);
> +               if (err) {
> +                       deactivate_locked_super(sb);
> +                       return err;
> +               }
> +
> +               sb->s_flags |= SB_ACTIVE;
> +       }
> +
> +       if (!fc->root)
> +               fc->root = dget(sb->s_root);
> +       return 0;
> +}
> +EXPORT_SYMBOL(vfs_get_super);
> +
>  #ifdef CONFIG_BLOCK
>  static int set_bdev_super(struct super_block *s, void *data)
>  {
> @@ -1196,7 +1383,7 @@ struct dentry *mount_single(struct file_system_type *fs_type,
>                 }
>                 s->s_flags |= SB_ACTIVE;
>         } else {
> -               do_remount_sb(s, flags, data, 0);
> +               do_remount_sb(s, flags, data, 0, NULL);
>         }
>         return dget(s->s_root);
>  }
> @@ -1529,3 +1716,76 @@ int thaw_super(struct super_block *sb)
>         return 0;
>  }
>  EXPORT_SYMBOL(thaw_super);
> +
> +/**
> + * vfs_get_tree - Get the mountable root
> + * @fc: The superblock configuration context.
> + *
> + * The filesystem is invoked to get or create a superblock which can then later
> + * be used for mounting.  The filesystem places a pointer to the root to be
> + * used for mounting in @fc->root.
> + */
> +int vfs_get_tree(struct fs_context *fc)
> +{
> +       struct super_block *sb;
> +       int ret;
> +
> +       if (fc->root)
> +               return -EBUSY;
> +
> +       if (fc->ops->validate) {
> +               ret = fc->ops->validate(fc);
> +               if (ret < 0)
> +                       return ret;
> +       }
> +
> +       /* The filesystem may transfer preallocated resources from the
> +        * configuration context to the superblock, thereby rendering the
> +        * config unusable for another attempt at creation if this one fails.
> +        */
> +       if (fc->degraded)
> +               return -EBUSY;
> +
> +       /* Get the mountable root in fc->root, with a ref on the root and a ref
> +        * on the superblock.
> +        */
> +       ret = fc->ops->get_tree(fc);
> +       if (ret < 0)
> +               return ret;
> +
> +       BUG_ON(!fc->root);
> +       sb = fc->root->d_sb;
> +       WARN_ON(!sb->s_bdi);
> +
> +       ret = security_sb_get_tree(fc);
> +       if (ret < 0)
> +               goto err_sb;
> +
> +       ret = -ENOMEM;
> +       if (fc->subtype && !sb->s_subtype) {
> +               sb->s_subtype = kstrdup(fc->subtype, GFP_KERNEL);
> +               if (!sb->s_subtype)
> +                       goto err_sb;
> +       }
> +
> +       sb->s_flags |= SB_BORN;
> +
> +       /* Filesystems should never set s_maxbytes larger than MAX_LFS_FILESIZE
> +        * but s_maxbytes was an unsigned long long for many releases.  Throw
> +        * this warning for a little while to try and catch filesystems that
> +        * violate this rule.
> +        */
> +       WARN(sb->s_maxbytes < 0,
> +            "%s set sb->s_maxbytes to negative value (%lld)\n",
> +            fc->fs_type->name, sb->s_maxbytes);
> +
> +       up_write(&sb->s_umount);
> +       return 0;
> +
> +err_sb:
> +       dput(fc->root);
> +       fc->root = NULL;
> +       deactivate_locked_super(sb);
> +       return ret;
> +}
> +EXPORT_SYMBOL(vfs_get_tree);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index bd2ee00e03ff..f391263c62a1 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -58,6 +58,7 @@ struct workqueue_struct;
>  struct iov_iter;
>  struct fscrypt_info;
>  struct fscrypt_operations;
> +struct fs_context;
>
>  extern void __init inode_init(void);
>  extern void __init inode_init_early(void);
> @@ -717,6 +718,11 @@ static inline void inode_unlock(struct inode *inode)
>         up_write(&inode->i_rwsem);
>  }
>
> +static inline int inode_lock_killable(struct inode *inode)
> +{
> +       return down_write_killable(&inode->i_rwsem);
> +}
> +
>  static inline void inode_lock_shared(struct inode *inode)
>  {
>         down_read(&inode->i_rwsem);
> @@ -1814,6 +1820,7 @@ struct super_operations {
>         int (*unfreeze_fs) (struct super_block *);
>         int (*statfs) (struct dentry *, struct kstatfs *);
>         int (*remount_fs) (struct super_block *, int *, char *);
> +       int (*remount_fs_fc) (struct super_block *, struct fs_context *);
>         void (*umount_begin) (struct super_block *);
>
>         int (*show_options)(struct seq_file *, struct dentry *);
> @@ -2072,8 +2079,10 @@ struct file_system_type {
>  #define FS_HAS_SUBTYPE         4
>  #define FS_USERNS_MOUNT                8       /* Can be mounted by userns root */
>  #define FS_RENAME_DOES_D_MOVE  32768   /* FS will handle d_move() during rename() internally. */
> +       unsigned short fs_context_size; /* Size of superblock config context to allocate */
>         struct dentry *(*mount) (struct file_system_type *, int,
>                        const char *, void *);
> +       int (*init_fs_context)(struct fs_context *, struct super_block *);
>         void (*kill_sb) (struct super_block *);
>         struct module *owner;
>         struct file_system_type * next;
> @@ -2113,6 +2122,9 @@ void deactivate_locked_super(struct super_block *sb);
>  int set_anon_super(struct super_block *s, void *data);
>  int get_anon_bdev(dev_t *);
>  void free_anon_bdev(dev_t);
> +struct super_block *sget_fc(struct fs_context *fc,
> +                           int (*test)(struct super_block *, struct fs_context *),
> +                           int (*set)(struct super_block *, struct fs_context *));
>  struct super_block *sget_userns(struct file_system_type *type,
>                         int (*test)(struct super_block *,void *),
>                         int (*set)(struct super_block *,void *),
> @@ -2155,8 +2167,8 @@ mount_pseudo(struct file_system_type *fs_type, char *name,
>
>  extern int register_filesystem(struct file_system_type *);
>  extern int unregister_filesystem(struct file_system_type *);
> -extern struct vfsmount *kern_mount_data(struct file_system_type *, void *data);
> -#define kern_mount(type) kern_mount_data(type, NULL)
> +extern struct vfsmount *kern_mount(struct file_system_type *);
> +extern struct vfsmount *kern_mount_data(struct file_system_type *, void *);
>  extern void kern_unmount(struct vfsmount *mnt);
>  extern int may_umount_tree(struct vfsmount *);
>  extern int may_umount(struct vfsmount *);
> diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
> index 645c57e10764..8af6ff0e869e 100644
> --- a/include/linux/fs_context.h
> +++ b/include/linux/fs_context.h
> @@ -27,9 +27,10 @@ struct user_namespace;
>  struct vfsmount;
>
>  enum fs_context_purpose {
> -       FS_CONTEXT_FOR_NEW,     /* New superblock for direct mount */
> +       FS_CONTEXT_FOR_USER_MOUNT,      /* New superblock for user-specified mount */
> +       FS_CONTEXT_FOR_KERNEL_MOUNT,    /* New superblock for kernel-internal mount */
>         FS_CONTEXT_FOR_SUBMOUNT,        /* New superblock for automatic submount */
> -       FS_CONTEXT_FOR_REMOUNT, /* Superblock reconfiguration for remount */
> +       FS_CONTEXT_FOR_REMOUNT,         /* Superblock reconfiguration for remount */
>  };
>
>  /*
> @@ -53,7 +54,8 @@ struct fs_context {
>         char                    *source;        /* The source name (eg. device) */
>         char                    *subtype;       /* The subtype to set on the superblock */
>         void                    *security;      /* The LSM context */
> -       unsigned int            sb_flags;       /* The superblock flags (MS_*) */
> +       void                    *s_fs_info;     /* Proposed s_fs_info */
> +       unsigned int            sb_flags;       /* Proposed superblock flags (SB_*) */
>         bool                    sloppy;         /* Unrecognised options are okay */
>         bool                    silent;
>         bool                    degraded;       /* True if the context can't be reused */
> @@ -70,4 +72,33 @@ struct fs_context_operations {
>         int (*get_tree)(struct fs_context *fc);
>  };
>
> +/*
> + * fs_context manipulation functions.
> + */
> +extern struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
> +                                            struct super_block *src_sb,
> +                                            unsigned int ms_flags,
> +                                            enum fs_context_purpose purpose);
> +extern struct fs_context *vfs_sb_reconfig(struct vfsmount *mnt,
> +                                         unsigned int ms_flags);
> +extern struct fs_context *vfs_dup_fs_context(struct fs_context *src);
> +extern int vfs_set_fs_source(struct fs_context *fc, const char *source, size_t slen);
> +extern int vfs_parse_mount_option(struct fs_context *fc, char *data);
> +extern int generic_parse_monolithic(struct fs_context *fc, void *data);
> +extern int vfs_get_tree(struct fs_context *fc);
> +extern void put_fs_context(struct fs_context *fc);
> +
> +/*
> + * sget() wrapper to be called from the ->get_tree() op.
> + */
> +enum vfs_get_super_keying {
> +       vfs_get_single_super,   /* Only one such superblock may exist */
> +       vfs_get_keyed_super,    /* Superblocks with different s_fs_info keys may exist */
> +       vfs_get_independent_super, /* Multiple independent superblocks may exist */
> +};
> +extern int vfs_get_super(struct fs_context *fc,
> +                        enum vfs_get_super_keying keying,
> +                        int (*fill_super)(struct super_block *sb,
> +                                          struct fs_context *fc));
> +
>  #endif /* _LINUX_FS_CONTEXT_H */
> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
> index 85398ba0b533..74aeccb041a2 100644
> --- a/include/linux/lsm_hooks.h
> +++ b/include/linux/lsm_hooks.h
> @@ -91,7 +91,7 @@
>   * @fs_context_free:
>   *     Clean up a filesystem context.
>   *     @fc indicates the filesystem context.
> - * @fs_context_parse_one:
> + * @fs_context_parse_option:
>   *     Userspace provided an option to configure a superblock.  The LSM may
>   *     reject it with an error and may use it for itself, in which case it
>   *     should return 1; otherwise it should return 0 to pass it on to the
> @@ -1419,7 +1419,7 @@ union security_list_options {
>         int (*fs_context_alloc)(struct fs_context *fc, struct super_block *src_sb);
>         int (*fs_context_dup)(struct fs_context *fc, struct fs_context *src_sc);
>         void (*fs_context_free)(struct fs_context *fc);
> -       int (*fs_context_parse_one)(struct fs_context *fc, char *opt);
> +       int (*fs_context_parse_option)(struct fs_context *fc, char *opt);
>         int (*sb_get_tree)(struct fs_context *fc);
>         int (*sb_mountpoint)(struct fs_context *fc, struct path *mountpoint);
>
> @@ -1745,7 +1745,7 @@ struct security_hook_heads {
>         struct list_head fs_context_alloc;
>         struct list_head fs_context_dup;
>         struct list_head fs_context_free;
> -       struct list_head fs_context_parse_one;
> +       struct list_head fs_context_parse_option;
>         struct list_head sb_get_tree;
>         struct list_head sb_mountpoint;
>         struct list_head sb_alloc_security;
> diff --git a/include/linux/mount.h b/include/linux/mount.h
> index 1ce85e6fd95f..f47306b4bf72 100644
> --- a/include/linux/mount.h
> +++ b/include/linux/mount.h
> @@ -20,6 +20,7 @@ struct super_block;
>  struct vfsmount;
>  struct dentry;
>  struct mnt_namespace;
> +struct fs_context;
>
>  #define MNT_NOSUID     0x01
>  #define MNT_NODEV      0x02
> @@ -87,6 +88,7 @@ struct path;
>  extern struct vfsmount *clone_private_mount(const struct path *path);
>
>  struct file_system_type;
> +extern struct vfsmount *vfs_create_mount(struct fs_context *fc);
>  extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
>                                       int flags, const char *name,
>                                       void *data);
> diff --git a/security/security.c b/security/security.c
> index 55383a0e764d..7826a493c02a 100644
> --- a/security/security.c
> +++ b/security/security.c
> @@ -366,9 +366,9 @@ void security_fs_context_free(struct fs_context *fc)
>         call_void_hook(fs_context_free, fc);
>  }
>
> -int security_fs_context_parse_one(struct fs_context *fc, char *opt)
> +int security_fs_context_parse_option(struct fs_context *fc, char *p)
>  {
> -       return call_int_hook(fs_context_parse_one, 0, fc, opt);
> +       return call_int_hook(fs_context_parse_option, 0, fc, p);
>  }
>
>  int security_sb_get_tree(struct fs_context *fc)
> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
> index 0dda7350b5af..ca57e61f9c43 100644
> --- a/security/selinux/hooks.c
> +++ b/security/selinux/hooks.c
> @@ -2927,7 +2927,7 @@ static void selinux_fs_context_free(struct fs_context *fc)
>         fc->security = NULL;
>  }
>
> -static int selinux_fs_context_parse_one(struct fs_context *fc, char *opt)
> +static int selinux_fs_context_parse_option(struct fs_context *fc, char *opt)
>  {
>         struct security_mnt_opts *opts = fc->security;
>         substring_t args[MAX_OPT_ARGS];
> @@ -3014,7 +3014,7 @@ static int selinux_sb_get_tree(struct fs_context *fc)
>                 return rc;
>
>         /* Allow all mounts performed by the kernel */
> -       if (fc->sb_flags & MS_KERNMOUNT)
> +       if (fc->purpose & FS_CONTEXT_FOR_KERNEL_MOUNT)
>                 return 0;
>
>         ad.type = LSM_AUDIT_DATA_DENTRY;
> @@ -6445,7 +6445,7 @@ static struct security_hook_list selinux_hooks[] __lsm_ro_after_init = {
>         LSM_HOOK_INIT(fs_context_alloc, selinux_fs_context_alloc),
>         LSM_HOOK_INIT(fs_context_dup, selinux_fs_context_dup),
>         LSM_HOOK_INIT(fs_context_free, selinux_fs_context_free),
> -       LSM_HOOK_INIT(fs_context_parse_one, selinux_fs_context_parse_one),
> +       LSM_HOOK_INIT(fs_context_parse_option, selinux_fs_context_parse_option),
>         LSM_HOOK_INIT(sb_get_tree, selinux_sb_get_tree),
>         LSM_HOOK_INIT(sb_mountpoint, selinux_sb_mountpoint),
>
>
