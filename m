From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 4 - Make sure an early close on a nfs/tcp connection is handled properly.
Date: Wed, 18 Jun 2003 10:30:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQq4-0000XC-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQlm-0007Cy-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 17:25:46 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <marcelo@conectiva.com.br>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 10:25:35 +1000
To: Marcelo Tosatti <marcelo@conectiva.com.br>
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


From: Hirokazu Takahashi <taka@valinux.co.jp>

In svc_tcp_listen_data_ready we should be waiting for
TCP_LISTEN, not TCP_ESTABLISHED.  The later only worked
by accident.
Also, if a socket is closed as soon as we accept it, we
must shut it down straight away as we will never get a 'close'
event.


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 10:16:06.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 10:19:20.000000000 +1000
@@ -595,8 +595,17 @@ svc_tcp_listen_data_ready(struct sock *s
 	dprintk("svc: socket %p TCP (listen) state change %d\n",
 			sk, sk->state);
 
-	if  (sk->state != TCP_ESTABLISHED) {
-		/* Aborted connection, SYN_RECV or whatever... */
+	if  (sk->state != TCP_LISTEN) {
+		/*
+		 * This callback may called twice when a new connection
+		 * is established as a child socket inherits everything
+		 * from a parent LISTEN socket.
+		 * 1) data_ready method of the parent socket will be called
+		 *    when one of child sockets become ESTABLISHED.
+		 * 2) data_ready method of the child socket may be called
+		 *    when it receives data before the socket is accepted.
+		 * In case of 2, we should ignore it silently.
+		 */
 		goto out;
 	}
 	if (!(svsk = (struct svc_sock *) sk->user_data)) {
@@ -964,6 +973,8 @@ svc_tcp_init(struct svc_sock *svsk)
 				    3 * svsk->sk_server->sv_bufsz);
 
 		set_bit(SK_CHNGBUF, &svsk->sk_flags);
+		if (sk->sk_state != TCP_ESTABLISHED) 
+			set_bit(SK_CLOSE, &svsk->sk_flags);
 	}
 
 	return 0;


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
