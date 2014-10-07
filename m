Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47834 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbaJGMcZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Oct 2014 08:32:25 -0400
Date: Tue, 7 Oct 2014 08:32:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Zach Brown <zab@zabbo.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix inclusive vfs_fsync_range() end
Message-ID: <20141007123224.GA23258@fieldses.org>
References: <1412638972-14617-1-git-send-email-zab@zabbo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412638972-14617-1-git-send-email-zab@zabbo.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 06, 2014 at 04:42:52PM -0700, Zach Brown wrote:
> The vfs_fsync_range() call during write processing got the end of the
> range off by one.  The range is inclusive, not exclusive.  The error has
> nfsd sync more data than requested -- it's correct but unnecessary
> overhead.
> 
> The call during commit processing is correct so I copied that pattern in
> write processing.  Maybe a helper would be nice but I kept it trivial.
> 
> This is untested.  I found it while reviewing code for something else
> entirely.

Makes sense to me, thanks!  Queuing up for 3.19.--b.

> 
> Signed-off-by: Zach Brown <zab@zabbo.net>
> ---
>  fs/nfsd/vfs.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f501a9b..825250e 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -921,6 +921,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	int			stable = *stablep;
>  	int			use_wgather;
>  	loff_t			pos = offset;
> +	loff_t			end = LLONG_MAX;
>  	unsigned int		pflags = current->flags;
>  
>  	if (rqstp->rq_local)
> @@ -952,10 +953,13 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	fsnotify_modify(file);
>  
>  	if (stable) {
> -		if (use_wgather)
> +		if (use_wgather) {
>  			host_err = wait_for_concurrent_writes(file);
> -		else
> -			host_err = vfs_fsync_range(file, offset, offset+*cnt, 0);
> +		} else {
> +			if (*cnt)
> +				end = offset + *cnt - 1;
> +			host_err = vfs_fsync_range(file, offset, end, 0);
> +		}
>  	}
>  
>  out_nfserr:
> -- 
> 1.9.3
> 
