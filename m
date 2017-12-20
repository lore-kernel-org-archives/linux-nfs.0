Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:44273 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755607AbdLTVaR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 16:30:17 -0500
Subject: [PATCH v1 00/12] Add static trace points to xprtrdma
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 20 Dec 2017 16:30:15 -0500
Message-ID: <20171220210236.29321.59307.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

For v4.16, please consider this series, which adds a variety of
static trace points to the RPC-over-RDMA client implementation.

One short series of patches for v4.16 remains after this one.

---

Chuck Lever (12):
      rdma/ib: Add trace point macros to display human-readable values
      rpcrdma: infrastructure for static trace points in rpcrdma.ko
      xprtrdma: Add trace points in RPC Call transmit paths
      xprtrdma: Add trace points in the RPC Reply handler paths
      xprtrdma: Add trace points to instrument memory registration
      xprtrdma: Add trace points in reply decoder path
      xprtrdma: Add trace points to instrument memory invalidation
      xprtrdma: Add trace points to instrument MR allocation and recovery
      xprtrdma: Add trace points for connect events
      xprtrdma: Add trace points in the client-side backchannel code paths
      xprtrdma: Add trace points to instrument QP and CQ access upcalls
      xprtrdma: Instrument allocation/release of rpcrdma_req/rep objects


 include/trace/events/rdma.h       |  128 +++++
 include/trace/events/rpcrdma.h    |  889 +++++++++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c |    8 
 net/sunrpc/xprtrdma/fmr_ops.c     |    4 
 net/sunrpc/xprtrdma/frwr_ops.c    |   38 +-
 net/sunrpc/xprtrdma/module.c      |   12 
 net/sunrpc/xprtrdma/rpc_rdma.c    |   72 +--
 net/sunrpc/xprtrdma/transport.c   |   24 -
 net/sunrpc/xprtrdma/verbs.c       |   70 +--
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 
 10 files changed, 1107 insertions(+), 142 deletions(-)
 create mode 100644 include/trace/events/rdma.h
 create mode 100644 include/trace/events/rpcrdma.h

--
Chuck Lever
