Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A1C0C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2C82E205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="grbV2fBR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C82E205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727212AbeK0HBw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:52 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54238 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:52 -0500
Received: by mail-it1-f195.google.com with SMTP id g85so30391324ita.3;
        Mon, 26 Nov 2018 12:06:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=eTVYu/Xxr0GxepgHJmgZhIooXljE1VWh1s8dYV+il1s=;
        b=grbV2fBRnY+YObJXaxKcZTH8+rpzDDS6OrPJmYFV4M4/qr/J0s9K6Cx5u3K9l15TzO
         XphCCbsnhnsQXlOts7AOUelOIZ+Q3Lt08USCfrP62qXA+Cgo5jpJDt4LodzcWyWrrncl
         qROv46jn3vJMpdi0/3wfgTeTyJ2vIsBpvl/UufPzXV1RanuxXaBAEy1DjJhoXocPNteV
         tD1eh3QgEIdXYvaovtTo8q51TrJKJcYXYxypb0h1tIvHJHnaFY1fTcgdiTbbPXwWGnxD
         KW+BNpjHBbUk1rSWmaBgCa/oER3mc1LtIqMx0t6g7iZYbDN+NITcraRulcXYNJBcB+VY
         SHmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=eTVYu/Xxr0GxepgHJmgZhIooXljE1VWh1s8dYV+il1s=;
        b=Fu4109MLR81JzXwmlQX5NTwRl54eCBgsY07MeIuUvevn6kbHiirXFpdhdhgNoAjp2j
         SXtbe9B9XuGTG1OpErzV6yhlFwx9v9WKBi7+rcE/VfIY8ymY4XEPNBwDTOwwdNVv4zTP
         X55r0aZyN+YZmjYhQy1LsCGIIUzMQSiqV4stF+euQfO0vei8M1CC9r32aqzHHNS3sB2m
         8esob1UImuDx5HD8nfIDPykiLi4LauZw8CG6GzKoAFdffOgUdG+jFcCunYW9K3f7O9/A
         SOdctX9FhlNimaEtk3YwiA6V8Tud+d3WS/CKBO30CknlaC8HuzyzBjnJuUiS15eSt9sj
         M+kA==
X-Gm-Message-State: AA+aEWZGVJdBDLwjvKh1oiymZLHiIEP1OJF+PTumKs8gQD9vvto2I91B
        CqAotnAM2MpBjer0VBn2Nu83O4js
X-Google-Smtp-Source: AFSGD/WiHrMavPM83z3MBWi27txFF0lSJH/nseM9TUnFhViG+U+2kdBdVwhKoSP54kkvarmK+Gck7w==
X-Received: by 2002:a24:1c04:: with SMTP id c4mr17056586itc.79.1543262797354;
        Mon, 26 Nov 2018 12:06:37 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 137sm1305467itm.21.2018.11.26.12.06.36
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:36 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6Ztt010669;
        Mon, 26 Nov 2018 20:06:35 GMT
Subject: [PATCH v2 09/20] xprtrdma: Simplify locking that protects the
 rl_allreqs list
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:35 -0500
Message-ID: <20181126200635.10321.86177.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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
take both in some cases.

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

