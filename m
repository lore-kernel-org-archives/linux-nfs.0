Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:54751 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725825AbeIEBdE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:04 -0400
Received: by mail-it0-f51.google.com with SMTP id f14-v6so7021490ita.4
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:12 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.10
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:10 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 00/34] Convert RPC client transmission to a queued model
Date: Tue,  4 Sep 2018 17:05:15 -0400
Message-Id: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
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

Finally, we look at trying to avoid the requirement that every request
must go through the process of being woken up to grab the XPRT_LOCK in
order to transmit itself by allowing a request that currently holds the
XPRT_LOCK to grab other requests from an ordered queue, and to transmit
them too. The bulk of the changes in this patchset are dedicated to
providing this functionality.

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

---
v2: - Address feedback by Chuck.
      - Handle UDP/RDMA credits correctly
      - Remove throttling of TCP slot allocations
      - Minor nits
    - Clean up the write_space handling
    - Fair queueing


Trond Myklebust (34):
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
  SUNRPC: Don't wake queued RPC calls multiple times in xprt_transmit
  SUNRPC: Rename xprt->recv_lock to xprt->queue_lock
  SUNRPC: Refactor xprt_transmit() to remove the reply queue code
  SUNRPC: Refactor xprt_transmit() to remove wait for reply code
  SUNRPC: Minor cleanup for call_transmit()
  SUNRPC: Distinguish between the slot allocation list and receive queue
  NFS: Add a transmission queue for RPC requests
  SUNRPC: Refactor RPC call encoding
  SUNRPC: Treat the task and request as separate in the
    xprt_ops->send_request()
  SUNRPC: Don't reset the request 'bytes_sent' counter when releasing
    XPRT_LOCK
  SUNRPC: Simplify xprt_prepare_transmit()
  SUNRPC: Move RPC retransmission stat counter to xprt_transmit()
  SUNRPC: Fix up the back channel transmit
  SUNRPC: Support for congestion control when queuing is enabled
  SUNRPC: Improve latency for interactive tasks
  SUNRPC: Allow calls to xprt_transmit() to drain the entire transmit
    queue
  SUNRPC: Queue the request for transmission immediately after encoding
  SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
  SUNRPC: Allow soft RPC calls to time out when waiting for the
    XPRT_LOCK
  SUNRPC: Turn off throttling of RPC slots for TCP sockets
  SUNRPC: Clean up transport write space handling
  SUNRPC: Cleanup: remove the unused 'task' argument from the
    request_send()
  SUNRPC: Queue fairness for all.

 include/linux/sunrpc/auth.h                |   2 +
 include/linux/sunrpc/auth_gss.h            |   1 +
 include/linux/sunrpc/sched.h               |   9 +-
 include/linux/sunrpc/svc_xprt.h            |   1 -
 include/linux/sunrpc/xprt.h                |  31 +-
 include/linux/sunrpc/xprtsock.h            |  23 +-
 include/trace/events/sunrpc.h              |  10 +-
 net/sunrpc/auth.c                          |  10 +
 net/sunrpc/auth_gss/auth_gss.c             |  41 ++
 net/sunrpc/backchannel_rqst.c              |   4 +-
 net/sunrpc/clnt.c                          | 152 ++---
 net/sunrpc/sched.c                         | 189 +++---
 net/sunrpc/svc_xprt.c                      |   2 -
 net/sunrpc/svcsock.c                       |   6 +-
 net/sunrpc/xprt.c                          | 679 +++++++++++++--------
 net/sunrpc/xprtrdma/backchannel.c          |   7 +-
 net/sunrpc/xprtrdma/rpc_rdma.c             |  12 +-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  14 +-
 net/sunrpc/xprtrdma/transport.c            |  10 +-
 net/sunrpc/xprtsock.c                      | 359 ++++++-----
 20 files changed, 919 insertions(+), 643 deletions(-)

-- 
2.17.1
