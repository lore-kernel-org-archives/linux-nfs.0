From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 2.6.30] xprtrdma: The frmr iova_start values are
  truncated by	the nfs rdma client.
Date: Mon, 27 Apr 2009 15:42:42 -0400
Message-ID: <49f60ac4.1c1d640a.2d0a.61a7@mx.google.com>
References: <20090424190510.3134.90405.stgit@build.ogc.int>
 <49F31A16.2080806@opengridcomputing.com>
 <49F4AE86.4090908@opengridcomputing.com>
 <49f515a5.1d1e640a.1c82.6677@mx.google.com>
 <49F5ED55.1010607@opengridcomputing.com>
 <1240855510.8818.9.camel@heimdal.trondhjem.org>
 <1240856613.8818.16.camel@heimdal.trondhjem.org>
 <49F60845.4010007@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	tom@opengridcomputing.com, linux-nfs@vger.kernel.org,
	vuhuong@mellanox.com
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:42604 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822AbZD0TnC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 15:43:02 -0400
Received: by yw-out-2324.google.com with SMTP id 5so70627ywb.1
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2009 12:43:01 -0700 (PDT)
In-Reply-To: <49F60845.4010007@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 03:32 PM 4/27/2009, Steve Wise wrote:
>Trond Myklebust wrote:
>> On Mon, 2009-04-27 at 14:05 -0400, Trond Myklebust wrote:
>>   
>>> It looks looks as though the bug is really that the IB code is using a
>>> u64 to store dma handles. As an external user of the IB api, we really
>>> shouldn't have to perform this sort of transformation. If it is
>>> absolutely necessary, then it should be done by means of specialised
>>> accessor functions to initialise/read iova_start value when given a
>>> dma_addr_t.
>>>
>>> I'd therefore prefer the no-cast version (with eventual compiler
>>> warnings), in the hope that eventually the IB folks will fix their
>>> interface.
>>>     
>>
>> Translation: It looks to me as if the interface that we're using is a
>> bit too corrupted with IB low level implementation grime. In the future,
>> I'd like to see someone come up with a more high level interface for use
>> by external code such as the sunrpc module.
>>
>>   
>
>Clarification:  The iova_start isn't used to store dma handles.  The 

Agreed, it's more of a hardware register, that ends up on the wire as well.

I think the net of this is that the mr_dma should have a more sensible
up-cast that yields the right bits in the iova_start. Maybe a nice
machine-dependent macro, defined in the RDMA layer, would be a good
approach. Surely the other upper layers need it too.

While I have the floor, why doesn't the server have this issue? Looking
at the code, it has the same (unsigned long) cast as the client when
initializing its iova_start.

Tom.

>iova_start is the "address" base value that is advertised to a peer to 
>describe the base address of a memory region.  The contents of that can 
>be more than just a dma handle...its up to the application.  For 
>instance, you could advertise a iova_start of zero or a kernel VA as the 
>rdma server does.  Also, the type is u64 because that is the size used 
>on the wire as part of the rdma (IB and iWARP) protocols. 
>
>
>Steve.
>

