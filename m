From: Greg Banks <gnb@sgi.com>
Subject: [RFC,PATCH 13/14] knfsd: add svc_sock_init
Date: Thu, 17 May 2007 05:28:49 +1000
Message-ID: <20070516192849.GS9626@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoPB8-00013N-LK
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:28:54 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HoPBB-0003Ue-0j
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 12:28:57 -0700
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


Reorganise the svc_sock initialisation code so that new service
transport code can use it without duplicating lots of code
that futzes with internal transport details (for example the
SK_BUSY bit).  Transport code should now call svc_sock_init() to
initialise the svc_sock structure, then one of svc_sock_add_listener
sock_add_connection or svc_sock_add_connectionless, and finally
svc_sock_received.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |   10 ++
 net/sunrpc/sunrpc_syms.c       |    4 
 net/sunrpc/svcsock.c           |  148 +++++++++++++++++++-----------
 3 files changed, 109 insertions(+), 53 deletions(-)

Index: linux/include/linux/sunrpc/svcsock.h
===================================================================
--- linux.orig/include/linux/sunrpc/svcsock.h	2007-05-17 03:19:26.626631647 +1000
+++ linux/include/linux/sunrpc/svcsock.h	2007-05-17 03:41:02.379970360 +1000
@@ -122,6 +122,16 @@ int		svc_addsock(struct svc_serv *serv,
 void		svc_sock_enqueue(struct svc_sock *svsk);
 void		svc_sock_received(struct svc_sock *svsk);
 void	    	__svc_sock_put(struct svc_sock *svsk);
+/* Initialise a newly allocated svc_sock.   The transport code needs
+ * to call svc_sock_received() when transport-specific initialisation
+ * is complete and one of the svc_add_*() functions has been called.  */
+void		svc_sock_init(struct svc_sock *, struct svc_serv *);
+/* Add an initialised connection svc_sock to the server */
+void		svc_sock_add_connection(struct svc_sock *);
+/* Add an initialised listener svc_sock to the server */
+void		svc_sock_add_listener(struct svc_sock *);
+/* Add an initialised connectionless svc_sock to the server */
+void		svc_sock_add_connectionless(struct svc_sock *);
 
 /*
  * svc_makesock socket characteristics
Index: linux/net/sunrpc/sunrpc_syms.c
===================================================================
--- linux.orig/net/sunrpc/sunrpc_syms.c	2007-05-17 03:20:08.785046921 +1000
+++ linux/net/sunrpc/sunrpc_syms.c	2007-05-17 03:41:02.435963006 +1000
@@ -77,6 +77,10 @@ EXPORT_SYMBOL(svc_process);
 EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
 EXPORT_SYMBOL(svc_makesock);
+EXPORT_SYMBOL_GPL(svc_sock_init);
+EXPORT_SYMBOL_GPL(svc_sock_add_connection);
+EXPORT_SYMBOL_GPL(svc_sock_add_listener);
+EXPORT_SYMBOL_GPL(svc_sock_add_connectionless);
 EXPORT_SYMBOL_GPL(svc_sock_enqueue);
 EXPORT_SYMBOL_GPL(svc_sock_received);
 EXPORT_SYMBOL(svc_reserve);
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-17 03:24:02.438110603 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-17 04:10:26.330080170 +1000
@@ -1387,43 +1387,49 @@ static const struct svc_sock_ops svc_tcp
 };
 
 static void
-svc_tcp_init(struct svc_sock *svsk)
+svc_tcp_init_listener(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
-	struct tcp_sock *tp = tcp_sk(sk);
 
 	svsk->sk_ops = &svc_tcp_ops;
 
-	if (sk->sk_state == TCP_LISTEN) {
-		dprintk("setting up TCP socket for listening\n");
-		sk->sk_data_ready = svc_tcp_listen_data_ready;
-		set_bit(SK_LISTENER, &svsk->sk_flags);
-		svc_sock_set_connection_ready(svsk);
-	} else {
-		dprintk("setting up TCP socket for reading\n");
-		sk->sk_state_change = svc_tcp_state_change;
-		sk->sk_data_ready = svc_tcp_data_ready;
-		sk->sk_write_space = svc_write_space;
-
-		svsk->sk_reclen = 0;
-		svsk->sk_tcplen = 0;
-
-		tp->nonagle = 1;        /* disable Nagle's algorithm */
-
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 * svc_tcp_recvfrom will re-adjust if necessary
-		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_max_mesg,
-				    3 * svsk->sk_server->sv_max_mesg);
+	dprintk("setting up TCP socket for listening\n");
+	sk->sk_data_ready = svc_tcp_listen_data_ready;
+	set_bit(SK_LISTENER, &svsk->sk_flags);
+	svc_sock_set_connection_ready(svsk);
+}
 
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
-		svc_sock_set_data_ready(svsk);
-		if (sk->sk_state != TCP_ESTABLISHED) {
-			/* note: caller calls svc_sock_enqueue() */
-			svc_sock_set_close(svsk);
-		}
+static void
+svc_tcp_init_connection(struct svc_sock *svsk)
+{
+	struct sock	*sk = svsk->sk_sk;
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	svsk->sk_ops = &svc_tcp_ops;
+
+	dprintk("setting up TCP socket for reading\n");
+	sk->sk_state_change = svc_tcp_state_change;
+	sk->sk_data_ready = svc_tcp_data_ready;
+	sk->sk_write_space = svc_write_space;
+
+	svsk->sk_reclen = 0;
+	svsk->sk_tcplen = 0;
+
+	tp->nonagle = 1;        /* disable Nagle's algorithm */
+
+	/* initialise setting must have enough space to
+	 * receive and respond to one request.
+	 * svc_tcp_recvfrom will re-adjust if necessary
+	 */
+	svc_sock_setbufsize(svsk->sk_sock,
+			    3 * svsk->sk_server->sv_max_mesg,
+			    3 * svsk->sk_server->sv_max_mesg);
+
+	set_bit(SK_CHNGBUF, &svsk->sk_flags);
+	svc_sock_set_data_ready(svsk);
+	if (sk->sk_state != TCP_ESTABLISHED) {
+		/* note: caller calls svc_sock_enqueue() */
+		svc_sock_set_close(svsk);
 	}
 }
 
@@ -1712,6 +1718,29 @@ static struct svc_sock *svc_setup_socket
 	svsk->sk_ostate = inet->sk_state_change;
 	svsk->sk_odata = inet->sk_data_ready;
 	svsk->sk_owspace = inet->sk_write_space;
+	svc_sock_init(svsk, serv);
+
+	/* Initialize the socket */
+	if (sock->type == SOCK_DGRAM) {
+		svc_udp_init(svsk);
+		svc_sock_add_connectionless(svsk);
+	} else if (inet->sk_state == TCP_LISTEN) {
+		BUG_ON(is_temporary);
+		svc_tcp_init_listener(svsk);
+		svc_sock_add_listener(svsk);
+	} else {
+		BUG_ON(!is_temporary);
+		svc_tcp_init_connection(svsk);
+		svc_sock_add_connection(svsk);
+	}
+
+	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
+				svsk, svsk->sk_sk);
+	return svsk;
+}
+
+void svc_sock_init(struct svc_sock *svsk, struct svc_serv *serv)
+{
 	svsk->sk_server = serv;
 	atomic_set(&svsk->sk_inuse, 1);
 	svsk->sk_lastrecv = get_seconds();
@@ -1719,35 +1748,48 @@ static struct svc_sock *svc_setup_socket
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
 	mutex_init(&svsk->sk_mutex);
+}
 
-	/* Initialize the socket */
-	if (sock->type == SOCK_DGRAM)
-		svc_udp_init(svsk);
-	else
-		svc_tcp_init(svsk);
+void svc_sock_add_connection(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_server;
 
 	spin_lock_bh(&serv->sv_lock);
-	if (is_temporary) {
-		set_bit(SK_TEMP, &svsk->sk_flags);
-		list_add(&svsk->sk_list, &serv->sv_tempsocks);
-		serv->sv_tmpcnt++;
-		if (serv->sv_temptimer.function == NULL) {
-			/* setup timer to age temp sockets */
-			setup_timer(&serv->sv_temptimer, svc_age_temp_sockets,
-					(unsigned long)serv);
-			mod_timer(&serv->sv_temptimer,
-					jiffies + svc_conn_age_period * HZ);
-		}
-	} else {
-		clear_bit(SK_TEMP, &svsk->sk_flags);
-		list_add(&svsk->sk_list, &serv->sv_permsocks);
+
+	set_bit(SK_TEMP, &svsk->sk_flags);
+	list_add(&svsk->sk_list, &serv->sv_tempsocks);
+	serv->sv_tmpcnt++;
+	if (serv->sv_temptimer.function == NULL) {
+		/* setup timer to age temp sockets */
+		setup_timer(&serv->sv_temptimer, svc_age_temp_sockets,
+				(unsigned long)serv);
+		mod_timer(&serv->sv_temptimer,
+				jiffies + svc_conn_age_period * HZ);
 	}
+
 	spin_unlock_bh(&serv->sv_lock);
+}
 
-	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
-				svsk, svsk->sk_sk);
+static void svc_sock_add_permanent(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_server;
 
-	return svsk;
+	spin_lock_bh(&serv->sv_lock);
+
+	clear_bit(SK_TEMP, &svsk->sk_flags);
+	list_add(&svsk->sk_list, &serv->sv_permsocks);
+
+	spin_unlock_bh(&serv->sv_lock);
+}
+
+void svc_sock_add_listener(struct svc_sock *svsk)
+{
+	svc_sock_add_permanent(svsk);
+}
+
+void svc_sock_add_connectionless(struct svc_sock *svsk)
+{
+	svc_sock_add_permanent(svsk);
 }
 
 int svc_addsock(struct svc_serv *serv,
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
