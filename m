Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6990AC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 26B992133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:39:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o8E3oGfO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388255AbeLQQj5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:39:57 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:55345 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388108AbeLQQjz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:39:55 -0500
Received: by mail-it1-f193.google.com with SMTP id o19so19435612itg.5;
        Mon, 17 Dec 2018 08:39:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=gewXrx17EYSQ+INXkilt/dP9W8sTmtrpJiumbs2rzgg=;
        b=o8E3oGfOTZ8PmgZbBSUugucLJ/PSWwcEJrKzSvZWjwZa15Nh6bUGezyICUm+nS/mtV
         4BZTw5LAfSgQ4c+5s/aiofOYIT99zA+TPTot/wKbbf4jSs5A+urOjwx70vw/GGSGcWe3
         vaTmBIJZluHdJrM7619hcGfa9zjhkt7hYwb8hjU7KDbltZ3dCJA1OD0pVxg+nLU52Psv
         T4zuB9EwZaYt64zUqTFmImQTRSgSAWscs561TZVJaqFzFhUgrLr2+yb+wJf9ntiP0C9e
         BINCaAkEVojpPevPYkluLrV71aAWddQH23EPsh4hmdBRjXd7fhVAcYlWWzt8/KKntxiq
         tYYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=gewXrx17EYSQ+INXkilt/dP9W8sTmtrpJiumbs2rzgg=;
        b=rospSii5SFQZ7HTTaZPc0nMvg/UCzdta/7iYs1IHGE9rqB02lK/RukMeUczFYeDb9U
         C2JYTjCLORWuu7J9nhgPwWD7YcHq6eij4S24nINV/DMDDQPKrKtBMiMU7IRF5PoHidZG
         fTUi1LaRtG9WdxWd+qXkctWzzJKx8XXsSP+0S331R4FEc/EKCrsjyVRur/6FMEWoUN90
         QT1vqjWRdJSAVWHSlPtcTB/djftONbTE9YOEXx82AOQ8PGE60fKuCDwbpMAyVNpNalkD
         dZ83BkrbjAZhuil+8f0H1YsqGl/jXJFB0LspwAzQErhJ9xQMwI0gf9/4kJV7nPKgdtjD
         25AQ==
X-Gm-Message-State: AA+aEWYHej7l+6dS2J4GOv99Klyl1hLtFuPqB4ulRk36Zc0Q7IFlXu/Y
        IIGTsn1vsoiDNHGe7v8jG39+wKT9
X-Google-Smtp-Source: AFSGD/V99uOr/sFBvtBLLRX95wA0FOMKRa++nbIc4Kzf3K98NoPca9MBCfgm6uAidbZs87eDmj5cCQ==
X-Received: by 2002:a24:f14d:: with SMTP id q13mr11849470iti.166.1545064794631;
        Mon, 17 Dec 2018 08:39:54 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id s15sm6091131ioe.52.2018.12.17.08.39.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:39:54 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGdrr8018588;
        Mon, 17 Dec 2018 16:39:53 GMT
Subject: [PATCH v4 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:39:53 -0500
Message-ID: <20181217163953.24133.29214.stgit@manet.1015granger.net>
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
 include/linux/sunrpc/xprt.h                |    1 +
 net/sunrpc/xprt.c                          |   19 +++++++++++++++++++
 net/sunrpc/xprtrdma/backchannel.c          |   13 +++++++------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    8 +++++---
 net/sunrpc/xprtrdma/transport.c            |   16 ++++++++++------
 net/sunrpc/xprtrdma/verbs.c                |    5 ++---
 6 files changed, 44 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index a4ab4f8..ee94ed0 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -401,6 +401,7 @@ static inline __be32 *xprt_skip_transport_header(struct rpc_xprt *xprt, __be32 *
 bool			xprt_request_get_cong(struct rpc_xprt *xprt, struct rpc_rqst *req);
 void			xprt_disconnect_done(struct rpc_xprt *xprt);
 void			xprt_force_disconnect(struct rpc_xprt *xprt);
+void			xprt_disconnect_nowake(struct rpc_xprt *xprt);
 void			xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie);
 
 bool			xprt_lock_connect(struct rpc_xprt *, struct rpc_task *, void *);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ce92700..afe412e 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -685,6 +685,25 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(xprt_force_disconnect);
 
+/**
+ * xprt_disconnect_nowake - force a call to xprt->ops->close
+ * @xprt: transport to disconnect
+ *
+ * The caller must ensure that xprt_wake_pending_tasks() is
+ * called later.
+ */
+void xprt_disconnect_nowake(struct rpc_xprt *xprt)
+{
+       /* Don't race with the test_bit() in xprt_clear_locked() */
+       spin_lock_bh(&xprt->transport_lock);
+       set_bit(XPRT_CLOSE_WAIT, &xprt->state);
+       /* Try to schedule an autoclose RPC call */
+       if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
+               queue_work(xprtiod_workqueue, &xprt->task_cleanup);
+       spin_unlock_bh(&xprt->transport_lock);
+}
+EXPORT_SYMBOL_GPL(xprt_disconnect_nowake);
+
 static unsigned int
 xprt_connect_cookie(struct rpc_xprt *xprt)
 {
diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index 2cb07a3..5d462e8 100644
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
+	xprt->ops->close(xprt);
 	return -ENOTCONN;
 }
 
@@ -338,7 +339,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 
 out_overflow:
 	pr_warn("RPC/RDMA backchannel overflow\n");
-	xprt_disconnect_done(xprt);
+	xprt_disconnect_nowake(xprt);
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
index 91c476a..a16296b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -453,13 +453,13 @@
 
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
@@ -467,6 +467,10 @@
 	 */
 	r_xprt->rx_buf.rb_credits = 1;
 	xprt->cwnd = RPC_CWNDSHIFT;
+
+out:
+	++xprt->connect_cookie;
+	xprt_disconnect_done(xprt);
 }
 
 /**
@@ -515,7 +519,7 @@
 static void
 xprt_rdma_timer(struct rpc_xprt *xprt, struct rpc_task *task)
 {
-	xprt_force_disconnect(xprt);
+	xprt_disconnect_nowake(xprt);
 }
 
 /**
@@ -717,7 +721,7 @@
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
 	if (!xprt_connected(xprt))
-		goto drop_connection;
+		return -ENOTCONN;
 
 	if (!xprt_request_get_cong(xprt, rqst))
 		return -EBADSLT;
@@ -749,8 +753,8 @@
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
index 9a0a765..38a757c 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -252,7 +252,7 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 #endif
 		set_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
 		ep->rep_connected = -ENODEV;
-		xprt_force_disconnect(xprt);
+		xprt_disconnect_nowake(xprt);
 		wait_for_completion(&ia->ri_remove_done);
 
 		ia->ri_id = NULL;
@@ -280,10 +280,9 @@ static void rpcrdma_xprt_drain(struct rpcrdma_xprt *r_xprt)
 			ep->rep_connected = -EAGAIN;
 		goto disconnected;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		++xprt->connect_cookie;
 		ep->rep_connected = -ECONNABORTED;
 disconnected:
-		xprt_force_disconnect(xprt);
+		xprt_disconnect_nowake(xprt);
 		wake_up_all(&ep->rep_connect_wait);
 		break;
 	default:

