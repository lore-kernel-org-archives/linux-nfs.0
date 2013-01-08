Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60634 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756442Ab3AHOqJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2013 09:46:09 -0500
Date: Tue, 8 Jan 2013 09:46:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joe Perches <joe@perches.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tom Tucker <tom@ogc.us>, steved@redhat.com,
        Tom Talpey <ttalpey@microsoft.com>
Subject: Re: [PATCH] sunrpc: verbs: Avoid 1kb stack
Message-ID: <20130108144604.GB16343@fieldses.org>
References: <1357587696.21481.48.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1357587696.21481.48.camel@joe-AO722>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2013 at 11:41:36AM -0800, Joe Perches wrote:
> 16 * 64 is a bit much.
> Use kmalloc_array instead.

I thought there was some reason we didn't do this.

Grepping up through the callers....  It looks like the result is
xprt_rdma_send_request returns -EIO, and as far as I can tell that gets
passed up to the application on the client.   That doesn't sound right.

--b.

> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 745973b..9cfebb4 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,8 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>  	int len, i, rc = 0;
> +	struct ib_phys_buf *ipb = kmalloc_array(RPCRDMA_MAX_DATA_SEGS,
> +						sizeof(*ipb),
> +						GFP_KERNEL);
> +
> +	if (!ipb)
> +		return -ENOMEM;
>  
>  	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>  		*nsegs = RPCRDMA_MAX_DATA_SEGS;
> @@ -1770,6 +1775,9 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  		seg1->mr_len = len;
>  	}
>  	*nsegs = i;
> +
> +	kfree(ipb);
> +
>  	return rc;
>  }
>  
> 
> 
