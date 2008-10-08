From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 05/15] RPC/RDMA: fix connection IRD/ORD setting
Date: Wed, 08 Oct 2008 13:32:02 -0400
Message-ID: <RTPCLUEXC1-PRDM3SOl00000073@RTPMVEXC1-PRD.hq.netapp.com>
References: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
 <20081008154744.1336.20909.stgit@tmt3.nane.netapp.com>
 <1223486816.7361.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Tom Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39589 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752788AbYJHRdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 13:33:00 -0400
In-Reply-To: <1223486816.7361.12.camel@localhost>
References: <20081008154506.1336.59892.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <20081008154744.1336.20909.stgit-pfX4bTJKMULWwzOYslWYilaTQe2KTcn/@public.gmane.org>
 <1223486816.7361.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 01:26 PM 10/8/2008, Trond Myklebust wrote:
>On Wed, 2008-10-08 at 11:47 -0400, Tom Talpey wrote:
>> From: Tom Tucker <talpey@netapp.com>
>
>Now I'm really confused!

Ok, that's a bug. :-)

Will fix, after figuring out the format you prefer for joint authors.

Tom.

>
>> This logic sets the connection parameter that configures the local device
>> and informs the remote peer how many concurrent incoming RDMA_READ
>> requests are supported. The original logic didn't really do what was
>> intended for two reasons:
>> 
>> - The max number supported by the device is typically smaller than
>> any one factor in the calculation used, and
>> 
>> - The field in the connection parameter structure where the value is
>> stored is a u8 and always overflows for the default settings.
>> 
>> So what really happens is the value requested for responder resources
>> is the left over 8 bits from the "desired value". If the desired value
>> happened to be a multiple of 256, the result was zero and it wouldn't
>> connect at all.
>> 
>> Given the above and the fact that max_requests is almost always larger
>> than the max responder resources supported by the adapter, this patch
>> simplifies this logic and simply requests the max supported by the device,
>> subject to a reasonable limit.
>> 
>> This bug was found by Jim Schutt at Sandia.
>> 
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>> Signed-off-by: Tom Talpey <talpey@netapp.com>
>> ---
>> 
>>  net/sunrpc/xprtrdma/verbs.c |   51 
>++++++++++++-------------------------------
>>  1 files changed, 14 insertions(+), 37 deletions(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 39a1652..e3fe905 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -705,30 +705,13 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, 
>struct rpcrdma_ia *ia,
>>  	ep->rep_remote_cma.private_data_len = 0;
>>  
>>  	/* Client offers RDMA Read but does not initiate */
>> -	switch (ia->ri_memreg_strategy) {
>> -	case RPCRDMA_BOUNCEBUFFERS:
>> +	ep->rep_remote_cma.initiator_depth = 0;
>> +	if (ia->ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS)
>>  		ep->rep_remote_cma.responder_resources = 0;
>> -		break;
>> -	case RPCRDMA_MTHCAFMR:
>> -	case RPCRDMA_REGISTER:
>> -	case RPCRDMA_FRMR:
>> -		ep->rep_remote_cma.responder_resources = cdata->max_requests *
>> -				(RPCRDMA_MAX_DATA_SEGS / 8);
>> -		break;
>> -	case RPCRDMA_MEMWINDOWS:
>> -	case RPCRDMA_MEMWINDOWS_ASYNC:
>> -#if RPCRDMA_PERSISTENT_REGISTRATION
>> -	case RPCRDMA_ALLPHYSICAL:
>> -#endif
>> -		ep->rep_remote_cma.responder_resources = cdata->max_requests *
>> -				(RPCRDMA_MAX_DATA_SEGS / 2);
>> -		break;
>> -	default:
>> -		break;
>> -	}
>> -	if (ep->rep_remote_cma.responder_resources > devattr.max_qp_rd_atom)
>> +	else if (devattr.max_qp_rd_atom > 32)	/* arbitrary but <= 255 */
>> +		ep->rep_remote_cma.responder_resources = 32;
>> +	else
>>  		ep->rep_remote_cma.responder_resources = devattr.max_qp_rd_atom;
>> -	ep->rep_remote_cma.initiator_depth = 0;
>>  
>>  	ep->rep_remote_cma.retry_count = 7;
>>  	ep->rep_remote_cma.flow_control = 0;
>> @@ -858,14 +841,6 @@ if 
>(strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
>>  	}
>>  }
>>  
>> -	/* Theoretically a client initiator_depth > 0 is not needed,
>> -	* but many peers fail to complete the connection unless they
>> -	* == responder_resources! */
>> -	if (ep->rep_remote_cma.initiator_depth !=
>> -				ep->rep_remote_cma.responder_resources)
>> -		ep->rep_remote_cma.initiator_depth =
>> -			ep->rep_remote_cma.responder_resources;
>> -
>>  	ep->rep_connected = 0;
>>  
>>  	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
>> @@ -894,14 +869,16 @@ if 
>(strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
>>  	if (ep->rep_connected <= 0) {
>>  		/* Sometimes, the only way to reliably connect to remote
>>  		* CMs is to use same nonzero values for ORD and IRD. */
>> -		ep->rep_remote_cma.initiator_depth =
>> -					ep->rep_remote_cma.responder_resources;
>> -		if (ep->rep_remote_cma.initiator_depth == 0)
>> -			++ep->rep_remote_cma.initiator_depth;
>> -		if (ep->rep_remote_cma.responder_resources == 0)
>> -			++ep->rep_remote_cma.responder_resources;
>> -		if (retry_count++ == 0)
>> +		if (retry_count++ <= RDMA_CONNECT_RETRY_MAX + 1 &&
>> +		    (ep->rep_remote_cma.responder_resources == 0 ||
>> +		     ep->rep_remote_cma.initiator_depth !=
>> +				ep->rep_remote_cma.responder_resources)) {
>> +			if (ep->rep_remote_cma.responder_resources == 0)
>> +				ep->rep_remote_cma.responder_resources = 1;
>> +			ep->rep_remote_cma.initiator_depth =
>> +				ep->rep_remote_cma.responder_resources;
>>  			goto retry;
>> +		}
>>  		rc = ep->rep_connected;
>>  	} else {
>>  		dprintk("RPC:       %s: connected\n", __func__);
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

