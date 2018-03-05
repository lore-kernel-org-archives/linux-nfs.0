Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35624 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbeCEUNb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Mar 2018 15:13:31 -0500
Subject: [PATCH 7/9] xprtrdma: Introduce ->alloc_slot call-out for xprtrdma
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 05 Mar 2018 15:13:29 -0500
Message-ID: <20180305201329.10904.5164.stgit@manet.1015granger.net>
In-Reply-To: <20180305200825.10904.40829.stgit@manet.1015granger.net>
References: <20180305200825.10904.40829.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcrdma_buffer_get acquires an rpcrdma_req and rep for each RPC.
Currently this is done in the call_allocate action, and sometimes it
can fail if there are many outstanding RPCs.

When call_allocate fails, the RPC task is put on the delayq. It is
awoken a few milliseconds later, but there's no guarantee it will
get a buffer at that time. The RPC task can be repeatedly put back
to sleep or even starved.

The call_allocate action should rarely fail. The delayq mechanism is
not meant to deal with transport congestion.

In the current sunrpc stack, there is a friendlier way to deal with
this situation. These objects are actually tantamount to an RPC
slot (rpc_rqst) and there is a separate FSM action, distinct from
call_allocate, for allocating slot resources. This is the
call_reserve action.

When allocation fails during this action, the RPC is placed on the
transport's backlog queue. The backlog mechanism provides a stronger
guarantee that when the RPC is awoken, a buffer will be available
for it; and backlogged RPCs are awoken one-at-a-time.

To make slot resource allocation occur in the call_reserve action,
create special ->alloc_slot and ->free_slot call-outs for xprtrdma.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |   52 ++++++++++++++++++++++++++++++++++++++-
 1 file changed, 50 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 40ff91d..1dac949 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -537,6 +537,54 @@
 	}
 }
 
+/**
+ * xprt_rdma_alloc_slot - allocate an rpc_rqst
+ * @xprt: controlling RPC transport
+ * @task: RPC task requesting a fresh rpc_rqst
+ *
+ * tk_status values:
+ *	%0 if task->tk_rqstp points to a fresh rpc_rqst
+ *	%-EAGAIN if no rpc_rqst is available; queued on backlog
+ */
+static void
+xprt_rdma_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	struct rpc_rqst *rqst;
+
+	spin_lock(&xprt->reserve_lock);
+	if (list_empty(&xprt->free))
+		goto out_sleep;
+	rqst = list_first_entry(&xprt->free, struct rpc_rqst, rq_list);
+	list_del(&rqst->rq_list);
+	spin_unlock(&xprt->reserve_lock);
+
+	task->tk_rqstp = rqst;
+	task->tk_status = 0;
+	return;
+
+out_sleep:
+	rpc_sleep_on(&xprt->backlog, task, NULL);
+	spin_unlock(&xprt->reserve_lock);
+	task->tk_status = -EAGAIN;
+}
+
+/**
+ * xprt_rdma_free_slot - release an rpc_rqst
+ * @xprt: controlling RPC transport
+ * @rqst: rpc_rqst to release
+ *
+ */
+static void
+xprt_rdma_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *rqst)
+{
+	memset(rqst, 0, sizeof(*rqst));
+
+	spin_lock(&xprt->reserve_lock);
+	list_add(&rqst->rq_list, &xprt->free);
+	rpc_wake_up_next(&xprt->backlog);
+	spin_unlock(&xprt->reserve_lock);
+}
+
 static bool
 rpcrdma_get_sendbuf(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req,
 		    size_t size, gfp_t flags)
@@ -779,8 +827,8 @@ void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 static const struct rpc_xprt_ops xprt_rdma_procs = {
 	.reserve_xprt		= xprt_reserve_xprt_cong,
 	.release_xprt		= xprt_release_xprt_cong, /* sunrpc/xprt.c */
-	.alloc_slot		= xprt_alloc_slot,
-	.free_slot		= xprt_free_slot,
+	.alloc_slot		= xprt_rdma_alloc_slot,
+	.free_slot		= xprt_rdma_free_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
 	.timer			= xprt_rdma_timer,

