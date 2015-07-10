Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:26906 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932620AbbGJT2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 15:28:48 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 02/12] xprtrdma: Raise maximum payload size to one
 megabyte
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204159.26247.44592.stgit@manet.1015granger.net>
Message-ID: <55A01B56.2020107@Netapp.com>
Date: Fri, 10 Jul 2015 15:21:58 -0400
MIME-Version: 1.0
In-Reply-To: <20150709204159.26247.44592.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On 07/09/2015 04:41 PM, Chuck Lever wrote:
> The point of larger rsize and wsize is to reduce the per-byte cost
> of memory registration and deregistration. Modern HCAs can typically
> handle a megabyte or more with a single registration operation.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  net/sunrpc/xprtrdma/xprt_rdma.h |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
> index f49dd8b..abee472 100644
> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
> @@ -165,8 +165,7 @@ rdmab_to_msg(struct rpcrdma_regbuf *rb)
>   * struct rpcrdma_buffer. N is the max number of outstanding requests.
>   */
>  
> -/* temporary static scatter/gather max */
> -#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
> +#define RPCRDMA_MAX_DATA_SEGS	((1 * 1024 * 1024) / PAGE_SIZE)
                                         ^^^
What is the significance of the 1 here?

Thanks,
Anna

>  #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
>  
>  struct rpcrdma_buffer;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

