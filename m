Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750965Ab3FDOBs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 10:01:48 -0400
Date: Tue, 4 Jun 2013 10:01:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to
 cover a full page when we have a lock that covers the entire file
Message-ID: <20130604100145.13f265b7@corrin.poochiereds.net>
In-Reply-To: <20130604132149.GL55330@tonberry.usersys.redhat.com>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
	<1369346021-20041-2-git-send-email-smayhew@redhat.com>
	<20130523182450.18adbcd8@tlielax.poochiereds.net>
	<1369348209.8861.12.camel@leira.trondhjem.org>
	<20130524072403.6b814585@corrin.poochiereds.net>
	<20130604132149.GL55330@tonberry.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 4 Jun 2013 09:21:49 -0400
Scott Mayhew <smayhew@redhat.com> wrote:


> 
> Currently nfs_updatepage allows a write to be extended to cover a full
> page only if we don't have a byte range lock lock on the file... but if
> we have a write delegation on the file or if we have the whole file
> locked for writing then we should be allowed to extend the write as
> well.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/write.c | 31 +++++++++++++++++++++++--------
>  1 file changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index a2c7c28..c8a1bcc 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -888,6 +888,28 @@ out:
>  	return PageUptodate(page) != 0;
>  }
>  
> +/* If we know the page is up to date, and we're not using byte range locks (or
> + * if we have the whole file locked for writing), it may be more efficient to
> + * extend the write to cover the entire page in order to avoid fragmentation
> + * inefficiencies.
> + *
> + * If the file is opened for synchronous writes or if we have a write delegation
> + * from the server then we can just skip the rest of the checks.
> + */
> +static int nfs_can_extend_write(struct file *file, struct page *page, struct inode *inode)
> +{
> +	if (file->f_flags & O_DSYNC)
> +		return 0;
> +	if (nfs_have_delegation(inode, FMODE_WRITE))
> +		return 1;
> +	if (nfs_write_pageuptodate(page, inode) && (inode->i_flock == NULL ||
> +			(inode->i_flock->fl_start == 0 &&
> +			inode->i_flock->fl_end == OFFSET_MAX &&
> +			inode->i_flock->fl_type != F_RDLCK)))
> +		return 1;
> +	return 0;
> +}
> +
>  /*
>   * Update and possibly write a cached page of an NFS file.
>   *
> @@ -908,14 +930,7 @@ int nfs_updatepage(struct file *file, struct page *page,
>  		file->f_path.dentry->d_name.name, count,
>  		(long long)(page_file_offset(page) + offset));
>  
> -	/* If we're not using byte range locks, and we know the page
> -	 * is up to date, it may be more efficient to extend the write
> -	 * to cover the entire page in order to avoid fragmentation
> -	 * inefficiencies.
> -	 */
> -	if (nfs_write_pageuptodate(page, inode) &&
> -			inode->i_flock == NULL &&
> -			!(file->f_flags & O_DSYNC)) {
> +	if (nfs_can_extend_write(file, page, inode)) {
>  		count = max(count + offset, nfs_page_length(page));
>  		offset = 0;
>  	}

Looks reasonable to me...

Acked-by: Jeff Layton <jlayton@redhat.com>
