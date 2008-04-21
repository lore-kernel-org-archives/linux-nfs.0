From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 01/33] SUNRPC: Fix a bug in call_decode()
Date: Mon, 21 Apr 2008 12:22:22 -0400
Message-ID: <3A712572-A884-41BB-ABFF-94C41EF41F7E@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204047.14124.76946.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41853 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756956AbYDUQXj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 12:23:39 -0400
In-Reply-To: <20080419204047.14124.76946.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> call_verify() can, under certain circumstances, free the RPC slot.  
> In that
> case, our cached pointer 'req = task->tk_rqstp' is invalid. Bug was
> introduced in commit 220bcc2afd7011b3e0569fc178331fa983c92c1b (SUNRPC:
> Don't call xprt_release in call refresh).

Since you still refer to this function as "call_verify" can I assume  
you rejected my patches that renamed it rpc_verify_header?

A better fix might instead move the logic in call_decode's out_retry:  
arm into call_verify.

A subsequent clean-up should refactor the spaghetti in call_verify  
into several simpler functions to reduce the likelihood of this kind  
of defect cropping up again.

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> net/sunrpc/clnt.c |    9 ++++++---
> 1 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index d6701f7..0c29792 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1236,10 +1236,13 @@ call_decode(struct rpc_task *task)
> 			task->tk_status);
> 	return;
> out_retry:
> -	req->rq_received = req->rq_private_buf.len = 0;
> 	task->tk_status = 0;
> -	if (task->tk_client->cl_discrtry)
> -		xprt_force_disconnect(task->tk_xprt);
> +	/* Note: call_verify() may have freed the RPC slot */
> +	if (task->tk_rqstp == req) {
> +		req->rq_received = req->rq_private_buf.len = 0;
> +		if (task->tk_client->cl_discrtry)
> +			xprt_force_disconnect(task->tk_xprt);
> +	}
> }
>
> /*
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



