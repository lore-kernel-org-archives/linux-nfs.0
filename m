Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41A2EC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 04EA12075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l1GY/TnI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726562AbfDJUGu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:06:50 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:52190 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726014AbfDJUGu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:06:50 -0400
Received: by mail-it1-f193.google.com with SMTP id s3so5671857itk.1;
        Wed, 10 Apr 2019 13:06:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=m7NXN2c2pOBHvG5aFASXO5TvWnrfQ3QDrgZZY3q8jg8=;
        b=l1GY/TnII7gROfD2Op4V1rZmIURhX9HXbk/DaLsEEMygqEYjLvSaLoSCz95LbtURbi
         YNZIhszsDoIwPyHi7sMaSZgG/RuON4Tn3W5jj9udVZ3ZoFjTYlXxD9lNtt3versGOLvf
         Kk8DTN1zS3HhUh0dHFQmccNZyooPxMsM1Blz/4fPe3ZLhm1OK/8K2P2CNJfy5OzDjMWF
         VVUTGqtC3DePbnAcC8lhLTIYB16ZSjmpW7XL21Zx9/ABdnSy6Ly8QfHlNBGgP6h3fkZv
         MQfuAfnSbo1dCA7Xz8su6TeMDlgFY4xL6tr0MMbE9gJiq//H+UjG5TgDDperABkxba6C
         4lSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=m7NXN2c2pOBHvG5aFASXO5TvWnrfQ3QDrgZZY3q8jg8=;
        b=LLefznb7GEtFDBP+ukOhFYmvlPjjqtYAjLWADIKOmS/ER+KE0M/gFOqNzUUYD5575T
         SGDM50ufumMH3EqIO99Be7y+PpHp88bCaOtBu79sgYII+kcAQ4dv11obb5RmH8hHzyUm
         xIeLr0/bgB9YdOuzdrDcQVBtLqIsJ3pMRVDPme3a2tUtQfW9OmiQ0F3XZaugaXy/U5xZ
         oMbUMUHFHAas1mhZ+sHhHe96hrl/ktL17Wb9mQmZBJ8uQ0NjXNRT6vooi7NT4wacw2CI
         kYSakLo++rNsfHB+s6BrzPpDoJ/gKN5i6H3vraFSJQ9hFUQeedFv7LtkPRY3oZcJafl9
         0e4g==
X-Gm-Message-State: APjAAAWfiPX45Dw7b8RnErzOnBrp7WQv8Y0mG3hMDO4EG25o/N8Su0zw
        YV1luK5rAQ5gVXdbA1rircB1nI3L
X-Google-Smtp-Source: APXvYqxpJF+437Jsh3Fq79igvIrVK2Y//Q2xGttBWpI41Ff2pD3bWZhJTr7Onv2DB+s4gOfoaRrEAg==
X-Received: by 2002:a24:738f:: with SMTP id y137mr4852600itb.133.1554926808995;
        Wed, 10 Apr 2019 13:06:48 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id x79sm1555720ita.17.2019.04.10.13.06.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:48 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6lBr004513;
        Wed, 10 Apr 2019 20:06:47 GMT
Subject: [PATCH v1 03/19] xprtrdma: Defer completion only when local
 invalidation is needed
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:47 -0400
Message-ID: <20190410200647.11522.29484.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While looking at another issue, I noticed that deferred completion
happens to run on the same CPU as Receive completion, thanks to the
fact that the deferred completion workqueue is BOUND. That suggests
there's really no benefit to deferring completion unless it will
have to context switch while waiting for LocalInv to complete.

A somewhat non-intuitive side benefit of this change is that there
are fewer waits for Send completions. Now that this wait is always
done in the Reply handler (a single process) it serializes
subsequent replies. Send completions are batched, so waiting for one
Send completion means waiting for all outstanding Send completions
at once. When the Reply handler gets to subsequent replies, waiting
(and the context switch that goes with it) is less likely to be
needed.

Measurements of IOPS throughput without deferred completion show
improvement of several percent, and latency is just as good or
slightly better for 4KB 100% read and 8KB 70% read / 30% write.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c  |   31 +++++++++++++++++++++++++------
 net/sunrpc/xprtrdma/verbs.c     |    8 ++++----
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 -
 3 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index b759b16..c3bd18a 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1226,7 +1226,7 @@ static int decode_reply_chunk(struct xdr_stream *xdr, u32 *length)
  * RPC completion while holding the transport lock to ensure
  * the rep, rqst, and rq_task pointers remain stable.
  */
-void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
+static void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 {
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
@@ -1268,6 +1268,12 @@ void rpcrdma_complete_rqst(struct rpcrdma_rep *rep)
 	goto out;
 }
 
+/**
+ * rpcrdma_release_rqst - Release hardware resources
+ * @r_xprt: controlling transport
+ * @req: request with resources to release
+ *
+ */
 void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 {
 	/* Invalidate and unmap the data payloads before waking
@@ -1295,7 +1301,11 @@ void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt, struct rpcrdma_req *req)
 	}
 }
 
-/* Reply handling runs in the poll worker thread. Anything that
+/**
+ * rpcrdma_deferred_completion
+ * @work: work struct embedded in an rpcrdma_rep
+ *
+ * Reply handling runs in the poll worker thread. Anything that
  * might wait is deferred to a separate workqueue.
  */
 void rpcrdma_deferred_completion(struct work_struct *work)
@@ -1306,13 +1316,14 @@ void rpcrdma_deferred_completion(struct work_struct *work)
 	struct rpcrdma_xprt *r_xprt = rep->rr_rxprt;
 
 	trace_xprtrdma_defer_cmp(rep);
-	if (rep->rr_wc_flags & IB_WC_WITH_INVALIDATE)
-		frwr_reminv(rep, &req->rl_registered);
+
 	rpcrdma_release_rqst(r_xprt, req);
 	rpcrdma_complete_rqst(rep);
 }
 
-/* Process received RPC/RDMA messages.
+/**
+ * rpcrdma_reply_handler - Process received RPC/RDMA messages
+ * @rep: Incoming rpcrdma_rep object to process
  *
  * Errors must result in the RPC task either being awakened, or
  * allowed to timeout, to discover the errors at that time.
@@ -1375,7 +1386,15 @@ void rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 	clear_bit(RPCRDMA_REQ_F_PENDING, &req->rl_flags);
 
 	trace_xprtrdma_reply(rqst->rq_task, rep, req, credits);
-	queue_work(buf->rb_completion_wq, &rep->rr_work);
+
+	if (rep->rr_wc_flags & IB_WC_WITH_INVALIDATE)
+		frwr_reminv(rep, &req->rl_registered);
+	if (!list_empty(&req->rl_registered)) {
+		queue_work(buf->rb_completion_wq, &rep->rr_work);
+	} else {
+		rpcrdma_release_rqst(r_xprt, req);
+		rpcrdma_complete_rqst(rep);
+	}
 	return;
 
 out_badversion:
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 30cfc0e..fe005c6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1106,10 +1106,10 @@ struct rpcrdma_req *
 	if (rc)
 		goto out;
 
-	buf->rb_completion_wq = alloc_workqueue("rpcrdma-%s",
-						WQ_MEM_RECLAIM | WQ_HIGHPRI,
-						0,
-			r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
+	buf->rb_completion_wq =
+		alloc_workqueue("rpcrdma-%s",
+				WQ_MEM_RECLAIM | WQ_HIGHPRI | WQ_UNBOUND, 0,
+				r_xprt->rx_xprt.address_strings[RPC_DISPLAY_ADDR]);
 	if (!buf->rb_completion_wq) {
 		rc = -ENOMEM;
 		goto out;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 10f6593..6a49597 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -613,7 +613,6 @@ int rpcrdma_prepare_send_sges(struct rpcrdma_xprt *r_xprt,
 void rpcrdma_unmap_sendctx(struct rpcrdma_sendctx *sc);
 int rpcrdma_marshal_req(struct rpcrdma_xprt *r_xprt, struct rpc_rqst *rqst);
 void rpcrdma_set_max_header_sizes(struct rpcrdma_xprt *);
-void rpcrdma_complete_rqst(struct rpcrdma_rep *rep);
 void rpcrdma_reply_handler(struct rpcrdma_rep *rep);
 void rpcrdma_release_rqst(struct rpcrdma_xprt *r_xprt,
 			  struct rpcrdma_req *req);

