Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:51229 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753052AbdJFUeW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Oct 2017 16:34:22 -0400
Subject: Re: [PATCH 03/14] VFS: Implement a filesystem superblock
 creation/configuration context [ver #6]
To: David Howells <dhowells@redhat.com>, viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
 <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <27530b6a-7290-2171-899e-6c16c14f402e@infradead.org>
Date: Fri, 6 Oct 2017 13:34:19 -0700
MIME-Version: 1.0
In-Reply-To: <150730496982.6182.10042997820796149075.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/06/17 08:49, David Howells wrote:
> 
> diff --git a/fs/fs_context.c b/fs/fs_context.c
> new file mode 100644
> index 000000000000..a3a7ccb4323d
> --- /dev/null
> +++ b/fs/fs_context.c

> +/**
> + * generic_parse_monolithic - Parse key[=val][,key[=val]]* mount data
> + * @mc: The superblock configuration to fill in.

function argument is &struct fs_context *ctx, not @mc

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
> +	char *options = data, *p;
> +	int ret;
> +
> +	if (!options)
> +		return 0;
> +
> +	while ((p = strsep(&options, ",")) != NULL) {
> +		if (*p) {
> +			ret = vfs_parse_mount_option(ctx, p);
> +			if (ret < 0)
> +				return ret;
> +		}
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(generic_parse_monolithic);
> +

> +
> +/**
> + * put_fs_context - Dispose of a superblock configuration context.
> + * @sc: The context to dispose of.

      @fc:

> + */
> +void put_fs_context(struct fs_context *fc)
> +{
> +	struct super_block *sb;
> +
> +	if (fc->root) {
> +		sb = fc->root->d_sb;
> +		dput(fc->root);
> +		fc->root = NULL;
> +		deactivate_super(sb);
> +	}
> +
> +	if (fc->ops && fc->ops->free)
> +		fc->ops->free(fc);
> +
> +	security_fs_context_free(fc);
> +	if (fc->net_ns)
> +		put_net(fc->net_ns);
> +	put_user_ns(fc->user_ns);
> +	if (fc->cred)
> +		put_cred(fc->cred);
> +	kfree(fc->subtype);
> +	put_filesystem(fc->fs_type);
> +	kfree(fc->source);
> +	kfree(fc);
> +}
> +EXPORT_SYMBOL(put_fs_context);


(in fs/namespace.c:)

> +/**
> + * vfs_create_mount - Create a mount for a configured superblock
> + * fc: The configuration context with the superblock attached

      @fc:

> + *
> + * Create a mount to an already configured superblock.  If necessary, the
> + * caller should invoke vfs_get_tree() before calling this.
> + *
> + * Note that this does not attach the mount to anything.
> + */
> +struct vfsmount *vfs_create_mount(struct fs_context *fc)
> +{
> +	struct mount *mnt;
> +
> +	if (!fc->root)
> +		return ERR_PTR(-EINVAL);
> +
> +	mnt = alloc_vfsmnt(fc->source ?: "none");
> +	if (!mnt)
> +		return ERR_PTR(-ENOMEM);
> +
> +	if (fc->purpose == FS_CONTEXT_FOR_KERNEL_MOUNT)
> +		/* It's a longterm mount, don't release mnt until we unmount
> +		 * before file sys is unregistered
> +		 */
> +		mnt->mnt.mnt_flags = MNT_INTERNAL;
> +
> +	atomic_inc(&fc->root->d_sb->s_active);
> +	mnt->mnt.mnt_sb		= fc->root->d_sb;
> +	mnt->mnt.mnt_root	= dget(fc->root);
> +	mnt->mnt_mountpoint	= mnt->mnt.mnt_root;
> +	mnt->mnt_parent		= mnt;
> +
> +	lock_mount_hash();
> +	list_add_tail(&mnt->mnt_instance, &mnt->mnt.mnt_sb->s_mounts);
> +	unlock_mount_hash();
> +	return &mnt->mnt;
> +}
> +EXPORT_SYMBOL(vfs_create_mount);


-- 
~Randy
