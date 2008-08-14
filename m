From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Thu, 14 Aug 2008 16:23:09 -0500
Message-ID: <48A4A23D.8040702@opengridcomputing.com>
References: <48A30685.6050301@opengridcomputing.com> <20080813211953.GN26765@fieldses.org> <48A36004.1030304@opengridcomputing.com> <20080814194847.GH23859@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:52204 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbYHNVXK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2008 17:23:10 -0400
In-Reply-To: <20080814194847.GH23859@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 05:28:20PM -0500, Tom Tucker wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Aug 13, 2008 at 11:06:29AM -0500, Tom Tucker wrote:
>>>> This patchset implements support for Fast Memory Registration in the
>>>> NFS server.  Fast Memory Regstration is the ability to quickly map a
>>>> kernel memory page list as a logically contiguous memory region from
>>>> the perspective of the adapter. This mapping is created and
>>>> invalidated using work requests posted on the SQ. This allows for
>>>> large amounts of data to transferred between the client and server
>>>> with a single work request as well as the ability to invalidate a
>>>> previously mapped memory region. For iWARP, this allows for "one-shot"
>>>> memory regions to be mapped for a single NFS-RDMA data transfer. This
>>>> improves security since a byzantine app listening on the net will have
>>>> a very short window during which the RKEY is valid.
>>>>
>>>> This capability is only enabled if the underlying device advertises
>>>> that it is supported.
>>> Thanks for your continuing work on this.
>>>
>>> I think we really need to document the security assumptions, though.
>>>
>> Yes, that's a good idea. Maybe a file in Documentation/svcrdma?
> 
> That would be great!  (Actually Documentation/filesystems/nfs-something
> might be good.  Adding it to nfs-rdma.txt would be ideal.)
> 
>>> (Currently is your entire memory at the mercy of anyone on the same
>>> local network as your rdma adapter?
>> ------------------------------------------------------------------------
>>
>> A principal exploit is that a node listening on a mirror port of a switch
>> could snoop RDMA packets containing RKEY and then forge a packet with this
>> RKEY to write or read the memory of the peer to which the RKEY referred.
> 
> RKEY?  Apologies, I've been avoiding up till now asking about every bit
> of jargon in hopes I could still get the gist, but I think I have to
> give up and learn it.  Remind me what I need to read?

Erf. You can read the IBTA/IETF specs. (see below), but that's overkill. 
Here's brief cheat-sheet:

- MR - Memory Region. A region of memory registered with the adapter and 
referred to with an identifier. For iWARP, the identifier is called an 
STag (Steering Tag). For IB, it's called an [L|R]KEY.

- RKEY	- Remote Key. A MR identifier exchanged on the wire between peers 
that allows the remote peer to access the issuing peer's memory. The 
permissions (REMOTE_READ, REMOTE_WRITE, LOCAL_READ, LOCAL_WRITE) are 
assigned at the time the MR is created/registered

- LKEY - Local Key. A MR identifer used locally to refer to an MR 
registered with the adapter. Can only the have local access rights above.

- STag - Steering Tag, can have both local and remote access rights.

For the OFA verbs, we refer to everything as an LKEY/RKEY.

FastReg adds the feature that an STag/RKEY can be created and then 
iteratively registered/invalidated.

> 
>> The NFSRDMA protocol is defined such that a) only the server initiates
>> RDMA, and b) only the client's memory is exposed via RKEY. This is why
>> the server reads to fetch RPC data from the client even though it would
>> be more efficient for the client to write the data to the server's memory.
>>
>> The above design goal is not entirely realized with iWARP, however, because
>> the RKEY (called an STag on iWARP) for the data sink of an RDMA_READ is
>> actually placed on the wire!
> 
> So "data sink" here means the server memory that the data's being copied
> to?  OK.

Yes.

> 
>> Not only that, iWARP (RDDP) requires that this
>> RKEY have Remote Write! This means that the server's memory is exposed by
>> virtue of having placed the RKEY for it's local memory on the wire in order
>> to receive the result of the RDMA_READ.
> 
> Got it.
> 
>> By contrast, IB uses an opaque
>> transaction ID# to associate the READ_RPL with the READ_REQ _and_ the data
> 
> Google gives only two hits for READ_RPL.  Help!

Sorry, I'm trying to generalize and glossing over details trying to get 
to the meat of it...

The verbs request (WR) is an RDMA_READ. On the wire, this becomes 
READ_REQ (read-request, ask the peer to read its memory), followed by 
some number of READ_RPL (read replies, # depends on amount read/mtu). 
The READ_REQ contains the RKEY from which you wish to read, the READ_RPL 
contains the target buffer spec + data. For iWARP this READ_RPL message 
contains a local memory ID (i.e. LKEY) + payload. For IB it contains the 
transaction ID + payload.

> 
>> sink of an RDMA_READ does not require remote access. That said, the evil node
>> in question, for example, could potentially forge a packet with this
>> transaction ID and corrupt the target memory, however, the duration
>> of the exploit is this single READ_REQ.
> 
> OK.  So what would be the effect of the forged packet?
> 

Corrupting the local memory that you are reading the remote payload 
into. So I try to read "hello" from the peer, but the troll under the 
bridge writes "goodbye" into this buffer.

The scope of the corruption depends on the amount of local memory 
exposed by the LKEY. This goal of the patches is to minimize this memory 
footprint to just the RPC memory into which we're reading.

>> The newer RDMA adapters (both iWARP and IB) support "Fast Memory Registration".
>> This capability allows memory to be quickly registered and
>> de-registered by submitting WR on the SQ. So the idea is to create an RKEY
>> that ONLY maps the single RPC. So the WR sequence is post_map,
>> post_rdma_read, post_invalidate. This has two benefits, a) it restricts the
>> domain of the exploit to the memory of a single RPC,
> 
> So the only server-side memory that can be remotely written to is the
> pages that will hold the write data?
> 
>> and b) it limits the
>> duration of the exploit to the time it takes to satisfy the RDMA_READ.
> 
> OK.
> 
>>   If so, fixing that would certainly
>>> make this stuff useful in more situations, but language like "a very
>>> short window" doesn't sound promising.  Also, we've got to make sure
>>> users understand where it's safe to use this stuff....)
>>>
>> There are those who argue that a one-shot STag/RKEY is no less secure than TCP.
> 
> If the attacker is limited to corrupting some write data, then, yes,
> that doesn't sound so different from nfs/rcp with auth_unix.
> 
>> Consider that the exact same evil application could more easily corrupt RPC
>> payload by simply forging a packet with the correct TCP sequence number --
>> in fact it's easier than the RDMA exploit because the RDMA exploit requires
>> that you correctly forge both the TCP packet _and_ the RDMA payload. In
>> addition the duration of the TCP exploit is the lifetime of the connection, not
>> the lifetime of a single WR.
>>
>> So if you buy the argument above, RDMA on IB or iWARP using Fast Reg is no
>> less secure than TCP. That is the goal of this patch series.
> 
> OK, thanks.
>

Here are the relevant specs:

Unfortunately, the IB specs are private to the IBTA.
http://www.infinibandta.org/home

The OFA verbs most closely resemble IB verbs.

Here are the iWARP protocol specs:

http://www.ietf.org/rfc/rfc5040.txt
http://www.ietf.org/rfc/rfc5041.txt
http://www.ietf.org/rfc/rfc5044.txt

Here are the iWARP verbs specs. This is what the adapters where written to.

http://www.rdmaconsortium.org/home/RNIC_Verbs_Overview2.pdf
http://www.rdmaconsortium.org/home/draft-hilland-iwarp-verbs-v1.0-RDMAC.pdf

Tom

> --b.

