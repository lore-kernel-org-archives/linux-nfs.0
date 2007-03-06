From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 4] knfsd: Fix recently introduced problem with
	shutting down a busy NFS server.
Date: Tue, 6 Mar 2007 13:15:15 +1100
Message-ID: <1070306021515.26922@suse.de>
References: <20070306131103.26638.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOPEB-0006hc-Ti
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:36 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOPEB-0005W1-E1
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:38 -0800
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


When the last thread of nfsd exits, it shuts down all related sockets.
It currently uses svc_close_socket to do this, but that only is
immediately effective if the socket is not SK_BUSY.

If the socket is busy - i.e. if a request has arrived that has not yet
been processes - svc_close_socket is not effective and the shutdown
process spins.

So create a new svc_force_close_socket which removes the SK_BUSY flag
is set and then calls svc_close_socket.

Also change some open-codes loops in svc_destroy to use
list_for_each_entry_safe.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svcsock.h |    2 +-
 ./net/sunrpc/svc.c               |   21 +++++++++------------
 ./net/sunrpc/svcsock.c           |   16 +++++++++++++++-
 3 files changed, 25 insertions(+), 14 deletions(-)

diff .prev/include/linux/sunrpc/svcsock.h ./include/linux/sunrpc/svcsock.h
--- .prev/include/linux/sunrpc/svcsock.h	2007-03-06 12:19:18.000000000 +1100
+++ ./include/linux/sunrpc/svcsock.h	2007-03-06 12:19:23.000000000 +1100
@@ -66,7 +66,7 @@ struct svc_sock {
  * Function prototypes.
  */
 int		svc_makesock(struct svc_serv *, int, unsigned short, int flags);
-void		svc_close_socket(struct svc_sock *);
+void		svc_force_close_socket(struct svc_sock *);
 int		svc_recv(struct svc_rqst *, long);
 int		svc_send(struct svc_rqst *);
 void		svc_drop(struct svc_rqst *);

diff .prev/net/sunrpc/svc.c ./net/sunrpc/svc.c
--- .prev/net/sunrpc/svc.c	2007-03-06 12:02:18.000000000 +1100
+++ ./net/sunrpc/svc.c	2007-03-06 12:27:12.000000000 +1100
@@ -367,6 +367,7 @@ void
 svc_destroy(struct svc_serv *serv)
 {
 	struct svc_sock	*svsk;
+	struct svc_sock *tmp;
 
 	dprintk("svc: svc_destroy(%s, %d)\n",
 				serv->sv_program->pg_name,
@@ -382,21 +383,17 @@ svc_destroy(struct svc_serv *serv)
 
 	del_timer_sync(&serv->sv_temptimer);
 
-	while (!list_empty(&serv->sv_tempsocks)) {
-		svsk = list_entry(serv->sv_tempsocks.next,
-				  struct svc_sock,
-				  sk_list);
-		svc_close_socket(svsk);
-	}
+	list_for_each_entry_safe(svsk, tmp, &serv->sv_tempsocks, sk_list)
+		svc_force_close_socket(svsk);
+
 	if (serv->sv_shutdown)
 		serv->sv_shutdown(serv);
 
-	while (!list_empty(&serv->sv_permsocks)) {
-		svsk = list_entry(serv->sv_permsocks.next,
-				  struct svc_sock,
-				  sk_list);
-		svc_close_socket(svsk);
-	}
+	list_for_each_entry_safe(svsk, tmp, &serv->sv_permsocks, sk_list)
+		svc_force_close_socket(svsk);
+
+	BUG_ON(!list_empty(&serv->sv_permsocks));
+	BUG_ON(!list_empty(&serv->sv_tempsocks));
 
 	cache_clean_deferred(serv);
 

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-03-06 11:12:40.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-03-06 12:36:20.000000000 +1100
@@ -82,6 +82,7 @@ static void		svc_delete_socket(struct sv
 static void		svc_udp_data_ready(struct sock *, int);
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
+static void		svc_close_socket(struct svc_sock *svsk);
 
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
@@ -1787,7 +1788,7 @@ svc_delete_socket(struct svc_sock *svsk)
 	spin_unlock_bh(&serv->sv_lock);
 }
 
-void svc_close_socket(struct svc_sock *svsk)
+static void svc_close_socket(struct svc_sock *svsk)
 {
 	set_bit(SK_CLOSE, &svsk->sk_flags);
 	if (test_and_set_bit(SK_BUSY, &svsk->sk_flags))
@@ -1800,6 +1801,19 @@ void svc_close_socket(struct svc_sock *s
 	svc_sock_put(svsk);
 }
 
+void svc_force_close_socket(struct svc_sock *svsk)
+{
+	set_bit(SK_CLOSE, &svsk->sk_flags);
+	if (test_bit(SK_BUSY, &svsk->sk_flags)) {
+		/* Waiting to be processed, but no threads left,
+		 * So just remove it from the waiting list
+		 */
+		list_del_init(&svsk->sk_ready);
+		clear_bit(SK_BUSY, &svsk->sk_flags);
+	}
+	svc_close_socket(svsk);
+}
+
 /**
  * svc_makesock - Make a socket for nfsd and lockd
  * @serv: RPC server structure

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
