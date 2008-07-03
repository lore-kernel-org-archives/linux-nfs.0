From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/11] svcrdma: WR context management bug fixes and
	cleanup
Date: Thu, 3 Jul 2008 16:27:55 -0400
Message-ID: <20080703202755.GD30918@fieldses.org>
References: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752207AbYGCU15 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2008 16:27:57 -0400
In-Reply-To: <1215052063-7330-1-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 02, 2008 at 09:27:32PM -0500, Tom Tucker wrote:
> Bruce:
> 
> This is version 2 of the WR context cleanup patchset. It includes modifications
> per your review. It has been tested with iozone and Connectathon over IB
> and iWARP on x86_64. The x86_32 platform has only been compile tested for 
> warnings.
> 
> This set of patches fixes bugs related to DMA mapping and unmapping and
> in the process redesigns and cleans up the way that WR contexts are managed.
> 
> In addition to the bug fixes, there are three major changes:
> 
> - The data structure that maps client side memory to server side
>   memory has been separated from the WR context. This makes for cleaner
>   type checking and a smaller memory footprint for the RDMA transport.
> 
> - The mapping and unmapping of DMA is performed independently from the
>   allocation and deallocation of the WR context. This is to allow the
>   unmapping to occur early on recv where the unmapping of the DMA needs
>   to be done prior to looking at the data and therefore before 
>   deallocating the WR context.
> 
> - The WR context cache now uses a kmem_cache and is shared across
>   all transport instances. This allows contexts to be shared between
>   mounts and idle mounts don't consume context memory.
> 
> This patchset is intended for 2.6.27 and is based on 2.6.26-rc8. These patches
> are also available at the following git url:
> 
> git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git

Thanks!--I've merged this and pushed out the result to

	git://linux-nfs.org/~bfields/linux.git for-2.6.27

--b.

> 
> [PATCH 01/11] svcrdma: Add a type for keeping NFS RPC mapping
> 
>  include/linux/sunrpc/svc_rdma.h          |   27 +++++++++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma.c           |   19 +++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   26 ++++++++++++++++++++++++++
>  3 files changed, 72 insertions(+), 0 deletions(-)
> 
> [PATCH 02/11] svcrdma: Use RPC reply map for RDMA_WRITE processing
> 
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  163 ++++++++++++++----------------
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
>  2 files changed, 80 insertions(+), 88 deletions(-)
> 
> [PATCH 03/11] svcrdma: Use reply and chunk map for RDMA_READ processing
> 
>  include/linux/sunrpc/svc_rdma.h         |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   83 ++++++++++++++-----------------
>  2 files changed, 39 insertions(+), 45 deletions(-)
> 
> [PATCH 04/11] svcrdma: Move the DMA unmap logic to the CQ handler
> 
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   20 ++++++++++++++------
>  1 files changed, 14 insertions(+), 6 deletions(-)
> 
> [PATCH 05/11] svcrdma: Add dma map count and WARN_ON
> 
>  include/linux/sunrpc/svc_rdma.h          |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    1 +
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    3 +++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +++++
>  4 files changed, 10 insertions(+), 0 deletions(-)
> 
> [PATCH 06/11] svcrdma: Remove unneeded spin locks from __svc_rdma_free
> 
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ----
>  1 files changed, 0 insertions(+), 4 deletions(-)
> 
> [PATCH 07/11] svcrdma: Remove unused wait q from svcrdma_xprt structure
> 
>  include/linux/sunrpc/svc_rdma.h |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> [PATCH 08/11] svcrdma: Limit ORD based on client's advertised IRD
> 
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |   16 ++++++++++++----
>  1 files changed, 12 insertions(+), 4 deletions(-)
> 
> [PATCH 09/11] svcrdma: Add flush_scheduled_work to module exit function
> 
>  net/sunrpc/xprtrdma/svc_rdma.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> [PATCH 10/11] svcrdma: Create a kmem cache for the WR contexts
> 
>  net/sunrpc/xprtrdma/svc_rdma.c |   23 +++++++++++++++++++----
>  1 files changed, 19 insertions(+), 4 deletions(-)
> 
> [PATCH 11/11] svcrdma: Change WR context get/put to use the kmem cache
> 
>  include/linux/sunrpc/svc_rdma.h          |    6 --
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  121 +++---------------------------
>  2 files changed, 12 insertions(+), 115 deletions(-)
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
