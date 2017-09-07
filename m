Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa09-06.prod.phx3.secureserver.net ([173.201.193.235]:34855
        "EHLO p3plsmtpa09-06.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755177AbdIGNZH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Sep 2017 09:25:07 -0400
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net>
 <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
 <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
 <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
 <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
 <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
 <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com>
 <20170906193946.GC18461@obsidianresearch.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <f2cb453d-a59f-de64-7a42-09e075562895@talpey.com>
Date: Thu, 7 Sep 2017 09:17:16 -0400
MIME-Version: 1.0
In-Reply-To: <20170906193946.GC18461@obsidianresearch.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/6/2017 3:39 PM, Jason Gunthorpe wrote:
> On Wed, Sep 06, 2017 at 02:33:50PM -0400, Chuck Lever wrote:
> 
>> B. Force RPC completion to wait for Send completion, which
>> would allow the post-v4.6 scatter-gather code to work
>> safely. This would need some guarantee that Sends will
>> always complete in a short period.
> 
> Why is waiting for the send completion so fundamentally different from
> waiting for the remote RPC reply?
> 
> I would say that 99% of time the send completion and RPC reply
> completion will occure approximately concurrently.

Absolutely not. The RPC reply requires upper layer processing at
the server, which involves work requests, context switches, file
system and disk i/o operations, and plain old queuing. RPC replies
typically can be expected in milliseconds from traditional HDDs,
and hundreds of microseconds from SSDs. Storage class memory is
reducing these by two orders of magnitude, but it's still not in
the range of a network round trip.

> eg It is quite likely the RPC reply SEND carries an embeded ack
> for the requesting SEND..

That's not what we've seen, even on InfiniBand. On adapters such as
iWARP, I will note, the send completion is often generated when
the adapter buffers the outgoing message, and has almost nothing
to do with the remote transport ack.

Tom.
