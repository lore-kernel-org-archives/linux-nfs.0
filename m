Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:58868 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbaDWKPT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2014 06:15:19 -0400
Received: by mail-we0-f175.google.com with SMTP id q58so636346wes.34
        for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 03:15:17 -0700 (PDT)
Message-ID: <535792B3.1070709@dev.mellanox.co.il>
Date: Wed, 23 Apr 2014 13:15:15 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH V2 16/17] xprtrdma: Limit work done by completion handler
References: <20140421214442.12569.8950.stgit@manet.1015granger.net> <20140421220308.12569.43779.stgit@manet.1015granger.net>
In-Reply-To: <20140421220308.12569.43779.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/22/2014 1:03 AM, Chuck Lever wrote:
> Sagi Grimberg <sagig@dev.mellanox.co.il> points out that a steady
> stream of CQ events could starve other work because of the boundless
> loop pooling in rpcrdma_{send,recv}_poll().
>
> Instead of a (potentially infinite) while loop, return after
> collecting a budgeted number of completions.
>
> Note that the total number of WCs that can be handled during one
> upcall is RPCRDMA_WC_BUDGET * 2, since the handler polls once before
> and once after re-enabling completion notifications.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>
>   net/sunrpc/xprtrdma/verbs.c     |   10 ++++++----
>   net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
>   2 files changed, 7 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index abb8d8d..d46bdee 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -165,8 +165,9 @@ static int
>   rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>   {
>   	struct ib_wc *wcs;
> -	int count, rc;
> +	int budget, count, rc;
>   
> +	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
>   	do {
>   		wcs = ep->rep_send_wcs;
>   
> @@ -177,7 +178,7 @@ rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>   		count = rc;
>   		while (count-- > 0)
>   			rpcrdma_sendcq_process_wc(wcs++);
> -	} while (rc == RPCRDMA_POLLSIZE);
> +	} while (rc == RPCRDMA_POLLSIZE && --budget);
>   	return 0;
>   }
>   
> @@ -254,8 +255,9 @@ static int
>   rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>   {
>   	struct ib_wc *wcs;
> -	int count, rc;
> +	int budget, count, rc;
>   
> +	budget = RPCRDMA_WC_BUDGET / RPCRDMA_POLLSIZE;
>   	do {
>   		wcs = ep->rep_recv_wcs;
>   
> @@ -266,7 +268,7 @@ rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
>   		count = rc;
>   		while (count-- > 0)
>   			rpcrdma_recvcq_process_wc(wcs++);
> -	} while (rc == RPCRDMA_POLLSIZE);
> +	} while (rc == RPCRDMA_POLLSIZE && --budget);
>   	return 0;
>   }
>   
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index cb4c882..0c3b88e 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -74,6 +74,7 @@ struct rpcrdma_ia {
>    * RDMA Endpoint -- one per transport instance
>    */
>   
> +#define RPCRDMA_WC_BUDGET	(128)

Would be nice to be able to configure that (modparam perhaps?)

Other than that, looks OK.

Acked-by: Sagi Grimberg <sagig@dev.mellanox.co.il>

