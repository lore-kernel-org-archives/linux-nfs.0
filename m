Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38668 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbEGPLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 May 2015 11:11:42 -0400
Received: by wiun10 with SMTP id n10so63727911wiu.1
        for <linux-nfs@vger.kernel.org>; Thu, 07 May 2015 08:11:40 -0700 (PDT)
Message-ID: <554B80B7.8090900@dev.mellanox.co.il>
Date: Thu, 07 May 2015 18:11:51 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Hefty, Sean" <sean.hefty@intel.com>
Subject: Re: [PATCH v1 04/14] xprtrdma: Use ib_device pointer safely
References: <20150504174626.3483.97639.stgit@manet.1015granger.net> <20150504175720.3483.80356.stgit@manet.1015granger.net> <554B37CF.2070206@dev.mellanox.co.il> <E1ADA91B-45DA-46B6-A114-E2600613969A@oracle.com> <554B6F2A.6000608@dev.mellanox.co.il> <BDE22240-DC37-4C54-B71E-D88EF54D3119@oracle.com>
In-Reply-To: <BDE22240-DC37-4C54-B71E-D88EF54D3119@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/7/2015 5:12 PM, Chuck Lever wrote:
>
> On May 7, 2015, at 9:56 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>
>> On 5/7/2015 4:39 PM, Chuck Lever wrote:
>>>
>>> On May 7, 2015, at 6:00 AM, Sagi Grimberg <sagig@dev.mellanox.co.il> wrote:
>>>
>>>> On 5/4/2015 8:57 PM, Chuck Lever wrote:
>>>>> The connect worker can replace ri_id, but prevents ri_id->device
>>>>> from changing during the lifetime of a transport instance.
>>>>>
>>>>> Cache a copy of ri_id->device in rpcrdma_ia and in rpcrdma_rep.
>>>>> The cached copy can be used safely in code that does not serialize
>>>>> with the connect worker.
>>>>>
>>>>> Other code can use it to save an extra address generation (one
>>>>> pointer dereference instead of two).
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>>   net/sunrpc/xprtrdma/fmr_ops.c      |    8 +----
>>>>>   net/sunrpc/xprtrdma/frwr_ops.c     |   12 +++----
>>>>>   net/sunrpc/xprtrdma/physical_ops.c |    8 +----
>>>>>   net/sunrpc/xprtrdma/verbs.c        |   61 +++++++++++++++++++-----------------
>>>>>   net/sunrpc/xprtrdma/xprt_rdma.h    |    2 +
>>>>>   5 files changed, 43 insertions(+), 48 deletions(-)
>>>>>
>>>>> diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
>>>>> index 302d4eb..0a96155 100644
>>>>> --- a/net/sunrpc/xprtrdma/fmr_ops.c
>>>>> +++ b/net/sunrpc/xprtrdma/fmr_ops.c
>>>>> @@ -85,7 +85,7 @@ fmr_op_map(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg,
>>>>>   	   int nsegs, bool writing)
>>>>>   {
>>>>>   	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>>>>> -	struct ib_device *device = ia->ri_id->device;
>>>>> +	struct ib_device *device = ia->ri_device;
>>>>>   	enum dma_data_direction direction = rpcrdma_data_dir(writing);
>>>>>   	struct rpcrdma_mr_seg *seg1 = seg;
>>>>>   	struct rpcrdma_mw *mw = seg1->rl_mw;
>>>>> @@ -137,17 +137,13 @@ fmr_op_unmap(struct rpcrdma_xprt *r_xprt, struct rpcrdma_mr_seg *seg)
>>>>>   {
>>>>>   	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
>>>>>   	struct rpcrdma_mr_seg *seg1 = seg;
>>>>> -	struct ib_device *device;
>>>>>   	int rc, nsegs = seg->mr_nsegs;
>>>>>   	LIST_HEAD(l);
>>>>>
>>>>>   	list_add(&seg1->rl_mw->r.fmr->list, &l);
>>>>>   	rc = ib_unmap_fmr(&l);
>>>>> -	read_lock(&ia->ri_qplock);
>>>>> -	device = ia->ri_id->device;
>>>>>   	while (seg1->mr_nsegs--)
>>>>> -		rpcrdma_unmap_one(device, seg++);
>>>>> -	read_unlock(&ia->ri_qplock);
>>>>> +		rpcrdma_unmap_one(ia->ri_device, seg++);
>>>>
>>>> Umm, I'm wandering if this is guaranteed to be the same device as
>>>> ri_id->device?
>>>>
>>>> Imagine you are working on a bond device where each slave belongs to
>>>> a different adapter. When the active port toggles, you will see a
>>>> ADDR_CHANGED event (that the current code does not handle...), what
>>>> you'd want to do is just reconnect and rdma_cm will resolve the new
>>>> address for you (via the backup slave). I suspect that in case this
>>>> flow is concurrent with the reconnects you may end up with a stale
>>>> device handle.
>>>
>>> I’m not sure what you mean by “stale” : freed memory?
>>>
>>> I’m looking at this code in rpcrdma_ep_connect() :
>>>
>>>   916                 if (ia->ri_id->device != id->device) {
>>>   917                         printk("RPC:       %s: can't reconnect on "
>>>   918                                 "different device!\n", __func__);
>>>   919                         rdma_destroy_id(id);
>>>   920                         rc = -ENETUNREACH;
>>>   921                         goto out;
>>>   922                 }
>>>
>>> After reconnecting, if the ri_id has changed, the connect fails. Today,
>>> xprtrdma does not support the device changing out from under it.
>>>
>>> Note also that our receive completion upcall uses ri_id->device for
>>> DMA map syncing. Would that also be a problem during a bond failover?
>>>
>>
>> I'm not talking about ri_id->device, this will be consistent. I'm
>> wandering about ia->ri_device, which might not have been updated yet.
>
> ia->ri_device is never updated. The only place it is set is in
> rpcrdma_ia_open().

So you assume that each ri_id that you will recreate contains the
same device handle?

I think that for ADDR_CHANGE event when the slave belongs to another
device you will hit a mismatch. CC'ing Sean for more info...

>
>> Just asking, assuming your transport device can change between consecutive reconnects (the new cm_id will contain another device), is
>> it safe to rely on ri_device being updated?
>
> My reading of the above logic is that ia->ri_id->device is guaranteed to
> be the same address during the lifetime of the transport instance. If it
> changes during a reconnect, rpcrdma_ep_connect() will fail the connect.

It is the same address - the bond0 IP...

>
> In the case of a bonded device, why are the physical slave devices exposed
> to consumers?

You mean ib_device handle? you need it to create PD/CQ/QP/MRs...
How else can you allocate the device resources without the device
handle?

rdma_cm simply gives you the device handle by the IP route. From there
you own the resources you create.

> It might be saner to construct a virtual ib_device in this
> case that consumers can depend on.

I'm not sure how does a virtual ib_device can work - that goes
to the verbs themselves... Seems like a layering mis-match to me...
