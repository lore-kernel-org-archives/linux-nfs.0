From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch]xprt: remove redundant checks
Date: Wed, 16 Mar 2011 10:25:40 -0400
Message-ID: <1300285540.16266.49.camel@lade.trondhjem.org>
References: <20110316064509.GA1498@asset.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: j223yang-I6MVnP1QzuRPSEYXltEZZrDks+cytr/Z@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40525 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752446Ab1CPOZr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2011 10:25:47 -0400
In-Reply-To: <20110316064509.GA1498-I6MVnP1QzuRPSEYXltEZZrDks+cytr/Z@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-03-16 at 02:45 -0400, j223yang-I6MVnP1QzuRPSEYXltEZZrDks+cytr/Z@public.gmane.org wrote:
> 'req' is already dereferenced in 
> 'struct rpc_xprt *xprt = req->rq_xprt;',
> but check again later in the function.
> The patch removes these redundant checks.
> 
> Signed-off-by: Jinqiu Yang <crindy646@gmail.com>
> ---
>  xprt.c |    8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpt/xprt.c b/net/sunrpt/xprt.c
> --- a/net/sunrpc/xprt.c	2011-03-16 00:10:08.764164573 -0400
> +++ b/net/sunrpt/xprt.c	2011-03-16 02:33:38.559164414 -0400
> @@ -202,10 +202,8 @@ int xprt_reserve_xprt(struct rpc_task *t
>  		goto out_sleep;
>  	}
>  	xprt->snd_task = task;
> -	if (req) {
> -		req->rq_bytes_sent = 0;
> -		req->rq_ntrans++;
> -	}
> +	req->rq_bytes_sent = 0;
> +	req->rq_ntrans++;
>  	return 1;
>  
>  out_sleep:
> @@ -213,7 +211,7 @@ out_sleep:
>  			task->tk_pid, xprt);
>  	task->tk_timeout = 0;
>  	task->tk_status = -EAGAIN;
> -	if (req && req->rq_ntrans)
> +	if (req->rq_ntrans)
>  		rpc_sleep_on(&xprt->resend, task, NULL);
>  	else
>  		rpc_sleep_on(&xprt->sending, task, NULL);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

You already sent hunk 1 in a different patch, and I've already applied
that to the nfs-for-2.6.39 branch. Could you therefore please resend
this patch with just the second hunk.

Cheers
  Trond

