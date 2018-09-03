Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:37403 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTuk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:40 -0400
Received: by mail-it0-f48.google.com with SMTP id h20-v6so1469183itf.2
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:00 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.29.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:29:59 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 01/27] SUNRPC: Clean up initialisation of the struct rpc_rqst
Date: Mon,  3 Sep 2018 11:29:10 -0400
Message-Id: <20180903152936.24325-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the initialisation back into xprt.c.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h |  1 -
 net/sunrpc/clnt.c           |  1 -
 net/sunrpc/xprt.c           | 91 +++++++++++++++++++++----------------
 3 files changed, 51 insertions(+), 42 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 336fd1a19cca..3d80524e92d6 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -325,7 +325,6 @@ struct xprt_class {
 struct rpc_xprt		*xprt_create_transport(struct xprt_create *args);
 void			xprt_connect(struct rpc_task *task);
 void			xprt_reserve(struct rpc_task *task);
-void			xprt_request_init(struct rpc_task *task);
 void			xprt_retry_reserve(struct rpc_task *task);
 int			xprt_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task);
 int			xprt_reserve_xprt_cong(struct rpc_xprt *xprt, struct rpc_task *task);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 8ea2f5fadd96..bc9d020bf71f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1558,7 +1558,6 @@ call_reserveresult(struct rpc_task *task)
 	task->tk_status = 0;
 	if (status >= 0) {
 		if (task->tk_rqstp) {
-			xprt_request_init(task);
 			task->tk_action = call_refresh;
 			return;
 		}
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index a8db2e3f8904..6aa09edc9567 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1250,6 +1250,55 @@ void xprt_free(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_free);
 
+static __be32
+xprt_alloc_xid(struct rpc_xprt *xprt)
+{
+	__be32 xid;
+
+	spin_lock(&xprt->reserve_lock);
+	xid = (__force __be32)xprt->xid++;
+	spin_unlock(&xprt->reserve_lock);
+	return xid;
+}
+
+static void
+xprt_init_xid(struct rpc_xprt *xprt)
+{
+	xprt->xid = prandom_u32();
+}
+
+static void
+xprt_request_init(struct rpc_task *task)
+{
+	struct rpc_xprt *xprt = task->tk_xprt;
+	struct rpc_rqst	*req = task->tk_rqstp;
+
+	INIT_LIST_HEAD(&req->rq_list);
+	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
+	req->rq_task	= task;
+	req->rq_xprt    = xprt;
+	req->rq_buffer  = NULL;
+	req->rq_xid	= xprt_alloc_xid(xprt);
+	req->rq_connect_cookie = xprt->connect_cookie - 1;
+	req->rq_bytes_sent = 0;
+	req->rq_snd_buf.len = 0;
+	req->rq_snd_buf.buflen = 0;
+	req->rq_rcv_buf.len = 0;
+	req->rq_rcv_buf.buflen = 0;
+	req->rq_release_snd_buf = NULL;
+	xprt_reset_majortimeo(req);
+	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
+			req, ntohl(req->rq_xid));
+}
+
+static void
+xprt_do_reserve(struct rpc_xprt *xprt, struct rpc_task *task)
+{
+	xprt->ops->alloc_slot(xprt, task);
+	if (task->tk_rqstp != NULL)
+		xprt_request_init(task);
+}
+
 /**
  * xprt_reserve - allocate an RPC request slot
  * @task: RPC task requesting a slot allocation
@@ -1269,7 +1318,7 @@ void xprt_reserve(struct rpc_task *task)
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (!xprt_throttle_congested(xprt, task))
-		xprt->ops->alloc_slot(xprt, task);
+		xprt_do_reserve(xprt, task);
 }
 
 /**
@@ -1291,45 +1340,7 @@ void xprt_retry_reserve(struct rpc_task *task)
 
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
-	xprt->ops->alloc_slot(xprt, task);
-}
-
-static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
-{
-	__be32 xid;
-
-	spin_lock(&xprt->reserve_lock);
-	xid = (__force __be32)xprt->xid++;
-	spin_unlock(&xprt->reserve_lock);
-	return xid;
-}
-
-static inline void xprt_init_xid(struct rpc_xprt *xprt)
-{
-	xprt->xid = prandom_u32();
-}
-
-void xprt_request_init(struct rpc_task *task)
-{
-	struct rpc_xprt *xprt = task->tk_xprt;
-	struct rpc_rqst	*req = task->tk_rqstp;
-
-	INIT_LIST_HEAD(&req->rq_list);
-	req->rq_timeout = task->tk_client->cl_timeout->to_initval;
-	req->rq_task	= task;
-	req->rq_xprt    = xprt;
-	req->rq_buffer  = NULL;
-	req->rq_xid	= xprt_alloc_xid(xprt);
-	req->rq_connect_cookie = xprt->connect_cookie - 1;
-	req->rq_bytes_sent = 0;
-	req->rq_snd_buf.len = 0;
-	req->rq_snd_buf.buflen = 0;
-	req->rq_rcv_buf.len = 0;
-	req->rq_rcv_buf.buflen = 0;
-	req->rq_release_snd_buf = NULL;
-	xprt_reset_majortimeo(req);
-	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
-			req, ntohl(req->rq_xid));
+	xprt_do_reserve(xprt, task);
 }
 
 /**
-- 
2.17.1
