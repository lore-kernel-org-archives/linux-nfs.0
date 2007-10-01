From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 30/35] svc: Removing remaining references to rq_sock in rqstp
Date: Mon, 01 Oct 2007 14:28:36 -0500
Message-ID: <20071001192836.3250.72057.stgit@dell3.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcQwY-0005eX-Ea
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:38 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcQwc-0001CG-J7
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 12:28:43 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
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
index f1ea6f7..0f57426 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -197,10 +197,12 @@ svc_release_skb(struct svc_rqst *rqstp)
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
@@ -429,7 +431,7 @@ svc_wake_up(struct svc_serv *serv)
 			dprintk("svc: daemon %p woken up.\n", rqstp);
 			/*
 			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_sock = NULL;
+			rqstp->rq_xprt = NULL;
 			 */
 			wake_up(&rqstp->rq_wait);
 		}
@@ -446,7 +448,9 @@ #define SVC_PKTINFO_SPACE \
 
 static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 			struct in_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -479,7 +483,8 @@ static void svc_set_cmsg_data(struct svc
 static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
 	union {
@@ -552,7 +557,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 	}
 out:
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
-		rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len,
+		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
 		xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
 
 	return len;
@@ -628,7 +633,8 @@ svc_recv_available(struct svc_sock *svsk
 static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
-	struct svc_sock *svsk = rqstp->rq_sock;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
@@ -711,7 +717,9 @@ svc_write_space(struct sock *sk)
 static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 					    struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 		struct in_pktinfo *pki = CMSG_DATA(cmh);
 		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
@@ -731,7 +739,8 @@ static inline void svc_udp_get_dest_addr
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
@@ -1118,7 +1127,8 @@ failed:
 static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
@@ -1281,16 +1291,16 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
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
@@ -1312,7 +1322,7 @@ svc_tcp_prep_reply_hdr(struct svc_rqst *
 static int
 svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
-	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 
@@ -1655,7 +1665,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
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
