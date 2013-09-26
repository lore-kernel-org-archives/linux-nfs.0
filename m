Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:5299 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654Ab3IZVpd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:45:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/7] SUNRPC: Clean up - convert xprt_prepare_transmit to return a bool
Date: Thu, 26 Sep 2013 17:45:03 -0400
Message-ID: <1380231907-13733-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1380231907-13733-1-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-2-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-3-git-send-email-Trond.Myklebust@netapp.com>
 <1380231907-13733-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xprt.h |  2 +-
 net/sunrpc/clnt.c           |  6 ++----
 net/sunrpc/xprt.c           | 15 +++++++++------
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index cec7b9b..8097b9d 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -288,7 +288,7 @@ int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
 void			xprt_lock_and_alloc_slot(struct rpc_xprt *xprt, struct rpc_task *task);
-int			xprt_prepare_transmit(struct rpc_task *task);
+bool			xprt_prepare_transmit(struct rpc_task *task);
 void			xprt_transmit(struct rpc_task *task);
 void			xprt_end_transmit(struct rpc_task *task);
 int			xprt_adjust_timeout(struct rpc_rqst *req);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7747960..fa50e42 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1722,8 +1722,7 @@ call_transmit(struct rpc_task *task)
 	task->tk_action = call_status;
 	if (task->tk_status < 0)
 		return;
-	task->tk_status = xprt_prepare_transmit(task);
-	if (task->tk_status != 0)
+	if (!xprt_prepare_transmit(task))
 		return;
 	task->tk_action = call_transmit_status;
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
@@ -1811,8 +1810,7 @@ call_bc_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 
-	task->tk_status = xprt_prepare_transmit(task);
-	if (task->tk_status == -EAGAIN) {
+	if (!xprt_prepare_transmit(task)) {
 		/*
 		 * Could not reserve the transport. Try again after the
 		 * transport is released.
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index e9ee7bf..c94f4a2 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -854,24 +854,27 @@ static inline int xprt_has_timer(struct rpc_xprt *xprt)
  * @task: RPC task about to send a request
  *
  */
-int xprt_prepare_transmit(struct rpc_task *task)
+bool xprt_prepare_transmit(struct rpc_task *task)
 {
 	struct rpc_rqst	*req = task->tk_rqstp;
 	struct rpc_xprt	*xprt = req->rq_xprt;
-	int err = 0;
+	bool ret = false;
 
 	dprintk("RPC: %5u xprt_prepare_transmit\n", task->tk_pid);
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (req->rq_reply_bytes_recvd && !req->rq_bytes_sent) {
-		err = req->rq_reply_bytes_recvd;
+		task->tk_status = req->rq_reply_bytes_recvd;
 		goto out_unlock;
 	}
-	if (!xprt->ops->reserve_xprt(xprt, task))
-		err = -EAGAIN;
+	if (!xprt->ops->reserve_xprt(xprt, task)) {
+		task->tk_status = -EAGAIN;
+		goto out_unlock;
+	}
+	ret = true;
 out_unlock:
 	spin_unlock_bh(&xprt->transport_lock);
-	return err;
+	return ret;
 }
 
 void xprt_end_transmit(struct rpc_task *task)
-- 
1.8.3.1

