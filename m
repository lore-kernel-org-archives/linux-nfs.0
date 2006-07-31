From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 11] knfsd: convert sk_reserved to atomic_t
Date: Mon, 31 Jul 2006 10:42:03 +1000
Message-ID: <1060731004203.29219@suse.de>
References: <20060731103458.29040.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7LrG-0003s7-DV
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:10 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7LrF-0001bO-5P
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 17:42:10 -0700
To: Andrew Morton <akpm@osdl.org>
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


From: Greg Banks <gnb@melbourne.sgi.com>

knfsd: Convert the svc_sock->sk_reserved variable from an int protected
by svc_serv->sv_lock, to an atomic.  This reduces (by 1) the number of
places we need to take the (effectively global) svc_serv->sv_lock.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svcsock.c           |   12 +++++-------
 2 files changed, 6 insertions(+), 8 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2006-07-31 10:00:30.000000000 +1000
+++ ./include/linux/sunrpc/svcsock.h	2006-07-31 10:00:44.000000000 +1000
@@ -34,7 +34,7 @@ struct svc_sock {
 #define	SK_OLD		9			/* used for temp socket aging mark+sweep */
 #define	SK_DETACHED	10			/* detached from tempsocks list */
 
-	int			sk_reserved;	/* space on outq that is reserved */
+	atomic_t    	    	sk_reserved;	/* space on outq that is reserved */
 
 	spinlock_t		sk_defer_lock;	/* protects sk_deferred */
 	struct list_head	sk_deferred;	/* deferred requests that need to

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-07-31 10:00:30.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-07-31 10:00:44.000000000 +1000
@@ -177,13 +177,13 @@ svc_sock_enqueue(struct svc_sock *svsk)
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
@@ -209,7 +209,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;
-		svsk->sk_reserved += rqstp->rq_reserved;
+		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
@@ -271,10 +271,8 @@ void svc_reserve(struct svc_rqst *rqstp,
 
 	if (space < rqstp->rq_reserved) {
 		struct svc_sock *svsk = rqstp->rq_sock;
-		spin_lock_bh(&svsk->sk_server->sv_lock);
-		svsk->sk_reserved -= (rqstp->rq_reserved - space);
+		atomic_sub((rqstp->rq_reserved - space), &svsk->sk_reserved);
 		rqstp->rq_reserved = space;
-		spin_unlock_bh(&svsk->sk_server->sv_lock);
 
 		svc_sock_enqueue(svsk);
 	}
@@ -1236,7 +1234,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 		rqstp->rq_sock = svsk;
 		atomic_inc(&svsk->sk_inuse);
 		rqstp->rq_reserved = serv->sv_bufsz;	
-		svsk->sk_reserved += rqstp->rq_reserved;
+		atomic_add(rqstp->rq_reserved, &svsk->sk_reserved);
 	} else {
 		/* No data pending. Go to sleep */
 		svc_serv_enqueue(serv, rqstp);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
