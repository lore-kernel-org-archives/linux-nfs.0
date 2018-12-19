Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37A60C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F2A7F217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:58:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VwUqk9nR"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729370AbeLSP6o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:58:44 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37434 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP6o (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:58:44 -0500
Received: by mail-it1-f194.google.com with SMTP id b5so10048822iti.2;
        Wed, 19 Dec 2018 07:58:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=aGyQWJVJ75JWH0t61EgFa3A/spEXQp3kHqveaGDMMpI=;
        b=VwUqk9nRg3BN9pPawD4Md46hpE8zlyH7/LSD7rF68+A14Sut9IiCnTrRSL7GqZh5oV
         rLcCiyzn93iczcvdakO3q15tT+omTUzdT/d7eX3zu2t2z6ior9S5gqSpAYeqbcYMr4ZI
         tMaydgNffNVVZ1j4CH0DU9O9NXOPnXqRnLYarhu7HZFzAAqRd/U5GEFANiY9oxoEGQM+
         rvFFJPKBUEKVhrQf1is5MUXfafDw7zB6a7uwhmbdGPnm8Ybs3qiD6WQFTfvrwZo6A1YE
         c7ooyVqC49lYaUOOiVM0KN4egj4wWlkNePGd8A1tKpqPWqBu4BWTVmeRGpW0/53cV5iM
         os4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=aGyQWJVJ75JWH0t61EgFa3A/spEXQp3kHqveaGDMMpI=;
        b=gL4Nzblr7AR1FyF2R26qO2yHJdIWf93vGdraSWKfeGkbgjQsp3X49XCRajJVU+a5aG
         ZNxI9r4I+8e+oN5ld39F7zBQl/JvEM0rE1V98NaktjrckHcaUA0oPRvn0o40eI2f6+rB
         b6Qfh+4KJgiZ8QZm5m6ozhBljbaY9aQmkQDvgdwXTPTHLj6N3DG1Hnk2oZP9S3Q6CVD2
         H60JfmSzwGSwQo03ZNjMUbrGjswKzenRi+LoO76PLwOS/M1fJE5syzOy1NFH1wFo8iHd
         sH5aBamGvCAsL96wiZTgpsbDIVtc7VQdnwhBbWY+p6M3vBDa+HgX3+I+deRDeqqq6il6
         vmuQ==
X-Gm-Message-State: AA+aEWaQNVpc9KkRYwnUad7IeERFr5cjfvlSk0TqW53FZLapSdvZ3QwI
        LLhF/wBSjMoT7hlEgNJlhOVpxtOZ
X-Google-Smtp-Source: AFSGD/WLyfYU0BEglEY7Zx2Wxjxt553YeVp9PdlqFL8hXN7y3TTbaox3nDXDYYYG2WYyPw6ypCzryg==
X-Received: by 2002:a24:d997:: with SMTP id p145mr6701917itg.30.1545235121804;
        Wed, 19 Dec 2018 07:58:41 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c194sm4144777itc.3.2018.12.19.07.58.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:58:41 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFweUf025774;
        Wed, 19 Dec 2018 15:58:40 GMT
Subject: [PATCH v5 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:58:40 -0500
Message-ID: <20181219155840.11602.58228.stgit@manet.1015granger.net>
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

Transport disconnect processing does a "wake pending tasks" at
various points.

Suppose an RPC Reply is being processed. The RPC task that Reply
goes with is waiting on the pending queue. If a disconnect wake-up
happens before reply processing is done, that reply, even if it is
good, is thrown away, and the RPC has to be sent again.

This window apparently does not exist for socket transports because
there is a lock held while a reply is being received which prevents
the wake-up call until after reply processing is done.

To resolve this, all RPC replies being processed on an RPC-over-RDMA
transport have to complete before pending tasks are awoken due to a
transport disconnect.

Callers that already hold the transport write lock may invoke
->ops->close directly. Others use a generic helper that schedules
a close when the write lock can be taken safely.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/backchannel.c          |   13 +++++++------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 +++++---
 net/sunrpc/xprtrdma/transport.c            |   17 ++++++++++-------
 net/sunrpc/xprtrdma/verbs.c                |    1 -
 net/sunrpc/xprtrdma/xprt_rdma.h            |    1 +
 5 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2cb07a3..79a55fc 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -193,14 +193,15 @@ static int rpcrdma_bc_marshal_reply(struct rpc_rqst *rqst)
  */
 int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
 {
-	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(rqst->rq_xprt);
+	struct rpc_xprt *xprt = rqst->rq_xprt;
+	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_req *req = rpcr_to_rdmar(rqst);
 	int rc;
 
-	if (!xprt_connected(rqst->rq_xprt))
-		goto drop_connection;
+	if (!xprt_connected(xprt))
+		return -ENOTCONN;
 
-	if (!xprt_request_get_cong(rqst->rq_xprt, rqst))
+	if (!xprt_request_get_cong(xprt, rqst))
 		return -EBADSLT;
 
 	rc = rpcrdma_bc_marshal_reply(rqst);
@@ -215,7 +216,7 @@ int xprt_rdma_bc_send_reply(struct rpc_rqst *rqst)
 	if (rc != -ENOTCONN)
 		return rc;
 drop_connection:
-	xprt_disconnect_done(rqst->rq_xprt);
+	xprt_rdma_close(xprt);
 	return -ENOTCONN;
 }
 
@@ -338,7 +339,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 
 out_overflow:
 	pr_warn("RPC/RDMA backchannel overflow\n");
-	xprt_disconnect_done(xprt);
+	xprt_force_disconnect(xprt);
 	/* This receive buffer gets reposted automatically
 	 * when the connection is re-established.
 	 */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index f3c147d..b908f2c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -200,11 +200,10 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 		svc_rdma_send_ctxt_put(rdma, ctxt);
 		goto drop_connection;
 	}
-	return rc;
+	return 0;
 
 drop_connection:
 	dprintk("svcrdma: failed to send bc call\n");
-	xprt_disconnect_done(xprt);
 	return -ENOTCONN;
 }
 
@@ -225,8 +224,11 @@ static int svc_rdma_bc_sendto(struct svcxprt_rdma *rdma,
 
 	ret = -ENOTCONN;
 	rdma = container_of(sxprt, struct svcxprt_rdma, sc_xprt);
-	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags))
+	if (!test_bit(XPT_DEAD, &sxprt->xpt_flags)) {
 		ret = rpcrdma_bc_send_request(rdma, rqst);
+		if (ret == -ENOTCONN)
+			svc_close_xprt(sxprt);
+	}
 
 	mutex_unlock(&sxprt->xpt_mutex);
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 91c476a..134aae2 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -437,8 +437,7 @@
  * Caller holds @xprt's send lock to prevent activity on this
  * transport while the connection is torn down.
  */
-static void
-xprt_rdma_close(struct rpc_xprt *xprt)
+void xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
@@ -453,13 +452,13 @@
 
 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		rpcrdma_ia_remove(ia);
-		return;
+		goto out;
 	}
+
 	if (ep->rep_connected == -ENODEV)
 		return;
 	if (ep->rep_connected > 0)
 		xprt->reestablish_timeout = 0;
-	xprt_disconnect_done(xprt);
 	rpcrdma_ep_disconnect(ep, ia);
 
 	/* Prepare @xprt for the next connection by reinitializing
@@ -467,6 +466,10 @@
 	 */
 	r_xprt->rx_buf.rb_credits = 1;
 	xprt->cwnd = RPC_CWNDSHIFT;
+
+out:
+	++xprt->connect_cookie;
+	xprt_disconnect_done(xprt);
 }
 
 /**
@@ -717,7 +720,7 @@
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
 	if (!xprt_connected(xprt))
-		goto drop_connection;
+		return -ENOTCONN;
 
 	if (!xprt_request_get_cong(xprt, rqst))
 		return -EBADSLT;
@@ -749,8 +752,8 @@
 	if (rc != -ENOTCONN)
 		return rc;
 drop_connection:
-	xprt_disconnect_done(xprt);
-	return -ENOTCONN;	/* implies disconnect */
+	xprt_rdma_close(xprt);
+	return -ENOTCONN;
 }
 
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9a0a765..29798b6 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -280,7 +280,6 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 			ep->rep_connected = -EAGAIN;
 		goto disconnected;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		++xprt->connect_cookie;
 		ep->rep_connected = -ECONNABORTED;
 disconnected:
 		xprt_force_disconnect(xprt);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 7c1b519..99b7f8e 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -647,6 +647,7 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 extern unsigned int xprt_rdma_max_inline_read;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void xprt_rdma_close(struct rpc_xprt *xprt);
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);

