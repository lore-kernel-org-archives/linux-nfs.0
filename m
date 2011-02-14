Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37961 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726Ab1BNRWw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 12:22:52 -0500
Subject: Re: [PATCH 1/7] wave4: nfs: rearrange nfs_write_rpcsetup
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <1297443279-19813-2-git-send-email-iisaman@netapp.com>
Date: Mon, 14 Feb 2011 12:22:31 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <142A667D-F17B-4B00-B3B4-85AD1E15C8CF@netapp.com>
References: <1297443279-19813-1-git-send-email-iisaman@netapp.com> <1297443279-19813-2-git-send-email-iisaman@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Since I'm the author for the read version of this code, I'll raise my hand to be the author for this version.

-->Andy

On Feb 11, 2011, at 11:54 AM, Fred Isaman wrote:

> From: The pNFS Team <linux-nfs@vger.kernel.org>
> 
> Reorder nfs_write_rpcsetup, preparing for a pnfs switch.
> 
> FIXME: these signoffs are ridiculous for this simple patch.
> Lets just pick an author and be done with it.
> 
> Reported-by: Alexandros Batsakis <batsakis@netapp.com>
> Signed-off-by: Andy Adamson <andros@citi.umich.edu>
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
> Signed-off-by: Mike Sager <sager@netapp.com>
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
> fs/nfs/write.c |   82 +++++++++++++++++++++++++++++++------------------------
> 1 files changed, 46 insertions(+), 36 deletions(-)
> 
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index aca0268..5604854 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -782,25 +782,21 @@ static int flush_task_priority(int how)
> 	return RPC_PRIORITY_NORMAL;
> }
> 
> -/*
> - * Set up the argument/result storage required for the RPC call.
> - */
> -static int nfs_write_rpcsetup(struct nfs_page *req,
> -		struct nfs_write_data *data,
> -		const struct rpc_call_ops *call_ops,
> -		unsigned int count, unsigned int offset,
> -		int how)
> +static int nfs_initiate_write(struct nfs_write_data *data,
> +		       struct rpc_clnt *clnt,
> +		       const struct rpc_call_ops *call_ops,
> +		       int how)
> {
> -	struct inode *inode = req->wb_context->path.dentry->d_inode;
> +	struct inode *inode = data->inode;
> 	int priority = flush_task_priority(how);
> 	struct rpc_task *task;
> 	struct rpc_message msg = {
> 		.rpc_argp = &data->args,
> 		.rpc_resp = &data->res,
> -		.rpc_cred = req->wb_context->cred,
> +		.rpc_cred = data->cred,
> 	};
> 	struct rpc_task_setup task_setup_data = {
> -		.rpc_client = NFS_CLIENT(inode),
> +		.rpc_client = clnt,
> 		.task = &data->task,
> 		.rpc_message = &msg,
> 		.callback_ops = call_ops,
> @@ -811,12 +807,49 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
> 	};
> 	int ret = 0;
> 
> +	/* Set up the initial task struct.  */
> +	NFS_PROTO(inode)->write_setup(data, &msg);
> +
> +	dprintk("NFS: %5u initiated write call "
> +		"(req %s/%lld, %u bytes @ offset %llu)\n",
> +		data->task.tk_pid,
> +		inode->i_sb->s_id,
> +		(long long)NFS_FILEID(inode),
> +		data->args.count,
> +		(unsigned long long)data->args.offset);
> +
> +	task = rpc_run_task(&task_setup_data);
> +	if (IS_ERR(task)) {
> +		ret = PTR_ERR(task);
> +		goto out;
> +	}
> +	if (how & FLUSH_SYNC) {
> +		ret = rpc_wait_for_completion_task(task);
> +		if (ret == 0)
> +			ret = task->tk_status;
> +	}
> +	rpc_put_task(task);
> +out:
> +	return ret;
> +}
> +
> +/*
> + * Set up the argument/result storage required for the RPC call.
> + */
> +static int nfs_write_rpcsetup(struct nfs_page *req,
> +		struct nfs_write_data *data,
> +		const struct rpc_call_ops *call_ops,
> +		unsigned int count, unsigned int offset,
> +		int how)
> +{
> +	struct inode *inode = req->wb_context->path.dentry->d_inode;
> +
> 	/* Set up the RPC argument and reply structs
> 	 * NB: take care not to mess about with data->commit et al. */
> 
> 	data->req = req;
> 	data->inode = inode = req->wb_context->path.dentry->d_inode;
> -	data->cred = msg.rpc_cred;
> +	data->cred = req->wb_context->cred;
> 
> 	data->args.fh     = NFS_FH(inode);
> 	data->args.offset = req_offset(req) + offset;
> @@ -837,30 +870,7 @@ static int nfs_write_rpcsetup(struct nfs_page *req,
> 	data->res.verf    = &data->verf;
> 	nfs_fattr_init(&data->fattr);
> 
> -	/* Set up the initial task struct.  */
> -	NFS_PROTO(inode)->write_setup(data, &msg);
> -
> -	dprintk("NFS: %5u initiated write call "
> -		"(req %s/%lld, %u bytes @ offset %llu)\n",
> -		data->task.tk_pid,
> -		inode->i_sb->s_id,
> -		(long long)NFS_FILEID(inode),
> -		count,
> -		(unsigned long long)data->args.offset);
> -
> -	task = rpc_run_task(&task_setup_data);
> -	if (IS_ERR(task)) {
> -		ret = PTR_ERR(task);
> -		goto out;
> -	}
> -	if (how & FLUSH_SYNC) {
> -		ret = rpc_wait_for_completion_task(task);
> -		if (ret == 0)
> -			ret = task->tk_status;
> -	}
> -	rpc_put_task(task);
> -out:
> -	return ret;
> +	return nfs_initiate_write(data, NFS_CLIENT(inode), call_ops, how);
> }
> 
> /* If a nfs_flush_* function fails, it should remove reqs from @head and
> -- 
> 1.7.2.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

