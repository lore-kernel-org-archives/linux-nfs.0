From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 4 - SVC sockets don't disable Nagle
Date: Wed, 18 Jun 2003 10:30:11 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQq3-0000Ws-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQlv-0007Jk-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 17:25:55 -0700
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


I noticed that the Nagle algorithm was disabled just recently on the 
client side, while it still seems to be enabled on the server side. The 
previous patch came from Chuck Lever.

Below patch disables it on the server side as well. For latency reasons, 
this should be the desired behaviour NFS at both client and server.


diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-06-18 10:05:47.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-06-18 10:16:06.000000000 +1000
@@ -936,6 +936,7 @@ static int
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
+	struct tcp_opt  *tp = &(sk->tp_pinfo.af_tcp);
 
 	svsk->sk_recvfrom = svc_tcp_recvfrom;
 	svsk->sk_sendto = svc_tcp_sendto;
@@ -952,6 +953,8 @@ svc_tcp_init(struct svc_sock *svsk)
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
 
+		tp->nonagle = 1;        /* disable Nagle's algorithm */
+
 		/* initialise setting must have enough space to
 		 * receive and respond to one request.  
 		 * svc_tcp_recvfrom will re-adjust if necessary


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
