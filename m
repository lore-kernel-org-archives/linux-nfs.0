Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:59878 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbaAMQH5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 11:07:57 -0500
Received: by mail-ie0-f181.google.com with SMTP id at1so490941iec.26
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jan 2014 08:07:57 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] xprtrdma: silence frame size warning
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1389627955.20467.9.camel@x41>
Date: Mon, 13 Jan 2014 10:59:40 -0500
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        "Miller David S." <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
References: <1389627955.20467.9.camel@x41>
To: Paul Bolle <pebolle@tiscali.nl>,
        Lever Charles Edward <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 13, 2014, at 10:45, Paul Bolle <pebolle@tiscali.nl> wrote:

> Building verbs.o on 32 bits x86, with CONFIG_FRAME_WARN set to 1024, its
> default value, triggers this GCC warning:
>    net/sunrpc/xprtrdma/verbs.c: In function ‘rpcrdma_register_default_external’:
>    net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1040 bytes is larger than 1024 bytes [-Wframe-larger-than=]
> 
> Silence this warning by allocating "ipb" dynamically.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> 0) Compile tested only (on 32 bits x86). I don't have access to
> Infiniband hardware.
> 
> 1) Please note that this is not a new warning. The oldest build log I
> have still available on this machine is for a v3.8 rc, and it already
> showed this warning. 
> 
> 2) I do hope my choice for the GFP_KERNEL flag is correct here.
> 
> net/sunrpc/xprtrdma/verbs.c | 6 +++++-
> 1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 93726560..939ccc8 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -1736,11 +1736,14 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
> 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
> 				  IB_ACCESS_REMOTE_READ);
> 	struct rpcrdma_mr_seg *seg1 = seg;
> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
> +	struct ib_phys_buf *ipb;
> 	int len, i, rc = 0;
> 
> 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
> 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
> +	ipb = kmalloc(sizeof(*ipb) * *nsegs, GFP_KERNEL);
> +	if (ipb == NULL)
> +		return -ENOMEM;
> 	for (len = 0, i = 0; i < *nsegs;) {
> 		rpcrdma_map_one(ia, seg, writing);
> 		ipb[i].addr = seg->mr_dma;
> @@ -1770,6 +1773,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
> 		seg1->mr_len = len;
> 	}
> 	*nsegs = i;
> +	kfree(ipb);
> 	return rc;
> }

Hi Paul,

Unfortunately, the above could be called from a file write back context, so we cannot use GFP_KERNEL allocations. In fact, I suspect we should only use GFP_ATOMIC, and then have the rpc_task delay and retry if the allocation fails.

The problem is that it looks to me as if xprt_rdma_send_request will currently fail, if we return an error from rpcrdma_register_default_external.

Chuck, will you be able to look into the above issue as part of your RDMA work?

Cheers
  Trond

--
Trond Myklebust
Linux NFS client maintainer

