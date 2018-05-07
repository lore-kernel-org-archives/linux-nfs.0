Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:33225 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752631AbeEGT0w (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:26:52 -0400
Subject: [PATCH v1 00/19] NFS/RDMA server for-next
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:26:49 -0400
Message-ID: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here are all the patches I'd like to see merged into the next kernel
(v4.18 or v5.0) if possible. The main changes are:

 - Added trace points to svcrdma
 - Post Recv WRs in Receive completion handler
 - Handle Send WRs with fewer page allocations
 - Lots of clean up that results from these changes

The svc_rdma_recv_ctxt and svc_rdma_send_ctxt changes improve the
efficiency of the transport receive and send paths by reducing
memory allocation and DMA mapping activity per RPC. Posting Recv
WRs in the Receive completion handler means the Receive Queue
does not bounce among all the CPUs.

---

Chuck Lever (19):
      svcrdma: Add proper SPDX tags for NetApp-contributed source
      svcrdma: Use passed-in net namespace when creating RDMA listener
      xprtrdma: Prepare RPC/RDMA includes for server-side trace points
      svcrdma: Trace key RPC/RDMA protocol events
      svcrdma: Trace key RDMA API events
      svcrdma: Introduce svc_rdma_recv_ctxt
      svcrdma: Remove sc_rq_depth
      svcrdma: Simplify svc_rdma_recv_ctxt_put
      svcrdma: Preserve Receive buffer until svc_rdma_sendto
      svcrdma: Persistently allocate and DMA-map Receive buffers
      svcrdma: Allocate recv_ctxt's on CPU handling Receives
      svcrdma: Refactor svc_rdma_dma_map_buf
      svcrdma: Clean up Send SGE accounting
      svcrdma: Introduce svc_rdma_send_ctxt
      svcrdma: Don't overrun the SGE array in svc_rdma_send_ctxt
      svcrdma: Remove post_send_wr
      svcrdma: Simplify svc_rdma_send()
      svcrdma: Persistently allocate and DMA-map Send buffers
      svcrdma: Remove unused svc_rdma_op_ctxt


 include/linux/sunrpc/svc_rdma.h            |   95 ++---
 include/trace/events/rpcrdma.h             |  584 ++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c          |    2 
 net/sunrpc/xprtrdma/fmr_ops.c              |    3 
 net/sunrpc/xprtrdma/frwr_ops.c             |    2 
 net/sunrpc/xprtrdma/module.c               |    4 
 net/sunrpc/xprtrdma/rpc_rdma.c             |    7 
 net/sunrpc/xprtrdma/svc_rdma.c             |    3 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   54 +--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |  439 +++++++++++++++------
 net/sunrpc/xprtrdma/svc_rdma_rw.c          |  133 +++---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  510 ++++++++++++++++--------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  484 ++++-------------------
 net/sunrpc/xprtrdma/transport.c            |    4 
 net/sunrpc/xprtrdma/verbs.c                |    1 
 net/sunrpc/xprtrdma/xprt_rdma.h            |    2 
 16 files changed, 1461 insertions(+), 866 deletions(-)

--
Chuck Lever
