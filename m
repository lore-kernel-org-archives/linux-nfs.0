From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Wed, 13 Aug 2008 17:28:20 -0500
Message-ID: <48A36004.1030304@opengridcomputing.com>
References: <48A30685.6050301@opengridcomputing.com> <20080813211953.GN26765@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:43240 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbYHMW2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 18:28:20 -0400
In-Reply-To: <20080813211953.GN26765@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 11:06:29AM -0500, Tom Tucker wrote:
>> This patchset implements support for Fast Memory Registration in the
>> NFS server.  Fast Memory Regstration is the ability to quickly map a
>> kernel memory page list as a logically contiguous memory region from
>> the perspective of the adapter. This mapping is created and
>> invalidated using work requests posted on the SQ. This allows for
>> large amounts of data to transferred between the client and server
>> with a single work request as well as the ability to invalidate a
>> previously mapped memory region. For iWARP, this allows for "one-shot"
>> memory regions to be mapped for a single NFS-RDMA data transfer. This
>> improves security since a byzantine app listening on the net will have
>> a very short window during which the RKEY is valid.
>>
>> This capability is only enabled if the underlying device advertises
>> that it is supported.
> 
> Thanks for your continuing work on this.
> 
> I think we really need to document the security assumptions, though.
> 

Yes, that's a good idea. Maybe a file in Documentation/svcrdma?

> (Currently is your entire memory at the mercy of anyone on the same
> local network as your rdma adapter?

------------------------------------------------------------------------

A principal exploit is that a node listening on a mirror port of a switch
could snoop RDMA packets containing RKEY and then forge a packet with this
RKEY to write or read the memory of the peer to which the RKEY referred.

The NFSRDMA protocol is defined such that a) only the server initiates
RDMA, and b) only the client's memory is exposed via RKEY. This is why
the server reads to fetch RPC data from the client even though it would
be more efficient for the client to write the data to the server's memory.

The above design goal is not entirely realized with iWARP, however, because
the RKEY (called an STag on iWARP) for the data sink of an RDMA_READ is
actually placed on the wire! Not only that, iWARP (RDDP) requires that this
RKEY have Remote Write! This means that the server's memory is exposed by
virtue of having placed the RKEY for it's local memory on the wire in order
to receive the result of the RDMA_READ. By contrast, IB uses an opaque
transaction ID# to associate the READ_RPL with the READ_REQ _and_ the data
sink of an RDMA_READ does not require remote access. That said, the evil node
in question, for example, could potentially forge a packet with this
transaction ID and corrupt the target memory, however, the duration
of the exploit is this single READ_REQ.

The newer RDMA adapters (both iWARP and IB) support "Fast Memory Registration".
This capability allows memory to be quickly registered and
de-registered by submitting WR on the SQ. So the idea is to create an RKEY
that ONLY maps the single RPC. So the WR sequence is post_map,
post_rdma_read, post_invalidate. This has two benefits, a) it restricts the
domain of the exploit to the memory of a single RPC, and b) it limits the
duration of the exploit to the time it takes to satisfy the RDMA_READ.

   If so, fixing that would certainly
> make this stuff useful in more situations, but language like "a very
> short window" doesn't sound promising.  Also, we've got to make sure
> users understand where it's safe to use this stuff....)
> 

There are those who argue that a one-shot STag/RKEY is no less secure than TCP.
Consider that the exact same evil application could more easily corrupt RPC
payload by simply forging a packet with the correct TCP sequence number --
in fact it's easier than the RDMA exploit because the RDMA exploit requires
that you correctly forge both the TCP packet _and_ the RDMA payload. In
addition the duration of the TCP exploit is the lifetime of the connection, not
the lifetime of a single WR.

So if you buy the argument above, RDMA on IB or iWARP using Fast Reg is no
less secure than TCP. That is the goal of this patch series.

Tom

> --b.
> 
>> This patches are also available here:
>> git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git
>>
>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>
>> include/linux/sunrpc/svc_rdma.h |   27 ++++++++++++++++++++++++++-
>> 1 files changed, 26 insertions(+), 1 deletions(-)
>>
>> [PATCH 02/09] svcrdma: Add FRMR get/put services
>>
>> include/linux/sunrpc/svc_rdma.h          |    3 +
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |  125 ++++++++++++++++++++++++++++-
>> 2 files changed, 123 insertions(+), 5 deletions(-)
>>
>> [PATCH 03/09] svcrdma: Query device for Fast Reg support during connection setup
>>
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   86 +++++++++++++++++++++++++++--
>> 1 files changed, 80 insertions(+), 6 deletions(-)
>>
>> [PATCH 04/09] svcrdma: Add a service to register a Fast Reg MR with the device
>>
>> include/linux/sunrpc/svc_rdma.h          |    1 +
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   53 ++++++++++++++++++++++++++---
>> 2 files changed, 48 insertions(+), 6 deletions(-)
>>
>> [PATCH 05/09] svcrdma: Modify post recv path to use local dma key
>>
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +++++++---
>> 1 files changed, 7 insertions(+), 3 deletions(-)
>>
>> [PATCH 06/09] svcrdma: Add support to svc_rdma_send to handle chained WR
>>
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 +++++++++++++++++++++--------
>> 1 files changed, 21 insertions(+), 8 deletions(-)
>>
>> [PATCH 07/09] svcrdma: Modify the RPC recv path to use FRMR when available
>>
>> include/linux/sunrpc/svc_rdma.h          |    1 +
>> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  187 ++++++++++++++++++++++++++----
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
>> 3 files changed, 171 insertions(+), 22 deletions(-)
>>
>> [PATCH 08/09] svcrdma: Modify the RPC reply path to use FRMR when available
>>
>> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  263 +++++++++++++++++++++++++-----
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
>> 2 files changed, 225 insertions(+), 40 deletions(-)
>>
>> [PATCH 09/09] svcrdma: Update svc_rdma_send_error to use DMA LKEY
>>
>> net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
>> 1 files changed, 9 insertions(+), 2 deletions(-)
>>

