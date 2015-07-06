Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43860 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbbGFFZR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 01:25:17 -0400
Date: Sun, 5 Jul 2015 22:25:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Message-ID: <20150706052515.GA1109@infradead.org>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
 <20150705232158.12029.25472.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150705232158.12029.25472.stgit@build2.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 05, 2015 at 06:22:00PM -0500, Steve Wise wrote:
> The semantics for MR access flags are not consistent across RDMA
> protocols.  So rather than have applications try and glean what they
> need, have them pass in the intended roles and attributes for the MR to
> be allocated and let the RDMA core select the appropriate access flags
> given the roles, attributes, and device capabilities.
> 
> We introduce rdma_mr_roles and rdma_mr_attributes that enumerate the
> possible roles and attributes for a MR.  These are documented in the
> enums themselves.
> 
> New services exported:
> 
> rdma_device_access_flags() - given the intended MR roles and attributes
> passed in, return the ib_access_flags bits for the device.
> 
> rdma_get_dma_mr() - allocate a dma mr using the applications intended
> MR roles and MR attributes.  This uses rdma_device_access_flags().
> 
> rdma_fast_reg_access_flags() - return the ib_access_flags bits needed
> for a fast register WR given the applications intended MR roles and
> MR attributes.  This uses rdma_device_access_flags().
> 
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---
> 
>  drivers/infiniband/core/verbs.c |   30 +++++++++++
>  include/rdma/ib_verbs.h         |  106 +++++++++++++++++++++++++++++++++++++++
>  2 files changed, 136 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
> index bac3fb4..f42595c 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -1144,6 +1144,36 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
>  }
>  EXPORT_SYMBOL(ib_get_dma_mr);
>  
> +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
> +{
> +	int access_flags = attrs;

Please add an assert for the values that are allowed for attrs.

It also would be highly useful to add a kerneldoc comment describing
the function and the parameters.  Also __bitwise sparse tricks
to ensure the right flags are passed wouldn't be a too bad idea.

> +/**
> + * rdma_mr_attributes - attributes for rdma memory regions
> + */
> +enum {
> +	RDMA_MRA_ZERO_BASED		= IB_ZERO_BASED,
> +	RDMA_MRA_ACCESS_ON_DEMAND	= IB_ACCESS_ON_DEMAND,
> +};

Why not specfiy these as separate nuerical namespace?

> +/**
> + * rdma_device_access_flags - Returns the device-specific MR access flags.
> + * @pd: The protection domain associated with the memory region.
> + * @roles: The intended roles of the MR
> + * @attrs: The desired attributes of the MR
> + *
> + * Use the intended roles from @roles along with @attrs and the device
> + * capabilities to generate the needed access rights.
> + *
> + * Return: the ib_access_flags value needed to allocate the MR.
> + */
> +int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs);

Oh, here we have kerneldoc comments, just in the wrong place.  Please
move them to the function defintion.

