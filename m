Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:61050 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaKIBPD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Nov 2014 20:15:03 -0500
Subject: [PATCH v2 07/10] xprtrdma: Display async errors
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Sat, 08 Nov 2014 20:15:01 -0500
Message-ID: <20141109011501.8806.23478.stgit@manet.1015granger.net>
In-Reply-To: <20141109010328.8806.5861.stgit@manet.1015granger.net>
References: <20141109010328.8806.5861.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An async error upcall is a hard error, and should be reported in
the system log.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   36 ++++++++++++++++++++++++++++++++----
 1 file changed, 32 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e6ac964..5783c1a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -106,6 +106,32 @@ rpcrdma_run_tasklet(unsigned long data)
 
 static DECLARE_TASKLET(rpcrdma_tasklet_g, rpcrdma_run_tasklet, 0UL);
 
+static const char * const async_event[] = {
+	"CQ error",
+	"QP fatal error",
+	"QP request error",
+	"QP access error",
+	"communication established",
+	"send queue drained",
+	"path migration successful",
+	"path mig error",
+	"device fatal error",
+	"port active",
+	"port error",
+	"LID change",
+	"P_key change",
+	"SM change",
+	"SRQ error",
+	"SRQ limit reached",
+	"last WQE reached",
+	"client reregister",
+	"GID change",
+};
+
+#define ASYNC_MSG(status)					\
+	((status) < ARRAY_SIZE(async_event) ?			\
+		async_event[(status)] : "unknown async error")
+
 static void
 rpcrdma_schedule_tasklet(struct list_head *sched_list)
 {
@@ -122,8 +148,9 @@ rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;
 
-	dprintk("RPC:       %s: QP error %X on device %s ep %p\n",
-		__func__, event->event, event->device->name, context);
+	pr_err("RPC:       %s: %s on device %s ep %p\n",
+	       __func__, ASYNC_MSG(event->event),
+		event->device->name, context);
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
 		ep->rep_func(ep);
@@ -136,8 +163,9 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
 {
 	struct rpcrdma_ep *ep = context;
 
-	dprintk("RPC:       %s: CQ error %X on device %s ep %p\n",
-		__func__, event->event, event->device->name, context);
+	pr_err("RPC:       %s: %s on device %s ep %p\n",
+	       __func__, ASYNC_MSG(event->event),
+		event->device->name, context);
 	if (ep->rep_connected == 1) {
 		ep->rep_connected = -EIO;
 		ep->rep_func(ep);

