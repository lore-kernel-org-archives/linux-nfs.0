From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are  truncated
 by	the nfs rdma client.
Date: Mon, 27 Apr 2009 12:37:25 -0500
Message-ID: <49F5ED55.1010607@opengridcomputing.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int> <49F31A16.2080806@opengridcomputing.com> <49F4AE86.4090908@opengridcomputing.com> <49f515a5.1d1e640a.1c82.6677@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond.Myklebust@netapp.com, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:51288 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756938AbZD0RhG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 13:37:06 -0400
In-Reply-To: <49f515a5.1d1e640a.1c82.6677-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 02:57 PM 4/26/2009, Steve Wise wrote:
>   
>> Hey Trond,
>>
>> Turns out the server side is fine.  So this patch is good to go.
>>     
>
> I'll ACK the patch, but I do wonder if the code will compile cleanly on all
> platforms. The iova_start is a u64, whereas the mr_dma is a dma_addr_t,
> which is variable sized, depending on platform. Would a (u64) cast be a
> safer patch, warning-wise?
>
>   

Well, if dma_addr_t is smaller, I don't think you'll get a warning, will 
you?  And if its larger than 64b, then you _want_ the warning, because 
nothing will work. :)

Its up to you and/or Trond.

Steve.


> Tom.
>
>   
>> Thanks,
>>
>> Steve.
>>
>> Steve Wise wrote:
>>     
>>> Trond,
>>>
>>> There is a similar bug in the server side too.  I'll repost a single 
>>> patch that fixes both.
>>>
>>> Steve.
>>>
>>> Steve Wise wrote:
>>>       
>>>> A bad cast causes the iova_start, which in this case is a DMA bus 
>>>> address,
>>>> to be truncated on 32b systems.  No cast is needed.
>>>>
>>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>>> ---
>>>>
>>>>  net/sunrpc/xprtrdma/verbs.c |    2 +-
>>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>>> index 3b21e0c..3a374f5 100644
>>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>>> @@ -1489,7 +1489,7 @@ rpcrdma_register_frmr_external(struct 
>>>> rpcrdma_mr_seg *seg,
>>>>      memset(&frmr_wr, 0, sizeof frmr_wr);
>>>>      frmr_wr.opcode = IB_WR_FAST_REG_MR;
>>>>      frmr_wr.send_flags = 0;            /* unsignaled */
>>>> -    frmr_wr.wr.fast_reg.iova_start = (unsigned long)seg1->mr_dma;
>>>> +    frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
>>>>      frmr_wr.wr.fast_reg.page_list = 
>>>> seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
>>>>      frmr_wr.wr.fast_reg.page_list_len = i;
>>>>      frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
>>>>
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>   
>>>>         
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>       
>>     

