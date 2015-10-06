Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:4118 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752734AbbJFRhv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Oct 2015 13:37:51 -0400
Subject: Re: [PATCH rdma-rc v1] xprtrdma: Don't require LOCAL_DMA_LKEY support
 for fasterg
To: Doug Ledford <dledford@redhat.com>, Sagi Grimberg <sagig@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>
References: <1444150357-2362-1-git-send-email-sagig@mellanox.com>
 <56140404.1010809@Netapp.com> <56140697.6050205@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <561406EC.3050508@Netapp.com>
Date: Tue, 6 Oct 2015 13:37:48 -0400
MIME-Version: 1.0
In-Reply-To: <56140697.6050205@redhat.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/06/2015 01:36 PM, Doug Ledford wrote:
> On 10/06/2015 01:25 PM, Anna Schumaker wrote:
>> Hi Sagi,
>>
>> On 10/06/2015 12:52 PM, Sagi Grimberg wrote:
>>> There is no need to require LOCAL_DMA_LKEY support as the
>>> PD allocation makes sure that there is a local_dma_lkey. Also
>>> correctly set a return value in error path.
>>>
>>> This caused a NULL pointer dereference in mlx5 which removed
>>> the support for LOCAL_DMA_LKEY.
>>
>> Looks good to me!  This is another patch going directly to an RDMA tree somewhere, right?
> 
> Yeah, I'll pick this one up.  Thanks!

Cool!  In that case you can add:

Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

> 
>> Anna
>>
>>>
>>> Fixes: bb6c96d72879 ("xprtrdma: Replace global lkey with lkey local to PD")
>>> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
>>> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> Changes from v0:
>>> - Added error path rc assignment.
>>>
>>>  net/sunrpc/xprtrdma/verbs.c |    8 +++-----
>>>  1 files changed, 3 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>>> index eb081ad..81e8d31 100644
>>> --- a/net/sunrpc/xprtrdma/verbs.c
>>> +++ b/net/sunrpc/xprtrdma/verbs.c
>>> @@ -543,11 +543,8 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
>>>  	}
>>>  
>>>  	if (memreg == RPCRDMA_FRMR) {
>>> -		/* Requires both frmr reg and local dma lkey */
>>> -		if (((devattr->device_cap_flags &
>>> -		     (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) !=
>>> -		    (IB_DEVICE_MEM_MGT_EXTENSIONS|IB_DEVICE_LOCAL_DMA_LKEY)) ||
>>> -		      (devattr->max_fast_reg_page_list_len == 0)) {
>>> +		if (!(devattr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS) ||
>>> +		    (devattr->max_fast_reg_page_list_len == 0)) {
>>>  			dprintk("RPC:       %s: FRMR registration "
>>>  				"not supported by HCA\n", __func__);
>>>  			memreg = RPCRDMA_MTHCAFMR;
>>> @@ -557,6 +554,7 @@ rpcrdma_ia_open(struct rpcrdma_xprt *xprt, struct sockaddr *addr, int memreg)
>>>  		if (!ia->ri_device->alloc_fmr) {
>>>  			dprintk("RPC:       %s: MTHCAFMR registration "
>>>  				"not supported by HCA\n", __func__);
>>> +			rc = -EINVAL;
>>>  			goto out3;
>>>  		}
>>>  	}
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> 
> 

