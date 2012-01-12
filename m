Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38718 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927Ab2ALQVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jan 2012 11:21:46 -0500
Date: Thu, 12 Jan 2012 11:21:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [patch] svcrdma: endian bug in send_write_chunks()
Message-ID: <20120112162141.GC6563@fieldses.org>
References: <20120112064722.GB2408@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120112064722.GB2408@elgon.mountain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 12, 2012 at 09:47:22AM +0300, Dan Carpenter wrote:
> Sparse complains because arg_ch->rs_length is declared as network
> endian but we're treating it as CPU endian.

This looks like it would actually change behavior on a little endian
architecture, so how did this work before?

>From some quick grepping, I see assignments both of the form

	...rs_length = ntohl(...)

and

	...rs_length = htonl(...)

but only see one declaration for a field named rs_length.

So my best guess would be that the code is ugly but working as is, and
needs cleanup by someone who knows how this field was intended to be
used.

?

--b.

> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index 249a835..30fda86 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -409,7 +409,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>  		u64 rs_offset;
>  
>  		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
> -		write_len = min(xfer_len, arg_ch->rs_length);
> +		write_len = min(xfer_len, ntohl(arg_ch->rs_length));
>  
>  		/* Prepare the response chunk given the length actually
>  		 * written */
> @@ -481,7 +481,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
>  	     chunk_no++) {
>  		u64 rs_offset;
>  		ch = &arg_ary->wc_array[chunk_no].wc_target;
> -		write_len = min(xfer_len, ch->rs_length);
> +		write_len = min(xfer_len, ntohl(ch->rs_length));
>  
>  		/* Prepare the reply chunk given the length actually
>  		 * written */
