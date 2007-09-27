From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 30/33] svc: Removing remaining references to rq_sock in rqstp
Date: Thu, 27 Sep 2007 00:02:37 -0500
Message-ID: <20070927050237.12677.84810.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalWK-0005kO-Uj
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:41 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWM-00020D-Tm
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:46 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


This functionally empty patch removes rq_sock and unamed union 
from rqstp structure. 

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svc.h |    5 +----
 net/sunrpc/svcsock.c       |   29 ++++++++++++++++-------------
 2 files changed, 17 insertions(+), 17 deletions(-)

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
index 8a708a8..5ea26b2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -196,10 +196,11 @@ svc_release_skb(struct svc_rqst *rqstp)
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
 	if (skb) {
+		struct svc_sock *svsk = (struct svc_sock *)rqstp->rq_xprt;
 		rqstp->rq_xprt_ctxt = NULL;
 
 		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
-		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
+		skb_free_datagram(svsk->sk_sk, skb);
 	}
 	if (dr) {
 		rqstp->rq_deferred = NULL;
@@ -428,7 +429,7 @@ svc_wake_up(struct svc_serv *serv)
 			dprintk("svc: daemon %p woken up.\n", rqstp);
 			/*
 			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_sock = NULL;
+			rqstp->rq_xprt = NULL;
 			 */
 			wake_up(&rqstp->rq_wait);
 		}
@@ -445,7 +446,8 @@ #define SVC_PKTINFO_SPACE \
 
 static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk = (struct svc_sock *)rqstp->rq_xprt;
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 			struct in_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -478,7 +480,7 @@ static void svc_set_cmsg_data(struct svc
 static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk = (struct svc_sock *)rqstp->rq_xprt;
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
 	union {
@@ -551,7 +553,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	}
 out:
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
-		rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len,
+		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
 		xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
 
 	return len;
@@ -627,7 +629,7 @@ svc_recv_available(struct svc_sock *svsk
 static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
-	struct svc_sock *svsk = rqstp->rq_sock;
+	struct svc_sock *svsk = (struct svc_sock *)rqstp->rq_xprt;
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
@@ -709,7 +711,8 @@ svc_write_space(struct sock *sk)
 static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 					    struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk = (struct svc_sock *)rqstp->rq_xprt;
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 		struct in_pktinfo *pki = CMSG_DATA(cmh);
 		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
@@ -729,7 +732,7 @@ static inline void svc_udp_get_dest_addr
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk = (struct svc_sock *)rqstp->rq_xprt;
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
@@ -1114,7 +1117,7 @@ failed:
 static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk = (struct svc_sock *)rqstp->rq_xprt;
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
@@ -1277,16 +1280,16 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
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
@@ -1650,7 +1653,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 void
 svc_drop(struct svc_rqst *rqstp)
 {
-	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
+	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
 	svc_xprt_release(rqstp);
 }
 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
