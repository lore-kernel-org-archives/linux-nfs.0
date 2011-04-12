Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54991 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932140Ab1DLPg1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 11:36:27 -0400
Subject: Re: [RFC][PATCH] Vector read/write support for NFS (DIO) client
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1302622335.3877.62.camel@badari-desktop>
Date: Tue, 12 Apr 2011 11:36:20 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <0DC51758-AE6C-4DD2-A959-8C8E701FEA4E@oracle.com>
References: <1302622335.3877.62.camel@badari-desktop>
To: Badari Pulavarty <pbadari@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 12, 2011, at 11:32 AM, Badari Pulavarty wrote:

> Hi,
> 
> We recently ran into serious performance issue with NFS client.
> It turned out that its due to lack of readv/write support for
> NFS (O_DIRECT) client.
> 
> Here is our use-case:
> 
> In our cloud environment, our storage is over NFS. Files
> on NFS are passed as a blockdevices to the guest (using
> O_DIRECT). When guest is doing IO on these block devices,
> they will end up as O_DIRECT writes to NFS (on KVM host).
> 
> QEMU (on the host) gets a vector from virtio-ring and
> submits them. Old versions of QEMU, linearized the vector
> it got from KVM (copied them into a buffer) and submits
> the buffer. So, NFS client always received a single buffer.
> 
> Later versions of QEMU, eliminated this copy and submits
> a vector directly using preadv/pwritev().
> 
> NFS client loops through the vector and submits each
> vector as separate request for each IO < wsize. In our
> case (negotiated wsize=1MB), for 256K IO - we get 64 
> vectors, each 4K. So, we end up submitting 64 4K FILE_SYNC IOs. 
> Server end up doing each 4K synchronously. This causes
> serious performance degrade. We are trying to see if the
> performance improves if we convert IOs to ASYNC - but
> our initial results doesn't look good.
> 
> readv/writev support NFS client for all possible cases is
> hard. Instead, if all vectors are page-aligned and 
> iosizes page-multiple - it fits the current code easily.
> Luckily, QEMU use-case fits these requirements.
> 
> Here is the patch to add this support. Comments ?

Restricting buffer alignment requirements would be an onerous API change, IMO.

If the NFS write path is smart enough not to set FILE_SYNC when there are multiple segments to write, then the problem should be mostly fixed.  I think Jeff Layton already has a patch that does this.

> 
> Thanks,
> Badari
> 
> Special readv/writev support for NFS O_DIRECT. Currently NFS 
> client O_DIRECT read/write iterates over individual elements 
> in the vector and submits the IO and waits for them to finish. 
> If individual IOsize is < r/wsize, each IO will be FILE_SYNC. 
> Server has to finish individual smaller IOs synchronous. This 
> causes serious performance degrade.
> 
> This patch is a special case to submit larger IOs from the client
> only if all the IO buffers are page-aligned and each individual
> IOs are page-multiple + total IO size is < r/wsize. 
> 
> This is the common case for QEMU usage.
> 
> Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
> ---
> fs/nfs/direct.c |  259 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> 1 file changed, 259 insertions(+)
> 
> Index: linux-2.6.38.2/fs/nfs/direct.c
> ===================================================================
> --- linux-2.6.38.2.orig/fs/nfs/direct.c	2011-04-12 10:56:29.374266292 -0400
> +++ linux-2.6.38.2/fs/nfs/direct.c	2011-04-12 11:01:21.883266310 -0400
> @@ -271,6 +271,52 @@ static const struct rpc_call_ops nfs_rea
> 	.rpc_release = nfs_direct_read_release,
> };
> 
> +static int nfs_direct_check_single_io(struct nfs_direct_req *dreq,
> +				      const struct iovec *iov,
> +                                      unsigned long nr_segs, int rw)
> +{
> +	unsigned long seg;
> +	int pages = 0;
> +	struct nfs_open_context *ctx = dreq->ctx;
> +	struct inode *inode = ctx->path.dentry->d_inode;
> +	size_t size;
> +
> +
> +	/* If its a single vector - use old code */
> +	if (nr_segs == 1)
> +		return pages;
> +	/*
> +	 * Check to see if all IO buffers are page-aligned and
> +	 * individual IO sizes are page-multiple.
> +	 * If so, we can submit them in a single IO.
> +	 * Otherwise, use old code
> +	 */
> +	for (seg = 0; seg < nr_segs; seg++) {
> +		unsigned long user_addr = (unsigned long)iov[seg].iov_base;
> +
> +		if ((user_addr & (PAGE_SIZE - 1)) ||
> +			(iov[seg].iov_len & (PAGE_SIZE - 1))) {
> +			pages = 0;
> +			break;
> +		}
> +		pages += (iov[seg].iov_len >> PAGE_SHIFT);
> +	}
> +
> +	if (rw)
> +		size = NFS_SERVER(inode)->wsize;
> +	else
> +		size = NFS_SERVER(inode)->rsize;
> +
> +	/*
> +         * If IOsize > wsize/rsize, we need to split IOs into r/wsize anyway
> +         * - fall back to old code.
> +         */
> +	if (pages > (size >> PAGE_SHIFT))
> +		pages = 0;
> +
> +	return pages;
> +}
> +
> /*
>  * For each rsize'd chunk of the user's buffer, dispatch an NFS READ
>  * operation.  If nfs_readdata_alloc() or get_user_pages() fails,
> @@ -385,6 +431,101 @@ static ssize_t nfs_direct_read_schedule_
> 	return result < 0 ? (ssize_t) result : -EFAULT;
> }
> 
> +/*
> + * Special Case: Efficient readv() support - only if all the IO buffers
> + * in the vector are page-aligned and IO sizes are page-multiple
> + * + total IO size is < rsize. We can map all of the vectors together
> + * and submit them in a single IO instead of operating on single entry
> + * in the vector.
> + */
> +static ssize_t nfs_direct_read_schedule_single_io(struct nfs_direct_req *dreq,
> +						 const struct iovec *iov,
> +						 unsigned long nr_segs,
> +						 int pages,
> +						 loff_t pos)
> +{
> +	struct nfs_open_context *ctx = dreq->ctx;
> +	struct inode *inode = ctx->path.dentry->d_inode;
> +	unsigned long user_addr = (unsigned long)iov->iov_base;
> +	size_t bytes = pages << PAGE_SHIFT;
> +	struct rpc_task *task;
> +	struct rpc_message msg = {
> +		.rpc_cred = ctx->cred,
> +	};
> +	struct rpc_task_setup task_setup_data = {
> +		.rpc_client = NFS_CLIENT(inode),
> +		.rpc_message = &msg,
> +		.callback_ops = &nfs_read_direct_ops,
> +		.workqueue = nfsiod_workqueue,
> +		.flags = RPC_TASK_ASYNC,
> +	};
> +	unsigned int pgbase;
> +	int result;
> +	int seg;
> +	int mapped = 0;
> +	int nr_pages;
> +	ssize_t started = 0;
> +	struct nfs_read_data *data;
> +
> +	result = -ENOMEM;
> +	data = nfs_readdata_alloc(pages);
> +	if (unlikely(!data))
> +		return result;
> +
> +	pgbase = user_addr & ~PAGE_MASK;
> +
> +	for (seg = 0; seg < nr_segs; seg++) {
> +		user_addr = (unsigned long)iov[seg].iov_base;
> +		nr_pages = iov[seg].iov_len >> PAGE_SHIFT;
> +
> +		down_read(&current->mm->mmap_sem);
> +		result = get_user_pages(current, current->mm, user_addr,
> +					nr_pages, 1, 0, &data->pagevec[mapped],
> +					NULL);
> +		up_read(&current->mm->mmap_sem);
> +		if (result < 0) {
> +			/* unmap what is done so far */
> +			nfs_direct_release_pages(data->pagevec, mapped);
> +			nfs_readdata_free(data);
> +			return result;
> +		}
> +		mapped += result;
> +	}
> +
> +	get_dreq(dreq);
> +
> +	data->req = (struct nfs_page *) dreq;
> +	data->inode = inode;
> +	data->cred = msg.rpc_cred;
> +	data->args.fh = NFS_FH(inode);
> +	data->args.context = ctx;
> +	data->args.offset = pos;
> +	data->args.pgbase = pgbase;
> +	data->args.pages = data->pagevec;
> +	data->args.count = bytes;
> +	data->res.fattr = &data->fattr;
> +	data->res.eof = 0;
> +	data->res.count = bytes;
> +	nfs_fattr_init(&data->fattr);
> +
> +	task_setup_data.task = &data->task;
> +	task_setup_data.callback_data = data;
> +	msg.rpc_argp = &data->args;
> +	msg.rpc_resp = &data->res;
> +	NFS_PROTO(inode)->read_setup(data, &msg);
> +
> +	task = rpc_run_task(&task_setup_data);
> +	if (IS_ERR(task))
> +		goto out;
> +	rpc_put_task(task);
> +
> +	started += bytes;
> +out:
> +	if (started)
> +		return started;
> +	return result < 0 ? (ssize_t) result : -EFAULT;
> +}
> +
> static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
> 					      const struct iovec *iov,
> 					      unsigned long nr_segs,
> @@ -396,6 +537,16 @@ static ssize_t nfs_direct_read_schedule_
> 
> 	get_dreq(dreq);
> 
> +	result = nfs_direct_check_single_io(dreq, iov, nr_segs, 0);
> +	if (result) {
> +		result = nfs_direct_read_schedule_single_io(dreq, iov, nr_segs,
> +							result, pos);
> +		if (result < 0)
> +			goto out;
> +		requested_bytes += result;
> +		pos += result;
> +		goto out;
> +	}
> 	for (seg = 0; seg < nr_segs; seg++) {
> 		const struct iovec *vec = &iov[seg];
> 		result = nfs_direct_read_schedule_segment(dreq, vec, pos);
> @@ -416,6 +567,7 @@ static ssize_t nfs_direct_read_schedule_
> 		return result < 0 ? result : -EIO;
> 	}
> 
> +out:
> 	if (put_dreq(dreq))
> 		nfs_direct_complete(dreq);
> 	return 0;
> @@ -821,6 +973,102 @@ static ssize_t nfs_direct_write_schedule
> 	return result < 0 ? (ssize_t) result : -EFAULT;
> }
> 
> +/*
> + * Special Case: Efficient writev() support - only if all the IO buffers
> + * in the vector are page-aligned and IO sizes are page-multiple
> + * + total IO size is < wsize. We can map all of the vectors together
> + * and submit them in a single IO instead of operating on single entry
> + * in the vector.
> + */
> +static ssize_t nfs_direct_write_schedule_single_io(struct nfs_direct_req *dreq,
> +						 const struct iovec *iov,
> +						 unsigned long nr_segs,
> +						 int pages,
> +						 loff_t pos, int sync)
> +{
> +	struct nfs_open_context *ctx = dreq->ctx;
> +	struct inode *inode = ctx->path.dentry->d_inode;
> +	unsigned long user_addr = (unsigned long)iov->iov_base;
> +	size_t bytes = pages << PAGE_SHIFT;
> +	struct rpc_task *task;
> +	struct rpc_message msg = {
> +		.rpc_cred = ctx->cred,
> +	};
> +	struct rpc_task_setup task_setup_data = {
> +		.rpc_client = NFS_CLIENT(inode),
> +		.rpc_message = &msg,
> +		.callback_ops = &nfs_write_direct_ops,
> +		.workqueue = nfsiod_workqueue,
> +		.flags = RPC_TASK_ASYNC,
> +	};
> +	unsigned int pgbase;
> +	int result;
> +	int seg;
> +	int mapped = 0;
> +	int nr_pages;
> +	ssize_t started = 0;
> +	struct nfs_write_data *data;
> +
> +	result = -ENOMEM;
> +	data = nfs_writedata_alloc(pages);
> +	if (unlikely(!data))
> +		return result;
> +
> +	pgbase = user_addr & ~PAGE_MASK;
> +
> +	for (seg = 0; seg < nr_segs; seg++) {
> +		user_addr = (unsigned long)iov[seg].iov_base;
> +		nr_pages = iov[seg].iov_len >> PAGE_SHIFT;
> +
> +		down_read(&current->mm->mmap_sem);
> +		result = get_user_pages(current, current->mm, user_addr,
> +					nr_pages, 0, 0, &data->pagevec[mapped], NULL);
> +		up_read(&current->mm->mmap_sem);
> +		if (result < 0) {
> +			/* unmap what is done so far */
> +			nfs_direct_release_pages(data->pagevec, mapped);
> +			nfs_writedata_free(data);
> +			return result;
> +		}
> +		mapped += result;
> +	}
> +
> +	get_dreq(dreq);
> +	list_move_tail(&data->pages, &dreq->rewrite_list);
> +
> +	data->req = (struct nfs_page *) dreq;
> +	data->inode = inode;
> +	data->cred = msg.rpc_cred;
> +	data->args.fh = NFS_FH(inode);
> +	data->args.context = ctx;
> +	data->args.offset = pos;
> +	data->args.pgbase = pgbase;
> +	data->args.pages = data->pagevec;
> +	data->args.count = bytes;
> +	data->args.stable = sync;
> +	data->res.fattr = &data->fattr;
> +	data->res.count = bytes;
> +	data->res.verf = &data->verf;
> +	nfs_fattr_init(&data->fattr);
> +
> +	task_setup_data.task = &data->task;
> +	task_setup_data.callback_data = data;
> +	msg.rpc_argp = &data->args;
> +	msg.rpc_resp = &data->res;
> +	NFS_PROTO(inode)->write_setup(data, &msg);
> +
> +	task = rpc_run_task(&task_setup_data);
> +	if (IS_ERR(task))
> +		goto out;
> +	rpc_put_task(task);
> +
> +	started += bytes;
> +out:
> +	if (started)
> +		return started;
> +	return result < 0 ? (ssize_t) result : -EFAULT;
> +}
> +
> static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> 					       const struct iovec *iov,
> 					       unsigned long nr_segs,
> @@ -832,6 +1080,16 @@ static ssize_t nfs_direct_write_schedule
> 
> 	get_dreq(dreq);
> 
> +	result = nfs_direct_check_single_io(dreq, iov, nr_segs, 1);
> +	if (result) {
> +		result = nfs_direct_write_schedule_single_io(dreq, iov, nr_segs,
> +							result, pos, sync);
> +		if (result < 0)
> +			goto out;
> +		requested_bytes += result;
> +		pos += result;
> +		goto out;
> +	}
> 	for (seg = 0; seg < nr_segs; seg++) {
> 		const struct iovec *vec = &iov[seg];
> 		result = nfs_direct_write_schedule_segment(dreq, vec,
> @@ -853,6 +1111,7 @@ static ssize_t nfs_direct_write_schedule
> 		return result < 0 ? result : -EIO;
> 	}
> 
> +out:
> 	if (put_dreq(dreq))
> 		nfs_direct_write_complete(dreq, dreq->inode);
> 	return 0;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




