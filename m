Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33717 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbbGIUln (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:41:43 -0400
Subject: [PATCH v1 00/12] NFS/RDMA client side for Linux 4.3
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 09 Jul 2015 16:41:39 -0400
Message-ID: <20150709203242.26247.4848.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several important client-side performance and scalability
improvements are made in this series, proposed for the 4.3
kernel, including:

 - Increase maximum RDMA credits to 128
 - Increase maximum NFS r/wsize to one megabyte
 - Prefer inline rather than reply chunk replies

And these fixes:

 - Send NFSv4 WRITE compounds correctly
 - Support RDMA_NOMSG calls
 - Fix large NFS symlink operations
 - Get inline threshold accounting right

Also available in the "nfs-rdma-for-4.3" topic branch of this git repo:

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.3

---

Chuck Lever (12):
      xprtrdma: Make xprt_setup_rdma() agnostic to family of server address
      xprtrdma: Raise maximum payload size to one megabyte
      xprtrdma: Increase default credit limit
      xprtrdma: Remove last ib_reg_phys_mr() call site
      xprtrdma: Account for RPC/RDMA header size when deciding to inline
      xprtrdma: Always provide a write list when sending NFS READ
      xprtrdma: Don't provide a reply chunk when expecting a short reply
      xprtrdma: Fix XDR tail buffer marshalling
      xprtrdma: Prepare rpcrdma_ep_post() for RDMA_NOMSG calls
      xprtrdma: Fix large NFS SYMLINK calls
      xprtrdma: Clean up xprt_rdma_print_stats()
      xprtrdma: Count RDMA_NOMSG type calls


 fs/nfs/nfs3xdr.c                |    1 
 fs/nfs/nfs4xdr.c                |    1 
 include/linux/sunrpc/xprtrdma.h |    2 -
 net/sunrpc/xprtrdma/rpc_rdma.c  |  129 +++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/transport.c |   77 +++++++++++------------
 net/sunrpc/xprtrdma/verbs.c     |  129 ++++++++++-----------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   23 ++++---
 7 files changed, 171 insertions(+), 191 deletions(-)

--
Chuck Lever
