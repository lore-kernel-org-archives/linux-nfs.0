Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:45121 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751477AbeEDTe3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:34:29 -0400
Subject: [PATCH v1 00/19] NFS/RDMA client patches for next
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:34:26 -0400
Message-ID: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Don't know what to call the next kernel release. v4.18? v5.0?
Anyway, here is the full set I'd like to see merged in that
release.

Along with the Receive efficiency-related patches that did not
get into v4.17, there are a number of unrelated fixes, improve-
ments, and clean ups in this series.

There is a three-patch series near the end that handles the
"empty sendctx queue" case a little more nicely. Instead of
waiting an arbitrary amount of time and trying again, an RPC
waits for the transport to wake it up when there are more
sendctxs available. I've found this makes the transport a
little less prone to deadlock under heavy workloads.

As usual, the series can be found in my git repo as well:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=refs/heads/nfs-rdma-for-4.18

---

Chuck Lever (19):
      xprtrdma: Add proper SPDX tags for NetApp-contributed source
      xprtrdma: Try to fail quickly if proto=rdma
      xprtrdma: Create transport's CM ID in the correct network namespace
      xprtrdma: Fix max_send_wr computation
      SUNRPC: Initialize rpc_rqst outside of xprt->reserve_lock
      SUNRPC: Add a ->free_slot transport callout
      xprtrdma: Introduce ->alloc_slot call-out for xprtrdma
      xprtrdma: Make rpc_rqst part of rpcrdma_req
      xprtrdma: Clean up Receive trace points
      xprtrdma: Move Receive posting to Receive handler
      xprtrdma: Remove rpcrdma_ep_{post_recv,post_extra_recv}
      xprtrdma: Remove rpcrdma_buffer_get_req_locked()
      xprtrdma: Remove rpcrdma_buffer_get_rep_locked()
      xprtrdma: Make rpcrdma_sendctx_put_locked() a static function
      xprtrdma: Return -ENOBUFS when no pages are available
      xprtrdma: Move common wait_for_buffer_space call to parent function
      xprtrdma: Wait on empty sendctx queue
      xprtrdma: Add trace_xprtrdma_dma_map(mr)
      xprtrdma: Remove transfertypes array


 include/linux/sunrpc/rpc_rdma.h            |    1 
 include/linux/sunrpc/xprt.h                |    6 -
 include/linux/sunrpc/xprtrdma.h            |    1 
 include/trace/events/rpcrdma.h             |   76 +++++--
 net/sunrpc/clnt.c                          |    1 
 net/sunrpc/xprt.c                          |   17 +-
 net/sunrpc/xprtrdma/backchannel.c          |  105 ++++------
 net/sunrpc/xprtrdma/fmr_ops.c              |   23 ++
 net/sunrpc/xprtrdma/frwr_ops.c             |   31 +++
 net/sunrpc/xprtrdma/module.c               |    1 
 net/sunrpc/xprtrdma/rpc_rdma.c             |   66 ++----
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |   64 +++++-
 net/sunrpc/xprtrdma/verbs.c                |  291 +++++++++++-----------------
 net/sunrpc/xprtrdma/xprt_rdma.h            |   26 +--
 net/sunrpc/xprtsock.c                      |    4 
 16 files changed, 359 insertions(+), 355 deletions(-)

--
Chuck Lever
