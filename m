From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 9 - RPC server need to know that TCP and UDP have different wspace functions.
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00061h-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1g-0000w9-00
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

From: Hirokazu Takahashi <taka@valinux.co.jp>

sock_wspace() is used to see how much can be written to a udp socket,
but tcp_wspace must be used on a tcp socket.
This patch informs sunrpc/svcsock.c of this subtlety.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |   21 +++++++++++++++++++--
 1 files changed, 19 insertions(+), 2 deletions(-)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-20 16:33:43.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-20 16:34:34.000000000 +1000
@@ -35,6 +35,7 @@
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
+#include <net/tcp.h>
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
@@ -116,6 +117,22 @@ svc_release_skb(struct svc_rqst *rqstp)
 }
 
 /*
+ * Any space to write?
+ */
+static inline unsigned long
+svc_sock_wspace(struct svc_sock *svsk)
+{
+	int wspace;
+
+	if (svsk->sk_sock->type == SOCK_STREAM)
+		wspace = tcp_wspace(svsk->sk_sk);
+	else
+		wspace = sock_wspace(svsk->sk_sk);
+
+	return wspace;
+}
+
+/*
  * Queue up a socket with data pending. If there are idle nfsd
  * processes, wake 'em up.
  *
@@ -150,13 +167,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	}
 
 	if (((svsk->sk_reserved + serv->sv_bufsz)*2
-	     > sock_wspace(svsk->sk_sk))
+	     > svc_sock_wspace(svsk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
 			svsk->sk_sk, svsk->sk_reserved+serv->sv_bufsz,
-			sock_wspace(svsk->sk_sk));
+			svc_sock_wspace(svsk));
 		goto out_unlock;
 	}
 


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
