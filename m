Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36035 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752773AbbFDU4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 16:56:47 -0400
Date: Thu, 4 Jun 2015 16:56:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/7] NFS/RDMA server patches for 4.2
Message-ID: <20150604205644.GG5209@fieldses.org>
References: <20150604151716.7835.65047.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150604151716.7835.65047.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 04, 2015 at 11:20:25AM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> This is a simple update of last week's v2, just to keep up to date
> with review comments. You can find these in my git repo in the
> "nfsd-rdma-for-4.2" topic branch. See:

Thanks, applying for 4.2 pending some testing.

--b.

> 
>  git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> 
> Changes since v2:
> - Rebased on v4.1-rc6
> - Dropped 2/10, 8/10, and 9/10, as discussed
> 
> 
> Changes since v1:
> - Rebased on v4.1-rc5
> - Add patch to merge xprtrdma.ko and svcrdma.ko into one module
> 
> ---
> 
> Chuck Lever (7):
>       rpcrdma: Merge svcrdma and xprtrdma modules into one
>       svcrdma: Add a separate "max data segs macro for svcrdma
>       svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
>       svcrdma: Keep rpcrdma_msg fields in network byte-order
>       svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
>       SUNRPC: Move EXPORT_SYMBOL for svc_process
>       svcrdma: Fix byte-swapping in svc_rdma_sendto.c
> 
> 
>  include/linux/sunrpc/svc_rdma.h          |   11 ++
>  net/sunrpc/Kconfig                       |   28 ++----
>  net/sunrpc/Makefile                      |    3 -
>  net/sunrpc/svc.c                         |    2 
>  net/sunrpc/xprtrdma/Makefile             |   14 +--
>  net/sunrpc/xprtrdma/module.c             |   46 ++++++++++
>  net/sunrpc/xprtrdma/svc_rdma.c           |    8 --
>  net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  140 ++++++++----------------------
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   16 ++-
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   36 ++------
>  net/sunrpc/xprtrdma/transport.c          |   13 ---
>  net/sunrpc/xprtrdma/xprt_rdma.h          |   11 +-
>  13 files changed, 135 insertions(+), 195 deletions(-)
>  create mode 100644 net/sunrpc/xprtrdma/module.c
> 
> -- 
> Chuck Lever
