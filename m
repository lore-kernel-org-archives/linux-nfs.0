From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 28/38] svc: Make svc_age_temp_sockets svc_age_temp_transports
Date: Thu, 29 Nov 2007 16:56:37 -0600
Message-ID: <20071129225637.15275.43900.stgit@dell3.ogc.int>
References: <20071129225510.15275.82660.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:47424 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763428AbXK2XUU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2007 18:20:20 -0500
In-Reply-To: <20071129225510.15275.82660.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This function is transport independent. Change it to use svc_xprt directly
and change it's name to reflect this.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 net/sunrpc/svcsock.c |   36 +++++++++++++++++++-----------------
 1 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 06a43ae..e4e2b2f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1673,48 +1673,50 @@ svc_send(struct svc_rqst *rqstp)
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
-		if (atomic_read(&svsk->sk_xprt.xpt_ref.refcount) > 1
-		    || test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags))
+		if (atomic_read(&xprt->xpt_ref.refcount) > 1
+		    || test_bit(XPT_BUSY, &xprt->xpt_flags))
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
 
-		dprintk("queuing svsk %p for closing\n", svsk);
+		dprintk("queuing xprt %p for closing\n", xprt);
 
 		/* a thread will dequeue and close it soon */
-		svc_xprt_enqueue(&svsk->sk_xprt);
-		svc_xprt_put(&svsk->sk_xprt);
+		svc_xprt_enqueue(xprt);
+		svc_xprt_put(xprt);
 	}
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
@@ -1772,7 +1774,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
 			/* setup timer to age temp sockets */
-			setup_timer(&serv->sv_temptimer, svc_age_temp_sockets,
+			setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
 					(unsigned long)serv);
 			mod_timer(&serv->sv_temptimer,
 					jiffies + svc_conn_age_period * HZ);
