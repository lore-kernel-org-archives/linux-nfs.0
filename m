Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40518 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754725Ab1CQSy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 14:54:27 -0400
Message-ID: <4D8258DF.3030302@opengridcomputing.com>
Date: Thu, 17 Mar 2011 12:54:23 -0600
From: Tom Tucker <tom@opengridcomputing.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jesper Juhl <jj@chaosbits.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Pavel Emelyanov <xemul@openvz.org>,
        Chuck Lever <chuck.lever@oracle.com>, Tejun Heo <tj@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] SUNRPC: Remove resource leak in svc_rdma_send_error()
References: <alpine.LNX.2.00.1101222233260.7746@swampdragon.chaosbits.net> <20110317183752.GH30180@fieldses.org>
In-Reply-To: <20110317183752.GH30180@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,

I believe this fix is correct.

Tom

On 3/17/11 12:37 PM, J. Bruce Fields wrote:
> On Sat, Jan 22, 2011 at 10:40:20PM +0100, Jesper Juhl wrote:
>> We leak the memory allocated to 'ctxt' when we return after
>> 'ib_dma_mapping_error()' returns !=0.
>>
>> Signed-off-by: Jesper Juhl<jj@chaosbits.net>
> I don't know this code, but I can't see how that could be wrong....
> Applying unless Tom tells me otherwise.
>
> --b.
>
>> ---
>>   svc_rdma_transport.c |    1 +
>>   1 file changed, 1 insertion(+)
>>
>>    compile tested only
>>
>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> index 9df1ead..1a10dcd 100644
>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>> @@ -1335,6 +1335,7 @@ void svc_rdma_send_error(struct svcxprt_rdma *xprt, struct rpcrdma_msg *rmsgp,
>>   					    p, 0, length, DMA_FROM_DEVICE);
>>   	if (ib_dma_mapping_error(xprt->sc_cm_id->device, ctxt->sge[0].addr)) {
>>   		put_page(p);
>> +		svc_rdma_put_context(ctxt, 1);
>>   		return;
>>   	}
>>   	atomic_inc(&xprt->sc_dma_used);
>>
>>
>> -- 
>> Jesper Juhl<jj@chaosbits.net>             http://www.chaosbits.net/
>> Don't top-post http://www.catb.org/~esr/jargon/html/T/top-post.html
>> Plain text mails only, please.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

