From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 9 - SVC sockets don't disable Nagle
Date: Wed, 21 May 2003 13:12:09 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1R-00061c-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1f-0000vE-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:09 +1000
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

I noticed that the Nagle algorithm was disabled just recently on the 
client side, while it still seems to be enabled on the server side. The 
previous patch came from Chuck Lever.

Below patch disables it on the server side as well. For latency reasons, 
this should be the desired behaviour NFS at both client and server.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    3 +++
 1 files changed, 3 insertions(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-20 16:31:42.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-20 16:33:43.000000000 +1000
@@ -1015,6 +1015,7 @@ static void
 svc_tcp_init(struct svc_sock *svsk)
 {
 	struct sock	*sk = svsk->sk_sk;
+	struct tcp_opt  *tp = tcp_sk(sk);
 
 	svsk->sk_recvfrom = svc_tcp_recvfrom;
 	svsk->sk_sendto = svc_tcp_sendto;
@@ -1032,6 +1033,8 @@ svc_tcp_init(struct svc_sock *svsk)
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
 
+		tp->nonagle = 1;        /* disable Nagle's algorithm */
+
 		/* initialise setting must have enough space to
 		 * receive and respond to one request.  
 		 * svc_tcp_recvfrom will re-adjust if necessary


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
