From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  7/17] svcrdma: Fix error handling during listening
	endpoint creation
Date: Mon, 5 May 2008 18:41:40 -0400
Message-ID: <20080505224140.GI12814@fieldses.org>
References: <12097457211122-git-send-email-tom@opengridcomputing.com> <12097457223433-git-send-email-tom@opengridcomputing.com> <12097457223971-git-send-email-tom@opengridcomputing.com> <12097457223635-git-send-email-tom@opengridcomputing.com> <12097457223351-git-send-email-tom@opengridcomputing.com> <12097457221640-git-send-email-tom@opengridcomputing.com> <120974572253-git-send-email-tom@opengridcomputing.com> <12097457223519-git-send-email-tom@opengridcomputing.com> <12097457223927-git-send-email-tom@opengridcomputing.com> <12097457232986-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33164 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761479AbYEEWll (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 18:41:41 -0400
In-Reply-To: <12097457232986-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:28:39AM -0500, Tom Tucker wrote:
> A listening endpoint isn't known to the generic transport switch until
> the svc_create_xprt function returns without error. Calling
> svc_xprt_put within the xpo_create function causes the module reference
> count to be erroneously decremented.

There's some redundant code in these three error paths; would the usual
kernel-style "goto cleanup" thing help?

--b.

> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> 
> ---
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> index 83818cf..0d9a828 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
> @@ -669,7 +669,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  
>  	listen_id = rdma_create_id(rdma_listen_handler, cma_xprt, RDMA_PS_TCP);
>  	if (IS_ERR(listen_id)) {
> -		svc_xprt_put(&cma_xprt->sc_xprt);
> +		kfree(cma_xprt);
>  		dprintk("svcrdma: rdma_create_id failed = %ld\n",
>  			PTR_ERR(listen_id));
>  		return (void *)listen_id;
> @@ -677,7 +677,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  	ret = rdma_bind_addr(listen_id, sa);
>  	if (ret) {
>  		rdma_destroy_id(listen_id);
> -		svc_xprt_put(&cma_xprt->sc_xprt);
> +		kfree(cma_xprt);
>  		dprintk("svcrdma: rdma_bind_addr failed = %d\n", ret);
>  		return ERR_PTR(ret);
>  	}
> @@ -686,7 +686,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
>  	ret = rdma_listen(listen_id, RPCRDMA_LISTEN_BACKLOG);
>  	if (ret) {
>  		rdma_destroy_id(listen_id);
> -		svc_xprt_put(&cma_xprt->sc_xprt);
> +		kfree(cma_xprt);
>  		dprintk("svcrdma: rdma_listen failed = %d\n", ret);
>  		return ERR_PTR(ret);
>  	}
