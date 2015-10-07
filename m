Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:35208 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901AbbJGRxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 13:53:16 -0400
Received: by ykdz138 with SMTP id z138so25158914ykd.2
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 10:53:15 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 3/4] SUNRPC: Move UDP receive data path into a workqueue context
Date: Wed,  7 Oct 2015 13:52:59 -0400
Message-Id: <1444240380-11184-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1444240380-11184-2-git-send-email-trond.myklebust@primarydata.com>
References: <1444240380-11184-1-git-send-email-trond.myklebust@primarydata.com>
 <1444240380-11184-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've done it for TCP, let's convert UDP as well.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 84 +++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 61 insertions(+), 23 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 58dc90ccebb6..df8bdcc10640 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -972,42 +972,36 @@ static void xs_local_data_ready(struct sock *sk)
 }
 
 /**
- * xs_udp_data_ready - "data ready" callback for UDP sockets
- * @sk: socket with data to read
+ * xs_udp_data_read_skb - receive callback for UDP sockets
+ * @xprt: transport
+ * @sk: socket
+ * @skb: skbuff
  *
  */
-static void xs_udp_data_ready(struct sock *sk)
+static void xs_udp_data_read_skb(struct rpc_xprt *xprt,
+		struct sock *sk,
+		struct sk_buff *skb)
 {
 	struct rpc_task *task;
-	struct rpc_xprt *xprt;
 	struct rpc_rqst *rovr;
-	struct sk_buff *skb;
-	int err, repsize, copied;
+	int repsize, copied;
 	u32 _xid;
 	__be32 *xp;
 
-	read_lock_bh(&sk->sk_callback_lock);
-	dprintk("RPC:       xs_udp_data_ready...\n");
-	if (!(xprt = xprt_from_sock(sk)))
-		goto out;
-
-	if ((skb = skb_recv_datagram(sk, 0, 1, &err)) == NULL)
-		goto out;
-
 	repsize = skb->len - sizeof(struct udphdr);
 	if (repsize < 4) {
 		dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
-		goto dropit;
+		return;
 	}
 
 	/* Copy the XID from the skb... */
 	xp = skb_header_pointer(skb, sizeof(struct udphdr),
 				sizeof(_xid), &_xid);
 	if (xp == NULL)
-		goto dropit;
+		return;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->transport_lock);
+	spin_lock_bh(&xprt->transport_lock);
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
@@ -1028,10 +1022,54 @@ static void xs_udp_data_ready(struct sock *sk)
 	xprt_complete_rqst(task, copied);
 
  out_unlock:
-	spin_unlock(&xprt->transport_lock);
- dropit:
-	skb_free_datagram(sk, skb);
- out:
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
+static void xs_udp_data_receive(struct sock_xprt *transport)
+{
+	struct sk_buff *skb;
+	struct sock *sk;
+	int err;
+
+	mutex_lock(&transport->recv_mutex);
+	sk = transport->inet;
+	if (sk == NULL)
+		goto out;
+	for (;;) {
+		skb = skb_recv_datagram(sk, 0, 1, &err);
+		if (skb == NULL)
+			break;
+		xs_udp_data_read_skb(&transport->xprt, sk, skb);
+		skb_free_datagram(sk, skb);
+	}
+out:
+	mutex_unlock(&transport->recv_mutex);
+}
+
+static void xs_udp_data_receive_workfn(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, recv_worker);
+	xs_udp_data_receive(transport);
+}
+
+/**
+ * xs_data_ready - "data ready" callback for UDP sockets
+ * @sk: socket with data to read
+ *
+ */
+static void xs_data_ready(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock_bh(&sk->sk_callback_lock);
+	dprintk("RPC:       xs_data_ready...\n");
+	xprt = xprt_from_sock(sk);
+	if (xprt != NULL) {
+		struct sock_xprt *transport = container_of(xprt,
+				struct sock_xprt, xprt);
+		queue_work(rpciod_workqueue, &transport->recv_worker);
+	}
 	read_unlock_bh(&sk->sk_callback_lock);
 }
 
@@ -2094,7 +2132,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_udp_data_ready;
+		sk->sk_data_ready = xs_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_allocation = GFP_NOIO;
 
@@ -2811,7 +2849,7 @@ static struct rpc_xprt *xs_setup_udp(struct xprt_create *args)
 
 	xprt->timeout = &xs_udp_default_timeout;
 
-	INIT_WORK(&transport->recv_worker, xs_dummy_data_receive_workfn);
+	INIT_WORK(&transport->recv_worker, xs_udp_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker, xs_udp_setup_socket);
 
 	switch (addr->sa_family) {
-- 
2.4.3

