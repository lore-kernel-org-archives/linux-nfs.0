From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 9 - Set SOCK_NOSPACE when RPC server decides there is insufficient.
Date: Wed, 21 May 2003 13:12:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19IK1S-00061n-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IK1f-0000vS-00
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
SOCK_NOSPACE is set, so we must set it when we want to get
a ->write_space callback.

 ----------- Diffstat output ------------
 ./net/sunrpc/svcsock.c |    2 ++
 1 files changed, 2 insertions(+)

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-05-20 16:34:34.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2003-05-20 16:34:34.000000000 +1000
@@ -166,6 +166,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		goto out_unlock;
 	}
 
+	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 	if (((svsk->sk_reserved + serv->sv_bufsz)*2
 	     > svc_sock_wspace(svsk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
@@ -176,6 +177,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 			svc_sock_wspace(svsk));
 		goto out_unlock;
 	}
+	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
 
 	/* Mark socket as busy. It will remain in this state until the
 	 * server has processed all pending data and put the socket back


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
