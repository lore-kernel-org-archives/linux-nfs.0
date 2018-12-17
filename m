Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2A5FC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 686742133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JxZMAmv1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388304AbeLQQkt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:49 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:39123 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388281AbeLQQkt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:49 -0500
Received: by mail-it1-f194.google.com with SMTP id a6so20902249itl.4;
        Mon, 17 Dec 2018 08:40:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=M1mWnOW+fmqs0BSG3OSh1UH3OsQGfVQFafkL8QUXdiM=;
        b=JxZMAmv1dqBUioP2OqjdhuS5yenJUSosGsiVSm0d4CiKz6rx7rXtFNZioJc2kKRXIV
         GX2PJ5/obI2RDE4UyUFDm6EMKXip3noX4ai9Q74jSx6iyj+HhYFmDqaDiwMZ2+bU4kMb
         o7DqEErmsv8kHxLaD00zR1O4GDFYCnWNbHlukgpnW+gzqTFcw/+3VSytisxfFz/0NkjJ
         bKOvCrIxiIieWv+wil616MY9DgKmsbzyrJBykR8krpc3k+mAvaD4g3ZuP5oWiRQmLP1c
         hUuLmMJHiaVIzwFCe4o+FUHe3FdhvxfzzYj4NvOacW9z657ulYVdifc69d3ldRpBl3xo
         9f4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=M1mWnOW+fmqs0BSG3OSh1UH3OsQGfVQFafkL8QUXdiM=;
        b=ByD8aS8syDUGeltdCikzoVJSavT9XFtuS11gyYUHsvXw1CbfQtKSm036uXXMAHmEe4
         uzW1lwYLF9aQ0HuGDHBzZ92x6TI4Lb5ypWUzeqLtrXc6uJg1MXwjFIzNq9Ufi0PRyT2n
         uCbF97XtMf3pgY49/4jCZnv/VUD7a2K9d//mNyCNDKEvA4s++d1nG2HMcakfXW13dTi8
         TATswBKktLeoYWMdn+j8Q6c3vEQcn6GUF9UTJf416xDxL/kzqfIbo7cccYQ0Rot/XaKi
         SzaoZe3nxzhaxKR6RnbNp6oSntN9eMNdnLp/UFwAJRqOoKJfiv6K2w6wZuoy8b9SyJCN
         Q0lA==
X-Gm-Message-State: AA+aEWbILE2oF2xlhQio1bdjvovuohYyxZkN3RRXImRXEmFVyr0lgOzP
        S1DF109pDY+yF9VIXZMa7TRpU8w1
X-Google-Smtp-Source: AFSGD/XAN6O+VaouR+WaaSVJnD+pidO35m+xVfEjRl+Om6Pm9SGkJK1Oei3CvJ9hWbV83YgyUqZPFg==
X-Received: by 2002:a24:1490:: with SMTP id 138mr14813325itg.101.1545064848459;
        Mon, 17 Dec 2018 08:40:48 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w129sm77140ita.0.2018.12.17.08.40.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:47 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGekvh018626;
        Mon, 17 Dec 2018 16:40:46 GMT
Subject: [PATCH v4 16/30] xprtrdma: Simplify locking that protects the
 rl_allreqs list
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:46 -0500
Message-ID: <20181217164046.24133.73626.stgit@manet.1015granger.net>
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

Clean up: There's little chance of contention between the use of
rb_lock and rb_reqslock, so merge the two. This avoids having to
take both in some (possibly future) cases.

Transport tear-down is already serialized, thus there is no need for
locking at all when destroying rpcrdma_reqs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c |   20 +++-----------------
 net/sunrpc/xprtrdma/verbs.c       |   31 +++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h   |    7 +++----
 3 files changed, 23 insertions(+), 35 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 9cb96a5..af8249b 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -19,29 +19,16 @@
 
 #undef RPCRDMA_BACKCHANNEL_DEBUG
 
-static void rpcrdma_bc_free_rqst(struct rpcrdma_xprt *r_xprt,
-				 struct rpc_rqst *rqst)
-{
-	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
-	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
-
-	spin_lock(&buf->rb_reqslock);
-	list_del(&req->rl_all);
-	spin_unlock(&buf->rb_reqslock);
-
-	rpcrdma_destroy_req(req);
-}
-
 static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 				 unsigned int count)
 {
 	struct rpc_xprt *xprt = &r_xprt->rx_xprt;
+	struct rpcrdma_req *req;
 	struct rpc_rqst *rqst;
 	unsigned int i;
 
 	for (i = 0; i < (count << 1); i++) {
 		struct rpcrdma_regbuf *rb;
-		struct rpcrdma_req *req;
 		size_t size;
 
 		req = rpcrdma_create_req(r_xprt);
@@ -67,7 +54,7 @@ static int rpcrdma_bc_setup_reqs(struct rpcrdma_xprt *r_xprt,
 	return 0;
 
 out_fail:
-	rpcrdma_bc_free_rqst(r_xprt, rqst);
+	rpcrdma_req_destroy(req);
 	return -ENOMEM;
 }
 
@@ -225,7 +212,6 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
  */
 void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
 {
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpc_rqst *rqst, *tmp;
 
 	spin_lock(&xprt->bc_pa_lock);
@@ -233,7 +219,7 @@ void xprt_rdma_bc_destroy(struct rpc_xprt *xprt, unsigned int reqs)
 		list_del(&rqst->rq_bc_pa_list);
 		spin_unlock(&xprt->bc_pa_lock);
 
-		rpcrdma_bc_free_rqst(r_xprt, rqst);
+		rpcrdma_req_destroy(rpcr_to_rdmar(rqst));
 
 		spin_lock(&xprt->bc_pa_lock);
 	}
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index d68efaf..a6ab216 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1043,9 +1043,9 @@ struct rpcrdma_req *
 	req->rl_buffer = buffer;
 	INIT_LIST_HEAD(&req->rl_registered);
 
-	spin_lock(&buffer->rb_reqslock);
+	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
-	spin_unlock(&buffer->rb_reqslock);
+	spin_unlock(&buffer->rb_lock);
 	return req;
 }
 
@@ -1113,7 +1113,6 @@ struct rpcrdma_req *
 
 	INIT_LIST_HEAD(&buf->rb_send_bufs);
 	INIT_LIST_HEAD(&buf->rb_allreqs);
-	spin_lock_init(&buf->rb_reqslock);
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
 
@@ -1154,9 +1153,18 @@ struct rpcrdma_req *
 	kfree(rep);
 }
 
+/**
+ * rpcrdma_req_destroy - Destroy an rpcrdma_req object
+ * @req: unused object to be destroyed
+ *
+ * This function assumes that the caller prevents concurrent device
+ * unload and transport tear-down.
+ */
 void
-rpcrdma_destroy_req(struct rpcrdma_req *req)
+rpcrdma_req_destroy(struct rpcrdma_req *req)
 {
+	list_del(&req->rl_all);
+
 	rpcrdma_free_regbuf(req->rl_recvbuf);
 	rpcrdma_free_regbuf(req->rl_sendbuf);
 	rpcrdma_free_regbuf(req->rl_rdmabuf);
@@ -1214,19 +1222,14 @@ struct rpcrdma_req *
 		rpcrdma_destroy_rep(rep);
 	}
 
-	spin_lock(&buf->rb_reqslock);
-	while (!list_empty(&buf->rb_allreqs)) {
+	while (!list_empty(&buf->rb_send_bufs)) {
 		struct rpcrdma_req *req;
 
-		req = list_first_entry(&buf->rb_allreqs,
-				       struct rpcrdma_req, rl_all);
-		list_del(&req->rl_all);
-
-		spin_unlock(&buf->rb_reqslock);
-		rpcrdma_destroy_req(req);
-		spin_lock(&buf->rb_reqslock);
+		req = list_first_entry(&buf->rb_send_bufs,
+				       struct rpcrdma_req, rl_list);
+		list_del(&req->rl_list);
+		rpcrdma_req_destroy(req);
 	}
-	spin_unlock(&buf->rb_reqslock);
 
 	rpcrdma_mrs_destroy(buf);
 }
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 56b299f..6e104cd 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -392,14 +392,13 @@ struct rpcrdma_buffer {
 	spinlock_t		rb_lock;	/* protect buf lists */
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
+	struct list_head	rb_allreqs;
+
 	unsigned long		rb_flags;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
 
 	u32			rb_bc_srv_max_requests;
-	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
-	struct list_head	rb_allreqs;
-
 	u32			rb_bc_max_requests;
 
 	struct workqueue_struct *rb_completion_wq;
@@ -522,7 +521,7 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
  * Buffer calls - xprtrdma/verbs.c
  */
 struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
-void rpcrdma_destroy_req(struct rpcrdma_req *);
+void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);

