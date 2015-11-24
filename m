Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:55864 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221AbbKXS5R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2015 13:57:17 -0500
Date: Tue, 24 Nov 2015 11:57:07 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
Message-ID: <20151124185707.GJ10391@obsidianresearch.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221414.32702.87638.stgit@manet.1015granger.net>
 <20151124064556.GA29141@infradead.org>
 <565442F5.7080400@dev.mellanox.co.il>
 <4B2D7C66-31AC-44F3-A8CC-22CC7136015C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B2D7C66-31AC-44F3-A8CC-22CC7136015C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2015 at 09:39:33AM -0500, Chuck Lever wrote:
> >> Do we really want to go down that road?  It seems like we've decided
> >> in general that while the protocol specs say MR must be unmapped before
> >> proceeding with the data that is painful enough to ignore this
> >> requirement.  E.g. iser for example only does the local invalidate
> >> just before reusing the MR.
> 
> That leaves the MR exposed to the remote indefinitely. If
> the MR is registered for remote write, that seems hazardous.

Agree.

If we have a performance knob it should be to post the invalidate,
then immediately dma unmap and start using the buffer, not to defer
the invalidate potentially indefinitely.  Then it is just a race to be
exploited not a long lived window into random page cache memory.

Jason
