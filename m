From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 079/100] svc: Removing remaining references to rq_sock in rqstp
Date: Fri, 25 Jan 2008 18:16:59 -0500
Message-ID: <1201303040-7779-79-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762174AbYAYXSS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:18 -0500
In-Reply-To: <1201303040-7779-78-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This functionally empty patch removes rq_sock and unamed union
from rqstp structure.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
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
index db9a541..03aa392 100644
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
@@ -418,7 +420,7 @@ svc_wake_up(struct svc_serv *serv)
 			dprintk("svc: daemon %p woken up.\n", rqstp);
 			/*
 			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_sock = NULL;
+			rqstp->rq_xprt = NULL;
 			 */
 			wake_up(&rqstp->rq_wait);
 		}
@@ -435,7 +437,9 @@ union svc_pktinfo_u {
 
 static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 {
-	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
+	switch (svsk->sk_sk->sk_family) {
 	case AF_INET: {
 			struct in_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -468,7 +472,8 @@ static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
 static int
 svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct socket	*sock = svsk->sk_sock;
 	int		slen;
 	union {
@@ -541,7 +546,7 @@ svc_sendto(struct svc_rqst *rqstp, struct xdr_buf *xdr)
 	}
 out:
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %s)\n",
-		rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len,
+		svsk, xdr->head[0].iov_base, xdr->head[0].iov_len,
 		xdr->len, len, svc_print_addr(rqstp, buf, sizeof(buf)));
 
 	return len;
@@ -617,7 +622,8 @@ svc_recv_available(struct svc_sock *svsk)
 static int
 svc_recvfrom(struct svc_rqst *rqstp, struct kvec *iov, int nr, int buflen)
 {
-	struct svc_sock *svsk = rqstp->rq_sock;
+	struct svc_sock *svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct msghdr msg = {
 		.msg_flags	= MSG_DONTWAIT,
 	};
@@ -707,7 +713,9 @@ svc_write_space(struct sock *sk)
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
@@ -727,7 +735,8 @@ static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	struct sk_buff	*skb;
 	union {
@@ -1109,7 +1118,8 @@ failed:
 static int
 svc_tcp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct svc_sock	*svsk = rqstp->rq_sock;
+	struct svc_sock	*svsk =
+		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int		len;
 	struct kvec *vec;
@@ -1273,16 +1283,16 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
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
@@ -1302,7 +1312,7 @@ static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
 
 static int svc_tcp_has_wspace(struct svc_xprt *xprt)
 {
-	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+	struct svc_sock *svsk =	container_of(xprt, struct svc_sock, sk_xprt);
 	struct svc_serv	*serv = svsk->sk_xprt.xpt_server;
 	int required;
 	int wspace;
@@ -1625,7 +1635,7 @@ svc_recv(struct svc_rqst *rqstp, long timeout)
 void
 svc_drop(struct svc_rqst *rqstp)
 {
-	dprintk("svc: socket %p dropped request\n", rqstp->rq_sock);
+	dprintk("svc: xprt %p dropped request\n", rqstp->rq_xprt);
 	svc_xprt_release(rqstp);
 }
 
-- 
1.5.4.rc2.60.gb2e62

