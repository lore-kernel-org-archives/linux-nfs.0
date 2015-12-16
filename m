Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:56703 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbbLPSti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 13:49:38 -0500
Date: Wed, 16 Dec 2015 11:49:33 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Christoph Hellwig <hch@lst.de>
Cc: chuck.lever@oracle.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] svc_rdma: use local_dma_lkey
Message-ID: <20151216184933.GA11846@obsidianresearch.com>
References: <1450278664-2133-1-git-send-email-hch@lst.de>
 <1450278664-2133-2-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1450278664-2133-2-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2015 at 04:11:04PM +0100, Christoph Hellwig wrote:
> We now alwasy have a per-PD local_dma_lkey available.  Make use of that
> fact in svc_rdma and stop registering our own MR.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -144,6 +144,7 @@ int rdma_read_chunk_lcl(struct svcxprt_rdma *xprt,
>  
>  		head->arg.pages[pg_no] = rqstp->rq_arg.pages[pg_no];
>  		head->arg.page_len += len;
> +
>  		head->arg.len += len;
>  		if (!pg_off)
>  			head->count++;

Was this hunk deliberate?

Jason
