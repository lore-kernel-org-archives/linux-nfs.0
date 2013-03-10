Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:39669 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751619Ab3CJRQH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Mar 2013 13:16:07 -0400
Message-ID: <513CBFD6.1000504@opengridcomputing.com>
Date: Sun, 10 Mar 2013 12:16:06 -0500
From: Tom Tucker <tom@opengridcomputing.com>
MIME-Version: 1.0
To: Tim Gardner <tim.gardner@canonical.com>
CC: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH linux-next] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
References: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com>
In-Reply-To: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is the result of 2773395b34883fe54418de188733a63bb38e0ad6. Steve 
might want to weigh in on this since it was done for performance reasons.

Tom

On 3/10/13 10:39 AM, Tim Gardner wrote:
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
>   net/sunrpc/xprtrdma/verbs.c |    7 ++++++-
>   1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..0916467 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,9 +1736,13 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>   	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>   				  IB_ACCESS_REMOTE_READ);
>   	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf *ipb;
>   	int len, i, rc = 0;
>   
> +	ipb = kmalloc(sizeof(*ipb) * RPCRDMA_MAX_DATA_SEGS, GFP_KERNEL);
> +	if (!ipb)
> +		return -ENOMEM;
> +
>   	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>   		*nsegs = RPCRDMA_MAX_DATA_SEGS;
>   	for (len = 0, i = 0; i < *nsegs;) {
> @@ -1770,6 +1774,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>   		seg1->mr_len = len;
>   	}
>   	*nsegs = i;
> +	kfree(ipb);
>   	return rc;
>   }
>   

