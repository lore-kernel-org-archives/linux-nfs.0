Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35960 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751786AbeEPSPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 May 2018 14:15:24 -0400
Date: Wed, 16 May 2018 14:15:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, dan.carpenter@oracle.com
Subject: Re: [PATCH] svcrdma: Fix incorrect return value/type in
 svc_rdma_post_recvs
Message-ID: <20180516181523.GB6016@fieldses.org>
References: <20180514172006.2217.10418.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180514172006.2217.10418.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!

--b.

On Mon, May 14, 2018 at 01:20:06PM -0400, Chuck Lever wrote:
> This crept in during the development process and wasn't caught
> before I posted the "final" version.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 0b2613c5883f ('svcrdma: Allocate recv_ctxt's on CPU ... ')
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 09ce09b..841fca1 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -270,7 +270,7 @@ bool svc_rdma_post_recvs(struct svcxprt_rdma *rdma)
>  	for (i = 0; i < rdma->sc_max_requests; i++) {
>  		ctxt = svc_rdma_recv_ctxt_get(rdma);
>  		if (!ctxt)
> -			return -ENOMEM;
> +			return false;
>  		ctxt->rc_temp = true;
>  		ret = __svc_rdma_post_recv(rdma, ctxt);
>  		if (ret) {
