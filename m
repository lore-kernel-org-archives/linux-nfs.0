Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC529C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6F1492133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rR78ME9H"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388128AbeLQQjq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:46 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:34671 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727771AbeLQQjp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:45 -0500
Received: by mail-it1-f193.google.com with SMTP id x124so5915383itd.1;
        Mon, 17 Dec 2018 08:39:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=HmItSEbpQ0nLYBpzJa2hliI2p7Ennn0e5DZHPjfdd58=;
        b=rR78ME9HGAIO4LSkN7R/rMtay+59VdVJOigXaIkxgH7m1BU3THH8HgeZykpxPZV3eJ
         ZUo0TDEWnuuzDYClMTJj9dBg13lbBXXY9BwZ7JPJnxhG+EicGopcuo+gGuylbBx2H6yd
         X1OdgtsYR34VmGaCCmFkm+WIRz4jYIHRiA1m6AyTFi09Y3G+3HiQuTdlaJsYm1aBMLSy
         JIl88okQz7c6aJsrwo+ip7cq/Enh20lBPsigSvmZYAWov/VHjAFAnmFv5fPl5P99TBXO
         ffb2QXJpUOtmQoSSbMwQzrvxqPT4Sy7UQXXlgQ8q6Axhwd9o1ZquAhYMIFjAD4lHSXcl
         7aWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HmItSEbpQ0nLYBpzJa2hliI2p7Ennn0e5DZHPjfdd58=;
        b=nY4FasTt5FcHj/lZIydG65RYm6iB188gGA35PkUoRydMGzDvuzvHCvfaXf7DqWrcFy
         ZVBRqfKgk02aFsYaoVlvTpER+TBYE3KikLE0rtpJcofcvtqlsm99/NXyTCEGGYBdzMkC
         1tQJ5PzmM0Vt8HzUCpBk3U65dABjtoMXnWOjKqOaUTPbwO6Ijsd4TQs34Q/eWaWXzZU9
         c8JBLJkLJCI/c/N8HGm43yfEPby4+D6nkfwLgmjvAfa2fCPQ7O54pkRbtcBmIvd8AlT4
         mHxaTD+0renWlw7VvotH24H4Fca+PAiZt5oNsjk4O74/SJPL4Zagq3EQ+DnqbgQxJbRQ
         N8BA==
X-Gm-Message-State: AA+aEWanTD8GydiTus5he5jT92sCJJK+2xhMsMgp+17V7E4sY8g9eTaA
        rqvNgzbUzg4MW86llyrcGz+n/Y8k
X-Google-Smtp-Source: AFSGD/WYanoJznCxMQjE/LG9wVmGnLv+o/WZqU3o5iFvlzjSwh3FnGqckUWwGnyX1YQyrKhbpaGkZw==
X-Received: by 2002:a24:2e94:: with SMTP id i142mr13747871ita.157.1545064784047;
        Mon, 17 Dec 2018 08:39:44 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id p19sm8754291itp.13.2018.12.17.08.39.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:43 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdge4018582;
        Mon, 17 Dec 2018 16:39:42 GMT
Subject: [PATCH v4 04/30] xprtrdma: Replace rpcrdma_receive_wq with a
 per-xprt workqueue
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:42 -0500
Message-ID: <20181217163942.24133.66960.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

To address a connection-close ordering problem, we need the ability
to drain the RPC completions running on rpcrdma_receive_wq for just
one transport. Give each transport its own RPC completion workqueue,
and drain that workqueue when disconnecting the transport.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |    2 +
 net/sunrpc/xprtrdma/transport.c |   17 +++-------
 net/sunrpc/xprtrdma/verbs.c     |   67 +++++++++++++++++++++------------------
 net/sunrpc/xprtrdma/xprt_rdma.h |    6 +--
 4 files changed, 44 insertions(+), 48 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index dc23977..5738c9f 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1356,7 +1356,7 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 
 	trace_xprtrdma_reply(rqst->rq_task, rep, req, credits);
-	queue_work(rpcrdma_receive_wq, &rep->rr_work);
+	queue_work(buf->rb_completion_wq, &rep->rr_work);
 	return;
 
 out_badversion:
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index ae2a838..91c476a 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -444,10 +444,14 @@
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
+	might_sleep();
+
 	dprintk("RPC:       %s: closing xprt %p\n", __func__, xprt);
 
+	/* Prevent marshaling and sending of new requests */
+	xprt_clear_connected(xprt);
+
 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
-		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
 		return;
 	}
@@ -858,8 +862,6 @@ void xprt_rdma_cleanup(void)
 		dprintk("RPC:       %s: xprt_unregister returned %i\n",
 			__func__, rc);
 
-	rpcrdma_destroy_wq();
-
 	rc = xprt_unregister_transport(&xprt_rdma_bc);
 	if (rc)
 		dprintk("RPC:       %s: xprt_unregister(bc) returned %i\n",
@@ -870,20 +872,13 @@ int xprt_rdma_init(void)
 {
 	int rc;
 
-	rc = rpcrdma_alloc_wq();
-	if (rc)
-		return rc;
-
 	rc = xprt_register_transport(&xprt_rdma);
-	if (rc) {
-		rpcrdma_destroy_wq();
+	if (rc)
 		return rc;
-	}
 
 	rc = xprt_register_transport(&xprt_rdma_bc);
 	if (rc) {
 		xprt_unregister_transport(&xprt_rdma);
-		rpcrdma_destroy_wq();
 		return rc;
 	}
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index e4461e7..cff3a5d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -80,33 +80,23 @@
 static void rpcrdma_dma_unmap_regbuf(struct rpcrdma_regbuf *rb);
 static void rpcrdma_post_recvs(struct rpcrdma_xprt *r_xprt, bool temp);
 
-struct workqueue_struct *rpcrdma_receive_wq __read_mostly;
-
-int
-rpcrdma_alloc_wq(void)
+/* Wait for outstanding transport work to finish.
+ */
+static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 {
-	struct workqueue_struct *recv_wq;
-
-	recv_wq = alloc_workqueue("xprtrdma_receive",
-				  WQ_MEM_RECLAIM | WQ_HIGHPRI,
-				  0);
-	if (!recv_wq)
-		return -ENOMEM;
-
-	rpcrdma_receive_wq = recv_wq;
-	return 0;
-}
+	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
+	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
-void
-rpcrdma_destroy_wq(void)
-{
-	struct workqueue_struct *wq;
+	/* Flush Receives, then wait for deferred Reply work
+	 * to complete.
+	 */
+	ib_drain_qp(ia->ri_id->qp);
+	drain_workqueue(buf->rb_completion_wq);
 
-	if (rpcrdma_receive_wq) {
-		wq = rpcrdma_receive_wq;
-		rpcrdma_receive_wq = NULL;
-		destroy_workqueue(wq);
-	}
+	/* Deferred Reply processing might have scheduled
+	 * local invalidations.
+	 */
+	ib_drain_sq(ia->ri_id->qp);
 }
 
 /**
@@ -483,7 +473,7 @@
 	 *   connection is already gone.
 	 */
 	if (ia->ri_id->qp) {
-		ib_drain_qp(ia->ri_id->qp);
+		rpcrdma_xprt_drain(r_xprt);
 		rdma_destroy_qp(ia->ri_id);
 		ia->ri_id->qp = NULL;
 	}
@@ -825,8 +815,10 @@
 	return rc;
 }
 
-/*
- * rpcrdma_ep_disconnect
+/**
+ * rpcrdma_ep_disconnect - Disconnect underlying transport
+ * @ep: endpoint to disconnect
+ * @ia: associated interface adapter
  *
  * This is separate from destroy to facilitate the ability
  * to reconnect without recreating the endpoint.
@@ -837,19 +829,20 @@
 void
 rpcrdma_ep_disconnect(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia)
 {
+	struct rpcrdma_xprt *r_xprt = container_of(ep, struct rpcrdma_xprt,
+						   rx_ep);
 	int rc;
 
+	/* returns without wait if ID is not connected */
 	rc = rdma_disconnect(ia->ri_id);
 	if (!rc)
-		/* returns without wait if not connected */
 		wait_event_interruptible(ep->rep_connect_wait,
 							ep->rep_connected != 1);
 	else
 		ep->rep_connected = rc;
-	trace_xprtrdma_disconnect(container_of(ep, struct rpcrdma_xprt,
-					       rx_ep), rc);
+	trace_xprtrdma_disconnect(r_xprt, rc);
 
-	ib_drain_qp(ia->ri_id->qp);
+	rpcrdma_xprt_drain(r_xprt);
 }
 
 /* Fixed-size circular FIFO queue. This implementation is wait-free and
@@ -1183,6 +1176,13 @@ struct rpcrdma_req *
 	if (rc)
 		goto out;
 
+	buf->rb_completion_wq = alloc_workqueue("rpcrdma-%s",
+						WQ_MEM_RECLAIM | WQ_HIGHPRI,
+						0,
+			r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
+	if (!buf->rb_completion_wq)
+		goto out;
+
 	return 0;
 out:
 	rpcrdma_buffer_destroy(buf);
@@ -1241,6 +1241,11 @@ struct rpcrdma_req *
 {
 	cancel_delayed_work_sync(&buf->rb_refresh_worker);
 
+	if (buf->rb_completion_wq) {
+		destroy_workqueue(buf->rb_completion_wq);
+		buf->rb_completion_wq = NULL;
+	}
+
 	rpcrdma_sendctxs_destroy(buf);
 
 	while (!list_empty(&buf->rb_recv_bufs)) {
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 788124c..3f198cd 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -412,6 +412,7 @@ struct rpcrdma_buffer {
 
 	u32			rb_bc_max_requests;
 
+	struct workqueue_struct *rb_completion_wq;
 	struct delayed_work	rb_refresh_worker;
 };
 #define rdmab_to_ia(b) (&container_of((b), struct rpcrdma_xprt, rx_buf)->rx_ia)
@@ -547,8 +548,6 @@ struct rpcrdma_xprt {
 bool frwr_is_supported(struct rpcrdma_ia *);
 bool fmr_is_supported(struct rpcrdma_ia *);
 
-extern struct workqueue_struct *rpcrdma_receive_wq;
-
 /*
  * Endpoint calls - xprtrdma/verbs.c
  */
@@ -603,9 +602,6 @@ struct rpcrdma_regbuf *rpcrdma_alloc_regbuf(size_t, enum dma_data_direction,
 	return __rpcrdma_dma_map_regbuf(ia, rb);
 }
 
-int rpcrdma_alloc_wq(void);
-void rpcrdma_destroy_wq(void);
-
 /*
  * Wrappers for chunk registration, shared by read/write chunk code.
  */

