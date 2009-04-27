From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
  truncated by	the nfs rdma client.
Date: Sun, 26 Apr 2009 22:17:03 -0400
Message-ID: <49f515a5.1d1e640a.1c82.6677@mx.google.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
 <49F31A16.2080806@opengridcomputing.com>
 <49F4AE86.4090908@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond.Myklebust@netapp.com, tom@opengridcomputing.com,
	linux-nfs@vger.kernel.org, vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:47785 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbZD0CRL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Apr 2009 22:17:11 -0400
Received: by yx-out-2324.google.com with SMTP id 3so1241653yxj.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Apr 2009 19:17:10 -0700 (PDT)
In-Reply-To: <49F4AE86.4090908@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:57 PM 4/26/2009, Steve Wise wrote:
>Hey Trond,
>
>Turns out the server side is fine.  So this patch is good to go.

I'll ACK the patch, but I do wonder if the code will compile cleanly on all
platforms. The iova_start is a u64, whereas the mr_dma is a dma_addr_t,
which is variable sized, depending on platform. Would a (u64) cast be a
safer patch, warning-wise?

Tom.

>
>Thanks,
>
>Steve.
>
>Steve Wise wrote:
>> Trond,
>>
>> There is a similar bug in the server side too.  I'll repost a single 
>> patch that fixes both.
>>
>> Steve.
>>
>> Steve Wise wrote:
>>> A bad cast causes the iova_start, which in this case is a DMA bus 
>>> address,
>>> to be truncated on 32b systems.  No cast is needed.
>>>
>>> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
>>> ---
>>>
>>>  net/sunrpc/xprtrdma/verbs.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index 3b21e0c..3a374f5 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -1489,7 +1489,7 @@ rpcrdma_register_frmr_external(struct 
>>> rpcrdma_mr_seg *seg,
>>>      memset(&frmr_wr, 0, sizeof frmr_wr);
>>>      frmr_wr.opcode = IB_WR_FAST_REG_MR;
>>>      frmr_wr.send_flags = 0;            /* unsignaled */
>>> -    frmr_wr.wr.fast_reg.iova_start = (unsigned long)seg1->mr_dma;
>>> +    frmr_wr.wr.fast_reg.iova_start = seg1->mr_dma;
>>>      frmr_wr.wr.fast_reg.page_list = 
>>> seg1->mr_chunk.rl_mw->r.frmr.fr_pgl;
>>>      frmr_wr.wr.fast_reg.page_list_len = i;
>>>      frmr_wr.wr.fast_reg.page_shift = PAGE_SHIFT;
>>>
>>> -- 
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>   
>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

