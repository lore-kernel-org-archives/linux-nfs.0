From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 01/04]  NFS/RDMA client stall patches
Date: Wed, 11 Jun 2008 09:53:01 -0400
Message-ID: <RTPCLUEXC1-PRDaogxL000001eb@RTPMVEXC1-PRD.hq.netapp.com>
References: <4830F91C.7070206@sgi.com>
 <1213125899.20459.34.camel@localhost>
 <484F86B7.7040109@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, talpey@netapp.com,
	linux-nfs@vger.kernel.org
To: Peter Leckie <pleckie@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4088 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbYFKNxU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jun 2008 09:53:20 -0400
In-Reply-To: <484F86B7.7040109@sgi.com>
References: <4830F91C.7070206@sgi.com>
 <1213125899.20459.34.camel@localhost>
 <484F86B7.7040109@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 04:03 AM 6/11/2008, Peter Leckie wrote:
>That's a good point you raise there I was looking to closely at the tcp 
>equivalent, the correct fix for this issue would be to implement a timer 
>function for NFS/RDMA pretty much identical to xs_udp_timer(), as follows:

Hmm, in fact that runs into a different issue - retransmitting over RDMA
isn't allowed, since it consumes server credits and therefore will eventually
overrun the connection's receive queue. I have a patch in my queue to
force a disconnect in fact, which is the appropriate action. I will send them
out soon, it's in with some other post-Connectathon work.

I think with your earlier patch to avoid the 5-second pause, the disconnect
action will be prompt and accurate. However, I would still be concerned why
the RPC was timing out in the first place. Was there an issue in the server?

Tom.

>
>
>Implement xprt_rdma_timer() to be called when an RPC times out.
>This is needed to decrement the cong after an rpc times out preventing
>the congestion aviodance from tripping under retransmitts.
>
>Signed-off-by: Peter Leckie <pleckie-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>Reviewed-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
>---
>
>Index: linux-2.6.25.3/net/sunrpc/xprtrdma/transport.c
>===================================================================
>--- linux-2.6.25.3.orig/net/sunrpc/xprtrdma/transport.c
>+++ linux-2.6.25.3/net/sunrpc/xprtrdma/transport.c
>@@ -450,6 +450,18 @@ out1:
> }
>
> /*
>+ * xprt_rdma_timer - called when a retransmit timeout occurs on a RDMA 
>transport
>+ * @task: task that timed out
>+ *
>+ * Adjust the congestion window after a retransmit timeout has occurred.
>+ */
>+static void
>+xprt_rdma_timer(struct rpc_task *task)
>+{
>+       xprt_adjust_cwnd(task, -ETIMEDOUT);
>+}
>+
>+/*
>  * Close a connection, during shutdown or timeout/reconnect
>  */
> static void
>@@ -755,7 +767,8 @@ static struct rpc_xprt_ops xprt_rdma_pro
>        .send_request           = xprt_rdma_send_request,
>        .close                  = xprt_rdma_close,
>        .destroy                = xprt_rdma_destroy,
>-       .print_stats            = xprt_rdma_print_stats
>+       .print_stats            = xprt_rdma_print_stats,
>+       .timer                  = xprt_rdma_timer
> };
>
> static struct xprt_class xprt_rdma = {
>
>

