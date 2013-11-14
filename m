Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:33094 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab3KNRAi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 12:00:38 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131114165042.013211118@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 12:00:06 -0500
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <71EA5383-5AAD-4BDE-B93A-BEE22D691CD8@oracle.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.013211118@bombadil.infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph-

On Nov 14, 2013, at 11:50 AM, Christoph Hellwig <hch@infradead.org> wrote:

> We'll need the i_mutex to prevent i_dio_count from incrementing while
> truncate is waiting for it to reach zero, and protects against having
> the pagecache repopulated after we flushed it.

How was the performance impact of this change measured?


> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/nfs/direct.c |   14 ++++++++++++--
> 1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index c32db2a..6cc7fe1 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -500,16 +500,17 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
> 	if (!count)
> 		goto out;
> 
> +	mutex_lock(&inode->i_mutex);
> 	result = nfs_sync_mapping(mapping);
> 	if (result)
> -		goto out;
> +		goto out_unlock;
> 
> 	task_io_account_read(count);
> 
> 	result = -ENOMEM;
> 	dreq = nfs_direct_req_alloc();
> 	if (dreq == NULL)
> -		goto out;
> +		goto out_unlock;
> 
> 	dreq->inode = inode;
> 	dreq->bytes_left = iov_length(iov, nr_segs);
> @@ -525,13 +526,22 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
> 
> 	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
> 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos, uio);
> +
> +	mutex_unlock(&inode->i_mutex);
> +
> 	if (!result) {
> 		result = nfs_direct_wait(dreq);
> 		if (result > 0)
> 			iocb->ki_pos = pos + result;
> 	}
> +
> +	nfs_direct_req_release(dreq);
> +	return result;
> +
> out_release:
> 	nfs_direct_req_release(dreq);
> +out_unlock:
> +	mutex_unlock(&inode->i_mutex);
> out:
> 	return result;
> }
> -- 
> 1.7.10.4
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




