Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47181 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab2BUVGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Feb 2012 16:06:07 -0500
Date: Tue, 21 Feb 2012 16:06:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [patch] svcrdma: silence a Sparse warning
Message-ID: <20120221210603.GA4326@fieldses.org>
References: <20120221072804.GA6896@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120221072804.GA6896@elgon.mountain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Cc'ing Tom).

On Tue, Feb 21, 2012 at 10:28:04AM +0300, Dan Carpenter wrote:
> Sparse complains that the definition function definition and the
> implementation aren't anotated the same way.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
> index d205e9f..0b8e3e6 100644
> --- a/include/linux/sunrpc/svc_rdma.h
> +++ b/include/linux/sunrpc/svc_rdma.h
> @@ -190,7 +190,7 @@ extern int svc_rdma_xdr_encode_error(struct svcxprt_rdma *,
>  extern void svc_rdma_xdr_encode_write_list(struct rpcrdma_msg *, int);
>  extern void svc_rdma_xdr_encode_reply_array(struct rpcrdma_write_array *, int);
>  extern void svc_rdma_xdr_encode_array_chunk(struct rpcrdma_write_array *, int,
> -					    u32, u64, u32);
> +					    __be32, __be64, u32);
>  extern void svc_rdma_xdr_encode_reply_header(struct svcxprt_rdma *,
>  					     struct rpcrdma_msg *,
>  					     struct rpcrdma_msg *,
