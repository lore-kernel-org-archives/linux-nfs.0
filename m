From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 00/09] svcrdma: Fast Memory Registration Support
Date: Wed, 13 Aug 2008 11:06:29 -0500
Message-ID: <48A30685.6050301@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:53405 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751864AbYHMQGa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:06:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This patchset implements support for Fast Memory Registration in the
NFS server.  Fast Memory Regstration is the ability to quickly map a
kernel memory page list as a logically contiguous memory region from
the perspective of the adapter. This mapping is created and
invalidated using work requests posted on the SQ. This allows for
large amounts of data to transferred between the client and server
with a single work request as well as the ability to invalidate a
previously mapped memory region. For iWARP, this allows for "one-shot"
memory regions to be mapped for a single NFS-RDMA data transfer. This
improves security since a byzantine app listening on the net will have
a very short window during which the RKEY is valid.

This capability is only enabled if the underlying device advertises
that it is supported.

This patches are also available here:
git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

 include/linux/sunrpc/svc_rdma.h |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

[PATCH 02/09] svcrdma: Add FRMR get/put services

 include/linux/sunrpc/svc_rdma.h          |    3 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  125 ++++++++++++++++++++++++++++-
 2 files changed, 123 insertions(+), 5 deletions(-)

[PATCH 03/09] svcrdma: Query device for Fast Reg support during connection setup

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   86 +++++++++++++++++++++++++++--
 1 files changed, 80 insertions(+), 6 deletions(-)

[PATCH 04/09] svcrdma: Add a service to register a Fast Reg MR with the device

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   53 ++++++++++++++++++++++++++---
 2 files changed, 48 insertions(+), 6 deletions(-)

[PATCH 05/09] svcrdma: Modify post recv path to use local dma key

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

[PATCH 06/09] svcrdma: Add support to svc_rdma_send to handle chained WR

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

[PATCH 07/09] svcrdma: Modify the RPC recv path to use FRMR when available

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  187 ++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
 3 files changed, 171 insertions(+), 22 deletions(-)

[PATCH 08/09] svcrdma: Modify the RPC reply path to use FRMR when available

 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  263 +++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
 2 files changed, 225 insertions(+), 40 deletions(-)

[PATCH 09/09] svcrdma: Update svc_rdma_send_error to use DMA LKEY

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

