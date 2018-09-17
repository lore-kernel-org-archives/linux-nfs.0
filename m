Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:40848 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727460AbeIQSbN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:13 -0400
Received: by mail-qt0-f173.google.com with SMTP id h4-v6so15111487qtj.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:03:58 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.03.56
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:03:57 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 00/44] Convert RPC client transmission to a queued model
Date: Mon, 17 Sep 2018 09:02:51 -0400
Message-Id: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For historical reasons, the RPC client is heavily serialised during the
process of transmitting a request by the XPRT_LOCK. A request is
required to take that lock before it can start XDR encoding, and it is
required to hold it until it is done transmitting. In essence the lock
protects the following functions:

- Stream based transport connect/reconnect
- RPCSEC_GSS encoding of the RPC message
- Transmission of a single RPC message

The following patch set assumes that we do not need to do much to
improve performance of the connect/reconnect case, as that is supposed
to be a rare occurrence.

The set looks at dealing with RPCSEC_GSS issues by removing serialisation
while encoding, and simply assuming that if we detect after grabbing the
XPRT_LOCK that we're about to transmit a message with a sequence number
that has fallen outside the window allowed by RFC2203, then we can
abort the transmission of that message, and schedule it for re-encoding.
Since window sizes are typically expected to lie above 100 messages or
so, we expect these cases where we miss the window to be rare, in
general.

We try to avoid the requirement that every request must go through the
process of being woken up to grab the XPRT_LOCK in order to transmit itself
by allowing a request that currently holds the XPRT_LOCK to grab other
requests from an ordered queue, and to transmit them too. The bulk of
the changes in this patchset are dedicated to providing this functionality.

In addition, the XPRT_LOCK queue provides some extra functionality:
- Throttling of the TCP slot allocation (as Chuck pointed out)
- Fair queuing, to ensure batch jobs don't crowd out interactive ones

The patchset does add functionality to ensure that the resulting
transmission queue is fair, and also fixes up the RPC wait queues to
ensure that they don't compromise fairness.
For now, this patchset discards the TCP slot throttling. We may still
want to throttle in the case where the connection is lost, but if we
do so, we should ensure we do not serialise all requests when in the
connected state.


The last few patches also take a new look at the client receive code
now that we have the iterator method for reading socket data into page
buffers. It converts the TCP and the UNIX stream code to using the
iterator method and performs some cleanups.

---
v2: - Address feedback by Chuck.
      - Handle UDP/RDMA credits correctly
      - Remove throttling of TCP slot allocations
      - Minor nits
    - Clean up the write_space handling
    - Fair queueing
v3: - Performance improvements, bugfixes and cleanups
    - Socket stream receive queue improvements

Trond Myklebust (44):
  SUNRPC: Clean up initialisation of the struct rpc_rqst
  SUNRPC: If there is no reply expected, bail early from call_decode
  SUNRPC: The transmitted message must lie in the RPCSEC window of
    validity
  SUNRPC: Simplify identification of when the message send/receive is
    complete
  SUNRPC: Avoid holding locks across the XDR encoding of the RPC message
  SUNRPC: Rename TCP receive-specific state variables
  SUNRPC: Move reset of TCP state variables into the reconnect code
  SUNRPC: Add socket transmit queue offset tracking
  SUNRPC: Simplify dealing with aborted partially transmitted messages
  SUNRPC: Refactor the transport request pinning
  SUNRPC: Add a helper to wake up a sleeping rpc_task and set its status
  SUNRPC: Test whether the task is queued before grabbing the queue
    spinlocks
  SUNRPC: Don't wake queued RPC calls multiple times in xprt_transmit
  SUNRPC: Rename xprt->recv_lock to xprt->queue_lock
  SUNRPC: Refactor xprt_transmit() to remove the reply queue code
  SUNRPC: Refactor xprt_transmit() to remove wait for reply code
  SUNRPC: Minor cleanup for call_transmit()
  SUNRPC: Distinguish between the slot allocation list and receive queue
  SUNRPC: Add a transmission queue for RPC requests
  SUNRPC: Refactor RPC call encoding
  SUNRPC: Fix up the back channel transmit
  SUNRPC: Treat the task and request as separate in the
    xprt_ops->send_request()
  SUNRPC: Don't reset the request 'bytes_sent' counter when releasing
    XPRT_LOCK
  SUNRPC: Simplify xprt_prepare_transmit()
  SUNRPC: Move RPC retransmission stat counter to xprt_transmit()
  SUNRPC: Improve latency for interactive tasks
  SUNRPC: Support for congestion control when queuing is enabled
  SUNRPC: Enqueue swapper tagged RPCs at the head of the transmit queue
  SUNRPC: Allow calls to xprt_transmit() to drain the entire transmit
    queue
  SUNRPC: Allow soft RPC calls to time out when waiting for the
    XPRT_LOCK
  SUNRPC: Turn off throttling of RPC slots for TCP sockets
  SUNRPC: Clean up transport write space handling
  SUNRPC: Cleanup: remove the unused 'task' argument from the
    request_send()
  SUNRPC: Don't take transport->lock unnecessarily when taking XPRT_LOCK
  SUNRPC: Convert xprt receive queue to use an rbtree
  SUNRPC: Fix priority queue fairness
  SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
  SUNRPC: Add a label for RPC calls that require allocation on receive
  SUNRPC: Add a bvec array to struct xdr_buf for use with iovec_iter()
  SUNRPC: Simplify TCP receive code by switching to using iterators
  SUNRPC: Clean up - rename xs_tcp_data_receive() to
    xs_stream_data_receive()
  SUNRPC: Allow AF_LOCAL sockets to use the generic stream receive
  SUNRPC: Clean up xs_udp_data_receive()
  SUNRPC: Unexport xdr_partial_copy_from_skb()

 fs/nfs/nfs3xdr.c                           |    4 +-
 include/linux/sunrpc/auth.h                |    2 +
 include/linux/sunrpc/auth_gss.h            |    1 +
 include/linux/sunrpc/bc_xprt.h             |    1 +
 include/linux/sunrpc/sched.h               |   10 +-
 include/linux/sunrpc/svc_xprt.h            |    1 -
 include/linux/sunrpc/xdr.h                 |   11 +-
 include/linux/sunrpc/xprt.h                |   35 +-
 include/linux/sunrpc/xprtsock.h            |   36 +-
 include/trace/events/sunrpc.h              |   37 +-
 net/sunrpc/auth.c                          |   10 +
 net/sunrpc/auth_gss/auth_gss.c             |   41 +
 net/sunrpc/auth_gss/gss_rpc_xdr.c          |    1 +
 net/sunrpc/backchannel_rqst.c              |    1 -
 net/sunrpc/clnt.c                          |  174 ++--
 net/sunrpc/sched.c                         |  178 ++--
 net/sunrpc/socklib.c                       |   10 +-
 net/sunrpc/svc_xprt.c                      |    2 -
 net/sunrpc/svcsock.c                       |    6 +-
 net/sunrpc/xdr.c                           |   34 +
 net/sunrpc/xprt.c                          |  893 ++++++++++++-----
 net/sunrpc/xprtrdma/backchannel.c          |    4 +-
 net/sunrpc/xprtrdma/rpc_rdma.c             |   12 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   14 +-
 net/sunrpc/xprtrdma/transport.c            |   10 +-
 net/sunrpc/xprtsock.c                      | 1060 +++++++++-----------
 26 files changed, 1474 insertions(+), 1114 deletions(-)

-- 
2.17.1
