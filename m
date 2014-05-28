Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:46026 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753689AbaE1Odo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:33:44 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 13/24] xprtrmda: Reduce calls to ib_poll_cq() in completion
	handlers
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:33:42 -0400
Message-ID: <20140528143342.23214.16257.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the completion handlers to grab up to 16 items per
ib_poll_cq() call. No extra ib_poll_cq() is needed if fewer than 16
items are returned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c     |   56 ++++++++++++++++++++++++++-------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 +++
 2 files changed, 42 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index c7d5281..b8caee9 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -162,14 +162,23 @@ rpcrdma_sendcq_process_wc(struct ib_wc *wc)
 }
 
 static int
-rpcrdma_sendcq_poll(struct ib_cq *cq)
+rpcrdma_sendcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 {
-	struct ib_wc wc;
-	int rc;
+	struct ib_wc *wcs;
+	int count, rc;
 
-	while ((rc = ib_poll_cq(cq, 1, &wc)) == 1)
-		rpcrdma_sendcq_process_wc(&wc);
-	return rc;
+	do {
+		wcs = ep->rep_send_wcs;
+
+		rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
+		if (rc <= 0)
+			return rc;
+
+		count = rc;
+		while (count-- > 0)
+			rpcrdma_sendcq_process_wc(wcs++);
+	} while (rc == RPCRDMA_POLLSIZE);
+	return 0;
 }
 
 /*
@@ -183,9 +192,10 @@ rpcrdma_sendcq_poll(struct ib_cq *cq)
 static void
 rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 {
+	struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
 	int rc;
 
-	rc = rpcrdma_sendcq_poll(cq);
+	rc = rpcrdma_sendcq_poll(cq, ep);
 	if (rc) {
 		dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
 			__func__, rc);
@@ -202,7 +212,7 @@ rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 		return;
 	}
 
-	rpcrdma_sendcq_poll(cq);
+	rpcrdma_sendcq_poll(cq, ep);
 }
 
 static void
@@ -241,14 +251,23 @@ out_schedule:
 }
 
 static int
-rpcrdma_recvcq_poll(struct ib_cq *cq)
+rpcrdma_recvcq_poll(struct ib_cq *cq, struct rpcrdma_ep *ep)
 {
-	struct ib_wc wc;
-	int rc;
+	struct ib_wc *wcs;
+	int count, rc;
 
-	while ((rc = ib_poll_cq(cq, 1, &wc)) == 1)
-		rpcrdma_recvcq_process_wc(&wc);
-	return rc;
+	do {
+		wcs = ep->rep_recv_wcs;
+
+		rc = ib_poll_cq(cq, RPCRDMA_POLLSIZE, wcs);
+		if (rc <= 0)
+			return rc;
+
+		count = rc;
+		while (count-- > 0)
+			rpcrdma_recvcq_process_wc(wcs++);
+	} while (rc == RPCRDMA_POLLSIZE);
+	return 0;
 }
 
 /*
@@ -266,9 +285,10 @@ rpcrdma_recvcq_poll(struct ib_cq *cq)
 static void
 rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 {
+	struct rpcrdma_ep *ep = (struct rpcrdma_ep *)cq_context;
 	int rc;
 
-	rc = rpcrdma_recvcq_poll(cq);
+	rc = rpcrdma_recvcq_poll(cq, ep);
 	if (rc) {
 		dprintk("RPC:       %s: ib_poll_cq failed: %i\n",
 			__func__, rc);
@@ -285,7 +305,7 @@ rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 		return;
 	}
 
-	rpcrdma_recvcq_poll(cq);
+	rpcrdma_recvcq_poll(cq, ep);
 }
 
 #ifdef RPC_DEBUG
@@ -721,7 +741,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	INIT_DELAYED_WORK(&ep->rep_connect_worker, rpcrdma_connect_worker);
 
 	sendcq = ib_create_cq(ia->ri_id->device, rpcrdma_sendcq_upcall,
-				  rpcrdma_cq_async_error_upcall, NULL,
+				  rpcrdma_cq_async_error_upcall, ep,
 				  ep->rep_attr.cap.max_send_wr + 1, 0);
 	if (IS_ERR(sendcq)) {
 		rc = PTR_ERR(sendcq);
@@ -738,7 +758,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 	}
 
 	recvcq = ib_create_cq(ia->ri_id->device, rpcrdma_recvcq_upcall,
-				  rpcrdma_cq_async_error_upcall, NULL,
+				  rpcrdma_cq_async_error_upcall, ep,
 				  ep->rep_attr.cap.max_recv_wr + 1, 0);
 	if (IS_ERR(recvcq)) {
 		rc = PTR_ERR(recvcq);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 334ab6e..cb4c882 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -74,6 +74,8 @@ struct rpcrdma_ia {
  * RDMA Endpoint -- one per transport instance
  */
 
+#define RPCRDMA_POLLSIZE	(16)
+
 struct rpcrdma_ep {
 	atomic_t		rep_cqcount;
 	int			rep_cqinit;
@@ -88,6 +90,8 @@ struct rpcrdma_ep {
 	struct rdma_conn_param	rep_remote_cma;
 	struct sockaddr_storage	rep_remote_addr;
 	struct delayed_work	rep_connect_worker;
+	struct ib_wc		rep_send_wcs[RPCRDMA_POLLSIZE];
+	struct ib_wc		rep_recv_wcs[RPCRDMA_POLLSIZE];
 };
 
 #define INIT_CQCOUNT(ep) atomic_set(&(ep)->rep_cqcount, (ep)->rep_cqinit)

