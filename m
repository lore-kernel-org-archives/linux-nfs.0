Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:46355 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752781AbbGNUaA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 16:30:00 -0400
Date: Tue, 14 Jul 2015 14:29:43 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714202943.GB26927@obsidianresearch.com>
References: <559EF332.7060103@redhat.com>
 <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150714195511.GB7716@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 12:55:11PM -0700, 'Christoph Hellwig' wrote:
> On Tue, Jul 14, 2015 at 02:32:31PM -0500, Steve Wise wrote:
> > You mean "should not", yea?  
> > 
> > Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)
> 
> Just curious if there are any holes in this little scheme to deal with
> the lkey mess:
> 
>  (1) make sure all drivers that currently do not set
>      IB_DEVICE_LOCAL_DMA_LKEY but which can safely use ib_get_dma_mr
>      call it underneath at device setup time, and tear it down before
>      removal.

Yes, I'd like this.

local_dma_lkey appears to be global, it works with any PD.

ib_get_dma_mr is tied to a PD, so it cannot replace local_dma_lkey at
the struct device level.

ib_alloc_pd is the in-kernel entry point, the UAPI calls
device->alloc_pd directly.. So how about the below patch as a starting
       >point?

(Steve the goal of step #1 would be to remove ib_get_dma_mr from ULPs
 Follow on patches would be to convert all ULPs to use this API change.)

In the long run this also makes it easier to develop helper wrappers
around posting because a local_dma_lkey is now always accessible to
the core code.

>  (2) now ULD can check for IB_DEVICE_LOCAL_DMA_LKEY and use local_dma_lkey
>      in that case, or will have to perform a per-IO MR with LOCAL and
>      REMOTE flags if not

If we do the above all ULPs simply use pd->local_dma_lkey and we drop
correct uses of ib_get_dma_mr completely ?

>  (3) remove insecure remote uses of ib_get_dma_mr from ULDs
>  (4) remove ib_get_dma_mr from the public API

Sure would be nice!

> This should help to sort out the lkey side of the memory registrations,
> and isn't too hard.  For rkeys I'd love to go with something like Sagis
> proposal as a first step, and then we can see if we can refine it in
> another iteration.

Agree. I'd love to see FMR fit under that, but even if we cannot, it
is appears to be a sane way to advance indirect MR..

Jason
