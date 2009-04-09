From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] svcrdma: Fix dma map direction for rdma read	targets
Date: Thu, 09 Apr 2009 14:17:48 -0500
Message-ID: <49DE49DC.4050805@opengridcomputing.com>
References: <20090403201824.18102.62915.stgit@build.ogc.int> <49D67053.2080105@opengridcomputing.com> <20090409153224.GB32589@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Steve Wise <swise@opengridcomputing.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:48977 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936232AbZDITRt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2009 15:17:49 -0400
In-Reply-To: <20090409153224.GB32589@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Apr 03, 2009 at 03:23:47PM -0500, Tom Tucker wrote:
>> Steve Wise wrote:
>>> The nfs server rdma transport was mapping rdma read target pages for
>>> TO_DEVICE instead of FROM_DEVICE.  This causes data corruption on non
>>> cache-coherent systems if frmrs are used.
>>>
>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>> ---
>>>
>>>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> index 629a287..42a6f9f 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
>>> @@ -265,7 +265,7 @@ static int fast_reg_read_chunks(struct svcxprt_rdma *xprt,
>>>  		frmr->page_list->page_list[page_no] =
>>>  			ib_dma_map_single(xprt->sc_cm_id->device,
>>>  					  page_address(rqstp->rq_arg.pages[page_no]),
>>> -					  PAGE_SIZE, DMA_TO_DEVICE);
>>> +					  PAGE_SIZE, DMA_FROM_DEVICE);
>> FWIW, this looks good to me.
> 
> Thanks; I'll add an acked-by if you don't object. 

Sure...

>... Should this go to
> stable as well?
> 

I think so because it's a bug and we've verified it fixes the data 
corruption issue and doesn't regress existing platforms.


> --b.
> 
>>>  		if (ib_dma_mapping_error(xprt->sc_cm_id->device,
>>>  					 frmr->page_list->page_list[page_no]))
>>>  			goto fatal_err;
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

