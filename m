From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Tue, 4 Dec 2007 16:12:04 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712041558220.7142@jlentini-linux.nane.netapp.com>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28820 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbXLDVM1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2007 16:12:27 -0500
In-Reply-To: <Pine.LNX.4.64.0711291521010.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond,

I wanted to make sure this didn't get lost in the shuffle. This fixes 
an observed problem. Does this look appropriate for 2.6.24?

james

On Thu, 29 Nov 2007, James Lentini wrote:

> 
> In some instances, the code in rpcrdma_convert_iovs was failing to 
> include a chunk for the xdr tail. This was caused by defensive code 
> that checked if the current xdr pos was greater than the total xdr 
> length before encoding the tail. However, the xdr->len is 0 for 
> non-write operations, and therefore this check was invalid for such 
> operations.
> 
> With this change, the tail will always be marshaled when present. This 
> makes the maintenance of the pos index unnecessary. The test of 
> xdrbuf->len to decide if a message should be logged is also incorrect.
> 
> This fixes an observed problem when reading certain file sizes over 
> NFS/RDMA. Please consider this for 2.6.24.
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> Signed-off-by: Tom Talpey <talpey@netapp.com>
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
> ---
>  net/sunrpc/xprtrdma/rpc_rdma.c |    9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> --- a/net/sunrpc/xprtrdma/rpc_rdma.c
> +++ b/net/sunrpc/xprtrdma/rpc_rdma.c
> @@ -92,7 +92,6 @@
>  		seg[n].mr_page = NULL;
>  		seg[n].mr_offset = xdrbuf->head[0].iov_base;
>  		seg[n].mr_len = xdrbuf->head[0].iov_len;
> -		pos += xdrbuf->head[0].iov_len;
>  		++n;
>  	}
>  
> @@ -104,7 +103,6 @@
>  		seg[n].mr_len = min_t(u32,
>  			PAGE_SIZE - xdrbuf->page_base, xdrbuf->page_len);
>  		len = xdrbuf->page_len - seg[n].mr_len;
> -		pos += len;
>  		++n;
>  		p = 1;
>  		while (len > 0) {
> @@ -119,20 +117,15 @@
>  		}
>  	}
>  
> -	if (pos < xdrbuf->len && xdrbuf->tail[0].iov_len) {
> +	if (xdrbuf->tail[0].iov_len) {
>  		if (n == nsegs)
>  			return 0;
>  		seg[n].mr_page = NULL;
>  		seg[n].mr_offset = xdrbuf->tail[0].iov_base;
>  		seg[n].mr_len = xdrbuf->tail[0].iov_len;
> -		pos += xdrbuf->tail[0].iov_len;
>  		++n;
>  	}
>  
> -	if (pos < xdrbuf->len)
> -		dprintk("RPC:       %s: marshaled only %d of %d\n",
> -				__func__, pos, xdrbuf->len);
> -
>  	return n;
>  }
>  
> 
