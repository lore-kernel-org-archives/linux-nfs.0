Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51264 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752928AbbGXSl0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 14:41:26 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: <dledford@redhat.com>, <infinipath@intel.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int> <20150724161859.25617.17286.stgit@build2.ogc.int> <20150724164909.GB25480@obsidianresearch.com>
In-Reply-To: <20150724164909.GB25480@obsidianresearch.com>
Subject: RE: [PATCH V6 8/9] isert: Use local_dma_lkey whenever possible.
Date: Fri, 24 Jul 2015 13:41:32 -0500
Message-ID: <00cc01d0c640$5c4c3850$14e4a8f0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> Sent: Friday, July 24, 2015 11:49 AM
> To: Steve Wise
> Cc: dledford@redhat.com; infinipath@intel.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-
> rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; bfields@fieldses.org
> Subject: Re: [PATCH V6 8/9] isert: Use local_dma_lkey whenever possible.
> 
> On Fri, Jul 24, 2015 at 11:18:59AM -0500, Steve Wise wrote:
> > No need to allocate a dma_mr if the device provides a local_dma_lkey.
> 
> It is probably safe to put your series on top of mine, which
> incorporates this patch already.
> 
> https://github.com/jgunthorpe/linux/commits/remove-ib_get_dma_mr
> 
> Jason

I will rebase on this. 

 

