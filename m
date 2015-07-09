Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:52702 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622AbbGIADq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 20:03:46 -0400
Date: Wed, 8 Jul 2015 18:03:37 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150709000337.GE16812@obsidianresearch.com>
References: <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150708203205.GA21847@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 01:32:05PM -0700, 'Christoph Hellwig' wrote:
> On Wed, Jul 08, 2015 at 01:08:42PM -0600, Jason Gunthorpe wrote:
> > Then, what is left is all remote MRs and maybe it will be clearer what
> > to do about them then...
> 
> From looking at that for a while the APIs needed seem pretty simple
> to me from a consumer perspective:
>
> struct rdma_mr *rmda_alloc_mr(struct ib_pd *pd, unsigned int nr_pages);
> void rdma_free_mr(struct rdma_mr *mr);

The major trouble with that is that the new MR types work by posting
work to the send queue, that work creates the MR.

I don't know all the details of how those schemes work, but it doesn't
look like it fits into this model ?

Maybe if rdma_register_sg was the only API and it accepted a QP, under
the hood it could re-use a pooled/create a non-queued (F)MR, or issue
FRMR, or work with indirect?

It would be nice if it is that simple :)

Sagi, are FMRs, FRMRs and Indirect MRs documented any place? I can't
recall off hand if FRMR was ever published by the IBTA?

Jason
