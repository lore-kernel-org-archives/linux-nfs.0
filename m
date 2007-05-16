From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 14/14] knfsd: centralise SK_ bits some more
Date: Thu, 17 May 2007 05:29:24 +1000
Message-ID: <20070516192924.GT9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoPBe-00019d-OX
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:29:26 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoPBg-000571-02
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:29:29 -0700
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


Further centralise the handling of the SK_BUSY, SK_DATA and SK_LISTENER
flags by moving the code which initialises them out of transport
specific code.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svcsock.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 04:10:26.330080170 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 04:12:19.099511550 +1000
@@ -938,7 +938,6 @@ svc_udp_init(struct svc_sock *svsk)
 			    3 * svsk->sk_server->sv_max_mesg,
 			    3 * svsk->sk_server->sv_max_mesg);
 
-	svc_sock_set_data_ready(svsk); /* might have come in before data_ready set up */
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
 
 	oldfs = get_fs();
@@ -1395,8 +1394,6 @@ svc_tcp_init_listener(struct svc_sock *s
 
 	dprintk("setting up TCP socket for listening\n");
 	sk->sk_data_ready = svc_tcp_listen_data_ready;
-	set_bit(SK_LISTENER, &svsk->sk_flags);
-	svc_sock_set_connection_ready(svsk);
 }
 
 static void
@@ -1426,7 +1423,6 @@ svc_tcp_init_connection(struct svc_sock 
 			    3 * svsk->sk_server->sv_max_mesg);
 
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
-	svc_sock_set_data_ready(svsk);
 	if (sk->sk_state != TCP_ESTABLISHED) {
 		/* note: caller calls svc_sock_enqueue() */
 		svc_sock_set_close(svsk);
@@ -1711,7 +1707,6 @@ static struct svc_sock *svc_setup_socket
 		return NULL;
 	}
 
-	set_bit(SK_BUSY, &svsk->sk_flags);
 	inet->sk_user_data = svsk;
 	svsk->sk_sock = sock;
 	svsk->sk_sk = inet;
@@ -1741,6 +1736,7 @@ static struct svc_sock *svc_setup_socket
 
 void svc_sock_init(struct svc_sock *svsk, struct svc_serv *serv)
 {
+	set_bit(SK_BUSY, &svsk->sk_flags);
 	svsk->sk_server = serv;
 	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
@@ -1754,6 +1750,8 @@ void svc_sock_add_connection(struct svc_
 {
 	struct svc_serv *serv = svsk->sk_server;
 
+	svc_sock_set_data_ready(svsk);
+
 	spin_lock_bh(&serv->sv_lock);
 
 	set_bit(SK_TEMP, &svsk->sk_flags);
@@ -1784,11 +1782,14 @@ static void svc_sock_add_permanent(struc
 
 void svc_sock_add_listener(struct svc_sock *svsk)
 {
+	set_bit(SK_LISTENER, &svsk->sk_flags);
+	svc_sock_set_connection_ready(svsk);
 	svc_sock_add_permanent(svsk);
 }
 
 void svc_sock_add_connectionless(struct svc_sock *svsk)
 {
+	svc_sock_set_data_ready(svsk); /* might have come in before data_ready set up */
 	svc_sock_add_permanent(svsk);
 }
 
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
