From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/3] nfs41: Retry delegation return if it failed with
 session error
Date: Sat, 05 Dec 2009 15:39:39 -0500
Message-ID: <1260045579.29208.9.camel@localhost>
References: <>
	 <1260043884-16267-1-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-2-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-3-git-send-email-Ricardo.Labiaga@netapp.com>
	 <1260043884-16267-4-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8326 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756960AbZLEUlT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Dec 2009 15:41:19 -0500
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id nB5KfO3n011185
	for <linux-nfs@vger.kernel.org>; Sat, 5 Dec 2009 12:41:25 -0800 (PST)
In-Reply-To: <1260043884-16267-4-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-12-05 at 12:11 -0800, Ricardo Labiaga wrote: 
> Update nfs4_delegreturn_done() to retry the operation after setting the
> NFS4CLNT_SESSION_SETUP bit to indicate the need to reset the session.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfs/nfs4proc.c |   13 +++++++++++--
>  1 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 97d4a82..25f4180 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3484,9 +3484,18 @@ static void nfs4_delegreturn_done(struct rpc_task *task, void *calldata)
>  	nfs4_sequence_done_free_slot(data->res.server, &data->res.seq_res,
>  				     task->tk_status);
>  
> -	data->rpc_status = task->tk_status;
> -	if (data->rpc_status == 0)
> +	switch (task->tk_status) {
> +	case -NFS4ERR_STALE_STATEID:
> +	case -NFS4ERR_EXPIRED:
> +	case 0:
>  		renew_lease(data->res.server, data->timestamp);
> +		break;
> +	default:
> +		if (nfs4_async_handle_error(task, data->res.server, NULL) ==
> +				-EAGAIN)
> +			nfs4_restart_rpc(task, data->res.server->nfs_client);

return; 
> +	}
> +	data->rpc_status = task->tk_status;
>  }
>  
>  static void nfs4_delegreturn_release(void *calldata)


