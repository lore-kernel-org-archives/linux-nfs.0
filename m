Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-03.prod.phx3.secureserver.net ([173.201.192.104]:46340
	"EHLO p3plsmtpa06-03.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753516AbbGIUAn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:00:43 -0400
Message-ID: <559ED2E5.3040901@talpey.com>
Date: Thu, 09 Jul 2015 16:00:37 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>
CC: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
References: <559B9891.8060907@dev.mellanox.co.il> <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com> <20150707161751.GA623@obsidianresearch.com> <559BFE03.4020709@dev.mellanox.co.il> <20150707213628.GA5661@obsidianresearch.com> <559CD174.4040901@dev.mellanox.co.il> <20150708190842.GB11740@obsidianresearch.com> <559D983D.6000804@talpey.com> <20150708233604.GA20765@obsidianresearch.com> <559E54AB.2010905@dev.mellanox.co.il> <20150709170142.GA21921@obsidianresearch.com>
In-Reply-To: <20150709170142.GA21921@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 1:01 PM, Jason Gunthorpe wrote:
> Laid out like this, I think it even means we can nuke the IB DMA API
> for these cases. rdma_post_read and rdma_post_complete_read are the
> two points that need dma api calls (cache flushes), and they can just
> do them internally.
>
> This also tells me that the above call sites must already exist in
> every ULP, so we, again, are not really substantially changing
> core control flow for the ULP.
>
> Are there more details that wreck the world?

Two things come to mind - PD's, and virtualization.

If there's no ib_get_dma_mr() call, what PD does the region get?
One could argue it inherits the QP's (Emulex proposed such a
PD-less MR in this year's OFS Developer's Workshop). But this
could impose new conditions on ULP's; they would have to be
aware of this affinity and it could affect their QP use.

More importantly, if a guest can post FRWR work requests with
physical addresses, what enforces their validity? The dma_mr
provides a PD but it also allows the host partition to interpose
on the call, setting up an IOMMU mapping, creating a new NIC TPT
mapping, etc. Without this, it may be possible for hostile guest
to forge FRMR's and attack the host, or other guests.

 > I didn't explore how errors work, but, I think, errors are just a
 > labeling exercise:
 >   if (wc is error && wc.wrid == read_wrid
 >      rdma_error_complete_read(...,read_wrid,wc)
 >
 > Error recovery blows up the QP, so we just need to book keep and get
 > the MRs accounted for. The driver could do a synchronous clean up of
 > whatever mess is left during the next create_qp, or on the PD destroy.

This is a subtle area. If the driver posts silenced completions as
you describe, there may not be a wc to reap. So either the driver or
the ULP will need to post a sentinel, the completion of which indicates
any prior silenced operations have actually done so. This can be
hard to get right. And if the driver posts everything signaled, well,
performance at high IOPS will be a challenge. The ULP is much better
positioned to manage that.

I'm with you on the flow control, btw. It's a new rule for the
ULP to obey, but probably not too onerous. Remember though, verbs
today return EAGAIN when the queue you're posting is full (a
terrible choice IMO). So upper layers don't actually need to
count WR's, unless they want to.

Tom.
