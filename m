From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are   truncated
 by	the nfs rdma client.
Date: Mon, 27 Apr 2009 14:50:56 -0500
Message-ID: <49F60CA0.2020209@opengridcomputing.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int> <49F31A16.2080806@opengridcomputing.com> <49F4AE86.4090908@opengridcomputing.com> <49f515a5.1d1e640a.1c82.6677@mx.google.com> <49F5ED55.1010607@opengridcomputing.com> <1240855510.8818.9.camel@heimdal.trondhjem.org> <1240856613.8818.16.camel@heimdal.trondhjem.org> <49F60845.4010007@opengridcomputing.com> <49f60ac4.1c1d640a.2d0a.61a7@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	tom@opengridcomputing.com, linux-nfs@vger.kernel.org,
	vuhuong@mellanox.com
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:52962 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752020AbZD0Tuh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 15:50:37 -0400
In-Reply-To: <49f60ac4.1c1d640a.2d0a.61a7-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 03:32 PM 4/27/2009, Steve Wise wrote:
>   
>> Trond Myklebust wrote:
>>     
>>> On Mon, 2009-04-27 at 14:05 -0400, Trond Myklebust wrote:
>>>   
>>>       
>>>> It looks looks as though the bug is really that the IB code is using a
>>>> u64 to store dma handles. As an external user of the IB api, we really
>>>> shouldn't have to perform this sort of transformation. If it is
>>>> absolutely necessary, then it should be done by means of specialised
>>>> accessor functions to initialise/read iova_start value when given a
>>>> dma_addr_t.
>>>>
>>>> I'd therefore prefer the no-cast version (with eventual compiler
>>>> warnings), in the hope that eventually the IB folks will fix their
>>>> interface.
>>>>     
>>>>         
>>> Translation: It looks to me as if the interface that we're using is a
>>> bit too corrupted with IB low level implementation grime. In the future,
>>> I'd like to see someone come up with a more high level interface for use
>>> by external code such as the sunrpc module.
>>>
>>>   
>>>       
>> Clarification:  The iova_start isn't used to store dma handles.  The 
>>     
>
> Agreed, it's more of a hardware register, that ends up on the wire as well.
>
> I think the net of this is that the mr_dma should have a more sensible
> up-cast that yields the right bits in the iova_start. Maybe a nice
> machine-dependent macro, defined in the RDMA layer, would be a good
> approach. Surely the other upper layers need it too.
>
> While I have the floor, why doesn't the server have this issue? Looking
> at the code, it has the same (unsigned long) cast as the client when
> initializing its iova_start.
>
>   

The server isn't using the dma address as the iova_start, but rather a 
kernel virtual address pointer, which is 32b on a i386 system.  If you 
take the cast off, then the the signed bit gets extended into the u64.  
Apparently pointers are signed? 

For instance, the server had a kva of 0xf5b75000.  If you remove the 
(unsigned long) cast and stuff that into a u64, it ends up as 
0xfffffffff5b75000.

here was a trace I took of the server doing the first rdma write using 
an frmr:

Apr 26 13:14:07 rac2 kernel: build_fastreg iova_start 0xfffffffff5b75000 
rkey 0x500 len 4096
Apr 26 13:14:07 rac2 kernel: build_fastreg pbl[0] 0x35b75000
Apr 26 13:14:07 rac2 kernel: build_rdma_write sge[0] lkey 0x500 addr 
0xf5b75000 len 24
Apr 26 13:14:07 rac2 kernel: post_qp_event - AE qpid 0x23 opcode 0 
status 0x6 type 1 wrid.hi 0x1 wrid.lo 0x0


So the frmr registration ends up with 0xfffffffff5b75000 as the 
iova_start, yet the rdma write work request has 0xf5b75000 as the sge 
address entry.   And the rnic fails this WR with a base/bounds violation 
(status 0x6 in the chelsio Async Event).

Steve.

