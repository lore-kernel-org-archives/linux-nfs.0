Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f47.google.com ([74.125.83.47]:47078 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab3JJIts (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2013 04:49:48 -0400
Received: by mail-ee0-f47.google.com with SMTP id d49so969226eek.6
        for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 01:49:47 -0700 (PDT)
Message-ID: <52566A27.3080204@primarydata.com>
Date: Thu, 10 Oct 2013 11:49:43 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Andrew Morton <akpm@linux-foundation.org>
CC: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        NFS list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] posix_acl: resolve compile dependency in posix_acl.h
References: <1380220974-14716-1-git-send-email-bhalevy@primarydata.com> <524C2F6D.1060703@primarydata.com> <20131009154109.13c7248c53b97d96194ca8f9@linux-foundation.org>
In-Reply-To: <20131009154109.13c7248c53b97d96194ca8f9@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-10 01:41, Andrew Morton wrote:
> On Wed, 02 Oct 2013 17:36:29 +0300 Benny Halevy <bhalevy@primarydata.com> wrote:
> 
>> From: Benny Halevy <bhalevy@panasas.com>
>>
>> get_cached_acl is defined as inline in posix_acl.h
>> requiring the full definition of struct inode as it
>> dereferences its struct inode * parameter.
> 
> That's very old code so you must have a peculiar config.  Please
> describe the circumstances under which this occurs, because I'd like to
> avoid merging this patch.
> 

Wow, sorry, you're right.  It originated in 2.6.33 as far as I can see
and it is no longer needed.

>> --- a/include/linux/posix_acl.h
>> +++ b/include/linux/posix_acl.h
>> @@ -9,6 +9,7 @@
>>  #define __LINUX_POSIX_ACL_H
>>
>>  #include <linux/bug.h>
>> +#include <linux/fs.h>
>>  #include <linux/slab.h>
>>  #include <linux/rcupdate.h>
> 
> A better fix is to undo all that crazy inlining in posix_acl.h.
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: posix_acl: uninlining
> 
> Uninline vast tracts of nested inline functions in
> include/linux/posix_acl.h.
> 
> This reduces the text+data+bss size of x86_64 allyesconfig vmlinux by 8026
> bytes.
> 
> Also fixes an obscure build error reported by Benny: get_cached_acl()
> needs fs.h for struct inode internals.

Sorry for the stale report, I have no problem with 3.12-rc3.

> 
> The patch also regularises the positioning of the EXPORT_SYMBOLs in
> posix_acl.c.
> 
> Reported-by:: Benny Halevy <bhalevy@panasas.com>

ditto.

> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: Benny Halevy <bhalevy@primarydata.com>
> Cc: Andreas Gruenbacher <agruen@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

FWIW, I tested my linux-pnfs 3.12-rc3 tree with this patch
and it builds and causes no regression with the connectathon test suite over pnfs.

Benny

> ---
> 
>  fs/posix_acl.c            |   84 +++++++++++++++++++++++++++++++++---
>  include/linux/posix_acl.h |   78 ++-------------------------------
>  2 files changed, 85 insertions(+), 77 deletions(-)
> 
> diff -puN fs/posix_acl.c~posix_acl-uninlining fs/posix_acl.c
> --- a/fs/posix_acl.c~posix_acl-uninlining
> +++ a/fs/posix_acl.c
> @@ -22,11 +22,80 @@
>  
>  #include <linux/errno.h>
>  
> -EXPORT_SYMBOL(posix_acl_init);
> -EXPORT_SYMBOL(posix_acl_alloc);
> -EXPORT_SYMBOL(posix_acl_valid);
> -EXPORT_SYMBOL(posix_acl_equiv_mode);
> -EXPORT_SYMBOL(posix_acl_from_mode);
> +struct posix_acl **acl_by_type(struct inode *inode, int type)
> +{
> +	switch (type) {
> +	case ACL_TYPE_ACCESS:
> +		return &inode->i_acl;
> +	case ACL_TYPE_DEFAULT:
> +		return &inode->i_default_acl;
> +	default:
> +		BUG();
> +	}
> +}
> +EXPORT_SYMBOL(acl_by_type);
> +
> +struct posix_acl *get_cached_acl(struct inode *inode, int type)
> +{
> +	struct posix_acl **p = acl_by_type(inode, type);
> +	struct posix_acl *acl = ACCESS_ONCE(*p);
> +	if (acl) {
> +		spin_lock(&inode->i_lock);
> +		acl = *p;
> +		if (acl != ACL_NOT_CACHED)
> +			acl = posix_acl_dup(acl);
> +		spin_unlock(&inode->i_lock);
> +	}
> +	return acl;
> +}
> +EXPORT_SYMBOL(get_cached_acl);
> +
> +struct posix_acl *get_cached_acl_rcu(struct inode *inode, int type)
> +{
> +	return rcu_dereference(*acl_by_type(inode, type));
> +}
> +EXPORT_SYMBOL(get_cached_acl_rcu);
> +
> +void set_cached_acl(struct inode *inode, int type, struct posix_acl *acl)
> +{
> +	struct posix_acl **p = acl_by_type(inode, type);
> +	struct posix_acl *old;
> +	spin_lock(&inode->i_lock);
> +	old = *p;
> +	rcu_assign_pointer(*p, posix_acl_dup(acl));
> +	spin_unlock(&inode->i_lock);
> +	if (old != ACL_NOT_CACHED)
> +		posix_acl_release(old);
> +}
> +EXPORT_SYMBOL(set_cached_acl);
> +
> +void forget_cached_acl(struct inode *inode, int type)
> +{
> +	struct posix_acl **p = acl_by_type(inode, type);
> +	struct posix_acl *old;
> +	spin_lock(&inode->i_lock);
> +	old = *p;
> +	*p = ACL_NOT_CACHED;
> +	spin_unlock(&inode->i_lock);
> +	if (old != ACL_NOT_CACHED)
> +		posix_acl_release(old);
> +}
> +EXPORT_SYMBOL(forget_cached_acl);
> +
> +void forget_all_cached_acls(struct inode *inode)
> +{
> +	struct posix_acl *old_access, *old_default;
> +	spin_lock(&inode->i_lock);
> +	old_access = inode->i_acl;
> +	old_default = inode->i_default_acl;
> +	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
> +	spin_unlock(&inode->i_lock);
> +	if (old_access != ACL_NOT_CACHED)
> +		posix_acl_release(old_access);
> +	if (old_default != ACL_NOT_CACHED)
> +		posix_acl_release(old_default);
> +}
> +EXPORT_SYMBOL(forget_all_cached_acls);
>  
>  /*
>   * Init a fresh posix_acl
> @@ -37,6 +106,7 @@ posix_acl_init(struct posix_acl *acl, in
>  	atomic_set(&acl->a_refcount, 1);
>  	acl->a_count = count;
>  }
> +EXPORT_SYMBOL(posix_acl_init);
>  
>  /*
>   * Allocate a new ACL with the specified number of entries.
> @@ -51,6 +121,7 @@ posix_acl_alloc(int count, gfp_t flags)
>  		posix_acl_init(acl, count);
>  	return acl;
>  }
> +EXPORT_SYMBOL(posix_acl_alloc);
>  
>  /*
>   * Clone an ACL.
> @@ -146,6 +217,7 @@ posix_acl_valid(const struct posix_acl *
>  		return 0;
>  	return -EINVAL;
>  }
> +EXPORT_SYMBOL(posix_acl_valid);
>  
>  /*
>   * Returns 0 if the acl can be exactly represented in the traditional
> @@ -186,6 +258,7 @@ posix_acl_equiv_mode(const struct posix_
>                  *mode_p = (*mode_p & ~S_IRWXUGO) | mode;
>          return not_equiv;
>  }
> +EXPORT_SYMBOL(posix_acl_equiv_mode);
>  
>  /*
>   * Create an ACL representing the file mode permission bits of an inode.
> @@ -207,6 +280,7 @@ posix_acl_from_mode(umode_t mode, gfp_t
>  	acl->a_entries[2].e_perm = (mode & S_IRWXO);
>  	return acl;
>  }
> +EXPORT_SYMBOL(posix_acl_from_mode);
>  
>  /*
>   * Return 0 if current is granted want access to the inode
> diff -puN include/linux/posix_acl.h~posix_acl-uninlining include/linux/posix_acl.h
> --- a/include/linux/posix_acl.h~posix_acl-uninlining
> +++ a/include/linux/posix_acl.h
> @@ -94,78 +94,12 @@ extern int posix_acl_chmod(struct posix_
>  extern struct posix_acl *get_posix_acl(struct inode *, int);
>  extern int set_posix_acl(struct inode *, int, struct posix_acl *);
>  
> -#ifdef CONFIG_FS_POSIX_ACL
> -static inline struct posix_acl **acl_by_type(struct inode *inode, int type)
> -{
> -	switch (type) {
> -	case ACL_TYPE_ACCESS:
> -		return &inode->i_acl;
> -	case ACL_TYPE_DEFAULT:
> -		return &inode->i_default_acl;
> -	default:
> -		BUG();
> -	}
> -}
> -
> -static inline struct posix_acl *get_cached_acl(struct inode *inode, int type)
> -{
> -	struct posix_acl **p = acl_by_type(inode, type);
> -	struct posix_acl *acl = ACCESS_ONCE(*p);
> -	if (acl) {
> -		spin_lock(&inode->i_lock);
> -		acl = *p;
> -		if (acl != ACL_NOT_CACHED)
> -			acl = posix_acl_dup(acl);
> -		spin_unlock(&inode->i_lock);
> -	}
> -	return acl;
> -}
> -
> -static inline struct posix_acl *get_cached_acl_rcu(struct inode *inode, int type)
> -{
> -	return rcu_dereference(*acl_by_type(inode, type));
> -}
> -
> -static inline void set_cached_acl(struct inode *inode,
> -				  int type,
> -				  struct posix_acl *acl)
> -{
> -	struct posix_acl **p = acl_by_type(inode, type);
> -	struct posix_acl *old;
> -	spin_lock(&inode->i_lock);
> -	old = *p;
> -	rcu_assign_pointer(*p, posix_acl_dup(acl));
> -	spin_unlock(&inode->i_lock);
> -	if (old != ACL_NOT_CACHED)
> -		posix_acl_release(old);
> -}
> -
> -static inline void forget_cached_acl(struct inode *inode, int type)
> -{
> -	struct posix_acl **p = acl_by_type(inode, type);
> -	struct posix_acl *old;
> -	spin_lock(&inode->i_lock);
> -	old = *p;
> -	*p = ACL_NOT_CACHED;
> -	spin_unlock(&inode->i_lock);
> -	if (old != ACL_NOT_CACHED)
> -		posix_acl_release(old);
> -}
> -
> -static inline void forget_all_cached_acls(struct inode *inode)
> -{
> -	struct posix_acl *old_access, *old_default;
> -	spin_lock(&inode->i_lock);
> -	old_access = inode->i_acl;
> -	old_default = inode->i_default_acl;
> -	inode->i_acl = inode->i_default_acl = ACL_NOT_CACHED;
> -	spin_unlock(&inode->i_lock);
> -	if (old_access != ACL_NOT_CACHED)
> -		posix_acl_release(old_access);
> -	if (old_default != ACL_NOT_CACHED)
> -		posix_acl_release(old_default);
> -}
> -#endif
> +struct posix_acl **acl_by_type(struct inode *inode, int type);
> +struct posix_acl *get_cached_acl(struct inode *inode, int type);
> +struct posix_acl *get_cached_acl_rcu(struct inode *inode, int type);
> +void set_cached_acl(struct inode *inode, int type, struct posix_acl *acl);
> +void forget_cached_acl(struct inode *inode, int type);
> +void forget_all_cached_acls(struct inode *inode);
>  
>  static inline void cache_no_acl(struct inode *inode)
>  {
> _
> 
