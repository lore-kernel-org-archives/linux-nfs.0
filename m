From: Mark Hemment <markhe@veritas.com>
Subject: [PATCH]
Date: Mon, 18 Aug 2003 12:12:08 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0308181207560.1203-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay-bridge.veritas.com ([143.127.3.10] helo=mtvmime01.veritas.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ohup-0006Sa-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 04:11:11 -0700
Received: from localhost.localdomain(markhe.wat.veritas.com[10.10.185.104]) (2640 bytes) by megami
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <markhe@veritas.com>)
	id <m19ohui-00008DC@megami>
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 04:11:04 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  For RPC over UDP, after receiving a packet kick another thread as soon
as possible.  This helps NFS performance.
  Patch is against 2.6.0-test3.

Mark


diff -urNp linux-2.6.0-test3/net/sunrpc/svcsock.c linux-2.6.0-test3-sunrpc/net/sunrpc/svcsock.c
--- linux-2.6.0-test3/net/sunrpc/svcsock.c	2003-08-09 05:32:33.000000000 +0100
+++ linux-2.6.0-test3-sunrpc/net/sunrpc/svcsock.c	2003-08-17 19:42:58.000000000 +0100
@@ -578,8 +578,14 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
+	svsk->sk_sk->sk_stamp = skb->stamp;
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */

+	/*
+	 * Maybe more packets - kick another thread ASAP.
+	 */
+	svc_sock_received(svsk);
+
 	len  = skb->len - sizeof(struct udphdr);
 	rqstp->rq_arg.len = len;

@@ -590,8 +596,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;

-	svsk->sk_sk->sk_stamp = skb->stamp;
-
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
 		local_bh_disable();
@@ -599,7 +603,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			local_bh_enable();
 			/* checksum error */
 			skb_free_datagram(svsk->sk_sk, skb);
-			svc_sock_received(svsk);
 			return 0;
 		}
 		local_bh_enable();
@@ -611,7 +614,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
 			if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 				skb_free_datagram(svsk->sk_sk, skb);
-				svc_sock_received(svsk);
 				return 0;
 			}
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -631,9 +633,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;

-	/* One down, maybe more to go... */
-	svc_sock_received(svsk);
-
 	return len;
 }




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
