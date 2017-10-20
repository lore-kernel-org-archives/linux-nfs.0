Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:44326 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdJTOrd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2017 10:47:33 -0400
Subject: [PATCH 0/9] More NFS/RDMA client patches for v4.15
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 20 Oct 2017 10:47:31 -0400
Message-ID: <20171020143635.14869.15714.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Here's my third set of NFS/RDMA client patches for v4.15. There is
one small set remaining after this one, which I can send once this
one is accepted.

This set implements strong Send Queue accounting, replacing the
current system which has been in place since the beginning with a
more reliable system that completely prevents the exposure of RPC
buffer contents after RPC completion (for example, when a Send
retransmit is necessary).

Please consider this set for v4.15.

---

Chuck Lever (9):
      xprtrdma: Clean up SGE accounting in rpcrdma_prepare_msg_sges()
      xprtrdma: Fix error handling in rpcrdma_prepare_msg_sges()
      xprtrdma: Change return value of rpcrdma_prepare_send_sges()
      xprtrdma: "Unoptimize" rpcrdma_prepare_hdr_sge()
      xprtrdma: Add data structure to manage RDMA Send arguments
      xprtrdma: Add a field of bit flags to struct rpcrdma_req
      xprtrdma: Refactor rpcrdma_deferred_completion
      xprtrdma: RPC completion should wait for Send completion
      xprtrdma: Remove atomic send completion counting


 net/sunrpc/xprtrdma/backchannel.c |    6 +
 net/sunrpc/xprtrdma/frwr_ops.c    |    8 -
 net/sunrpc/xprtrdma/rpc_rdma.c    |  178 ++++++++++++++++++++++-----------
 net/sunrpc/xprtrdma/transport.c   |   15 +--
 net/sunrpc/xprtrdma/verbs.c       |  201 +++++++++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/xprt_rdma.h   |   79 +++++++++------
 6 files changed, 367 insertions(+), 120 deletions(-)

--
Chuck Lever
