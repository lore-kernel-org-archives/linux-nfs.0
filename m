Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:24875 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759707Ab3EWWPi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2013 18:15:38 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Scott Mayhew <smayhew@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 1/1] NFS: Allow nfs_updatepage to extend a write to
 cover a full page when we have a lock that covers the entire file
Date: Thu, 23 May 2013 22:15:34 +0000
Message-ID: <1369347328.8861.6.camel@leira.trondhjem.org>
References: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
	 <1369346021-20041-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1369346021-20041-2-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Scott,

On Thu, 2013-05-23 at 17:53 -0400, Scott Mayhew wrote:
> Currently nfs_updatepage allows a write to be extended to cover a full
> page only if we don't have a byte range lock on the file... but if we've
> got the whole file locked, then we should be allowed to extend the
> write.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  fs/nfs/write.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index a2c7c28..f35fb4f 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -908,13 +908,16 @@ int nfs_updatepage(struct file *file, struct page *page,
>  		file->f_path.dentry->d_name.name, count,
>  		(long long)(page_file_offset(page) + offset));
>  
> -	/* If we're not using byte range locks, and we know the page
> +	/* If we're not using byte range locks (or if the range of the
> +	 * lock covers the entire file), and we know the page
>  	 * is up to date, it may be more efficient to extend the write
>  	 * to cover the entire page in order to avoid fragmentation
>  	 * inefficiencies.
>  	 */
>  	if (nfs_write_pageuptodate(page, inode) &&
> -			inode->i_flock == NULL &&
> +			(inode->i_flock == NULL ||
> +			(inode->i_flock->fl_start == 0 &&
> +			inode->i_flock->fl_end == OFFSET_MAX)) &&
>  			!(file->f_flags & O_DSYNC)) {

Can we put this condition into a helper function? I started with the
"nfs_write_pageuptodate()" thingy, but now we're starting to add in
extra complications...

Thanks!
  Trond

>  		count = max(count + offset, nfs_page_length(page));
>  		offset = 0;


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
