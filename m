From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH]  Fix bug in sunrpc/server code.
Date: Mon, 11 Aug 2003 14:29:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19m4Iq-0002fO-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19m4J3-0004sa-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Aug 2003 21:29:17 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Mon, 11 Aug 2003 14:29:07 +1000
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

When a socket has a request ready it notifies a server thread.
When the thread has 'received' the request it calls svc_sock_received
to confirm the fact.
In some cases, svc_sock_received would be called an extra time and
this could lead to linked-list corruption and bad problems.
Fixed now.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-08-11 13:51:57.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-08-11 13:52:03.000000000 +1000
@@ -567,14 +567,17 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_bufsz,
 				(serv->sv_nrthreads+3) * serv->sv_bufsz);
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk)))
+	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
+		svc_sock_received(svsk);
 		return svc_deferred_recv(rqstp);
+	}
 
 	clear_bit(SK_DATA, &svsk->sk_flags);
 	while ((skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
-		svc_sock_received(svsk);
-		if (err == -EAGAIN)
+		if (err == -EAGAIN) {
+			svc_sock_received(svsk);
 			return err;
+		}
 		/* possibly an icmp error */
 		dprintk("svc: recvfrom returned error %d\n", -err);
 	}
@@ -869,8 +872,10 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(SK_CONN, &svsk->sk_flags),
 		test_bit(SK_CLOSE, &svsk->sk_flags));
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk)))
+	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
+		svc_sock_received(svsk);
 		return svc_deferred_recv(rqstp);
+	}
 
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		svc_delete_socket(svsk);
@@ -1545,6 +1550,5 @@ static struct svc_deferred_req *svc_defe
 		set_bit(SK_DEFERRED, &svsk->sk_flags);
 	}
 	spin_unlock(&serv->sv_lock);
-	svc_sock_received(svsk);
 	return dr;
 }


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
