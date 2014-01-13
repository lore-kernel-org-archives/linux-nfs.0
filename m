Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35572 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754502AbaAMQRh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 11:17:37 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] xprtrdma: silence frame size warning
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
Date: Mon, 13 Jan 2014 11:17:19 -0500
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Miller David S." <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, LKML Kernel <linux-kernel@vger.kernel.org>
Message-Id: <D3560A1A-59B3-4480-8627-9114A4B9895C@oracle.com>
References: <1389627955.20467.9.camel@x41> <CDD9CEF2-F91A-4ABA-8DA7-53AF8A749194@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Paul Bolle <pebolle@tiscali.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

On Jan 13, 2014, at 10:59 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Jan 13, 2014, at 10:45, Paul Bolle <pebolle@tiscali.nl> wrote:
> 
>> Building verbs.o on 32 bits x86, with CONFIG_FRAME_WARN set to 1024, its
>> default value, triggers this GCC warning:
>>   net/sunrpc/xprtrdma/verbs.c: In function ‘rpcrdma_register_default_external’:
>>   net/sunrpc/xprtrdma/verbs.c:1774:1: warning: the frame size of 1040 bytes is larger than 1024 bytes [-Wframe-larger-than=]
>> 
>> Silence this warning by allocating "ipb" dynamically.
>> 
>> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
>> ---
>> 0) Compile tested only (on 32 bits x86). I don't have access to
>> Infiniband hardware.
>> 
>> 1) Please note that this is not a new warning. The oldest build log I
>> have still available on this machine is for a v3.8 rc, and it already
>> showed this warning. 
>> 
>> 2) I do hope my choice for the GFP_KERNEL flag is correct here.
>> 
>> net/sunrpc/xprtrdma/verbs.c | 6 +++++-
>> 1 file changed, 5 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 93726560..939ccc8 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -1736,11 +1736,14 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>> 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
>> 				  IB_ACCESS_REMOTE_READ);
>> 	struct rpcrdma_mr_seg *seg1 = seg;
>> -	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
>> +	struct ib_phys_buf *ipb;
>> 	int len, i, rc = 0;
>> 
>> 	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
>> 		*nsegs = RPCRDMA_MAX_DATA_SEGS;
>> +	ipb = kmalloc(sizeof(*ipb) * *nsegs, GFP_KERNEL);
>> +	if (ipb == NULL)
>> +		return -ENOMEM;
>> 	for (len = 0, i = 0; i < *nsegs;) {
>> 		rpcrdma_map_one(ia, seg, writing);
>> 		ipb[i].addr = seg->mr_dma;
>> @@ -1770,6 +1773,7 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
>> 		seg1->mr_len = len;
>> 	}
>> 	*nsegs = i;
>> +	kfree(ipb);
>> 	return rc;
>> }
> 
> Hi Paul,
> 
> Unfortunately, the above could be called from a file write back context, so we cannot use GFP_KERNEL allocations. In fact, I suspect we should only use GFP_ATOMIC, and then have the rpc_task delay and retry if the allocation fails.
> 
> The problem is that it looks to me as if xprt_rdma_send_request will currently fail, if we return an error from rpcrdma_register_default_external.
> 
> Chuck, will you be able to look into the above issue as part of your RDMA work?

I’m building a queue of NFS/RDMA work on bugzilla.kernel.org.  Let’s create a defect report there to document this, and it will get prioritized with the rest.  Paul, can you do that to start us off?  Product “File system”, Component “NFS”.

I can’t say that a warning on 32-bit x86 is going to be an especially high priority.  However, the underlying issue of allocating arrays of data segments on the stack is something that needs extended attention, and is already in plan.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



