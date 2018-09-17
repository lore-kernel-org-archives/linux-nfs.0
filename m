Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:40309 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728327AbeIQSb7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2018 14:31:59 -0400
Received: by mail-qt0-f196.google.com with SMTP id h4-v6so15114036qtj.7
        for <linux-nfs@vger.kernel.org>; Mon, 17 Sep 2018 06:04:44 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([66.187.232.65])
        by smtp.gmail.com with ESMTPSA id q1-v6sm10499607qkl.31.2018.09.17.06.04.42
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Sep 2018 06:04:42 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 42/44] SUNRPC: Allow AF_LOCAL sockets to use the generic stream receive
Date: Mon, 17 Sep 2018 09:03:33 -0400
Message-Id: <20180917130335.112832-43-trond.myklebust@hammerspace.com>
In-Reply-To: <20180917130335.112832-42-trond.myklebust@hammerspace.com>
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
 <20180917130335.112832-42-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xdr.h |   1 -
 net/sunrpc/socklib.c       |   4 +-
 net/sunrpc/xprtsock.c      | 137 +++++--------------------------------
 3 files changed, 18 insertions(+), 124 deletions(-)

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 745587132a87..8815be7cae72 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -185,7 +185,6 @@ struct xdr_skb_reader {
 
 typedef size_t (*xdr_skb_read_actor)(struct xdr_skb_reader *desc, void *to, size_t len);
 
-size_t xdr_skb_read_bits(struct xdr_skb_reader *desc, void *to, size_t len);
 extern int csum_partial_copy_to_xdr(struct xdr_buf *, struct sk_buff *);
 extern ssize_t xdr_partial_copy_from_skb(struct xdr_buf *, unsigned int,
 		struct xdr_skb_reader *, xdr_skb_read_actor);
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 08f00a98151f..0e7c0dee7578 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -26,7 +26,8 @@
  * Possibly called several times to iterate over an sk_buff and copy
  * data out of it.
  */
-size_t xdr_skb_read_bits(struct xdr_skb_reader *desc, void *to, size_t len)
+static size_t
+xdr_skb_read_bits(struct xdr_skb_reader *desc, void *to, size_t len)
 {
 	if (len > desc->count)
 		len = desc->count;
@@ -36,7 +37,6 @@ size_t xdr_skb_read_bits(struct xdr_skb_reader *desc, void *to, size_t len)
 	desc->offset += len;
 	return len;
 }
-EXPORT_SYMBOL_GPL(xdr_skb_read_bits);
 
 /**
  * xdr_skb_read_and_csum_bits - copy and checksum from skb to buffer
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 15364e2746bd..1daa179b7706 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -667,6 +667,17 @@ static void xs_stream_data_receive_workfn(struct work_struct *work)
 	xs_stream_data_receive(transport);
 }
 
+static void
+xs_stream_reset_connect(struct sock_xprt *transport)
+{
+	transport->recv.offset = 0;
+	transport->recv.len = 0;
+	transport->recv.copied = 0;
+	transport->xmit.offset = 0;
+	transport->xprt.stat.connect_count++;
+	transport->xprt.stat.connect_start = jiffies;
+}
+
 #define XS_SENDMSG_FLAGS	(MSG_DONTWAIT | MSG_NOSIGNAL)
 
 static int xs_send_kvec(struct socket *sock, struct sockaddr *addr, int addrlen, struct kvec *vec, unsigned int base, int more)
@@ -1263,114 +1274,6 @@ static void xs_destroy(struct rpc_xprt *xprt)
 	module_put(THIS_MODULE);
 }
 
-static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
-{
-	struct xdr_skb_reader desc = {
-		.skb		= skb,
-		.offset		= sizeof(rpc_fraghdr),
-		.count		= skb->len - sizeof(rpc_fraghdr),
-	};
-
-	if (xdr_partial_copy_from_skb(xdr, 0, &desc, xdr_skb_read_bits) < 0)
-		return -1;
-	if (desc.count)
-		return -1;
-	return 0;
-}
-
-/**
- * xs_local_data_read_skb
- * @xprt: transport
- * @sk: socket
- * @skb: skbuff
- *
- * Currently this assumes we can read the whole reply in a single gulp.
- */
-static void xs_local_data_read_skb(struct rpc_xprt *xprt,
-		struct sock *sk,
-		struct sk_buff *skb)
-{
-	struct rpc_task *task;
-	struct rpc_rqst *rovr;
-	int repsize, copied;
-	u32 _xid;
-	__be32 *xp;
-
-	repsize = skb->len - sizeof(rpc_fraghdr);
-	if (repsize < 4) {
-		dprintk("RPC:       impossible RPC reply size %d\n", repsize);
-		return;
-	}
-
-	/* Copy the XID from the skb... */
-	xp = skb_header_pointer(skb, sizeof(rpc_fraghdr), sizeof(_xid), &_xid);
-	if (xp == NULL)
-		return;
-
-	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->queue_lock);
-	rovr = xprt_lookup_rqst(xprt, *xp);
-	if (!rovr)
-		goto out_unlock;
-	xprt_pin_rqst(rovr);
-	spin_unlock(&xprt->queue_lock);
-	task = rovr->rq_task;
-
-	copied = rovr->rq_private_buf.buflen;
-	if (copied > repsize)
-		copied = repsize;
-
-	if (xs_local_copy_to_xdr(&rovr->rq_private_buf, skb)) {
-		dprintk("RPC:       sk_buff copy failed\n");
-		spin_lock(&xprt->queue_lock);
-		goto out_unpin;
-	}
-
-	spin_lock(&xprt->queue_lock);
-	xprt_complete_rqst(task, copied);
-out_unpin:
-	xprt_unpin_rqst(rovr);
- out_unlock:
-	spin_unlock(&xprt->queue_lock);
-}
-
-static void xs_local_data_receive(struct sock_xprt *transport)
-{
-	struct sk_buff *skb;
-	struct sock *sk;
-	int err;
-
-restart:
-	mutex_lock(&transport->recv_mutex);
-	sk = transport->inet;
-	if (sk == NULL)
-		goto out;
-	for (;;) {
-		skb = skb_recv_datagram(sk, 0, 1, &err);
-		if (skb != NULL) {
-			xs_local_data_read_skb(&transport->xprt, sk, skb);
-			skb_free_datagram(sk, skb);
-			continue;
-		}
-		if (!test_and_clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state))
-			break;
-		if (need_resched()) {
-			mutex_unlock(&transport->recv_mutex);
-			cond_resched();
-			goto restart;
-		}
-	}
-out:
-	mutex_unlock(&transport->recv_mutex);
-}
-
-static void xs_local_data_receive_workfn(struct work_struct *work)
-{
-	struct sock_xprt *transport =
-		container_of(work, struct sock_xprt, recv_worker);
-	xs_local_data_receive(transport);
-}
-
 /**
  * xs_udp_data_read_skb - receive callback for UDP sockets
  * @xprt: transport
@@ -1971,11 +1874,8 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
 
-	transport->xmit.offset = 0;
+	xs_stream_reset_connect(transport);
 
-	/* Tell the socket layer to start connecting... */
-	xprt->stat.connect_count++;
-	xprt->stat.connect_start = jiffies;
 	return kernel_connect(sock, xs_addr(xprt), xprt->addrlen, 0);
 }
 
@@ -2332,14 +2232,9 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 	xs_set_memalloc(xprt);
 
 	/* Reset TCP record info */
-	transport->recv.offset = 0;
-	transport->recv.len = 0;
-	transport->recv.copied = 0;
-	transport->xmit.offset = 0;
+	xs_stream_reset_connect(transport);
 
 	/* Tell the socket layer to start connecting... */
-	xprt->stat.connect_count++;
-	xprt->stat.connect_start = jiffies;
 	set_bit(XPRT_SOCK_CONNECTING, &transport->sock_state);
 	ret = kernel_connect(sock, xs_addr(xprt), xprt->addrlen, O_NONBLOCK);
 	switch (ret) {
@@ -2714,6 +2609,7 @@ static const struct rpc_xprt_ops xs_local_ops = {
 	.connect		= xs_local_connect,
 	.buf_alloc		= rpc_malloc,
 	.buf_free		= rpc_free,
+	.prepare_request	= xs_stream_prepare_request,
 	.send_request		= xs_local_send_request,
 	.set_retrans_timeout	= xprt_set_retrans_timeout_def,
 	.close			= xs_close,
@@ -2898,9 +2794,8 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 	xprt->ops = &xs_local_ops;
 	xprt->timeout = &xs_local_default_timeout;
 
-	INIT_WORK(&transport->recv_worker, xs_local_data_receive_workfn);
-	INIT_DELAYED_WORK(&transport->connect_worker,
-			xs_dummy_setup_socket);
+	INIT_WORK(&transport->recv_worker, xs_stream_data_receive_workfn);
+	INIT_DELAYED_WORK(&transport->connect_worker, xs_dummy_setup_socket);
 
 	switch (sun->sun_family) {
 	case AF_LOCAL:
-- 
2.17.1
