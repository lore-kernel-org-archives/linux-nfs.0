From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 6 - Make sure nfs/tcp socket only gets closed once.
Date: Thu, 04 Sep 2003 16:25:55 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19unZ5-0004VM-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19unZJ-00027E-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 23:26:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19unZI-0002HW-Oo
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 23:26:08 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <marcelo.tosatti@cyclades.com.br>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 4 Sep 2003 16:25:56 +1000
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com.br>
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


It is possible for svc_delete_socket to be called multiple times,
which can cause problems.  This patch uses SK_DEAD to make sure it
only has any effect the first time, and uses SK_DEAD in a few other
places to make sure nothing is done on a deleted socket.

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-09-04 11:32:12.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-09-04 11:45:48.000000000 +1000
@@ -120,6 +120,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!(svsk->sk_flags &
 	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)) ))
 		return;
+	if (test_bit(SK_DEAD, &svsk->sk_flags))
+		return;
 
 	spin_lock_bh(&serv->sv_lock);
 
@@ -930,6 +932,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	bufp->iov[0].iov_len  = bufp->len << 2;
 	bufp->base[0] = htonl(0x80000000|((bufp->len << 2) - 4));
 
+	if (test_bit(SK_DEAD, &rqstp->rq_sock->sk_flags))
+		return -ENOTCONN;
+
 	sent = svc_sendto(rqstp, bufp->iov, bufp->nriov);
 	if (sent != bufp->len<<2) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: sent only %d bytes of %d - shutting down socket\n",
@@ -1277,6 +1282,9 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	dprintk("svc: svc_delete_socket(%p)\n", svsk);
 
+	if (test_and_set_bit(SK_DEAD, &svsk->sk_flags))
+		return ;
+
 	serv = svsk->sk_server;
 	sk = svsk->sk_sk;
 
@@ -1293,8 +1301,6 @@ svc_delete_socket(struct svc_sock *svsk)
 		list_del(&svsk->sk_ready);
 
 
-	set_bit(SK_DEAD, &svsk->sk_flags);
-
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);
 		sock_release(svsk->sk_sock);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
