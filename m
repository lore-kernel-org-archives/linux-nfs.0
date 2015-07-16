Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52225 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147AbbGPIEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2015 04:04:07 -0400
Date: Thu, 16 Jul 2015 01:04:02 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Steve Wise <swise@opengridcomputing.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150716080402.GC9093@infradead.org>
References: <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
 <20150714202943.GB26927@obsidianresearch.com>
 <20150715065057.GA22113@infradead.org>
 <20150715191257.GF23588@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150715191257.GF23588@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 15, 2015 at 01:12:57PM -0600, Jason Gunthorpe wrote:
> > This looks perfect to me.  After this we can get rid of the
> > ib_get_dma_mr calls outside of ib_alloc_pd, and eventuall move
> > setting up ->local_dma_lkey into the HW driver and kill of
> > ib_get_dma_mr, IB_DEVICE_LOCAL_DMA_LKEY and device->local_dma_lkey.
> 
> Just for clarity, again, we can never do this.
> 
> device->local_dma_lkey requires dedicated hardware support. We cannot
> create it in software on old hardware. The only option I see is the
> different-for-every-PD solution in my patch.

I don't see how my sentence above contradicts this.

One we use pd->local_dma_lkey everywhere, we can kill of
device->local_dma_lkey as an API - drivers either stick it straight
into pd->local_dma_lkey or do the internal equivalent of ib_get_dma_mr.
