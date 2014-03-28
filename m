Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39638 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757242AbaC1CIk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2014 22:08:40 -0400
Date: Thu, 27 Mar 2014 22:08:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH] Fix regression in NFSRDMA server
Message-ID: <20140328020834.GD27633@fieldses.org>
References: <20140325201457.6861.21819.stgit@build.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140325201457.6861.21819.stgit@build.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 25, 2014 at 03:14:57PM -0500, Steve Wise wrote:
> From: Tom Tucker <tom@ogc.us>
> 
> The server regression was caused by the addition of rq_next_page
> (afc59400d6c65bad66d4ad0b2daf879cbff8e23e). There were a few places that
> were missed with the update of the rq_respages array.

Apologies.  (But, it could happen again--could we set up some regular
testing?  It doesn't have to be anything fancy, just cthon over
rdma--really, just read and write over rdma--would probably catch a
lot.)

Also: I don't get why all these rq_next_page initializations are
required.  Why isn't the initialization at the top of svc_process()
enough?  Is rdma using it before we get to that point?  The only use of
it I see off hand is in the while loop that you're deleting.

--b.

> 
> Signed-off-by: Tom Tucker <tom@ogc.us>
> Tested-by: Steve Wise <swise@ogc.us>
> ---
> 
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   12 ++++--------
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c   |    1 +
>  2 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> index 0ce7552..8d904e4 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
> @@ -90,6 +90,7 @@ static void rdma_build_arg_xdr(struct svc_rqst *rqstp,
>  		sge_no++;
>  	}
>  	rqstp->rq_respages = &rqstp->rq_pages[sge_no];
> +	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  
>  	/* We should never run out of SGE because the limit is defined to
>  	 * support the max allowed RPC data length
> @@ -169,6 +170,7 @@ static int map_read_chunks(struct svcxprt_rdma *xprt,
>  		 */
>  		head->arg.pages[page_no] = rqstp->rq_arg.pages[page_no];
>  		rqstp->rq_respages = &rqstp->rq_arg.pages[page_no+1];
> +		rqstp->rq_next_page = rqstp->rq_respages + 1;
>  
>  		byte_count -= sge_bytes;
>  		ch_bytes -= sge_bytes;
> @@ -276,6 +278,7 @@ static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
>  
>  	/* rq_respages points one past arg pages */
>  	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> +	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  
>  	/* Create the reply and chunk maps */
>  	offset = 0;
> @@ -520,13 +523,6 @@ next_sge:
>  	for (ch_no = 0; &rqstp->rq_pages[ch_no] < rqstp->rq_respages; ch_no++)
>  		rqstp->rq_pages[ch_no] = NULL;
>  
> -	/*
> -	 * Detach res pages. If svc_release sees any it will attempt to
> -	 * put them.
> -	 */
> -	while (rqstp->rq_next_page != rqstp->rq_respages)
> -		*(--rqstp->rq_next_page) = NULL;
> -
>  	return err;
>  }
>  
> @@ -550,7 +546,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
>  
>  	/* rq_respages starts after the last arg page */
>  	rqstp->rq_respages = &rqstp->rq_arg.pages[page_no];
> -	rqstp->rq_next_page = &rqstp->rq_arg.pages[page_no];
> +	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  
>  	/* Rebuild rq_arg head and tail. */
>  	rqstp->rq_arg.head[0] = head->arg.head[0];
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> index c1d124d..11e90f8 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
> @@ -625,6 +625,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>  		if (page_no+1 >= sge_no)
>  			ctxt->sge[page_no+1].length = 0;
>  	}
> +	rqstp->rq_next_page = rqstp->rq_respages + 1;
>  	BUG_ON(sge_no > rdma->sc_max_sge);
>  	memset(&send_wr, 0, sizeof send_wr);
>  	ctxt->wr_op = IB_WR_SEND;
> 
