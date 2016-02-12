Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35077 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbcBLVFz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Feb 2016 16:05:55 -0500
Subject: [PATCH v1 0/8] NFS/RDMA client patches for v4.6
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 12 Feb 2016 16:05:53 -0500
Message-ID: <20160212205107.5278.55938.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There continues to be some fallout from enabling NFSv4.1/RDMA, and
from converting the reply handler to use a work queue.  This series
includes some bug fixes for those issues.

Logic to handle the RPC-over-RDMA RDMA_ERROR message type is also
introduced into the RPC reply handler.

Also included is a patch set to convert xprtrdma to use the new core
CQ API.

Available in the "nfs-rdma-for-4.6" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.6


Chuck Lever (8):
      xprtrdma: Segment head and tail XDR buffers on page boundaries
      xprtrdma: Invalidate memory when a signal is caught
      rpcrdma: Add RPCRDMA_HDRLEN_ERR
      xprtrdma: Properly handle RDMA_ERROR replies
      xprtrdma: Serialize credit accounting again
      xprtrdma: Use new CQ API for RPC-over-RDMA client receive CQs
      xprtrdma: Use an anonymous union in struct rpcrdma_mw
      xprtrdma: Use new CQ API for RPC-over-RDMA client send CQs


 include/linux/sunrpc/rpc_rdma.h |   12 +-
 net/sunrpc/xprtrdma/fmr_ops.c   |   28 +++---
 net/sunrpc/xprtrdma/frwr_ops.c  |  137 ++++++++++++++++++---------
 net/sunrpc/xprtrdma/rpc_rdma.c  |   89 +++++++++++++-----
 net/sunrpc/xprtrdma/transport.c |   41 +++++++-
 net/sunrpc/xprtrdma/verbs.c     |  198 ++++++++++++---------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   15 +--
 7 files changed, 279 insertions(+), 241 deletions(-)

--
Chuck Lever
