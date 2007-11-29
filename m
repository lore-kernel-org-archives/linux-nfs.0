From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 30/38] svc: Removing remaining references to rq_sock in rqstp
Date: Thu, 29 Nov 2007 16:56:41 -0600
Message-ID: <20071129225641.15275.51031.stgit@dell3.ogc.int>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47422 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763179AbXK2XUO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:14 -0500
In-Reply-To: <20071129225510.15275.82660.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This functionally empty patch removes rq_sock and unamed union 
from rqstp structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h |    5 +----
 net/sunrpc/svcsock.c       |   38 ++++++++++++++++++++++++--------------
 2 files changed, 25 insertions(+), 18 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 40adc9d..04eb20e 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -204,10 +204,7 @@ union svc_addr_u {
 struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct list_head	rq_all;		/* all threads list */
-	union {
-		struct svc_xprt *	rq_xprt;	/* transport ptr */
-		struct svc_sock *	rq_sock; 	/* socket ptr */
-	};
+	struct svc_xprt *	rq_xprt;	/* transport ptr */
 	struct sockaddr_storage	rq_addr;	/* peer address */
 	size_t			rq_addrlen;
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 8f0ceef..c4b2a5e 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -201,10 +201,12 @@ static void svc_release_skb(struct svc_rqst *rqstp)
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
 	if (skb) {
+		struct svc_sock *svsk =
+			container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 		rqstp->rq_xprt_ctxt = NULL;
 
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
-		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
+		skb_free_datagram(svsk->sk_sk, skb);
 	}
 	if (dr) {
 		rqstp->rq_deferred = NULL;
@@ -433,7 +435,7 @@ svc_wake_up(struct svc_serv *serv)
 			dprintk("svc: daemon %p woken up.\n", rqstp);
 			/*
 			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_sock = NULL;
+			rqstp->rq_xprt = NULL;
 			 */
 			wake_up(&rqstp->rq_wait);
 		}
@@ -450,7 +452,9 @@ union svc_pktinfo_u {
 
 static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 			struct in_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -483,7 +487,8 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
 	union {
@@ -556,7 +561,7 @@ svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	}
 out:
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
-		rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len,
+		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
 		xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
 
 	return len;
@@ -632,7 +637,8 @@ svc_recv_available(struct svc_sock *svsk)
 static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
-	struct svc_sock *svsk = rqstp->rq_sock;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
@@ -722,7 +728,9 @@ svc_write_space(struct sock *sk)
 static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 				     struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 		struct in_pktinfo *pki = CMSG_DATA(cmh);
 		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
@@ -742,7 +750,8 @@ static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
@@ -1126,7 +1135,8 @@ failed:
 static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
@@ -1290,16 +1300,16 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	reclen = htonl(0x80000000|((xbufp->len ) - 4));
 	memcpy(xbufp->head[0].iov_base, &reclen, 4);
 
-	if (test_bit(XPT_DEAD, &rqstp->rq_sock->sk_xprt.xpt_flags))
+	if (test_bit(XPT_DEAD, &rqstp->rq_xprt->xpt_flags))
 		return -ENOTCONN;
 
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",
-		       rqstp->rq_sock->sk_xprt.xpt_server->sv_name,
+		       rqstp->rq_xprt->xpt_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
-		set_bit(XPT_CLOSE, &rqstp->rq_sock->sk_xprt.xpt_flags);
+		set_bit(XPT_CLOSE, &rqstp->rq_xprt->xpt_flags);
 		svc_xprt_enqueue(rqstp->rq_xprt);
 		sent = -EAGAIN;
 	}
@@ -1319,7 +1329,7 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
-	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 
@@ -1641,7 +1651,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 void
 svc_drop(struct svc_rqst *rqstp)
 {
-	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
+	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
 	svc_xprt_release(rqstp);
 }
 
