Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53393 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228AbcCKORD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2016 09:17:03 -0500
Date: Fri, 11 Mar 2016 06:17:01 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        linux-api@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com,
        Christoph Hellwig <hch@infradead.org>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel@vger.kernel.org, Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4@vger.kernel.org, Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 18/22] richacl: xattr mapping functions
Message-ID: <20160311141701.GE14808@infradead.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <1456733847-17982-19-git-send-email-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456733847-17982-19-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +#include <linux/richacl_xattr.h>
> +
> +MODULE_LICENSE("GPL");

what's the point given that the code isn't even modolar?

> +static void
> +fix_xattr_from_user(const char *kname, void *kvalue, size_t size)
> +{
> +	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
> +		return;
> +	kname += XATTR_SYSTEM_PREFIX_LEN;
> +	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
> +	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
> +		posix_acl_fix_xattr_from_user(kvalue, size);
> +}
>  
>  /*
>   * Extended attribute SET operations
> @@ -329,9 +339,7 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
>  			error = -EFAULT;
>  			goto out;
>  		}
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_from_user(kvalue, size);
> +		fix_xattr_from_user(kname, kvalue, size);
>  	}
>  
>  	error = vfs_setxattr(d, kname, kvalue, size, flags);
> @@ -396,6 +404,17 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
>  	return error;
>  }
>  
> +static void
> +fix_xattr_to_user(const char *kname, void *kvalue, size_t size)
> +{
> +	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
> +		return;
> +	kname += XATTR_SYSTEM_PREFIX_LEN;
> +	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
> +	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
> +		posix_acl_fix_xattr_to_user(kvalue, size);
> +}
> +
>  /*
>   * Extended attribute GET operations
>   */
> @@ -426,9 +445,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
>  
>  	error = vfs_getxattr(d, kname, kvalue, size);
>  	if (error > 0) {
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_to_user(kvalue, size);
> +		fix_xattr_to_user(kname, kvalue, size);

I don't see how this is related to the rest of the patch.

> +++ b/include/linux/richacl_xattr.h

What's the point in splitting this from the richacl.h header?

Same for the uapi versions.

> +struct richacl_xattr {
> +	unsigned char	a_version;
> +	unsigned char	a_flags;

Explicit __u8 for uapi headers, please.

