Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40862 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab2ILTJS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Sep 2012 15:09:18 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Get rid of the redundant xprt->shutdown bit field
Date: Wed, 12 Sep 2012 15:09:12 -0400
Message-Id: <1347476952-34734-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is only set after everyone has dereferenced the transport,
and serves no useful purpose: setting it is racy, so all the
socket code, etc still needs to be able to cope with the cases
where they miss reading it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 include/linux/sunrpc/xprt.h     |  3 +--
 net/sunrpc/xprt.c               |  8 ++------
 net/sunrpc/xprtrdma/transport.c | 22 ++++++++--------------
 net/sunrpc/xprtsock.c           | 18 ------------------
 4 files changed, 11 insertions(+), 40 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index bf8c49f..951cb9b 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -173,8 +173,7 @@ struct rpc_xprt {
 	unsigned int		min_reqs;	/* min number of slots */
 	atomic_t		num_reqs;	/* total slots */
 	unsigned long		state;		/* transport state */
-	unsigned char		shutdown   : 1,	/* being shut down */
-				resvport   : 1; /* use a reserved port */
+	unsigned char		resvport   : 1; /* use a reserved port */
 	unsigned int		swapper;	/* we're swapping over this
 						   transport */
 	unsigned int		bind_index;	/* bind function index */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 5d7f61d..bd462a5 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -231,7 +231,7 @@ EXPORT_SYMBOL_GPL(xprt_reserve_xprt);
 static void xprt_clear_locked(struct rpc_xprt *xprt)
 {
 	xprt->snd_task = NULL;
-	if (!test_bit(XPRT_CLOSE_WAIT, &xprt->state) || xprt->shutdown) {
+	if (!test_bit(XPRT_CLOSE_WAIT, &xprt->state)) {
 		smp_mb__before_clear_bit();
 		clear_bit(XPRT_LOCKED, &xprt->state);
 		smp_mb__after_clear_bit();
@@ -504,9 +504,6 @@ EXPORT_SYMBOL_GPL(xprt_wait_for_buffer_space);
  */
 void xprt_write_space(struct rpc_xprt *xprt)
 {
-	if (unlikely(xprt->shutdown))
-		return;
-
 	spin_lock_bh(&xprt->transport_lock);
 	if (xprt->snd_task) {
 		dprintk("RPC:       write space: waking waiting task on "
@@ -679,7 +676,7 @@ xprt_init_autodisconnect(unsigned long data)
 	struct rpc_xprt *xprt = (struct rpc_xprt *)data;
 
 	spin_lock(&xprt->transport_lock);
-	if (!list_empty(&xprt->recv) || xprt->shutdown)
+	if (!list_empty(&xprt->recv))
 		goto out_abort;
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state))
 		goto out_abort;
@@ -1262,7 +1259,6 @@ out:
 static void xprt_destroy(struct rpc_xprt *xprt)
 {
 	dprintk("RPC:       destroying transport %p\n", xprt);
-	xprt->shutdown = 1;
 	del_timer_sync(&xprt->timer);
 
 	rpc_destroy_wait_queue(&xprt->binding);
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 5d9202d..c9aa7a3 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -199,21 +199,15 @@ xprt_rdma_connect_worker(struct work_struct *work)
 	struct rpc_xprt *xprt = &r_xprt->xprt;
 	int rc = 0;
 
-	if (!xprt->shutdown) {
-		current->flags |= PF_FSTRANS;
-		xprt_clear_connected(xprt);
-
-		dprintk("RPC:       %s: %sconnect\n", __func__,
-				r_xprt->rx_ep.rep_connected != 0 ? "re" : "");
-		rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
-		if (rc)
-			goto out;
-	}
-	goto out_clear;
+	current->flags |= PF_FSTRANS;
+	xprt_clear_connected(xprt);
+
+	dprintk("RPC:       %s: %sconnect\n", __func__,
+			r_xprt->rx_ep.rep_connected != 0 ? "re" : "");
+	rc = rpcrdma_ep_connect(&r_xprt->rx_ep, &r_xprt->rx_ia);
+	if (rc)
+		xprt_wake_pending_tasks(xprt, rc);
 
-out:
-	xprt_wake_pending_tasks(xprt, rc);
-out_clear:
 	dprintk("RPC:       %s: exit\n", __func__);
 	xprt_clear_connecting(xprt);
 	current->flags &= ~PF_FSTRANS;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a35b8e5..9f6d35a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -917,9 +917,6 @@ static void xs_local_data_ready(struct sock *sk, int len)
 	if (skb == NULL)
 		goto out;
 
-	if (xprt->shutdown)
-		goto dropit;
-
 	repsize = skb->len - sizeof(rpc_fraghdr);
 	if (repsize < 4) {
 		dprintk("RPC:       impossible RPC reply size %d\n", repsize);
@@ -981,9 +978,6 @@ static void xs_udp_data_ready(struct sock *sk, int len)
 	if ((skb = skb_recv_datagram(sk, 0, 1, &err)) == NULL)
 		goto out;
 
-	if (xprt->shutdown)
-		goto dropit;
-
 	repsize = skb->len - sizeof(struct udphdr);
 	if (repsize < 4) {
 		dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
@@ -1402,9 +1396,6 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
 	read_lock_bh(&sk->sk_callback_lock);
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
-	if (xprt->shutdown)
-		goto out;
-
 	/* Any data means we had a useful conversation, so
 	 * the we don't need to delay the next reconnect
 	 */
@@ -1889,9 +1880,6 @@ static void xs_local_setup_socket(struct work_struct *work)
 	struct socket *sock;
 	int status = -EIO;
 
-	if (xprt->shutdown)
-		goto out;
-
 	current->flags |= PF_FSTRANS;
 
 	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
@@ -2008,9 +1996,6 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int status = -EIO;
 
-	if (xprt->shutdown)
-		goto out;
-
 	current->flags |= PF_FSTRANS;
 
 	/* Start by resetting any existing state */
@@ -2156,9 +2141,6 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 	struct rpc_xprt *xprt = &transport->xprt;
 	int status = -EIO;
 
-	if (xprt->shutdown)
-		goto out;
-
 	current->flags |= PF_FSTRANS;
 
 	if (!sock) {
-- 
1.7.11.4

