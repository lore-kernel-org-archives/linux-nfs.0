Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59546 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752444AbdF3NYr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:24:47 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 13/14] SUNRPC: vsock svcsock support
Date: Fri, 30 Jun 2017 14:23:51 +0100
Message-Id: <20170630132352.32133-14-stefanha@redhat.com>
In-Reply-To: <20170630132352.32133-1-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/svcsock.c | 214 +++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 190 insertions(+), 24 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index e67b097..86cce8f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -42,7 +42,9 @@
 #include <net/udp.h>
 #include <net/tcp.h>
 #include <net/tcp_states.h>
+#include <net/af_vsock.h>
 #include <linux/uaccess.h>
+#include <asm/uaccess.h>
 #include <asm/ioctls.h>
 #include <trace/events/skb.h>
 
@@ -64,7 +66,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *, struct socket *,
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 static void		svc_sock_detach(struct svc_xprt *);
-static void		svc_tcp_sock_detach(struct svc_xprt *);
+static void		svc_common_sock_detach(struct svc_xprt *);
 static void		svc_sock_free(struct svc_xprt *);
 
 static struct svc_xprt *svc_create_socket(struct svc_serv *, int,
@@ -810,9 +812,9 @@ static void svc_tcp_state_change(struct sock *sk)
 }
 
 /*
- * Accept a TCP connection
+ * Accept an incoming connection
  */
-static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
+static struct svc_xprt *svc_common_accept(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 	struct sockaddr_storage addr;
@@ -824,7 +826,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	int		err, slen;
 	RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
-	dprintk("svc: tcp_accept %p sock %p\n", svsk, sock);
+	dprintk("svc: %s %p sock %p\n", __func__, svsk, sock);
 	if (!sock)
 		return NULL;
 
@@ -877,7 +879,7 @@ static struct svc_xprt *svc_tcp_accept(struct svc_xprt *xprt)
 	svc_xprt_set_remote(&newsvsk->sk_xprt, sin, slen);
 	err = kernel_getsockname(newsock, sin, &slen);
 	if (unlikely(err < 0)) {
-		dprintk("svc_tcp_accept: kernel_getsockname error %d\n", -err);
+		dprintk("%s: kernel_getsockname error %d\n", __func__, -err);
 		slen = offsetof(struct sockaddr, sa_data);
 	}
 	svc_xprt_set_local(&newsvsk->sk_xprt, sin, slen);
@@ -1131,7 +1133,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.page_len = rqstp->rq_arg.len - rqstp->rq_arg.head[0].iov_len;
 
 	rqstp->rq_xprt_ctxt   = NULL;
-	rqstp->rq_prot	      = IPPROTO_TCP;
+	rqstp->rq_prot	      = IPPROTO_TCP; /* TODO vsock should either use 0 or IPPROTO_MAX */
 	if (test_bit(XPT_LOCAL, &svsk->sk_xprt.xpt_flags))
 		set_bit(RQ_LOCAL, &rqstp->rq_flags);
 	else
@@ -1200,13 +1202,13 @@ static int svc_tcp_sendto(struct svc_rqst *rqstp)
 }
 
 /*
- * Setup response header. TCP has a 4B record length field.
+ * Setup response header. Byte stream transports have a 4B record length field.
  */
-static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
+static void svc_stream_prep_reply_hdr(struct svc_rqst *rqstp)
 {
 	struct kvec *resv = &rqstp->rq_res.head[0];
 
-	/* tcp needs a space for the record length... */
+	/* space for the record length... */
 	svc_putnl(resv, 0);
 }
 
@@ -1232,7 +1234,7 @@ static struct svc_xprt_ops svc_tcp_bc_ops = {
 	.xpo_create = svc_bc_create_socket,
 	.xpo_detach = svc_bc_tcp_sock_detach,
 	.xpo_free = svc_bc_sock_free,
-	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_prep_reply_hdr = svc_stream_prep_reply_hdr,
 	.xpo_secure_port = svc_sock_secure_port,
 };
 
@@ -1244,6 +1246,145 @@ static struct svc_xprt_class svc_tcp_bc_class = {
 };
 
 #ifdef CONFIG_SUNRPC_XPRT_VSOCK
+/*
+ * A data_ready event on a listening socket means there's a connection
+ * pending. Do not use state_change as a substitute for it.
+ */
+static void svc_vsock_listen_data_ready(struct sock *sk)
+{
+	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq;
+
+	dprintk("svc: socket %p AF_VSOCK (listen) state change %d\n",
+		sk, sk->sk_state);
+
+	/*
+	 * This callback may called twice when a new connection
+	 * is established as a child socket inherits everything
+	 * from a parent VSOCK_SS_LISTEN socket.
+	 * 1) data_ready method of the parent socket will be called
+	 *    when one of child sockets become SS_CONNECTED.
+	 * 2) data_ready method of the child socket may be called
+	 *    when it receives data before the socket is accepted.
+	 * In case of 2, we should ignore it silently.
+	 */
+	if (sk->sk_state == VSOCK_SS_LISTEN) {
+		if (svsk) {
+			set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
+			svc_xprt_enqueue(&svsk->sk_xprt);
+		} else
+			printk("svc: socket %p: no user data\n", sk);
+	}
+
+	wq = sk_sleep(sk);
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible_all(wq);
+}
+
+/*
+ * A state change on a connected socket means it's dying or dead.
+ */
+static void svc_vsock_state_change(struct sock *sk)
+{
+	struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq = sk_sleep(sk);
+
+	dprintk("svc: socket %p AF_VSOCK (connected) state change %d (svsk %p)\n",
+		sk, sk->sk_state, sk->sk_user_data);
+
+	if (!svsk)
+		printk("svc: socket %p: no user data\n", sk);
+	else {
+		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+		svc_xprt_enqueue(&svsk->sk_xprt);
+	}
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible_all(wq);
+}
+
+static void svc_vsock_data_ready(struct sock *sk)
+{
+	struct svc_sock *svsk = (struct svc_sock *)sk->sk_user_data;
+	wait_queue_head_t *wq = sk_sleep(sk);
+
+	dprintk("svc: socket %p AF_VSOCK data ready (svsk %p)\n",
+		sk, sk->sk_user_data);
+	if (svsk) {
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		svc_xprt_enqueue(&svsk->sk_xprt);
+	}
+	if (wq && waitqueue_active(wq))
+		wake_up_interruptible(wq);
+}
+
+static int svc_vsock_has_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
+
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags))
+		return 1;
+	return !test_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+}
+
+static struct svc_xprt *svc_vsock_create(struct svc_serv *serv,
+					 struct net *net,
+					 struct sockaddr *sa, int salen,
+					 int flags)
+{
+	return svc_create_socket(serv, 0, net, sa, salen, flags);
+}
+
+static struct svc_xprt_ops svc_vsock_ops = {
+	.xpo_create = svc_vsock_create,
+	.xpo_recvfrom = svc_tcp_recvfrom,
+	.xpo_sendto = svc_tcp_sendto,
+	.xpo_release_rqst = svc_release_skb,
+	.xpo_detach = svc_common_sock_detach,
+	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_stream_prep_reply_hdr,
+	.xpo_has_wspace = svc_vsock_has_wspace,
+	.xpo_accept = svc_common_accept,
+	.xpo_secure_port = svc_sock_secure_port,
+};
+
+static struct svc_xprt_class svc_vsock_class = {
+	.xcl_name = "vsock",
+	.xcl_owner = THIS_MODULE,
+	.xcl_ops = &svc_vsock_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD,
+	.xcl_ident = XPRT_TRANSPORT_VSOCK,
+};
+
+static void svc_vsock_init(struct svc_sock *svsk, struct svc_serv *serv)
+{
+	struct sock *sk = svsk->sk_sk;
+
+	svc_xprt_init(sock_net(svsk->sk_sock->sk), &svc_vsock_class,
+		      &svsk->sk_xprt, serv);
+	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
+	if (sk->sk_state == VSOCK_SS_LISTEN) {
+		dprintk("setting up AF_VSOCK socket for listening\n");
+		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
+		sk->sk_data_ready = svc_vsock_listen_data_ready;
+		set_bit(XPT_CONN, &svsk->sk_xprt.xpt_flags);
+	} else {
+		dprintk("setting up AF_VSOCK socket for reading\n");
+		sk->sk_state_change = svc_vsock_state_change;
+		sk->sk_data_ready = svc_vsock_data_ready;
+		sk->sk_write_space = svc_write_space;
+
+		svsk->sk_reclen = 0;
+		svsk->sk_tcplen = 0;
+		svsk->sk_datalen = 0;
+		memset(&svsk->sk_pages[0], 0, sizeof(svsk->sk_pages));
+
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+		if (sk->sk_state != SS_CONNECTED)
+			set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	}
+}
+
 static void svc_bc_vsock_sock_detach(struct svc_xprt *xprt)
 {
 }
@@ -1252,7 +1393,7 @@ static struct svc_xprt_ops svc_vsock_bc_ops = {
 	.xpo_create = svc_bc_create_socket,
 	.xpo_detach = svc_bc_vsock_sock_detach,
 	.xpo_free = svc_bc_sock_free,
-	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_prep_reply_hdr = svc_stream_prep_reply_hdr,
 	.xpo_secure_port = svc_sock_secure_port,
 };
 
@@ -1294,11 +1435,11 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release_rqst = svc_release_skb,
-	.xpo_detach = svc_tcp_sock_detach,
+	.xpo_detach = svc_common_sock_detach,
 	.xpo_free = svc_sock_free,
-	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_prep_reply_hdr = svc_stream_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
-	.xpo_accept = svc_tcp_accept,
+	.xpo_accept = svc_common_accept,
 	.xpo_secure_port = svc_sock_secure_port,
 	.xpo_kill_temp_xprt = svc_tcp_kill_temp_xprt,
 };
@@ -1315,6 +1456,9 @@ void svc_init_xprt_sock(void)
 {
 	svc_reg_xprt_class(&svc_tcp_class);
 	svc_reg_xprt_class(&svc_udp_class);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	svc_reg_xprt_class(&svc_vsock_class);
+#endif
 	svc_init_bc_xprt_sock();
 }
 
@@ -1322,6 +1466,9 @@ void svc_cleanup_xprt_sock(void)
 {
 	svc_unreg_xprt_class(&svc_tcp_class);
 	svc_unreg_xprt_class(&svc_udp_class);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	svc_unreg_xprt_class(&svc_vsock_class);
+#endif
 	svc_cleanup_bc_xprt_sock();
 }
 
@@ -1417,6 +1564,10 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
 		svc_udp_init(svsk, serv);
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	else if (inet->sk_family == AF_VSOCK)
+		svc_vsock_init(svsk, serv);
+#endif
 	else
 		svc_tcp_init(svsk, serv);
 
@@ -1468,13 +1619,22 @@ int svc_addsock(struct svc_serv *serv, const int fd, char *name_return,
 
 	if (!so)
 		return err;
-	err = -EAFNOSUPPORT;
-	if ((so->sk->sk_family != PF_INET) && (so->sk->sk_family != PF_INET6))
-		goto out;
-	err =  -EPROTONOSUPPORT;
-	if (so->sk->sk_protocol != IPPROTO_TCP &&
-	    so->sk->sk_protocol != IPPROTO_UDP)
+	err = -EPROTONOSUPPORT;
+	switch (so->sk->sk_family) {
+	case PF_INET:
+	case PF_INET6:
+		if (so->sk->sk_protocol != IPPROTO_TCP &&
+		    so->sk->sk_protocol != IPPROTO_UDP)
+			goto out;
+		break;
+	case PF_VSOCK:
+		if (so->sk->sk_protocol != 0)
+			goto out;
+		break;
+	default:
+		err = -EAFNOSUPPORT;
 		goto out;
+	}
 	err = -EISCONN;
 	if (so->state > SS_UNCONNECTED)
 		goto out;
@@ -1521,7 +1681,8 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 			serv->sv_program->pg_name, protocol,
 			__svc_print_addr(sin, buf, sizeof(buf)));
 
-	if (protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
+	if (sin->sa_family != AF_VSOCK &&
+	    protocol != IPPROTO_UDP && protocol != IPPROTO_TCP) {
 		printk(KERN_WARNING "svc: only UDP and TCP "
 				"sockets supported\n");
 		return ERR_PTR(-EINVAL);
@@ -1535,6 +1696,11 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	case AF_INET:
 		family = PF_INET;
 		break;
+#ifdef CONFIG_SUNRPC_XPRT_VSOCK
+	case AF_VSOCK:
+		family = PF_VSOCK;
+		break;
+#endif
 	default:
 		return ERR_PTR(-EINVAL);
 	}
@@ -1566,7 +1732,7 @@ static struct svc_xprt *svc_create_socket(struct svc_serv *serv,
 	if (error < 0)
 		goto bummer;
 
-	if (protocol == IPPROTO_TCP) {
+	if (type == SOCK_STREAM) {
 		if ((error = kernel_listen(sock, 64)) < 0)
 			goto bummer;
 	}
@@ -1607,11 +1773,11 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 /*
  * Disconnect the socket, and reset the callbacks
  */
-static void svc_tcp_sock_detach(struct svc_xprt *xprt)
+static void svc_common_sock_detach(struct svc_xprt *xprt)
 {
 	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
 
-	dprintk("svc: svc_tcp_sock_detach(%p)\n", svsk);
+	dprintk("svc: %s(%p)\n", __func__, svsk);
 
 	svc_sock_detach(xprt);
 
-- 
2.9.4

