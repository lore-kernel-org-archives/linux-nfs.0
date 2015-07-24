Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51249 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752630AbbGXSkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 14:40:11 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Jason Gunthorpe'" <jgunthorpe@obsidianresearch.com>
Cc: <dledford@redhat.com>, <infinipath@intel.com>, <sagig@mellanox.com>,
        <ogerlitz@mellanox.com>, <roid@mellanox.com>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <target-devel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
References: <20150724161331.25617.8475.stgit@build2.ogc.int> <20150724161820.25617.63886.stgit@build2.ogc.int> <20150724164123.GA25480@obsidianresearch.com>
In-Reply-To: <20150724164123.GA25480@obsidianresearch.com>
Subject: RE: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to device fastreg max depth
Date: Fri, 24 Jul 2015 13:40:17 -0500
Message-ID: <00ca01d0c640$2f813d70$8e83b850$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: Jason Gunthorpe [mailto:jgunthorpe@obsidianresearch.com]
> Sent: Friday, July 24, 2015 11:41 AM
> To: Steve Wise
> Cc: dledford@redhat.com; infinipath@intel.com; sagig@mellanox.com; ogerlitz@mellanox.com; roid@mellanox.com; linux-
> rdma@vger.kernel.org; eli@mellanox.com; target-devel@vger.kernel.org; linux-nfs@vger.kernel.org; bfields@fieldses.org
> Subject: Re: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to device fastreg max depth
> 
> On Fri, Jul 24, 2015 at 11:18:21AM -0500, Steve Wise wrote:
> > Currently the sg tablesize, which dictates fast register page list
> > depth to use, does not take into account the limits of the rdma device.
> > So adjust it once we discover the device fastreg max depth limit.  Also
> > adjust the max_sectors based on the resulting sg tablesize.
> 
> Huh. How does this relate to the max_page_list_len argument:
> 
>  struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)
> 
> Shouldn't max_fast_reg_page_list_len be checked during the above?
> 
> Ie does this still make sense:
> 
> drivers/infiniband/ulp/iser/iser_verbs.c:       desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE + 1);
> 
> ?
> 
> The only ULP that checks this is SRP, so basically, all our ULPs are
> probably quietly broken? cxgb3 has a limit of 10 (!?!?!!)
> 

Yea seems like some drivers need to enforce this in ib_alloc_fast_reg_mr() as well as ib_alloc_fast_reg_page_list(), and ULPs need
to not exceed the device max.

I will fix iser to limit the mr and page_list allocation based on the device max.

Steve.

