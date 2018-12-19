Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4061CC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 06B09217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tj60Zpjy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729154AbeLSP7h (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:37 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:53286 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727975AbeLSP7g (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:36 -0500
Received: by mail-it1-f193.google.com with SMTP id g85so10381619ita.3;
        Wed, 19 Dec 2018 07:59:35 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ot8YrCAOClaLZEB8d+4BtlkkZuUxk/YFO4keDzT+mbg=;
        b=tj60ZpjyGtNrcTTzC8iLjMi+OicBzp+H9ovzv9VC6/BkP1ucyCzMf6uVcwv31mxLdX
         kNUKyDsp1e/fGyAicko3NNX4nOwTfG6MQzRox7zN6LK0/Arp8tLV/ZpQm8PBnWI+3BUt
         wxoqHlCMh7XJDA3+G5Hf6sS+cVtMUcbdcqAMZRKaYA01RtywjtsbxN6G1xysL1x7QYzK
         oMu0XEH3B4EAsrSPmcBxio9a50TuFhcKPQ7Y40JsoPKlj6bDz1i3BzovBLhzPUAhZpGV
         1tlueA1CuT81tcLsV9FFeQwrgzeHtDouqtccaSHg9plZcmuRkk+hh63oN7QhXjs9J59Y
         rGHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ot8YrCAOClaLZEB8d+4BtlkkZuUxk/YFO4keDzT+mbg=;
        b=i/v6CYbjn1uSsD9blhiYPBCxY6a/su3+fmG3CYA8Va150SNhNob7YtPpkuxCv/uzH7
         QJzh52o1o5OXv5scDJ1be+BJiABOoA/eOYRRqoHtmgtCji02/5il6fasKQBM8Gt+4EPz
         ySOh32ohv/9SEbdCALjrwJjqCps9VQlCGC07Ar+HeKJy6xbInW5fw1jUBWhkQgIDpICt
         9gnYHFTcqeT+gPYonL5Om+lXciadhAiOxkLl5+Ln4PF9ruN4u9DbOQY++9H9eAt/98Yo
         TucAMlFP16cJHEPLTTtl2UFML1YlLS6wg4r52CPv4UtPiSjfPscjdCLnvIG10F5G969k
         uiDA==
X-Gm-Message-State: AA+aEWZNpPnb4DkY3vBcpT5hjAgHQ6opG4Fkz1HMMB4159/LFpEOMe5b
        O0dOYEQ9pC6BmFiVxomE5H4=
X-Google-Smtp-Source: AFSGD/VRIlkcBK25ROWwWzZ8nzWLnaYSL3KcoO9BYRZoYNVgLMeiWupAD04zM7MOo4iJmqLSKSJlGw==
X-Received: by 2002:a24:ed4f:: with SMTP id r76mr6582889ith.17.1545235175484;
        Wed, 19 Dec 2018 07:59:35 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b188sm3644690itc.9.2018.12.19.07.59.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:34 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxXLW025804;
        Wed, 19 Dec 2018 15:59:33 GMT
Subject: [PATCH v5 16/30] xprtrdma: Simplify locking that protects the
 rl_allreqs list
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:33 -0500
Message-ID: <20181219155933.11602.86521.stgit@manet.1015granger.net>
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
index e2704db..aae2eb1 100644
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
index 0cce7b2..51e09ae1 100644
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
index ff4eab1..a1cdc85 100644
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

