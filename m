From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 3 - Make sure nothing happens to a dead rpc/tcp socket
Date: Tue, 19 Aug 2003 14:35:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19oyD8-0001H9-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19oyDK-00063h-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Aug 2003 21:35:22 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 19 Aug 2003 14:35:11 +1000
To: Linus Torvalds <torvalds@osdl.org>
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


Three more little patches for knfsd in 2.6.0-test3
NeilBrown


### Comments for ChangeSet

Just make sure that once SK_DEAD is set, nothing is attempted on the socket.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    5 +++++
 1 files changed, 5 insertions(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-08-18 09:41:01.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-08-18 09:41:01.000000000 +1000
@@ -147,6 +147,8 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	if (!(svsk->sk_flags &
 	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
 		return;
+	if (test_bit(SK_DEAD, &svsk->sk_flags))
+		return;
 
 	spin_lock_bh(&serv->sv_lock);
 
@@ -1029,6 +1031,9 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	reclen = htonl(0x80000000|((xbufp->len ) - 4));
 	memcpy(xbufp->head[0].iov_base, &reclen, 4);
 
+	if (test_bit(SK_DEAD, &rqstp->rq_sock->sk_flags))
+		return -ENOTCONN;
+
 	sent = svc_sendto(rqstp, &rqstp->rq_res);
 	if (sent != xbufp->len) {
 		printk(KERN_NOTICE "rpc-srv/tcp: %s: %s %d when sending %d bytes - shutting down socket\n",


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
