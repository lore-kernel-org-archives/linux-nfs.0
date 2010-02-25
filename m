From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: NFSv4 callback client should use
	RPC_TASK_SOFTCONN
Date: Wed, 24 Feb 2010 20:51:45 -0500
Message-ID: <20100225015145.GJ16665@fieldses.org>
References: <20100224214709.1399.59887.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59523 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab0BYBus (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2010 20:50:48 -0500
In-Reply-To: <20100224214709.1399.59887.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 24, 2010 at 01:48:06PM -0800, Chuck Lever wrote:
> The server's callback client should stop trying to connect to the
> client's callback server as soon as it gets ECONNREFUSED.
> 
> The NFS server's callback client does not call rpc_ping(), but appears
> to have it's own "ping" procedure, so it wasn't covered by commit
> caabea8a.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> Hi Bruce-
> 
> Noticed at Connectathon.  I think this is appropriate for 2.6.34, which opened
> today.

Thanks, applied for 2.6.34.

--b.

> 
>  fs/nfsd/nfs4callback.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index c6eed2a..5ab598d 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -542,7 +542,8 @@ void do_probe_callback(struct nfs4_client *clp)
>  	};
>  	int status;
>  
> -	status = rpc_call_async(cb->cb_client, &msg, RPC_TASK_SOFT,
> +	status = rpc_call_async(cb->cb_client, &msg,
> +				RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
>  				&nfsd4_cb_probe_ops, (void *)clp);
>  	if (status) {
>  		warn_no_callback_path(clp, status);
> 
