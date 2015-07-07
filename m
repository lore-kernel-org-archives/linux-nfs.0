Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:34155 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757960AbbGGQSO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jul 2015 12:18:14 -0400
Date: Tue, 7 Jul 2015 10:17:51 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150707161751.GA623@obsidianresearch.com>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 07, 2015 at 09:05:15AM -0500, Steve Wise wrote:

> I took the feedback from Christoph and Jason to mean I should remove
> ib_get_dma_mr() entirely and pull its guts into rdma_get_dma_mr(),
> and change all the users of ib_get_dma_mr() to use
> rdma_get_dma_mr().  So the net result isn't a wrapper.  It would of
> course still use rdma_device_access_flags()...

Right, to the greatest extent possible.

Keeping ib_get_dma_mr and the old flags around just means someone
could go back and use the old flags.

I expect well need to keep the driver entry point for user space, but
we should be able to hide the API and flags from other modules.

A wrapper is a reasonable way to stage through that transition..

Jason
