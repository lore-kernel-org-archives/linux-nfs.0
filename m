From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/10] SUNRPC: Remove sock and inet fields from
	rpc_xprt
Date: Wed, 25 Oct 2006 12:47:00 -0400
Message-ID: <20061025164700.6410.92972.stgit@localhost.localdomain>
References: <20061025164602.6410.27449.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcrQT-0006QG-IZ
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:40:45 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GcrQT-000745-Bw
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 15:40:46 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061025164602.6410.27449.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The "sock" and "inet" fields are socket-specific.  Move them to a private
data structure maintained entirely within net/sunrpc/xprtsock.c

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    4 +--
 net/sunrpc/xprtsock.c       |   62 +++++++++++++++++++++++++++----------------
 2 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index d791901..4c074a7 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -17,6 +17,8 @@ #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/sunrpc/msg_prot.h>
 
+#include <net/sock.h>
+
 extern unsigned int xprt_udp_slot_table_entries;
 extern unsigned int xprt_tcp_slot_table_entries;
 
@@ -126,8 +128,6 @@ struct rpc_xprt_ops {
 struct rpc_xprt {
 	struct kref		kref;		/* Reference count */
 	struct rpc_xprt_ops *	ops;		/* transport methods */
-	struct socket *		sock;		/* BSD socket layer */
-	struct sock *		inet;		/* INET layer */
 
 	struct rpc_timeout	timeout;	/* timeout parms */
 	struct sockaddr_storage	addr;		/* server address */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 44df649..4cc5bbf 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -127,6 +127,12 @@ #endif
 
 struct sock_xprt {
 	struct rpc_xprt		xprt;
+
+	/*
+	 * Network layer
+	 */
+	struct socket *		sock;
+	struct sock *		inet;
 };
 
 static void xs_format_peer_addresses(struct rpc_xprt *xprt)
@@ -295,19 +301,20 @@ static void xs_nospace(struct rpc_task *
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 
 	dprintk("RPC: %4d xmit incomplete (%u left of %u)\n",
 			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
 			req->rq_slen);
 
-	if (test_bit(SOCK_ASYNC_NOSPACE, &xprt->sock->flags)) {
+	if (test_bit(SOCK_ASYNC_NOSPACE, &sx->sock->flags)) {
 		/* Protect against races with write_space */
 		spin_lock_bh(&xprt->transport_lock);
 
 		/* Don't race with disconnect */
 		if (!xprt_connected(xprt))
 			task->tk_status = -ENOTCONN;
-		else if (test_bit(SOCK_NOSPACE, &xprt->sock->flags))
+		else if (test_bit(SOCK_NOSPACE, &sx->sock->flags))
 			xprt_wait_for_buffer_space(task);
 
 		spin_unlock_bh(&xprt->transport_lock);
@@ -331,6 +338,7 @@ static int xs_udp_send_request(struct rp
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
 	int status;
 
@@ -339,8 +347,10 @@ static int xs_udp_send_request(struct rp
 				req->rq_svec->iov_len);
 
 	req->rq_xtime = jiffies;
-	status = xs_sendpages(xprt->sock, (struct sockaddr *) &xprt->addr,
-				xprt->addrlen, xdr, req->rq_bytes_sent);
+	status = xs_sendpages(sx->sock,
+			      (struct sockaddr *) &xprt->addr,
+			      xprt->addrlen, xdr,
+			      req->rq_bytes_sent);
 
 	dprintk("RPC:      xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
@@ -396,6 +406,7 @@ static int xs_tcp_send_request(struct rp
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	struct xdr_buf *xdr = &req->rq_snd_buf;
 	int status, retry = 0;
 
@@ -410,8 +421,8 @@ static int xs_tcp_send_request(struct rp
 	 * called sendmsg(). */
 	while (1) {
 		req->rq_xtime = jiffies;
-		status = xs_sendpages(xprt->sock, NULL, 0, xdr,
-						req->rq_bytes_sent);
+		status = xs_sendpages(sx->sock,
+					NULL, 0, xdr, req->rq_bytes_sent);
 
 		dprintk("RPC:      xs_tcp_send_request(%u) = %d\n",
 				xdr->len - req->rq_bytes_sent, status);
@@ -489,8 +500,9 @@ out_release:
  */
 static void xs_close(struct rpc_xprt *xprt)
 {
-	struct socket *sock = xprt->sock;
-	struct sock *sk = xprt->inet;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = sx->sock;
+	struct sock *sk = sx->inet;
 
 	if (!sk)
 		goto clear_close_wait;
@@ -498,8 +510,8 @@ static void xs_close(struct rpc_xprt *xp
 	dprintk("RPC:      xs_close xprt %p\n", xprt);
 
 	write_lock_bh(&sk->sk_callback_lock);
-	xprt->inet = NULL;
-	xprt->sock = NULL;
+	sx->inet = NULL;
+	sx->sock = NULL;
 
 	sk->sk_user_data = NULL;
 	sk->sk_data_ready = xprt->old_data_ready;
@@ -956,7 +968,8 @@ static void xs_tcp_write_space(struct so
 
 static void xs_udp_do_set_buffer_size(struct rpc_xprt *xprt)
 {
-	struct sock *sk = xprt->inet;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct sock *sk = sx->inet;
 
 	if (xprt->rcvsize) {
 		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
@@ -1072,7 +1085,8 @@ static int xs_bindresvport(struct rpc_xp
 static void xs_udp_connect_worker(void *args)
 {
 	struct rpc_xprt *xprt = (struct rpc_xprt *) args;
-	struct socket *sock = xprt->sock;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = sx->sock;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
@@ -1094,7 +1108,7 @@ static void xs_udp_connect_worker(void *
 	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
 			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
 
-	if (!xprt->inet) {
+	if (!sx->inet) {
 		struct sock *sk = sock->sk;
 
 		write_lock_bh(&sk->sk_callback_lock);
@@ -1111,8 +1125,8 @@ static void xs_udp_connect_worker(void *
 		xprt_set_connected(xprt);
 
 		/* Reset to new socket */
-		xprt->sock = sock;
-		xprt->inet = sk;
+		sx->sock = sock;
+		sx->inet = sk;
 
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
@@ -1130,7 +1144,7 @@ out:
 static void xs_tcp_reuse_connection(struct rpc_xprt *xprt)
 {
 	int result;
-	struct socket *sock = xprt->sock;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 	struct sockaddr any;
 
 	dprintk("RPC:      disconnecting xprt %p to reuse port\n", xprt);
@@ -1141,7 +1155,7 @@ static void xs_tcp_reuse_connection(stru
 	 */
 	memset(&any, 0, sizeof(any));
 	any.sa_family = AF_UNSPEC;
-	result = kernel_connect(sock, &any, sizeof(any), 0);
+	result = kernel_connect(sx->sock, &any, sizeof(any), 0);
 	if (result)
 		dprintk("RPC:      AF_UNSPEC connect return code %d\n",
 				result);
@@ -1156,13 +1170,14 @@ static void xs_tcp_reuse_connection(stru
 static void xs_tcp_connect_worker(void *args)
 {
 	struct rpc_xprt *xprt = (struct rpc_xprt *)args;
-	struct socket *sock = xprt->sock;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
+	struct socket *sock = sx->sock;
 	int err, status = -EIO;
 
 	if (xprt->shutdown || !xprt_bound(xprt))
 		goto out;
 
-	if (!xprt->sock) {
+	if (!sock) {
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
 			dprintk("RPC:      can't create TCP transport socket (%d).\n", -err);
@@ -1180,7 +1195,7 @@ static void xs_tcp_connect_worker(void *
 	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
 			xprt, xs_print_peer_address(xprt, RPC_DISPLAY_ALL));
 
-	if (!xprt->inet) {
+	if (!sx->inet) {
 		struct sock *sk = sock->sk;
 
 		write_lock_bh(&sk->sk_callback_lock);
@@ -1203,8 +1218,8 @@ static void xs_tcp_connect_worker(void *
 		xprt_clear_connected(xprt);
 
 		/* Reset to new socket */
-		xprt->sock = sock;
-		xprt->inet = sk;
+		sx->sock = sock;
+		sx->inet = sk;
 
 		write_unlock_bh(&sk->sk_callback_lock);
 	}
@@ -1253,11 +1268,12 @@ out_clear:
 static void xs_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
+	struct sock_xprt *sx = container_of(xprt, struct sock_xprt, xprt);
 
 	if (xprt_test_and_set_connecting(xprt))
 		return;
 
-	if (xprt->sock != NULL) {
+	if (sx->sock != NULL) {
 		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
 		schedule_delayed_work(&xprt->connect_worker,

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
