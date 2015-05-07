Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:34258 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbbEGKgW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 06:36:22 -0400
Received: by wicmx19 with SMTP id mx19so10477709wic.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 03:36:21 -0700 (PDT)
Message-ID: <554B402F.3000604@dev.mellanox.co.il>
Date: Thu, 07 May 2015 13:36:31 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 10/14] xprtrdma: Remove ->ro_reset
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175818.3483.22408.stgit@manet.1015granger.net>
In-Reply-To: <20150504175818.3483.22408.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/4/2015 8:58 PM, Chuck Lever wrote:
> An RPC can exit at any time. When it does so, xprt_rdma_free() is
> called, and it calls ->op_unmap().
>
> If ->ro_reset() is running due to a transport disconnect, the two
> methods can race while processing the same rpcrdma_mw. The results
> are unpredictable.
>
> Because of this, in previous patches I've replaced the ->ro_reset()
> methods with a recovery workqueue. ->ro_reset() is no longer used
> and can be removed.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/sunrpc/xprtrdma/fmr_ops.c      |   11 -----------
>   net/sunrpc/xprtrdma/frwr_ops.c     |   16 ----------------
>   net/sunrpc/xprtrdma/physical_ops.c |    6 ------
>   net/sunrpc/xprtrdma/verbs.c        |    2 --
>   net/sunrpc/xprtrdma/xprt_rdma.h    |    1 -
>   5 files changed, 36 deletions(-)
>
> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
> index ad0055b..5dd77da 100644
> --- a/net/sunrpc/xprtrdma/fmr_ops.c
> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
> @@ -197,16 +197,6 @@ out_err:
>   	return nsegs;
>   }
>
> -/* After a disconnect, unmap all FMRs.
> - *
> - * This is invoked only in the transport connect worker in order
> - * to serialize with rpcrdma_register_fmr_external().
> - */
> -static void
> -fmr_op_reset(struct rpcrdma_xprt *r_xprt)
> -{
> -}
> -
>   static void
>   fmr_op_destroy(struct rpcrdma_buffer *buf)
>   {
> @@ -230,7 +220,6 @@ const struct rpcrdma_memreg_ops rpcrdma_fmr_memreg_ops = {
>   	.ro_open			= fmr_op_open,
>   	.ro_maxpages			= fmr_op_maxpages,
>   	.ro_init			= fmr_op_init,
> -	.ro_reset			= fmr_op_reset,
>   	.ro_destroy			= fmr_op_destroy,
>   	.ro_displayname			= "fmr",
>   };
> diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
> index 6f93a89..3fb609a 100644
> --- a/net/sunrpc/xprtrdma/frwr_ops.c
> +++ b/net/sunrpc/xprtrdma/frwr_ops.c
> @@ -430,21 +430,6 @@ out_err:
>   	return nsegs;
>   }
>
> -/* After a disconnect, a flushed FAST_REG_MR can leave an FRMR in
> - * an unusable state. Find FRMRs in this state and dereg / reg
> - * each.  FRMRs that are VALID and attached to an rpcrdma_req are
> - * also torn down.
> - *
> - * This gives all in-use FRMRs a fresh rkey and leaves them INVALID.
> - *
> - * This is invoked only in the transport connect worker in order
> - * to serialize with rpcrdma_register_frmr_external().
> - */
> -static void
> -frwr_op_reset(struct rpcrdma_xprt *r_xprt)
> -{
> -}
> -
>   static void
>   frwr_op_destroy(struct rpcrdma_buffer *buf)
>   {
> @@ -464,7 +449,6 @@ const struct rpcrdma_memreg_ops rpcrdma_frwr_memreg_ops = {
>   	.ro_open			= frwr_op_open,
>   	.ro_maxpages			= frwr_op_maxpages,
>   	.ro_init			= frwr_op_init,
> -	.ro_reset			= frwr_op_reset,
>   	.ro_destroy			= frwr_op_destroy,
>   	.ro_displayname			= "frwr",
>   };
> diff --git a/net/sunrpc/xprtrdma/physical_ops.c b/net/sunrpc/xprtrdma/physical_ops.c
> index da149e8..41985d0 100644
> --- a/net/sunrpc/xprtrdma/physical_ops.c
> +++ b/net/sunrpc/xprtrdma/physical_ops.c
> @@ -69,11 +69,6 @@ physical_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>   }
>
>   static void
> -physical_op_reset(struct rpcrdma_xprt *r_xprt)
> -{
> -}
> -
> -static void
>   physical_op_destroy(struct rpcrdma_buffer *buf)
>   {
>   }
> @@ -84,7 +79,6 @@ const struct rpcrdma_memreg_ops rpcrdma_physical_memreg_ops = {
>   	.ro_open			= physical_op_open,
>   	.ro_maxpages			= physical_op_maxpages,
>   	.ro_init			= physical_op_init,
> -	.ro_reset			= physical_op_reset,
>   	.ro_destroy			= physical_op_destroy,
>   	.ro_displayname			= "physical",
>   };
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 5120a8e..eaf0b9d 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -897,8 +897,6 @@ retry:
>   		rpcrdma_flush_cqs(ep);
>
>   		xprt = container_of(ia, struct rpcrdma_xprt, rx_ia);
> -		ia->ri_ops->ro_reset(xprt);
> -
>   		id = rpcrdma_create_id(xprt, ia,
>   				(struct sockaddr *)&xprt->rx_data.addr);
>   		if (IS_ERR(id)) {
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index 98227d6..6a1e565 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -353,7 +353,6 @@ struct rpcrdma_memreg_ops {
>   				   struct rpcrdma_create_data_internal *);
>   	size_t		(*ro_maxpages)(struct rpcrdma_xprt *);
>   	int		(*ro_init)(struct rpcrdma_xprt *);
> -	void		(*ro_reset)(struct rpcrdma_xprt *);
>   	void		(*ro_destroy)(struct rpcrdma_buffer *);
>   	const char	*ro_displayname;
>   };
>

Looks good,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
