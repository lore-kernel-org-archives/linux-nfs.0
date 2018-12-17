Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA33BC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ABC202133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RKIcWbnq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388310AbeLQQlQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:16 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:50278 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388011AbeLQQlQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:41:16 -0500
Received: by mail-it1-f196.google.com with SMTP id z7so19482548iti.0;
        Mon, 17 Dec 2018 08:41:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=AuCrVQqqfFuSRgtyALKDS0UafgRojodNvuiKzeqp4Jc=;
        b=RKIcWbnqEGxQM+SZc+jafbjClCV7gLIeBrrxKukh7taTgeMu+3x1Nm7oXW36iPGKe4
         LGvTF1sAw8eGTLsUFXT5TqjA7OFcQmLT/NdY9qp845qgQJLvExrZ77KH4AS8jeo7LmIL
         qU0tML+NNBoCmyPnbqDq5kWJXsCAqz2HnZ0qYqgsX4RyUKRI1N0fV03jv1gzhwGjg0xV
         4FAHzcw3pEfwc/hZ0wz91L0p8XnjJgdCXdQzWeLKMGvVgLX4owcj1qwoNMpQhzeJJRio
         5rUzGLNthSmTVdHtQamc0uOm4KRxon2h2abhHnOBlEFa5ZFVca16U5X6vpJMXpiMvGHr
         SyZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=AuCrVQqqfFuSRgtyALKDS0UafgRojodNvuiKzeqp4Jc=;
        b=Fi864LZy6njnlfPRM8vyWv2H+aqNVrCd1x01ie703b3OVb0bsVj6lHMSf08RrZP5RA
         XY0NMsR0nigATpyqHnpFOuXrdQjwl0WlZjp7szZ4WMmTeRREpz94JwZ9Aow+ZhbqYxd8
         QUGvfVaErIlMJJy7BqlkloHSuXjKyPKDTiAi+w18nIIHSoFA0huuECEWQB+S+QLdfy9M
         jXlsptEG6Gxc5jVDFL/KVRF2tD9ymxdmWcM5DO2mvxFhaG3AvcBRo2rT0YpAzFekWQPN
         RwTn5OyVzKoImtYIpw8sds/avaxQKwbahzxfZWVjfAjn2QuGvvfUy6+UfDcHQXOVGZTj
         rTKg==
X-Gm-Message-State: AA+aEWY9OTtEWFBfCJe3wQT3Qvs3g74493uQKUKkZRaHY+MS1QgrYU/p
        r0N28XMKkJXnXpy1FacttLY+NQj+
X-Google-Smtp-Source: AFSGD/UdvU+fdl0eyYZBXpvnFR0vNSO4HpZCCnz8a9fJ324H9LbGfOPvanWsyAD1UzMnR1NXrPILbg==
X-Received: by 2002:a24:b951:: with SMTP id k17mr11756175iti.147.1545064874671;
        Mon, 17 Dec 2018 08:41:14 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id j5sm552235iop.17.2018.12.17.08.41.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:41:14 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGfDvG018642;
        Mon, 17 Dec 2018 16:41:13 GMT
Subject: [PATCH v4 21/30] xprtrdma: Add trace points for calls to transport
 switch methods
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:41:13 -0500
Message-ID: <20181217164113.24133.16198.stgit@manet.1015granger.net>
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
index 41e4347..cb855b2 100644
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
@@ -441,6 +442,8 @@
 
 	might_sleep();
 
+	trace_xprtrdma_op_close(r_xprt);
+
 	/* Prevent marshaling and sending of new requests */
 	xprt_clear_connected(xprt);
 
@@ -526,6 +529,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
+	trace_xprtrdma_op_connect(r_xprt);
 	if (r_xprt->rx_ep.rep_connected != 0) {
 		/* Reconnect */
 		schedule_delayed_work(&r_xprt->rx_connect_worker,
@@ -660,11 +664,11 @@
 
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
 
@@ -683,7 +687,7 @@
 
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
 		rpcrdma_release_rqst(r_xprt, req);
-	trace_xprtrdma_rpc_done(task, req);
+	trace_xprtrdma_op_free(task, req);
 }
 
 /**

