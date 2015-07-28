Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60420 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932340AbbG1NmY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jul 2015 09:42:24 -0400
Date: Tue, 28 Jul 2015 09:42:23 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RESEND 0/4] Use max_sge_rd device capability
Message-ID: <20150728134223.GC20951@fieldses.org>
References: <20150727230906.10102.88491.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150727230906.10102.88491.stgit@build2.ogc.int>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 27, 2015 at 06:09:55PM -0500, Steve Wise wrote:
> Resending because I forgot to cc linux-rdma :(
> 
> Some devices were not setting this capability, so fix those devices,
> and svcrdma to use max_sge_rd.  Also remove rdma_cap_read_multi_sge()
> since it isn't needed.
> 
> These patches were originally part of:
> 
> http://www.spinics.net/lists/linux-rdma/msg27436.html
> 
> They really aren't part of iSER/iWARP at all, so I've split 
> them out.  
> 
> Bruce: This hits svcrdma, but I suggest they get merged via Doug's tree
> to avoid any merge problems.

Sounds fine.  I've got some changes to those files in my for-next as
well, but they don't appear to conflict.

Feel free to add my

	Acked-by: J. Bruce Fields <bfields@redhat.com>

to patch 3/4 if it helps.

--b.

> 
> ---
> 
> Sagi Grimberg (1):
>       mlx4, mlx5, mthca: Expose max_sge_rd correctly
> 
> Steve Wise (3):
>       RDMA/Core: remove rdma_cap_read_multi_sge() helper
>       svcrdma: Use max_sge_rd for destination read depths
>       ipath,qib: Expose max_sge_rd correctly
> 
> 
>  drivers/infiniband/hw/ipath/ipath_verbs.c    |    1 +
>  drivers/infiniband/hw/mlx4/main.c            |    1 +
>  drivers/infiniband/hw/mlx5/main.c            |    1 +
>  drivers/infiniband/hw/mthca/mthca_provider.c |    1 +
>  drivers/infiniband/hw/qib/qib_verbs.c        |    1 +
>  include/linux/sunrpc/svc_rdma.h              |    1 +
>  include/rdma/ib_verbs.h                      |   28 --------------------------
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c      |   12 +----------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c     |    4 ++++
>  9 files changed, 11 insertions(+), 39 deletions(-)
> 
> -- 
> 
> Steve
