Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:46565 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728343AbeIQSb6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:58 -0400
Received: by mail-qt0-f174.google.com with SMTP id l42-v6so15095245qtf.13
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:43 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.41
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:41 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 41/44] SUNRPC: Clean up - rename xs_tcp_data_receive() to xs_stream_data_receive()
Date: Mon, 17 Sep 2018 09:03:32 -0400
Message-Id: <20180917130335.112832-42-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-41-trond.myklebust@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
 <20180917130335.112832-2-trond.myklebust@hammerspace.com>
 <20180917130335.112832-3-trond.myklebust@hammerspace.com>
 <20180917130335.112832-4-trond.myklebust@hammerspace.com>
 <20180917130335.112832-5-trond.myklebust@hammerspace.com>
 <20180917130335.112832-6-trond.myklebust@hammerspace.com>
 <20180917130335.112832-7-trond.myklebust@hammerspace.com>
 <20180917130335.112832-8-trond.myklebust@hammerspace.com>
 <20180917130335.112832-9-trond.myklebust@hammerspace.com>
 <20180917130335.112832-10-trond.myklebust@hammerspace.com>
 <20180917130335.112832-11-trond.myklebust@hammerspace.com>
 <20180917130335.112832-12-trond.myklebust@hammerspace.com>
 <20180917130335.112832-13-trond.myklebust@hammerspace.com>
 <20180917130335.112832-14-trond.myklebust@hammerspace.com>
 <20180917130335.112832-15-trond.myklebust@hammerspace.com>
 <20180917130335.112832-16-trond.myklebust@hammerspace.com>
 <20180917130335.112832-17-trond.myklebust@hammerspace.com>
 <20180917130335.112832-18-trond.myklebust@hammerspace.com>
 <20180917130335.112832-19-trond.myklebust@hammerspace.com>
 <20180917130335.112832-20-trond.myklebust@hammerspace.com>
 <20180917130335.112832-21-trond.myklebust@hammerspace.com>
 <20180917130335.112832-22-trond.myklebust@hammerspace.com>
 <20180917130335.112832-23-trond.myklebust@hammerspace.com>
 <20180917130335.112832-24-trond.myklebust@hammerspace.com>
 <20180917130335.112832-25-trond.myklebust@hammerspace.com>
 <20180917130335.112832-26-trond.myklebust@hammerspace.com>
 <20180917130335.112832-27-trond.myklebust@hammerspace.com>
 <20180917130335.112832-28-trond.myklebust@hammerspace.com>
 <20180917130335.112832-29-trond.myklebust@hammerspace.com>
 <20180917130335.112832-30-trond.myklebust@hammerspace.com>
 <20180917130335.112832-31-trond.myklebust@hammerspace.com>
 <20180917130335.112832-32-trond.myklebust@hammerspace.com>
 <20180917130335.112832-33-trond.myklebust@hammerspace.com>
 <20180917130335.112832-34-trond.myklebust@hammerspace.com>
 <20180917130335.112832-35-trond.myklebust@hammerspace.com>
 <20180917130335.112832-36-trond.myklebust@hammerspace.com>
 <20180917130335.112832-37-trond.myklebust@hammerspace.com>
 <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation for sharing with AF_LOCAL.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/trace/events/sunrpc.h | 16 ++++----
 net/sunrpc/xprtsock.c         | 71 +++++++++++++++--------------------
 2 files changed, 38 insertions(+), 49 deletions(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 19e08d12696c..28e384186c35 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -470,14 +470,14 @@ TRACE_EVENT(xprt_ping,
 			__get_str(addr), __get_str(port), __entry->status)
 );
 
-TRACE_EVENT(xs_tcp_data_ready,
-	TP_PROTO(struct rpc_xprt *xprt, int err, unsigned int total),
+TRACE_EVENT(xs_stream_read_data,
+	TP_PROTO(struct rpc_xprt *xprt, ssize_t err, size_t total),
 
 	TP_ARGS(xprt, err, total),
 
 	TP_STRUCT__entry(
-		__field(int, err)
-		__field(unsigned int, total)
+		__field(ssize_t, err)
+		__field(size_t, total)
 		__string(addr, xprt ? xprt->address_strings[RPC_DISPLAY_ADDR] :
 				"(null)")
 		__string(port, xprt ? xprt->address_strings[RPC_DISPLAY_PORT] :
@@ -493,11 +493,11 @@ TRACE_EVENT(xs_tcp_data_ready,
 			xprt->address_strings[RPC_DISPLAY_PORT] : "(null)");
 	),
 
-	TP_printk("peer=[%s]:%s err=%d total=%u", __get_str(addr),
+	TP_printk("peer=[%s]:%s err=%zd total=%zu", __get_str(addr),
 			__get_str(port), __entry->err, __entry->total)
 );
 
-TRACE_EVENT(xs_tcp_data_recv,
+TRACE_EVENT(xs_stream_read_request,
 	TP_PROTO(struct sock_xprt *xs),
 
 	TP_ARGS(xs),
@@ -508,7 +508,7 @@ TRACE_EVENT(xs_tcp_data_recv,
 		__field(u32, xid)
 		__field(unsigned long, copied)
 		__field(unsigned int, reclen)
-		__field(unsigned long, offset)
+		__field(unsigned int, offset)
 	),
 
 	TP_fast_assign(
@@ -520,7 +520,7 @@ TRACE_EVENT(xs_tcp_data_recv,
 		__entry->offset = xs->recv.offset;
 	),
 
-	TP_printk("peer=[%s]:%s xid=0x%08x copied=%lu reclen=%u offset=%lu",
+	TP_printk("peer=[%s]:%s xid=0x%08x copied=%lu reclen=%u offset=%u",
 			__get_str(addr), __get_str(port), __entry->xid,
 			__entry->copied, __entry->reclen, __entry->offset)
 );
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5269ad98bb08..15364e2746bd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -623,7 +623,7 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		read += ret;
 	}
 	if (xs_read_stream_request_done(transport)) {
-		trace_xs_tcp_data_recv(transport);
+		trace_xs_stream_read_request(transport);
 		transport->recv.copied = 0;
 	}
 	transport->recv.offset = 0;
@@ -639,6 +639,34 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 	return ret;
 }
 
+static void xs_stream_data_receive(struct sock_xprt *transport)
+{
+	size_t read = 0;
+	ssize_t ret = 0;
+
+	mutex_lock(&transport->recv_mutex);
+	if (transport->sock == NULL)
+		goto out;
+	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
+	for (;;) {
+		ret = xs_read_stream(transport, MSG_DONTWAIT | MSG_NOSIGNAL);
+		if (ret <= 0)
+			break;
+		read += ret;
+		cond_resched();
+	}
+out:
+	mutex_unlock(&transport->recv_mutex);
+	trace_xs_stream_read_data(&transport->xprt, ret, read);
+}
+
+static void xs_stream_data_receive_workfn(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, recv_worker);
+	xs_stream_data_receive(transport);
+}
+
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
 static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
@@ -1495,45 +1523,6 @@ static size_t xs_tcp_bc_maxpayload(struct rpc_xprt *xprt)
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-static void xs_tcp_data_receive(struct sock_xprt *transport)
-{
-	struct rpc_xprt *xprt = &transport->xprt;
-	struct sock *sk;
-	size_t read = 0;
-	ssize_t ret = 0;
-
-restart:
-	mutex_lock(&transport->recv_mutex);
-	sk = transport->inet;
-	if (sk == NULL)
-		goto out;
-
-	for (;;) {
-		clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
-		ret = xs_read_stream(transport, MSG_DONTWAIT | MSG_NOSIGNAL);
-		if (ret < 0)
-			break;
-		read += ret;
-		if (need_resched()) {
-			mutex_unlock(&transport->recv_mutex);
-			cond_resched();
-			goto restart;
-		}
-	}
-	if (test_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-		queue_work(xprtiod_workqueue, &transport->recv_worker);
-out:
-	mutex_unlock(&transport->recv_mutex);
-	trace_xs_tcp_data_ready(xprt, ret, read);
-}
-
-static void xs_tcp_data_receive_workfn(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, recv_worker);
-	xs_tcp_data_receive(transport);
-}
-
 /**
  * xs_tcp_state_change - callback to handle TCP socket state changes
  * @sk: socket whose state has changed
@@ -3063,7 +3052,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->connect_timeout = xprt->timeout->to_initval *
 		(xprt->timeout->to_retries + 1);
 
-	INIT_WORK(&transport->recv_worker, xs_tcp_data_receive_workfn);
+	INIT_WORK(&transport->recv_worker, xs_stream_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker, xs_tcp_setup_socket);
 
 	switch (addr->sa_family) {
-- 
2.17.1
