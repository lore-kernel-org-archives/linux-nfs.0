Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60DFEC43381
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 30FDD2087C
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 15:18:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="V/Z3Nbx4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728481AbfCEPSe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 10:18:34 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:40943 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727114AbfCEPSe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2019 10:18:34 -0500
Received: by mail-it1-f193.google.com with SMTP id l139so4978050ita.5
        for <linux-nfs@vger.kernel.org>; Tue, 05 Mar 2019 07:18:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=BYsqryolyjzRCd67B0Kt2dHBgB8sofnU9RITB2T3s2w=;
        b=V/Z3Nbx4kjjwTpuJ1T6FDO7b8oAv8c3KWQRtMq7ejmgvpKR8hBH04GBOIuXH2NmADN
         aExngd7qAh/fxmvhJwb76BPFKM3dg49QsxfWRi4iMdSpAhEJBH/IZFQQQs3LC3EadxyV
         vlUFL1NGPMHf7oKL9yGUL7/mf20+UMdh6U6ksudAMJjOpi6oVyDZA9TtXcRmHG5mvfP8
         ZzAGv1eaVgi6xhl5KcT9gqBuJQA7BzOr/IrX3ujRkJPQ+IHY93eOmWoJQI6aQRierTG2
         GLE06YFnoiQ9dkPDfROulf4wscBYVCx9+Pz6t55oS5eCk/hw50tck/P6+5AP7MkXMHdZ
         5EeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=BYsqryolyjzRCd67B0Kt2dHBgB8sofnU9RITB2T3s2w=;
        b=pnxMeeaNySNzs2F4syW34Py9olbhkZJTf1V/jSnAqTuTbEDUozLlgGT8my3CIFTug2
         dyWjShtalx50JiQpoENLQ122SIqTjMVQ0c5JxE17XRw376Kg5lE5ZLGVJpzsFSA2B4Dh
         oHOnyzbZFPuy/FismCcPUr2SkJSgUSlFTNcN9kHF3OMH5hzXX/MnMHD45eSp0hwcm3w9
         8tV2EQ3Yd7lZWUaJoK5P3jULOrC7BJNg8IUB4urG8q28UFpWY5XKBPufn5qCDvLjqjSo
         RtUHLvgAYFTWKkYSR8lzt5I1xWwlx3jCnj6OWfxAZQEsGooZ/M2inFDnyjG4PMewYGk5
         J8Ag==
X-Gm-Message-State: APjAAAUQOzEH1KL+o8VGpZ/rZbE65f3Bt9qYYWhv4nJ+rdSTQyJ8V2cl
        26qtoiR9niRNa1WcQaUuLF+RJGg=
X-Google-Smtp-Source: APXvYqzTXwID//FLg0bZDgmS0+Oaq1xkRQfuBlJ450Vq/hDfq8kKcloIrxcpmVPvXOvyELsYQN+qiQ==
X-Received: by 2002:a24:c486:: with SMTP id v128mr3014089itf.138.1551799112166;
        Tue, 05 Mar 2019 07:18:32 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id 10sm5003935itv.10.2019.03.05.07.18.31
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 07:18:31 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/3] SUNRPC: Fix up RPC back channel transmission
Date:   Tue,  5 Mar 2019 10:17:21 -0500
Message-Id: <20190305151722.45732-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190305151722.45732-1-trond.myklebust@hammerspace.com>
References: <20190305151722.45732-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that transmissions happen through a queue, we require the RPC tasks
to handle error conditions that may have been set while they were
sleeping. The back channel does not currently do this, but assumes
that any error condition happens during its own call to xprt_transmit().

The solution is to ensure that the back channel splits out the
error handling just like the forward channel does.

Fixes: 89f90fe1ad8b ("SUNRPC: Allow calls to xprt_transmit() to drain...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 64 +++++++++++++++++++++++++++--------------------
 1 file changed, 37 insertions(+), 27 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e7ae75a045c9..c154684a35d4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -66,9 +66,6 @@ static void	call_decode(struct rpc_task *task);
 static void	call_bind(struct rpc_task *task);
 static void	call_bind_status(struct rpc_task *task);
 static void	call_transmit(struct rpc_task *task);
-#if defined(CONFIG_SUNRPC_BACKCHANNEL)
-static void	call_bc_transmit(struct rpc_task *task);
-#endif /* CONFIG_SUNRPC_BACKCHANNEL */
 static void	call_status(struct rpc_task *task);
 static void	call_transmit_status(struct rpc_task *task);
 static void	call_refresh(struct rpc_task *task);
@@ -1133,6 +1130,8 @@ rpc_call_async(struct rpc_clnt *clnt, const struct rpc_message *msg, int flags,
 EXPORT_SYMBOL_GPL(rpc_call_async);
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static void call_bc_encode(struct rpc_task *task);
+
 /**
  * rpc_run_bc_task - Allocate a new RPC task for backchannel use, then run
  * rpc_execute against it
@@ -1154,7 +1153,7 @@ struct rpc_task *rpc_run_bc_task(struct rpc_rqst *req)
 	task = rpc_new_task(&task_setup_data);
 	xprt_init_bc_request(req, task);
 
-	task->tk_action = call_bc_transmit;
+	task->tk_action = call_bc_encode;
 	atomic_inc(&task->tk_count);
 	WARN_ON_ONCE(atomic_read(&task->tk_count) != 2);
 	rpc_execute(task);
@@ -2078,6 +2077,16 @@ call_transmit_status(struct rpc_task *task)
 }
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
+static void call_bc_transmit(struct rpc_task *task);
+static void call_bc_transmit_status(struct rpc_task *task);
+
+static void
+call_bc_encode(struct rpc_task *task)
+{
+	xprt_request_enqueue_transmit(task);
+	task->tk_action = call_bc_transmit;
+}
+
 /*
  * 5b.	Send the backchannel RPC reply.  On error, drop the reply.  In
  * addition, disconnect on connectivity errors.
@@ -2085,26 +2094,29 @@ call_transmit_status(struct rpc_task *task)
 static void
 call_bc_transmit(struct rpc_task *task)
 {
-	struct rpc_rqst *req = task->tk_rqstp;
-
-	if (rpc_task_need_encode(task))
-		xprt_request_enqueue_transmit(task);
-	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate))
-		goto out_wakeup;
-
-	if (!xprt_prepare_transmit(task))
-		goto out_retry;
+	task->tk_status = 0;
 
-	if (task->tk_status < 0) {
-		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
-			"error: %d\n", task->tk_status);
-		goto out_done;
+	if (test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		if (!xprt_prepare_transmit(task))
+			return;
+		if (!xprt_connected(task->tk_xprt) ||
+		    !xprt_bound(task->tk_xprt)) {
+			rpc_exit(task, -ENOTCONN);
+			return;
+		}
+		xprt_transmit(task);
 	}
+	task->tk_action = call_bc_transmit_status;
+	xprt_end_transmit(task);
+}
 
-	xprt_transmit(task);
+static void
+call_bc_transmit_status(struct rpc_task *task)
+{
+	struct rpc_rqst *req = task->tk_rqstp;
 
-	xprt_end_transmit(task);
 	dprint_status(task);
+
 	switch (task->tk_status) {
 	case 0:
 		/* Success */
@@ -2118,8 +2130,13 @@ call_bc_transmit(struct rpc_task *task)
 	case -ENOTCONN:
 	case -EPIPE:
 		break;
+	case -ENOBUFS:
+		rpc_delay(task, HZ>>2);
+		/* fall through */
+	case -EBADSLT:
 	case -EAGAIN:
-		goto out_retry;
+		task->tk_action = call_bc_transmit;
+		return;
 	case -ETIMEDOUT:
 		/*
 		 * Problem reaching the server.  Disconnect and let the
@@ -2138,18 +2155,11 @@ call_bc_transmit(struct rpc_task *task)
 		 * We were unable to reply and will have to drop the
 		 * request.  The server should reconnect and retransmit.
 		 */
-		WARN_ON_ONCE(task->tk_status == -EAGAIN);
 		printk(KERN_NOTICE "RPC: Could not send backchannel reply "
 			"error: %d\n", task->tk_status);
 		break;
 	}
-out_wakeup:
-	rpc_wake_up_queued_task(&req->rq_xprt->pending, task);
-out_done:
 	task->tk_action = rpc_exit_task;
-	return;
-out_retry:
-	task->tk_status = 0;
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-- 
2.20.1

