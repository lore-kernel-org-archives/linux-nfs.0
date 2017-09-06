Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50650 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdIFVAm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 17:00:42 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20170906200957.GB22567@obsidianresearch.com>
Date: Wed, 6 Sep 2017 17:00:29 -0400
Cc: Sagi Grimberg <sagi@grimberg.me>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C5144079-7F9C-4783-AF4D-A73411420D5E@oracle.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net> <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me> <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com> <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me> <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com> <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me> <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com> <20170906193946.GC18461@obsidianresearch.com> <4D7ECF64-0F68-4137-B72A-9E942147C8D4@oracle.com> <20170906200957.GB22567@obsidianresearch.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2017, at 4:09 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
> 
> On Wed, Sep 06, 2017 at 04:02:24PM -0400, Chuck Lever wrote:
>> 
>>> On Sep 6, 2017, at 3:39 PM, Jason Gunthorpe <jgunthorpe@obsidianresearch.com> wrote:
>>> 
>>> On Wed, Sep 06, 2017 at 02:33:50PM -0400, Chuck Lever wrote:
>>> 
>>>> B. Force RPC completion to wait for Send completion, which
>>>> would allow the post-v4.6 scatter-gather code to work
>>>> safely. This would need some guarantee that Sends will
>>>> always complete in a short period.
>>> 
>>> Why is waiting for the send completion so fundamentally different from
>>> waiting for the remote RPC reply?
>>> 
>>> I would say that 99% of time the send completion and RPC reply
>>> completion will occure approximately concurrently.
>>> 
>>> eg It is quite likely the RPC reply SEND carries an embeded ack
>>> for the requesting SEND..
>> 
>> Depends on implementation. Average RTT on IB is 3-5 usecs.
>> Average RPC RTT is about an order of magnitude more. Typically
>> the Send is ACK'd more quickly than the RPC Reply can be sent.
>> 
>> But I get your point: the normal case isn't a problem.
>> 
>> The problematic case arises when the Send is not able to complete
>> because the NFS server is not reachable. User starts pounding on
>> ^C, RPC can't complete because Send won't complete, control
>> doesn't return to user.
> 
> Sure, but why is that so different from the NFS server not generating
> a response?
> 
> I thought you already implemetned a ctrl-c scheme that killed the QP?
> Or was that just a discussion?

No, we want to _avoid_ killing the QP if we can. A ctrl-C (or a
timer signal, say) on an otherwise healthy connection must not
perturb other outstanding RPCs, if possible.

What I implemented was a scheme to invalidate the memory of a
(POSIX) signaled RPC before it completes, in case the RPC Reply
hadn't yet arrived.

Currently, the only time the QP might be killed is if the server
attempts to RDMA Write an RPC Reply into one of these invalidated
memory regions. That case can't be avoided with the current RPC-
over-RDMA protocol.


> That is the only way to async terminate outstanding RPCs and clean
> up. Killing the QP will allow the send to be 'completed'.

It forces outstanding Sends to flush.

But as you explained it at the time, xprtrdma needs to wait
somehow for the QP to complete it's transition to error state
before allowing RPCs to complete. Probably ib_drain_qp would be
enough.

And again, we want to preserve the connection if it is healthy.


> Having ctrl-c escalate to a QP tear down after a short timeout seems
> reasonable. 99% of cases will not need the teardown since the send
> will complete..

So I think we are partially there already. If an RPC timeout occurs
(which should be after a few minutes) then xprtrdma does disconnect,
which tears down the QP.

If a timer signal fires on an RPC waiting for a server that is
unreachable, the application won't see the signal until the RPC
times out. Maybe that's how it works now?

And, otherwise, a ^C on an app waiting for an unresponsive server
will not have immediate results. But again, I think that's how it
works now.


> How does sockets based NFS handle this? Doesn't it zero copy from these
> same buffers into SKBs? How does it cancel the SKBs before the NIC
> transmits them?
> 
> Seems like exactly the same kind of problem to me..

TCP has keep-alive, where the sockets consumer is notified as soon
as the network layer determines the remote is unresponsive. The
connection is closed from underneath the consumer.

For RDMA, which has no keep-alive mechanism, we seem to be going
with waiting for the RPC to time out, then the consumer itself
breaks the connection.


--
Chuck Lever



