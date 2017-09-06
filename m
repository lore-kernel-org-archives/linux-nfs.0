Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:36237 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752313AbdIFVLH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 17:11:07 -0400
Date: Wed, 6 Sep 2017 15:11:03 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
Message-ID: <20170906211103.GA26642@obsidianresearch.com>
References: <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me>
 <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com>
 <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me>
 <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com>
 <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
 <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com>
 <20170906193946.GC18461@obsidianresearch.com>
 <4D7ECF64-0F68-4137-B72A-9E942147C8D4@oracle.com>
 <20170906200957.GB22567@obsidianresearch.com>
 <C5144079-7F9C-4783-AF4D-A73411420D5E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C5144079-7F9C-4783-AF4D-A73411420D5E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 06, 2017 at 05:00:29PM -0400, Chuck Lever wrote:

> What I implemented was a scheme to invalidate the memory of a
> (POSIX) signaled RPC before it completes, in case the RPC Reply
> hadn't yet arrived.
> 
> Currently, the only time the QP might be killed is if the server
> attempts to RDMA Write an RPC Reply into one of these invalidated
> memory regions. That case can't be avoided with the current RPC-
> over-RDMA protocol.

Okay..

> And again, we want to preserve the connection if it is healthy.

Well, if SENDs are not completing then it is not healthly. It is
analogous to what TCP Keep Alive does.

> > How does sockets based NFS handle this? Doesn't it zero copy from these
> > same buffers into SKBs? How does it cancel the SKBs before the NIC
> > transmits them?
> > 
> > Seems like exactly the same kind of problem to me..
> 
> TCP has keep-alive, where the sockets consumer is notified as soon
> as the network layer determines the remote is unresponsive. The
> connection is closed from underneath the consumer.

keep-alive is something different, it pings the remote periodicaly and
detects dead connections even when there is no traffic.

RDMA detects dead connections via retries and timeouts, but only if
there is traffic.

My questions was about how the same situation is handled in TCP. If it
does DMA directly from the source buffers by chaining them into SKBs
then it has exactly the same problem, it cannot release the buffers
until SKB is released from the TCP stack after NIC xmit. Like in RDMA,
this only happens once TCP has got the ack back.

Perhaps the answer is that TCP does not zero copy these buffers, or
TCP doesn't care about transmitting random memory, but it seems a
question worth asking.

Jason
