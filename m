Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47264 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbGOGvH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2015 02:51:07 -0400
Date: Tue, 14 Jul 2015 23:50:57 -0700
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
Message-ID: <20150715065057.GA22113@infradead.org>
References: <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
 <20150714202943.GB26927@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150714202943.GB26927@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 02:29:43PM -0600, Jason Gunthorpe wrote:
> local_dma_lkey appears to be global, it works with any PD.
> 
> ib_get_dma_mr is tied to a PD, so it cannot replace local_dma_lkey at
> the struct device level.
> 
> ib_alloc_pd is the in-kernel entry point, the UAPI calls
> device->alloc_pd directly.. So how about the below patch as a starting
> point?

This looks perfect to me.  After this we can get rid of the
ib_get_dma_mr calls outside of ib_alloc_pd, and eventuall move
setting up ->local_dma_lkey into the HW driver and kill of
ib_get_dma_mr, IB_DEVICE_LOCAL_DMA_LKEY and device->local_dma_lkey.

> >  (2) now ULD can check for IB_DEVICE_LOCAL_DMA_LKEY and use local_dma_lkey
> >      in that case, or will have to perform a per-IO MR with LOCAL and
> >      REMOTE flags if not
> 
> If we do the above all ULPs simply use pd->local_dma_lkey and we drop
> correct uses of ib_get_dma_mr completely ?

Yes, please, although:

> >  (3) remove insecure remote uses of ib_get_dma_mr from ULDs

I kept this separate as the I suspect the "optimizations" using 
ib_get_dma_mr with remote flags will warrant a separate discussion.

> >From 5a9799bf487d822daae5a8b8f3b197f1dda1db45 Mon Sep 17 00:00:00 2001
> From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Date: Tue, 14 Jul 2015 14:27:37 -0600
> Subject: [PATCH] IB/core: Guarantee that a local_dma_lkey is available
> 
> Every single ULP requires a local_dma_lkey to do anything with
> a QP, so lets us ensure one exists for every PD created.
> 
> If the driver can supply a global local_dma_lkey then use that, otherwise
> ask the driver to create a local use all physical memory MR associated
> with the new PD.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>


Acked-by: Christoph Hellwig <hch@lst.de>

(especially together with patches removing all other callsites of
"ib_get_dma_mr(pd, IB_ACCESS_LOCAL_WRITE)".
