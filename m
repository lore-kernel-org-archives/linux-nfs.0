From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: PATCH - RPC/TCP 1 of 4 - Rearrange setting of snd/rcv buf size to avoid locking issue
Date: Tue, 13 Aug 2002 12:56:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15704.30067.278698.903038@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: minoura@valinux.co.jp (Minoura Makoto), Chuck Lever <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eRtL-0008JC-00
	for <nfs@lists.sourceforge.net>; Mon, 12 Aug 2002 19:58:43 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <minoura@valinux.co.jp>)
	(for <cel@citi.umich.edu>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Tue, 13 Aug 2002 12:56:54 +1000
To: Linus Torvalds <torvalds@transmeta.com>
cc: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This patch and the next three fix problems found and reported by
Minoura Makoto back in April (sorry for the delay, and thanks).
They all relate to RPC over TCP.  My patches are not quite the same as
Minoura's but they do address the problem.

Patches are against 2.5.31

NeilBrown


### Comments for ChangeSet

Currently svc_sock_setbuf can be called under a spinlock,
but it can try to lock a socket, which can block....

Now when we decide that changing the size might be good we
set a flag (SK_CHNGBUF) and then later (when the next
packet arrives) we change the sizes appropriately.


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcsock.h |    1 
 ./net/sunrpc/svcsock.c           |   58 ++++++++++++++++++---------------------
 2 files changed, 28 insertions(+), 31 deletions(-)

--- ./include/linux/sunrpc/svcsock.h	2002/08/12 02:59:27	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/08/12 06:01:41	1.2
@@ -30,6 +30,7 @@ struct svc_sock {
 #define	SK_TEMP		4			/* temp (TCP) socket */
 #define	SK_QUED		5			/* on serv->sk_sockets */
 #define	SK_DEAD		6			/* socket closed */
+#define	SK_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
 
 	int			sk_reserved;	/* space on outq that is reserved */
 
--- ./net/sunrpc/svcsock.c	2002/08/12 03:00:33	1.1
+++ ./net/sunrpc/svcsock.c	2002/08/12 06:01:42	1.2
@@ -481,6 +481,16 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	u32		*data;
 	int		err, len;
 
+	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+	    /* udp sockets need large rcvbuf as all pending
+	     * requests are still in that buffer.  sndbuf must
+	     * also be large enough that there is enough space
+	     * for one reply per thread.
+	     */
+	    svc_sock_setbufsize(svsk->sk_sock,
+				(serv->sv_nrthreads+3) * serv->sv_bufsz,
+				(serv->sv_nrthreads+3) * serv->sv_bufsz);
+
 	clear_bit(SK_DATA, &svsk->sk_flags);
 	while ((skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
 		svc_sock_received(svsk);
@@ -564,6 +574,8 @@ svc_udp_init(struct svc_sock *svsk)
 	svsk->sk_recvfrom = svc_udp_recvfrom;
 	svsk->sk_sendto = svc_udp_sendto;
 
+	set_bit(SK_CHNGBUF, &svsk->sk_flags);
+
 	return 0;
 }
 
@@ -771,6 +783,18 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 	}
 
+	if (test_and_clear_bit(SK_CHNGBUF, &svsk->sk_flags))
+		/* sndbuf needs to have room for one request
+		 * per thread, otherwise we can stall even when the
+		 * network isn't a bottleneck.
+		 * rcvbuf just needs to be able to hold a few requests.
+		 * Normally they will be removed from the queue 
+		 * as soon a a complete request arrives.
+		 */
+		svc_sock_setbufsize(svsk->sk_sock,
+				    (serv->sv_nrthreads+3) * serv->sv_bufsz,
+				    3 * serv->sv_bufsz);
+
 	clear_bit(SK_DATA, &svsk->sk_flags);
 
 	/* Receive data. If we haven't got the record length yet, get
@@ -916,17 +940,7 @@ svc_tcp_init(struct svc_sock *svsk)
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
 
-		/* sndbuf needs to have room for one request
-		 * per thread, otherwise we can stall even when the
-		 * network isn't a bottleneck.
-		 * rcvbuf just needs to be able to hold a few requests.
-		 * Normally they will be removed from the queue 
-		 * as soon a a complete request arrives.
-		 */
-		svc_sock_setbufsize(svsk->sk_sock,
-				    (svsk->sk_server->sv_nrthreads+3) *
-				    svsk->sk_server->sv_bufsz,
-				    3 * svsk->sk_server->sv_bufsz);
+		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 	}
 
 	return 0;
@@ -945,30 +959,12 @@ svc_sock_update_bufs(struct svc_serv *se
 	list_for_each(le, &serv->sv_permsocks) {
 		struct svc_sock *svsk = 
 			list_entry(le, struct svc_sock, sk_list);
-		struct socket *sock = svsk->sk_sock;
-		if (sock->type == SOCK_DGRAM) {
-			/* udp sockets need large rcvbuf as all pending
-			 * requests are still in that buffer.
-			 */
-			svc_sock_setbufsize(sock,
-					    (serv->sv_nrthreads+3) * serv->sv_bufsz,
-					    (serv->sv_nrthreads+3) * serv->sv_bufsz);
-		} else if (svsk->sk_sk->state != TCP_LISTEN) {
-			printk(KERN_ERR "RPC update_bufs: permanent sock neither UDP or TCP_LISTEN\n");
-		}
+		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 	}
 	list_for_each(le, &serv->sv_tempsocks) {
 		struct svc_sock *svsk =
 			list_entry(le, struct svc_sock, sk_list);
-		struct socket *sock = svsk->sk_sock;
-		if (sock->type == SOCK_STREAM) {
-			/* See svc_tcp_init above for rationale on buffer sizes */
-			svc_sock_setbufsize(sock,
-					    (serv->sv_nrthreads+3) *
-					    serv->sv_bufsz,
-					    3 * serv->sv_bufsz);
-		} else 
-			printk(KERN_ERR "RPC update_bufs: temp sock not TCP\n");
+		set_bit(SK_CHNGBUF, &svsk->sk_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 }


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
