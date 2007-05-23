From: Greg Banks <gnb@sgi.com>
Subject: [RFC,
	PATCH 1/5] knfsd: completely centralise deferral handling
Date: Thu, 24 May 2007 00:32:47 +1000
Message-ID: <20070523143247.GI14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqrtR-0004vF-To
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:32:49 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX19M7BrWEYS5qwtEE7GmT7b9fLyERxpR4Io=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HqrtU-0001y5-Fp
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:32:52 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Pull all the deferred request logic up into the generic code so
that transport-specified code does not need to be aware of it.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svcsock.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-23 21:39:49.835887107 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-23 21:40:00.030560270 +1000
@@ -754,11 +754,6 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg,
 				(serv->sv_nrthreads+3) * serv->sv_max_mesg);
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
-		return svc_deferred_recv(rqstp);
-	}
-
 	svc_sock_clear_data_ready(svsk);
 	while ((err = kernel_recvmsg(svsk->sk_sock, &msg, NULL,
 				     0, 0, MSG_PEEK | MSG_DONTWAIT)) < 0 ||
@@ -1153,11 +1148,6 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(SK_CONN, &svsk->sk_flags),
 		test_bit(SK_CLOSE, &svsk->sk_flags));
 
-	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
-		svc_sock_received(svsk);
-		return svc_deferred_recv(rqstp);
-	}
-
 	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
 		/* sndbuf needs to have room for one request
 		 * per thread, otherwise we can stall even when the
@@ -1538,6 +1528,10 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	} else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
 		svsk->sk_type->st_accept(svsk);
 		svc_sock_received(svsk);
+	} else if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {
+		dprintk("svc: rqstp=%p got deferred request on svsk=%p\n", rqstp, svsk);
+		svc_sock_received(svsk);
+		len = svc_deferred_recv(rqstp);
 	} else {
 		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
 			 rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
