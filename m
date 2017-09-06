Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36281 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdIFSeG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Sep 2017 14:34:06 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH RFC 0/5] xprtrdma Send completion batching
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
Date: Wed, 6 Sep 2017 14:33:50 -0400
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <5B2F42B8-2CBD-43F4-BBAD-71EDD4F871FB@oracle.com>
References: <20170905164347.11106.27140.stgit@manet.1015granger.net> <1230f9d9-07c1-6d00-b197-f408712fb5c1@grimberg.me> <890CC58C-7F8F-4B7E-8620-21F07007D3AA@oracle.com> <6dcdcc25-2613-cdb5-1db2-6c944f05242b@grimberg.me> <4E2E5580-69A5-4C3B-9FCA-E61AE2042E6B@oracle.com> <9059315f-1985-042e-a59f-26a66fbece3e@grimberg.me>
To: Sagi Grimberg <sagi@grimberg.me>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2017, at 11:23 AM, Sagi Grimberg <sagi@grimberg.me> wrote:
> 
> 
>>> I see, but how can the user know that that it needs to use RPCSEC_GSS
>>> otherwise nfs/rdma might compromise sensitive data? And is this
>>> a valid constraint? (just asking, you're the expert)
>> sec=krb5p is used in cases where data on the wire must remain
>> confidential. Otherwise, sensitive or no, data on the wire goes
>> in the clear.
>> But an administrator might not expect that other sensitive data
>> on the client (not involved with NFS) can be placed on the wire
>> by the vagaries of memory allocation and hardware retransmission,
>> as exceptionally rare as that might be.
>> Memory in which Send data resides is donated to the device until
>> the Send completion fires: the ULP has no way to get it back in
>> the meantime. ULPs can invalidate memory used for RDMA Read at
>> any time, but Send memory is registered with the local DMA key
>> (as anything else is just as expensive as an RDMA data transfer).

>> The immediate solution is to never use Send to move file data
>> directly. It will always have to be copied into a buffer or
>> we use RDMA Read. These buffers contain only data that is
>> destined for the wire. Does that close the unwanted exposure
>> completely?
> 
> It would, but is that a smaller sacrifice than signaling
> send completions for small writes?

Recall that if there's no file data, the transport will
utilize a persistently registered and DMA mapped buffer
that it owns in which to build the RPC Call message and
post the Send.

If there is file data, the same buffer is used, but the
memory containing the file data is DMA mapped and added
to the Send SGE list.

With sendctx, every 16th Send [*] is signaled whether it
is carrying extra SGEs that need to be unmapped, or not.
All other Sends are not signaled. This guarantees correct
Send Queue accounting for all workloads and registration
modes, using a minimum number of completions.

During each Send completion, the handler walks through
SGEs since the last completion, and unmaps them if needed.

If we choose never to do scatter-gather Send with file
data, then this last step is unneeded because then only
persistently registered and mapped buffers would be used
for sending RPC Call messages.

But note that either mechanism results in the same Send
completion rate.


[*] 16 is adjusted down to accommodate smaller Send
Queues as needed.

>> If the HCA can guarantee that all Sends complete quickly (either
>> successful, flush, or time out after a few seconds) then it could
>> be fair to make RPC completion also wait for Send completion.
>> Otherwise, a ^C on a file operation targeting an unreachable
>> server will hang indefinitely.
> 
> You could set retry_count=0/1 which will fail with zero or one
> send retries (a matter of seconds), but that would make the qp go to
> error state which is probably not what we want...

I'm told that not letting the hardware try as hard as it
can to transmit a Send is asking for data corruption. Thus
the current setting is 6. That should cause a time out in
less than a minute? It depends on the HCA I guess.

Dropping the connection is desirable to force a full
reconnect (with address resolution) and to kick off
another Send. It is not desirable because it will also
interrupt all other outstanding RPCs on that connection.

As I see it, the options are to apply sendctx (this series),
and then:

A. Remove the post-v4.6 scatter-gather code, or

B. Force RPC completion to wait for Send completion, which
would allow the post-v4.6 scatter-gather code to work
safely. This would need some guarantee that Sends will
always complete in a short period.

For B, the signaling scheme would have to be: signal
non-data-bearing Send every so often, but signal all
data-bearing Sends. RPC completion would have to be able
to tell the difference and wait as needed. I can probably
handle this by adding a couple of atomic bits in struct
rpcrdma_req.

A. seems like the more straightforward approach.


--
Chuck Lever



