From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Thu, 14 Aug 2008 15:48:47 -0400
Message-ID: <20080814194847.GH23859@fieldses.org>
References: <48A30685.6050301@opengridcomputing.com> <20080813211953.GN26765@fieldses.org> <48A36004.1030304@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49289 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753414AbYHNTss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 15:48:48 -0400
In-Reply-To: <48A36004.1030304@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 13, 2008 at 05:28:20PM -0500, Tom Tucker wrote:
> J. Bruce Fields wrote:
>> On Wed, Aug 13, 2008 at 11:06:29AM -0500, Tom Tucker wrote:
>>> This patchset implements support for Fast Memory Registration in the
>>> NFS server.  Fast Memory Regstration is the ability to quickly map a
>>> kernel memory page list as a logically contiguous memory region from
>>> the perspective of the adapter. This mapping is created and
>>> invalidated using work requests posted on the SQ. This allows for
>>> large amounts of data to transferred between the client and server
>>> with a single work request as well as the ability to invalidate a
>>> previously mapped memory region. For iWARP, this allows for "one-shot"
>>> memory regions to be mapped for a single NFS-RDMA data transfer. This
>>> improves security since a byzantine app listening on the net will have
>>> a very short window during which the RKEY is valid.
>>>
>>> This capability is only enabled if the underlying device advertises
>>> that it is supported.
>>
>> Thanks for your continuing work on this.
>>
>> I think we really need to document the security assumptions, though.
>>
>
> Yes, that's a good idea. Maybe a file in Documentation/svcrdma?

That would be great!  (Actually Documentation/filesystems/nfs-something
might be good.  Adding it to nfs-rdma.txt would be ideal.)

>
>> (Currently is your entire memory at the mercy of anyone on the same
>> local network as your rdma adapter?
>
> ------------------------------------------------------------------------
>
> A principal exploit is that a node listening on a mirror port of a switch
> could snoop RDMA packets containing RKEY and then forge a packet with this
> RKEY to write or read the memory of the peer to which the RKEY referred.

RKEY?  Apologies, I've been avoiding up till now asking about every bit
of jargon in hopes I could still get the gist, but I think I have to
give up and learn it.  Remind me what I need to read?

> The NFSRDMA protocol is defined such that a) only the server initiates
> RDMA, and b) only the client's memory is exposed via RKEY. This is why
> the server reads to fetch RPC data from the client even though it would
> be more efficient for the client to write the data to the server's memory.
>
> The above design goal is not entirely realized with iWARP, however, because
> the RKEY (called an STag on iWARP) for the data sink of an RDMA_READ is
> actually placed on the wire!

So "data sink" here means the server memory that the data's being copied
to?  OK.

> Not only that, iWARP (RDDP) requires that this
> RKEY have Remote Write! This means that the server's memory is exposed by
> virtue of having placed the RKEY for it's local memory on the wire in order
> to receive the result of the RDMA_READ.

Got it.

> By contrast, IB uses an opaque
> transaction ID# to associate the READ_RPL with the READ_REQ _and_ the data

Google gives only two hits for READ_RPL.  Help!

> sink of an RDMA_READ does not require remote access. That said, the evil node
> in question, for example, could potentially forge a packet with this
> transaction ID and corrupt the target memory, however, the duration
> of the exploit is this single READ_REQ.

OK.  So what would be the effect of the forged packet?

> The newer RDMA adapters (both iWARP and IB) support "Fast Memory Registration".
> This capability allows memory to be quickly registered and
> de-registered by submitting WR on the SQ. So the idea is to create an RKEY
> that ONLY maps the single RPC. So the WR sequence is post_map,
> post_rdma_read, post_invalidate. This has two benefits, a) it restricts the
> domain of the exploit to the memory of a single RPC,

So the only server-side memory that can be remotely written to is the
pages that will hold the write data?

> and b) it limits the
> duration of the exploit to the time it takes to satisfy the RDMA_READ.

OK.

>   If so, fixing that would certainly
>> make this stuff useful in more situations, but language like "a very
>> short window" doesn't sound promising.  Also, we've got to make sure
>> users understand where it's safe to use this stuff....)
>>
>
> There are those who argue that a one-shot STag/RKEY is no less secure than TCP.

If the attacker is limited to corrupting some write data, then, yes,
that doesn't sound so different from nfs/rcp with auth_unix.

> Consider that the exact same evil application could more easily corrupt RPC
> payload by simply forging a packet with the correct TCP sequence number --
> in fact it's easier than the RDMA exploit because the RDMA exploit requires
> that you correctly forge both the TCP packet _and_ the RDMA payload. In
> addition the duration of the TCP exploit is the lifetime of the connection, not
> the lifetime of a single WR.
>
> So if you buy the argument above, RDMA on IB or iWARP using Fast Reg is no
> less secure than TCP. That is the goal of this patch series.

OK, thanks.

--b.
