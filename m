Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:34660 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068AbcGFS5I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 14:57:08 -0400
Received: by mail-qk0-f176.google.com with SMTP id t127so323103888qkf.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 11:57:08 -0700 (PDT)
Message-ID: <1467831425.2908.16.camel@redhat.com>
Subject: Re: [PATCH v23 13/22] vfs: Cache richacl in struct inode
From: Jeff Layton <jlayton@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Date: Wed, 06 Jul 2016 14:57:05 -0400
In-Reply-To: <1467294433-3222-14-git-send-email-agruenba@redhat.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
	 <1467294433-3222-14-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-06-30 at 15:47 +0200, Andreas Gruenbacher wrote:
> Cache richacls in struct inode so that this doesn't have to be done
> individually in each filesystem.  This is similar to POSIX ACLs.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> ---
>  fs/inode.c              | 13 +++++---
>  fs/richacl.c            | 81 +++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/fs.h      |  5 ++-
>  include/linux/richacl.h | 11 +++++++
>  4 files changed, 105 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 40c03a7..7dbb09c 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -181,8 +181,11 @@ int inode_init_always(struct super_block *sb, struct inode *inode)
>  	inode->i_private = NULL;
>  	inode->i_mapping = mapping;
>  	INIT_HLIST_HEAD(&inode->i_dentry);	/* buggered by rcu freeing */
> -#ifdef CONFIG_FS_POSIX_ACL
> -	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
> +#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
> +	inode->i_acl = ACL_NOT_CACHED;
> +# if defined(CONFIG_FS_POSIX_ACL)
> +	inode->i_default_acl = ACL_NOT_CACHED;
> +# endif
>  #endif
>  
>  #ifdef CONFIG_FSNOTIFY
> @@ -238,17 +241,19 @@ void __destroy_inode(struct inode *inode)
>  		atomic_long_dec(&inode->i_sb->s_remove_count);
>  	}
>  
> -#ifdef CONFIG_FS_POSIX_ACL
> +#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
>  	if (inode->i_acl && !is_uncached_acl(inode->i_acl))
>  		base_acl_put(inode->i_acl);
> +# if defined(CONFIG_FS_POSIX_ACL)
>  	if (inode->i_default_acl && !is_uncached_acl(inode->i_default_acl))
>  		base_acl_put(inode->i_default_acl);
> +# endif
>  #endif
>  	this_cpu_dec(nr_inodes);
>  }
>  EXPORT_SYMBOL(__destroy_inode);
>  
> -#ifdef CONFIG_FS_POSIX_ACL
> +#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
>  struct base_acl *__get_cached_acl(struct base_acl **p)
>  {
>  	struct base_acl *base_acl;
> diff --git a/fs/richacl.c b/fs/richacl.c
> index 8971ead..b2a03c1 100644
> --- a/fs/richacl.c
> +++ b/fs/richacl.c
> @@ -20,6 +20,87 @@
>  #include 
>  #include 
>  
> +void set_cached_richacl(struct inode *inode, struct richacl *acl)
> +{
> +	struct base_acl *old;
> +
> +	old = xchg(&inode->i_acl, &richacl_get(acl)->a_base);
> +	if (!is_uncached_acl(old))
> +		base_acl_put(old);
> +}
> +EXPORT_SYMBOL_GPL(set_cached_richacl);
> +
> +void forget_cached_richacl(struct inode *inode)
> +{
> +	__forget_cached_acl(&inode->i_acl);
> +}
> +EXPORT_SYMBOL_GPL(forget_cached_richacl);
> +
> +struct richacl *get_richacl(struct inode *inode)
> +{
> +	struct base_acl *sentinel, *base_acl;
> +	struct richacl *acl;
> +
> +	if (!IS_RICHACL(inode))
> +		return NULL;
> +
> +	/*
> +	 * The sentinel is used to detect when another operation like
> +	 * set_cached_richacl() or forget_cached_richacl() races with
> +	 * get_richacl().
> +	 * It is guaranteed that is_uncached_acl(sentinel) is true.
> +	 */
> +
> +	base_acl = __get_cached_acl(&inode->i_acl);
> +	if (!is_uncached_acl(base_acl))
> +		return richacl(base_acl);
> +
> +	sentinel = uncached_acl_sentinel(current);
> +
> +	/*
> +	 * If the ACL isn't being read yet, set our sentinel.  Otherwise, the
> +	 * current value of the ACL will not be ACL_NOT_CACHED and so our own
> +	 * sentinel will not be set; another task will update the cache.  We
> +	 * could wait for that other task to complete its job, but it's easier
> +	 * to just call ->get_acl to fetch the ACL ourself.  (This is going to
> +	 * be an unlikely race.)
> +	 */
> +	if (cmpxchg(&inode->i_acl, ACL_NOT_CACHED, sentinel) != ACL_NOT_CACHED)
> +		/* fall through */ ;
> +

So you do the same thing regardless of the outcome of the above? Why
bother with the if at all here? Just do the cmpxchg and toss out the
result.

> +	/*
> +	 * Normally, the ACL returned by ->get_richacl will be cached.
> +	 * A filesystem can prevent that by calling
> +	 * forget_cached_richacl(inode) in ->get_richacl.
> +	 *
> +	 * If the filesystem doesn't have a ->get_richacl function at all,
> +	 * we'll just create the negative cache entry.
> +	 */
> +	if (!inode->i_op->get_richacl) {
> +		set_cached_richacl(inode, NULL);
> +		return NULL;
> +	}
> +
> +	acl = inode->i_op->get_richacl(inode);
> +	if (IS_ERR(acl)) {
> +		/*
> +		 * Remove our sentinel so that we don't block future attempts
> +		 * to cache the ACL.
> +		 */
> +		cmpxchg(&inode->i_acl, sentinel, ACL_NOT_CACHED);
> +		return acl;
> +	}
> +

So this is sort of icky: only the task that sets the sentinel can set
the cached acl.

You could have one task set the sentinel, call get_richacl and fail, but then a concurrent task also issues a get_richacl and succeeds. That task will get its acl, but it doesn't end up getting cached and subsequent callers then have to reissue the request. It would be good if the first successful fetch of the acl sets it in the cache.

That said, getting the acl could be pretty expensive with some filesystems. NFS or CIFS are going to have to do an on the wire call to fetch them, for instance. I think it would be better to have concurrent callers wait for the first caller's result instead of issuing parallel get_richacl requests.

> +	/*
> +	 * Cache the result, but only if our sentinel is still in place.
> +	 */
> +	richacl_get(acl);
> +	if (unlikely(cmpxchg(&inode->i_acl, sentinel, &acl->a_base) != sentinel))
> +		richacl_put(acl);
> +	return acl;
> +}
> +EXPORT_SYMBOL_GPL(get_richacl);
> +
>  /**
>   * richacl_alloc  -  allocate a richacl
>   * @count:	number of entries
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index ac96bda..4d72a6d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -589,6 +589,7 @@ struct base_acl {
>  	};
>  };
>  struct posix_acl;
> +struct richacl;
>  #define ACL_NOT_CACHED ((void *)(-1))
>  
>  static inline struct base_acl *
> @@ -619,9 +620,11 @@ struct inode {
>  	kgid_t			i_gid;
>  	unsigned int		i_flags;
>  
> -#if defined(CONFIG_FS_POSIX_ACL)
> +#if defined(CONFIG_FS_POSIX_ACL) || defined(CONFIG_FS_RICHACL)
>  	struct base_acl		*i_acl;
> +# if defined(CONFIG_FS_POSIX_ACL)
>  	struct base_acl		*i_default_acl;
> +# endif
>  #endif
>  

Oh, so if we compile in richacls and not posix acls, we shrink the
inode by a pointer. Nice!

>  	const struct inode_operations	*i_op;
> diff --git a/include/linux/richacl.h b/include/linux/richacl.h
> index 35a5bcb..3e05c94 100644
> --- a/include/linux/richacl.h
> +++ b/include/linux/richacl.h
> @@ -70,6 +70,17 @@ richacl_put(struct richacl *acl)
>  	base_acl_put(&acl->a_base);
>  }
>  
> +static inline struct richacl *
> +richacl(struct base_acl *base_acl)
> +{
> +	BUILD_BUG_ON(offsetof(struct richacl, a_base) != 0);
> +	return container_of(base_acl, struct richacl, a_base);
> +}
> +
> +extern void set_cached_richacl(struct inode *, struct richacl *);
> +extern void forget_cached_richacl(struct inode *);
> +extern struct richacl *get_richacl(struct inode *);
> +
>  /**
>   * richace_is_owner  -  check if @ace is an OWNER@ entry
>   */

-- 
Jeff Layton <jlayton@redhat.com>

