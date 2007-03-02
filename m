From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 3] knfsd: Use recv_msg to get peer address for
	NFSD instead of code-copying
Date: Fri, 2 Mar 2007 15:28:25 +1100
Message-ID: <1070302042825.5760@suse.de>
References: <20070302151748.5226.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMzOc-0002IM-Qg
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:29:32 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HMzOe-0000Me-4D
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:29:32 -0800
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


The sunrpc server code needs to know the source and destination address
for UDP packets so it can reply properly. 
It currently copies code out of the network stack to pick the pieces out
of the skb.
This is ugly and causes compile problems with the IPv6 stuff.

So, rip that out and use recv_msg instead.  This is a much cleaner
interface, but has a slight cost in that the checksum is now checked
before the copy, so we don't benefit from doing both at the same time.
This can probably be fixed.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   63 ++++++++++++++++++++++++-------------------------
 1 file changed, 31 insertions(+), 32 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-03-02 14:20:14.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-03-02 15:12:52.000000000 +1100
@@ -721,45 +721,23 @@ svc_write_space(struct sock *sk)
 	}
 }
 
-static void svc_udp_get_sender_address(struct svc_rqst *rqstp,
-					struct sk_buff *skb)
+static inline void svc_udp_get_dest_address(struct svc_rqst *rqstp,
+					    struct cmsghdr *cmh)
 {
 	switch (rqstp->rq_sock->sk_sk->sk_family) {
 	case AF_INET: {
-		/* this seems to come from net/ipv4/udp.c:udp_recvmsg */
-			struct sockaddr_in *sin = svc_addr_in(rqstp);
-
-			sin->sin_family = AF_INET;
-			sin->sin_port = skb->h.uh->source;
-			sin->sin_addr.s_addr = skb->nh.iph->saddr;
-			rqstp->rq_addrlen = sizeof(struct sockaddr_in);
-			/* Remember which interface received this request */
-			rqstp->rq_daddr.addr.s_addr = skb->nh.iph->daddr;
-		}
+		struct in_pktinfo *pki = CMSG_DATA(cmh);
+		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
 		break;
+		}
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6: {
-		/* this is derived from net/ipv6/udp.c:udpv6_recvmesg */
-			struct sockaddr_in6 *sin6 = svc_addr_in6(rqstp);
-
-			sin6->sin6_family = AF_INET6;
-			sin6->sin6_port = skb->h.uh->source;
-			sin6->sin6_flowinfo = 0;
-			sin6->sin6_scope_id = 0;
-			if (ipv6_addr_type(&sin6->sin6_addr) &
-							IPV6_ADDR_LINKLOCAL)
-				sin6->sin6_scope_id = IP6CB(skb)->iif;
-			ipv6_addr_copy(&sin6->sin6_addr,
-							&skb->nh.ipv6h->saddr);
-			rqstp->rq_addrlen = sizeof(struct sockaddr_in);
-			/* Remember which interface received this request */
-			ipv6_addr_copy(&rqstp->rq_daddr.addr6,
-							&skb->nh.ipv6h->saddr);
-		}
+		struct in6_pktinfo *pki = CMSG_DATA(cmh);
+		ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
 		break;
+		}
 #endif
 	}
-	return;
 }
 
 /*
@@ -771,7 +749,15 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
+	char		buffer[CMSG_SPACE(sizeof(union svc_pktinfo_u))];
+	struct cmsghdr *cmh = (struct cmsghdr *)buffer;
 	int		err, len;
+	struct msghdr msg = {
+		.msg_name = svc_addr(rqstp),
+		.msg_control = cmh,
+		.msg_controllen = sizeof(buffer),
+		.msg_flags = MSG_DONTWAIT,
+	};
 
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
 	    /* udp sockets need large rcvbuf as all pending
@@ -797,7 +783,9 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
-	while ((skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
+	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
+				      0, 0, MSG_PEEK)) < 0 ||
+	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
 		if (err == -EAGAIN) {
 			svc_sock_received(svsk);
 			return err;
@@ -805,6 +793,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
+	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	if (skb->tstamp.off_sec == 0) {
 		struct timeval tv;
 
@@ -827,7 +816,7 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 
 	rqstp->rq_prot = IPPROTO_UDP;
 
-	svc_udp_get_sender_address(rqstp, skb);
+	svc_udp_get_dest_address(rqstp, cmh);
 
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
@@ -884,6 +873,9 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 static void
 svc_udp_init(struct svc_sock *svsk)
 {
+	int one = 1;
+	mm_segment_t oldfs;
+
 	svsk->sk_sk->sk_data_ready = svc_udp_data_ready;
 	svsk->sk_sk->sk_write_space = svc_write_space;
 	svsk->sk_recvfrom = svc_udp_recvfrom;
@@ -899,6 +891,13 @@ svc_udp_init(struct svc_sock *svsk)
 
 	set_bit(SK_DATA, &svsk->sk_flags); /* might have come in before data_ready set up */
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
+
+	oldfs = get_fs();
+	set_fs(KERNEL_DS);
+	/* make sure we get destination address info */
+	svsk->sk_sock->ops->setsockopt(svsk->sk_sock, IPPROTO_IP, IP_PKTINFO,
+				       (char __user *)&one, sizeof(one));
+	set_fs(oldfs);
 }
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
