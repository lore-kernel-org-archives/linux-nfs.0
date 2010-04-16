From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] SUNRPC: Clean up xprt_release()
Date: Fri, 16 Apr 2010 16:47:46 -0400
Message-ID: <1271450871-10777-1-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54877 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932521Ab0DPUrw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Apr 2010 16:47:52 -0400
Received: from localhost.localdomain (marilynd-lxp.hq.netapp.com [10.58.50.136] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3GKlp8v008034
	for <linux-nfs@vger.kernel.org>; Fri, 16 Apr 2010 13:47:51 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xprt.c |   32 ++++++++++++++++----------------
 1 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 42f09ad..18415cc 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -62,7 +62,6 @@
  * Local functions
  */
 static void	xprt_request_init(struct rpc_task *, struct rpc_xprt *);
-static inline void	do_xprt_reserve(struct rpc_task *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
@@ -935,7 +934,7 @@ void xprt_transmit(struct rpc_task *task)
 	spin_unlock_bh(&xprt->transport_lock);
 }
 
-static inline void do_xprt_reserve(struct rpc_task *task)
+static void xprt_alloc_slot(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
@@ -955,6 +954,16 @@ static inline void do_xprt_reserve(struct rpc_task *task)
 	rpc_sleep_on(&xprt->backlog, task, NULL);
 }
 
+static void xprt_free_slot(struct rpc_xprt *xprt, struct rpc_rqst *req)
+{
+	memset(req, 0, sizeof(*req));	/* mark unused */
+
+	spin_lock(&xprt->reserve_lock);
+	list_add(&req->rq_list, &xprt->free);
+	rpc_wake_up_next(&xprt->backlog);
+	spin_unlock(&xprt->reserve_lock);
+}
+
 /**
  * xprt_reserve - allocate an RPC request slot
  * @task: RPC task requesting a slot allocation
@@ -968,7 +977,7 @@ void xprt_reserve(struct rpc_task *task)
 
 	task->tk_status = -EIO;
 	spin_lock(&xprt->reserve_lock);
-	do_xprt_reserve(task);
+	xprt_alloc_slot(task);
 	spin_unlock(&xprt->reserve_lock);
 }
 
@@ -1006,14 +1015,10 @@ void xprt_release(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt;
 	struct rpc_rqst	*req;
-	int is_bc_request;
 
 	if (!(req = task->tk_rqstp))
 		return;
 
-	/* Preallocated backchannel request? */
-	is_bc_request = bc_prealloc(req);
-
 	xprt = req->rq_xprt;
 	rpc_count_iostats(task);
 	spin_lock_bh(&xprt->transport_lock);
@@ -1027,21 +1032,16 @@ void xprt_release(struct rpc_task *task)
 		mod_timer(&xprt->timer,
 				xprt->last_used + xprt->idle_timeout);
 	spin_unlock_bh(&xprt->transport_lock);
-	if (!bc_prealloc(req))
+	if (req->rq_buffer)
 		xprt->ops->buf_free(req->rq_buffer);
 	task->tk_rqstp = NULL;
 	if (req->rq_release_snd_buf)
 		req->rq_release_snd_buf(req);
 
 	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
-	if (likely(!is_bc_request)) {
-		memset(req, 0, sizeof(*req));	/* mark unused */
-
-		spin_lock(&xprt->reserve_lock);
-		list_add(&req->rq_list, &xprt->free);
-		rpc_wake_up_next(&xprt->backlog);
-		spin_unlock(&xprt->reserve_lock);
-	} else
+	if (likely(!bc_prealloc(req)))
+		xprt_free_slot(xprt, req);
+	else
 		xprt_free_bc_request(req);
 }
 
-- 
1.6.6.1

