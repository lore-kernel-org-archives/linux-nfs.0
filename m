From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 02/11] svcrdma: Use RPC reply map for RDMA_WRITE	processing
Date: Mon, 23 Jun 2008 21:29:57 -0500
Message-ID: <48605C25.4000503@opengridcomputing.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com> <12120836962324-git-send-email-tom@opengridcomputing.com> <12120836963727-git-send-email-tom@opengridcomputing.com> <20080616210442.GB29446@fieldses.org> <485D2BCC.9000508@opengridcomputing.com> <20080623182114.GB24373@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:47813 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751822AbYFXC35 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 22:29:57 -0400
In-Reply-To: <20080623182114.GB24373@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Sat, Jun 21, 2008 at 11:26:52AM -0500, Tom Tucker wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> Also, the only caller of xdr_to_sge() appears to be svc_rdma_sendto(),
>>> which is called from svc_sendto() immediately after setting:
>>>
>>> 	xb = &rqstp->rq_res;
>>> 	xb->len = xb->head[0].iov_len + 		xb->page_len +
>>> 		xb->tail[0].iov_len;
>>>
>>> So I think xdr_to_sge() is doing a bunch of unnecessary work to handle
>>> the case where xdr->len could be less than that sum?
>>>
>>>   
>>>       
>> Ok... check me below please.
>>     
>>>>   	/* Head SGE */
>>>> -	sge[sge_no].addr = ib_dma_map_single(xprt->sc_cm_id->device,
>>>> -					     xdr->head[0].iov_base,
>>>> -					     xdr->head[0].iov_len,
>>>> -					     DMA_TO_DEVICE);
>>>> +	vec->sge[sge_no].iov_base = xdr->head[0].iov_base;
>>>>  	sge_bytes = min_t(u32, byte_count, xdr->head[0].iov_len);
>>>>     
>>>>         
>> This doesn't need to be min_t. It could be xdr->head[0].iov_len.
>>     
>
> Yes.  The variable byte_count shouldn't be needed at all, so I'd start
> by eliminating all references to byte_count.
>
>   
>>>>  	byte_count -= sge_bytes;
>>>> -	sge[sge_no].length = sge_bytes;
>>>> -	sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>>>> +	vec->sge[sge_no].iov_len = sge_bytes;
>>>>  	sge_no++;
>>>>   	/* pages SGE */
>>>> @@ -99,16 +94,13 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>>>  	page_bytes = xdr->page_len;
>>>>  	page_off = xdr->page_base;
>>>>  	while (byte_count && page_bytes) {
>>>> +		vec->sge[sge_no].iov_base =
>>>> +			page_address(xdr->pages[page_no]) + page_off;
>>>>  		sge_bytes = min_t(u32, byte_count, (PAGE_SIZE-page_off));
>>>>     
>>>>         
>> This is still needed if the xdr terminates with a portion of a page and  
>> there is not tail.
>>     
>
> Yes, but the condition could just be (page_bytes).
>
>   
Right.
>>>> -		sge[sge_no].addr =
>>>> -			ib_dma_map_page(xprt->sc_cm_id->device,
>>>> -					xdr->pages[page_no], page_off,
>>>> -					sge_bytes, DMA_TO_DEVICE);
>>>>  		sge_bytes = min(sge_bytes, page_bytes);
>>>>  		byte_count -= sge_bytes;
>>>>  		page_bytes -= sge_bytes;
>>>> -		sge[sge_no].length = sge_bytes;
>>>> -		sge[sge_no].lkey = xprt->sc_phys_mr->lkey;
>>>> +		vec->sge[sge_no].iov_len = sge_bytes;
>>>>   		sge_no++;
>>>>  		page_no++;
>>>> @@ -117,23 +109,17 @@ static struct ib_sge *xdr_to_sge(struct svcxprt_rdma *xprt,
>>>>   	/* Tail SGE */
>>>>  	if (byte_count && xdr->tail[0].iov_len) {
>>>>     
>>>>         
>> This is defensive. It could just be byte_count.
>>     
>
> I agree, though I'd just make it (xdr->tail[0].iov_len) instead of just
> (byte_count).
>
>   
Agreed.
>> If byte_count != xdr->tail[0].iov_len, the BUG_ON below will let us know.
>>     
>>>> -		sge[sge_no].addr =
>>>> -			ib_dma_map_single(xprt->sc_cm_id->device,
>>>> -					  xdr->tail[0].iov_base,
>>>> -					  xdr->tail[0].iov_len,
>>>> -					  DMA_TO_DEVICE);
>>>> +		vec->sge[sge_no].iov_base = xdr->tail[0].iov_base;
>>>>  		sge_bytes = min_t(u32, byte_count, xdr->tail[0].iov_len);
>>>>     
>>>>         
>> The min_t isn't needed. It could just be byte_count.
>>     
>
> Right, but could also just be tail length, as above.
>
>   

Ok, page # confirmed...

> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

