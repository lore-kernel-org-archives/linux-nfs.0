Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:44660 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbaJPTjV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:39:21 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so4194298ier.34
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:39:20 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id o192sm3539381ioe.11.2014.10.16.12.39.20
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:39:20 -0700 (PDT)
Subject: [PATCH v1 08/16] xprtrdma: Display async errors
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:39:19 -0400
Message-ID: <20141016193919.13414.61481.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
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
index dc4c8e3..73079d5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -108,6 +108,32 @@ rpcrdma_run_tasklet(unsigned long data)
 
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
@@ -124,8 +150,9 @@ rpcrdma_qp_async_error_upcall(struct ib_event *event, void *context)
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
@@ -138,8 +165,9 @@ rpcrdma_cq_async_error_upcall(struct ib_event *event, void *context)
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

