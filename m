Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f177.google.com ([209.85.212.177]:54860 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932527AbaJVUxX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2014 16:53:23 -0400
Received: by mail-wi0-f177.google.com with SMTP id ex7so126873wid.4
        for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2014 13:53:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <F1F06936-AB16-4E64-A484-B8D4B628E51A@oracle.com>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
	<20141016194000.13414.83844.stgit@manet.1015granger.net>
	<54454762.8020506@Netapp.com>
	<A1CBA20C-FA2F-4E6B-9D94-75F7EFDED9C3@oracle.com>
	<CAHQdGtTgJ7vRR3Kw8n4K4=PSoMXV_ZQK9yFkAcK-CK5xsaTm3A@mail.gmail.com>
	<D259448C-9E9B-43AE-A809-A73C3C2716C5@oracle.com>
	<CAHQdGtRahOX68j6J6Vq9ykBE-2qUm1sd_HPw=HGimKAGs5V=9Q@mail.gmail.com>
	<5BF0312C-06EC-4D83-81E9-F929724A0EAD@oracle.com>
	<CAHQdGtRumr9Cr6oJPUEw5nLiiWqNW5JRq7tzpsKUVtCG=F1QFg@mail.gmail.com>
	<EB7360E0-CDE8-40A6-8F91-6A119EE68DEC@oracle.com>
	<CAHQdGtTgE3MdkcW9+NFgKCg81nUC0bGW8Mp26EKcu0RAT2TiPA@mail.gmail.com>
	<F1F06936-AB16-4E64-A484-B8D4B628E51A@oracle.com>
Date: Wed, 22 Oct 2014 23:53:21 +0300
Message-ID: <CAHQdGtQu99Xh5FiQLGd=kijT_zv2nssTqqBC=uBvj5GRLJzr4A@mail.gmail.com>
Subject: Re: [PATCH v1 13/16] NFS: Add sidecar RPC client support
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tom Talpey <tom@talpey.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2014 at 8:20 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Oct 22, 2014, at 4:39 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>
>>> On Tue, Oct 21, 2014 at 8:11 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>> On Oct 21, 2014, at 3:45 AM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>>
>>>>> On Tue, Oct 21, 2014 at 4:06 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>
>>>>> There is no show-stopper (see Section 5.1, after all). It’s
>>>>> simply a matter of development effort: a side-car is much
>>>>> less work than implementing full RDMA backchannel support for
>>>>> both a client and server, especially since TCP backchannel
>>>>> already works and can be used immediately.
>>>>>
>>>>> Also, no problem with eventually implementing RDMA backchannel
>>>>> if the complexity, and any performance overhead it introduces in
>>>>> the forward channel, can be justified. The client can use the
>>>>> CREATE_SESSION flags to detect what a server supports.
>>>>
>>>> What complexity and performance overhead does it introduce in the
>>>> forward channel?
>>>
>>> The benefit of RDMA is that there are opportunities to
>>> reduce host CPU interaction with incoming data.
>>> Bi-direction requires that the transport look at the RPC
>>> header to determine the direction of the message. That
>>> could have an impact on the forward channel, but it’s
>>> never been measured, to my knowledge.
>>>
>>> The reason this is more of an issue for RPC/RDMA is that
>>> a copy of the XID appears in the RPC/RDMA header to avoid
>>> the need to look at the RPC header. That’s typically what
>>> implementations use to steer RPC reply processing.
>>>
>>> Often the RPC/RDMA header and RPC header land in
>>> disparate buffers. The RPC/RDMA reply handler looks
>>> strictly at the RPC/RDMA header, and runs in a tasklet
>>> usually on a different CPU. Adding bi-direction would mean
>>> the transport would have to peek into the upper layer
>>> headers, possibly resulting in cache line bouncing.
>>
>> Under what circumstances would you expect to receive a valid NFSv4.1
>> callback with an RDMA header that spans multiple cache lines?
>
> The RPC header and RPC/RDMA header are separate entities, but
> together can span multiple cache lines if the server has returned a
> chunk list containing multiple entries.
>
> For example, RDMA_NOMSG would send the RPC/RDMA header
> via RDMA SEND with a chunk list that represents the RPC and NFS
> payload. That list could make the header larger than 32 bytes.
>
> I expect that any callback that involves more than 1024 byte of
> RPC payload will need to use RDMA_NOMSG. A long device
> info list might fit that category?

Right, but are there any callbacks that would do that? AFAICS, most of
them are CB_SEQUENCE+(PUT_FH+CB_do_some_recall_operation_on_this_file
| some single CB_operation)

The point is that we can set finite limits on the size of callbacks in
the CREATE_SESSION. As long as those limits are reasonable (and 1K
does seem more than reasonable for existing use cases) then why
shouldn't we be able to expect the server to use RDMA_MSG?

>>> The complexity would be the addition of over a hundred
>>> new lines of code on the client, and possibly a similar
>>> amount of new code on the server. Small, perhaps, but
>>> not insignificant.
>>
>> Until there are RDMA users, I care a lot less about code changes to
>> xprtrdma than to NFS.
>>
>>>>>> 2) Why do we instead have to solve the whole backchannel problem in
>>>>>> the NFSv4.1 layer, and where is the discussion of the merits for and
>>>>>> against that particular solution? As far as I can tell, it imposes at
>>>>>> least 2 extra requirements:
>>>>>> a) NFSv4.1 client+server must have support either for session
>>>>>> trunking or for clientid trunking
>>>>>
>>>>> Very minimal trunking support. The only operation allowed on
>>>>> the TCP side-car's forward channel is BIND_CONN_TO_SESSION.
>>>>>
>>>>> Bruce told me that associating multiple transports to a
>>>>> clientid/session should not be an issue for his server (his
>>>>> words were “if that doesn’t work, it’s a bug”).
>>>>>
>>>>> Would this restrictive form of trunking present a problem?
>>>>>
>>>>>> b) NFSv4.1 client must be able to set up a TCP connection to the
>>>>>> server (that can be session/clientid trunked with the existing RDMA
>>>>>> channel)
>>>>>
>>>>> Also very minimal changes. The changes are already done,
>>>>> posted in v1 of this patch series.
>>>>
>>>> I'm not asking for details on the size of the changesets, but for a
>>>> justification of the design itself.
>>>
>>> The size of the changeset _is_ the justification. It’s
>>> a much less invasive change to add a TCP side-car than
>>> it is to implement RDMA backchannel on both server and
>>> client.
>>
>> Please define your use of the word "invasive" in the above context. To
>> me "invasive" means "will affect code that is in use by others".
>
> The server side, then, is non-invasive. The client side makes minor
> changes to state management.
>
>>
>>> Most servers would require almost no change. Linux needs
>>> only a bug fix or two. Effectively zero-impact for
>>> servers that already support NFSv4.0 on RDMA to get
>>> NFSv4.1 and pNFS on RDMA, with working callbacks.
>>>
>>> That’s really all there is to it. It’s almost entirely a
>>> practical consideration: we have the infrastructure and
>>> can make it work in just a few lines of code.
>>>
>>>> If it is possible to confine all
>>>> the changes to the RPC/RDMA layer, then why consider patches that
>>>> change the NFSv4.1 layer at all?
>>>
>>> The fast new transport bring-up benefit is probably the
>>> biggest win. A TCP side-car makes bringing up any new
>>> transport implementation simpler.
>>
>> That's an assertion that assumes:
>> - we actually want to implement more transports aside from RDMA
>
> So you no longer consider RPC/SCTP a possibility?

I'd still like to consider it, but the whole point would be to _avoid_
doing trunking in the NFS layer. SCTP does trunking/multi-pathing at
the transport level, meaning that we don't have to deal with tracking
connections, state, replaying messages, etc.
Doing bi-directional RPC with SCTP is not an issue, since the
transport is fully symmetric.

>> - implementing bi-directional transports in the RPC layer is non-simple
>
> I don't care to generalize about that. In the RPC/RDMA case, there
> are some complications that make it non-simple, but not impossible.
> So we have an example of a non-simple case, IMO.
>
>> Right now, the benefit is only to RDMA users. Nobody else is asking
>> for such a change.
>>
>>> And, RPC/RDMA offers zero performance benefit for
>>> backchannel traffic, especially since CB traffic would
>>> never move via RDMA READ/WRITE (as per RFC 5667 section
>>> 5.1).
>>>
>>> The primary benefit to doing an RPC/RDMA-only solution
>>> is that there is no upper layer impact. Is that a design
>>> requirement?
>
> Based on your objections, it appears that "no upper layer
> impact" is a hard design requirement. I will take this as a
> NACK for the side-car approach.

There is not a hard NACK yet, but I am asking for stronger
justification. I do _not_ want to find myself in a situation 2 or 3
years down the road where I have to argue against someone telling me
that we additionally have to implement callbacks over IB/RDMA because
the TCP sidecar is an incomplete solution. We should do either one or
the other, but not both...

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
