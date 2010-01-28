From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 4/4] nfs4: fix race between umount and renew operations
Date: Thu, 28 Jan 2010 15:48:28 -0500
Message-ID: <1264711708.7553.46.camel@localhost>
References: <1264560235-2478-1-git-send-email-batsakis@netapp.com>
	 <1264560235-2478-2-git-send-email-batsakis@netapp.com>
	 <1264560235-2478-3-git-send-email-batsakis@netapp.com>
	 <1264560235-2478-4-git-send-email-batsakis@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, trond@netapp.com
To: Alexandros Batsakis <batsakis@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437Ab0A1Usa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2010 15:48:30 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0SKmTf1001195
	for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2010 12:48:29 -0800 (PST)
In-Reply-To: <1264560235-2478-4-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-01-26 at 18:43 -0800, Alexandros Batsakis wrote: 
> Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   12 +++++++++++-
>  1 files changed, 11 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index cd523df..cc8f059 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3162,11 +3162,18 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
>  	if (time_before(clp->cl_last_renewal,timestamp))
>  		clp->cl_last_renewal = timestamp;
>  	spin_unlock(&clp->cl_lock);
> -	nfs4_schedule_state_renewal(clp);
> +	if (atomic_read(clp->cl_count) > 1)
> +		nfs4_schedule_state_renewal(clp);
> +}
> +
> +static void nfs4_renew_release(void *calldata)
> +{
> +	nfs_put_client((struct nfs_client *) calldata);
>  }
>  
>  static const struct rpc_call_ops nfs4_renew_ops = {
>  	.rpc_call_done = nfs4_renew_done,
> +	.rpc_release = nfs4_renew_release,
>  };
>  
>  int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
> @@ -3177,6 +3184,9 @@ int nfs4_proc_async_renew(struct nfs_client *clp, struct rpc_cred *cred)
>  		.rpc_cred	= cred,
>  	};
>  
> +	if (!atomic_inc_not_zero(clp->cl_count))
> +		return -EIO;
> +
>  	return rpc_call_async(clp->cl_rpcclient, &msg, RPC_TASK_SOFT,
>  			&nfs4_renew_ops, (void *)jiffies);
>  }

Thanks! This looks good.
