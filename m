Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa07-10.prod.phx3.secureserver.net ([173.201.192.239]:49434
	"EHLO p3plsmtpa07-10.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932939AbbGJSmx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 14:42:53 -0400
Message-ID: <55A01225.9000000@talpey.com>
Date: Fri, 10 Jul 2015 14:42:45 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Doug Ledford <dledford@redhat.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
CC: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <20150708203205.GA21847@infradead.org> <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <55A00754.4010009@redhat.com>
In-Reply-To: <55A00754.4010009@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/10/2015 1:56 PM, Doug Ledford wrote:
> On 07/10/2015 12:11 PM, Jason Gunthorpe wrote:
>> On Fri, Jul 10, 2015 at 09:22:24AM -0400, Tom Talpey wrote:
>>> and it is enabled only when the RDMA Read is active.
>>
>> ??? How is that done? ib_get_dma_mr is defined to return a remote
>> usable rkey that is valid from when it it returns until the MR is
>> destroyed. NFS creates one mr early on, it does not seem to make one
>> per RDMA READ?

Actually you're right - the NFS server never tears down the MR. So, the
old code is just as vulnerable as the new code.

>> For the proposed iSER patch the problem is very acute, iser makes a
>> single PD and phys MR at boot time for each device. This means there
>> is a single machine wide unchanging rkey that allows remote physical
>> memory access. An attacker only has to repeatedly open QPs to iSER and
>> guess rkey values until they find it. Add in likely non-crypto
>> randomness for rkeys, and I bet it isn't even that hard to do.

The rkeys have a PD, wich cannot be forged, so it's not a matter of
attacking, but it is most definitely a system integrity risk, as I
mentioned earlier, a simple arithmetic offset mistake can overwrite
anything.

>> So this seems to be a catastrophic security failing.

s/security/integrity/ and I agree.

> As I recall, didn't the NFSoRDMA stack do even worse in the beginning
> (meaning it previously had a memory model that was simply "register all
> memory on the client and pass the rkey to the server and then tell the
> server when/where to read/write", which was subsequently removed in
> Chuck's NFSoRDMA cleanups over the last 5 or so kernel versions)?

Yes, Doug, shamefully it did, but

a) That was the client and Jason and I are talking about the server
b) When that code was written (2007), FRMR did not exist, and other
    memory registration methods had abysmal performance
c) It was heavily deprecated with console warnings emitted
d) Chuck did away with it since then.

> I'm not bringing this up to downplay the current iSER issue, but to
> demonstrate that we have long had a different trust model than the one
> in RFC5042.  More below on that.

I'll say something after requoting you.

>>>>  From there, it is a logical wish: If Steve is going to FRMR'ize iSER
>>>> to be acceptable security wise, I'd rather see that work done on in a
>>>> general way. Hence the API discussion.
>>>
>>> Well, it's important to realize that NFS already does the Right Thing.
>>> So it isn't actually an urgent issue. There is time to discuss.
>>
>> It depends on what is going on with iWarp iSER. If the iWarp community
>> thinks it should go ahead insecurely then fine, put a giant warning in
>> dmesg and go ahead, otherwise iWarp needs to address this difference
>> with a proper generic API, which appears, must wrapper
>> ib_post_send. Harder job :\
>>
>> I'm sorry Steve for leading you down the wrong path with these flags,
>> I did not fully realize exactly what the iWarp difference was at the
>> start :(
>
> Are there security issues?  Yes.  Are we going to solve them in this
> patch set?  No.  Especially since those security issues extend beyond
> iSER + iWARP.
>
> There are currently 4 RDMA capable link types/protocols.  Of those 4, 3
> enforce locality (IB, OPA, RoCE all require lossless fabrics and cannot
> be sent out into the wild internet).  RFC5042 is written with iWARP in
> mind because it *can* be sent out over the Internet and therefore it is
> possible for someone to place an RNIC card directly on the Internet and
> it must therefore deal with all of the attack vectors this entails.
>
> The linux RDMA stack, as a whole, is no where near RFC5042 compliant.
> And it isn't just the kernel space at fault here.  Early versions of
> opensm used to require that the master and slave machines must have
> passwordless root ssh access to each other to copy around the guid2lid
> file so when the master failed over, the slave would have an up to date
> list.
>
> Because 3 of the 4 RDMA technology types enforce localized clusters, the
> majority of the stack and the implementations have utilized the cluster
> as the point of trust.  In truth, I think it's simply been the easy way
> to do things.  RFC5042 is very clearly a non-trust model where each
> machine, and each connection, is assumed to be a threat.
>
> So, long story short(ish):
>
> While this discussion is taking place in the cleanup thread, part of it
> involves the preceding patch set: iSER support for iWARP.  Patch 4/5 in
> the iSER/iWARP series enables the remote write on device->mr
> registration which constitutes the security issue we've been discussing.
>   This cleanup patch set, then, is merely guilty of hiding that security
> issue, not introducing it.
>
> I think Steve and the other iSER folks should consider the wisdom of
> including the iWARP support as it stands.  If they think that the common
> use case is in a sequestered cluster, and that the current trust domain
> is already not RFC5042 compliant, then I'm OK with enabling iSER support
> for iWARP, but I would want there to be a very clear warning in the
> dmesg about the trust domain issue.  I might even suggest that the iSER
> driver, at least on iWARP connections, could possibly check the src/dst
> addresses to make sure that they are in a private IP domain and if they
> aren't, refuse to create a connection while emitting an additional
> warning about the trust domain.
>
> As far as the cleanup patches are concerned, I'm OK with those too.
> However, since we would have added a large warning in the iSER code
> about this issue, and that would then go away with the cleanup, the
> warning would need to be generalized (such as "module <foo> is
> requesting insecure iWARP mappings"), and appropriately WARN_ONCEd on
> probably a per module basis or something like that.
>
>  From there, we can start to look at the bigger picture of cleanup up the
> default trust domain in the kernel and user space both (and soliciting
> feedback on that...I have a suspicion that some users will not like us
> tightening up security as it might interfere with their usage in their
> sequestered clusters).

All excellent points. It's not worse, and it adds important transport
support.

However, it's an extremely bad idea to codify writable privileged rmr's
in the API as best practice. So under no circumstance should that become
the long term plan.

Tom.

