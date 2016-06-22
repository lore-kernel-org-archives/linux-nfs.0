Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:39347 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751242AbcFVRZB convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 13:25:01 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 10/12] NFS: Do not serialise O_DIRECT reads and writes
Date: Wed, 22 Jun 2016 17:24:50 +0000
Message-ID: <97494C37-23D3-44FA-A9B8-1887E17429D9@primarydata.com>
References: <1466544893-12058-1-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-2-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-3-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <20160622164715.GB16823@infradead.org>
In-Reply-To: <20160622164715.GB16823@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 22, 2016, at 12:47, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Tue, Jun 21, 2016 at 05:34:51PM -0400, Trond Myklebust wrote:
>> Allow dio requests to be scheduled in parallel, but ensuring that they
>> do not conflict with buffered I/O.
> 
> Can you explain why we care about the full direct / bufferd exclusion
> that no other file system seems do be doing?  I would have expected
> something more like the patch below, which follows the XFS locking
> model 1:1.  This passed xfstests with plain NFSv4, haven't done any pNFS
> testing yet:


If we’re going to worry about write atomicity in the buffered I/O case, then we really should also make sure that O_DIRECT writes are atomic w.r.t. page cache updates too. With this locking model, a buffered read() can race with the O_DIRECT write() and get a mixture of old data and new.

> 
> ---
> From 913189e25fc0e7318f077610c0aa8d5c1071c0c8 Mon Sep 17 00:00:00 2001
> From: Christoph Hellwig <hch@lst.de>
> Date: Wed, 22 Jun 2016 18:00:24 +0200
> Subject: nfs: do not serialise O_DIRECT reads and writes
> 
> Currently NFS takes the inode lock exclusive for all direct I/O reads and
> writes, which forces users of direct I/O to be unessecarily synchronized.
> We only need the exclusive lock to invalidate the page cache, and could
> otherwise do with a shared lock to protect against buffered writers and
> truncate.  This also adds the shared lock to buffered reads to provide
> Posix synchronized I/O guarantees for reads after synchronous writes,
> although that change shouldn't be nessecary to allow parallel direct I/O.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/nfs/direct.c | 47 +++++++++++++++++++++++++++++++----------------
> fs/nfs/file.c   |  4 +++-
> 2 files changed, 34 insertions(+), 17 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 979b3c4..8b9c7e95 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -581,10 +581,17 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
> 	if (!count)
> 		goto out;
> 
> -	inode_lock(inode);
> -	result = nfs_sync_mapping(mapping);
> -	if (result)
> -		goto out_unlock;
> +	if (mapping->nrpages) {
> +		inode_lock(inode);

This is unnecessary now that we have a rw_semaphore. You don’t need to take an exclusive lock in order to serialise w.r.t. new writes, and by doing so you end up serialising all reads if there happens to be pages in the page cache. This is true whether or not those pages are dirty.

> +		result = nfs_sync_mapping(mapping);
> +		if (result) {
> +			inode_unlock(inode);
> +			goto out;
> +		}
> +		downgrade_write(&inode->i_rwsem);
> +	} else {
> +		inode_lock_shared(inode);
> +	}
> 
> 	task_io_account_read(count);
> 
> @@ -609,7 +616,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
> 	NFS_I(inode)->read_io += count;
> 	result = nfs_direct_read_schedule_iovec(dreq, iter, iocb->ki_pos);
> 
> -	inode_unlock(inode);
> +	inode_unlock_shared(inode);
> 
> 	if (!result) {
> 		result = nfs_direct_wait(dreq);
> @@ -623,7 +630,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
> out_release:
> 	nfs_direct_req_release(dreq);
> out_unlock:
> -	inode_unlock(inode);
> +	inode_unlock_shared(inode);
> out:
> 	return result;
> }
> @@ -1005,17 +1012,22 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
> 	pos = iocb->ki_pos;
> 	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
> 
> -	inode_lock(inode);
> -
> -	result = nfs_sync_mapping(mapping);
> -	if (result)
> -		goto out_unlock;
> -
> 	if (mapping->nrpages) {
> -		result = invalidate_inode_pages2_range(mapping,
> -					pos >> PAGE_SHIFT, end);
> +		inode_lock(inode);
> +		result = nfs_sync_mapping(mapping);
> 		if (result)
> -			goto out_unlock;
> +			goto out_unlock_exclusive;
> +
> +		if (mapping->nrpages) {
> +			result = invalidate_inode_pages2_range(mapping,
> +					pos >> PAGE_SHIFT, end);
> +			if (result)	
> +				goto out_unlock_exclusive;
> +		}
> +
> +		downgrade_write(&inode->i_rwsem);
> +	} else {
> +		inode_lock_shared(inode);
> 	}
> 
> 	task_io_account_write(iov_iter_count(iter));
> @@ -1045,7 +1057,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
> 					      pos >> PAGE_SHIFT, end);
> 	}
> 
> -	inode_unlock(inode);
> +	inode_unlock_shared(inode);
> 
> 	if (!result) {
> 		result = nfs_direct_wait(dreq);
> @@ -1068,6 +1080,9 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
> out_release:
> 	nfs_direct_req_release(dreq);
> out_unlock:
> +	inode_unlock_shared(inode);
> +	return result;
> +out_unlock_exclusive:
> 	inode_unlock(inode);
> 	return result;
> }
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 717a8d6..719296f 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -170,12 +170,14 @@ nfs_file_read(struct kiocb *iocb, struct iov_iter *to)
> 		iocb->ki_filp,
> 		iov_iter_count(to), (unsigned long) iocb->ki_pos);
> 
> -	result = nfs_revalidate_mapping_protected(inode, iocb->ki_filp->f_mapping);
> +	inode_lock_shared(inode);
> +	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
> 	if (!result) {
> 		result = generic_file_read_iter(iocb, to);
> 		if (result > 0)
> 			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES, result);
> 	}
> +	inode_unlock_shared(inode);
> 	return result;
> }
> EXPORT_SYMBOL_GPL(nfs_file_read);
> -- 
> 2.1.4
> 

