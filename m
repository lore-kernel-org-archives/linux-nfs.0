Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34275 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbIQUoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 16:44:12 -0400
Subject: [PATCH v1 00/18] RFC NFS/RDMA patches for merging into v4.4
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 17 Sep 2015 16:44:10 -0400
Message-ID: <20150917202829.19671.90044.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series begins with the usual fixes, then introduces patches
that add support for bi-directional RPC/RDMA. Bi-directional
RPC/RDMA is a pre-requisite for NFSv4.1 on RDMA transports. It
includes both client and server side support, though the server side
is not as far along as I had hoped, and could be postponed to 4.5.

This v1 is an initial request for review, not a "these suckers are
ready to be merged."

Also available in the "nfs-rdma-for-4.4" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.4

---

Chuck Lever (18):
      xprtrdma: Enable swap-on-NFS/RDMA
      xprtrdma: Replace global lkey with lkey local to PD
      xprtrdma: Remove completion polling budgets
      xprtrdma: Refactor reply handler error handling
      xprtrdma: Replace send and receive arrays
      SUNRPC: Abstract backchannel operations
      xprtrdma: Pre-allocate backward rpc_rqst and send/receive buffers
      xprtrdma: Pre-allocate Work Requests for backchannel
      xprtrdma: Add support for sending backward direction RPC replies
      xprtrdma: Handle incoming backward direction RPC calls
      svcrdma: Add backward direction service for RPC/RDMA transport
      SUNRPC: Remove the TCP-only restriction in bc_svc_process()
      NFS: Enable client side NFSv4.1 backchannel to use other transports
      svcrdma: Define maximum number of backchannel requests
      svcrdma: Add svc_rdma_get_context() API that is allowed to fail
      svcrdma: Add infrastructure to send backwards direction RPC/RDMA calls
      svcrdma: Add infrastructure to receive backwards direction RPC/RDMA replies
      xprtrdma: Add class for RDMA backwards direction transport


 fs/nfs/callback.c                        |   33 ++-
 include/linux/sunrpc/bc_xprt.h           |    5 
 include/linux/sunrpc/svc_rdma.h          |   15 +
 include/linux/sunrpc/xprt.h              |    6 
 net/sunrpc/backchannel_rqst.c            |   24 ++
 net/sunrpc/svc.c                         |    5 
 net/sunrpc/xprt.c                        |    1 
 net/sunrpc/xprtrdma/Makefile             |    1 
 net/sunrpc/xprtrdma/backchannel.c        |  368 ++++++++++++++++++++++++++++++
 net/sunrpc/xprtrdma/fmr_ops.c            |   19 --
 net/sunrpc/xprtrdma/frwr_ops.c           |    5 
 net/sunrpc/xprtrdma/physical_ops.c       |   10 -
 net/sunrpc/xprtrdma/rpc_rdma.c           |  212 ++++++++++++++---
 net/sunrpc/xprtrdma/svc_rdma.c           |    6 
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |   60 +++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   63 +++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  104 ++++++++
 net/sunrpc/xprtrdma/transport.c          |  253 ++++++++++++++++++++-
 net/sunrpc/xprtrdma/verbs.c              |  341 ++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h          |   56 ++++-
 net/sunrpc/xprtsock.c                    |   16 +
 21 files changed, 1341 insertions(+), 262 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/backchannel.c

--
Chuck Lever
