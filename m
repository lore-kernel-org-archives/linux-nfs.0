From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 001 of 11] knfsd: move tempsock aging to a timer
Date: Tue, 25 Jul 2006 15:05:13 +1000
Message-ID: <1153803913.21040.2.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5F6e-0002zs-6F
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:05:20 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G5F6d-0002Vk-74
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 22:05:20 -0700
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

knfsd: Move the aging of RPC/TCP connection sockets from the main
svc_recv() loop to a timer which uses a mark-and-sweep algorithm
every 6 minutes.  This reduces the amount of work that needs to be
done in the main RPC loop and the length of time we need to hold
the (effectively global) svc_serv->sv_lock.


Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc.h     |    1 
 include/linux/sunrpc/svcsock.h |    2 
 net/sunrpc/svc.c               |    3 
 net/sunrpc/svcsock.c           |   96 +++++++++++++++++++++---------
 4 files changed, 76 insertions(+), 26 deletions(-)

Index: linus-git/include/linux/sunrpc/svc.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svc.h	2006-07-05 15:55:39.692174436 +1000
+++ linus-git/include/linux/sunrpc/svc.h	2006-07-24 16:11:01.433553624 +1000
@@ -40,6 +40,7 @@ struct svc_serv {
 	struct list_head	sv_permsocks;	/* all permanent sockets */
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
 	int			sv_tmpcnt;	/* count of temporary sockets */
+	struct timer_list	sv_temptimer;	/* timer for aging temporary sockets */
 
 	char *			sv_name;	/* service name */
 };
Index: linus-git/include/linux/sunrpc/svcsock.h
===================================================================
--- linus-git.orig/include/linux/sunrpc/svcsock.h	2006-07-05 15:55:39.693150872 +1000
+++ linus-git/include/linux/sunrpc/svcsock.h	2006-07-24 16:11:01.433553624 +1000
@@ -31,6 +31,8 @@ struct svc_sock {
 #define	SK_DEAD		6			/* socket closed */
 #define	SK_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
 #define	SK_DEFERRED	8			/* request on sk_deferred */
+#define	SK_OLD		9			/* used for temp socket aging mark+sweep */
+#define	SK_DETACHED	10			/* detached from tempsocks list */
 
 	int			sk_reserved;	/* space on outq that is reserved */
 
Index: linus-git/net/sunrpc/svc.c
===================================================================
--- linus-git.orig/net/sunrpc/svc.c	2006-07-24 15:14:46.987645180 +1000
+++ linus-git/net/sunrpc/svc.c	2006-07-24 16:11:01.453551029 +1000
@@ -57,6 +57,7 @@ svc_create(struct svc_program *prog, uns
 	INIT_LIST_HEAD(&serv->sv_sockets);
 	INIT_LIST_HEAD(&serv->sv_tempsocks);
 	INIT_LIST_HEAD(&serv->sv_permsocks);
+	init_timer(&serv->sv_temptimer);
 	spin_lock_init(&serv->sv_lock);
 
 	/* Remove any stale portmap registrations */
@@ -85,6 +86,8 @@ svc_destroy(struct svc_serv *serv)
 	} else
 		printk("svc_destroy: no threads for serv=%p!\n", serv);
 
+	del_timer_sync(&serv->sv_temptimer);
+
 	while (!list_empty(&serv->sv_tempsocks)) {
 		svsk = list_entry(serv->sv_tempsocks.next,
 				  struct svc_sock,
Index: linus-git/net/sunrpc/svcsock.c
===================================================================
--- linus-git.orig/net/sunrpc/svcsock.c	2006-07-24 15:14:46.987645180 +1000
+++ linus-git/net/sunrpc/svcsock.c	2006-07-24 16:53:39.126813226 +1000
@@ -73,6 +73,13 @@ static struct svc_deferred_req *svc_defe
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
 
+/* apparently the "standard" is that clients close
+ * idle connections after 5 minutes, servers after
+ * 6 minutes
+ *   http://www.connectathon.org/talks96/nfstcp.pdf
+ */
+static int svc_conn_age_period = 6*60;
+
 /*
  * Queue up an idle server thread.  Must have serv->sv_lock held.
  * Note: this is really a stack rather than a queue, so that we only
@@ -1183,24 +1190,7 @@ svc_recv(struct svc_serv *serv, struct s
 		return -EINTR;
 
 	spin_lock_bh(&serv->sv_lock);
-	if (!list_empty(&serv->sv_tempsocks)) {
-		svsk = list_entry(serv->sv_tempsocks.next,
-				  struct svc_sock, sk_list);
-		/* apparently the "standard" is that clients close
-		 * idle connections after 5 minutes, servers after
-		 * 6 minutes
-		 *   http://www.connectathon.org/talks96/nfstcp.pdf 
-		 */
-		if (get_seconds() - svsk->sk_lastrecv < 6*60
-		    || test_bit(SK_BUSY, &svsk->sk_flags))
-			svsk = NULL;
-	}
-	if (svsk) {
-		set_bit(SK_BUSY, &svsk->sk_flags);
-		set_bit(SK_CLOSE, &svsk->sk_flags);
-		rqstp->rq_sock = svsk;
-		svsk->sk_inuse++;
-	} else if ((svsk = svc_sock_dequeue(serv)) != NULL) {
+	if ((svsk = svc_sock_dequeue(serv)) != NULL) {
 		rqstp->rq_sock = svsk;
 		svsk->sk_inuse++;
 		rqstp->rq_reserved = serv->sv_bufsz;	
@@ -1245,13 +1235,7 @@ svc_recv(struct svc_serv *serv, struct s
 		return -EAGAIN;
 	}
 	svsk->sk_lastrecv = get_seconds();
-	if (test_bit(SK_TEMP, &svsk->sk_flags)) {
-		/* push active sockets to end of list */
-		spin_lock_bh(&serv->sv_lock);
-		if (!list_empty(&svsk->sk_list))
-			list_move_tail(&svsk->sk_list, &serv->sv_tempsocks);
-		spin_unlock_bh(&serv->sv_lock);
-	}
+	clear_bit(SK_OLD, &svsk->sk_flags);
 
 	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
 	rqstp->rq_chandle.defer = svc_defer;
@@ -1311,6 +1295,58 @@ svc_send(struct svc_rqst *rqstp)
 }
 
 /*
+ * Timer function to close old temporary sockets, using
+ * a mark-and-sweep algorithm.
+ */
+static void
+svc_age_temp_sockets(unsigned long closure)
+{
+	struct svc_serv *serv = (struct svc_serv *)closure;
+	struct svc_sock *svsk;
+	struct list_head *le, *next;
+	LIST_HEAD(to_be_aged);
+
+	dprintk("svc_age_temp_sockets\n");
+
+	if (!spin_trylock_bh(&serv->sv_lock)) {
+		/* busy, try again 1 sec later */
+		dprintk("svc_age_temp_sockets: busy\n");
+		mod_timer(&serv->sv_temptimer, jiffies + HZ);
+		return;
+	}
+
+	list_for_each_safe(le, next, &serv->sv_tempsocks) {
+		svsk = list_entry(le, struct svc_sock, sk_list);
+
+		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
+			continue;
+		if (svsk->sk_inuse || test_bit(SK_BUSY, &svsk->sk_flags))
+			continue;
+		svsk->sk_inuse++;
+		list_move(le, &to_be_aged);
+		set_bit(SK_CLOSE, &svsk->sk_flags);
+		set_bit(SK_DETACHED, &svsk->sk_flags);
+	}
+	spin_unlock_bh(&serv->sv_lock);
+
+	while (!list_empty(&to_be_aged)) {
+		le = to_be_aged.next;
+		/* fiddling the sk_list node is safe 'cos we're SK_DETACHED */
+		list_del_init(le);
+		svsk = list_entry(le, struct svc_sock, sk_list);
+
+		dprintk("queuing svsk %p for closing, %lu seconds old\n",
+			svsk, get_seconds() - svsk->sk_lastrecv);
+
+		/* a thread will dequeue and close it soon */
+		svc_sock_enqueue(svsk);
+		svc_sock_put(svsk);
+	}
+
+	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
+}
+
+/*
  * Initialize socket for RPC use and create svc_sock struct
  * XXX: May want to setsockopt SO_SNDBUF and SO_RCVBUF.
  */
@@ -1363,6 +1399,13 @@ svc_setup_socket(struct svc_serv *serv, 
 		set_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_tempsocks);
 		serv->sv_tmpcnt++;
+		if (serv->sv_temptimer.function == NULL) {
+			/* setup timer to age temp sockets */
+			serv->sv_temptimer.function = svc_age_temp_sockets;
+			serv->sv_temptimer.data = (unsigned long)serv;
+			serv->sv_temptimer.expires = jiffies + svc_conn_age_period * HZ;
+			add_timer(&serv->sv_temptimer);
+		}
 	} else {
 		clear_bit(SK_TEMP, &svsk->sk_flags);
 		list_add(&svsk->sk_list, &serv->sv_permsocks);
@@ -1446,7 +1489,8 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	spin_lock_bh(&serv->sv_lock);
 
-	list_del_init(&svsk->sk_list);
+	if (!test_and_set_bit(SK_DETACHED, &svsk->sk_flags))
+		list_del_init(&svsk->sk_list);
 	list_del_init(&svsk->sk_ready);
 	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags))
 		if (test_bit(SK_TEMP, &svsk->sk_flags))

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
