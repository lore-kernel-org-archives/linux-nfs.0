From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] sunrpc - 2 of 3 - Tidy up closing of RPC tcp connections to avoid races
Date: Tue, 07 Jan 2003 13:39:39 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18VjeV-00071r-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Vjee-0005sR-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Jan 2003 18:39:48 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 7 Jan 2003 13:39:40 +1100
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

Also discard SK_QUED as it is never used.

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcsock.h |    1 -
 ./net/sunrpc/svcsock.c           |   28 +++++++++++++++-------------
 2 files changed, 15 insertions(+), 14 deletions(-)

diff ./include/linux/sunrpc/svcsock.h~current~ ./include/linux/sunrpc/svcsock.h
--- ./include/linux/sunrpc/svcsock.h~current~	2003-01-07 13:36:40.000000000 +1100
+++ ./include/linux/sunrpc/svcsock.h	2003-01-07 13:36:40.000000000 +1100
@@ -28,7 +28,6 @@ struct svc_sock {
 #define	SK_CLOSE	2			/* dead or dying */
 #define	SK_DATA		3			/* data pending */
 #define	SK_TEMP		4			/* temp (TCP) socket */
-#define	SK_QUED		5			/* on serv->sk_sockets */
 #define	SK_DEAD		6			/* socket closed */
 #define	SK_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
 #define	SK_DEFERRED	8			/* request on sk_deferred */

diff ./net/sunrpc/svcsock.c~current~ ./net/sunrpc/svcsock.c
--- ./net/sunrpc/svcsock.c~current~	2003-01-07 13:36:33.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2003-01-07 13:36:40.000000000 +1100
@@ -137,6 +137,12 @@ svc_sock_enqueue(struct svc_sock *svsk)
 		printk(KERN_ERR
 			"svc_sock_enqueue: threads and sockets both waiting??\n");
 
+	if (test_bit(SK_DEAD, &svsk->sk_flags)) {
+		/* Don't enqueue dead sockets */
+		dprintk("svc: socket %p is dead, not enqueued\n", svsk->sk_sk);
+		goto out_unlock;
+	}
+
 	if (test_bit(SK_BUSY, &svsk->sk_flags)) {
 		/* Don't enqueue socket while daemon is receiving */
 		dprintk("svc: socket %p busy, not enqueued\n", svsk->sk_sk);
@@ -179,7 +185,6 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	} else {
 		dprintk("svc: socket %p put into queue\n", svsk->sk_sk);
 		list_add_tail(&svsk->sk_ready, &serv->sv_sockets);
-		set_bit(SK_QUED, &svsk->sk_flags);
 	}
 
 out_unlock:
@@ -199,11 +204,10 @@ svc_sock_dequeue(struct svc_serv *serv)
 
 	svsk = list_entry(serv->sv_sockets.next,
 			  struct svc_sock, sk_ready);
-	list_del(&svsk->sk_ready);
+	list_del_init(&svsk->sk_ready);
 
 	dprintk("svc: socket %p dequeued, inuse=%d\n",
 		svsk->sk_sk, svsk->sk_inuse);
-	clear_bit(SK_QUED, &svsk->sk_flags);
 
 	return svsk;
 }
@@ -1176,8 +1180,8 @@ svc_recv(struct svc_serv *serv, struct s
 	if (test_bit(SK_TEMP, &svsk->sk_flags)) {
 		/* push active sockets to end of list */
 		spin_lock_bh(&serv->sv_lock);
-		list_del(&svsk->sk_list);
-		list_add_tail(&svsk->sk_list, &serv->sv_tempsocks);
+		if (!list_empty(&svsk->sk_list))
+			list_move_tail(&svsk->sk_list, &serv->sv_tempsocks);
 		spin_unlock_bh(&serv->sv_lock);
 	}
 
@@ -1273,6 +1277,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = get_seconds();
 	INIT_LIST_HEAD(&svsk->sk_deferred);
+	INIT_LIST_HEAD(&svsk->sk_ready);
 	sema_init(&svsk->sk_sem, 1);
 
 	/* Initialize the socket */
@@ -1368,14 +1373,11 @@ svc_delete_socket(struct svc_sock *svsk)
 
 	spin_lock_bh(&serv->sv_lock);
 
-	list_del(&svsk->sk_list);
-	if (test_bit(SK_TEMP, &svsk->sk_flags))
-		serv->sv_tmpcnt--;
-	if (test_bit(SK_QUED, &svsk->sk_flags))
-		list_del(&svsk->sk_ready);
-
-
-	set_bit(SK_DEAD, &svsk->sk_flags);
+	list_del_init(&svsk->sk_list);
+	list_del_init(&svsk->sk_ready);
+	if (!test_and_set_bit(SK_DEAD, &svsk->sk_flags))
+		if (test_bit(SK_TEMP, &svsk->sk_flags))
+			serv->sv_tmpcnt--;
 
 	if (!svsk->sk_inuse) {
 		spin_unlock_bh(&serv->sv_lock);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
