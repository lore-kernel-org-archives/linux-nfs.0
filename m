Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41266 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbGIIA7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 04:00:59 -0400
Date: Thu, 9 Jul 2015 01:00:42 -0700
From: "'Christoph Hellwig'" <hch@infradead.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "'Christoph Hellwig'" <hch@infradead.org>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150709080042.GA27629@infradead.org>
References: <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
 <20150708190842.GB11740@obsidianresearch.com>
 <20150708203205.GA21847@infradead.org>
 <20150709000337.GE16812@obsidianresearch.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150709000337.GE16812@obsidianresearch.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 06:03:37PM -0600, Jason Gunthorpe wrote:
> The major trouble with that is that the new MR types work by posting
> work to the send queue, that work creates the MR.
> 
> I don't know all the details of how those schemes work, but it doesn't
> look like it fits into this model ?

It sorta does, but we do need a QP argument.  I have implemented this
abstraction in a driver, but it's still usign driver specific data
structures at this point, so extracting all the arguments is a bit
of a mess.  But if there is some interest I can try to polish it up
and port an existing driver or two to it.

Note that post_send isn't really used for alloating the MR structure
but performing the registration.

> Maybe if rdma_register_sg was the only API and it accepted a QP, under
> the hood it could re-use a pooled/create a non-queued (F)MR, or issue
> FRMR, or work with indirect?

I really want to avoid another allocator in my driver.  With the blk-mq
model we basically preallocate a request with all resoruces, so right
now I totally avoid allocations in I/O path, which is something I'd
like to keep if possible.
