Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab2J3QOh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Oct 2012 12:14:37 -0400
Date: Tue, 30 Oct 2012 12:14:29 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        michael.brantley@deshaw.com, hch@infradead.org, miklos@szeredi.hu,
        pstaubach@exagrid.com
Subject: Re: [PATCH v8 11/32] vfs: make do_unlinkat retry on ESTALE errors
Message-ID: <20121030161429.GD24618@fieldses.org>
References: <1351341219-17837-1-git-send-email-jlayton@redhat.com>
 <1351341219-17837-12-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351341219-17837-12-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 27, 2012 at 08:33:18AM -0400, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/namei.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 7c9bb50..467b9f1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -3446,9 +3446,13 @@ static long do_unlinkat(int dfd, const char __user *pathname)
>  	struct filename *name;
>  	struct dentry *dentry;
>  	struct nameidata nd;
> -	struct inode *inode = NULL;
> +	struct inode *inode;
> +	unsigned int try = 0;
> +	unsigned int lookup_flags = LOOKUP_PARENT;
>  
> -	name = user_path_parent(dfd, pathname, &nd, 0);
> +retry:
> +	inode = NULL;

So, you fail after "inode" was set (say vfs_unlink returned an error)
the first time, then before "inode" was set (lookup_hash returns an
error), and you end up incorrectly doing another iput() the second time
through if you don't reset inode here?

(I think I made the same mistake in another patch, actually....)

--b.

> +	name = user_path_parent(dfd, pathname, &nd, try);
>  	if (IS_ERR(name))
>  		return PTR_ERR(name);
>  
> @@ -3486,6 +3490,10 @@ exit2:
>  exit1:
>  	path_put(&nd.path);
>  	putname(name);
> +	if (retry_estale(error, try++)) {
> +		lookup_flags |= LOOKUP_REVAL;
> +		goto retry;
> +	}
>  	return error;
>  
>  slashes:
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
