Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34587 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110Ab3CJU2o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Mar 2013 16:28:44 -0400
Date: Sun, 10 Mar 2013 16:28:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tim Gardner <tim.gardner@canonical.com>
Cc: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: Re: [PATCH linux-next] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
Message-ID: <20130310202838.GL31448@fieldses.org>
References: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 10, 2013 at 09:39:13AM -0600, Tim Gardner wrote:
> rpcrdma_register_default_external() is several frames into
> the call stack which goes deeper yet. You run the risk of stack
> corruption by declaring such a large automatic variable,
> so dynamically allocate the array of 'struct ib_phys_buf' objects in
> order to silence the frame-larger-than warning.
> 
> net/sunrpc/xprtrdma/verbs.c: In function 'rpcrdma_register_default_external':
> net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> gcc version 4.6.3
> 
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Tom Tucker <tom@ogc.us>
> Cc: Haggai Eran <haggaie@mellanox.com>
> Cc: Or Gerlitz <ogerlitz@mellanox.com>
> Cc: Shani Michaeli <shanim@mellanox.com>
> Cc: linux-nfs@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c |    7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..0916467 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,9 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>  				  IB_ACCESS_REMOTE_READ);
>  	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf *ipb;
>  	int len, i, rc = 0;
>  
> +	ipb = kmalloc(sizeof(*ipb) * RPCRDMA_MAX_DATA_SEGS, GFP_KERNEL);

Have you checked that this occurs in a context where allocations are OK?
Checking very quickly through the callers I can't see any spinlocks or
anything, but I also don't see any other allocations.

Assuming this is just in rpciod context....  Trond's the authority, but
I think we generally try to avoid allocations here, or make them
GFP_NOFS if we must.

Would it be possible to allocate this array as part of the rpcrdma_req?

--b.

> +	if (!ipb)
> +		return -ENOMEM;
> +
>  	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>  		*nsegs = RPCRDMA_MAX_DATA_SEGS;
>  	for (len = 0, i = 0; i < *nsegs;) {
> @@ -1770,6 +1774,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>  		seg1->mr_len = len;
>  	}
>  	*nsegs = i;
> +	kfree(ipb);
>  	return rc;
>  }
>  
> -- 
> 1.7.9.5
> 
