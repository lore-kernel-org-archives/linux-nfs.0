From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 3 - Release udp socket for next nfs request to arrive earlier
Date: Tue, 19 Aug 2003 14:35:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19oyD8-0001HP-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19oyDK-00063j-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 21:35:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 19 Aug 2003 14:35:12 +1000
To: Linus Torvalds <torvalds@osdl.org>
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

### Comments for ChangeSet

From: Mark Hemment <markhe@veritas.com>
  For RPC over UDP, after receiving a packet kick another thread as soon
as possible.  This helps NFS performance.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-08-18 09:53:17.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-08-19 08:49:47.000000000 +1000
@@ -592,8 +592,14 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
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
 
@@ -605,8 +611,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
 	rqstp->rq_daddr = skb->nh.iph->daddr;
 
-	svsk->sk_sk->sk_stamp = skb->stamp;
-
 	if (skb_is_nonlinear(skb)) {
 		/* we have to copy */
 		local_bh_disable();
@@ -614,7 +618,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 			local_bh_enable();
 			/* checksum error */
 			skb_free_datagram(svsk->sk_sk, skb);
-			svc_sock_received(svsk);
 			return 0;
 		}
 		local_bh_enable();
@@ -626,7 +629,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
 			if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 				skb_free_datagram(svsk->sk_sk, skb);
-				svc_sock_received(svsk);
 				return 0;
 			}
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -646,9 +648,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
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
