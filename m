From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/5] VFS: Add VFS helper functions for setting up
	private namespaces
Date: Tue, 23 Jun 2009 15:13:07 -0500
Message-ID: <20090623201307.GA25760@us.ibm.com>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org> <20090622190913.27923.61549.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:38480 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbZFWUN0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jun 2009 16:13:26 -0400
In-Reply-To: <20090622190913.27923.61549.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting Trond Myklebust (Trond.Myklebust@netapp.com):
> The purpose of this patch is to improve the remote mount path lookup
> support for distributed filesystems such as the NFSv4 client.
> 
> When given a mount command of the form "mount server:/foo/bar /mnt", the
> NFSv4 client is required to look up the filehandle for "server:/", and
> then look up each component of the remote mount path "foo/bar" in order
> to find the directory that is actually going to be mounted on /mnt.
> Following that remote mount path may involve following symlinks,
> crossing server-side mount points and even following referrals to
> filesystem volumes on other servers.
> 
> Since the standard VFS path lookup code already supports walking paths
> that contain all these features (using in-kernel automounts for
> following referrals) we would like to be able to reuse that rather than
> duplicate the full path traversal functionality in the NFSv4 client code.
> 
> This patch therefore defines a VFS helper function create_mnt_ns(), that
> sets up a temporary filesystem namespace and attaches a root filesystem to
> it. It exports the create_mnt_ns() and put_mnt_ns() function for use by
> filesystem modules.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

This looks good, thanks.  Though I see no reason not to also switch over
init_mount_tree() to the new helper.

(Seems plausible that c/r code would use this as well)

Reviewed-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

> ---
> 
>  fs/namespace.c                |   45 ++++++++++++++++++++++++++++++++++-------
>  include/linux/mnt_namespace.h |    1 +
>  2 files changed, 38 insertions(+), 8 deletions(-)
> 
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 2465c05..9b766b0 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1937,6 +1937,21 @@ dput_out:
>  	return retval;
>  }
> 
> +static struct mnt_namespace *alloc_mnt_ns(void)
> +{
> +	struct mnt_namespace *new_ns;
> +
> +	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
> +	if (!new_ns)
> +		return ERR_PTR(-ENOMEM);
> +	atomic_set(&new_ns->count, 1);
> +	new_ns->root = NULL;
> +	INIT_LIST_HEAD(&new_ns->list);
> +	init_waitqueue_head(&new_ns->poll);
> +	new_ns->event = 0;
> +	return new_ns;
> +}
> +
>  /*
>   * Allocate a new namespace structure and populate it with contents
>   * copied from the namespace of the passed in task structure.
> @@ -1948,14 +1963,9 @@ static struct mnt_namespace *dup_mnt_ns(struct mnt_namespace *mnt_ns,
>  	struct vfsmount *rootmnt = NULL, *pwdmnt = NULL;
>  	struct vfsmount *p, *q;
> 
> -	new_ns = kmalloc(sizeof(struct mnt_namespace), GFP_KERNEL);
> -	if (!new_ns)
> -		return ERR_PTR(-ENOMEM);
> -
> -	atomic_set(&new_ns->count, 1);
> -	INIT_LIST_HEAD(&new_ns->list);
> -	init_waitqueue_head(&new_ns->poll);
> -	new_ns->event = 0;
> +	new_ns = alloc_mnt_ns();
> +	if (IS_ERR(new_ns))
> +		return new_ns;
> 
>  	down_write(&namespace_sem);
>  	/* First pass: copy the tree topology */
> @@ -2019,6 +2029,24 @@ struct mnt_namespace *copy_mnt_ns(unsigned long flags, struct mnt_namespace *ns,
>  	return new_ns;
>  }
> 
> +/**
> + * create_mnt_ns - creates a private namespace and adds a root filesystem
> + * @mnt: pointer to the new root filesystem mountpoint
> + */
> +struct mnt_namespace *create_mnt_ns(struct vfsmount *mnt)
> +{
> +	struct mnt_namespace *new_ns;
> +
> +	new_ns = alloc_mnt_ns();
> +	if (!IS_ERR(new_ns)) {
> +		mnt->mnt_ns = new_ns;
> +		new_ns->root = mnt;
> +		list_add(&new_ns->list, &new_ns->root->mnt_list);
> +	}
> +	return new_ns;
> +}
> +EXPORT_SYMBOL(create_mnt_ns);
> +
>  SYSCALL_DEFINE5(mount, char __user *, dev_name, char __user *, dir_name,
>  		char __user *, type, unsigned long, flags, void __user *, data)
>  {
> @@ -2264,3 +2292,4 @@ void put_mnt_ns(struct mnt_namespace *ns)
>  	release_mounts(&umount_list);
>  	kfree(ns);
>  }
> +EXPORT_SYMBOL(put_mnt_ns);
> diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
> index 299d11a..3beb259 100644
> --- a/include/linux/mnt_namespace.h
> +++ b/include/linux/mnt_namespace.h
> @@ -24,6 +24,7 @@ struct proc_mounts {
> 
>  struct fs_struct;
> 
> +extern struct mnt_namespace *create_mnt_ns(struct vfsmount *mnt);
>  extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
>  		struct fs_struct *);
>  extern void put_mnt_ns(struct mnt_namespace *ns);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
