From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: reduce copying data in svc_udp_recvfrom
Date: Mon, 18 Nov 2002 10:45:59 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15832.10807.339070.614753@notabene.cse.unsw.edu.au>
References: <20021115.131641.98855378.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DZ79-0006gs-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Nov 2002 15:46:08 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Mon, 18 Nov 2002 10:46:01 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 15
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

On Friday November 15, taka@valinux.co.jp wrote:
> Hello Neil,
> 
> rqstp->rq_arg.head[0] can use data in a skbuff directly instead of
> copying the data into xdr when the skbuff is linear.
> New kNFSd can do it like old kNFSd did.
> 
> Is there any problem?

Only one:-)

In the case where the skb is nonlinear you skb_free_datagram before
the port/address are copies into rqstp->rq_addr.

Apart from that, the patch is fine, thanks.

Here is my version.

NeilBrown

--------------------------------------------------
Status: compiles

Avoid copying unfragmented udp NFS requests.

If an NFS request arrives in a linear skb,
we don't need to copy it, particularly if the
network card has already done the DUB checksum.

This patch only copies a request if it is
already non-linear.

 ----------- Diffstat output ------------
 net/sunrpc/svcsock.c |   45 ++++++++++++++++++++++++++++++---------------
 1 files changed, 30 insertions(+), 15 deletions(-)

diff net/sunrpc/svcsock.c~current~ net/sunrpc/svcsock.c
--- net/sunrpc/svcsock.c~current~	2002-11-18 10:24:26.000000000 +1100
+++ net/sunrpc/svcsock.c	2002-11-18 10:40:09.000000000 +1100
@@ -564,16 +564,39 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	set_bit(SK_DATA, &svsk->sk_flags); /* there may be more data... */
 
 	len  = skb->len - sizeof(struct udphdr);
+	rqstp->rq_arg.len = len;
 
-	if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
-		/* checksum error */
-		skb_free_datagram(svsk->sk_sk, skb);
-		svc_sock_received(svsk);
-		return 0;
-	}
+	rqstp->rq_prot        = IPPROTO_UDP;
 
+	/* Get sender address */
+	rqstp->rq_addr.sin_family = AF_INET;
+	rqstp->rq_addr.sin_port = skb->h.uh->source;
+	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+
+	if (skb_is_nonlinear(skb)) {
+		/* we have to copy */
+		if (csum_partial_copy_to_xdr(&rqstp->rq_arg, skb)) {
+			/* checksum error */
+			skb_free_datagram(svsk->sk_sk, skb);
+			svc_sock_received(svsk);
+			return 0;
+		}
+		skb_free_datagram(svsk->sk_sk, skb); 
+	} else {
+		/* we can use it in-place */
+		rqstp->rq_arg.head[0].iov_base = skb->data + sizeof(struct udphdr);
+		rqstp->rq_arg.head[0].iov_len = len;
+		if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
+			if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
+				skb_free_datagram(svsk->sk_sk, skb);
+				svc_sock_received(svsk);
+				return 0;
+			}
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+		}
+		rqstp->rq_skbuff = skb;
+	}
 
-	rqstp->rq_arg.len = len;
 	rqstp->rq_arg.page_base = 0;
 	if (len <= rqstp->rq_arg.head[0].iov_len) {
 		rqstp->rq_arg.head[0].iov_len = len;
@@ -582,14 +605,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 		rqstp->rq_arg.page_len = len - rqstp->rq_arg.head[0].iov_len;
 		rqstp->rq_argused += (rqstp->rq_arg.page_len + PAGE_SIZE - 1)/ PAGE_SIZE;
 	}
-	rqstp->rq_prot        = IPPROTO_UDP;
-
-	/* Get sender address */
-	rqstp->rq_addr.sin_family = AF_INET;
-	rqstp->rq_addr.sin_port = skb->h.uh->source;
-	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
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
