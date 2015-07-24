Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51390 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbbGXT5i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 15:57:38 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: <dledford@redhat.com>, <infinipath@intel.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int> <20150724161904.25617.85015.stgit@build2.ogc.int> <20150724165721.GC25480@obsidianresearch.com> <00ce01d0c641$493ea300$dbbbe900$@opengridcomputing.com> <20150724192411.GC26225@obsidianresearch.com>
In-Reply-To: <20150724192411.GC26225@obsidianresearch.com>
Subject: RE: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
Date: Fri, 24 Jul 2015 14:57:45 -0500
Message-ID: <00db01d0c64b$01f40300$05dc0900$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> Sent: Friday, July 24, 2015 2:24 PM
> To: Steve Wise
> Cc: dledford@redhat.com; infinipath@intel.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-
> rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; bfields@fieldses.org
> Subject: Re: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
> 
> On Fri, Jul 24, 2015 at 01:48:09PM -0500, Steve Wise wrote:
> > > The use of FRWR for RDMA READ should be iWarp specific, IB shouldn't
> > > pay that overhead. I am expecting to see a cap_rdma_read_rkey or
> > > something in here ?
> >
> > Ok.  But cap_rdma_read_rkey() doesn't really describe the
> > requirement.  The requirement is rkey + REMOTE_WRITE.  So it is more
> > like rdma_cap_read_requires_remote_write() which is ugly and too
> > long (but descriptive)...
> 
> I don't care much what name you pick, just jam something like this in
> the description
> 
>  If set then RDMA_READ must be performed by mapping the local
>  buffers through a rkey MR with ACCESS_REMOTE_WRITE enabled.
>  The rkey of this MR should be passed in as the sg_lists's lkey for
>  IB_WR_RDMA_READ_WITH_INV.
> 
>  FRWR should be used to register the buffer in the send queue,
>  and the read should be issued using IB_WR_RDMA_READ_WITH_INV (xx
>  can we just implicitly rely on this? Are there any iWarp cards that
>  support FRWR but not WITH_INV?)
>

No.  And iWARP devices must support READ_WITH_INV from my reading of the iWARP verbs spec.  

I will add all these comments and make use of READ_WITH_INV.

>  Finally, only a single SGE can be used with RDMA_READ, all scattering
>  must be accomplished with the MR.
> 
> This quite dramatically changes what is an allowed scatter for the
> transfer, IB can support arbitary unaligned S/G lists, while this is
> now forced into gapless page aligned elements.
> 
> Your patch takes care of this? And only impacts IB?

Did you mean "only impacts iWARP?"  

Yes the patch takes care of sg->fr page list packing. And it uses the existing isert_map_fr_pagelist() to pack the sg into the
fastreg page list.  This same routine is used by the IB FRMR/PI reg/unreg routines as well.

None of this impacts isert over IB, assuming the suggested change above to only use the new reg/unreg functions for devices that
need the iwarp style of read. IE IB devices will either use the existing FRMR/PI methods if they support FRMR/LOCAL_DMA_LKEY/PI
(mlx5) or they will use the existing DMA_MR methods (all the rest of the IB devices).  IW devices will get my new reg/unreg
methods...

Steve.



