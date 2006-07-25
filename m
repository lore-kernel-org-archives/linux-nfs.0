From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 004 of 11] knfsd: convert sk_reserved to atomic_t
Date: Tue, 25 Jul 2006 15:08:55 +1000
Message-ID: <1153804135.21040.9.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5FAE-0003HJ-1I
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:09:02 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5FAD-00038J-3x
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:09:02 -0700
To: Neil Brown <neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

knfsd: Convert the svc_sock->sk_inuse variable from an int protected
by svc_serv->sv_lock, to an atomic.  This reduces (by 1) the number of
places we need to take the (effectively global) svc_serv->sv_lock.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svcsock.h |    2 +-
 net/sunrpc/svcsock.c           |   12 +++++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

Index: linus-git/include/linux/sunrpc/svcsock.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svcsock.h	2006-07-24 16:59:07.008514424 +1000
+++ linus-git/include/linux/sunrpc/svcsock.h	2006-07-24 17:16:25.602833875 +1000
@@ -34,7 +34,7 @@ struct svc_sock {
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
 
-	int			sk_reserved;	/* space on outq that is reserved */
+	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
 	spinlock_t		sk_defer_lock;	/* protects sk_deferred */
 	struct list_head	sk_deferred;	/* deferred requests that need to
Index: linus-git/net/sunrpc/svcsock.c
===================================================================
--- linus-git.orig/net/sunrpc/svcsock.c	2006-07-24 16:59:07.088504101 +1000
+++ linus-git/net/sunrpc/svcsock.c	2006-07-24 17:16:25.698821516 +1000
@@ -176,13 +176,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	}
 
 	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
-	if (((svsk->sk_reserved + serv->sv_bufsz)*2
+	if (((atomic_read(&svsk->sk_reserved) + serv->sv_bufsz)*2
 	     > svc_sock_wspace(svsk))
 	    && !test_bit(SK_CLOSE, &svsk->sk_flags)
 	    && !test_bit(SK_CONN, &svsk->sk_flags)) {
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: socket %p  no space, %d*2 > %ld, not enqueued\n",
-			svsk->sk_sk, svsk->sk_reserved+serv->sv_bufsz,
+			svsk->sk_sk, atomic_read(&svsk->sk_reserved)+serv->sv_bufsz,
 			svc_sock_wspace(svsk));
 		goto out_unlock;
 	}
@@ -208,7 +208,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;
-		svsk->sk_reserved += rqstp->rq_reserved;
+		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
@@ -270,10 +270,8 @@ void svc_reserve(struct svc_rqst *rqstp,
 
 	if (space < rqstp->rq_reserved) {
 		struct svc_sock *svsk = rqstp->rq_sock;
-		spin_lock_bh(&svsk->sk_server->sv_lock);
-		svsk->sk_reserved -= (rqstp->rq_reserved - space);
+		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_reserved);
 		rqstp->rq_reserved = space;
-		spin_unlock_bh(&svsk->sk_server->sv_lock);
 
 		svc_sock_enqueue(svsk);
 	}
@@ -1189,7 +1187,7 @@ svc_recv(struct svc_serv *serv, struct s
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;	
-		svsk->sk_reserved += rqstp->rq_reserved;
+		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_serv_enqueue(serv, rqstp);

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
