Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:41093 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754596AbdLOBzz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Dec 2017 20:55:55 -0500
Subject: [PATCH v1 00/16] NFS/RDMA clean-ups and fixes
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 14 Dec 2017 20:55:53 -0500
Message-ID: <20171215015403.13776.46706.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

This is the second series of NFS/RDMA client patches for v4.16.

This is a bunch of minor fixes and clean-ups in preparation for
adding static trace points to the RPC-over-RDMA transport
implementation. Please consider these for v4.16.

---

Chuck Lever (16):
      xprtrdma: Fix buffer leak after transport set up failure
      xprtrdma: Fix backchannel allocation of extra rpcrdma_reps
      xprtrdma: Eliminate unnecessary lock cycle in xprt_rdma_send_request
      xprtrdma: Per-mode handling for Remote Invalidation
      xprtrdma: Remove ri_reminv_expected
      xprtrdma: Remove unused padding variables
      xprtrdma: Initialize the xprt address string array earlier
      xprtrdma: Remove another sockaddr_storage field (cdata::addr)
      xprtrdma: Support IPv6 in xprt_rdma_set_port
      xprtrdma: Move unmap-safe logic to rpcrdma_marshal_req
      xprtrdma: buf_free not called for CB replies
      xprtrdma: Split xprt_rdma_send_request
      xprtrdma: Don't clear RPC_BC_PA_IN_USE on pre-allocated rpc_rqst's
      xprtrdma: Replace all usage of "frmr" with "frwr"
      xprtrdma: Remove usage of "mw"
      xprtrdma: Introduce rpcrdma_mw_unmap_and_put


 include/linux/sunrpc/xprtrdma.h   |    2 
 net/sunrpc/xprtrdma/backchannel.c |   68 +++++---
 net/sunrpc/xprtrdma/fmr_ops.c     |  155 +++++++++---------
 net/sunrpc/xprtrdma/frwr_ops.c    |  317 +++++++++++++++++++------------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   98 +++++------
 net/sunrpc/xprtrdma/transport.c   |  102 +++++-------
 net/sunrpc/xprtrdma/verbs.c       |  212 ++++++++++++++-----------
 net/sunrpc/xprtrdma/xprt_rdma.h   |  112 +++++++------
 8 files changed, 552 insertions(+), 514 deletions(-)

--
Chuck Lever
