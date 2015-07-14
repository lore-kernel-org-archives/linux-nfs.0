Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36292 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752845AbbGNUkr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 16:40:47 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
Cc: "'Sagi Grimberg'" <sagig@dev.mellanox.co.il>,
        "'Tom Talpey'" <tom@talpey.com>,
        "'Doug Ledford'" <dledford@redhat.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <trond.myklebust@primarydata.com>, <bfields@fieldses.org>,
        "'Oren Duer'" <oren@mellanox.com>
References: <559EF332.7060103@redhat.com> <20150709225306.GA30741@obsidianresearch.com> <559FC710.1050307@talpey.com> <20150710161108.GA19042@obsidianresearch.com> <CCB6E837-88FF-4DBB-976D-4CF56396A1A1@ogc.us> <55A24571.60902@dev.mellanox.co.il> <00e201d0be6a$e49bc910$add35b30$@opengridcomputing.com> <20150714192941.GA26292@obsidianresearch.com> <00e401d0be6b$d3952750$7abf75f0$@opengridcomputing.com> <20150714195511.GB7716@infradead.org> <20150714202943.GB26927@obsidianresearch.com>
In-Reply-To: <20150714202943.GB26927@obsidianresearch.com>
Subject: RE: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
Date: Tue, 14 Jul 2015 15:40:49 -0500
Message-ID: <010a01d0be75$5e60d600$1b228200$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-rdma-owner@vger.kernel.org [mailto:linux-rdma-owner@vger.kernel.org] On Behalf Of Jason Gunthorpe
> Sent: Tuesday, July 14, 2015 3:30 PM
> To: 'Christoph Hellwig'
> Cc: Steve Wise; 'Sagi Grimberg'; 'Steve Wise'; 'Tom Talpey'; 'Doug Ledford'; sagig@mellanox.com; ogerlitz@mellanox.com;
> roid@mellanox.com; linux-rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org;
> trond.myklebust@primarydata.com; bfields@fieldses.org; 'Oren Duer'
> Subject: Re: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
> 
> On Tue, Jul 14, 2015 at 12:55:11PM -0700, 'Christoph Hellwig' wrote:
> > On Tue, Jul 14, 2015 at 02:32:31PM -0500, Steve Wise wrote:
> > > You mean "should not", yea?
> > >
> > > Ok.  I'll check for iWARP.  But don't tell me to remove the transport-specific hacks in this series when I post it! ;)
> >
> > Just curious if there are any holes in this little scheme to deal with
> > the lkey mess:
> >
> >  (1) make sure all drivers that currently do not set
> >      IB_DEVICE_LOCAL_DMA_LKEY but which can safely use ib_get_dma_mr
> >      call it underneath at device setup time, and tear it down before
> >      removal.
> 
> Yes, I'd like this.
> 
> local_dma_lkey appears to be global, it works with any PD.
> 
> ib_get_dma_mr is tied to a PD, so it cannot replace local_dma_lkey at
> the struct device level.
> 
> ib_alloc_pd is the in-kernel entry point, the UAPI calls
> device->alloc_pd directly.. So how about the below patch as a starting
>        >point?
> 
> (Steve the goal of step #1 would be to remove ib_get_dma_mr from ULPs
>  Follow on patches would be to convert all ULPs to use this API change.)
> 
> In the long run this also makes it easier to develop helper wrappers
> around posting because a local_dma_lkey is now always accessible to
> the core code.
>

I'm not seeing the benefit of adding pd->local_dma_lkey?  pd->device->local_dma_lkey is there for core and ULP use, and we could
have old drivers that don't currently have support for local_dma_lkey allocate their own private pd/dma_mr (via their private
functions for doing this) with only LOCAL_WRITE access flags, and export that lkey as the device->local_dma_lkey.  Wouldn't that be
simpler?

 > >  (2) now ULD can check for IB_DEVICE_LOCAL_DMA_LKEY and use local_dma_lkey
> >      in that case, or will have to perform a per-IO MR with LOCAL and
> >      REMOTE flags if not
> 
> If we do the above all ULPs simply use pd->local_dma_lkey and we drop
> correct uses of ib_get_dma_mr completely ?
> 
> >  (3) remove insecure remote uses of ib_get_dma_mr from ULDs
> >  (4) remove ib_get_dma_mr from the public API
> 
> Sure would be nice!
> 
> > This should help to sort out the lkey side of the memory registrations,
> > and isn't too hard.  For rkeys I'd love to go with something like Sagis
> > proposal as a first step, and then we can see if we can refine it in
> > another iteration.
> 
> Agree. I'd love to see FMR fit under that, but even if we cannot, it
> is appears to be a sane way to advance indirect MR..
> 
> Jason
> 
> >From 5a9799bf487d822daae5a8b8f3b197f1dda1db45 Mon Sep 17 00:00:00 2001
> From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Date: Tue, 14 Jul 2015 14:27:37 -0600
> Subject: [PATCH] IB/core: Guarantee that a local_dma_lkey is available
> 
> Every single ULP requires a local_dma_lkey to do anything with
> a QP, so lets us ensure one exists for every PD created.
> 
> If the driver can supply a global local_dma_lkey then use that, otherwise
> ask the driver to create a local use all physical memory MR associated
> with the new PD.
> 
> Signed-off-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> ---
>  drivers/infiniband/core/verbs.c | 40 +++++++++++++++++++++++++++++++++++-----
>  include/rdma/ib_verbs.h         |  2 ++
>  2 files changed, 37 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
> index bac3fb406a74..1ddf06314f36 100644
> --- a/drivers/infiniband/core/verbs.c
> +++ b/drivers/infiniband/core/verbs.c
> @@ -213,24 +213,54 @@ EXPORT_SYMBOL(rdma_port_get_link_layer);
> 
>  /* Protection domains */
> 
> +/* Return a pd for in-kernel use that has a local_dma_lkey which provides
> +   local access to all physical memory. */
>  struct ib_pd *ib_alloc_pd(struct ib_device *device)
>  {
>  	struct ib_pd *pd;
> +	struct ib_device_attr devattr;
> +	int rc;
> +
> +	rc = ib_query_device(device, &devattr);
> +	if (rc)
> +		return ERR_PTR(rc);
> 
>  	pd = device->alloc_pd(device, NULL, NULL);
> +	if (IS_ERR(pd))
> +		return pd;
> +
> +	pd->device = device;
> +	pd->uobject = NULL;
> +	pd->local_mr = NULL;
> +	atomic_set(&pd->usecnt, 0);
> +
> +	if (devattr.device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY)
> +		pd->local_dma_lkey = device->local_dma_lkey;
> +	else {
> +		struct ib_mr *mr;
> +
> +		mr = ib_get_dma_mr(pd, IB_ACCESS_LOCAL_WRITE);
> +		if (IS_ERR(mr)) {
> +			ib_dealloc_pd(pd);
> +			return (struct ib_pd *)mr;
> +		}
> 
> -	if (!IS_ERR(pd)) {
> -		pd->device  = device;
> -		pd->uobject = NULL;
> -		atomic_set(&pd->usecnt, 0);
> +		pd->local_mr = mr;
> +		pd->local_dma_lkey = pd->local_mr->lkey;
>  	}
> -
>  	return pd;
>  }
> +
>  EXPORT_SYMBOL(ib_alloc_pd);
> 
>  int ib_dealloc_pd(struct ib_pd *pd)
>  {
> +	if (pd->local_mr) {
> +		if (ib_dereg_mr(pd->local_mr))
> +			return -EBUSY;
> +		pd->local_mr = NULL;
> +	}
> +
>  	if (atomic_read(&pd->usecnt))
>  		return -EBUSY;
> 
> diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
> index 986fddb08579..cfda95d7b067 100644
> --- a/include/rdma/ib_verbs.h
> +++ b/include/rdma/ib_verbs.h
> @@ -1255,6 +1255,8 @@ struct ib_pd {
>  	struct ib_device       *device;
>  	struct ib_uobject      *uobject;
>  	atomic_t          	usecnt; /* count all resources */
> +	struct ib_mr	       *local_mr;
> +	u32			local_dma_lkey;
>  };
> 
>  struct ib_xrcd {
> --
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

