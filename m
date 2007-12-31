From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH 05/40] svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
Date: Sun, 30 Dec 2007 21:07:23 -0600
Message-ID: <20071231030723.8430.13011.stgit@dell3.ogc.int>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:41480 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751313AbXLaDHX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Dec 2007 22:07:23 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The sk_sendto and sk_recvfrom are function pointers that allow svc_sock
to be used for both UDP and TCP. Move these function pointers to the 
svc_xprt_ops structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc_xprt.h |    2 ++
 include/linux/sunrpc/svcsock.h  |    3 ---
 net/sunrpc/svcsock.c            |   12 ++++++------
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 187dc4e..7ae6c85 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -10,6 +10,8 @@
 #include <linux/sunrpc/svc.h>
 
 struct svc_xprt_ops {
+	int		(*xpo_recvfrom)(struct svc_rqst *);
+	int		(*xpo_sendto)(struct svc_rqst *);
 };
 
 struct svc_xprt_class {
diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 1878cbe..08e78d0 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -45,9 +45,6 @@ struct svc_sock {
 						 * be revisted */
 	struct mutex		sk_mutex;	/* to serialize sending data */
 
-	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
-	int			(*sk_sendto)(struct svc_rqst *rqstp);
-
 	/* We keep the old state_change and data_ready CB's here */
 	void			(*sk_ostate)(struct sock *);
 	void			(*sk_odata)(struct sock *, int bytes);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c507f6f..7817c7e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -901,6 +901,8 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 }
 
 static struct svc_xprt_ops svc_udp_ops = {
+	.xpo_recvfrom = svc_udp_recvfrom,
+	.xpo_sendto = svc_udp_sendto,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -918,8 +920,6 @@ svc_udp_init(struct svc_sock *svsk)
 	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt);
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
-	svsk->sk_recvfrom = svc_udp_recvfrom;
-	svsk->sk_sendto = svc_udp_sendto;
 
 	/* initialise setting must have enough space to
 	 * receive and respond to one request.
@@ -1355,6 +1355,8 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 }
 
 static struct svc_xprt_ops svc_tcp_ops = {
+	.xpo_recvfrom = svc_tcp_recvfrom,
+	.xpo_sendto = svc_tcp_sendto,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
@@ -1382,8 +1384,6 @@ svc_tcp_init(struct svc_sock *svsk)
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	svc_xprt_init(&svc_tcp_class, &svsk->sk_xprt);
-	svsk->sk_recvfrom = svc_tcp_recvfrom;
-	svsk->sk_sendto = svc_tcp_sendto;
 
 	if (sk->sk_state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
@@ -1531,7 +1531,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 		 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-	len = svsk->sk_recvfrom(rqstp);
+	len = svsk->sk_xprt.xpt_ops->xpo_recvfrom(rqstp);
 	dprintk("svc: got len=%d\n", len);
 
 	/* No data, incomplete (TCP) read, or accept() */
@@ -1591,7 +1591,7 @@ svc_send(struct svc_rqst *rqstp)
 	if (test_bit(SK_DEAD, &svsk->sk_flags))
 		len = -ENOTCONN;
 	else
-		len = svsk->sk_sendto(rqstp);
+		len = svsk->sk_xprt.xpt_ops->xpo_sendto(rqstp);
 	mutex_unlock(&svsk->sk_mutex);
 	svc_sock_release(rqstp);
 
