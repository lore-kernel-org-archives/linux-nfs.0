From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Wed, 13 Aug 2008 17:19:53 -0400
Message-ID: <20080813211953.GN26765@fieldses.org>
References: <48A30685.6050301@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47584 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752480AbYHMVT7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 17:19:59 -0400
In-Reply-To: <48A30685.6050301@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 13, 2008 at 11:06:29AM -0500, Tom Tucker wrote:
>
> This patchset implements support for Fast Memory Registration in the
> NFS server.  Fast Memory Regstration is the ability to quickly map a
> kernel memory page list as a logically contiguous memory region from
> the perspective of the adapter. This mapping is created and
> invalidated using work requests posted on the SQ. This allows for
> large amounts of data to transferred between the client and server
> with a single work request as well as the ability to invalidate a
> previously mapped memory region. For iWARP, this allows for "one-shot"
> memory regions to be mapped for a single NFS-RDMA data transfer. This
> improves security since a byzantine app listening on the net will have
> a very short window during which the RKEY is valid.
>
> This capability is only enabled if the underlying device advertises
> that it is supported.

Thanks for your continuing work on this.

I think we really need to document the security assumptions, though.

(Currently is your entire memory at the mercy of anyone on the same
local network as your rdma adapter?  If so, fixing that would certainly
make this stuff useful in more situations, but language like "a very
short window" doesn't sound promising.  Also, we've got to make sure
users understand where it's safe to use this stuff....)

--b.

>
> This patches are also available here:
> git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>
> include/linux/sunrpc/svc_rdma.h |   27 ++++++++++++++++++++++++++-
> 1 files changed, 26 insertions(+), 1 deletions(-)
>
> [PATCH 02/09] svcrdma: Add FRMR get/put services
>
> include/linux/sunrpc/svc_rdma.h          |    3 +
> net/sunrpc/xprtrdma/svc_rdma_transport.c |  125 ++++++++++++++++++++++++++++-
> 2 files changed, 123 insertions(+), 5 deletions(-)
>
> [PATCH 03/09] svcrdma: Query device for Fast Reg support during connection setup
>
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   86 +++++++++++++++++++++++++++--
> 1 files changed, 80 insertions(+), 6 deletions(-)
>
> [PATCH 04/09] svcrdma: Add a service to register a Fast Reg MR with the device
>
> include/linux/sunrpc/svc_rdma.h          |    1 +
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   53 ++++++++++++++++++++++++++---
> 2 files changed, 48 insertions(+), 6 deletions(-)
>
> [PATCH 05/09] svcrdma: Modify post recv path to use local dma key
>
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +++++++---
> 1 files changed, 7 insertions(+), 3 deletions(-)
>
> [PATCH 06/09] svcrdma: Add support to svc_rdma_send to handle chained WR
>
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 +++++++++++++++++++++--------
> 1 files changed, 21 insertions(+), 8 deletions(-)
>
> [PATCH 07/09] svcrdma: Modify the RPC recv path to use FRMR when available
>
> include/linux/sunrpc/svc_rdma.h          |    1 +
> net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  187 ++++++++++++++++++++++++++----
> net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
> 3 files changed, 171 insertions(+), 22 deletions(-)
>
> [PATCH 08/09] svcrdma: Modify the RPC reply path to use FRMR when available
>
> net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  263 +++++++++++++++++++++++++-----
> net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
> 2 files changed, 225 insertions(+), 40 deletions(-)
>
> [PATCH 09/09] svcrdma: Update svc_rdma_send_error to use DMA LKEY
>
> net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
> 1 files changed, 9 insertions(+), 2 deletions(-)
>
