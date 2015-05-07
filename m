Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38093 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbEGJiJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 05:38:09 -0400
Received: by wiun10 with SMTP id n10so52672313wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 02:38:08 -0700 (PDT)
Message-ID: <554B328B.9040804@dev.mellanox.co.il>
Date: Thu, 07 May 2015 12:38:19 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 03/14] xprtrdma: Replace rpcrdma_rep::rr_buffer with
 rr_rxprt
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175711.3483.17222.stgit@manet.1015granger.net>
In-Reply-To: <20150504175711.3483.17222.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:57 PM, Chuck Lever wrote:
> Clean up: Instead of carrying a pointer to the buffer pool and
> the rpc_xprt, carry a pointer to the controlling rpcrdma_xprt.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/rpc_rdma.c  |    4 ++--
>   net/sunrpc/xprtrdma/transport.c |    7 ++-----
>   net/sunrpc/xprtrdma/verbs.c     |    8 +++++---
>   net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
>   4 files changed, 10 insertions(+), 12 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
> index 2c53ea9..98a3b95 100644
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -732,8 +732,8 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
>   	struct rpcrdma_msg *headerp;
>   	struct rpcrdma_req *req;
>   	struct rpc_rqst *rqst;
> -	struct rpc_xprt *xprt = rep->rr_xprt;
> -	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
> +	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
> +	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
>   	__be32 *iptr;
>   	int rdmalen, status;
>   	unsigned long cwnd;
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index fdcb2c7..ed70551 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -650,12 +650,9 @@ xprt_rdma_send_request(struct rpc_task *task)
>
>   	if (req->rl_reply == NULL) 		/* e.g. reconnection */
>   		rpcrdma_recv_buffer_get(req);
> -
> -	if (req->rl_reply) {
> +	/* rpcrdma_recv_buffer_get may have set rl_reply, so check again */
> +	if (req->rl_reply)
>   		req->rl_reply->rr_func = rpcrdma_reply_handler;
> -		/* this need only be done once, but... */
> -		req->rl_reply->rr_xprt = xprt;
> -	}

Can't you just fold that into rpcrdma_recv_buffer_get() instead of
checking what it did?

Other than that,

Looks good,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
