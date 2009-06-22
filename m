From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] SUNRPC: handle IPv6 PKTINFO when extracting destination
	address
Date: Mon, 22 Jun 2009 10:17:10 -0700
Message-ID: <20090622171433.3085.11419.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:54872 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbZFVRRi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 13:17:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PKTINFO is needed to scrape the caller's IP address off the socket so
RPC replies are routed correctly.

Fill in missing pieces in the kernel RPC server's UDP receive path to
request IPv6 PKTINFO and correctly parse the IPv6 cmsg header.

Related commit: 7a37f5787e76bf1765c1add3a9a7163f841a28bb

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Neil-

I spotted this one last week at Bake-a-thon.  Does this look reasonable?

 net/sunrpc/svcsock.c |   83 +++++++++++++++++++++++++++++++++-----------------
 1 files changed, 55 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 004a2f9..f59e64f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -422,29 +422,49 @@ static void svc_write_space(struct sock *sk)
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
@@ -521,16 +541,14 @@ static int svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_prot = IPPROTO_UDP;
 
-	if (cmh->cmsg_level != IPPROTO_IP ||
-	    cmh->cmsg_type != IP_PKTINFO) {
+	if (!svc_udp_get_dest_address(rqstp, cmh)) {
 		if (net_ratelimit())
-			printk("rpcsvc: received unknown control message:"
-			       "%d/%d\n",
-			       cmh->cmsg_level, cmh->cmsg_type);
+			printk(KERN_WARNING
+				"svc: received unknown control message:"
+				" %d/%d\n", cmh->cmsg_level, cmh->cmsg_type);
 		skb_free_datagram(svsk->sk_sk, skb);
 		return 0;
 	}
-	svc_udp_get_dest_address(rqstp, cmh);
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
@@ -641,8 +659,7 @@ static struct svc_xprt_class svc_udp_class = {
 
 static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
-	int one = 1;
-	mm_segment_t oldfs;
+	int err, level, optname, one = 1;
 
 	svc_xprt_init(&svc_udp_class, &svsk->sk_xprt, serv);
 	clear_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
@@ -661,12 +678,22 @@ static void svc_udp_init(struct svc_sock *svsk, struct svc_serv *serv)
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

