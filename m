Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48020 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750922AbdE3SDW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 14:03:22 -0400
Date: Tue, 30 May 2017 14:03:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 10/10] nfsd: remove nfsd_vfs_read
Message-ID: <20170530180321.GI18523@fieldses.org>
References: <20170527081654.15957-1-hch@lst.de>
 <20170527081654.15957-11-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170527081654.15957-11-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK.--b.

On Sat, May 27, 2017 at 11:16:54AM +0300, Christoph Hellwig wrote:
> Simpler done in the only caller.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/vfs.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 37a03c456b38..0d19ab1b9404 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -920,16 +920,6 @@ __be32 nfsd_readv(struct file *file, loff_t offset, struct kvec *vec, int vlen,
>  	return nfsd_finish_read(file, count, host_err);
>  }
>  
> -static __be32
> -nfsd_vfs_read(struct svc_rqst *rqstp, struct file *file,
> -	      loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
> -{
> -	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
> -		return nfsd_splice_read(rqstp, file, offset, count);
> -	else
> -		return nfsd_readv(file, offset, vec, vlen, count);
> -}
> -
>  /*
>   * Gathered writes: If another process is currently writing to the file,
>   * there's a high chance this is another nfsd (triggered by a bulk write
> @@ -1041,7 +1031,12 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	ra = nfsd_init_raparms(file);
>  
>  	trace_read_opened(rqstp, fhp, offset, vlen);
> -	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
> +
> +	if (file->f_op->splice_read && test_bit(RQ_SPLICE_OK, &rqstp->rq_flags))
> +		err = nfsd_splice_read(rqstp, file, offset, count);
> +	else
> +		err = nfsd_readv(file, offset, vec, vlen, count);
> +
>  	trace_read_io_done(rqstp, fhp, offset, vlen);
>  
>  	if (ra)
> -- 
> 2.11.0
