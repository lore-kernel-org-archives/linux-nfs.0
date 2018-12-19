Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D1A9C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E4B20217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PN1mwfsb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729276AbeLSP6d (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:33 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36337 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728095AbeLSP6c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:32 -0500
Received: by mail-it1-f193.google.com with SMTP id c9so10052217itj.1;
        Wed, 19 Dec 2018 07:58:31 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=HmItSEbpQ0nLYBpzJa2hliI2p7Ennn0e5DZHPjfdd58=;
        b=PN1mwfsbPRqndWvKZ4sT5NnwV7NC7ON46NIWVy3jgF0ihfqROqX5o6G9YmmYLR9lQu
         TO22Nu0x1r9dM1i3twWrK4Zx/AG/CmWs+TXPEaMYT+Xg/bvT6khuP6Vcit0sl9D3Sj2I
         ybuJXa8HeFJVrCkRxK1IW35sNAmoGD01ytaU6OiVdD/VIMMVuxUfcYuCUb7X8Uh5GURl
         70W6ZVJb7+qflBrU7qOpiextv8EEC1QzaodlOyPE2BdZLFK4swlTC7cJjX6eXwHR8MCU
         sWVuKMZWPJWSiWPlzxxQiEa6tjXiuKTuqqvMfabwHse48yMAaq1VuYzPvLtqSJKvYWHq
         OBMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=HmItSEbpQ0nLYBpzJa2hliI2p7Ennn0e5DZHPjfdd58=;
        b=nNbStV5ENyFIITHqUqYZZ8Peym9h2HmcXmsnJJSpxENDs4mTUUR4yt6tS+L+E3Ig7K
         cSMcWEKQ/A9IgtdLpD7JkFJxJwDaVdnqd1peIqB0agfTQVxTORqi3JKJvbccJV8jDlPe
         /sawRf0svVsFr+HA3ZLvdkGsoUdh2c8nsxUP4wl1C0GBMtOpsgErNxjWotZb/E4UtMFR
         R5YiQJsX+KDocJqkxCu633vG3l+aJ1dfod7ydB+nvc57Hpk7WTEdYPPpH0WUY3P7dzvY
         /2vdqAq38h+aeHD0nxUQuYYppKJDFT4Nmc+oexYmtJCywpijdspF1FmbuvWwsiK9gtm+
         oWCQ==
X-Gm-Message-State: AA+aEWZexsS+4bNH1TMv/83he2h9emLLxECBm+2gz+jZTCfEyxgh0az5
        yxaE3l5YooMWABDIpbez5c92mSPu
X-Google-Smtp-Source: AFSGD/Va0w8e/fyMnWFZDZaywJ/kUW8Jj0X8Kzf0g+De1YvHA7PYz2VUgOb1Vr95JJ0L5gWgZ9GTpw==
X-Received: by 2002:a02:8943:: with SMTP id u3mr19440189jaj.92.1545235111440;
        Wed, 19 Dec 2018 07:58:31 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id r11sm8062214iog.46.2018.12.19.07.58.30
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:30 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFwTfg025768;
        Wed, 19 Dec 2018 15:58:29 GMT
Subject: [PATCH v5 04/30] xprtrdma: Replace rpcrdma_receive_wq with a
 per-xprt workqueue
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:29 -0500
Message-ID: <20181219155829.11602.21903.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
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

