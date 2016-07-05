Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:36431 "EHLO
	mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbcGEPix (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jul 2016 11:38:53 -0400
Received: by mail-qt0-f178.google.com with SMTP id w59so102802766qtd.3
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 08:38:52 -0700 (PDT)
Message-ID: <1467733130.3800.36.camel@redhat.com>
Subject: Re: [PATCH v23 10/22] posix_acl: Improve xattr fixup code
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
Date: Tue, 05 Jul 2016 11:38:50 -0400
In-Reply-To: <1467294433-3222-11-git-send-email-agruenba@redhat.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
	 <1467294433-3222-11-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-06-30 at 15:47 +0200, Andreas Gruenbacher wrote:
> Both XATTR_NAME_POSIX_ACL_ACCESS and XATTR_NAME_POSIX_ACL_DEFAULT have
> the same XATTR_SYSTEM_PREFIX prefix; don't check for the same prefix
> repeatedly.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: Steve French <steve.french@primarydata.com>
> ---
>  fs/xattr.c | 29 +++++++++++++++++++++++------
>  1 file changed, 23 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 4beafc4..61ac218 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -295,6 +295,16 @@ out:
>  }
>  EXPORT_SYMBOL_GPL(vfs_removexattr);
>  
> +static void
> +fix_xattr_from_user(const char *kname, void *kvalue, size_t size)
> +{
> +	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
> +		return;
> +	kname += XATTR_SYSTEM_PREFIX_LEN;
> +	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
> +	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
> +		posix_acl_fix_xattr_from_user(kvalue, size);
> +}
>  
>  /*
>   * Extended attribute SET operations
> @@ -329,9 +339,7 @@ setxattr(struct dentry *d, const char __user *name, const void __user *value,
>  			error = -EFAULT;
>  			goto out;
>  		}
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_from_user(kvalue, size);
> +		fix_xattr_from_user(kname, kvalue, size);
>  	}
>  
>  	error = vfs_setxattr(d, kname, kvalue, size, flags);
> @@ -396,6 +404,17 @@ SYSCALL_DEFINE5(fsetxattr, int, fd, const char __user *, name,
>  	return error;
>  }
>  
> +static void
> +fix_xattr_to_user(const char *kname, void *kvalue, size_t size)
> +{
> +	if (strncmp(kname, XATTR_SYSTEM_PREFIX, XATTR_SYSTEM_PREFIX_LEN))
> +		return;
> +	kname += XATTR_SYSTEM_PREFIX_LEN;
> +	if (!strcmp(kname, XATTR_POSIX_ACL_ACCESS) ||
> +	    !strcmp(kname, XATTR_POSIX_ACL_DEFAULT))
> +		posix_acl_fix_xattr_to_user(kvalue, size);
> +}
> +
>  /*
>   * Extended attribute GET operations
>   */
> @@ -426,9 +445,7 @@ getxattr(struct dentry *d, const char __user *name, void __user *value,
>  
>  	error = vfs_getxattr(d, kname, kvalue, size);
>  	if (error > 0) {
> -		if ((strcmp(kname, XATTR_NAME_POSIX_ACL_ACCESS) == 0) ||
> -		    (strcmp(kname, XATTR_NAME_POSIX_ACL_DEFAULT) == 0))
> -			posix_acl_fix_xattr_to_user(kvalue, size);
> +		fix_xattr_to_user(kname, kvalue, size);
>  		if (size && copy_to_user(value, kvalue, error))
>  			error = -EFAULT;
>  	} else if (error == -ERANGE && size >= XATTR_SIZE_MAX) {

Might be nice to move this one to the head of the queue. I don't see it
as being a controversial change, and it could go in before the rest of
the patches.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
