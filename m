From: Olaf Kirch <olaf.kirch@oracle.com>
Subject: [PATCH - try #2] sunrpc: fix typo in svc_udp_recvfrom
Date: Tue, 27 Mar 2007 17:39:42 +0200
Message-ID: <200703271739.43675.olaf.kirch@oracle.com>
References: <200703271651.13181.olaf.kirch@oracle.com>
	<1175008207.6153.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWDnK-0008Tm-4y
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:41:10 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWDnL-0001hd-28
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 08:41:12 -0700
In-Reply-To: <1175008207.6153.12.camel@heimdal.trondhjem.org>
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

On Tuesday 27 March 2007 17:10, Trond Myklebust wrote:
> Could you please rather move those assignments out of the while()? Good
> coding style dictates that the above should be avoided. One of the
> benefits is precisely to avoid the above ambiguities.

Okay, here we go:
----------------------
Fix a typo in svc_udp_recvfrom

This patch corrects a small and harmless typo in svc_udp_recvfrom.

Signed-off-by: olaf.kirch@oracle.com
---
 net/sunrpc/svcsock.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

Index: linux-2.6/net/sunrpc/svcsock.c
===================================================================
--- linux-2.6.orig/net/sunrpc/svcsock.c
+++ linux-2.6/net/sunrpc/svcsock.c
@@ -779,9 +779,14 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
-	while ((err == kernel_recvmsg(svsk->sk_sock, &msg, NULL,
-				      0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
-	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
+	while (1) {
+		err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
+				      0, 0, MSG_PEEK | MSG_DONTWAIT);
+		if (err >= 0) {
+		       	skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
+			if (skb)
+				break;
+		}
 		if (err == -EAGAIN) {
 			svc_sock_received(svsk);
 			return err;


-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
