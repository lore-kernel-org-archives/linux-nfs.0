Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:57078 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754545AbbGIVRW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Jul 2015 17:17:22 -0400
Date: Thu, 9 Jul 2015 15:16:58 -0600
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
Message-ID: <20150709211658.GA29044@obsidianresearch.com>
References: <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <559D983D.6000804@talpey.com>
 <20150708233604.GA20765@obsidianresearch.com>
 <559E54AB.2010905@dev.mellanox.co.il>
 <20150709170142.GA21921@obsidianresearch.com>
 <559ED2E5.3040901@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559ED2E5.3040901@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 09, 2015 at 04:00:37PM -0400, Tom Talpey wrote:
> On 7/9/2015 1:01 PM, Jason Gunthorpe wrote:
> >Laid out like this, I think it even means we can nuke the IB DMA API
> >for these cases. rdma_post_read and rdma_post_complete_read are the
> >two points that need dma api calls (cache flushes), and they can just
> >do them internally.
> >
> >This also tells me that the above call sites must already exist in
> >every ULP, so we, again, are not really substantially changing
> >core control flow for the ULP.
> >
> >Are there more details that wreck the world?
> 
> Two things come to mind - PD's, and virtualization.
> 
> If there's no ib_get_dma_mr() call, what PD does the region get?
> One could argue it inherits the QP's (Emulex proposed such a
> PD-less MR in this year's OFS Developer's Workshop). But this
> could impose new conditions on ULP's; they would have to be
> aware of this affinity and it could affect their QP use.

You'll have to educate me here. Why does the in-kernel ULP care about
what PD is used for lkey MRs?

This is a real question - every ULP in kernel seems to create a single
PD per device and thats it. (though NFS creates two, I assume that is
some odd internal split, not actually functional)

So, if there is a reason to have multiple PD's, nobody has done
anything with it in the last decade?

Thus, I think, for use on a lkey MR, it doesn't matter what PD is
used, as long as the adaptor will execute the request. If the driver
needs a PD, then using the one from the QP seems like it would cause
no problems.

> More importantly, if a guest can post FRWR work requests with
> physical addresses, what enforces their validity? The dma_mr
> provides a PD but it also allows the host partition to interpose
> on the call, setting up an IOMMU mapping, creating a new NIC TPT
> mapping, etc. Without this, it may be possible for hostile guest
> to forge FRMR's and attack the host, or other guests.

The MR concept doesn't go away, it just stops being exposed to the ULP.

Every PD would implictly create a ib_get_dma_mr that can handle all
local access. This isn't even a change, every ULP that creates a PD
also immediately creates a ib_get_dma_mr, I'm just moving that into
the alloc_pd call so the ULP never sees it.

FRMR doesn't change, other than the WR is created in the core/driver
layer, not the ULP. Whatever is put in that WR isn't going to change,
if it is secure today, then it will still be secure tomorrow.

Temporary MRs mean that rmda_post_read needs to be called in a context
where it can hypercall to create one, if the driver needs. I don't
think this is any different from the requirements the DMA API has? So
nothing changes. Not exactly sure what ULPs do here, but I'm expecting
they do this call before posting. Do any thread it?

Sagi's comment on indirect registrations seems like future
virtualization schemes will use a SQE post like FRMR to do this, but I
don't know the details.

So, nothing really seems to change here. What am I missing?

> > I didn't explore how errors work, but, I think, errors are just a
> > labeling exercise:
> >   if (wc is error && wc.wrid == read_wrid
> >      rdma_error_complete_read(...,read_wrid,wc)
> >
> > Error recovery blows up the QP, so we just need to book keep and get
> > the MRs accounted for. The driver could do a synchronous clean up of
> > whatever mess is left during the next create_qp, or on the PD destroy.
> 
> This is a subtle area. If the driver posts silenced completions as
> you describe, there may not be a wc to reap. So either the driver or
> the ULP will need to post a sentinel, the completion of which indicates
> any prior silenced operations have actually done so. This can be
> hard to get right. And if the driver posts everything signaled, well,
> performance at high IOPS will be a challenge. The ULP is much better
> positioned to manage that.

But again, nothing really changes. The ULP calls rdma_post_read, and
like every other ib_post_send type thing, it will ask for signaled
completion or not.

If yes, then the last WR in the chain gets marked, otherwise none are
marked. No different than what a ULP would do today when it builds WRs
manually.

The trick is, every call to rdma_post_read *MUST* be paired with a
call to either rdma_error_complete_read, or rdma_post_complete_read
with the wrid from above.

If the ULP is using supressed completion, then it must bookkeep this
stuff, and if it sees a completion for WRID+10, it must go through and
call rdma_post_complete_read for WRID+0,+1,+2, ...

Error unwind is similar..

> I'm with you on the flow control, btw. It's a new rule for the
> ULP to obey, but probably not too onerous. Remember though, verbs
> today return EAGAIN when the queue you're posting is full (a
> terrible choice IMO). So upper layers don't actually need to
> count WR's, unless they want to.

Yes, EAGAIN is ugly, but we cannot trivially support that at this
proposed API level. The issue is idempotency, if the core/driver needs
to push 3 SGEs on, and only 2 make it, then WTF does the ULP do?

To support EAGAIN, the core/drivers needs to support an all or nothing
ib_post_send, which is beyond the driver capability we have today...

Jason
