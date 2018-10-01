Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f171.google.com ([209.85.166.171]:40428 "EHLO
        mail-it1-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726178AbeJBBEK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:04:10 -0400
Subject: [PATCH v2 00/20] NFS/RDMA client patches for v4.20
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:25:03 -0400
Message-ID: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

These are ready for you to consider for the next merge window.
The series is a mixed bag of fixes and clean ups, the important
ones being:

- Ensure credit grant is reduced to 1 after a reconnect
- Delete MRs instead of recovering them
- Modernize the connect logic

Details can be found in the patch descriptions.

Support for sending RPCs with both Write and Reply chunks has
been dropped after some server-side issues were discovered
during NFS bake-a-thon testing. I plan to revisit these.


Changes since v1:
- rebased on v4.19-rc6
- write + reply patches dropped
- tested at NFS bake-a-thon
- comments and patch descriptions clarified

---

Chuck Lever (20):
      xprtrdma: xprt_release_rqst_cong is called outside of transport_lock
      xprtrdma: Reset credit grant properly after a disconnect
      xprtrdma: Create more MRs at a time
      xprtrdma: Explicitly resetting MRs is no longer necessary
      xprtrdma: Name MR trace events consistently
      sunrpc: Fix connect metrics
      sunrpc: Report connect_time in seconds
      xprtrdma: Rename rpcrdma_conn_upcall
      xprtrdma: Conventional variable names in rpcrdma_conn_upcall
      xprtrdma: Eliminate "connstate" variable from rpcrdma_conn_upcall()
      xprtrdma: Re-organize the switch() in rpcrdma_conn_upcall
      xprtrdma: Simplify RPC wake-ups on connect
      xprtrdma: Rename rpcrdma_qp_async_error_upcall
      xprtrdma: Remove memory address of "ep" from an error message
      xprtrdma: Don't disable BH's in backchannel server
      xprtrdma: Move rb_flags initialization
      xprtrdma: Report when there were zero posted Receives
      xprtrdma: Add documenting comments
      xprtrdma: Clean up xprt_rdma_disconnect_inject
      xprtrdma: Squelch a sparse warning


 include/trace/events/rpcrdma.h             |   18 +--
 net/sunrpc/xprt.c                          |   14 +-
 net/sunrpc/xprtrdma/backchannel.c          |   16 +--
 net/sunrpc/xprtrdma/fmr_ops.c              |  131 +++++++++------------
 net/sunrpc/xprtrdma/frwr_ops.c             |  137 ++++++++--------------
 net/sunrpc/xprtrdma/rpc_rdma.c             |   20 +--
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 
 net/sunrpc/xprtrdma/transport.c            |  110 ++++++++---------
 net/sunrpc/xprtrdma/verbs.c                |  178 ++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h            |   18 +--
 net/sunrpc/xprtsock.c                      |   14 +-
 11 files changed, 302 insertions(+), 355 deletions(-)

--
Chuck Lever
