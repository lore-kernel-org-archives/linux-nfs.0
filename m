From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 9 - Make sure an RPC socket is closed immediately when a server write fails.
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00061s-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1f-0000vH-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 20:12:24 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 21 May 2003 13:12:10 +1000
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

The check for "write was incomplete" is not atomic with the actual write,
so a second write could slip in after a partial write to a tcp socket
and this will cause problems.

So we move the locking out a bit, and test if the socket has
been deleted (SK_DEAD) between getting the lock and trying
to send.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-20 16:34:34.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-20 16:34:35.000000000 +1000
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
@@ -1258,7 +1253,13 @@ svc_send(struct svc_rqst *rqstp)
 		xb->page_len +
 		xb->tail[0].iov_len;
 
-	len = svsk->sk_sendto(rqstp);
+	/* Grab svsk->sk_sem to serialize outgoing data. */
+	down(&svsk->sk_sem);
+	if (test_bit(SK_DEAD, &svsk->sk_flags))
+		len = -ENOTCONN;
+	else
+		len = svsk->sk_sendto(rqstp);
+	up(&svsk->sk_sem);
 	svc_sock_release(rqstp);
 
 	if (len == -ECONNREFUSED || len == -ENOTCONN || len == -EAGAIN)


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
