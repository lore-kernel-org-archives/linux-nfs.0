Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:58640 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727614AbeICWCg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 18:02:36 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 00/27] Convert RPC client transmission to a queued model
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
Date: Mon, 3 Sep 2018 13:41:21 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7775195B-7882-422A-862E-0E0DEE7171C4@oracle.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
To: Trond Myklebust <trondmy@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Sep 3, 2018, at 11:29 AM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> For historical reasons, the RPC client is heavily serialised during the
> process of transmitting a request by the XPRT_LOCK. A request is
> required to take that lock before it can start XDR encoding, and it is
> required to hold it until it is done transmitting. In essence the lock
> protects the following functions:
> 
> - Stream based transport connect/reconnect
> - RPCSEC_GSS encoding of the RPC message
> - Transmission of a single RPC message

It also protects TCP rqst slot allocation:

void xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
{
        /* Note: grabbing the xprt_lock_write() ensures that we throttle
         * new slot allocation if the transport is congested (i.e. when
         * reconnecting a stream transport or when out of socket write
         * buffer space).
         */
        if (xprt_lock_write(xprt, task)) {
                xprt_alloc_slot(xprt, task);
                xprt_release_write(xprt, task);
        }
}


> The following patch set assumes that we do not need to do much to
> improve performance of the connect/reconnect case, as that is supposed
> to be a rare occurrence.
> 
> The set looks at dealing with RPCSEC_GSS issues by removing serialisation
> while encoding, and simply assuming that if we detect after grabbing the
> XPRT_LOCK that we're about to transmit a message with a sequence number
> that has fallen outside the window allowed by RFC2203, then we can
> abort the transmission of that message, and schedule it for re-encoding.
> Since window sizes are typically expected to lie above 100 messages or
> so, we expect these cases where we miss the window to be rare, in
> general.
> 
> Finally, we look at trying to avoid the requirement that every request
> must go through the process of being woken up to grab the XPRT_LOCK in
> order to transmit itself by allowing a request that currently holds the
> XPRT_LOCK to grab other requests from an ordered queue, and to transmit
> them too. The bulk of the changes in this patchset are dedicated to
> providing this functionality.

When considering whether this kind of change could work for
xprtrdma: the transport send lock mechanism is used to manage
the credit grant. The transport send lock prevents the client
from sending too many RPC Calls at once.

Congestion- or flow-controlled transports might not be able to
adopt this approach, because there needs to be a check before
each RPC Call is sent to see if the congestion/credit window
has room.


> Trond Myklebust (27):
>  SUNRPC: Clean up initialisation of the struct rpc_rqst
>  SUNRPC: If there is no reply expected, bail early from call_decode
>  SUNRPC: The transmitted message must lie in the RPCSEC window of
>    validity
>  SUNRPC: Simplify identification of when the message send/receive is
>    complete
>  SUNRPC: Avoid holding locks across the XDR encoding of the RPC message
>  SUNRPC: Rename TCP receive-specific state variables
>  SUNRPC: Move reset of TCP state variables into the reconnect code
>  SUNRPC: Add socket transmit queue offset tracking
>  SUNRPC: Simplify dealing with aborted partially transmitted messages
>  SUNRPC: Refactor the transport request pinning
>  SUNRPC: Add a helper to wake up a sleeping rpc_task and set its status
>  SUNRPC: Don't wake queued RPC calls multiple times in xprt_transmit
>  SUNRPC: Rename xprt->recv_lock to xprt->queue_lock
>  SUNRPC: Refactor xprt_transmit() to remove the reply queue code
>  SUNRPC: Refactor xprt_transmit() to remove wait for reply code
>  SUNRPC: Minor cleanup for call_transmit()
>  SUNRPC: Distinguish between the slot allocation list and receive queue
>  NFS: Add a transmission queue for RPC requests
>  SUNRPC: Refactor RPC call encoding
>  SUNRPC: Treat the task and request as separate in the
>    xprt_ops->send_request()
>  SUNRPC: Don't reset the request 'bytes_sent' counter when releasing
>    XPRT_LOCK
>  SUNRPC: Simplify xprt_prepare_transmit()
>  SUNRPC: Move RPC retransmission stat counter to xprt_transmit()
>  SUNRPC: Fix up the back channel transmit
>  SUNRPC: Allow calls to xprt_transmit() to drain the entire transmit
>    queue
>  SUNRPC: Queue the request for transmission immediately after encoding
>  SUNRPC: Convert the xprt->sending queue back to an ordinary wait queue
> 
> include/linux/sunrpc/auth.h                |   2 +
> include/linux/sunrpc/auth_gss.h            |   1 +
> include/linux/sunrpc/sched.h               |   7 +-
> include/linux/sunrpc/xprt.h                |  23 +-
> include/linux/sunrpc/xprtsock.h            |  23 +-
> include/trace/events/sunrpc.h              |  10 +-
> net/sunrpc/auth.c                          |  10 +
> net/sunrpc/auth_gss/auth_gss.c             |  41 ++
> net/sunrpc/backchannel_rqst.c              |   3 +-
> net/sunrpc/clnt.c                          | 139 +++---
> net/sunrpc/sched.c                         |  63 ++-
> net/sunrpc/svcsock.c                       |   6 +-
> net/sunrpc/xprt.c                          | 503 +++++++++++++--------
> net/sunrpc/xprtrdma/backchannel.c          |   3 +-
> net/sunrpc/xprtrdma/rpc_rdma.c             |  10 +-
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   7 +-
> net/sunrpc/xprtrdma/transport.c            |   5 +-
> net/sunrpc/xprtsock.c                      | 327 +++++++-------
> 18 files changed, 728 insertions(+), 455 deletions(-)
> 
> -- 
> 2.17.1
> 

--
Chuck Lever
