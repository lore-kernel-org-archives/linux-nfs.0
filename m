Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:46658 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754021AbdE0ITq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 May 2017 04:19:46 -0400
Date: Sat, 27 May 2017 10:19:44 +0200
From: Christoph Hellwig <hch@lst.de>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 06/10] fs: set kernel address limit in
        do_loop_readv_writev
Message-ID: <20170527081944.GA31189@lst.de>
References: <20170527081654.15957-1-hch@lst.de> <20170527081654.15957-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170527081654.15957-7-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Arg.  This patch has been NAKed by Al, but got stuck in the series.
It's not actually needed by the latter patches and can be discarded.

On Sat, May 27, 2017 at 11:16:50AM +0300, Christoph Hellwig wrote:
> This will allow to use all iov_iter based read/write for ITER_KVEC
> without having to check if the file has the iter version of the
> read/write ops, which will allow us to get rid of a large number
> of get_fs/set_fs calls in drivers.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/read_write.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 64b61a032a56..60c64a996ab2 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -704,9 +704,18 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
>  		loff_t *ppos, int type, int flags)
>  {
>  	ssize_t ret = 0;
> +	mm_segment_t uninitialized_var(old_fs);
>  
>  	if (flags & ~RWF_HIPRI)
>  		return -EOPNOTSUPP;
> +	if (iter->type & (ITER_BVEC | ITER_PIPE))
> +		return -EOPNOTSUPP;
> +
> +	/* adjust the address limit for in-kernel I/O */
> +	if (iter->type & ITER_KVEC) {
> +		old_fs = get_fs();
> +		set_fs(get_ds());
> +	}
>  
>  	while (iov_iter_count(iter)) {
>  		struct iovec iovec = iov_iter_iovec(iter);
> @@ -731,6 +740,8 @@ static ssize_t do_loop_readv_writev(struct file *filp, struct iov_iter *iter,
>  		iov_iter_advance(iter, nr);
>  	}
>  
> +	if (iter->type & ITER_KVEC)
> +		set_fs(old_fs);
>  	return ret;
>  }
>  
> -- 
> 2.11.0
---end quoted text---
