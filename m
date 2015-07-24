Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53207 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbbGXQld (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jul 2015 12:41:33 -0400
Date: Fri, 24 Jul 2015 10:41:23 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH V6 1/9] RDMA/iser: Limit sg tablesize and max_sectors to
 device fastreg max depth
Message-ID: <20150724164123.GA25480@obsidianresearch.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161820.25617.63886.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150724161820.25617.63886.stgit@build2.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 24, 2015 at 11:18:21AM -0500, Steve Wise wrote:
> Currently the sg tablesize, which dictates fast register page list
> depth to use, does not take into account the limits of the rdma device.
> So adjust it once we discover the device fastreg max depth limit.  Also
> adjust the max_sectors based on the resulting sg tablesize.

Huh. How does this relate to the max_page_list_len argument:

 struct ib_mr *ib_alloc_fast_reg_mr(struct ib_pd *pd, int max_page_list_len)

Shouldn't max_fast_reg_page_list_len be checked during the above?

Ie does this still make sense:

drivers/infiniband/ulp/iser/iser_verbs.c:       desc->data_mr = ib_alloc_fast_reg_mr(pd, ISCSI_ISER_SG_TABLESIZE + 1);

?

The only ULP that checks this is SRP, so basically, all our ULPs are
probably quietly broken? cxgb3 has a limit of 10 (!?!?!!)

Jason
