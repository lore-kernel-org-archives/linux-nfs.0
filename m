Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37104 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdECVnv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 17:43:51 -0400
Received: by mail-wm0-f43.google.com with SMTP id m123so1299827wma.0
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 14:43:50 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
        <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
Date: Wed, 03 May 2017 23:43:47 +0200
In-Reply-To: <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
        (David Howells's message of "Wed, 03 May 2017 17:04:59 +0100")
Message-ID: <87bmr939bg.fsf@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 03 2017, David Howells <dhowells@redhat.com> wrote:

> fs_type->fsopen() is called to set it up.  fs_type->mc_size says how much
> should be added on to the mount context for the filesystem's use.

This is repeated several times in the documentation, but the code says
that ->mc_size should be the full size of the struct wrapping struct
mount_context.

> diff --git a/fs/mount.h b/fs/mount.h
> index 2826543a131d..b1e99b38f2ee 100644
> --- a/fs/mount.h
> +++ b/fs/mount.h
> @@ -108,9 +108,10 @@ static inline void detach_mounts(struct dentry *dentry)
>  	__detach_mounts(dentry);
>  }
>  
> -static inline void get_mnt_ns(struct mnt_namespace *ns)
> +static inline struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns)
>  {
>  	atomic_inc(&ns->count);
> +	return ns;
>  }
>
>  extern seqlock_t mount_lock;

it's not much, but at least this could go into a patch of its own.

> +/**
> + * __vfs_fsopen - Open a filesystem and create a mount context
> + * @fs_type: The filesystem type
> + * @src_sb: A superblock from which this one derives (or NULL)
> + * @ms_flags: Superblock flags and op flags (such as MS_REMOUNT)
> + * @mnt_flags: Mountpoint flags, such as MNT_READONLY
> + * @mount_type: Type of mount
> + *
> + * Open a filesystem and create a mount context.  The mount context is
> + * initialised with the supplied flags and, if a submount/automount from
> + * another superblock (@src_sb), may have parameters such as namespaces copied
> + * across from that superblock.
> + */
> +struct mount_context *__vfs_fsopen(struct file_system_type *fs_type,
> +				   struct super_block *src_sb,
> +				   unsigned int ms_flags, unsigned int mnt_flags,
> +				   enum mount_type mount_type)
> +{
> +	struct mount_context *mc;
> +	int ret;
> +
> +	if (fs_type->fsopen && fs_type->mc_size < sizeof(*mc))
> +		BUG();

So ->mc_size can be 0 (i.e. not explicitly initialized) if fs_type does
not have ->fsopen. OK.

> +	mc = kzalloc(max_t(size_t, fs_type->mc_size, sizeof(*mc)), GFP_KERNEL);

In which case we round up to sizeof(*mc). OK.

> +	if (!mc)
> +		return ERR_PTR(-ENOMEM);
> +
> +	mc->mount_type = mount_type;
> +	mc->ms_flags = ms_flags;
> +	mc->mnt_flags = mnt_flags;
> +	mc->fs_type = fs_type;
> +	get_filesystem(fs_type);

Maybe get_filesystem should also be taught to return its argument so
this could be written like the below assignments.

> +	mc->mnt_ns = get_mnt_ns(current->nsproxy->mnt_ns);
> +	mc->pid_ns = get_pid_ns(task_active_pid_ns(current));
> +	mc->net_ns = get_net(current->nsproxy->net_ns);
> +	mc->user_ns = get_user_ns(current_user_ns());
> +	mc->cred = get_current_cred();
> +
> +
> +/**
> + * vfs_dup_mount_context: Duplicate a mount context.
> + * @src: The mount context to copy.
> + */
> +struct mount_context *vfs_dup_mount_context(struct mount_context *src)
> +{
> +	struct mount_context *mc;
> +	int ret;
> +
> +	if (!src->ops->dup)
> +		return ERR_PTR(-ENOTSUPP);
> +
> +	mc = kmemdup(src, src->fs_type->mc_size, GFP_KERNEL);

So this assumes that vfs_dup_mount_context is only used if ->mc_size is
explicitly initialized. A max_t here as well probably wouldn't hurt.

> +	unsigned short mc_size;		/* Size of mount context to allocate */

Any particular reason to use a short? The struct doesn't pack any better.

> +static int selinux_mount_ctx_dup(struct mount_context *mc,
> +				 struct mount_context *src_mc)
> +{
> +	const struct security_mnt_opts *src = src_mc->security;
> +	struct security_mnt_opts *opts;
> +	int i, n;
> +
> +	opts = kzalloc(sizeof(*opts), GFP_KERNEL);
> +	if (!opts)
> +		return -ENOMEM;
> +	mc->security = opts;
> +
> +	if (!src || !src->num_mnt_opts)
> +		return 0;
> +	n = opts->num_mnt_opts = src->num_mnt_opts;
> +
> +	if (opts->mnt_opts) {

should probably be src->mnt_opts

