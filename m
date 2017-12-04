Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:42848 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752664AbdLDTEH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:04:07 -0500
Subject: [PATCH v2] xprtrdma: Spread reply processing over more CPUs
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 04 Dec 2017 14:04:04 -0500
Message-ID: <20171204190257.18106.4464.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d8f532d20ee4 ("xprtrdma: Invoke rpcrdma_reply_handler
directly from RECV completion") introduced a performance regression
for NFS I/O small enough to not need memory registration. In multi-
threaded benchmarks that generate primarily small I/O requests,
IOPS throughput is reduced by nearly a third. This patch restores
the previous level of throughput.

Because workqueues are typically BOUND (in particular ib_comp_wq,
nfsiod_workqueue, and rpciod_workqueue), NFS/RDMA workloads tend
to aggregate on the CPU that is handling Receive completions.

The usual approach to addressing this problem is to create a QP
and CQ for each CPU, and then schedule transactions on the QP
for the CPU where you want the transaction to complete. The
transaction then does not require an extra context switch during
completion to end up on the same CPU where the transaction was
started.

This approach doesn't work for the Linux NFS/RDMA client because
currently the Linux NFS client does not support multiple connections
per client-server pair, and the RDMA core API does not make it
straightforward for ULPs to determine which CPU is responsible for
handling Receive completions for a CQ.

So for the moment, record the CPU number in the rpcrdma_req before
the transport sends each RPC Call. Then during Receive completion,
queue the RPC completion on that same CPU.

Additionally, move all RPC completion processing to the deferred
handler so that even RPCs with simple small replies complete on
the CPU that sent the corresponding RPC Call.

Fixes: d8f532d20ee4 ("xprtrdma: Invoke rpcrdma_reply_handler ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Anna-

This version actually applies to v4.15-rc2. The previous one applied
to v4.15-rc1 plus my for-4.16 patches. Sorry for the noise!


 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 +-----
 net/sunrpc/xprtrdma/transport.c |    2 ++
 net/sunrpc/xprtrdma/verbs.c     |    2 +-
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index ed34dc0..a3f2ab2 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1408,11 +1408,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	dprintk("RPC:       %s: reply %p completes request %p (xid 0x%08x)\n",
 		__func__, rep, req, be32_to_cpu(rep->rr_xid));
 
-	if (list_empty(&req->rl_registered) &&
-	    !test_bit(RPCRDMA_REQ_F_TX_RESOURCES, &req->rl_flags))
-		rpcrdma_complete_rqst(rep);
-	else
-		queue_work(rpcrdma_receive_wq, &rep->rr_work);
+	queue_work_on(req->rl_cpu, rpcrdma_receive_wq, &rep->rr_work);
 	return;
 
 out_badstatus:
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 646c244..6ee1ad8 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -52,6 +52,7 @@
 #include <linux/slab.h>
 #include <linux/seq_file.h>
 #include <linux/sunrpc/addr.h>
+#include <linux/smp.h>
 
 #include "xprt_rdma.h"
 
@@ -656,6 +657,7 @@
 		task->tk_pid, __func__, rqst->rq_callsize,
 		rqst->rq_rcvsize, req);
 
+	req->rl_cpu = smp_processor_id();
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	rpcrdma_set_xprtdata(rqst, req);
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 710b3f7..8607c02 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -83,7 +83,7 @@
 	struct workqueue_struct *recv_wq;
 
 	recv_wq = alloc_workqueue("xprtrdma_receive",
-				  WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_HIGHPRI,
+				  WQ_MEM_RECLAIM | WQ_HIGHPRI,
 				  0);
 	if (!recv_wq)
 		return -ENOMEM;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 51686d9..1342f743 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -342,6 +342,7 @@ enum {
 struct rpcrdma_buffer;
 struct rpcrdma_req {
 	struct list_head	rl_list;
+	int			rl_cpu;
 	unsigned int		rl_connect_cookie;
 	struct rpcrdma_buffer	*rl_buffer;
 	struct rpcrdma_rep	*rl_reply;

