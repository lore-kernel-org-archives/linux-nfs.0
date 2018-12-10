Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 820DFC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 398132082F
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:30:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FsAyLksK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 398132082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728371AbeLJQaP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:30:15 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:41392 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728359AbeLJQaP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:30:15 -0500
Received: by mail-io1-f65.google.com with SMTP id s22so9220525ioc.8;
        Mon, 10 Dec 2018 08:30:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=cI24Dx+mo2YC+SYEjUTWn8lGg46X/mJOMj583KufF/s=;
        b=FsAyLksKc+M+rrewu7D34tfPI+KBSkpNEpwDmuDKu/iacXd93rwUX0lKegyunGUQwq
         TeIoM7wHjGUumXdooXKYiZ2EhbQ1WpLrMsrCXr4d0S+BNE1fHfnrCtp/vDCtZ/Ll/IAB
         GqfBSM3mkTKKN0Lwt6oRIFsCYBlARAXvxNxNiPLDchqsRz3rewU/USU8L0MSkWCHuBKH
         WMjS1IfrJY/9dLuthY14epTBC9cd4m1Xlkcr2fUYvrTKaICdbN19NFlc5V7i/gP5zKho
         DUPUXCKc5uOuQyhOqH/pufPUajWJZ08I61KMy7OcQrQrpFTwFHhoYX60N0anaFPwlNfy
         HYww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=cI24Dx+mo2YC+SYEjUTWn8lGg46X/mJOMj583KufF/s=;
        b=fWOmS3nIbW8C1CiJeMkIGTtvQV2S/aWwHQiMI1UVlbi1jNgdQWSwd0wr/RBwIzNNFE
         pKDOeiseWZ3+7R5fO6EkfKIKoRiWR0+D3GnUYd7MTsi+ALUWEWmuPmkIL0QL4/9Et3eF
         3fWUF4YmjkhXd0ofHsrzCNWbrCHZekr6s2/mDHpcSw7uSlM2+9B9S2wUOtlHxpRsp3Rq
         s+fHADUL0wIcS0Xr1HIPfPrjpa7Is4CtJGfV0J1JbI1BWSn9Y8/ofF2qQ2yLCtpMdI+2
         cpKcDpi/qBLn+LoOnSf/0Hp2chWO35qFRb3wOplKwua9vo3JOyfkImtnDC0wMmBDUeAu
         IRAg==
X-Gm-Message-State: AA+aEWaj29F34wLuXFeHkStnGvuCAm92ZyfbPZ8jbsuC2u9vhUrvAEzx
        BfRHXxpYkDr1zYzyu9NVAw7sScf+
X-Google-Smtp-Source: AFSGD/XABBqutqt3MQWV+AfHK2ilft7qwqRtXdj2KbABGNqpaydSAn/g/hAleERGQTKdPRo96/kovg==
X-Received: by 2002:a5d:9717:: with SMTP id h23mr9574422iol.3.1544459413845;
        Mon, 10 Dec 2018 08:30:13 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k26sm1385882ior.10.2018.12.10.08.30.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:30:13 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGUCWd031052;
        Mon, 10 Dec 2018 16:30:12 GMT
Subject: [PATCH v3 10/24] xprtrdma: Simplify locking that protects the
 rl_allreqs list
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:30:12 -0500
Message-ID: <20181210163012.4198.33197.stgit@manet.1015granger.net>
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
index e31cf26..41d263c 100644
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
index a8d4def..bd6bc45 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1083,9 +1083,9 @@ struct rpcrdma_req *
 	req->rl_buffer = buffer;
 	INIT_LIST_HEAD(&req->rl_registered);
 
-	spin_lock(&buffer->rb_reqslock);
+	spin_lock(&buffer->rb_lock);
 	list_add(&req->rl_all, &buffer->rb_allreqs);
-	spin_unlock(&buffer->rb_reqslock);
+	spin_unlock(&buffer->rb_lock);
 	return req;
 }
 
@@ -1153,7 +1153,6 @@ struct rpcrdma_req *
 
 	INIT_LIST_HEAD(&buf->rb_send_bufs);
 	INIT_LIST_HEAD(&buf->rb_allreqs);
-	spin_lock_init(&buf->rb_reqslock);
 	for (i = 0; i < buf->rb_max_requests; i++) {
 		struct rpcrdma_req *req;
 
@@ -1188,9 +1187,18 @@ struct rpcrdma_req *
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
@@ -1244,19 +1252,14 @@ struct rpcrdma_req *
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
index 2ae1ee2..e1c6235 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -401,15 +401,14 @@ struct rpcrdma_buffer {
 	spinlock_t		rb_lock;	/* protect buf lists */
 	struct list_head	rb_send_bufs;
 	struct list_head	rb_recv_bufs;
+	struct list_head	rb_allreqs;
+
 	unsigned long		rb_flags;
 	u32			rb_max_requests;
 	u32			rb_credits;	/* most recent credit grant */
 	int			rb_posted_receives;
 
 	u32			rb_bc_srv_max_requests;
-	spinlock_t		rb_reqslock;	/* protect rb_allreqs */
-	struct list_head	rb_allreqs;
-
 	u32			rb_bc_max_requests;
 
 	struct delayed_work	rb_refresh_worker;
@@ -566,7 +565,7 @@ int rpcrdma_ep_post(struct rpcrdma_ia *, struct rpcrdma_ep *,
  * Buffer calls - xprtrdma/verbs.c
  */
 struct rpcrdma_req *rpcrdma_create_req(struct rpcrdma_xprt *);
-void rpcrdma_destroy_req(struct rpcrdma_req *);
+void rpcrdma_req_destroy(struct rpcrdma_req *req);
 int rpcrdma_buffer_create(struct rpcrdma_xprt *);
 void rpcrdma_buffer_destroy(struct rpcrdma_buffer *);
 struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf);

