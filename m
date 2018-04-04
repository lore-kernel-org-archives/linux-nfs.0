Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:40876 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbeDDV6Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Apr 2018 17:58:24 -0400
Subject: [PATCH v2 00/16] Series short description
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 04 Apr 2018 17:58:21 -0400
Message-ID: <20180404215246.8317.20479.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series implements...

---

Chuck Lever (16):
      xprtrdma: Fix latency regression on NUMA NFS/RDMA clients
      xprtrdma: Remove arbitrary limit on initiator depth
      xprtrdma: Remove xprt-specific connect cookie
      xprtrdma: ->send_request returns -EAGAIN when there are no free MRs
      xprtrdma: Reduce number of MRs created by rpcrdma_mrs_create
      xprtrdma: "Support" call-only RPCs
      xprtrdma: Chain Send to FastReg WRs
      xprtrdma: Move creation of rl_rdmabuf to rpcrdma_create_req
      SUNRPC: Move xprt_update_rtt callsite
      SUNRPC: Make RTT measurement more precise (Receive)
      SUNRPC: Make RTT measurement more precise (Send)
      SUNRPC: Make num_reqs a non-atomic integer
      sunrpc: Simplify synopsis of some trace points
      sunrpc: Add static trace point to report RPC latency stats
      sunrpc: Add static trace point to report result of RPC ping
      xprtrdma: Fix corner cases when handling device removal


 include/linux/sunrpc/clnt.h       |    7 ++
 include/linux/sunrpc/xprt.h       |    3 +
 include/trace/events/sunrpc.h     |  106 ++++++++++++++++++++++++++++++-------
 net/sunrpc/clnt.c                 |    8 ++-
 net/sunrpc/sched.c                |   10 ++-
 net/sunrpc/stats.c                |   16 ++++--
 net/sunrpc/sunrpc.h               |    6 --
 net/sunrpc/xprt.c                 |   34 +++++++-----
 net/sunrpc/xprtrdma/backchannel.c |    7 --
 net/sunrpc/xprtrdma/fmr_ops.c     |   13 ++++-
 net/sunrpc/xprtrdma/frwr_ops.c    |   53 +++++++++++++------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   32 ++++++++---
 net/sunrpc/xprtrdma/transport.c   |   43 +++------------
 net/sunrpc/xprtrdma/verbs.c       |   44 ++++++++++-----
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 +
 net/sunrpc/xprtsock.c             |    4 +
 16 files changed, 254 insertions(+), 136 deletions(-)

--
Chuck Lever
