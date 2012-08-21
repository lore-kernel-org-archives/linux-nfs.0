Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46812 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758544Ab2HUU5g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:36 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 13/14] svcrpc: split up svc_handle_xprt
Date: Tue, 21 Aug 2012 16:57:31 -0400
Message-Id: <1345582652-18476-14-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Move initialization of newly accepted socket into a helper.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |   47 +++++++++++++++++++++++++----------------------
 1 file changed, 25 insertions(+), 22 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 6ebc9a9..194d865 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -679,6 +679,23 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 	return xprt;
 }
 
+void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *newxpt)
+{
+	spin_lock_bh(&serv->sv_lock);
+	set_bit(XPT_TEMP, &newxpt->xpt_flags);
+	list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
+	serv->sv_tmpcnt++;
+	if (serv->sv_temptimer.function == NULL) {
+		/* setup timer to age temp transports */
+		setup_timer(&serv->sv_temptimer, svc_age_temp_xprts,
+			    (unsigned long)serv);
+		mod_timer(&serv->sv_temptimer,
+			  jiffies + svc_conn_age_period * HZ);
+	}
+	spin_unlock_bh(&serv->sv_lock);
+	svc_xprt_received(newxpt);
+}
+
 static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 {
 	struct svc_serv *serv = rqstp->rq_server;
@@ -692,29 +709,15 @@ static int svc_handle_xprt(struct svc_rqst *rqstp, struct svc_xprt *xprt)
 	}
 	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
+		/*
+		 * We know this module_get will succeed because the
+		 * listener holds a reference too
+		 */
+		__module_get(xprt->xpt_class->xcl_owner);
+		svc_check_conn_limits(xprt->xpt_server);
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
-		if (newxpt) {
-			/*
-			 * We know this module_get will succeed because the
-			 * listener holds a reference too
-			 */
-			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(xprt->xpt_server);
-			spin_lock_bh(&serv->sv_lock);
-			set_bit(XPT_TEMP, &newxpt->xpt_flags);
-			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
-			serv->sv_tmpcnt++;
-			if (serv->sv_temptimer.function == NULL) {
-				/* setup timer to age temp transports */
-				setup_timer(&serv->sv_temptimer,
-					    svc_age_temp_xprts,
-					    (unsigned long)serv);
-				mod_timer(&serv->sv_temptimer,
-					  jiffies + svc_conn_age_period * HZ);
-			}
-			spin_unlock_bh(&serv->sv_lock);
-			svc_xprt_received(newxpt);
-		}
+		if (newxpt)
+			svc_add_new_temp_xprt(serv, newxpt);
 	} else if (xprt->xpt_ops->xpo_has_wspace(xprt)) {
 		/* XPT_DATA|XPT_DEFERRED case: */
 		dprintk("svc: server %p, pool %u, transport %p, inuse=%d\n",
-- 
1.7.9.5

