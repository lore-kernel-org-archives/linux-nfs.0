Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37463 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbbGNU7g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 16:59:36 -0400
Date: Tue, 14 Jul 2015 14:59:25 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714205925.GA21390@obsidianresearch.com>
References: <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
 <20150714195511.GB7716@infradead.org>
 <20150714202943.GB26927@obsidianresearch.com>
 <010a01d0be75$5e60d600$1b228200$@opengridcomputing.com>
 <20150714204442.GD26927@obsidianresearch.com>
 <010e01d0be77$3ec99b90$bc5cd2b0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <010e01d0be77$3ec99b90$bc5cd2b0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 03:54:15PM -0500, Steve Wise wrote:
> > > I'm not seeing the benefit of adding pd->local_dma_lkey?
> > > pd->device->local_dma_lkey is there for core and ULP use, and we
> > > could have old drivers that don't currently have support for
> > > local_dma_lkey allocate their own private pd/dma_mr (via their
> > > private functions for doing this) with only LOCAL_WRITE access
> > > flags, and export that lkey as the device->local_dma_lkey.  Wouldn't
> > > that be simpler?
> > 
> > It would be, but AFAIK that can't work?
> > 
> > My understanding is if you create a QP against a PD then only lkeys
> > and rkeys (and local_dma_rkey) created against that PD are valid for
> > use with that QP.
> > 
> > I can't use an lkey from a PD not associated with the QP.
> > 
> > Am I wrong on this?
> 
> Kernel users can use the local_dma_lkey for all lkey IO on all QPs
> (ignoring the iwarp read issue).  Look at sc_dma_lkey in the NFSRDMA
> server.

Read the exchange again?

You asked this:

> > > could have old drivers that don't currently have support for
> > > local_dma_lkey allocate their own private pd/dma_mr (via their

The answer to why that doesn't work is: In the generic case of old
drivers every PD has a different local_dma_lkey value.

Jason
