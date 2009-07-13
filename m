From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: handle IPv6 PKTINFO when extracting destination
	address
Date: Mon, 13 Jul 2009 10:54:26 -0400
Message-ID: <20090713145352.2177.8095.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:58802
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756077AbZGMOyu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2009 10:54:50 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PKTINFO is needed to scrape the caller's IP address off the socket so
RPC datagram replies are routed correctly.  Fill in missing pieces in
the kernel RPC server's UDP receive path to request IPv6 PKTINFO and
correctly parse the IPv6 cmsg header.

Without this patch, kernel RPC services drop all incoming requests on
UDP on IPv6.

Related commit: 7a37f5787e76bf1765c1add3a9a7163f841a28bb

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>
---

Hi Bruce-

For 2.6.32.

 net/sunrpc/svcsock.c |   84 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 56 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 23128ee..99a826d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -432,29 +432,49 @@ static void svc_tcp_write_space(struct sock *sk)
 }
 
 /*
+ * See net/ipv6/ip_sockglue.c : ip_cmsg_recv_pktinfo
+ */
+static int svc_udp_get_dest_address4(struct svc_rqst *rqstp,
+				     struct cmsghdr *cmh)
+{
+	struct in_pktinfo *pki = CMSG_DATA(cmh);
+	if (cmh->cmsg_type != IP_PKTINFO)
+		return 0;
+	rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
+	return 1;
+}
+
+/*
+ * See net/ipv6/datagram.c : datagram_recv_ctl
+ */
+static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
+				     struct cmsghdr *cmh)
+{
+	struct in6_pktinfo *pki = CMSG_DATA(cmh);
+	if (cmh->cmsg_type != IPV6_PKTINFO)
+		return 0;
+	ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
+	return 1;
+}
+
+/*
  * Copy the UDP datagram's destination address to the rqstp structure.
  * The 'destination' address in this case is the address to which the
  * peer sent the datagram, i.e. our local address. For multihomed
  * hosts, this can change from msg to msg. Note that only the IP
  * address changes, the port number should remain the same.
  */
-static void svc_udp_get_dest_address(struct svc_rqst *rqstp,
-				     struct cmsghdr *cmh)
+static int svc_udp_get_dest_address(struct svc_rqst *rqstp,
+				    struct cmsghdr *cmh)
 {
-	struct svc_sock *svsk =
-		container_of(rqstp->rq_xprt, struct svc_sock, sk_xprt);
-	switch (svsk->sk_sk->sk_family) {
-	case AF_INET: {
-		struct in_pktinfo *pki = CMSG_DATA(cmh);
-		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
-		break;
-		}
-	case AF_INET6: {
-		struct in6_pktinfo *pki = CMSG_DATA(cmh);
-		ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
-		break;
-		}
+	switch (cmh->cmsg_level) {
+	case SOL_IP:
+		return svc_udp_get_dest_address4(rqstp, cmh);
+	case SOL_IPV6:
+		return svc_udp_get_dest_address6(rqstp, cmh);
 	}
+
+	return 0;
 }
 
 /*
@@ -531,16 +551,15 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_prot = IPPROTO_UDP;
 
-	if (cmh->cmsg_level != IPPROTO_IP ||
-	    cmh->cmsg_type != IP_PKTINFO) {
+	if (!svc_udp_get_dest_address(rqstp, cmh)) {
 		if (net_ratelimit())
-			printk("rpcsvc: received unknown control message:"
-			       "%d/%d\n",
-			       cmh->cmsg_level, cmh->cmsg_type);
+			printk(KERN_WARNING
+				"svc: received unknown control message %d/%d; "
+				"dropping RPC reply datagram\n",
+					cmh->cmsg_level, cmh->cmsg_type);
 		skb_free_datagram(svsk->sk_sk, skb);
 		return 0;
 	}
-	svc_udp_get_dest_address(rqstp, cmh);
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
@@ -651,8 +670,7 @@ static struct svc_xprt_class svc_udp_class = {
 
 static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
-	int one = 1;
-	mm_segment_t oldfs;
+	int err, level, optname, one = 1;
 
 	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
 	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
@@ -671,12 +689,22 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 
-	oldfs = get_fs();
-	set_fs(KERNEL_DS);
 	/* make sure we get destination address info */
-	svsk->sk_sock->ops->setsockopt(svsk->sk_sock, IPPROTO_IP, IP_PKTINFO,
-				       (char __user *)&one, sizeof(one));
-	set_fs(oldfs);
+	switch (svsk->sk_sk->sk_family) {
+	case AF_INET:
+		level = SOL_IP;
+		optname = IP_PKTINFO;
+		break;
+	case AF_INET6:
+		level = SOL_IPV6;
+		optname = IPV6_RECVPKTINFO;
+		break;
+	default:
+		BUG();
+	}
+	err = kernel_setsockopt(svsk->sk_sock, level, optname,
+					(char *)&one, sizeof(one));
+	dprintk("svc: kernel_setsockopt returned %d\n", err);
 }
 
 /*

