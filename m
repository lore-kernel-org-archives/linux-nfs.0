From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 33/38] svc: Add transport hdr size for defer/revisit
Date: Fri, 30 Nov 2007 18:51:30 -0500
Message-ID: <B4CC1EA5-5718-4F50-B3EB-8A77A4CE7F0A@oracle.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224103.14563.72780.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:23894 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755434AbXK3Xvz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 18:51:55 -0500
In-Reply-To: <20071129224103.14563.72780.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:41 PM, Tom Tucker wrote:
> Some transports have a header in front of the RPC header. The current
> defer/revisit processing considers only the iov_len and arg_len to
> determine how much to back up when saving the original request
> to revisit. Add a field to the rqstp structure to save the size
> of the transport header so svc_defer can correctly compute
> the start of a request.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  include/linux/sunrpc/svc.h |    2 ++
>  net/sunrpc/svc_xprt.c      |   36 ++++++++++++++++++++++++++ 
> +---------
>  net/sunrpc/svcsock.c       |    2 ++
>  3 files changed, 31 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 04eb20e..f2ada2a 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -217,6 +217,7 @@ struct svc_rqst {
>  	void *			rq_xprt_ctxt;	/* transport specific context ptr */
>  	struct svc_deferred_req*rq_deferred;	/* deferred request we are  
> replaying */
>
> +	size_t			rq_xprt_hlen;	/* xprt header len */
>  	struct xdr_buf		rq_arg;
>  	struct xdr_buf		rq_res;
>  	struct page *		rq_pages[RPCSVC_MAXPAGES];
> @@ -322,6 +323,7 @@ struct svc_deferred_req {
>  	size_t			addrlen;
>  	union svc_addr_u	daddr;	/* where reply must come from */
>  	struct cache_deferred_req handle;
> +	int			xprt_hlen;
>  	int			argslen;
>  	__be32			args[0];
>  };

Why is xprt_hlen an int if rq_xprt_hlen is a size_t?  Shouldn't they  
both be size_t?

I don't see xprt_hlen going negative, but it is used in a bunch of  
computations involving unsigned ints and size_ts.  Since size_t can  
be wider than 32 bits on non-i386, I think we should be defensive  
about not using ints as temporary variables when doing computations  
with iov_base and iov_len.

> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 56204e9..b31ba0e 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -29,7 +29,6 @@
>  #include <linux/sunrpc/types.h>
>  #include <linux/sunrpc/clnt.h>
>  #include <linux/sunrpc/xdr.h>
> -#include <linux/sunrpc/svcsock.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/svc_xprt.h>
>
> @@ -827,10 +826,18 @@ static void svc_revisit(struct  
> cache_deferred_req *dreq, int too_many)
>  	svc_xprt_put(xprt);
>  }
>
> +/*
> + * Save the request off for later processing. The request buffer  
> looks
> + * like this:
> + *
> + * <xprt-header><rpc-header><rpc-pagelist><rpc-tail>
> + *
> + * This code can only handle requests that consist of an xprt-header
> + * and rpc-header.
> + */
>  static struct cache_deferred_req *svc_defer(struct cache_req *req)
>  {
>  	struct svc_rqst *rqstp = container_of(req, struct svc_rqst,  
> rq_chandle);
> -	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
>  	struct svc_deferred_req *dr;
>
>  	if (rqstp->rq_arg.page_len)
> @@ -839,8 +846,10 @@ static struct cache_deferred_req *svc_defer 
> (struct cache_req *req)
>  		dr = rqstp->rq_deferred;
>  		rqstp->rq_deferred = NULL;
>  	} else {
> -		int skip  = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
> +		int skip;
> +		int size;

How about:

	size_t size, skip;

instead?

>  		/* FIXME maybe discard if size too large */
> +		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
>  		dr = kmalloc(size, GFP_KERNEL);
>  		if (dr == NULL)
>  			return NULL;
> @@ -851,8 +860,12 @@ static struct cache_deferred_req *svc_defer 
> (struct cache_req *req)
>  		dr->addrlen = rqstp->rq_addrlen;
>  		dr->daddr = rqstp->rq_daddr;
>  		dr->argslen = rqstp->rq_arg.len >> 2;
> -		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip,
> -		       dr->argslen<<2);
> +		dr->xprt_hlen = rqstp->rq_xprt_hlen;
> +
> +		/* back up head to the start of the buffer and copy */
> +		skip = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
> +		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base - skip,
> +		       dr->argslen << 2);
>  	}
>  	svc_xprt_get(rqstp->rq_xprt);
>  	dr->xprt = rqstp->rq_xprt;
> @@ -868,16 +881,21 @@ static int svc_deferred_recv(struct svc_rqst  
> *rqstp)
>  {
>  	struct svc_deferred_req *dr = rqstp->rq_deferred;
>
> -	rqstp->rq_arg.head[0].iov_base = dr->args;
> -	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
> +	/* setup iov_base past transport header */
> +	rqstp->rq_arg.head[0].iov_base = dr->args + (dr->xprt_hlen>>2);
> +	/* The iov_len does not include the transport header bytes */
> +	rqstp->rq_arg.head[0].iov_len = (dr->argslen<<2) - dr->xprt_hlen;
>  	rqstp->rq_arg.page_len = 0;
> -	rqstp->rq_arg.len = dr->argslen<<2;
> +	/* The rq_arg.len includes the transport header bytes */
> +	rqstp->rq_arg.len     = dr->argslen<<2;
>  	rqstp->rq_prot        = dr->prot;
>  	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
>  	rqstp->rq_addrlen     = dr->addrlen;
> +	/* Save off transport header len in case we get deferred again */
> +	rqstp->rq_xprt_hlen   = dr->xprt_hlen;
>  	rqstp->rq_daddr       = dr->daddr;
>  	rqstp->rq_respages    = rqstp->rq_pages;
> -	return dr->argslen<<2;
> +	return (dr->argslen<<2) - dr->xprt_hlen;
>  }
>
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 23a2ab6..03207c9 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -397,6 +397,8 @@ svc_recvfrom(struct svc_rqst *rqstp, struct  
> kvec *iov, int nr, int buflen)
>  	};
>  	int len;
>
> +	rqstp->rq_xprt_hlen = 0;
> +
>  	len = kernel_recvmsg(svsk->sk_sock, &msg, iov, nr, buflen,
>  				msg.msg_flags);
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux- 
> nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



