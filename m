From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] sunrpc - 1 of 3 - Reorganise sock init in rpcsvc to avoid races.
Date: Tue, 07 Jan 2003 13:39:39 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VjeV-00071o-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Vjee-0005sQ-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 18:39:48 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 7 Jan 2003 13:39:40 +1100
To: Linus Torvalds <torvalds@transmeta.com>
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

If one of the callback (e.g. data ready) is called 
before socket setup is complete, oops may occur.

With this patch, socket is kept SK_BUSY until all is
ready to avoid this.

Also some code is moved around to make it cleaner.


 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   55 ++++++++++++++++++++++---------------------------
 1 files changed, 25 insertions(+), 30 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-01-07 13:36:33.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2003-01-07 13:36:33.000000000 +1100
@@ -627,7 +627,7 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
-static int
+static void
 svc_udp_init(struct svc_sock *svsk)
 {
 	svsk->sk_sk->data_ready = svc_udp_data_ready;
@@ -643,9 +643,8 @@ svc_udp_init(struct svc_sock *svsk)
 			    3 * svsk->sk_server->sv_bufsz,
 			    3 * svsk->sk_server->sv_bufsz);
 
+	set_bit(SK_DATA, &svsk->sk_flags); /* might have come in before data_ready set up */
 	set_bit(SK_CHNGBUF, &svsk->sk_flags);
-
-	return 0;
 }
 
 /*
@@ -773,19 +772,14 @@ svc_tcp_accept(struct svc_sock *svsk)
 	dprintk("%s: connect from %u.%u.%u.%u:%04x\n", serv->sv_name,
 			NIPQUAD(sin.sin_addr.s_addr), ntohs(sin.sin_port));
 
-	if (!(newsvsk = svc_setup_socket(serv, newsock, &err, 0)))
-		goto failed;
-
 	/* make sure that a write doesn't block forever when
 	 * low on memory
 	 */
 	newsock->sk->sndtimeo = HZ*30;
 
-	/* Precharge. Data may have arrived on the socket before we
-	 * installed the data_ready callback. 
-	 */
-	set_bit(SK_DATA, &newsvsk->sk_flags);
-	svc_sock_enqueue(newsvsk);
+	if (!(newsvsk = svc_setup_socket(serv, newsock, &err, 0)))
+		goto failed;
+
 
 	/* make sure that we don't have too many active connections.
 	 * If we have, something must be dropped.
@@ -1006,7 +1000,7 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
-static int
+static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
@@ -1017,6 +1011,7 @@ svc_tcp_init(struct svc_sock *svsk)
 	if (sk->state == TCP_LISTEN) {
 		dprintk("setting up TCP socket for listening\n");
 		sk->data_ready = svc_tcp_listen_data_ready;
+		set_bit(SK_CONN, &svsk->sk_flags);
 	} else {
 		dprintk("setting up TCP socket for reading\n");
 		sk->state_change = svc_tcp_state_change;
@@ -1035,9 +1030,8 @@ svc_tcp_init(struct svc_sock *svsk)
 				    3 * svsk->sk_server->sv_bufsz);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
+		set_bit(SK_DATA, &svsk->sk_flags);
 	}
-
-	return 0;
 }
 
 void
@@ -1258,6 +1252,18 @@ svc_setup_socket(struct svc_serv *serv, 
 	memset(svsk, 0, sizeof(*svsk));
 
 	inet = sock->sk;
+
+	/* Register socket with portmapper */
+	if (*errp >= 0 && pmap_register)
+		*errp = svc_register(serv, inet->protocol,
+				     ntohs(inet_sk(inet)->sport));
+
+	if (*errp < 0) {
+		kfree(svsk);
+		return NULL;
+	}
+
+	set_bit(SK_BUSY, &svsk->sk_flags);
 	inet->user_data = svsk;
 	svsk->sk_sock = sock;
 	svsk->sk_sk = inet;
@@ -1271,23 +1277,9 @@ svc_setup_socket(struct svc_serv *serv, 
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
-		*errp = svc_udp_init(svsk);
+		svc_udp_init(svsk);
 	else
-		*errp = svc_tcp_init(svsk);
-if (svsk->sk_sk == NULL)
-	printk(KERN_WARNING "svsk->sk_sk == NULL after svc_prot_init!\n");
-
-	/* Register socket with portmapper */
-	if (*errp >= 0 && pmap_register)
-		*errp = svc_register(serv, inet->protocol,
-				     ntohs(inet_sk(inet)->sport));
-
-	if (*errp < 0) {
-		inet->user_data = NULL;
-		kfree(svsk);
-		return NULL;
-	}
-
+		svc_tcp_init(svsk);
 
 	spin_lock_bh(&serv->sv_lock);
 	if (!pmap_register) {
@@ -1302,6 +1294,9 @@ if (svsk->sk_sk == NULL)
 
 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
 				svsk, svsk->sk_sk);
+
+	clear_bit(SK_BUSY, &svsk->sk_flags);
+	svc_sock_enqueue(svsk);
 	return svsk;
 }
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
