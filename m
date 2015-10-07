Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f173.google.com ([209.85.160.173]:32828 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755124AbbJGRxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 13:53:17 -0400
Received: by ykft14 with SMTP id t14so25326361ykf.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 10:53:16 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH v2 4/4] SUNRPC: Move AF_LOCAL receive data path into a workqueue context
Date: Wed,  7 Oct 2015 13:53:00 -0400
Message-Id: <1444240380-11184-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1444240380-11184-3-git-send-email-trond.myklebust@primarydata.com>
References: <1444240380-11184-1-git-send-email-trond.myklebust@primarydata.com>
 <1444240380-11184-2-git-send-email-trond.myklebust@primarydata.com>
 <1444240380-11184-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we've done it for TCP and UDP, let's convert AF_LOCAL as well.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 72 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 42 insertions(+), 30 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index df8bdcc10640..1471ecceabf9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -909,44 +909,36 @@ static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 }
 
 /**
- * xs_local_data_ready - "data ready" callback for AF_LOCAL sockets
- * @sk: socket with data to read
+ * xs_local_data_read_skb
+ * @xprt: transport
+ * @sk: socket
+ * @skb: skbuff
  *
  * Currently this assumes we can read the whole reply in a single gulp.
  */
-static void xs_local_data_ready(struct sock *sk)
+static void xs_local_data_read_skb(struct rpc_xprt *xprt,
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
-	dprintk("RPC:       %s...\n", __func__);
-	xprt = xprt_from_sock(sk);
-	if (xprt == NULL)
-		goto out;
-
-	skb = skb_recv_datagram(sk, 0, 1, &err);
-	if (skb == NULL)
-		goto out;
-
 	repsize = skb->len - sizeof(rpc_fraghdr);
 	if (repsize < 4) {
 		dprintk("RPC:       impossible RPC reply size %d\n", repsize);
-		goto dropit;
+		return;
 	}
 
 	/* Copy the XID from the skb... */
 	xp = skb_header_pointer(skb, sizeof(rpc_fraghdr), sizeof(_xid), &_xid);
 	if (xp == NULL)
-		goto dropit;
+		return;
 
 	/* Look up and lock the request corresponding to the given XID */
-	spin_lock(&xprt->transport_lock);
+	spin_lock_bh(&xprt->transport_lock);
 	rovr = xprt_lookup_rqst(xprt, *xp);
 	if (!rovr)
 		goto out_unlock;
@@ -964,11 +956,35 @@ static void xs_local_data_ready(struct sock *sk)
 	xprt_complete_rqst(task, copied);
 
  out_unlock:
-	spin_unlock(&xprt->transport_lock);
- dropit:
-	skb_free_datagram(sk, skb);
- out:
-	read_unlock_bh(&sk->sk_callback_lock);
+	spin_unlock_bh(&xprt->transport_lock);
+}
+
+static void xs_local_data_receive(struct sock_xprt *transport)
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
+		xs_local_data_read_skb(&transport->xprt, sk, skb);
+		skb_free_datagram(sk, skb);
+	}
+out:
+	mutex_unlock(&transport->recv_mutex);
+}
+
+static void xs_local_data_receive_workfn(struct work_struct *work)
+{
+	struct sock_xprt *transport =
+		container_of(work, struct sock_xprt, recv_worker);
+	xs_local_data_receive(transport);
 }
 
 /**
@@ -1895,10 +1911,6 @@ static inline void xs_reclassify_socket(int family, struct socket *sock)
 }
 #endif
 
-static void xs_dummy_data_receive_workfn(struct work_struct *work)
-{
-}
-
 static void xs_dummy_setup_socket(struct work_struct *work)
 {
 }
@@ -1946,7 +1958,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		xs_save_old_callbacks(transport, sk);
 
 		sk->sk_user_data = xprt;
-		sk->sk_data_ready = xs_local_data_ready;
+		sk->sk_data_ready = xs_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_NOIO;
@@ -2777,7 +2789,7 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 	xprt->ops = &xs_local_ops;
 	xprt->timeout = &xs_local_default_timeout;
 
-	INIT_WORK(&transport->recv_worker, xs_dummy_data_receive_workfn);
+	INIT_WORK(&transport->recv_worker, xs_local_data_receive_workfn);
 	INIT_DELAYED_WORK(&transport->connect_worker,
 			xs_dummy_setup_socket);
 
-- 
2.4.3

