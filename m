Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:51958 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752255AbdIFUCn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 16:02:43 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170906193946.GC18461@obsidianresearch.com>
Date: Wed, 6 Sep 2017 16:02:24 -0400
Cc: Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <4D7ECF64-0F68-4137-B72A-9E942147C8D4@oracle.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net> <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me> <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com> <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me> <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com> <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me> <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com> <20170906193946.GC18461@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2017, at 3:39 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
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
> 
> eg It is quite likely the RPC reply SEND carries an embeded ack
> for the requesting SEND..

Depends on implementation. Average RTT on IB is 3-5 usecs.
Average RPC RTT is about an order of magnitude more. Typically
the Send is ACK'd more quickly than the RPC Reply can be sent.

But I get your point: the normal case isn't a problem.

The problematic case arises when the Send is not able to complete
because the NFS server is not reachable. User starts pounding on
^C, RPC can't complete because Send won't complete, control
doesn't return to user.

The Send Queue is blocked in that case anyway. That should result
in the sendctx queue becoming empty, so that RPCs can't even post
another Send, and we avoid the problem with newly issued RPCs.

We really do prefer the mechanics of the transport to be detached
from the ability of the RPC client and above to respond to user
signals, IMO.


--
Chuck Lever



