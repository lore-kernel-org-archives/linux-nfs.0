Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:52719 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758299AbbGHTIw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jul 2015 15:08:52 -0400
Date: Wed, 8 Jul 2015 13:08:42 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Christoph Hellwig'" <hch@infradead.org>, dledford@redhat.com,
        sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org,
        Oren Duer <oren@mellanox.com>
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150708190842.GB11740@obsidianresearch.com>
References: <559A340E.9000000@dev.mellanox.co.il>
 <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com>
 <559AAA22.1000608@dev.mellanox.co.il>
 <20150707090001.GB11736@infradead.org>
 <559B9891.8060907@dev.mellanox.co.il>
 <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
 <20150707161751.GA623@obsidianresearch.com>
 <559BFE03.4020709@dev.mellanox.co.il>
 <20150707213628.GA5661@obsidianresearch.com>
 <559CD174.4040901@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <559CD174.4040901@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 10:29:56AM +0300, Sagi Grimberg wrote:
> >Sure, but the oddness is that rdma_device_access_flags exists at all,
> >not the wrapper. The wrapper is what we want the API to look like,
> 
> I don't necessarily agree. The API we'd want is a single API at all
> the call sites to all types of MRs.

Well, I'm speaking specifically about the access protection flags
because that is all this patch set is working on.

What to do about the rest of the mess is a whole other problem,
and completely orthogonal to the access protection problem.

> We have different QP types, and still we don't have an allocation
> API for each and every one.  I honestly don't see why we have that
> for MRs.

The MR stuff was never really designed, the HW people provided some
capability and the SW side just raw exposed it, thoughtlessly.

> If we can converge to a single API for MR allocation we can just get it
> right once.

I'm not sure focusing on MR is the right layer, but who knows.

Every time I look at this, I just shake my head and go *WTF*?

Even something simple like issuing a SEND against local memory seems
horribly complicated. Why do we have local_dma_lkey and ib_get_dma_mr?

Why is code using iWarp calling ib_get_dma_mr with
RDMA_MRR_READ_DEST/IB_ACCESS_REMOTE_WRITE ? That is insecure.

Why on earth is NFS using frmr to create RDMA READ lkeys?

The flags change is easy, and makes sense, but this whole thing looks
deeply rotten.

I'd strongly suggest a MR cleanup should look first at purging lkey
completely from the in-kernel API.

I think when you do that, it quickly becomes clear that iWarp's
problem is not a seemingly minor issue with different flag bits, but
that iWarp *cannot* use local_dma_lkey as a RDMA READ local buffer.
Using ib_get_dma_mr(IB_ACCESS_REMOTE_WRITE) is an insecure work
around. So iWarp (and only iWarp) should take the pain of spinning up
temporary local MRs for RDMA READ.

This should all be hidden under a common API and it shouldn't be
sprinkled all over the place in NFS, iSER, etc.

So, I'd say, first order of buisness to fix the MR mess would be to
purge lkey from the in-kernel API and rationalize the local side to
something cleaner.

Then, what is left is all remote MRs and maybe it will be clearer what
to do about them then...

> >if we could trivially change the WR format as well then
> >rdma_device_access_flags wouldn't even exist at all.
> 
> I have taken some time to truly think about that following Christoph's
> comments to my indirect registration patches. This is one of the things
> I'm looking at.

I really hope you can come up with something here, I'm sure you can
get some help on this issue, because all the storage ULPs are
suffering together under this awful set of APIs.

Jason
