Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:38254 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752956AbdCPPw2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 11:52:28 -0400
Subject: [PATCH v1 00/14] Server-side NFS/RDMA changes for v4.12
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 16 Mar 2017 11:52:25 -0400
Message-ID: <20170316154132.4482.56769.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series overhauls the "reply send" side of the RPC-over-RDMA
transport to use the new rdma_rw API. Benefits include:

<> Better code modularity, less code duplication with other ULPs

<> Ability for svcrdma to use any registration mode for RDMA Writes

<> Correctly handles RPCs that have both a Write and a Reply chunk

<> Much better handling of Write chunk overrun


No significant performance changes noticed with this overhaul.

Additions outweigh deletions for two reasons: there are more large
block comments in the new code, and code to handle "call receive"
is also added in svc_rdma_rw.c, but not used yet.


Available in the "nfsd-rdma-for-4.12" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.12

---

Chuck Lever (14):
      svcrdma: Move send_wr to svc_rdma_op_ctxt
      svcrdma: Add svc_rdma_map_reply_hdr()
      svcrdma: Eliminate RPCRDMA_SQ_DEPTH_MULT
      svcrdma: Add helper to save pages under I/O
      svcrdma: Introduce local rdma_rw API helpers
      svcrdma: Use rdma_rw API in RPC reply path
      svcrdma: Clean up RDMA_ERROR path
      svcrdma: Report Write/Reply chunk overruns
      svcrdma: Clean up RPC-over-RDMA backchannel reply processing
      svcrdma: Reduce size of sge array in struct svc_rdma_op_ctxt
      svcrdma: Remove old RDMA Write completion handlers
      svcrdma: Remove the req_map cache
      svcrdma: Clean out old XDR encoders
      svcrdma: Clean up svc_rdma_post_recv() error handling


 include/linux/sunrpc/rpc_rdma.h            |    3 
 include/linux/sunrpc/svc_rdma.h            |   81 +--
 net/sunrpc/xprtrdma/Makefile               |    2 
 net/sunrpc/xprtrdma/svc_rdma.c             |    8 
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   74 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |  148 +++--
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   80 ++-
 net/sunrpc/xprtrdma/svc_rdma_rw.c          |  785 +++++++++++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  872 ++++++++++++----------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  176 ++----
 10 files changed, 1438 insertions(+), 791 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/svc_rdma_rw.c

--
Chuck Lever
