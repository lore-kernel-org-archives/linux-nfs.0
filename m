From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 02/11] svcrdma: Use RPC reply map for RDMA_WRITE	processing
Date: Sat, 21 Jun 2008 11:26:52 -0500
Message-ID: <485D2BCC.9000508@opengridcomputing.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com> <12120836963727-git-send-email-tom@opengridcomputing.com> <20080616210442.GB29446@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:51456 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750892AbYFUQ0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jun 2008 12:26:52 -0400
In-Reply-To: <20080616210442.GB29446@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, May 29, 2008 at 12:54:47PM -0500, Tom Tucker wrote:
>   
>> Use the new svc_rdma_req_map data type for mapping the client side memory
>> to the server side memory. Move the DMA mapping to the context pointed to
>> by each WR individually so that it is unmapped after the WR completes.
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>
>> ---
>>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  122 ++++++++++++++----------------
>>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
>>  2 files changed, 62 insertions(+), 65 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> index fb82b1b..7cd65b7 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
>> @@ -64,10 +64,9 @@
>>   * SGE[sge_count-1]    data from xdr->tail.
>>   *
>>   */
>> -static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>> -				 struct xdr_buf *xdr,
>> -				 struct ib_sge *sge,
>> -				 int *sge_count)
>> +static void xdr_to_sge(struct svcxprt_rdma *xprt,
>> +		       struct xdr_buf *xdr,
>> +		       struct svc_rdma_req_map *vec)
>>  {
>>  	/* Max we need is the length of the XDR / pagesize + one for
>>  	 * head + one for tail + one for RPCRDMA header
>> @@ -84,14 +83,10 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>  	sge_no = 1;
>>     
>
> Should the arrays in the svc_rdma_req_map actually be size
> RPC_SVC_MAXPAGES+1 to allow for the RPCRDMA header?
>   
Yes, I think this is a bug. I'm going to clamp max data in a different 
way in an upcomeing patch. So this will change in a subsequent patch.

> Also, the only caller of xdr_to_sge() appears to be svc_rdma_sendto(),
> which is called from svc_sendto() immediately after setting:
>
> 	xb = &rqstp->rq_res;
> 	xb->len = xb->head[0].iov_len + 
> 		xb->page_len +
> 		xb->tail[0].iov_len;
>
> So I think xdr_to_sge() is doing a bunch of unnecessary work to handle
> the case where xdr->len could be less than that sum?
>
>   
Ok... check me below please.
>>  
>>  	/* Head SGE */
>> -	sge[sge_no].addr = ib_dma_map_single(xprt->sc_cm_id->device,
>> -					     xdr->head[0].iov_base,
>> -					     xdr->head[0].iov_len,
>> -					     DMA_TO_DEVICE);
>> +	vec->sge[sge_no].iov_base = xdr->head[0].iov_base;
>>  	sge_bytes = min_t(u32, byte_count, xdr->head[0].iov_len);
>>     

This doesn't need to be min_t. It could be xdr->head[0].iov_len.

>>  	byte_count -= sge_bytes;
>> -	sge[sge_no].length = sge_bytes;
>> -	sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>> +	vec->sge[sge_no].iov_len = sge_bytes;
>>  	sge_no++;
>>  
>>  	/* pages SGE */
>> @@ -99,16 +94,13 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>  	page_bytes = xdr->page_len;
>>  	page_off = xdr->page_base;
>>  	while (byte_count && page_bytes) {
>> +		vec->sge[sge_no].iov_base =
>> +			page_address(xdr->pages[page_no]) + page_off;
>>  		sge_bytes = min_t(u32, byte_count, (PAGE_SIZE-page_off));
>>     
This is still needed if the xdr terminates with a portion of a page and 
there is not tail.
>> -		sge[sge_no].addr =
>> -			ib_dma_map_page(xprt->sc_cm_id->device,
>> -					xdr->pages[page_no], page_off,
>> -					sge_bytes, DMA_TO_DEVICE);
>>  		sge_bytes = min(sge_bytes, page_bytes);
>>  		byte_count -= sge_bytes;
>>  		page_bytes -= sge_bytes;
>> -		sge[sge_no].length = sge_bytes;
>> -		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>> +		vec->sge[sge_no].iov_len = sge_bytes;
>>  
>>  		sge_no++;
>>  		page_no++;
>> @@ -117,23 +109,17 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>  
>>  	/* Tail SGE */
>>  	if (byte_count && xdr->tail[0].iov_len) {
>>     
This is defensive. It could just be byte_count.
If byte_count != xdr->tail[0].iov_len, the BUG_ON below will let us know.
>> -		sge[sge_no].addr =
>> -			ib_dma_map_single(xprt->sc_cm_id->device,
>> -					  xdr->tail[0].iov_base,
>> -					  xdr->tail[0].iov_len,
>> -					  DMA_TO_DEVICE);
>> +		vec->sge[sge_no].iov_base = xdr->tail[0].iov_base;
>>  		sge_bytes = min_t(u32, byte_count, xdr->tail[0].iov_len);
>>     
The min_t isn't needed. It could just be byte_count.
>>  		byte_count -= sge_bytes;
>> -		sge[sge_no].length = sge_bytes;
>> -		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>> +		vec->sge[sge_no].iov_len = sge_bytes;
>>  		sge_no++;
>>  	}
>>  
>>  	BUG_ON(sge_no > sge_max);
>>  	BUG_ON(byte_count != 0);
>>  
>> -	*sge_count = sge_no;
>> -	return sge;
>> +	vec->count = sge_no;
>>  }
>>  
>>  
>> @@ -143,9 +129,8 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>  static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
>>  		      u32 rmr, u64 to,
>>  		      u32 xdr_off, int write_len,
>> -		      struct ib_sge *xdr_sge, int sge_count)
>> +		      struct svc_rdma_req_map *vec)
>>  {
>> -	struct svc_rdma_op_ctxt *tmp_sge_ctxt;
>>  	struct ib_send_wr write_wr;
>>  	struct ib_sge *sge;
>>  	int xdr_sge_no;
>> @@ -156,23 +141,22 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
>>  	struct svc_rdma_op_ctxt *ctxt;
>>  	int ret = 0;
>>  
>> -	BUG_ON(sge_count > RPCSVC_MAXPAGES);
>> +	BUG_ON(vec->count > RPCSVC_MAXPAGES);
>>  	dprintk("svcrdma: RDMA_WRITE rmr=%x, to=%llx, xdr_off=%d, "
>> -		"write_len=%d, xdr_sge=%p, sge_count=%d\n",
>> +		"write_len=%d, vec->sge=%p, vec->count=%lu\n",
>>  		rmr, (unsigned long long)to, xdr_off,
>> -		write_len, xdr_sge, sge_count);
>> +		write_len, vec->sge, vec->count);
>>  
>>  	ctxt = svc_rdma_get_context(xprt);
>> -	ctxt->count = 0;
>> -	tmp_sge_ctxt = svc_rdma_get_context(xprt);
>> -	sge = tmp_sge_ctxt->sge;
>> +	ctxt->direction = DMA_TO_DEVICE;
>> +	sge = ctxt->sge;
>>  
>>  	/* Find the SGE associated with xdr_off */
>> -	for (bc = xdr_off, xdr_sge_no = 1; bc && xdr_sge_no < sge_count;
>> +	for (bc = xdr_off, xdr_sge_no = 1; bc && xdr_sge_no < vec->count;
>>  	     xdr_sge_no++) {
>> -		if (xdr_sge[xdr_sge_no].length > bc)
>> +		if (vec->sge[xdr_sge_no].iov_len > bc)
>>  			break;
>> -		bc -= xdr_sge[xdr_sge_no].length;
>> +		bc -= vec->sge[xdr_sge_no].iov_len;
>>  	}
>>  
>>  	sge_off = bc;
>> @@ -180,21 +164,27 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
>>  	sge_no = 0;
>>  
>>  	/* Copy the remaining SGE */
>> -	while (bc != 0 && xdr_sge_no < sge_count) {
>> -		sge[sge_no].addr = xdr_sge[xdr_sge_no].addr + sge_off;
>> -		sge[sge_no].lkey = xdr_sge[xdr_sge_no].lkey;
>> +	while (bc != 0 && xdr_sge_no < vec->count) {
>> +		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>>  		sge_bytes = min((size_t)bc,
>> -				(size_t)(xdr_sge[xdr_sge_no].length-sge_off));
>> +				(size_t)(vec->sge[xdr_sge_no].iov_len-sge_off));
>>  		sge[sge_no].length = sge_bytes;
>> -
>> +		sge[sge_no].addr =
>> +			ib_dma_map_single(xprt->sc_cm_id->device,
>> +					  (void *)
>> +					  vec->sge[xdr_sge_no].iov_base + sge_off,
>> +					  sge_bytes, DMA_TO_DEVICE);
>> +		if (dma_mapping_error(sge[sge_no].addr))
>> +			return -EINVAL;
>>     
>
> We leak a svc_rdma_op_ctxt on error here.
>   
Ok.
> --b.
>
>   
>>  		sge_off = 0;
>>  		sge_no++;
>> +		ctxt->count++;
>>  		xdr_sge_no++;
>>  		bc -= sge_bytes;
>>  	}
>>  
>>  	BUG_ON(bc != 0);
>> -	BUG_ON(xdr_sge_no > sge_count);
>> +	BUG_ON(xdr_sge_no > vec->count);
>>  
>>  	/* Prepare WRITE WR */
>>  	memset(&write_wr, 0, sizeof write_wr);
>> @@ -210,11 +200,10 @@ static int send_write(struct svcxprt_rdma *xprt, struct svc_rqst *rqstp,
>>  	/* Post It */
>>  	atomic_inc(&rdma_stat_write);
>>  	if (svc_rdma_send(xprt, &write_wr)) {
>> -		svc_rdma_put_context(ctxt, 1);
>> +		svc_rdma_put_context(ctxt, 0);
>>  		/* Fatal error, close transport */
>>  		ret = -EIO;
>>  	}
>> -	svc_rdma_put_context(tmp_sge_ctxt, 0);
>>  	return ret;
>>  }
>>  
>> @@ -222,8 +211,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>>  			     struct rpcrdma_msg *rdma_argp,
>>  			     struct rpcrdma_msg *rdma_resp,
>>  			     struct svc_rqst *rqstp,
>> -			     struct ib_sge *sge,
>> -			     int sge_count)
>> +			     struct svc_rdma_req_map *vec)
>>  {
>>  	u32 xfer_len = rqstp->rq_res.page_len + rqstp->rq_res.tail[0].iov_len;
>>  	int write_len;
>> @@ -269,8 +257,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
>>  					 rs_offset + chunk_off,
>>  					 xdr_off,
>>  					 this_write,
>> -					 sge,
>> -					 sge_count);
>> +					 vec);
>>  			if (ret) {
>>  				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
>>  					ret);
>> @@ -292,8 +279,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
>>  			     struct rpcrdma_msg *rdma_argp,
>>  			     struct rpcrdma_msg *rdma_resp,
>>  			     struct svc_rqst *rqstp,
>> -			     struct ib_sge *sge,
>> -			     int sge_count)
>> +			     struct svc_rdma_req_map *vec)
>>  {
>>  	u32 xfer_len = rqstp->rq_res.len;
>>  	int write_len;
>> @@ -341,8 +327,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
>>  					 rs_offset + chunk_off,
>>  					 xdr_off,
>>  					 this_write,
>> -					 sge,
>> -					 sge_count);
>> +					 vec);
>>  			if (ret) {
>>  				dprintk("svcrdma: RDMA_WRITE failed, ret=%d\n",
>>  					ret);
>> @@ -380,7 +365,7 @@ static int send_reply(struct svcxprt_rdma *rdma,
>>  		      struct page *page,
>>  		      struct rpcrdma_msg *rdma_resp,
>>  		      struct svc_rdma_op_ctxt *ctxt,
>> -		      int sge_count,
>> +		      struct svc_rdma_req_map *vec,
>>  		      int byte_count)
>>  {
>>  	struct ib_send_wr send_wr;
>> @@ -413,10 +398,15 @@ static int send_reply(struct svcxprt_rdma *rdma,
>>  	ctxt->sge[0].lkey = rdma->sc_phys_mr->lkey;
>>  
>>  	/* Determine how many of our SGE are to be transmitted */
>> -	for (sge_no = 1; byte_count && sge_no < sge_count; sge_no++) {
>> -		sge_bytes = min((size_t)ctxt->sge[sge_no].length,
>> -				(size_t)byte_count);
>> +	for (sge_no = 1; byte_count && sge_no < vec->count; sge_no++) {
>> +		sge_bytes = min_t(size_t, vec->sge[sge_no].iov_len, byte_count);
>>  		byte_count -= sge_bytes;
>> +		ctxt->sge[sge_no].addr =
>> +			ib_dma_map_single(rdma->sc_cm_id->device,
>> +					  vec->sge[sge_no].iov_base,
>> +					  sge_bytes, DMA_TO_DEVICE);
>> +		ctxt->sge[sge_no].length = sge_bytes;
>> +		ctxt->sge[sge_no].lkey = rdma->sc_phys_mr->lkey;
>>  	}
>>  	BUG_ON(byte_count != 0);
>>  
>> @@ -428,8 +418,10 @@ static int send_reply(struct svcxprt_rdma *rdma,
>>  		ctxt->pages[page_no+1] = rqstp->rq_respages[page_no];
>>  		ctxt->count++;
>>  		rqstp->rq_respages[page_no] = NULL;
>> +		/* If there are more pages than SGE, terminate SGE list */
>> +		if (page_no+1 >= sge_no)
>> +			ctxt->sge[page_no+1].length = 0;
>>  	}
>> -
>>  	BUG_ON(sge_no > rdma->sc_max_sge);
>>  	memset(&send_wr, 0, sizeof send_wr);
>>  	ctxt->wr_op = IB_WR_SEND;
>> @@ -473,20 +465,20 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>>  	enum rpcrdma_proc reply_type;
>>  	int ret;
>>  	int inline_bytes;
>> -	struct ib_sge *sge;
>> -	int sge_count = 0;
>>  	struct page *res_page;
>>  	struct svc_rdma_op_ctxt *ctxt;
>> +	struct svc_rdma_req_map *vec;
>>  
>>  	dprintk("svcrdma: sending response for rqstp=%p\n", rqstp);
>>  
>>  	/* Get the RDMA request header. */
>>  	rdma_argp = xdr_start(&rqstp->rq_arg);
>>  
>> -	/* Build an SGE for the XDR */
>> +	/* Build an req vec for the XDR */
>>  	ctxt = svc_rdma_get_context(rdma);
>>  	ctxt->direction = DMA_TO_DEVICE;
>> -	sge = xdr_to_sge(rdma, &rqstp->rq_res, ctxt->sge, &sge_count);
>> +	vec = svc_rdma_get_req_map();
>> +	xdr_to_sge(rdma, &rqstp->rq_res, vec);
>>  
>>  	inline_bytes = rqstp->rq_res.len;
>>  
>> @@ -503,7 +495,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>>  
>>  	/* Send any write-chunk data and build resp write-list */
>>  	ret = send_write_chunks(rdma, rdma_argp, rdma_resp,
>> -				rqstp, sge, sge_count);
>> +				rqstp, vec);
>>  	if (ret < 0) {
>>  		printk(KERN_ERR "svcrdma: failed to send write chunks, rc=%d\n",
>>  		       ret);
>> @@ -513,7 +505,7 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>>  
>>  	/* Send any reply-list data and update resp reply-list */
>>  	ret = send_reply_chunks(rdma, rdma_argp, rdma_resp,
>> -				rqstp, sge, sge_count);
>> +				rqstp, vec);
>>  	if (ret < 0) {
>>  		printk(KERN_ERR "svcrdma: failed to send reply chunks, rc=%d\n",
>>  		       ret);
>> @@ -521,11 +513,13 @@ int svc_rdma_sendto(struct svc_rqst *rqstp)
>>  	}
>>  	inline_bytes -= ret;
>>  
>> -	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, sge_count,
>> +	ret = send_reply(rdma, rqstp, res_page, rdma_resp, ctxt, vec,
>>  			 inline_bytes);
>> +	svc_rdma_put_req_map(vec);
>>  	dprintk("svcrdma: send_reply returns %d\n", ret);
>>  	return ret;
>>   error:
>> +	svc_rdma_put_req_map(vec);
>>  	svc_rdma_put_context(ctxt, 0);
>>  	put_page(res_page);
>>  	return ret;
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index ae90758..fc86338 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -387,10 +387,13 @@ static void sq_cq_reap(struct svcxprt_rdma *xprt)
>>  
>>  		switch (ctxt->wr_op) {
>>  		case IB_WR_SEND:
>> -		case IB_WR_RDMA_WRITE:
>>  			svc_rdma_put_context(ctxt, 1);
>>  			break;
>>  
>> +		case IB_WR_RDMA_WRITE:
>> +			svc_rdma_put_context(ctxt, 0);
>> +			break;
>> +
>>  		case IB_WR_RDMA_READ:
>>  			if (test_bit(RDMACTXT_F_LAST_CTXT, &ctxt->flags)) {
>>  				struct svc_rdma_op_ctxt *read_hdr = ctxt->read_hdr;
>>     
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

