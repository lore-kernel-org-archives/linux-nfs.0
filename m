Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:53583 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757489AbbGGOFN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jul 2015 10:05:13 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Christoph Hellwig'" <hch@infradead.org>
Cc: <dledford@redhat.com>, <sagig@mellanox.com>, <ogerlitz@mellanox.com>,
        <roid@mellanox.com>, <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int> <20150705232158.12029.25472.stgit@build2.ogc.int> <559A340E.9000000@dev.mellanox.co.il> <001601d0b7f9$3e1d6d40$ba5847c0$@opengridcomputing.com> <559AAA22.1000608@dev.mellanox.co.il> <20150707090001.GB11736@infradead.org> <559B9891.8060907@dev.mellanox.co.il>
In-Reply-To: <559B9891.8060907@dev.mellanox.co.il>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 7 Jul 2015 09:05:15 -0500
Message-ID: <000b01d0b8bd$f2bfcc10$d83f6430$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Sagi Grimberg
> Sent: Tuesday, July 07, 2015 4:15 AM
> To: Christoph Hellwig
> Cc: Steve Wise; dledford@redhat.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-rdma@vger.kernel.org;
> eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; trond.myklebust@primarydata.com; bfields@fieldses.org
> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> On 7/7/2015 12:00 PM, Christoph Hellwig wrote:
> > On Mon, Jul 06, 2015 at 07:17:38PM +0300, Sagi Grimberg wrote:
> >>> Ok. I'll remove all uses of ib_get_dma_mr()...
> >>>
> >>>
> >>
> >> I meant that rdma_get_dma_mr can go away. I'd prefer to get the
> >> needed access_flags and just call existing verb.
> >
> > I strongly disagree.  As this series has shown the existing API is not
> > epressive enough for all transports.  It thus needs to go away and be
> > fully replaced by the new API introduced here.
> >
> 
> Christoph,
> 
> I wasn't arguing about having a transport independent API. I was
> referring to this wrapper specifically that trampolines to
> ib_get_dma_mr() with rdma_device_access_flags(pd, roles, attrs) helper.
> 
> The rdma_device_access_flags() itself is fine. However, given that
> this helper is used elsewhere as well, I don't see the point of having
> yet another helper specifically just for the dma_mr case that does
> nothing more than trampolines with a call to rdma_device_access_flags().
> 

I took the feedback from Christoph and Jason to mean I should remove ib_get_dma_mr() entirely and pull its guts into
rdma_get_dma_mr(), and change all the users of ib_get_dma_mr() to use rdma_get_dma_mr().  So the net result isn't a wrapper.  It
would of course still use rdma_device_access_flags()...

Steve. 


