From: Ben Myers <bpm@sgi.com>
Subject: [PATCH 2/2] sunrpc: socket buffer size module parameter
Date: Mon, 22 Feb 2010 15:54:47 -0600
Message-ID: <20100222215447.8481.19927.stgit@case>
References: <20100222215349.8481.80700.stgit@case>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:60451 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753769Ab0BVVys (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2010 16:54:48 -0500
Received: from snoot.americas.sgi.com (case.americas.sgi.com [128.162.244.182])
	by relay2.corp.sgi.com (Postfix) with ESMTP id 46C2130409B
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 13:54:48 -0800 (PST)
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by snoot.americas.sgi.com (Postfix) with ESMTP id C665C49F2093
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 15:54:47 -0600 (CST)
In-Reply-To: <20100222215349.8481.80700.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 1020 threads the send buffer size wraps and becomes negative causing the nfs
server to grind to a halt.  Rather than setting bufsize based upon the number
of nfsd threads I have made the buffer sizes tuneable via module parameters.
In other versions of this patch they were sysctls.

Set the buffer sizes in terms of the number of rpcs you want to fit into the
buffer.

Signed-off-by: Ben Myers <bpm@sgi.com>
---
 fs/nfsd/nfsctl.c         |    1 +
 net/sunrpc/sunrpc_syms.c |   39 ++++++++++++++++++++++
 net/sunrpc/svcsock.c     |   81 +++++++++++++++++++++++-----------------------
 3 files changed, 80 insertions(+), 41 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 981366d..bce8df3 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -19,6 +19,7 @@
 /* Default to use existing settings in svc_check_conn_limits */
 unsigned int nfsd_max_connections = 0;
 
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index f438347..a7a80b4 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -26,6 +26,45 @@ extern struct cache_detail ip_map_cache, unix_gid_cache;
 
 extern void cleanup_rpcb_clnt(void);
 
+/*
+ * Size each socket's send and receive buffers based upon the number of rpcs
+ * we'd like to be able to fit into them.  The TCP rcvbuf is enough for just a
+ * few requests.  TCP sndbuf is the same as the tcp_slot_table_entries default,
+ * the maximum number of in-flight rpcs for a client.  UDP sndbuf and rcvbuf
+ * defaults are the same as the udp_slot_table_entries default.
+ *
+ * Setting these too small can cause nfsd threads to block when sending.
+ */
+int            tcp_rcvbuf_nrpc = 6;
+int            tcp_sndbuf_nrpc = 16;
+
+int            udp_rcvbuf_nrpc = 16;
+int            udp_sndbuf_nrpc = 16;
+
+/*
+ * Minimum for bufsize settings is enough space for 6 rpcs, maximum is enough
+ * space for 128 rpcs.
+ */
+static int param_set_bufsize_nrpc(const char *val, struct kernel_param *kp)
+{
+	char	*endp;
+	int 	num = simple_strtol(val, &endp, 0);
+
+	if (endp == val || (*endp && *endp != '\n') || num < 6 || num > 128)
+		return -EINVAL;
+	*((int *)kp->arg) = num;
+	return 0;
+}
+
+module_param_call(tcp_rcvbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
+	          &tcp_rcvbuf_nrpc, 0644);
+module_param_call(tcp_sndbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
+		  &tcp_sndbuf_nrpc, 0644);
+module_param_call(udp_rcvbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
+	          &udp_rcvbuf_nrpc, 0644);
+module_param_call(udp_sndbuf_nrpc, param_set_bufsize_nrpc, param_get_int,
+	          &udp_sndbuf_nrpc, 0644);
+
 static int __init
 init_sunrpc(void)
 {
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 9e09391..f172b27 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -381,8 +381,7 @@ static int svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr,
 /*
  * Set socket snd and rcv buffer lengths
  */
-static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
-				unsigned int rcv)
+static void svc_sock_setbufsize(struct socket *sock, int snd, int rcv)
 {
 #if 0
 	mm_segment_t	oldfs;
@@ -398,13 +397,14 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	 * DaveM said I could!
 	 */
 	lock_sock(sock->sk);
-	sock->sk->sk_sndbuf = snd * 2;
-	sock->sk->sk_rcvbuf = rcv * 2;
+	sock->sk->sk_sndbuf = snd;
+	sock->sk->sk_rcvbuf = rcv;
 	sock->sk->sk_userlocks |= SOCK_SNDBUF_LOCK|SOCK_RCVBUF_LOCK;
 	sock->sk->sk_write_space(sock->sk);
 	release_sock(sock->sk);
 #endif
 }
+
 /*
  * INET callback when data has been received on the socket.
  */
@@ -498,6 +498,7 @@ static int svc_udp_get_dest_address(struct svc_rqst *rqstp,
 	return 0;
 }
 
+extern int udp_sndbuf_nrpc, udp_rcvbuf_nrpc;
 /*
  * Receive a datagram from a UDP socket.
  */
@@ -521,18 +522,16 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 	size_t len;
 	int err;
 
-	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
-	    /* udp sockets need large rcvbuf as all pending
-	     * requests are still in that buffer.  sndbuf must
-	     * also be large enough that there is enough space
-	     * for one reply per thread.  We count all threads
-	     * rather than threads in a particular pool, which
-	     * provides an upper bound on the number of threads
-	     * which will access the socket.
-	     */
-	    svc_sock_setbufsize(svsk->sk_sock,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags)) {
+		/*
+		 * UDP sockets need a large rcvbuf as all pending requests are
+		 * still in that buffer.  sndbuf must also be large enough to
+		 * fit a reply for each request the server could be processing.
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    udp_sndbuf_nrpc * serv->sv_max_mesg,
+				    udp_rcvbuf_nrpc * serv->sv_max_mesg);
+	}
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	skb = NULL;
@@ -697,14 +696,14 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
-
-	/* initialise setting must have enough space to
-	 * receive and respond to one request.
-	 * svc_udp_recvfrom will re-adjust if necessary
+	
+	/*
+	 * Initial setting must have enough space to receive and respond to one
+	 * request.  svc_udp_recvfrom will readjust if necessary.
 	 */
 	svc_sock_setbufsize(svsk->sk_sock,
-			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
-			    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
+			    6 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+			    6 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 	/* data might have come in before data_ready set up */
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
@@ -874,6 +873,7 @@ failed:
 	return NULL;
 }
 
+extern int tcp_sndbuf_nrpc, tcp_rcvbuf_nrpc;
 /*
  * Receive data.
  * If we haven't gotten the record length yet, get the next four bytes.
@@ -885,22 +885,20 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int len;
 
-	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags))
-		/* sndbuf needs to have room for one request
-		 * per thread, otherwise we can stall even when the
-		 * network isn't a bottleneck.
-		 *
-		 * We count all threads rather than threads in a
-		 * particular pool, which provides an upper bound
-		 * on the number of threads which will access the socket.
-		 *
-		 * rcvbuf just needs to be able to hold a few requests.
-		 * Normally they will be removed from the queue
-		 * as soon a a complete request arrives.
+	if (test_and_clear_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags)) {
+		/* 
+		 * sndbuf needs to have enough room for every request the
+		 * server could be processing, otherwise we can block even when
+		 * the network isn't a bottleneck.
+		 *	
+		 * Normally they will be removed from the queue as soon as a
+		 * complete request arrives.
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    (serv->sv_nrthreads+3) * serv->sv_max_mesg,
-				    3 * serv->sv_max_mesg);
+				    tcp_sndbuf_nrpc * serv->sv_max_mesg,
+				    tcp_rcvbuf_nrpc * serv->sv_max_mesg);
+	}
+
 
 	clear_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
@@ -1250,13 +1248,14 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
 
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 * svc_tcp_recvfrom will re-adjust if necessary
+		/*
+		 * Initial setting must have enough space to receive and
+		 * respond to one request.  svc_tcp_recvfrom will readjust if
+		 * necessary.
 		 */
 		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg,
-				    3 * svsk->sk_xprt.xpt_server->sv_max_mesg);
+				    6 * svsk->sk_xprt.xpt_server->sv_max_mesg,
+				    6 * svsk->sk_xprt.xpt_server->sv_max_mesg);
 
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);

