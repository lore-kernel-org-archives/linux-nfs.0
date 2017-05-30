Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48004 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750821AbdE3SCt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 14:02:49 -0400
Date: Tue, 30 May 2017 14:02:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 09/10] nfsd: use vfs_iter_read/write
Message-ID: <20170530180248.GH18523@fieldses.org>
References: <20170527081654.15957-1-hch@lst.de>
 <20170527081654.15957-10-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170527081654.15957-10-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK.--b.

On Sat, May 27, 2017 at 11:16:53AM +0300, Christoph Hellwig wrote:
> Instead of messing with the address limit to use vfs_read/vfs_writev.
> 
> Note that this requires that exported file implement ->read_iter and
> ->write_iter.  All currently exportable file systems do this.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/vfs.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 2be32955d7f2..37a03c456b38 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -911,13 +911,12 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp,
>  __be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
>  		unsigned long *count)
>  {
> -	mm_segment_t oldfs;
> +	struct iov_iter iter;
>  	int host_err;
>  
> -	oldfs = get_fs();
> -	set_fs(KERNEL_DS);
> -	host_err = vfs_readv(file, (struct iovec __user *)vec, vlen, &offset, 0);
> -	set_fs(oldfs);
> +	iov_iter_kvec(&iter, READ | ITER_KVEC, vec, vlen, *count);
> +	host_err = vfs_iter_read(file, &iter, &offset, 0);
> +
>  	return nfsd_finish_read(file, count, host_err);
>  }
>  
> @@ -974,7 +973,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  				unsigned long *cnt, int stable)
>  {
>  	struct svc_export	*exp;
> -	mm_segment_t		oldfs;
> +	struct iov_iter		iter;
>  	__be32			err = 0;
>  	int			host_err;
>  	int			use_wgather;
> @@ -1000,10 +999,8 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	if (stable && !use_wgather)
>  		flags |= RWF_SYNC;
>  
> -	/* Write the data. */
> -	oldfs = get_fs(); set_fs(KERNEL_DS);
> -	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &pos, flags);
> -	set_fs(oldfs);
> +	iov_iter_kvec(&iter, WRITE | ITER_KVEC, vec, vlen, *cnt);
> +	host_err = vfs_iter_write(file, &iter, &pos, flags);
>  	if (host_err < 0)
>  		goto out_nfserr;
>  	*cnt = host_err;
> -- 
> 2.11.0
