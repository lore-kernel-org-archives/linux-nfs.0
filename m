Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:52797 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757947AbbGGVgn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Jul 2015 17:36:43 -0400
Date: Tue, 7 Jul 2015 15:36:28 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150707213628.GA5661@obsidianresearch.com>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
 <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559BFE03.4020709@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 07, 2015 at 07:27:47PM +0300, Sagi Grimberg wrote:

> Doesn't it look odd to you?

Sure, but the oddness is that rdma_device_access_flags exists at all,
not the wrapper. The wrapper is what we want the API to look like,
if we could trivially change the WR format as well then
rdma_device_access_flags wouldn't even exist at all.

> >I expect well need to keep the driver entry point for user space, but
> >we should be able to hide the API and flags from other modules.
> 
> dma_mr for user-space?? How can this be relevant for user-space?

I didn't mean dma_mr specifically, but all the other driver entry
points that use the old-style IBV_ACCESS_* flags.

Jason
