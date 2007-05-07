From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 8] knfsd: Simplify a 'while' condition in
	svcsock.c
Date: Mon, 7 May 2007 10:35:45 +1000
Message-ID: <1070507003545.24158@suse.de>
References: <20070507103211.23855.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrCx-00056k-RH
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:08 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrD0-0002mm-3N
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 17:36:10 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


This while loop has an overly complex condition, which performs a
couple of assignments.  This hurts readability.

We don't really need a loop at all.  We can just return -EAGAIN and
(providing we set SK_DATA), the function will be called again.

So discard the loop, make the complex conditional become a few clear
function calls, and hopefully improve readability.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-05-07 10:30:16.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2007-05-07 10:31:04.000000000 +1000
@@ -788,15 +788,20 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	}
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
-	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
-				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
-	       (skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
-		if (err == -EAGAIN) {
-			svc_sock_received(svsk);
-			return err;
+	skb = NULL;
+	err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
+			     0, 0, MSG_PEEK | MSG_DONTWAIT);
+	if (err >= 0)
+		skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err);
+
+	if (skb == NULL) {
+		if (err != -EAGAIN) {
+			/* possibly an icmp error */
+			dprintk("svc: recvfrom returned error %d\n", -err);
+			set_bit(SK_DATA, &svsk->sk_flags);
 		}
-		/* possibly an icmp error */
-		dprintk("svc: recvfrom returned error %d\n", -err);
+		svc_sock_received(svsk);
+		return -EAGAIN;
 	}
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	if (skb->tstamp.tv64 == 0) {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
