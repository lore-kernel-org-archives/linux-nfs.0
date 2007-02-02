From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 14] knfsd: SUNRPC: aplit svc_sock_enqueue out
	of svc_setup_socket.
Date: Fri, 2 Feb 2007 15:39:52 +1100
Message-ID: <1070202043952.18971@suse.de>
References: <20070202153531.18622.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@osdl.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCqDi-00086F-Jo
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:42:57 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCqDk-0007Ue-8F
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 20:40:20 -0800
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


Rather than calling svc_sock_enqueue at the end of svc_setup_socket,
we now call it (via svc_sock_recieved) after calling svc_setup_socket
at each call site.

We do this because a subsequent patch will insert some code between
the two calls at one call site.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-02-02 15:15:11.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-02-02 15:18:37.000000000 +1100
@@ -925,7 +925,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	if (!(newsvsk = svc_setup_socket(serv, newsock, &err,
 				 (SVC_SOCK_ANONYMOUS | SVC_SOCK_TEMPORARY))))
 		goto failed;
-
+	svc_sock_received(newsvsk);
 
 	/* make sure that we don't have too many active connections.
 	 * If we have, something must be dropped.
@@ -1532,8 +1532,6 @@ static struct svc_sock *svc_setup_socket
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);
 
-	clear_bit(SK_BUSY, &svsk->sk_flags);
-	svc_sock_enqueue(svsk);
 	return svsk;
 }
 
@@ -1557,8 +1555,10 @@ int svc_addsock(struct svc_serv *serv,
 		err = -EISCONN;
 	else {
 		svsk = svc_setup_socket(serv, so, &err, SVC_SOCK_DEFAULTS);
-		if (svsk)
+		if (svsk) {
+			svc_sock_received(svsk);
 			err = 0;
+		}
 	}
 	if (err) {
 		sockfd_put(so);
@@ -1609,8 +1609,10 @@ static int svc_create_socket(struct svc_
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL)
+	if ((svsk = svc_setup_socket(serv, sock, &error, flags)) != NULL) {
+		svc_sock_received(svsk);
 		return ntohs(inet_sk(svsk->sk_sk)->sport);
+	}
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
