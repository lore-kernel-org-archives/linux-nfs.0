Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78946C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 17:49:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3446E20874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 17:49:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545068967;
	bh=oYPJChmpKT7nymHLYUzwgjX+gQsjmDWzFXEsPK4+woE=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=tzT4FMk5L/AFVlXBgXbu/ApSkcO6BBDUZjlOHOmjFJLSuQPa7pFCsyvlwuCF4HqOs
	 fBnYECMA98NQIAPbbHHPk5PLI/4DInKbYwTa4S5IkjgpQJ9bKe/JhK9gnf7jOE8BBh
	 ap7m7ofVAWJfDrA2cw9koiSALxFZ1mCLxILpCXHA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727686AbeLQRt0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 12:49:26 -0500
Received: from mail.kernel.org ([198.145.29.99]:53652 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727301AbeLQRt0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 12:49:26 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 44FFC2086C;
        Mon, 17 Dec 2018 17:49:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1545068965;
        bh=oYPJChmpKT7nymHLYUzwgjX+gQsjmDWzFXEsPK4+woE=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=It+qyjZa4eqR9sRqiIim1kB5JiClL1nj2KKIEERJADTxnfCr21DvfklUCyIg+n35y
         Z9sV6JcEbNop81lvHcRIzFOglFHerJ1kMtYw6GtB3twbcFG4XyLoZuzCXAPPN6cEap
         zKiaY7FEmckdjKuNbCxdgDjyan34lM97cypuKae0=
Message-ID: <83282ba18c9d074294ff2eeb51c119d83f8856ca.camel@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
From:   Jeff Layton <jlayton@kernel.org>
To:     Vasily Averin <vvs@virtuozzo.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Evgenii Shatokhin <eshatokhin@virtuozzo.com>,
        Konstantin Khorenko <khorenko@virtuozzo.com>
Date:   Mon, 17 Dec 2018 12:49:22 -0500
In-Reply-To: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.3 (3.30.3-1.fc29) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2018-12-17 at 19:23 +0300, Vasily Averin wrote:
> if node have NFSv41+ mounts inside several net namespaces
> it can lead to use-after-free in svc_process_common()
> 
> svc_process_common() 
>         /* Setup reply header */
>         rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp); <<< HERE
> 
> svc_process_common() can use already freed rqstp->rq_xprt,
> it was assigned in bc_svc_process() where it was taken from serv->sv_bc_xprt.
> 
> serv is global structure but sv_bc_xprt is assigned per-netnamespace,
> so if nfsv41+ shares are mounted in several containers together
> bc_svc_process() can use wrong backchannel or even access freed memory.
> 
> To find correct svc_xprt of client-related backchannel
> bc_svc_process() now calls new .bc_get_xprt callback
> that executes svc_find_xprt() with proper xprt name.
> 
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  include/linux/sunrpc/xprt.h       |  1 +
>  net/sunrpc/svc.c                  | 22 ++++++++++++++++------
>  net/sunrpc/xprtrdma/backchannel.c |  5 +++++
>  net/sunrpc/xprtrdma/transport.c   |  1 +
>  net/sunrpc/xprtrdma/xprt_rdma.h   |  1 +
>  net/sunrpc/xprtsock.c             |  7 +++++++
>  6 files changed, 31 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index a4ab4f8d9140..031d2843a002 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -158,6 +158,7 @@ struct rpc_xprt_ops {
>  	int		(*bc_setup)(struct rpc_xprt *xprt,
>  				    unsigned int min_reqs);
>  	int		(*bc_up)(struct svc_serv *serv, struct net *net);
> +	struct svc_xprt*(*bc_get_xprt)(struct svc_serv *serv, struct net *net);
>  	size_t		(*bc_maxpayload)(struct rpc_xprt *xprt);
>  	void		(*bc_free_rqst)(struct rpc_rqst *rqst);
>  	void		(*bc_destroy)(struct rpc_xprt *xprt,
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index d13e05f1a990..a7264fd1b3db 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -1450,16 +1450,22 @@ int
>  bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  	       struct svc_rqst *rqstp)
>  {
> +	struct net	*net = req->rq_xprt->xprt_net;
>  	struct kvec	*argv = &rqstp->rq_arg.head[0];
>  	struct kvec	*resv = &rqstp->rq_res.head[0];
>  	struct rpc_task *task;
> +	struct svc_xprt *s_xprt;
>  	int proc_error;
>  	int error;
>  
>  	dprintk("svc: %s(%p)\n", __func__, req);
>  
> +	s_xprt = req->rq_xprt->ops->bc_get_xprt(serv, net);
> +	if (!s_xprt)
> +		goto proc_error;
> +
>  	/* Build the svc_rqst used by the common processing routine */
> -	rqstp->rq_xprt = serv->sv_bc_xprt;
> +	rqstp->rq_xprt = s_xprt;
>  	rqstp->rq_xid = req->rq_xid;
>  	rqstp->rq_prot = req->rq_xprt->prot;
>  	rqstp->rq_server = serv;
> @@ -1494,13 +1500,11 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  
>  	/* Parse and execute the bc call */
>  	proc_error = svc_process_common(rqstp, argv, resv);
> +	svc_xprt_put(rqstp->rq_xprt);
>  
>  	atomic_inc(&req->rq_xprt->bc_free_slots);
> -	if (!proc_error) {
> -		/* Processing error: drop the request */
> -		xprt_free_bc_request(req);
> -		return 0;
> -	}
> +	if (!proc_error)
> +		goto proc_error;
>  
>  	/* Finally, send the reply synchronously */
>  	memcpy(&req->rq_snd_buf, &rqstp->rq_res, sizeof(req->rq_snd_buf));
> @@ -1517,6 +1521,12 @@ bc_svc_process(struct svc_serv *serv, struct rpc_rqst *req,
>  out:
>  	dprintk("svc: %s(), error=%d\n", __func__, error);
>  	return error;
> +
> +proc_error:
> +	/* Processing error: drop the request */
> +	xprt_free_bc_request(req);
> +	error = -EINVAL;
> +	goto out;
>  }
>  EXPORT_SYMBOL_GPL(bc_svc_process);
>  #endif /* CONFIG_SUNRPC_BACKCHANNEL */
> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
> index e5b367a3e517..3e06aeacda43 100644
> --- a/net/sunrpc/xprtrdma/backchannel.c
> +++ b/net/sunrpc/xprtrdma/backchannel.c
> @@ -133,6 +133,11 @@ int xprt_rdma_bc_up(struct svc_serv *serv, struct net *net)
>  	return 0;
>  }
>  
> +struct svc_xprt *xprt_rdma_bc_get_xprt(struct svc_serv *serv, struct net *net)
> +{
> +	return svc_find_xprt(serv, "rdma-bc", net, AF_UNSPEC, 0);
> +}
> +
>  /**
>   * xprt_rdma_bc_maxpayload - Return maximum backchannel message size
>   * @xprt: transport
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index ae2a83828953..41d67de93531 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -828,6 +828,7 @@ static const struct rpc_xprt_ops xprt_rdma_procs = {
>  #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>  	.bc_setup		= xprt_rdma_bc_setup,
>  	.bc_up			= xprt_rdma_bc_up,
> +	.bc_get_xprt		= xprt_rdma_bc_get_xprt,
>  	.bc_maxpayload		= xprt_rdma_bc_maxpayload,
>  	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
>  	.bc_destroy		= xprt_rdma_bc_destroy,
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index a13ccb643ce0..2726d71052a8 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -662,6 +662,7 @@ void xprt_rdma_cleanup(void);
>  #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>  int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
>  int xprt_rdma_bc_up(struct svc_serv *, struct net *);
> +struct svc_xprt *xprt_rdma_bc_get_xprt(struct svc_serv *serv, struct net *net);
>  size_t xprt_rdma_bc_maxpayload(struct rpc_xprt *);
>  int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
>  void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 8a5e823e0b33..16f9c7720465 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -1411,6 +1411,12 @@ static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
>  	return 0;
>  }
>  
> +static struct svc_xprt *xs_tcp_bc_get_xprt(struct svc_serv *serv,
> +					   struct net *net)
> +{
> +	return svc_find_xprt(serv, "tcp-bc", net, AF_UNSPEC, 0);
> +}
> +
>  static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
>  {
>  	return PAGE_SIZE;
> @@ -2668,6 +2674,7 @@ static const struct rpc_xprt_ops xs_tcp_ops = {
>  #ifdef CONFIG_SUNRPC_BACKCHANNEL
>  	.bc_setup		= xprt_setup_bc,
>  	.bc_up			= xs_tcp_bc_up,
> +	.bc_get_xprt		= xs_tcp_bc_get_xprt,
>  	.bc_maxpayload		= xs_tcp_bc_maxpayload,
>  	.bc_free_rqst		= xprt_free_bc_rqst,
>  	.bc_destroy		= xprt_destroy_bc,

Reviewed-by: Jeff Layton <jlayton@kernel.org>

