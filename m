Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:32891 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbEGLAp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 07:00:45 -0400
Received: by lbbzk7 with SMTP id zk7so28146202lbb.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 04:00:44 -0700 (PDT)
Message-ID: <554B45E7.4040902@dev.mellanox.co.il>
Date: Thu, 07 May 2015 14:00:55 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 14/14] xprtrmda: Reduce per-transport MR allocation
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175856.3483.57373.stgit@manet.1015granger.net>
In-Reply-To: <20150504175856.3483.57373.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:58 PM, Chuck Lever wrote:
> Reduce resource consumption per-transport to make way for increasing
> the credit limit and maximum r/wsize. Pre-allocate fewer MRs.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/fmr_ops.c  |    6 ++++--
>   net/sunrpc/xprtrdma/frwr_ops.c |    6 ++++--
>   2 files changed, 8 insertions(+), 4 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index 4a53ad5..f1e8daf 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -69,8 +69,10 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
>   	INIT_LIST_HEAD(&buf->rb_mws);
>   	INIT_LIST_HEAD(&buf->rb_all);
>
> -	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
> -	dprintk("RPC:       %s: initializing %d FMRs\n", __func__, i);
> +	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / RPCRDMA_MAX_FMR_SGES, 1);
> +	i += 2;				/* head + tail */
> +	i *= buf->rb_max_requests;	/* one set for each RPC slot */
> +	dprintk("RPC:       %s: initalizing %d FMRs\n", __func__, i);
>
>   	rc = -ENOMEM;
>   	while (i--) {
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index edc10ba..fc2d0c6 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -270,8 +270,10 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
>   	INIT_LIST_HEAD(&buf->rb_mws);
>   	INIT_LIST_HEAD(&buf->rb_all);
>
> -	i = (buf->rb_max_requests + 1) * RPCRDMA_MAX_SEGS;
> -	dprintk("RPC:       %s: initializing %d FRMRs\n", __func__, i);
> +	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / depth, 1);
> +	i += 2;				/* head + tail */
> +	i *= buf->rb_max_requests;	/* one set for each RPC slot */
> +	dprintk("RPC:       %s: initalizing %d FRMRs\n", __func__, i);
>
>   	while (i--) {
>   		struct rpcrdma_mw *r;
>

Looks good.

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
