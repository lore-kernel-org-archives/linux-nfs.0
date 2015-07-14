Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36238 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753846AbbGNUKx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 16:10:53 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Christoph Hellwig'" <hch@infradead.org>
Cc: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Steve Wise'" <swise@ogc.us>, "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <20150709000337.GE16812@obsidianresearch.com> <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714192941.GA26292@obsidianresearch.com> <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com> <20150714195511.GB7716@infradead.org>
In-Reply-To: <20150714195511.GB7716@infradead.org>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 15:10:56 -0500
Message-ID: <00fe01d0be71$31792830$946b7890$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: 'Christoph Hellwig' [mailto:hch@infradead.org]
> Sent: Tuesday, July 14, 2015 2:55 PM
> To: Steve Wise
> Cc: 'Jason Gunthorpe'; 'Sagi Grimberg'; 'Steve Wise'; 'Tom Talpey'; 'Doug Ledford'; 'Christoph Hellwig'; sagig@mellanox.com;
> ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-
> nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> On Tue, Jul 14, 2015 at 02:32:31PM -0500, Steve Wise wrote:
> > You mean "should not", yea?
> >
> > Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)
> 
> Just curious if there are any holes in this little scheme to deal with
> the lkey mess:
> 
>  (1) make sure all drivers that currently do not set
>      IB_DEVICE_LOCAL_DMA_LKEY but which can safely use ib_get_dma_mr
>      call it underneath at device setup time, and tear it down before
>      removal.
>  (2) now ULD can check for IB_DEVICE_LOCAL_DMA_LKEY and use local_dma_lkey
>      in that case, or will have to perform a per-IO MR with LOCAL and
>      REMOTE flags if not
>  (3) remove insecure remote uses of ib_get_dma_mr from ULDs
>  (4) remove ib_get_dma_mr from the public API
> 

Perhaps I missed some of the discussion on all this, but what is the point of #1?

Are these 4 steps intended to be (bisectable) steps / commits with the goal of removing ib_get_dma_mr()?  If so I still don't get
#1.

Steve.

