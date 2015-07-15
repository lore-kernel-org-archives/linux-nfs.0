Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53004 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbbGOTNH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jul 2015 15:13:07 -0400
Date: Wed, 15 Jul 2015 13:12:57 -0600
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
Message-ID: <20150715191257.GF23588@obsidianresearch.com>
References: <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
 <20150714202943.GB26927@obsidianresearch.com>
 <20150715065057.GA22113@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150715065057.GA22113@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 11:50:57PM -0700, 'Christoph Hellwig' wrote:
> On Tue, Jul 14, 2015 at 02:29:43PM -0600, Jason Gunthorpe wrote:
> > local_dma_lkey appears to be global, it works with any PD.
> > 
> > ib_get_dma_mr is tied to a PD, so it cannot replace local_dma_lkey at
> > the struct device level.
> > 
> > ib_alloc_pd is the in-kernel entry point, the UAPI calls
> > device->alloc_pd directly.. So how about the below patch as a starting
> > point?
> 
> This looks perfect to me.  After this we can get rid of the
> ib_get_dma_mr calls outside of ib_alloc_pd, and eventuall move
> setting up ->local_dma_lkey into the HW driver and kill of
> ib_get_dma_mr, IB_DEVICE_LOCAL_DMA_LKEY and device->local_dma_lkey.

Just for clarity, again, we can never do this.

device->local_dma_lkey requires dedicated hardware support. We cannot
create it in software on old hardware. The only option I see is the
different-for-every-PD solution in my patch.

> (especially together with patches removing all other callsites of
> "ib_get_dma_mr(pd, IB_ACCESS_LOCAL_WRITE)".

I might find time to type this in, but I won't be able to find time to
do any testing on the ULPs..

Jason
