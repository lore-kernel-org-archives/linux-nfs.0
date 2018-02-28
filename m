Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:37870 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934322AbeB1Ua0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Feb 2018 15:30:26 -0500
Subject: [PATCH 0/8] NFS/RDMA client-side patches for v4.17
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 28 Feb 2018 15:30:22 -0500
Message-ID: <20180228202916.25968.21750.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Starting set of NFS/RDMA client-side changes for the next merge
window. These are clean-ups and simple fixes. Let me know what you
think.

---

Chuck Lever (8):
      xprtrdma: Fix latency regression on NUMA NFS/RDMA clients
      xprtrdma: Remove arbitrary limit on initiator depth
      xprtrdma: Remove xprt-specific connect cookie
      xprtrdma: ->send_request returns -EAGAIN when there are no free MRs
      xprtrdma: Reduce number of MRs created by rpcrdma_mrs_create
      xprtrdma: "Support" call-only RPCs
      xprtrdma: Chain Send to FastReg WRs
      xprtrdma: Move creation of rl_rdmabuf to rpcrdma_create_req


 include/linux/sunrpc/clnt.h       |    7 +++++
 net/sunrpc/sunrpc.h               |    6 ----
 net/sunrpc/xprtrdma/backchannel.c |    7 -----
 net/sunrpc/xprtrdma/fmr_ops.c     |   13 ++++++++-
 net/sunrpc/xprtrdma/frwr_ops.c    |   53 +++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/rpc_rdma.c    |   32 +++++++++++++++-------
 net/sunrpc/xprtrdma/transport.c   |   42 ++++++-----------------------
 net/sunrpc/xprtrdma/verbs.c       |   31 ++++++++++++++--------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    4 +--
 9 files changed, 108 insertions(+), 87 deletions(-)

--
Chuck Lever
