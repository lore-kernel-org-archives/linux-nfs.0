From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 14] knfsd: SUNRPC: support IPv6 addresses in
	RPC server's UDP receive path
Date: Wed, 13 Dec 2006 10:59:39 +1100
Message-ID: <1061212235939.21521@suse.de>
References: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GuHWu-0002YR-Le
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:59:24 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GuHWv-0004xm-Er
	for nfs@lists.sourceforge.net; Tue, 12 Dec 2006 15:59:26 -0800
To: Andrew Morton <akpm@osdl.org>
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


From: Chuck Lever <chuck.lever@oracle.com>
Add support for IPv6 addresses in the RPC server's UDP receive path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    5 ++++
 ./net/sunrpc/svcsock.c       |   49 +++++++++++++++++++++++++++++++++++--------
 2 files changed, 46 insertions(+), 8 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2006-12-13 10:32:10.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2006-12-13 10:32:20.000000000 +1100
@@ -267,6 +267,11 @@ static inline struct sockaddr_in *svc_ad
 	return (struct sockaddr_in *) &rqst->rq_addr;
 }
 
+static inline struct sockaddr_in6 *svc_addr_in6(struct svc_rqst *rqst)
+{
+	return (struct sockaddr_in6 *) &rqst->rq_addr;
+}
+
 static inline struct sockaddr *svc_addr(struct svc_rqst *rqst)
 {
 	return (struct sockaddr *) &rqst->rq_addr;

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-12-13 10:32:19.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2006-12-13 10:32:20.000000000 +1100
@@ -717,13 +717,51 @@ svc_write_space(struct sock *sk)
 	}
 }
 
+static void svc_udp_get_sender_address(struct svc_rqst *rqstp,
+					struct sk_buff *skb)
+{
+	switch (rqstp->rq_sock->sk_sk->sk_family) {
+	case AF_INET:
+		/* this seems to come from net/ipv4/udp.c:udp_recvmsg */
+		do {
+			struct sockaddr_in *sin = svc_addr_in(rqstp);
+
+			sin->sin_family = AF_INET;
+			sin->sin_port = skb->h.uh->source;
+			sin->sin_addr.s_addr = skb->nh.iph->saddr;
+			rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
+		} while (0);
+		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case AF_INET6:
+		/* this is derived from net/ipv6/udp.c:udpv6_recvmesg */
+		do {
+			struct sockaddr_in6 *sin6 = svc_addr_in6(rqstp);
+
+			sin6->sin6_family = AF_INET6;
+			sin6->sin6_port = skb->h.uh->source;
+			sin6->sin6_flowinfo = 0;
+			sin6->sin6_scope_id = 0;
+			if (ipv6_addr_type(&sin6->sin6_addr) &
+							IPV6_ADDR_LINKLOCAL)
+				sin6->sin6_scope_id = IP6CB(skb)->iif;
+			ipv6_addr_copy(&sin6->sin6_addr,
+							&skb->nh.ipv6h->saddr);
+			ipv6_addr_copy(&rqstp->rq_daddr.addr6,
+							&skb->nh.ipv6h->saddr);
+		} while (0);
+		break;
+#endif
+	}
+	return;
+}
+
 /*
  * Receive a datagram from a UDP socket.
  */
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *sin = svc_addr_in(rqstp);
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
@@ -775,14 +813,9 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	len  = skb->len - sizeof(struct udphdr);
 	rqstp->rq_arg.len = len;
+	rqstp->rq_prot = IPPROTO_UDP;
 
-	rqstp->rq_prot        = IPPROTO_UDP;
-
-	/* Get sender address */
-	sin->sin_family = AF_INET;
-	sin->sin_port = skb->h.uh->source;
-	sin->sin_addr.s_addr = skb->nh.iph->saddr;
-	rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
+	svc_udp_get_sender_address(rqstp, skb);
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
