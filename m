Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750721AbaATO3S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 09:29:18 -0500
Date: Mon, 20 Jan 2014 09:29:15 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [PATCH] nfs: always make sure page is up-to-date before
 extending a write to cover the entire page
Message-ID: <20140120092915.2dbccf57@tlielax.poochiereds.net>
In-Reply-To: <1389989525-33610-1-git-send-email-smayhew@redhat.com>
References: <1389989525-33610-1-git-send-email-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 17 Jan 2014 15:12:05 -0500
Scott Mayhew <smayhew@redhat.com> wrote:

> We should always make sure the cached page is up-to-date when we're
> determining whether we can extend a write to cover the full page -- even
> if we've received a write delegation from the server.
> 
> Commit c7559663 added logic to skip this check if we have a write
> delegation, which can lead to data corruption such as the following
> scenario if client B receives a write delegation from the NFS server:
> 
> Client A:
>     # echo 123456789 > /mnt/file
> 
> Client B:
>     # echo abcdefghi >> /mnt/file
>     # cat /mnt/file
>     0�D0�abcdefghi
> 
> Just because we hold a write delegation doesn't mean that we've read in
> the entire page contents.
> 
> Cc: <stable@vger.kernel.org> # v3.11+
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/write.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index c1d5482..6a85038 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -922,19 +922,20 @@ out:
>   * extend the write to cover the entire page in order to avoid fragmentation
>   * inefficiencies.
>   *
> - * If the file is opened for synchronous writes or if we have a write delegation
> - * from the server then we can just skip the rest of the checks.
> + * If the file is opened for synchronous writes then we can just skip the rest
> + * of the checks.
>   */
>  static int nfs_can_extend_write(struct file *file, struct page *page, struct inode *inode)
>  {
>  	if (file->f_flags & O_DSYNC)
>  		return 0;
> +	if (!nfs_write_pageuptodate(page, inode))
> +		return 0;
>  	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
>  		return 1;
> -	if (nfs_write_pageuptodate(page, inode) && (inode->i_flock == NULL ||
> -			(inode->i_flock->fl_start == 0 &&
> +	if (inode->i_flock == NULL || (inode->i_flock->fl_start == 0 &&
>  			inode->i_flock->fl_end == OFFSET_MAX &&
> -			inode->i_flock->fl_type != F_RDLCK)))
> +			inode->i_flock->fl_type != F_RDLCK))
>  		return 1;
>  	return 0;
>  }

Makes sense. We can't extend the write unless we know that the page
is uptodate, or we'll potentially be writing uninitialized data.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
