Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47890 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757732AbaGWPAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jul 2014 11:00:44 -0400
Date: Wed, 23 Jul 2014 11:00:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svcrdma: Double the default credit limit
Message-ID: <20140723150044.GW8438@fieldses.org>
References: <20140722214804.3398.34829.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140722214804.3398.34829.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 22, 2014 at 05:48:04PM -0400, Chuck Lever wrote:
> The RDMA credit limit controls how many concurrent RPCs are allowed
> per connection.
> 
> An NFS/RDMA client and server exchange their credit limits in the
> RPC/RDMA headers. The Linux client and the Solaris client and server
> allow 32 credits. The Linux server allows only 16, which limits its
> performance.
> 
> Set the server's default credit limit to 32, like the other well-
> known implementations, so the out-of-the-shrinkwrap performance of
> the Linux server is better.

Thanks, applying for 3.17.--b.

> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  include/linux/sunrpc/svc_rdma.h |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index 5cf99a0..975da75 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -174,8 +174,7 @@ struct svcxprt_rdma {
>   * page size of 4k, or 32k * 2 ops / 4k = 16 outstanding RDMA_READ.  */
>  #define RPCRDMA_ORD             (64/4)
>  #define RPCRDMA_SQ_DEPTH_MULT   8
> -#define RPCRDMA_MAX_THREADS     16
> -#define RPCRDMA_MAX_REQUESTS    16
> +#define RPCRDMA_MAX_REQUESTS    32
>  #define RPCRDMA_MAX_REQ_SIZE    4096
>  
>  /* svc_rdma_marshal.c */
> 
