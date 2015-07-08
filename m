Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:44600 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbbGHXgR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 19:36:17 -0400
Date: Wed, 8 Jul 2015 17:36:04 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Tom Talpey <tom@talpey.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150708233604.GA20765@obsidianresearch.com>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559D983D.6000804@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 05:38:05PM -0400, Tom Talpey wrote:
> On 7/8/2015 3:08 PM, Jason Gunthorpe wrote:
> >The MR stuff was never really designed, the HW people provided some
> >capability and the SW side just raw exposed it, thoughtlessly.
> 
> Jason, I don't disagree that the API can be improved. I have some
> responses to your statements below though.
> 
> >Why is code using iWarp calling ib_get_dma_mr with
> >RDMA_MRR_READ_DEST/IB_ACCESS_REMOTE_WRITE ? That is insecure.
> 
> Because the iWARP protocol requires it, which was very much an
> intentional decision. It actually is not insecure, as discussed
> in detail in RFC5042. However, it is different from Infiniband.

You'll have to point me to the section on that..

ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) is defined to create a remote
access MR to all of physical memory. That means there exists a packet
the far side can send that will write to any place in physical memory.

Yes, the far side has to guess the key, but there is no way you'll
convince me that is secure, and 6.3.4 supports that position.

   "The ULP must set the base and bounds of the buffer when the
    STag is initialized to expose only the data to be retrieved."

ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) directly contravenes that
requirement.

I assume you mean when it creates a FRMR it is secure that it uses
IB_ACCESS_REMOTE_WRITE and the invalidates the MR before accessing it
- and I agree with that.

> >Why on earth is NFS using frmr to create RDMA READ lkeys?
> 
> Because NFS desires to have a single code path that works for all
> transports. In addition, using the IB dma_mr as an lkey means that
> large I/O (common with NFS) would require multiple RDMA Read
> operations, when the page list exceeded the local scatter/gather
> limit of the device.

So NFS got overwhelmed by API complexity and used a scheme that
penalizes all hardware, in all cases, rather than fall back on MR only
when absolutely necessary. Not really a ringing endorsement of status
quo....

> >I think when you do that, it quickly becomes clear that iWarp's
> >problem is not a seemingly minor issue with different flag bits, but
> >that iWarp *cannot* use local_dma_lkey as a RDMA READ local buffer.
> >Using ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) is an insecure work
> >around. So iWarp (and only iWarp) should take the pain of spinning up
> >temporary local MRs for RDMA READ.
> 
> That is entirely the wrong layer to address this. It would prevent
> reuse of MRs, and require upper layers to be aware that this was
> the case - which is exactly the opposite of what you are trying
> to achieve.

How So?

I'd hope for an API that is transparent to the upper layer, that lets
the driver/core do a variety of things.

If a call needs to create a temporary local MR, then the API should be
structured so the driver/core can do that. If the MR type benefits
from re-use then the core/driver should internally pool and re-use the
MRs.

Give me a reason why NFS should care about any of this? All it is
doing is issuing RDMA READ's and expecting that data to land in local
memory.

Concretely, I'd imagine something like

cookie = rdma_post_read(sendq,local_sg,remote_sg,wrid);
[..]
if (wc->wrid == wrid)
  rdma_complete_read(sendq,cookie);

And the core/driver will RDMA READ the remote addresses in remote_sg
list into the local_sg, using the best available strategy, and it
doesn't have limits like only a few SG entries because 'best
available strategy' includes using temporary MRs and multiple SQWEs.

The driver will pick the 'best available strategy' that suits the HW
it is driving, not NFS/iSER/SRP/Lustre.

Same basic story for SEND, WRITE and RECV.

> >This should all be hidden under a common API and it shouldn't be
> >sprinkled all over the place in NFS, iSER, etc.
> 
> Are you arguing that all upper layer storage protocols take a single
> common approach to memory registration? That is a very different
> discussion.

I'm arguing upper layer protocols should never even see local memory
registration, that it is totally irrelevant to them. So yes, you can
call that a common approach to memory registration if you like..

Basically it appears there is nothing that NFS can do to optimize that
process that cannot be done in the driver/core equally effectively and
shared between all ULPs. If you see something otherwise, I'm really
interested to hear about it.

Even your case of the MR trade off for S/G list limitations - that is
a performance point NFS has no buisness choosing. The driver is best
placed to know when to switch between S/G lists, multiple RDMA READs
and MR. The trade off will shift depending on HW limits:
 - Old mthca hardware is probably better to use multiple RDMA READ
 - mlx4 is probably better to use FRMR
 - mlx5 is likely best with indirect MR
 - All of the above are likely best to exhaust the S/G list first
 
The same basic argument is true of WRITE, SEND and RECV. If the S/G
list is exhausted then the API should transparently build a local MR
to linearize the buffer, and the API should be designed so the core
code can do that without the ULP having to be involved in those
details.

Is it possible?

Jason
