From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] sunrpc may oops during initialization sokcets.
Date: Mon, 18 Nov 2002 20:22:19 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021118.202219.90829917.taka@valinux.co.jp>
References: <20021115.132706.26959611.taka@valinux.co.jp>
	<15832.11815.395760.763047@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Dk8C-0004dS-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 03:31:56 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15832.11815.395760.763047@notabene.cse.unsw.edu.au>
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

I found another problem and fixed it.

My box has crashed in heavily loaded condition.
I realized there were races during initializing sunrpc sockets.

We should keep sockets SK_BUSY during its initalization or
the data_ready callbacks may access uninitalized data and
may cause Oops. The callbacks can't handle a packet correctly
just after registering them.


Thank you,
Hirokazu Takahashi.



--- linux/net/sunrpc/svcsock.c.INITRACE	Mon Nov 18 18:50:03 2030
+++ linux/net/sunrpc/svcsock.c	Mon Nov 18 19:27:43 2030
@@ -765,6 +765,7 @@ svc_tcp_accept(struct svc_sock *svsk)
 	/* Precharge. Data may have arrived on the socket before we
 	 * installed the data_ready callback. 
 	 */
+	clear_bit(SK_BUSY, &newsvsk->sk_flags);
 	set_bit(SK_DATA, &newsvsk->sk_flags);
 	svc_sock_enqueue(newsvsk);
 
@@ -1238,6 +1239,11 @@ svc_setup_socket(struct svc_serv *serv, 
 	}
 	memset(svsk, 0, sizeof(*svsk));
 
+	/* prevent races against the data_ready callbacks
+	 * during initialization.
+	 */
+	svsk->sk_flags = SK_BUSY;
+
 	inet = sock->sk;
 	inet->user_data = svsk;
 	svsk->sk_sock = sock;
@@ -1325,8 +1331,18 @@ svc_create_socket(struct svc_serv *serv,
 			goto bummer;
 	}
 
-	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL)
+	if ((svsk = svc_setup_socket(serv, sock, &error, 1)) != NULL) {
+		/*
+		 * data may have already arrived
+		 */
+		clear_bit(SK_BUSY, &svsk->sk_flags);
+		if (protocol == IPPROTO_TCP)
+			set_bit(SK_CONN, &svsk->sk_flags);
+		else
+			set_bit(SK_DATA, &svsk->sk_flags);
+		svc_sock_enqueue(svsk);
 		return 0;
+	}
 
 bummer:
 	dprintk("svc: svc_create_socket error = %d\n", -error);




-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
