Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B96ABC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 80C6620821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DvFzLlqh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80C6620821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726912AbeLJQah (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:37 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:43288 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726261AbeLJQah (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:37 -0500
Received: by mail-io1-f68.google.com with SMTP id f10so9207679iop.10;
        Mon, 10 Dec 2018 08:30:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ijFlg4gNwV5klWtj+UHZfTnXIPSoAKNmthK3wzVM/cM=;
        b=DvFzLlqhGKo32bccDOpjra1MJJfmsz5QAehcsIeZIQ9Z7TnwXBohunWmEUpaJ1XA8g
         jMZdCYolIx+vt/urBlYjz3qtPbuKviVYB/yZIjXlaDLbnlb+we3GFG1S/eBSROw8O8IL
         tajX01xzxrAnaN5dvtMV0hgfsXRZZN+EYKK/ur+fnkw+GXteBi7DKXbzSgI5KC5VZup0
         ONkS787R1UPH7w7d1rQOEaqX/nBqWMoznytZfoSxSgMAvrIiqMdFtUMqmNAXtV7p4liG
         a6D8a0QKvvTcQ0yMbyvC5JK/fAiBmQQ5e+7UrD5w+DRpiaN0BuhyIuH9dnQv+FsNMlS7
         PBIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ijFlg4gNwV5klWtj+UHZfTnXIPSoAKNmthK3wzVM/cM=;
        b=pgkBwZdgSMjOQGAlpYB1L5joNkB3ZUBUolqvGTpxCfXnBFun+24qgb6oqZYx63FqqI
         Bx3BnDoGxC4Mk9buabjxNRTuJluqujKbcXQyPW+YDbayF5nnW9KAhI2vIYNeq+mLuVDU
         hsLOyz778+Cie3jpWoQ6hg9U1wz7TvtA3Z1kpLxKilHEis5827x+GLpsHFYxNEpTZeoL
         Ga6DiBXeOJSBpJYIStUV85/Gj8+kChNl8emrntKlJmcTiBeJ+de4+rqOLvs/5vXVfpws
         +cwHIB6T1LS5rEP4x94f2A6SKxvtE/4pHR65tXpb9Xkej/cg+urGQUT6eUimPJjpEyWK
         apAQ==
X-Gm-Message-State: AA+aEWaJ5lTJVQZk+rZ4zyVggsP8GTZNhRcpHnVXA5qiHaHtjDoFNbkB
        cjjKRTZULsr9lQWW5ivr9JbYHuYZ
X-Google-Smtp-Source: AFSGD/UtPha4prkRCXjjI0yDBj+Ix+V2fNsLgpnFu+In/q1pWZiJYmkgbaIbzANaUr0zRyFPOiKRDg==
X-Received: by 2002:a6b:6e17:: with SMTP id d23mr9050320ioh.138.1544459435704;
        Mon, 10 Dec 2018 08:30:35 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t129sm5956645ita.4.2018.12.10.08.30.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:35 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUX8Q031064;
        Mon, 10 Dec 2018 16:30:33 GMT
Subject: [PATCH v3 14/24] xprtrdma: Add trace points for calls to transport
 switch methods
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:33 -0500
Message-ID: <20181210163033.4198.62477.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
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
index 807669c..727786f 100644
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
index 5d6c3b3..7e9f143 100644
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
@@ -439,6 +440,8 @@
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
 	struct rpcrdma_ia *ia = &r_xprt->rx_ia;
 
+	trace_xprtrdma_op_close(r_xprt);
+
 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
@@ -518,6 +521,7 @@
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 
+	trace_xprtrdma_op_connect(r_xprt);
 	if (r_xprt->rx_ep.rep_connected != 0) {
 		/* Reconnect */
 		schedule_delayed_work(&r_xprt->rx_connect_worker,
@@ -652,11 +656,11 @@
 
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
 
@@ -675,7 +679,7 @@
 
 	if (test_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags))
 		rpcrdma_release_rqst(r_xprt, req);
-	trace_xprtrdma_rpc_done(task, req);
+	trace_xprtrdma_op_free(task, req);
 }
 
 /**

