Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 530FDC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E89C217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:00:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gHzjvJTB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729530AbeLSQAD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:00:03 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:43986 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727847AbeLSQAD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 11:00:03 -0500
Received: by mail-io1-f66.google.com with SMTP id g17so4151415ioc.10;
        Wed, 19 Dec 2018 08:00:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=q1UNWX1xN3M3bnDETWUWnK9CwpUhoEmmNy0M9CGMCC8=;
        b=gHzjvJTBDCP0Pom5WNtL3Pxuu+cPOLUaftFkWtLlHd93N8V6dr1kzakKwxHUNFAYES
         atzP9o3HVDyCveymYDBQEUdkQH7RGQBVswsaxbG5gqFDQfvJCs2CH1cQFZIYZVybNq2Y
         FnaKXXwSgBqDD6yCtVoi9NALRx5lC0ypNSLChMPzT5/V0L09tWTyn/FJkvqZjvbsN4Xi
         K+UUKfWnFnCT18zpe3Iu4sMb7EUKwc1H9XDYWlCoFkc7LM8d7us48WjoH/IrMlrRmWsN
         d5NjUJTBtGcKakLY7oUohNJTz1QP3mHbYMKgrtZj8G/OPPYnVKY3J5KYy6uR64TFVPku
         4exA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=q1UNWX1xN3M3bnDETWUWnK9CwpUhoEmmNy0M9CGMCC8=;
        b=f6B4efsj0Q0OZB4VqQ5VqnznpTyrXhlrnee1UHOcZM7hslFqQKCv1UriwaTlJLOzAC
         tkIUUwNjdz8fPocC1CH1yCFZTxh9gKiGgYkxUNs3JBCgsKWWer0GJIdZvRngIG+RD5zY
         Smi5hFq7O/39px40YqX90V5ehgTMczJgRkqWb31QbSx+C72vGU2E5UY0L7xKsrIaHhEm
         9g6XzqbjRze0LV54x0tH0v80t9HQTtZQGoWglXkwoMZ1bm7/76cRJsO+C/i3aM2zvkMi
         Fuetv1Vl/wE2V535wAabdWtfCzBJTBkviCNtuO17ApRqtdCO0PNb9zAgyUNqCpGceXd5
         6r5g==
X-Gm-Message-State: AA+aEWYrMuSyjfsrW7Ffa3uwsZ8Z9DELie6VssgN4kaxLerSkbjZcJSV
        4YarB3gbv1z+gOA4FdtRpN0=
X-Google-Smtp-Source: AFSGD/WlWB5lInCNaoeoz9WksGSV7Mf44zbrWuIAzpSIMOnokdWffzdNGoaU3QT+CZtAOv8WE7MJSg==
X-Received: by 2002:a6b:3b47:: with SMTP id i68mr18374855ioa.133.1545235202110;
        Wed, 19 Dec 2018 08:00:02 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id i201sm9334646ioa.1.2018.12.19.08.00.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 08:00:01 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJG002A025819;
        Wed, 19 Dec 2018 16:00:00 GMT
Subject: [PATCH v5 21/30] xprtrdma: Add trace points for calls to transport
 switch methods
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 11:00:00 -0500
Message-ID: <20181219160000.11602.77153.stgit@manet.1015granger.net>
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

Name them "trace_xprtrdma_op_*" so they can be easily enabled as a
group. No trace point is added where the generic layer already has
observability.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h  |   10 ++++++----
 net/sunrpc/xprtrdma/transport.c |   18 +++++++++++-------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index e9fbf7d..3d068bb 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -381,11 +381,13 @@
 DEFINE_RXPRT_EVENT(xprtrdma_conn_start);
 DEFINE_RXPRT_EVENT(xprtrdma_conn_tout);
 DEFINE_RXPRT_EVENT(xprtrdma_create);
-DEFINE_RXPRT_EVENT(xprtrdma_destroy);
+DEFINE_RXPRT_EVENT(xprtrdma_op_destroy);
 DEFINE_RXPRT_EVENT(xprtrdma_remove);
 DEFINE_RXPRT_EVENT(xprtrdma_reinsert);
 DEFINE_RXPRT_EVENT(xprtrdma_reconnect);
-DEFINE_RXPRT_EVENT(xprtrdma_inject_dsc);
+DEFINE_RXPRT_EVENT(xprtrdma_op_inject_dsc);
+DEFINE_RXPRT_EVENT(xprtrdma_op_close);
+DEFINE_RXPRT_EVENT(xprtrdma_op_connect);
 
 TRACE_EVENT(xprtrdma_qp_event,
 	TP_PROTO(
@@ -834,7 +836,7 @@
  ** Allocation/release of rpcrdma_reqs and rpcrdma_reps
  **/
 
-TRACE_EVENT(xprtrdma_allocate,
+TRACE_EVENT(xprtrdma_op_allocate,
 	TP_PROTO(
 		const struct rpc_task *task,
 		const struct rpcrdma_req *req
@@ -864,7 +866,7 @@
 	)
 );
 
-TRACE_EVENT(xprtrdma_rpc_done,
+TRACE_EVENT(xprtrdma_op_free,
 	TP_PROTO(
 		const struct rpc_task *task,
 		const struct rpcrdma_req *req
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 6a57033..d94da3c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -268,7 +268,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
-	trace_xprtrdma_inject_dsc(r_xprt);
+	trace_xprtrdma_op_inject_dsc(r_xprt);
 	rdma_disconnect(r_xprt->rx_ia.ri_id);
 }
 
@@ -284,7 +284,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
-	trace_xprtrdma_destroy(r_xprt);
+	trace_xprtrdma_op_destroy(r_xprt);
 
 	cancel_delayed_work_sync(&r_xprt->rx_connect_worker);
 
@@ -418,7 +418,7 @@
 out2:
 	rpcrdma_ia_close(&new_xprt->rx_ia);
 out1:
-	trace_xprtrdma_destroy(new_xprt);
+	trace_xprtrdma_op_destroy(new_xprt);
 	xprt_rdma_free_addresses(xprt);
 	xprt_free(xprt);
 	return ERR_PTR(rc);
@@ -428,7 +428,8 @@
  * xprt_rdma_close - close a transport connection
  * @xprt: transport context
  *
- * Called during transport shutdown, reconnect, or device removal.
+ * Called during autoclose or device removal.
+ *
  * Caller holds @xprt's send lock to prevent activity on this
  * transport while the connection is torn down.
  */
@@ -440,6 +441,8 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 
 	might_sleep();
 
+	trace_xprtrdma_op_close(r_xprt);
+
 	/* Prevent marshaling and sending of new requests */
 	xprt_clear_connected(xprt);
 
@@ -525,6 +528,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
+	trace_xprtrdma_op_connect(r_xprt);
 	if (r_xprt->rx_ep.rep_connected != 0) {
 		/* Reconnect */
 		schedule_delayed_work(&r_xprt->rx_connect_worker,
@@ -659,11 +663,11 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 
 	rqst->rq_buffer = req->rl_sendbuf->rg_base;
 	rqst->rq_rbuffer = req->rl_recvbuf->rg_base;
-	trace_xprtrdma_allocate(task, req);
+	trace_xprtrdma_op_allocate(task, req);
 	return 0;
 
 out_fail:
-	trace_xprtrdma_allocate(task, NULL);
+	trace_xprtrdma_op_allocate(task, NULL);
 	return -ENOMEM;
 }
 
@@ -682,7 +686,7 @@ void xprt_rdma_close(struct rpc_xprt *xprt)
 
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
 		rpcrdma_release_rqst(r_xprt, req);
-	trace_xprtrdma_rpc_done(task, req);
+	trace_xprtrdma_op_free(task, req);
 }
 
 /**

