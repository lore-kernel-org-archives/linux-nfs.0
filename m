Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42744 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbbGNTzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 15:55:18 -0400
Date: Tue, 14 Jul 2015 12:55:11 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        bfields@fieldses.org, "'Oren Duer'" <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150714195511.GB7716@infradead.org>
References: <20150709000337.GE16812@obsidianresearch.com>
 <559EF332.7060103@redhat.com>
 <20150709225306.GA30741@obsidianresearch.com>
 <559FC710.1050307@talpey.com>
 <20150710161108.GA19042@obsidianresearch.com>
 <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us>
 <55A24571.60902@dev.mellanox.co.il>
 <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com>
 <20150714192941.GA26292@obsidianresearch.com>
 <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2015 at 02:32:31PM -0500, Steve Wise wrote:
> You mean "should not", yea?  
> 
> Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)

Just curious if there are any holes in this little scheme to deal with
the lkey mess:

 (1) make sure all drivers that currently do not set
     IB_DEVICE_LOCAL_DMA_LKEY but which can safely use ib_get_dma_mr
     call it underneath at device setup time, and tear it down before
     removal.
 (2) now ULD can check for IB_DEVICE_LOCAL_DMA_LKEY and use local_dma_lkey
     in that case, or will have to perform a per-IO MR with LOCAL and
     REMOTE flags if not
 (3) remove insecure remote uses of ib_get_dma_mr from ULDs
 (4) remove ib_get_dma_mr from the public API

This should help to sort out the lkey side of the memory registrations,
and isn't too hard.  For rkeys I'd love to go with something like Sagis
proposal as a first step, and then we can see if we can refine it in
another iteration.

Given that we might not be able to do the above for the next merge
window add your iWarp transport heck for now, at least we'll have a
clear plan to remove it.
