From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] [PATCH] Flow control problems(1)
Date: Mon, 19 May 2003 22:21:54 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030519.222154.102583212.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, taka@valinux.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([210.128.90.2])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19HkfX-0001sX-00
	for <nfs@lists.sourceforge.net>; Mon, 19 May 2003 06:27:11 -0700
To: neilb@cse.unsw.edu.au
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

neilb> Finally I have had reports of poor stability with 2.5 nfsd, but I
neilb> don't have any specific details.  If anyone wants to hammer nfsd
neilb> nice and hard and tell me lots of details about any negative
neilb> results, I would appreciate it.

There are some flow control problems when we use NFS over TCP.

svc_sock_enqueue() calls sock_wspace() to checkes whether there
is enough space in a sending buffer. But in case of TCP it won't
work correctly.

We should use tcp_wspace() instead of sock_wspace().


Thank you,
Hirokazu Takahashi.


--- net/sunrpc/svcsock.c.ORG	Wed May 14 17:00:35 2031
+++ net/sunrpc/svcsock.c	Fri May 16 11:43:46 2031
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
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
