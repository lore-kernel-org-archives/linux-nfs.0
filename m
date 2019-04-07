Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39A82C282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E838F213F2
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KYjLuCkL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726396AbfDGSB0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:26 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:55317 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726335AbfDGSBZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:25 -0400
Received: by mail-it1-f194.google.com with SMTP id y134so10661794itc.5
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=oXpNgtjk/pXDmhG4NDR4Oj6TkEKGdglhq0H0a/4jjXA=;
        b=KYjLuCkL5mXx/YKaBUIICdfAqdqnqsIZONdmXUGnzvZjxmVhnPTWIGDPELENmjpu/2
         TLlOQptk0Hk2uJ0xcKuOoAChAvCpisyom0f+1Cc6SZN25tz8S4dlX6XjAHYZl1OMSrzA
         Mka7zLtm8xE30LnjcT3ZsSlMvcU8951nfCRtn/8WRWfpiBifZP6R+VtOeOwACP1WYDTi
         fkvZ9N3qHU106w7dHQIDWK0llEfC9zBDLG90OIjiGXoKEmeSMAHcrygLN1ZEs8uMAhl7
         g5FkmHCL6IxhwgEcoDcRF7SiY6cgK8V9WL9KLH4V+eVpp/vGpyrjbW923dBr/z2hCdgA
         Q/cQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=oXpNgtjk/pXDmhG4NDR4Oj6TkEKGdglhq0H0a/4jjXA=;
        b=WudmUWcsV7gtg+Fp428E1uSQG7whNLLpXjCBDgJQRKScb1swRpntP/za70jYc2xzOk
         ylFVX7bY0TSIPlX7CgNZfyo9IpL/yc/OpvEK3biwG0ADnJzqkXUOZhOK4w1fvv4NtdpV
         wZiY3k3mPpKJoN4w4QrI+JrJWIud9eR8M0bAYWorh0xokorL1V0qe4YBJXryth1FQk6n
         UAOwcnurcADdveyzsK/OnSBmH8MJyTm62FAB0czwnlEMOZUxILsTHnHGnHHyoK4HAgaf
         V3+2RcVyfKMHk1wo2JRhv/dk8VOTFSeCkAFeGHPYlxYiBltu1SHX2poHGSNttMeiWdZn
         2u5w==
X-Gm-Message-State: APjAAAWB9tCDdDCowUO25Gz5tl9eTApsviWIsG6xQrdxksST8tJhS4mU
        5dYWdJDG3H7G5nH7dwUCmcLLuys=
X-Google-Smtp-Source: APXvYqz60Cf5cC4ilth/eozQVA1NCcSpowcKrERwHOu5UAJGqc3aXPEjTjzS28kFC7a1NVxBOhumWA==
X-Received: by 2002:a02:924d:: with SMTP id y13mr15675197jag.24.1554660083976;
        Sun, 07 Apr 2019 11:01:23 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:23 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 03/29] SUNRPC: Refactor xprt_request_wait_receive()
Date:   Sun,  7 Apr 2019 13:58:46 -0400
Message-Id: <20190407175912.23528-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-3-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Convert the transport callback to actually put the request to sleep
instead of just setting a timeout. This is in preparation for
rpc_sleep_on_timeout().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprt.h                |  6 +-
 net/sunrpc/xprt.c                          | 79 ++++++++++++----------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  2 +-
 net/sunrpc/xprtrdma/transport.c            |  2 +-
 net/sunrpc/xprtsock.c                      |  8 +--
 5 files changed, 51 insertions(+), 46 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 3a391544299e..a6d9fce7f20e 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -143,7 +143,7 @@ struct rpc_xprt_ops {
 	void		(*buf_free)(struct rpc_task *task);
 	void		(*prepare_request)(struct rpc_rqst *req);
 	int		(*send_request)(struct rpc_rqst *req);
-	void		(*set_retrans_timeout)(struct rpc_task *task);
+	void		(*wait_for_reply_request)(struct rpc_task *task);
 	void		(*timer)(struct rpc_xprt *xprt, struct rpc_task *task);
 	void		(*release_request)(struct rpc_task *task);
 	void		(*close)(struct rpc_xprt *xprt);
@@ -378,8 +378,8 @@ xprt_disable_swap(struct rpc_xprt *xprt)
 int			xprt_register_transport(struct xprt_class *type);
 int			xprt_unregister_transport(struct xprt_class *type);
 int			xprt_load_transport(const char *);
-void			xprt_set_retrans_timeout_def(struct rpc_task *task);
-void			xprt_set_retrans_timeout_rtt(struct rpc_task *task);
+void			xprt_wait_for_reply_request_def(struct rpc_task *task);
+void			xprt_wait_for_reply_request_rtt(struct rpc_task *task);
 void			xprt_wake_pending_tasks(struct rpc_xprt *xprt, int status);
 void			xprt_wait_for_buffer_space(struct rpc_xprt *xprt);
 bool			xprt_write_space(struct rpc_xprt *xprt);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 3a4156cb0134..5afffa669d04 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -554,41 +554,6 @@ bool xprt_write_space(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_write_space);
 
-/**
- * xprt_set_retrans_timeout_def - set a request's retransmit timeout
- * @task: task whose timeout is to be set
- *
- * Set a request's retransmit timeout based on the transport's
- * default timeout parameters.  Used by transports that don't adjust
- * the retransmit timeout based on round-trip time estimation.
- */
-void xprt_set_retrans_timeout_def(struct rpc_task *task)
-{
-	task->tk_timeout = task->tk_rqstp->rq_timeout;
-}
-EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_def);
-
-/**
- * xprt_set_retrans_timeout_rtt - set a request's retransmit timeout
- * @task: task whose timeout is to be set
- *
- * Set a request's retransmit timeout using the RTT estimator.
- */
-void xprt_set_retrans_timeout_rtt(struct rpc_task *task)
-{
-	int timer = task->tk_msg.rpc_proc->p_timer;
-	struct rpc_clnt *clnt = task->tk_client;
-	struct rpc_rtt *rtt = clnt->cl_rtt;
-	struct rpc_rqst *req = task->tk_rqstp;
-	unsigned long max_timeout = clnt->cl_timeout->to_maxval;
-
-	task->tk_timeout = rpc_calc_rto(rtt, timer);
-	task->tk_timeout <<= rpc_ntimeo(rtt, timer) + req->rq_retries;
-	if (task->tk_timeout > max_timeout || task->tk_timeout == 0)
-		task->tk_timeout = max_timeout;
-}
-EXPORT_SYMBOL_GPL(xprt_set_retrans_timeout_rtt);
-
 static void xprt_reset_majortimeo(struct rpc_rqst *req)
 {
 	const struct rpc_timeout *to = req->rq_task->tk_client->cl_timeout;
@@ -1102,6 +1067,47 @@ static void xprt_timer(struct rpc_task *task)
 		task->tk_status = 0;
 }
 
+/**
+ * xprt_wait_for_reply_request_def - wait for reply
+ * @task: pointer to rpc_task
+ *
+ * Set a request's retransmit timeout based on the transport's
+ * default timeout parameters.  Used by transports that don't adjust
+ * the retransmit timeout based on round-trip time estimation,
+ * and put the task to sleep on the pending queue.
+ */
+void xprt_wait_for_reply_request_def(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
+
+	task->tk_timeout = req->rq_timeout;
+	rpc_sleep_on(&req->rq_xprt->pending, task, xprt_timer);
+}
+EXPORT_SYMBOL_GPL(xprt_wait_for_reply_request_def);
+
+/**
+ * xprt_wait_for_reply_request_rtt - wait for reply using RTT estimator
+ * @task: pointer to rpc_task
+ *
+ * Set a request's retransmit timeout using the RTT estimator,
+ * and put the task to sleep on the pending queue.
+ */
+void xprt_wait_for_reply_request_rtt(struct rpc_task *task)
+{
+	int timer = task->tk_msg.rpc_proc->p_timer;
+	struct rpc_clnt *clnt = task->tk_client;
+	struct rpc_rtt *rtt = clnt->cl_rtt;
+	struct rpc_rqst *req = task->tk_rqstp;
+	unsigned long max_timeout = clnt->cl_timeout->to_maxval;
+
+	task->tk_timeout = rpc_calc_rto(rtt, timer);
+	task->tk_timeout <<= rpc_ntimeo(rtt, timer) + req->rq_retries;
+	if (task->tk_timeout > max_timeout || task->tk_timeout == 0)
+		task->tk_timeout = max_timeout;
+	rpc_sleep_on(&req->rq_xprt->pending, task, xprt_timer);
+}
+EXPORT_SYMBOL_GPL(xprt_wait_for_reply_request_rtt);
+
 /**
  * xprt_request_wait_receive - wait for the reply to an RPC request
  * @task: RPC task about to send a request
@@ -1121,8 +1127,7 @@ void xprt_request_wait_receive(struct rpc_task *task)
 	 */
 	spin_lock(&xprt->queue_lock);
 	if (test_bit(RPC_TASK_NEED_RECV, &task->tk_runstate)) {
-		xprt->ops->set_retrans_timeout(task);
-		rpc_sleep_on(&xprt->pending, task, xprt_timer);
+		xprt->ops->wait_for_reply_request(task);
 		/*
 		 * Send an extra queue wakeup call if the
 		 * connection was dropped in case the call to
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index 907464c2a9f0..bed57d8b5c19 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -261,7 +261,7 @@ static const struct rpc_xprt_ops xprt_rdma_bc_procs = {
 	.buf_alloc		= xprt_rdma_bc_allocate,
 	.buf_free		= xprt_rdma_bc_free,
 	.send_request		= xprt_rdma_bc_send_request,
-	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.wait_for_reply_request	= xprt_wait_for_reply_request_def,
 	.close			= xprt_rdma_bc_close,
 	.destroy		= xprt_rdma_bc_put,
 	.print_stats		= xprt_rdma_print_stats
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5d261353bd90..7e73abe01cfe 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -815,7 +815,7 @@ static const struct rpc_xprt_ops xprt_rdma_procs = {
 	.alloc_slot		= xprt_rdma_alloc_slot,
 	.free_slot		= xprt_rdma_free_slot,
 	.release_request	= xprt_release_rqst_cong,       /* ditto */
-	.set_retrans_timeout	= xprt_set_retrans_timeout_def, /* ditto */
+	.wait_for_reply_request	= xprt_wait_for_reply_request_def, /* ditto */
 	.timer			= xprt_rdma_timer,
 	.rpcbind		= rpcb_getport_async,	/* sunrpc/rpcb_clnt.c */
 	.set_port		= xprt_rdma_set_port,
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 732d4b57411a..b4b4b8db143c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2690,7 +2690,7 @@ static const struct rpc_xprt_ops xs_local_ops = {
 	.buf_free		= rpc_free,
 	.prepare_request	= xs_stream_prepare_request,
 	.send_request		= xs_local_send_request,
-	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.wait_for_reply_request	= xprt_wait_for_reply_request_def,
 	.close			= xs_close,
 	.destroy		= xs_destroy,
 	.print_stats		= xs_local_print_stats,
@@ -2710,7 +2710,7 @@ static const struct rpc_xprt_ops xs_udp_ops = {
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
 	.send_request		= xs_udp_send_request,
-	.set_retrans_timeout	= xprt_set_retrans_timeout_rtt,
+	.wait_for_reply_request	= xprt_wait_for_reply_request_rtt,
 	.timer			= xs_udp_timer,
 	.release_request	= xprt_release_rqst_cong,
 	.close			= xs_close,
@@ -2733,7 +2733,7 @@ static const struct rpc_xprt_ops xs_tcp_ops = {
 	.buf_free		= rpc_free,
 	.prepare_request	= xs_stream_prepare_request,
 	.send_request		= xs_tcp_send_request,
-	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.wait_for_reply_request	= xprt_wait_for_reply_request_def,
 	.close			= xs_tcp_shutdown,
 	.destroy		= xs_destroy,
 	.set_connect_timeout	= xs_tcp_set_connect_timeout,
@@ -2761,7 +2761,7 @@ static const struct rpc_xprt_ops bc_tcp_ops = {
 	.buf_alloc		= bc_malloc,
 	.buf_free		= bc_free,
 	.send_request		= bc_send_request,
-	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
+	.wait_for_reply_request	= xprt_wait_for_reply_request_def,
 	.close			= bc_close,
 	.destroy		= bc_destroy,
 	.print_stats		= xs_tcp_print_stats,
-- 
2.20.1

