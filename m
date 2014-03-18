Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549AbaCRTCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Mar 2014 15:02:46 -0400
Message-ID: <53289852.9050806@RedHat.com>
Date: Tue, 18 Mar 2014 15:02:42 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] SUNRPC: Ensure that call_bind times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com> <1395081645-11906-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395081645-11906-2-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/17/2014 02:40 PM, Trond Myklebust wrote:
> If the rpcbind server is unavailable, we still want the RPC client
> to respect the timeout.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.

> ---
>  net/sunrpc/clnt.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index f22d3a115fda..53a13835b90f 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1728,9 +1728,7 @@ call_bind_status(struct rpc_task *task)
>  	case -EPROTONOSUPPORT:
>  		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
>  				task->tk_pid);
> -		task->tk_status = 0;
> -		task->tk_action = call_bind;
> -		return;
> +		goto retry_timeout;
>  	case -ECONNREFUSED:		/* connection problems */
>  	case -ECONNRESET:
>  	case -ECONNABORTED:
> @@ -1756,6 +1754,7 @@ call_bind_status(struct rpc_task *task)
>  	return;
>  
>  retry_timeout:
> +	task->tk_status = 0;
>  	task->tk_action = call_timeout;
>  }
>  
> 
