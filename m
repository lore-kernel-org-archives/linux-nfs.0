From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,
	PATCH 28/33] svc: Make svc_age_temp_sockets svc_age_temp_transports
Date: Thu, 27 Sep 2007 00:02:33 -0500
Message-ID: <20070927050233.12677.44689.stgit@dell3.ogc.int>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, gnb@sgi.com
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IalWF-0005jg-SG
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:35 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IalWD-0005U9-Gs
	for nfs@lists.sourceforge.net; Wed, 26 Sep 2007 22:02:35 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
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


This function is transport independent. Change it to use svc_xprt directly
and change it's name to reflect this.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   32 +++++++++++++++++---------------
 1 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index f5da434..b1affaa 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1685,49 +1685,51 @@ svc_send(struct svc_rqst *rqstp)
  * a mark-and-sweep algorithm.
  */
 static void
-svc_age_temp_sockets(unsigned long closure)
+svc_age_temp_xprts(unsigned long closure)
 {
 	struct svc_serv *serv = (struct svc_serv *)closure;
-	struct svc_sock *svsk;
+	struct svc_xprt *xprt;
 	struct list_head *le, *next;
 	LIST_HEAD(to_be_aged);
 
-	dprintk("svc_age_temp_sockets\n");
+	dprintk("svc_age_temp_xprts\n");
 
 	if (!spin_trylock_bh(&serv->sv_lock)) {
 		/* busy, try again 1 sec later */
-		dprintk("svc_age_temp_sockets: busy\n");
+		dprintk("svc_age_temp_xprts: busy\n");
 		mod_timer(&serv->sv_temptimer, jiffies + HZ);
 		return;
 	}
 
 	list_for_each_safe(le, next, &serv->sv_tempsocks) {
-		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
 
-		if (!test_and_set_bit(XPT_OLD, &svsk->sk_xprt.xpt_flags))
+		/* First time through, just mark it OLD. Second time 
+		 * through, close it. */
+		if (!test_and_set_bit(XPT_OLD, &xprt->xpt_flags))
 			continue;
 		if (atomic_read(&svsk->sk_xprt.xpt_ref.refcount) > 1 
 		    || test_bit(SK_BUSY, &svsk->sk_flags))
 			continue;
-		svc_xprt_get(&svsk->sk_xprt);
+		svc_xprt_get(xprt);
 		list_move(le, &to_be_aged);
-		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-		set_bit(XPT_DETACHED, &svsk->sk_xprt.xpt_flags);
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
+		set_bit(XPT_DETACHED, &xprt->xpt_flags);
 	}
 	spin_unlock_bh(&serv->sv_lock);
 
 	while (!list_empty(&to_be_aged)) {
 		le = to_be_aged.next;
-		/* fiddling the sk_xprt.xpt_list node is safe 'cos we're XPT_DETACHED */
+		/* fiddling the xpt_list node is safe 'cos we're XPT_DETACHED */
 		list_del_init(le);
-		svsk = list_entry(le, struct svc_sock, sk_xprt.xpt_list);
+		xprt = list_entry(le, struct svc_xprt, xpt_list);
 
 		dprintk("queuing svsk %p for closing, %lu seconds old\n",
-			svsk, get_seconds() - svsk->sk_xprt.xpt_lastrecv);
+			xprt, get_seconds() - xprt->xpt_lastrecv);
 
 		/* a thread will dequeue and close it soon */
-		svc_xprt_enqueue(&svsk->sk_xprt);
-		svc_xprt_put(&svsk->sk_xprt);
+		svc_xprt_enqueue(xprt);
+		svc_xprt_put(xprt);
 	}
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
@@ -1790,7 +1792,7 @@ static struct svc_sock *svc_setup_socket
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
 			/* setup timer to age temp sockets */
-			setup_timer(&serv->sv_temptimer, svc_age_temp_sockets,
+			setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
 					(unsigned long)serv);
 			mod_timer(&serv->sv_temptimer,
 					jiffies + svc_conn_age_period * HZ);

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
