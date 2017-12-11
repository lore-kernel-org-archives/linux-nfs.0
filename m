Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35806 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751543AbdLKQIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 11:08:25 -0500
Date: Mon, 11 Dec 2017 11:08:25 -0500
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH 4/4] fhandle: Improve error responses in
 name_to_handle_at()
Message-ID: <20171211160825.GA27552@fieldses.org>
References: <151297214390.7818.7216826079527521005.stgit@noble>
 <151297224523.7818.12267549679803980398.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151297224523.7818.12267549679803980398.stgit@noble>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 11, 2017 at 05:04:05PM +1100, NeilBrown wrote:
> 1/ Always return the mnt_id, even if some other error occurs.
>    It can be useful without the file handle.
>    An application can initialise the memory to, e.g. -1
>    and if there is some other value after name_to_handle_at()
>    returns, then it is a valid mnt_id.
>    If the value is unchanged, then the kernel does not
>    have this patch.

That's interesting--not the interface we might have chosen if we were
starting from scratch, but I can't see why it wouldn't work.  OK!
ACK.--b.

> 
> 2/ Don't return -EINVAL if the requested handle_bytes is
>    larger than MAX_HANDLE_SZ.  There is no need for an
>    error and it causes unnecessary behavior change
>    in the kernel ever needs to increase MAX_HANDLE_SZ.
>    Simple limit handle_bytes to MAX_HANDLE_SZ silently.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/fhandle.c |   16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/fhandle.c b/fs/fhandle.c
> index 0ace128f5d23..04afffaeb742 100644
> --- a/fs/fhandle.c
> +++ b/fs/fhandle.c
> @@ -23,9 +23,16 @@ static long do_sys_name_to_handle(struct path *path,
>  	int handle_dwords, handle_bytes;
>  	struct file_handle *handle = NULL;
>  
> +	/*
> +	 * Always return the mnt_id, it might be useful even
> +	 * without the file handle
> +	 */
> +	if (copy_to_user(mnt_id, &real_mount(path->mnt)->mnt_id,
> +			 sizeof(*mnt_id)))
> +		return -EFAULT;
>  	/*
>  	 * We need to make sure whether the file system
> -	 * support decoding of the file handle
> +	 * supports decoding of the file handle.
>  	 */
>  	if (!path->dentry->d_sb->s_export_op ||
>  	    !path->dentry->d_sb->s_export_op->fh_to_dentry)
> @@ -35,7 +42,7 @@ static long do_sys_name_to_handle(struct path *path,
>  		return -EFAULT;
>  
>  	if (f_handle.handle_bytes > MAX_HANDLE_SZ)
> -		return -EINVAL;
> +		f_handle.handle_bytes = MAX_HANDLE_SZ;
>  
>  	handle = kmalloc(sizeof(struct file_handle) + f_handle.handle_bytes,
>  			 GFP_KERNEL);
> @@ -68,10 +75,7 @@ static long do_sys_name_to_handle(struct path *path,
>  		retval = -EOVERFLOW;
>  	} else
>  		retval = 0;
> -	/* copy the mount id */
> -	if (copy_to_user(mnt_id, &real_mount(path->mnt)->mnt_id,
> -			 sizeof(*mnt_id)) ||
> -	    copy_to_user(ufh, handle,
> +	if (copy_to_user(ufh, handle,
>  			 sizeof(struct file_handle) + handle_bytes))
>  		retval = -EFAULT;
>  	kfree(handle);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
