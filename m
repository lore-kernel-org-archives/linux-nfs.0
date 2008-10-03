From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 00/12] svcrdma: Fast memory registration support
Date: Fri,  3 Oct 2008 16:33:37 -0500
Message-ID: <1223069629-5267-1-git-send-email-tom@opengridcomputing.com>
Cc: thomas.talpey@netapp.com, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:40967 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376AbYJCVdu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:33:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Bruce:

This updated patchset implements support for Fast Memory Registration
in the NFS server. The second to last patch has been updated to
provide better guidance on whether the connection is safe or
not. Basically the code gives you a qualification string instead of
expecting the administrator to know how to interpret the memory
registration strategy and transport idiosyncrasies. The documentation
has also been updated given your suggestions and the change to the
informative log message. The string is certainly informative, but may
be a little long. For this reason, there is a proc file entry to
disable it.

Fast Memory Regstration is the ability to quickly map a kernel memory
page list as a logically contiguous memory region from the perspective
of the adapter. This mapping is created and invalidated using work
requests posted on the SQ.

There are two benefits of this new memory registration strategy:

- It allows for large amounts of data to be transferred between the
  client and server with a single work request

- It improves security since the effective lifetime and scope of an
  RKEY is a single RPC and WR.

The documentation file Documentation/filesystems/nfs-rdma.txt file has
been updated with information about NFSRDMA security in general and
how it is affected by the new Fast Memory Registration capability.

This new capability is only enabled if the underlying device advertises
that it is supported. It is not necessary that both the client and
server use the same strategy, however, for Fast Memory Registration,
it improves performance.

These patches are also available here:
git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>


[PATCH 01/12] svcrdma: Add Fast Reg MR Data Types

 include/linux/sunrpc/svc_rdma.h |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

[PATCH 02/12] svcrdma: Add FRMR get/put services

 include/linux/sunrpc/svc_rdma.h          |    3 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  122 ++++++++++++++++++++++++++++-
 2 files changed, 120 insertions(+), 5 deletions(-)

[PATCH 03/12] svcrdma: Query device for Fast Reg support during connection setup

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   76 +++++++++++++++++++++++++++--
 1 files changed, 70 insertions(+), 6 deletions(-)

[PATCH 04/12] svcrdma: Add a service to register a Fast Reg MR with the device

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  118 +++++++++++++++++++++---------
 2 files changed, 84 insertions(+), 35 deletions(-)

[PATCH 05/12] svcrdma: Modify post recv path to use local dma key

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

[PATCH 06/12] svcrdma: Add support to svc_rdma_send to handle chained WR

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   29 +++++++++++++++++++++--------
 1 files changed, 21 insertions(+), 8 deletions(-)

[PATCH 07/12] svcrdma: Modify the RPC recv path to use FRMR when available

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  187 ++++++++++++++++++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    5 +-
 3 files changed, 171 insertions(+), 22 deletions(-)

[PATCH 08/12] svcrdma: Modify the RPC reply path to use FRMR when available

 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  263 +++++++++++++++++++++++++-----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +
 2 files changed, 225 insertions(+), 40 deletions(-)

[PATCH 09/12] svcrdma: Update svc_rdma_send_error to use DMA LKEY

 net/sunrpc/xprtrdma/svc_rdma_transport.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

[PATCH 10/12] svcrdma: Fix IRD/ORD polarity

 net/sunrpc/xprtrdma/svc_rdma_transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

[PATCH 11/12] svcrdma: Add a message log string to indicate if FastReg is being used

 include/linux/sunrpc/svc_rdma.h          |    1 +
 net/sunrpc/xprtrdma/svc_rdma.c           |    8 ++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   63 ++++++++++++++++++-----------
 3 files changed, 48 insertions(+), 24 deletions(-)

[PATCH 12/12] svcrdma: Documentation update for the FastReg memory model

 Documentation/filesystems/nfs-rdma.txt |  126 ++++++++++++++++++++++++++++++++
 1 files changed, 126 insertions(+), 0 deletions(-)

