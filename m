Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754832Ab3KNSgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Nov 2013 13:36:17 -0500
Date: Thu, 14 Nov 2013 13:35:51 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20131114133551.5d08b5cd@tlielax.poochiereds.net>
In-Reply-To: <20131114165042.205194841@bombadil.infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
	<20131114165042.205194841@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Nov 2013 08:50:34 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> Make sure to properly invalidate the pagecache before performing direct I/O,
> so that no stale pages are left around.  This matches what the generic
> direct I/O code does.  Also take the i_mutex over the direct write submission
> to avoid the lifelock vs truncate waiting for i_dio_count to decrease, and
> to avoid having the pagecache easily repopulated while direct I/O is in
> progrss.  Again matching the generic direct I/O code.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfs/direct.c |   29 +++++++++++++++++++++++++++--
>  1 file changed, 27 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 6cc7fe1..2b778fc 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -939,9 +939,12 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
>  	struct inode *inode = mapping->host;
>  	struct nfs_direct_req *dreq;
>  	struct nfs_lock_context *l_ctx;
> +	loff_t end;
>  	size_t count;
>  
>  	count = iov_length(iov, nr_segs);
> +	end = (pos + count - 1) >> PAGE_CACHE_SHIFT;
> +
>  	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES, count);
>  
>  	dfprintk(FILE, "NFS: direct write(%pD2, %zd@%Ld)\n",
> @@ -958,16 +961,25 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
>  	if (!count)
>  		goto out;
>  
> +	mutex_lock(&inode->i_mutex);
> +
>  	result = nfs_sync_mapping(mapping);
>  	if (result)
> -		goto out;
> +		goto out_unlock;
> +
> +	if (mapping->nrpages) {
> +		result = invalidate_inode_pages2_range(mapping,
> +					pos >> PAGE_CACHE_SHIFT, end);
> +		if (result)
> +			goto out_unlock;
> +	}
>  
>  	task_io_account_write(count);
>  
>  	result = -ENOMEM;
>  	dreq = nfs_direct_req_alloc();
>  	if (!dreq)
> -		goto out;
> +		goto out_unlock;
>  
>  	dreq->inode = inode;
>  	dreq->bytes_left = count;
> @@ -982,6 +994,14 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
>  		dreq->iocb = iocb;
>  
>  	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, uio);
> +	
> +	if (mapping->nrpages) {
> +		invalidate_inode_pages2_range(mapping,
> +					      pos >> PAGE_CACHE_SHIFT, end);
> +	}
> +
> +	mutex_unlock(&inode->i_mutex);
> +
>  	if (!result) {
>  		result = nfs_direct_wait(dreq);
>  		if (result > 0) {
> @@ -994,8 +1014,13 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
>  			spin_unlock(&inode->i_lock);
>  		}
>  	}
> +	nfs_direct_req_release(dreq);
> +	return result;
> +
>  out_release:
>  	nfs_direct_req_release(dreq);
> +out_unlock:
> +	mutex_unlock(&inode->i_mutex);
>  out:
>  	return result;
>  }

Hrm... I started chasing down a bug reported by our QA group last week
that's showing up when you mix DIO writes and buffered reads
(basically, diotest3 in the LTP suite is failing). The bug is marked
private for dumb reasons but I'll see if I can make it public. I'll
also plan to give this series a spin to see if it helps fix that bug...

In any case, the DIO write code calls nfs_zap_mapping after it gets the
WRITE reply. That sets NFS_INO_INVALID_DATA and should prevent buffered
read() calls from getting data out of the cache after the write reply
comes in.

Why is that not sufficient here?

-- 
Jeff Layton <jlayton@redhat.com>
