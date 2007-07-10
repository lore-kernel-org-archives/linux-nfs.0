From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 11/20] svc: cleanup svc_sock initialization
Date: Tue, 10 Jul 2007 00:34:43 -0500
Message-ID: <20070710053443.28979.72342.stgit@dell3.ogc.int>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I88N4-00074x-Kg
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:46 -0700
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I88N6-0003UY-R9
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 22:34:50 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 720177C79E
	for <nfs@lists.sourceforge.net>; Tue, 10 Jul 2007 00:34:43 -0500 (CDT)
In-Reply-To: <20070710052711.28979.70843.stgit@dell3.ogc.int>
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
Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/svcsock.h |   10 +++
 net/sunrpc/svcsock.c           |  143 ++++++++++++++++++++++++++--------------
 2 files changed, 102 insertions(+), 51 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index e455783..0e7307c 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -116,6 +116,16 @@ int		svc_addsock(struct svc_serv *serv,
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
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0193f54..57fefea 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1357,45 +1357,48 @@ static const struct svc_sock_ops svc_tcp
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
+	dprintk("setting up TCP socket for listening\n");
+	sk->sk_data_ready = svc_tcp_listen_data_ready;
+	set_bit(SK_LISTENER, &svsk->sk_flags);
+	set_bit(SK_CONN, &svsk->sk_flags);
+}
 
-		set_bit(SK_LISTENER, &svsk->sk_flags);
-		set_bit(SK_CONN, &svsk->sk_flags);
-	} else {
-		dprintk("setting up TCP socket for reading\n");
-		sk->sk_state_change = svc_tcp_state_change;
-		sk->sk_data_ready = svc_tcp_data_ready;
-		sk->sk_write_space = svc_write_space;
+static void
+svc_tcp_init_connection(struct svc_sock *svsk)
+{
+	struct sock	*sk = svsk->sk_sk;
+	struct tcp_sock *tp = tcp_sk(sk);
 
-		svsk->sk_reclen = 0;
-		svsk->sk_tcplen = 0;
+	svsk->sk_ops = &svc_tcp_ops;
 
-		tp->nonagle = 1;        /* disable Nagle's algorithm */
+	dprintk("setting up TCP socket for reading\n");
+	sk->sk_state_change = svc_tcp_state_change;
+	sk->sk_data_ready = svc_tcp_data_ready;
+	sk->sk_write_space = svc_write_space;
 
-		/* initialise setting must have enough space to
-		 * receive and respond to one request.
-		 * svc_tcp_recvfrom will re-adjust if necessary
-		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    3 * svsk->sk_server->sv_max_mesg,
-				    3 * svsk->sk_server->sv_max_mesg);
+	svsk->sk_reclen = 0;
+	svsk->sk_tcplen = 0;
 
-		set_bit(SK_CHNGBUF, &svsk->sk_flags);
-		set_bit(SK_DATA, &svsk->sk_flags);
-		if (sk->sk_state != TCP_ESTABLISHED) {
-			/* note: caller calls svc_sock_enqueue() */
-			set_bit(SK_CLOSE, &svsk->sk_flags);
-		}
-	}
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
+	set_bit(SK_DATA, &svsk->sk_flags);
+	if (sk->sk_state != TCP_ESTABLISHED)
+		set_bit(SK_CLOSE, &svsk->sk_flags);
 }
 
 void
@@ -1683,6 +1686,29 @@ static struct svc_sock *svc_setup_socket
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
@@ -1690,36 +1716,51 @@ static struct svc_sock *svc_setup_socket
 	INIT_LIST_HEAD(&svsk->sk_deferred);
 	INIT_LIST_HEAD(&svsk->sk_ready);
 	mutex_init(&svsk->sk_mutex);
+}
+EXPORT_SYMBOL(svc_sock_init);
 
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
+EXPORT_SYMBOL(svc_sock_add_connection);
 
-	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
-				svsk, svsk->sk_sk);
+static void svc_sock_add_permanent(struct svc_sock *svsk)
+{
+	struct svc_serv *serv = svsk->sk_server;
 
-	return svsk;
+	BUG_ON(test_bit(SK_TEMP, &svsk->sk_flags));
+	spin_lock_bh(&serv->sv_lock);
+	list_add(&svsk->sk_list, &serv->sv_permsocks);
+	spin_unlock_bh(&serv->sv_lock);
+}
+
+void svc_sock_add_listener(struct svc_sock *svsk)
+{
+	svc_sock_add_permanent(svsk);
+}
+EXPORT_SYMBOL(svc_sock_add_listener);
+
+void svc_sock_add_connectionless(struct svc_sock *svsk)
+{
+	svc_sock_add_permanent(svsk);
 }
+EXPORT_SYMBOL(svc_sock_add_connectionless);
 
 int svc_addsock(struct svc_serv *serv,
 		int fd,

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
