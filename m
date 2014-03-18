Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757524AbaCRSsJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Mar 2014 14:48:09 -0400
Message-ID: <532894E6.2090702@RedHat.com>
Date: Tue, 18 Mar 2014 14:48:06 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/17/2014 02:40 PM, Trond Myklebust wrote:
> When the server is unavailable due to a networking error, etc, we want
> the RPC client to respect the timeout delays when attempting to reconnect.
> 
> Fixes: 561ec1603171 (SUNRPC: call_connect_status should recheck bind..)
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Tested-by: Steve Dickson <steved@redhat.com>

steved.
> ---
>  net/sunrpc/clnt.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 0edada973434..f22d3a115fda 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1798,10 +1798,6 @@ call_connect_status(struct rpc_task *task)
>  	trace_rpc_connect_status(task, status);
>  	task->tk_status = 0;
>  	switch (status) {
> -		/* if soft mounted, test if we've timed out */
> -	case -ETIMEDOUT:
> -		task->tk_action = call_timeout;
> -		return;
>  	case -ECONNREFUSED:
>  	case -ECONNRESET:
>  	case -ECONNABORTED:
> @@ -1812,7 +1808,9 @@ call_connect_status(struct rpc_task *task)
>  		if (RPC_IS_SOFTCONN(task))
>  			break;
>  	case -EAGAIN:
> -		task->tk_action = call_bind;
> +	case -ETIMEDOUT:
> +		/* Check if we've timed out before looping back to call_bind */
> +		task->tk_action = call_timeout;
>  		return;
>  	case 0:
>  		clnt->cl_stats->netreconn++;
> 
