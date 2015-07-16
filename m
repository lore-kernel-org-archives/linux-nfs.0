Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:38599 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754001AbbGPGmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2015 02:42:08 -0400
Date: Thu, 16 Jul 2015 00:41:41 -0600
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
Message-ID: <20150716064141.GA29049@obsidianresearch.com>
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

> I might find time to type this in, but I won't be able to find time to
> do any testing on the ULPs..

Here is the typing, I'll look more carefully at it later and send it
via email:

https://github.com/jgunthorpe/linux/commits/remove-ib_get_dma_mr

Jason Gunthorpe (9):
      IB/core: Guarantee that a local_dma_lkey is available
      IB/mad: Remove ib_get_dma_mr calls
      IB/ipoib: Remove ib_get_dma_mr calls
      IB/mlx4: Remove ib_get_dma_mr calls
      IB/mlx5: Remove ib_get_dma_mr calls
      iser-target: Remove ib_get_dma_mr calls
      ib_srpt: Remove ib_get_dma_mr calls
      net/9p: Remove ib_get_dma_mr calls
      rds/ib: Remove ib_get_dma_mr calls

The remaining calls are more complex as they are opening remote
writable physical windows.

Jason
