Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5EA4DC282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 17:30:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22EE32147A
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 17:30:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548696615;
	bh=DswvjFhhMD433tg2t4eilKeFeUabt1oJPaBCuhaotog=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=rxIZ2PkDBklsZsd/ghCNAsQZnLcWYeqJVXu54UvSCjNB4PS0CrUFV2Mf3MQFADKOp
	 TISmBOCgiTiUu4VquTcAbJMnaOKPePaM1G2ti5Q9Xk3UeKvDhZCk4I2wUbk09tS/my
	 5CSsdtKq5upCHxmoCliD532/LqLBZrTRfX/mFuOE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729664AbfA1P7Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 10:59:24 -0500
Received: from mail.kernel.org ([198.145.29.99]:44716 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727635AbfA1P7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 10:59:23 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id DC3342082E;
        Mon, 28 Jan 2019 15:59:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548691162;
        bh=DswvjFhhMD433tg2t4eilKeFeUabt1oJPaBCuhaotog=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=pWV3PkRTKYtkzXdghQU2+xIZ6/XHc3UROAQ9kwpoh6uAnH4vsrG1SPFTexuchcCvF
         MOOKGN2Q8LC3tbHy95Dg2UNw8hgS4alSWytLjKsFRgf+P0D9ersxpyJo2NC+ZkcBx7
         +UrZwuE5DTkeH0Bkg0JMCvny1f7IK3VLTPaVFRsA=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 4.20 304/304] xprtrdma: Don't wake pending tasks until disconnect is done
Date:   Mon, 28 Jan 2019 10:43:41 -0500
Message-Id: <20190128154341.47195-304-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128154341.47195-1-sashal@kernel.org>
References: <20190128154341.47195-1-sashal@kernel.org>
MIME-Version: 1.0
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

[ Upstream commit 0c0829bcf51aef713806e49b8ea2bac7962f54e2 ]

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
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/xprtrdma/backchannel.c          | 13 +++++++------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |  8 +++++---
 net/sunrpc/xprtrdma/transport.c            | 17 ++++++++++-------
 net/sunrpc/xprtrdma/verbs.c                |  1 -
 net/sunrpc/xprtrdma/xprt_rdma.h            |  1 +
 5 files changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a3e517..88fde80b9347 100644
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
@@ -216,7 +217,7 @@ failed_marshal:
 	if (rc != -ENOTCONN)
 		return rc;
 drop_connection:
-	xprt_disconnect_done(rqst->rq_xprt);
+	xprt_rdma_close(xprt);
 	return -ENOTCONN;
 }
 
@@ -339,7 +340,7 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 
 out_overflow:
 	pr_warn("RPC/RDMA backchannel overflow\n");
-	xprt_disconnect_done(xprt);
+	xprt_force_disconnect(xprt);
 	/* This receive buffer gets reposted automatically
 	 * when the connection is re-established.
 	 */
diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index f3c147d70286..b908f2ca08fd 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -200,11 +200,10 @@ rpcrdma_bc_send_request(struct svcxprt_rdma *rdma, struct rpc_rqst *rqst)
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
 
@@ -225,8 +224,11 @@ xprt_rdma_bc_send_request(struct rpc_rqst *rqst)
 
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
index ae2a83828953..e7683d3b1e6c 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -437,8 +437,7 @@ out1:
  * Caller holds @xprt's send lock to prevent activity on this
  * transport while the connection is torn down.
  */
-static void
-xprt_rdma_close(struct rpc_xprt *xprt)
+void xprt_rdma_close(struct rpc_xprt *xprt)
 {
 	struct rpcrdma_xprt *r_xprt = rpcx_to_rdmax(xprt);
 	struct rpcrdma_ep *ep = &r_xprt->rx_ep;
@@ -449,13 +448,13 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		xprt_clear_connected(xprt);
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
@@ -463,6 +462,10 @@ xprt_rdma_close(struct rpc_xprt *xprt)
 	 */
 	r_xprt->rx_buf.rb_credits = 1;
 	xprt->cwnd = RPC_CWNDSHIFT;
+
+out:
+	++xprt->connect_cookie;
+	xprt_disconnect_done(xprt);
 }
 
 /**
@@ -713,7 +716,7 @@ xprt_rdma_send_request(struct rpc_rqst *rqst)
 #endif	/* CONFIG_SUNRPC_BACKCHANNEL */
 
 	if (!xprt_connected(xprt))
-		goto drop_connection;
+		return -ENOTCONN;
 
 	if (!xprt_request_get_cong(xprt, rqst))
 		return -EBADSLT;
@@ -745,8 +748,8 @@ failed_marshal:
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
index b9bc7f9f6bb9..919fddec0197 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -316,7 +316,6 @@ rpcrdma_cm_event_handler(struct rdma_cm_id *id, struct rdma_cm_event *event)
 			ep->rep_connected = -EAGAIN;
 		goto disconnected;
 	case RDMA_CM_EVENT_DISCONNECTED:
-		++xprt->connect_cookie;
 		ep->rep_connected = -ECONNABORTED;
 disconnected:
 		xprt_force_disconnect(xprt);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index a13ccb643ce0..0af75b1405f8 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -653,6 +653,7 @@ static inline void rpcrdma_set_xdrlen(struct xdr_buf *xdr, size_t len)
 extern unsigned int xprt_rdma_max_inline_read;
 void xprt_rdma_format_addresses(struct rpc_xprt *xprt, struct sockaddr *sap);
 void xprt_rdma_free_addresses(struct rpc_xprt *xprt);
+void xprt_rdma_close(struct rpc_xprt *xprt);
 void xprt_rdma_print_stats(struct rpc_xprt *xprt, struct seq_file *seq);
 int xprt_rdma_init(void);
 void xprt_rdma_cleanup(void);
-- 
2.19.1

