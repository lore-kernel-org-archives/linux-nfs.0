From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: reduce copying data in svc_udp_recvfrom
Date: Fri, 15 Nov 2002 13:16:41 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021115.131641.98855378.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com ([198.186.202.147])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18CaIO-00069G-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 22:49:40 -0800
Received: from sv1.valinux.co.jp ([202.221.173.100]:1219)
	by panoramix.vasoftware.com with esmtp (Exim 4.05-VA-mm1 #1 (Debian))
	id 18CY3I-0000hD-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Nov 2002 20:25:56 -0800
To: <neilb@cse.unsw.edu.au>
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

Hello Neil,

rqstp->rq_arg.head[0] can use data in a skbuff directly instead of
copying the data into xdr when the skbuff is linear.
New kNFSd can do it like old kNFSd did.

Is there any problem?

Thank you,
Hirokazu Takahashi.


--- net/sunrpc/svcsock.c.NONZERO	Fri Nov 15 11:26:18 2030
+++ net/sunrpc/svcsock.c	Fri Nov 15 11:30:14 2030
@@ -564,21 +564,35 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
 	len  = skb->len - sizeof(struct udphdr);
+	rqstp->rq_arg.len = len;
 
-	if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
-		/* checksum error */
+	if (skb_is_nonlinear(skb)) {
+		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
+			/* checksum error */
+			skb_free_datagram(svsk->sk_sk, skb);
+			svc_sock_received(svsk);
+			return 0;
+		}
+		if (len <= rqstp->rq_arg.head[0].iov_len) {
+			rqstp->rq_arg.head[0].iov_len = len;
+			rqstp->rq_arg.page_len = 0;
+		} else {
+			rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
+			rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
+		}
 		skb_free_datagram(svsk->sk_sk, skb);
-		svc_sock_received(svsk);
-		return 0;
-	}
-
-	rqstp->rq_arg.len = len;
-	if (len <= rqstp->rq_arg.head[0].iov_len) {
-		rqstp->rq_arg.head[0].iov_len = len;
-		rqstp->rq_arg.page_len = 0;
 	} else {
-		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
-		rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
+		if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
+			if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
+				skb_free_datagram(svsk->sk_sk, skb);
+				svc_sock_received(svsk);
+				return 0;
+			}
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+		rqstp->rq_skbuff = skb;
+		rqstp->rq_arg.head[0].iov_base = skb->data + sizeof(struct udphdr);
+		rqstp->rq_arg.head[0].iov_len = len;
 	}
 
 	rqstp->rq_prot        = IPPROTO_UDP;
@@ -587,8 +601,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_addr.sin_family = AF_INET;
 	rqstp->rq_addr.sin_port = skb->h.uh->source;
 	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
-
-	skb_free_datagram(svsk->sk_sk, skb);
 
 	if (serv->sv_stats)
 		serv->sv_stats->netudpcnt++;


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
