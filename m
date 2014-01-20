Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbaATO0a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 09:26:30 -0500
Subject: Re: [PATCH] nfs: always make sure page is up-to-date before
 extending a write to cover the entire page
From: David Wysochanski <dwysocha@redhat.com>
Reply-To: dwysocha@redhat.com
To: Scott Mayhew <smayhew@redhat.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        stable@vger.kernel.org
In-Reply-To: <1389989525-33610-1-git-send-email-smayhew@redhat.com>
References: <1389989525-33610-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 09:26:28 -0500
Message-ID: <1390227988.3979.7.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-01-17 at 15:12 -0500, Scott Mayhew wrote:
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

Acked-by: Dave Wysochanski <dwysocha@redhat.com>


