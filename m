From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/4] nfs41: fix race between umount and renewd sequence
 operations
Date: Thu, 28 Jan 2010 15:47:46 -0500
Message-ID: <1264711666.7553.45.camel@localhost>
References: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
	 <1264560235-2478-2-git-send-email-batsakis@netapp.com>
	 <1264560235-2478-3-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, trond@netapp.com
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:60853 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149Ab0A1UsF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2010 15:48:05 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0SKlmV0021923
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2010 12:47:48 -0800 (PST)
In-Reply-To: <1264560235-2478-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-26 at 18:43 -0800, Alexandros Batsakis wrote: 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 9fc99e9..cd523df 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5041,6 +5041,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
>  
>  	if (task->tk_status < 0) {
>  		dprintk("%s ERROR %d\n", __func__, task->tk_status);
> +		if (atomic_read(&clp->cl_count) == 1)
> +			return;
>  
>  		if (_nfs4_async_handle_error(task, NULL, clp, NULL)
>  								== -EAGAIN) {
> @@ -5050,7 +5052,8 @@ void nfs41_sequence_call_done(struct rpc_task *task, void *data)
>  	}
>  	dprintk("%s rpc_cred %p\n", __func__, task->tk_msg.rpc_cred);
>  
> -	nfs4_schedule_state_renewal(clp);
> +	if (atomic_read(&clp->cl_count) > 1)

Why not just have a single
         if (atomic_read(&clp->cl_count) == 1)
return;

above

> +		nfs4_schedule_state_renewal(clp);
>  
>  	kfree(task->tk_msg.rpc_argp);
>  	kfree(task->tk_msg.rpc_resp);

These belong in the 'sequence_release' function regardless. Otherwise
you have a memory leak if rpc_call_async() failed, and also if your test
for clp->cl_count == 1 in the error case above.

> @@ -5073,9 +5076,15 @@ static void nfs41_sequence_prepare(struct rpc_task *task, void *data)
>  	rpc_call_start(task);
>  }
>  
> +static void nfs41_sequence_release(void *calldata)
> +{
> +	nfs_put_client((struct nfs_client *) calldata);
> +}
> +
>  static const struct rpc_call_ops nfs41_sequence_ops = {
>  	.rpc_call_done = nfs41_sequence_call_done,
>  	.rpc_call_prepare = nfs41_sequence_prepare,
> +	.rpc_release = nfs41_sequence_release,
>  };
>  
>  static int nfs41_proc_async_sequence(struct nfs_client *clp,
> @@ -5088,11 +5097,16 @@ static int nfs41_proc_async_sequence(struct nfs_client *clp,
>  		.rpc_cred = cred,
>  	};
>  
> +	if (!atomic_inc_not_zero(&clp->cl_count))
> +		return -EIO;
>  	args = kzalloc(sizeof(*args), GFP_KERNEL);
> -	if (!args)
> +	if (!args) {
> +		nfs_put_client(clp);
>  		return -ENOMEM;
> +	}
>  	res = kzalloc(sizeof(*res), GFP_KERNEL);
>  	if (!res) {
> +		nfs_put_client(clp);
>  		kfree(args);
>  		return -ENOMEM;
>  	}


