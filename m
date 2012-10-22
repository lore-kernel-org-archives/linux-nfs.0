Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9352 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913Ab2JVPp3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 11:45:29 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Dave Kleikamp <dave.kleikamp@oracle.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 20/22] nfs: add support for read_iter, write_iter
Date: Mon, 22 Oct 2012 15:21:38 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA909288AFD@SACEXCMBX04-PRD.hq.netapp.com>
References: <1350918922-6096-1-git-send-email-dave.kleikamp@oracle.com>
 <1350918922-6096-21-git-send-email-dave.kleikamp@oracle.com>
In-Reply-To: <1350918922-6096-21-git-send-email-dave.kleikamp@oracle.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Dave Kleikamp [mailto:dave.kleikamp@oracle.com]
> Sent: Monday, October 22, 2012 11:15 AM
> To: linux-fsdevel@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org; Zach Brown; Maxim V. Patlasov; Dave
> Kleikamp; Myklebust, Trond; linux-nfs@vger.kernel.org
> Subject: [PATCH 20/22] nfs: add support for read_iter, write_iter
> 
> This patch implements the read_iter and write_iter file operations which
> allow kernel code to initiate directIO. This allows the loop device to read and
> write directly to the server, bypassing the page cache.
> 
> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
> Cc: Zach Brown <zab@zabbo.net>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> ---
>  fs/nfs/direct.c        | 169 +++++++++++++++++++++++++++++++++-----------
> -----
>  fs/nfs/file.c          |  48 ++++++++++----
>  fs/nfs/internal.h      |   2 +
>  fs/nfs/nfs4file.c      |   2 +
>  include/linux/nfs_fs.h |   6 +-
>  5 files changed, 155 insertions(+), 72 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c index 4532781..b1fda1c 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -90,6 +90,7 @@ struct nfs_direct_req {
>  	int			flags;
>  #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply
> was received */
>  #define NFS_ODIRECT_RESCHED_WRITES	(2)	/* write verification
> failed */
> +#define NFS_ODIRECT_MARK_DIRTY		(4)	/* mark read pages
> dirty */
>  	struct nfs_writeverf	verf;		/* unstable write verifier */
>  };
> 
> @@ -131,15 +132,13 @@ ssize_t nfs_direct_IO(int rw, struct kiocb *iocb,
> struct iov_iter *iter,
> 
>  	return -EINVAL;
>  #else
> -	const struct iovec *iov = iov_iter_iovec(iter);
> -
>  	VM_BUG_ON(iocb->ki_left != PAGE_SIZE);
>  	VM_BUG_ON(iocb->ki_nbytes != PAGE_SIZE);
> 
>  	if (rw == READ || rw == KERNEL_READ)
> -		return nfs_file_direct_read(iocb, iov, iter->nr_segs, pos,
> +		return nfs_file_direct_read(iocb, iter, pos,
>  				rw == READ ? true : false);
> -	return nfs_file_direct_write(iocb, iov, iter->nr_segs, pos,
> +	return nfs_file_direct_write(iocb, iter, pos,
>  				rw == WRITE ? true : false);
>  #endif /* CONFIG_NFS_SWAP */
>  }
> @@ -277,7 +276,8 @@ static void nfs_direct_read_completion(struct
> nfs_pgio_header *hdr)
>  					hdr->good_bytes & ~PAGE_MASK,
>  					PAGE_SIZE);
>  		}
> -		if (!PageCompound(page)) {
> +		if ((dreq->flags & NFS_ODIRECT_MARK_DIRTY) &&
> +		    !PageCompound(page)) {
>  			if (test_bit(NFS_IOHDR_ERROR, &hdr->flags)) {
>  				if (bytes < hdr->good_bytes)
>  					set_page_dirty(page);
> @@ -414,10 +414,9 @@ static ssize_t
> nfs_direct_read_schedule_segment(struct nfs_pageio_descriptor *de
>  	return result < 0 ? (ssize_t) result : -EFAULT;  }
> 
> -static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
> -					      const struct iovec *iov,
> -					      unsigned long nr_segs,
> -					      loff_t pos, bool uio)
> +static ssize_t nfs_direct_read_schedule(struct nfs_direct_req *dreq,
> +					struct iov_iter *iter, loff_t pos,
> +					bool uio)
>  {
>  	struct nfs_pageio_descriptor desc;
>  	ssize_t result = -EINVAL;
> @@ -429,16 +428,47 @@ static ssize_t
> nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
>  	get_dreq(dreq);
>  	desc.pg_dreq = dreq;
> 
> -	for (seg = 0; seg < nr_segs; seg++) {
> -		const struct iovec *vec = &iov[seg];
> -		result = nfs_direct_read_schedule_segment(&desc, vec,
> pos, uio);
> -		if (result < 0)
> -			break;
> -		requested_bytes += result;
> -		if ((size_t)result < vec->iov_len)
> -			break;
> -		pos += vec->iov_len;
> -	}
> +	if (iov_iter_has_iovec(iter)) {
> +		const struct iovec *iov = iov_iter_iovec(iter);
> +		if (uio)
> +			dreq->flags = NFS_ODIRECT_MARK_DIRTY;
> +		for (seg = 0; seg < iter->nr_segs; seg++) {
> +			const struct iovec *vec = &iov[seg];
> +			result = nfs_direct_read_schedule_segment(&desc,
> vec,
> +								  pos, uio);
> +			if (result < 0)
> +				break;
> +			requested_bytes += result;
> +			if ((size_t)result < vec->iov_len)
> +				break;
> +			pos += vec->iov_len;
> +		}
> +	} else if (iov_iter_has_bvec(iter)) {
> +		struct nfs_open_context *ctx = dreq->ctx;
> +		struct inode *inode = ctx->dentry->d_inode;
> +		struct bio_vec *bvec = iov_iter_bvec(iter);
> +		for (seg = 0; seg < iter->nr_segs; seg++) {
> +			struct nfs_page *req;
> +			unsigned int req_len = bvec[seg].bv_len;
> +			req = nfs_create_request(ctx, inode,
> +						 bvec[seg].bv_page,
> +						 bvec[seg].bv_offset,
> req_len);
> +			if (IS_ERR(req)) {
> +				result = PTR_ERR(req);
> +				break;
> +			}
> +			req->wb_index = pos >> PAGE_SHIFT;
> +			req->wb_offset = pos & ~PAGE_MASK;
> +			if (!nfs_pageio_add_request(&desc, req)) {
> +				result = desc.pg_error;
> +				nfs_release_request(req);
> +				break;
> +			}
> +			requested_bytes += req_len;
> +			pos += req_len;
> +		}
> +	} else
> +		BUG();

Can we please split the contents of these 2 if statements into 2 helper functions  nfs_direct_do_schedule_read_iovec() and nfs_direct_do_schedule_read_bvec()?

> 
>  	nfs_pageio_complete(&desc);
> 
> @@ -456,8 +486,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct
> nfs_direct_req *dreq,
>  	return 0;
>  }
> 
> -static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
> -			       unsigned long nr_segs, loff_t pos, bool uio)
> +static ssize_t nfs_direct_read(struct kiocb *iocb, struct iov_iter *iter,
> +			       loff_t pos, bool uio)
>  {
>  	ssize_t result = -ENOMEM;
>  	struct inode *inode = iocb->ki_filp->f_mapping->host; @@ -469,7
> +499,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct
> iovec *iov,
>  		goto out;
> 
>  	dreq->inode = inode;
> -	dreq->bytes_left = iov_length(iov, nr_segs);
> +	dreq->bytes_left = iov_iter_count(iter);
>  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb-
> >ki_filp));
>  	l_ctx = nfs_get_lock_context(dreq->ctx);
>  	if (IS_ERR(l_ctx)) {
> @@ -480,8 +510,8 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const
> struct iovec *iov,
>  	if (!is_sync_kiocb(iocb))
>  		dreq->iocb = iocb;
> 
> -	NFS_I(inode)->read_io += iov_length(iov, nr_segs);
> -	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos,
> uio);
> +	NFS_I(inode)->read_io += iov_iter_count(iter);
> +	result = nfs_direct_read_schedule(dreq, iter, pos, uio);
>  	if (!result)
>  		result = nfs_direct_wait(dreq);
>  out_release:
> @@ -815,10 +845,9 @@ static const struct nfs_pgio_completion_ops
> nfs_direct_write_completion_ops = {
>  	.completion = nfs_direct_write_completion,  };
> 
> -static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> -					       const struct iovec *iov,
> -					       unsigned long nr_segs,
> -					       loff_t pos, bool uio)
> +static ssize_t nfs_direct_write_schedule(struct nfs_direct_req *dreq,
> +					 struct iov_iter *iter, loff_t pos,
> +					 bool uio)
>  {
>  	struct nfs_pageio_descriptor desc;
>  	struct inode *inode = dreq->inode;
> @@ -832,17 +861,48 @@ static ssize_t
> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
>  	get_dreq(dreq);
>  	atomic_inc(&inode->i_dio_count);
> 
> -	NFS_I(dreq->inode)->write_io += iov_length(iov, nr_segs);
> -	for (seg = 0; seg < nr_segs; seg++) {
> -		const struct iovec *vec = &iov[seg];
> -		result = nfs_direct_write_schedule_segment(&desc, vec,
> pos, uio);
> -		if (result < 0)
> -			break;
> -		requested_bytes += result;
> -		if ((size_t)result < vec->iov_len)
> -			break;
> -		pos += vec->iov_len;
> -	}
> +	NFS_I(dreq->inode)->write_io += iov_iter_count(iter);
> +
> +	if (iov_iter_has_iovec(iter)) {
> +		const struct iovec *iov = iov_iter_iovec(iter);
> +		for (seg = 0; seg < iter->nr_segs; seg++) {
> +			const struct iovec *vec = &iov[seg];
> +			result = nfs_direct_write_schedule_segment(&desc,
> vec,
> +								   pos, uio);
> +			if (result < 0)
> +				break;
> +			requested_bytes += result;
> +			if ((size_t)result < vec->iov_len)
> +				break;
> +			pos += vec->iov_len;
> +		}
> +	} else if (iov_iter_has_bvec(iter)) {
> +		struct nfs_open_context *ctx = dreq->ctx;
> +		struct bio_vec *bvec = iov_iter_bvec(iter);
> +		for (seg = 0; seg < iter->nr_segs; seg++) {
> +			struct nfs_page *req;
> +			unsigned int req_len = bvec[seg].bv_len;
> +
> +			req = nfs_create_request(ctx, inode,
> bvec[seg].bv_page,
> +						 bvec[seg].bv_offset,
> req_len);
> +			if (IS_ERR(req)) {
> +				result = PTR_ERR(req);
> +				break;
> +			}
> +			nfs_lock_request(req);
> +			req->wb_index = pos >> PAGE_SHIFT;
> +			req->wb_offset = pos & ~PAGE_MASK;
> +			if (!nfs_pageio_add_request(&desc, req)) {
> +				result = desc.pg_error;
> +				nfs_unlock_and_release_request(req);
> +				break;
> +			}
> +			requested_bytes += req_len;
> +			pos += req_len;
> +		}
> +	} else
> +		BUG();

Ditto...

> +
>  	nfs_pageio_complete(&desc);
> 
>  	/*
> @@ -860,9 +920,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct
> nfs_direct_req *dreq,
>  	return 0;
>  }
> 
> -static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
> -				unsigned long nr_segs, loff_t pos,
> -				size_t count, bool uio)
> +static ssize_t nfs_direct_write(struct kiocb *iocb, struct iov_iter *iter,
> +				loff_t pos, bool uio)
>  {
>  	ssize_t result = -ENOMEM;
>  	struct inode *inode = iocb->ki_filp->f_mapping->host; @@ -874,7
> +933,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct
> iovec *iov,
>  		goto out;
> 
>  	dreq->inode = inode;
> -	dreq->bytes_left = count;
> +	dreq->bytes_left = iov_iter_count(iter);
>  	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb-
> >ki_filp));
>  	l_ctx = nfs_get_lock_context(dreq->ctx);
>  	if (IS_ERR(l_ctx)) {
> @@ -885,7 +944,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb,
> const struct iovec *iov,
>  	if (!is_sync_kiocb(iocb))
>  		dreq->iocb = iocb;
> 
> -	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos,
> uio);
> +	result = nfs_direct_write_schedule(dreq, iter, pos, uio);
>  	if (!result)
>  		result = nfs_direct_wait(dreq);
>  out_release:
> @@ -897,8 +956,7 @@ out:
>  /**
>   * nfs_file_direct_read - file direct read operation for NFS files
>   * @iocb: target I/O control block
> - * @iov: vector of user buffers into which to read data
> - * @nr_segs: size of iov vector
> + * @iter: vector of buffers into which to read data
>   * @pos: byte offset in file where reading starts
>   *
>   * We use this function for direct reads instead of calling @@ -915,15 +973,15
> @@ out:
>   * client must read the updated atime from the server back into its
>   * cache.
>   */
> -ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec *iov,
> -				unsigned long nr_segs, loff_t pos, bool uio)
> +ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter,
> +			     loff_t pos, bool uio)
>  {
>  	ssize_t retval = -EINVAL;
>  	struct file *file = iocb->ki_filp;
>  	struct address_space *mapping = file->f_mapping;
>  	size_t count;
> 
> -	count = iov_length(iov, nr_segs);
> +	count = iov_iter_count(iter);
>  	nfs_add_stats(mapping->host, NFSIOS_DIRECTREADBYTES, count);
> 
>  	dfprintk(FILE, "NFS: direct read(%s/%s, %zd@%Ld)\n", @@ -941,7
> +999,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, const struct iovec
> *iov,
> 
>  	task_io_account_read(count);
> 
> -	retval = nfs_direct_read(iocb, iov, nr_segs, pos, uio);
> +	retval = nfs_direct_read(iocb, iter, pos, uio);
>  	if (retval > 0)
>  		iocb->ki_pos = pos + retval;
> 
> @@ -952,8 +1010,7 @@ out:
>  /**
>   * nfs_file_direct_write - file direct write operation for NFS files
>   * @iocb: target I/O control block
> - * @iov: vector of user buffers from which to write data
> - * @nr_segs: size of iov vector
> + * @iter: vector of buffers from which to write data
>   * @pos: byte offset in file where writing starts
>   *
>   * We use this function for direct writes instead of calling @@ -971,15
> +1028,15 @@ out:
>   * Note that O_APPEND is not supported for NFS direct writes, as there
>   * is no atomic O_APPEND write facility in the NFS protocol.
>   */
> -ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct iovec *iov,
> -				unsigned long nr_segs, loff_t pos, bool uio)
> +ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter,
> +			      loff_t pos, bool uio)
>  {
>  	ssize_t retval = -EINVAL;
>  	struct file *file = iocb->ki_filp;
>  	struct address_space *mapping = file->f_mapping;
>  	size_t count;
> 
> -	count = iov_length(iov, nr_segs);
> +	count = iov_iter_count(iter);
>  	nfs_add_stats(mapping->host, NFSIOS_DIRECTWRITTENBYTES,
> count);
> 
>  	dfprintk(FILE, "NFS: direct write(%s/%s, %zd@%Ld)\n", @@ -1004,7
> +1061,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, const struct
> iovec *iov,
> 
>  	task_io_account_write(count);
> 
> -	retval = nfs_direct_write(iocb, iov, nr_segs, pos, count, uio);
> +	retval = nfs_direct_write(iocb, iter, pos, uio);
>  	if (retval > 0) {
>  		struct inode *inode = mapping->host;
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c index 582bb88..b4bf6ef 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -172,28 +172,39 @@ nfs_file_flush(struct file *file, fl_owner_t id)
> EXPORT_SYMBOL_GPL(nfs_file_flush);
> 
>  ssize_t
> -nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
> -		unsigned long nr_segs, loff_t pos)
> +nfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter, loff_t
> +pos)
>  {
>  	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
>  	struct inode * inode = dentry->d_inode;
>  	ssize_t result;
> 
>  	if (iocb->ki_filp->f_flags & O_DIRECT)
> -		return nfs_file_direct_read(iocb, iov, nr_segs, pos, true);
> +		return nfs_file_direct_read(iocb, iter, pos, true);
> 
> -	dprintk("NFS: read(%s/%s, %lu@%lu)\n",
> +	dprintk("NFS: read_iter(%s/%s, %lu@%lu)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name,
> -		(unsigned long) iov_length(iov, nr_segs), (unsigned long)
> pos);
> +		(unsigned long) iov_iter_count(iter), (unsigned long) pos);
> 
>  	result = nfs_revalidate_mapping(inode, iocb->ki_filp->f_mapping);
>  	if (!result) {
> -		result = generic_file_aio_read(iocb, iov, nr_segs, pos);
> +		result = generic_file_read_iter(iocb, iter, pos);
>  		if (result > 0)
>  			nfs_add_stats(inode, NFSIOS_NORMALREADBYTES,
> result);
>  	}
>  	return result;
>  }
> +EXPORT_SYMBOL_GPL(nfs_file_read_iter);
> +
> +ssize_t
> +nfs_file_read(struct kiocb *iocb, const struct iovec *iov,
> +		unsigned long nr_segs, loff_t pos)
> +{
> +	struct iov_iter iter;
> +
> +	iov_iter_init(&iter, iov, nr_segs, iov_length(iov, nr_segs), 0);
> +
> +	return nfs_file_read_iter(iocb, &iter, pos); }
>  EXPORT_SYMBOL_GPL(nfs_file_read);
> 
>  ssize_t
> @@ -610,19 +621,19 @@ static int nfs_need_sync_write(struct file *filp,
> struct inode *inode)
>  	return 0;
>  }
> 
> -ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
> -		       unsigned long nr_segs, loff_t pos)
> +ssize_t nfs_file_write_iter(struct kiocb *iocb, struct iov_iter *iter,
> +				   loff_t pos)
>  {
>  	struct dentry * dentry = iocb->ki_filp->f_path.dentry;
>  	struct inode * inode = dentry->d_inode;
>  	unsigned long written = 0;
>  	ssize_t result;
> -	size_t count = iov_length(iov, nr_segs);
> +	size_t count = iov_iter_count(iter);
> 
>  	if (iocb->ki_filp->f_flags & O_DIRECT)
> -		return nfs_file_direct_write(iocb, iov, nr_segs, pos, true);
> +		return nfs_file_direct_write(iocb, iter, pos, true);
> 
> -	dprintk("NFS: write(%s/%s, %lu@%Ld)\n",
> +	dprintk("NFS: write_iter(%s/%s, %lu@%lld)\n",
>  		dentry->d_parent->d_name.name, dentry->d_name.name,
>  		(unsigned long) count, (long long) pos);
> 
> @@ -642,7 +653,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, const struct
> iovec *iov,
>  	if (!count)
>  		goto out;
> 
> -	result = generic_file_aio_write(iocb, iov, nr_segs, pos);
> +	result = generic_file_write_iter(iocb, iter, pos);
>  	if (result > 0)
>  		written = result;
> 
> @@ -661,6 +672,17 @@ out_swapfile:
>  	printk(KERN_INFO "NFS: attempt to write to active swap file!\n");
>  	goto out;
>  }
> +EXPORT_SYMBOL_GPL(nfs_file_write_iter);
> +
> +ssize_t nfs_file_write(struct kiocb *iocb, const struct iovec *iov,
> +		       unsigned long nr_segs, loff_t pos) {
> +	struct iov_iter iter;
> +
> +	iov_iter_init(&iter, iov, nr_segs, iov_length(iov, nr_segs), 0);
> +
> +	return nfs_file_write_iter(iocb, &iter, pos); }
>  EXPORT_SYMBOL_GPL(nfs_file_write);
> 
>  ssize_t nfs_file_splice_write(struct pipe_inode_info *pipe, @@ -914,6
> +936,8 @@ const struct file_operations nfs_file_operations = {
>  	.write		= do_sync_write,
>  	.aio_read	= nfs_file_read,
>  	.aio_write	= nfs_file_write,
> +	.read_iter	= nfs_file_read_iter,
> +	.write_iter	= nfs_file_write_iter,
>  	.mmap		= nfs_file_mmap,
>  	.open		= nfs_file_open,
>  	.flush		= nfs_file_flush,
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h index 59b133c..8db3b11
> 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -302,10 +302,12 @@ int nfs_file_fsync_commit(struct file *, loff_t,
> loff_t, int);  loff_t nfs_file_llseek(struct file *, loff_t, int);  int
> nfs_file_flush(struct file *, fl_owner_t);  ssize_t nfs_file_read(struct kiocb *,
> const struct iovec *, unsigned long, loff_t);
> +ssize_t nfs_file_read_iter(struct kiocb *, struct iov_iter *, loff_t);
>  ssize_t nfs_file_splice_read(struct file *, loff_t *, struct pipe_inode_info *,
>  			     size_t, unsigned int);
>  int nfs_file_mmap(struct file *, struct vm_area_struct *);  ssize_t
> nfs_file_write(struct kiocb *, const struct iovec *, unsigned long, loff_t);
> +ssize_t nfs_file_write_iter(struct kiocb *, struct iov_iter *, loff_t);
>  int nfs_file_release(struct inode *, struct file *);  int nfs_lock(struct file *, int,
> struct file_lock *);  int nfs_flock(struct file *, int, struct file_lock *); diff --git
> a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c index afddd66..195188e 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -123,6 +123,8 @@ const struct file_operations nfs4_file_operations = {
>  	.write		= do_sync_write,
>  	.aio_read	= nfs_file_read,
>  	.aio_write	= nfs_file_write,
> +	.read_iter	= nfs_file_read_iter,
> +	.write_iter	= nfs_file_write_iter,
>  	.mmap		= nfs_file_mmap,
>  	.open		= nfs4_file_open,
>  	.flush		= nfs_file_flush,
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h index
> 4913e3c..9f8e8a9 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -445,11 +445,9 @@ extern int nfs3_removexattr (struct dentry *, const
> char *name);
>   * linux/fs/nfs/direct.c
>   */
>  extern ssize_t nfs_direct_IO(int, struct kiocb *, struct iov_iter *, loff_t); -
> extern ssize_t nfs_file_direct_read(struct kiocb *iocb,
> -			const struct iovec *iov, unsigned long nr_segs,
> +extern ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter
> +*iter,
>  			loff_t pos, bool uio);
> -extern ssize_t nfs_file_direct_write(struct kiocb *iocb,
> -			const struct iovec *iov, unsigned long nr_segs,
> +extern ssize_t nfs_file_direct_write(struct kiocb *iocb, struct
> +iov_iter *iter,
>  			loff_t pos, bool uio);
> 
>  /*

Otherwise, everything looks fine to me...

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Cheers
  Trond
