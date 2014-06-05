Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56282 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbaFEQNx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2014 12:13:53 -0400
Date: Thu, 5 Jun 2014 12:13:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH V2] svcrdma: Fence LOCAL_INV work requests
Message-ID: <20140605161353.GH8362@fieldses.org>
References: <20140605145429.14347.22150.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140605145429.14347.22150.stgit@build.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 05, 2014 at 09:54:31AM -0500, Steve Wise wrote:
> This applies on top of:
> 
> 	commit e5a070216356dbcb03607cb264cc3104e17339b3
> 	Author: Steve Wise <swise@opengridcomputing.com>
> 	Date:   Wed May 28 15:12:01 2014 -0500
> 
> 	    svcrdma: refactor marshalling logic

Sorry, I lost track--was there another revision of that patch coming
too?

--b.

> 
> Fencing forces the invalidate to only happen after all prior send
> work requests have been completed.
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 52d9f2c..8f92a61 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -338,7 +338,7 @@ static int rdma_read_chunk_frmr(struct svcxprt_rdma *xprt,
>  		memset(&inv_wr, 0, sizeof(inv_wr));
>  		inv_wr.wr_id = (unsigned long)ctxt;
>  		inv_wr.opcode = IB_WR_LOCAL_INV;
> -		inv_wr.send_flags = IB_SEND_SIGNALED;
> +		inv_wr.send_flags = IB_SEND_SIGNALED | IB_SEND_FENCE;
>  		inv_wr.ex.invalidate_rkey = frmr->mr->lkey;
>  	}
>  	ctxt->wr_op = read_wr.opcode;
> 
