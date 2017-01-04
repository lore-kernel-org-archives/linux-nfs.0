Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53968 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968693AbdADRrC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 12:47:02 -0500
Date: Wed, 4 Jan 2017 12:14:28 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 3/3 v2] NFSD: Remove unused value inode in nfsd_vfs_write
Message-ID: <20170104171428.GB17649@fieldses.org>
References: <9a495047-179e-180b-2482-c413ae614d7d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9a495047-179e-180b-2482-c413ae614d7d@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These three look fine, thanks.--b.

On Sat, Dec 31, 2016 at 09:00:21PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/vfs.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index d1d4a11..2c13216 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -943,7 +943,6 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  				unsigned long *cnt, int stable)
>  {
>  	struct svc_export	*exp;
> -	struct inode		*inode;
>  	mm_segment_t		oldfs;
>  	__be32			err = 0;
>  	int			host_err;
> @@ -961,9 +960,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  		 */
>  		current->flags |= PF_LESS_THROTTLE;
>  
> -	inode = file_inode(file);
> -	exp   = fhp->fh_export;
> -
> +	exp = fhp->fh_export;
>  	use_wgather = (rqstp->rq_vers == 2) && EX_WGATHER(exp);
>  
>  	if (!EX_ISSYNC(exp))
> -- 
> 2.9.3
