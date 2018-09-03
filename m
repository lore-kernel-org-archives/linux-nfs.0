Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38759 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726314AbeICTuq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 15:50:46 -0400
Received: by mail-io0-f196.google.com with SMTP id y3-v6so691397ioc.5
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 08:30:06 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id c25-v6sm7040027iob.30.2018.09.03.08.30.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Sep 2018 08:30:05 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/27] SUNRPC: Add socket transmit queue offset tracking
Date: Mon,  3 Sep 2018 11:29:17 -0400
Message-Id: <20180903152936.24325-9-trond.myklebust@hammerspace.com>
In-Reply-To: <20180903152936.24325-8-trond.myklebust@hammerspace.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
 <20180903152936.24325-2-trond.myklebust@hammerspace.com>
 <20180903152936.24325-3-trond.myklebust@hammerspace.com>
 <20180903152936.24325-4-trond.myklebust@hammerspace.com>
 <20180903152936.24325-5-trond.myklebust@hammerspace.com>
 <20180903152936.24325-6-trond.myklebust@hammerspace.com>
 <20180903152936.24325-7-trond.myklebust@hammerspace.com>
 <20180903152936.24325-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprtsock.h |  7 ++++++
 net/sunrpc/xprtsock.c           | 40 ++++++++++++++++++---------------
 2 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 90d5ca8e65f4..005cfb6e7238 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -42,6 +42,13 @@ struct sock_xprt {
 				flags;
 	} recv;
 
+	/*
+	 * State of TCP transmit queue
+	 */
+	struct {
+		u32		offset;
+	} xmit;
+
 	/*
 	 * Connection of transports
 	 */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ec1e3f93e707..629cc45e1e6c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -461,7 +461,7 @@ static int xs_nospace(struct rpc_task *task)
 	int ret = -EAGAIN;
 
 	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
-			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
+			task->tk_pid, req->rq_slen - transport->xmit.offset,
 			req->rq_slen);
 
 	/* Protect against races with write_space */
@@ -528,19 +528,22 @@ static int xs_local_send_request(struct rpc_task *task)
 			req->rq_svec->iov_base, req->rq_svec->iov_len);
 
 	req->rq_xtime = ktime_get();
-	status = xs_sendpages(transport->sock, NULL, 0, xdr, req->rq_bytes_sent,
+	status = xs_sendpages(transport->sock, NULL, 0, xdr,
+			      transport->xmit.offset,
 			      true, &sent);
 	dprintk("RPC:       %s(%u) = %d\n",
-			__func__, xdr->len - req->rq_bytes_sent, status);
+			__func__, xdr->len - transport->xmit.offset, status);
 
 	if (status == -EAGAIN && sock_writeable(transport->inet))
 		status = -ENOBUFS;
 
 	if (likely(sent > 0) || status == 0) {
-		req->rq_bytes_sent += sent;
-		req->rq_xmit_bytes_sent += sent;
+		transport->xmit.offset += sent;
+		req->rq_bytes_sent = transport->xmit.offset;
 		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
+			req->rq_xmit_bytes_sent += transport->xmit.offset;
 			req->rq_bytes_sent = 0;
+			transport->xmit.offset = 0;
 			return 0;
 		}
 		status = -EAGAIN;
@@ -592,10 +595,10 @@ static int xs_udp_send_request(struct rpc_task *task)
 		return -ENOTCONN;
 	req->rq_xtime = ktime_get();
 	status = xs_sendpages(transport->sock, xs_addr(xprt), xprt->addrlen,
-			      xdr, req->rq_bytes_sent, true, &sent);
+			      xdr, 0, true, &sent);
 
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
-			xdr->len - req->rq_bytes_sent, status);
+			xdr->len, status);
 
 	/* firewall is blocking us, don't return -EAGAIN or we end up looping */
 	if (status == -EPERM)
@@ -684,17 +687,20 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	while (1) {
 		sent = 0;
 		status = xs_sendpages(transport->sock, NULL, 0, xdr,
-				      req->rq_bytes_sent, zerocopy, &sent);
+				      transport->xmit.offset,
+				      zerocopy, &sent);
 
 		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
-				xdr->len - req->rq_bytes_sent, status);
+				xdr->len - transport->xmit.offset, status);
 
 		/* If we've sent the entire packet, immediately
 		 * reset the count of bytes sent. */
-		req->rq_bytes_sent += sent;
-		req->rq_xmit_bytes_sent += sent;
+		transport->xmit.offset += sent;
+		req->rq_bytes_sent = transport->xmit.offset;
 		if (likely(req->rq_bytes_sent >= req->rq_slen)) {
+			req->rq_xmit_bytes_sent += transport->xmit.offset;
 			req->rq_bytes_sent = 0;
+			transport->xmit.offset = 0;
 			return 0;
 		}
 
@@ -760,18 +766,13 @@ static int xs_tcp_send_request(struct rpc_task *task)
  */
 static void xs_tcp_release_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 {
-	struct rpc_rqst *req;
+	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
 	if (task != xprt->snd_task)
 		return;
 	if (task == NULL)
 		goto out_release;
-	req = task->tk_rqstp;
-	if (req == NULL)
-		goto out_release;
-	if (req->rq_bytes_sent == 0)
-		goto out_release;
-	if (req->rq_bytes_sent == req->rq_snd_buf.len)
+	if (transport->xmit.offset == 0 || !xprt_connected(xprt))
 		goto out_release;
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 out_release:
@@ -2021,6 +2022,8 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
+	transport->xmit.offset = 0;
+
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
 	xprt->stat.connect_start = jiffies;
@@ -2384,6 +2387,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	transport->recv.len = 0;
 	transport->recv.copied = 0;
 	transport->recv.flags = TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
+	transport->xmit.offset = 0;
 
 	/* Tell the socket layer to start connecting... */
 	xprt->stat.connect_count++;
-- 
2.17.1
