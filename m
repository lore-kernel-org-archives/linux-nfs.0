From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 3/8] SUNRPC: Use RPC procedure name in call_verify
Date: Tue, 20 May 2008 17:21:38 -0400
Message-ID: <1211318498.26809.13.camel@localhost>
References: <20080520202108.3851.7464.stgit@ellison.1015granger.net>
	 <20080520202941.3851.61861.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62906 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756376AbYETVWP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 17:22:15 -0400
In-Reply-To: <20080520202941.3851.61861.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-05-20 at 16:29 -0400, Chuck Lever wrote:
> Making debugging output a little cleaner in call_verify by displaying the
> name of the RPC procedure instead of it's number.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/clnt.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index adbc85c..5aa32fa 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1431,10 +1431,10 @@ call_verify(struct rpc_task *task)
>  		error = -EPROTONOSUPPORT;
>  		goto out_err;
>  	case RPC_PROC_UNAVAIL:
> -		dprintk("RPC: %5u %s: proc %p unsupported by program %u, "
> +		dprintk("RPC: %5u %s: proc %s unsupported by program %u, "
>  				"version %u on server %s\n",
>  				task->tk_pid, __func__,
> -				task->tk_msg.rpc_proc,
> +				task->tk_msg.rpc_proc->p_name,
>  				task->tk_client->cl_prog,
>  				task->tk_client->cl_vers,
>  				task->tk_client->cl_server);

This will cause a crash if you ever call it while somebody is calling
rpc_call_null. There may be other cases too.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
