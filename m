Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36333 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbcDKUKK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2016 16:10:10 -0400
Subject: [PATCH v1 00/18] NFS/RDMA client patches for 4.7
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 11 Apr 2016 16:10:06 -0400
Message-ID: <20160411200323.20531.8893.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One larger change: Attempt to fence memory regions after a signal
interrupts a synchronous RPC. This should prevent a server from
writing a reply into a client's memory after the memory has been
released.

In addition, the following changes and fixes:

- Use new ib_drain_qp() API
- Advertise max size of NFSv4.1 callbacks on RPC/RDMA
- Prevent overflowing the server's receive buffers
- Read list + Reply chunk (to support krb5i and krbp on RPC/RDMA)
- Detect connection loss sooner

---

Chuck Lever (18):
      sunrpc: Advertise maximum backchannel payload size
      xprtrdma: Bound the inline threshold values
      xprtrdma: Limit number of RDMA segments in RPC-over-RDMA headers
      xprtrdma: Prevent inline overflow
      xprtrdma: Avoid using Write list for small NFS READ requests
      xprtrdma: Update comments in rpcrdma_marshal_req()
      xprtrdma: Allow Read list and Reply chunk simultaneously
      xprtrdma: Remove rpcrdma_create_chunks()
      xprtrdma: Use core ib_drain_qp() API
      xprtrdma: Rename rpcrdma_frwr::sg and sg_nents
      xprtrdma: Save I/O direction in struct rpcrdma_frwr
      xprtrdma: Reset MRs in frwr_op_unmap_sync()
      xprtrdma: Refactor the FRWR recovery worker
      xprtrdma: Move fr_xprt and fr_worker to struct rpcrdma_mw
      xprtrdma: Refactor __fmr_dma_unmap()
      xprtrdma: Add ro_unmap_safe memreg method
      xprtrdma: Remove ro_unmap() from all registration modes
      xprtrdma: Faster server reboot recovery


 fs/nfs/nfs4proc.c                  |   10 -
 include/linux/sunrpc/clnt.h        |    1 
 include/linux/sunrpc/xprt.h        |    1 
 include/linux/sunrpc/xprtrdma.h    |    4 
 net/sunrpc/clnt.c                  |   17 +
 net/sunrpc/xprtrdma/backchannel.c  |   16 +
 net/sunrpc/xprtrdma/fmr_ops.c      |  134 +++++++--
 net/sunrpc/xprtrdma/frwr_ops.c     |  214 ++++++++-------
 net/sunrpc/xprtrdma/physical_ops.c |   39 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c     |  517 ++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c    |   16 +
 net/sunrpc/xprtrdma/verbs.c        |   91 ++----
 net/sunrpc/xprtrdma/xprt_rdma.h    |   42 ++-
 net/sunrpc/xprtsock.c              |    6 
 14 files changed, 674 insertions(+), 434 deletions(-)

--
Chuck Lever
