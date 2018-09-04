Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:56210 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726284AbeIEBdL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:11 -0400
Received: by mail-it0-f65.google.com with SMTP id d10-v6so6999283itj.5
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:19 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:17 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/34] SUNRPC: Simplify dealing with aborted partially transmitted messages
Date: Tue,  4 Sep 2018 17:05:24 -0400
Message-Id: <20180904210549.81673-10-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-9-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
 <20180904210549.81673-6-trond.myklebust@hammerspace.com>
 <20180904210549.81673-7-trond.myklebust@hammerspace.com>
 <20180904210549.81673-8-trond.myklebust@hammerspace.com>
 <20180904210549.81673-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the previous message was only partially transmitted, we need to close
the socket in order to avoid corruption of the message stream. To do so,
we currently hijack the unlocking of the socket in order to schedule
the close.
Now that we track the message offset in the socket state, we can move
that kind of checking out of the socket lock code, which is needed to
allow messages to remain queued after dropping the socket lock.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 51 +++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 26 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 629cc45e1e6c..3fbccebd0b10 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -491,6 +491,16 @@ static int xs_nospace(struct rpc_task *task)
 	return ret;
 }
 
+/*
+ * Determine if the previous message in the stream was aborted before it
+ * could complete transmission.
+ */
+static bool
+xs_send_request_was_aborted(struct sock_xprt *transport, struct rpc_rqst *req)
+{
+	return transport->xmit.offset != 0 && req->rq_bytes_sent == 0;
+}
+
 /*
  * Construct a stream transport record marker in @buf.
  */
@@ -522,6 +532,12 @@ static int xs_local_send_request(struct rpc_task *task)
 	int status;
 	int sent = 0;
 
+	/* Close the stream if the previous transmission was incomplete */
+	if (xs_send_request_was_aborted(transport, req)) {
+		xs_close(xprt);
+		return -ENOTCONN;
+	}
+
 	xs_encode_stream_record_marker(&req->rq_snd_buf);
 
 	xs_pktdump("packet data:",
@@ -665,6 +681,13 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	int status;
 	int sent;
 
+	/* Close the stream if the previous transmission was incomplete */
+	if (xs_send_request_was_aborted(transport, req)) {
+		if (transport->sock != NULL)
+			kernel_sock_shutdown(transport->sock, SHUT_RDWR);
+		return -ENOTCONN;
+	}
+
 	xs_encode_stream_record_marker(&req->rq_snd_buf);
 
 	xs_pktdump("packet data:",
@@ -755,30 +778,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	return status;
 }
 
-/**
- * xs_tcp_release_xprt - clean up after a tcp transmission
- * @xprt: transport
- * @task: rpc task
- *
- * This cleans up if an error causes us to abort the transmission of a request.
- * In this case, the socket may need to be reset in order to avoid confusing
- * the server.
- */
-static void xs_tcp_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
-{
-	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
-
-	if (task != xprt->snd_task)
-		return;
-	if (task == NULL)
-		goto out_release;
-	if (transport->xmit.offset == 0 || !xprt_connected(xprt))
-		goto out_release;
-	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
-out_release:
-	xprt_release_xprt(xprt, task);
-}
-
 static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
 {
 	transport->old_data_ready = sk->sk_data_ready;
@@ -2764,7 +2763,7 @@ static void bc_destroy(struct rpc_xprt *xprt)
 
 static const struct rpc_xprt_ops xs_local_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
-	.release_xprt		= xs_tcp_release_xprt,
+	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_alloc_slot,
 	.free_slot		= xprt_free_slot,
 	.rpcbind		= xs_local_rpcbind,
@@ -2806,7 +2805,7 @@ static const struct rpc_xprt_ops xs_udp_ops = {
 
 static const struct rpc_xprt_ops xs_tcp_ops = {
 	.reserve_xprt		= xprt_reserve_xprt,
-	.release_xprt		= xs_tcp_release_xprt,
+	.release_xprt		= xprt_release_xprt,
 	.alloc_slot		= xprt_lock_and_alloc_slot,
 	.free_slot		= xprt_free_slot,
 	.rpcbind		= rpcb_getport_async,
-- 
2.17.1
