From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 077/100] svc: Make svc_age_temp_sockets svc_age_temp_transports
Date: Fri, 25 Jan 2008 18:16:57 -0500
Message-ID: <1201303040-7779-77-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-55-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-56-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-57-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-58-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-59-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-60-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-61-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-62-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-63-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-64-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-65-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-66-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-67-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-68-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-69-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-70-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-71-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-72-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-73-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-74-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-75-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47520 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762171AbYAYXSQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:18:16 -0500
In-Reply-To: <1201303040-7779-76-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

This function is transport independent. Change it to use svc_xprt directly
and change it's name to reflect this.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index b3a64bf..822ccb6 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1656,49 +1656,50 @@ svc_send(struct svc_rqst *rqstp)
  * Timer function to close old temporary sockets, using
  * a mark-and-sweep algorithm.
  */
-static void
-svc_age_temp_sockets(unsigned long closure)
+static void svc_age_temp_xprts(unsigned long closure)
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
@@ -1756,7 +1757,7 @@ static struct svc_sock *svc_setup_socket(struct svc_serv *serv,
 		serv->sv_tmpcnt++;
 		if (serv->sv_temptimer.function == NULL) {
 			/* setup timer to age temp sockets */
-			setup_timer(&serv->sv_temptimer, svc_age_temp_sockets,
+			setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
 					(unsigned long)serv);
 			mod_timer(&serv->sv_temptimer,
 					jiffies + svc_conn_age_period * HZ);
-- 
1.5.4.rc2.60.gb2e62

