From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] Flow control problems(3)
Date: Mon, 19 May 2003 22:26:18 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030519.222618.23005625.taka@valinux.co.jp>
References: <20030519.222154.102583212.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([210.128.90.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Hkjm-00048a-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 06:31:34 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <20030519.222154.102583212.taka@valinux.co.jp>
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

Hello,

> There are some flow control problems when we use NFS over TCP.

svc_tcp_sendto() may send a partial packet in case of heavily
loaded situations.

In this case we should shutdown the socket immediately
or many broken RPC packets will be sent and may make some NFS
clients stucked. (e.g. I saw NFS clients on Solaris have stucked.)


Thank you,
Hirokazu Takahashi.




--- include/linux/sunrpc/svcsock.h.ORG	Thu May 15 17:52:27 2031
+++ include/linux/sunrpc/svcsock.h	Fri May 16 11:47:01 2031
@@ -56,7 +56,7 @@ struct svc_sock {
  * Function prototypes.
  */
 int		svc_makesock(struct svc_serv *, int, unsigned short);
-void		svc_delete_socket(struct svc_sock *);
+void		svc_delete_socket(struct svc_sock *, int);
 int		svc_recv(struct svc_serv *, struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);
--- net/sunrpc/svcsock.c.NEW2	Fri May 16 11:45:27 2031
+++ net/sunrpc/svcsock.c	Fri May 16 11:47:01 2031
@@ -360,9 +360,6 @@ svc_sendto(struct svc_rqst *rqstp, struc
 
 	slen = xdr->len;
 
-	/* Grab svsk->sk_sem to serialize outgoing data. */
-	down(&svsk->sk_sem);
-
 	if (rqstp->rq_prot == IPPROTO_UDP) {
 		/* set the destination */
 		struct msghdr	msg;
@@ -415,8 +412,6 @@ svc_sendto(struct svc_rqst *rqstp, struc
 			len += result;
 	}
 out:
-	up(&svsk->sk_sem);
-
 	dprintk("svc: socket %p sendto([%p %Zu... ], %d) = %d (addr %x)\n",
 			rqstp->rq_sock, xdr->head[0].iov_base, xdr->head[0].iov_len, xdr->len, len,
 		rqstp->rq_addr.sin_addr.s_addr);
@@ -867,7 +862,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return svc_deferred_recv(rqstp);
 
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
-		svc_delete_socket(svsk);
+		svc_delete_socket(svsk, 0);
 		return 0;
 	}
 
@@ -981,7 +976,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	return len;
 
  err_delete:
-	svc_delete_socket(svsk);
+	svc_delete_socket(svsk, 0);
 	return -EAGAIN;
 
  error:
@@ -1020,7 +1015,11 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 		       rqstp->rq_sock->sk_server->sv_name,
 		       (sent<0)?"got error":"sent only",
 		       sent, xbufp->len);
-		svc_delete_socket(rqstp->rq_sock);
+		/*
+		 * we can't keep the socket alive anymore
+		 * if we wrote a partial packet.
+		 */
+		svc_delete_socket(rqstp->rq_sock, sent > 0);
 		sent = -EAGAIN;
 	}
 	return sent;
@@ -1251,7 +1250,10 @@ svc_send(struct svc_rqst *rqstp)
 		xb->page_len +
 		xb->tail[0].iov_len;
 
+	/* Grab svsk->sk_sem to serialize outgoing data. */
+	down(&svsk->sk_sem);
 	len = svsk->sk_sendto(rqstp);
+	up(&svsk->sk_sem);
 	svc_sock_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)
@@ -1379,15 +1381,17 @@ bummer:
  * Remove a dead socket
  */
 void
-svc_delete_socket(struct svc_sock *svsk)
+svc_delete_socket(struct svc_sock *svsk, int doshutdown)
 {
 	struct svc_serv	*serv;
 	struct sock	*sk;
+	struct socket	*sock;
 
 	dprintk("svc: svc_delete_socket(%p)\n", svsk);
 
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
+	sock = svsk->sk_sock;
 
 	sk->state_change = svsk->sk_ostate;
 	sk->data_ready = svsk->sk_odata;
@@ -1407,6 +1411,8 @@ svc_delete_socket(struct svc_sock *svsk)
 		kfree(svsk);
 	} else {
 		spin_unlock_bh(&serv->sv_lock);
+		if (doshutdown && sock->ops->shutdown)
+			sock->ops->shutdown(sock, 2/*SHUT_RDWR*/);
 		dprintk(KERN_NOTICE "svc: server socket destroy delayed\n");
 		/* svsk->sk_server = NULL; */
 	}
--- net/sunrpc/svc.c.ORG	Wed May 14 17:56:33 2031
+++ net/sunrpc/svc.c	Thu May 15 19:50:27 2031
@@ -90,13 +90,13 @@ svc_destroy(struct svc_serv *serv)
 		svsk = list_entry(serv->sv_tempsocks.next,
 				  struct svc_sock,
 				  sk_list);
-		svc_delete_socket(svsk);
+		svc_delete_socket(svsk, 0);
 	}
 	while (!list_empty(&serv->sv_permsocks)) {
 		svsk = list_entry(serv->sv_permsocks.next,
 				  struct svc_sock,
 				  sk_list);
-		svc_delete_socket(svsk);
+		svc_delete_socket(svsk, 0);
 	}
 
 	/* Unregister service with the portmapper */


-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
