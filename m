Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:37508 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbeBZRWJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Feb 2018 12:22:09 -0500
Subject: [PATCH] xprtrdma: Fix latency regression on NUMA NFS/RDMA clients
From: Chuck Lever <chuck.lever@oracle.com>
To: tj@kernel.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 26 Feb 2018 12:22:06 -0500
Message-ID: <20180226171008.13286.35869.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With v4.15, on one of my NFS/RDMA clients I measured a nearly
doubling in the latency of small read and write system calls. There
was no change in server round trip time. The extra latency appears
in the whole RPC execution path.

"git bisect" settled on commit ccede7598588 ("xprtrdma: Spread reply
processing over more CPUs") .

After some experimentation, I found that leaving the WQ bound and
allowing the scheduler to pick the dispatch CPU seems to eliminate
the long latencies, and it does not introduce any new regressions.

The fix is implemented by reverting only the part of
commit ccede7598588 ("xprtrdma: Spread reply processing over more
CPUs") that dispatches RPC replies specifically on the CPU where the
matching RPC call was made.

Interestingly, saving the CPU number and later queuing reply
processing there was effective _only_ for a NFS READ and WRITE
request. On my NUMA client, in-kernel RPC reply processing for
asynchronous RPCs was dispatched on the same CPU where the RPC call
was made, as expected. However synchronous RPCs seem to get their
reply dispatched on some other CPU than where the call was placed,
every time.

Fixes: ccede7598588 ("xprtrdma: Spread reply processing over ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Tejun-

I'm interested in your comments about how rpcrdma_reply_handler uses
queue_work to spread workload away from the CPU core that is
assigned to handle Receive completions, in particular how it might
work on NUMA systems.

The rpcrdma_receive_wq workqueue is no longer WQ_UNBOUND. In this
patch I have changed the mechanism from queuing work on a particular
core to queuing work using WORK_CPU_UNBOUND and letting the scheduler
choose where the work item is dispatched.

The purpose is to move work away from the Receiving CPU when it is
busy, to help the workload scale well on systems with multiple CPUs.


 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +-
 net/sunrpc/xprtrdma/transport.c |    2 --
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index f0855a9..4bc0f4d 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1366,7 +1366,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 
 	trace_xprtrdma_reply(rqst->rq_task, rep, req, credits);
 
-	queue_work_on(req->rl_cpu, rpcrdma_receive_wq, &rep->rr_work);
+	queue_work(rpcrdma_receive_wq, &rep->rr_work);
 	return;
 
 out_badstatus:
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 4b1ecfe..f86021e 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -52,7 +52,6 @@
 #include <linux/slab.h>
 #include <linux/seq_file.h>
 #include <linux/sunrpc/addr.h>
-#include <linux/smp.h>
 
 #include "xprt_rdma.h"
 
@@ -651,7 +650,6 @@
 	if (!rpcrdma_get_recvbuf(r_xprt, req, rqst->rq_rcvsize, flags))
 		goto out_fail;
 
-	req->rl_cpu = smp_processor_id();
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 69883a9..430a6de 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -334,7 +334,6 @@ enum {
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
-	int			rl_cpu;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;

