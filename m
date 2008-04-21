From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/33] SUNRPC: Fix read ordering problems with req->rq_private_buf.len
Date: Mon, 21 Apr 2008 17:19:16 -0400
Message-ID: <CAC2A944-24A0-4E20-83AE-2A4F88CF5C70@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204049.14124.11174.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40701 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752282AbYDUVTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 17:19:40 -0400
In-Reply-To: <20080419204049.14124.11174.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> We want to ensure that req->rq_private_buf.len is updated before
> req->rq_received, so that call_decode() doesn't use an old value for
> req->rq_rcv_buf.len.
>
> In 'call_decode()' itself, instead of using task->tk_status (which  
> is set
> using req->rq_received) must use the actual value of
> req->rq_private_buf.len when deciding whether or not the received  
> RPC reply
> is too short.
>
> Finally ensure that we set req->rq_rcv_buf.len to zero when retrying a
> request. A typo meant that we were resetting req->rq_private_buf.len  
> in
> call_decode(), and then clobbering that value with the old  
> rq_rcv_buf.len
> again in xprt_transmit().

After staring at this for a while, the interaction between  
xprt_complete_rqst and call_decode isn't clear to me.

I take it there is no guarantee that the xdr_buf fields and  
rq_received are completely updated before the task is awoken and  
call_decode runs?

> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> net/sunrpc/clnt.c |   26 +++++++++++++-------------
> net/sunrpc/xprt.c |    3 ++-
> 2 files changed, 15 insertions(+), 14 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 0c29792..57663a4 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1195,18 +1195,6 @@ call_decode(struct rpc_task *task)
> 		task->tk_flags &= ~RPC_CALL_MAJORSEEN;
> 	}
>
> -	if (task->tk_status < 12) {
> -		if (!RPC_IS_SOFT(task)) {
> -			task->tk_action = call_bind;
> -			clnt->cl_stats->rpcretrans++;
> -			goto out_retry;
> -		}
> -		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
> -				clnt->cl_protname, task->tk_status);
> -		task->tk_action = call_timeout;
> -		goto out_retry;
> -	}
> -
> 	/*
> 	 * Ensure that we see all writes made by xprt_complete_rqst()
> 	 * before it changed req->rq_received.
> @@ -1218,6 +1206,18 @@ call_decode(struct rpc_task *task)
> 	WARN_ON(memcmp(&req->rq_rcv_buf, &req->rq_private_buf,
> 				sizeof(req->rq_rcv_buf)) != 0);
>
> +	if (req->rq_rcv_buf.len < 12) {
> +		if (!RPC_IS_SOFT(task)) {
> +			task->tk_action = call_bind;
> +			clnt->cl_stats->rpcretrans++;
> +			goto out_retry;
> +		}
> +		dprintk("RPC:       %s: too small RPC reply size (%d bytes)\n",
> +				clnt->cl_protname, task->tk_status);
> +		task->tk_action = call_timeout;
> +		goto out_retry;
> +	}
> +
> 	/* Verify the RPC header */
> 	p = call_verify(task);
> 	if (IS_ERR(p)) {
> @@ -1239,7 +1239,7 @@ out_retry:
> 	task->tk_status = 0;
> 	/* Note: call_verify() may have freed the RPC slot */
> 	if (task->tk_rqstp == req) {
> -		req->rq_received = req->rq_private_buf.len = 0;
> +		req->rq_received = req->rq_rcv_buf.len = 0;
> 		if (task->tk_client->cl_discrtry)
> 			xprt_force_disconnect(task->tk_xprt);
> 	}
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index 3ba64f9..5110a4e 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -757,9 +757,10 @@ void xprt_complete_rqst(struct rpc_task *task,  
> int copied)
> 	task->tk_rtt = (long)jiffies - req->rq_xtime;
>
> 	list_del_init(&req->rq_list);
> +	req->rq_private_buf.len = copied;
> 	/* Ensure all writes are done before we update req->rq_received */
> 	smp_wmb();
> -	req->rq_received = req->rq_private_buf.len = copied;
> +	req->rq_received = copied;
> 	rpc_wake_up_queued_task(&xprt->pending, task);
> }
> EXPORT_SYMBOL_GPL(xprt_complete_rqst);
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



