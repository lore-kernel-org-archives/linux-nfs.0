Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57338 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752414AbdIES7W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Sep 2017 14:59:22 -0400
Date: Tue, 5 Sep 2017 14:59:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Final NFS/RDMA server patches proposed for v4.14
Message-ID: <20170905185921.GB7557@fieldses.org>
References: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.14.

--b.

On Mon, Aug 28, 2017 at 03:05:57PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> These patches allow svcrdma to adjust more precisely to the limits
> of the underlying RDMA device on the server.
> 
> These have been floating around for several months, and were posted
> a few weeks ago for review on linux-rdma. They should be ready for
> you to take for v4.14.
> 
> These are the final server-side patches I have for for v4.14 cycle.
> 
> 
> ---
> 
> Chuck Lever (3):
>       svcrdma: Limit RQ depth
>       rdma core: Add rdma_rw_mr_payload()
>       svcrdma: Estimate Send Queue depth properly
> 
> 
>  drivers/infiniband/core/rw.c             |   24 ++++++++++++++++++++
>  include/rdma/rw.h                        |    2 ++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   36 +++++++++++++++++++++---------
>  3 files changed, 51 insertions(+), 11 deletions(-)
> 
> --
> Chuck Lever
