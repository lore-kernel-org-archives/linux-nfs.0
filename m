Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37608 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755Ab3BOTXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2013 14:23:35 -0500
Date: Fri, 15 Feb 2013 14:23:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@start.ca>
Cc: Mark Lord <kernel@teksavvy.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>,
        Tom Horsley <horsley1953@gmail.com>,
        Jason Tibbitts <tibbs@math.uh.edu>
Subject: [PATCH 2/2] svcrpc: fix rpc server shutdown races
Message-ID: <20130215192332.GE19923@fieldses.org>
References: <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
 <20130117130335.GD6598@fieldses.org>
 <50F7FB7E.2020503@parallels.com>
 <50F88C14.7030903@teksavvy.com>
 <50F8DF7E.8080107@parallels.com>
 <50FC74E0.20305@teksavvy.com>
 <20130212205216.GE10267@fieldses.org>
 <511BAAAA.9040804@start.ca>
 <20130215192303.GD19923@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130215192303.GD19923@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rewrite server shutdown to remove the assumption that there are no
longer any threads running (no longer true, for example, when shutting
down the service in one network namespace while it's still running in
others).

Do that by doing what we'd do in normal circumstances: just CLOSE each
socket, then enqueue it.

Since there may not be threads to handle the resulting queued xprts,
also run a simplified version of the svc_recv() loop run by a server to
clean up any closed xprts afterwards.

Cc: stable@kernel.org
Tested-by: Jason Tibbitts <tibbs@math.uh.edu>
Acked-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc.c      |    9 --------
 net/sunrpc/svc_xprt.c |   57 +++++++++++++++++++++++++++----------------------
 2 files changed, 32 insertions(+), 34 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index b9ba2a8..89a588b 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -515,15 +515,6 @@ EXPORT_SYMBOL_GPL(svc_create_pooled);
 
 void svc_shutdown_net(struct svc_serv *serv, struct net *net)
 {
-	/*
-	 * The set of xprts (contained in the sv_tempsocks and
-	 * sv_permsocks lists) is now constant, since it is modified
-	 * only by accepting new sockets (done by service threads in
-	 * svc_recv) or aging old ones (done by sv_temptimer), or
-	 * configuration changes (excluded by whatever locking the
-	 * caller is using--nfsd_mutex in the case of nfsd).  So it's
-	 * safe to traverse those lists and shut everything down:
-	 */
 	svc_close_net(serv, net);
 
 	if (serv->sv_shutdown)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 11a33c8..80a6640 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -955,21 +955,24 @@ void svc_close_xprt(struct svc_xprt *xprt)
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
 
-static void svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, struct net *net)
+static int svc_close_list(struct svc_serv *serv, struct list_head *xprt_list, struct net *net)
 {
 	struct svc_xprt *xprt;
+	int ret = 0;
 
 	spin_lock(&serv->sv_lock);
 	list_for_each_entry(xprt, xprt_list, xpt_list) {
 		if (xprt->xpt_net != net)
 			continue;
+		ret++;
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		set_bit(XPT_BUSY, &xprt->xpt_flags);
+		svc_xprt_enqueue(xprt);
 	}
 	spin_unlock(&serv->sv_lock);
+	return ret;
 }
 
-static void svc_clear_pools(struct svc_serv *serv, struct net *net)
+static struct svc_xprt *svc_dequeue_net(struct svc_serv *serv, struct net *net)
 {
 	struct svc_pool *pool;
 	struct svc_xprt *xprt;
@@ -984,42 +987,46 @@ static void svc_clear_pools(struct svc_serv *serv, struct net *net)
 			if (xprt->xpt_net != net)
 				continue;
 			list_del_init(&xprt->xpt_ready);
+			spin_unlock_bh(&pool->sp_lock);
+			return xprt;
 		}
 		spin_unlock_bh(&pool->sp_lock);
 	}
+	return NULL;
 }
 
-static void svc_clear_list(struct svc_serv *serv, struct list_head *xprt_list, struct net *net)
+static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
 {
 	struct svc_xprt *xprt;
-	struct svc_xprt *tmp;
-	LIST_HEAD(victims);
-
-	spin_lock(&serv->sv_lock);
-	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
-		if (xprt->xpt_net != net)
-			continue;
-		list_move(&xprt->xpt_list, &victims);
-	}
-	spin_unlock(&serv->sv_lock);
 
-	list_for_each_entry_safe(xprt, tmp, &victims, xpt_list)
+	while ((xprt = svc_dequeue_net(serv, net))) {
+		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		svc_delete_xprt(xprt);
+	}
 }
 
+/*
+ * Server threads may still be running (especially in the case where the
+ * service is still running in other network namespaces).
+ *
+ * So we shut down sockets the same way we would on a running server, by
+ * setting XPT_CLOSE, enqueuing, and letting a thread pick it up to do
+ * the close.  In the case there are no such other threads,
+ * threads running, svc_clean_up_xprts() does a simple version of a
+ * server's main event loop, and in the case where there are other
+ * threads, we may need to wait a little while and then check again to
+ * see if they're done.
+ */
 void svc_close_net(struct svc_serv *serv, struct net *net)
 {
-	svc_close_list(serv, &serv->sv_tempsocks, net);
-	svc_close_list(serv, &serv->sv_permsocks, net);
+	int delay = 0;
 
-	svc_clear_pools(serv, net);
-	/*
-	 * At this point the sp_sockets lists will stay empty, since
-	 * svc_xprt_enqueue will not add new entries without taking the
-	 * sp_lock and checking XPT_BUSY.
-	 */
-	svc_clear_list(serv, &serv->sv_tempsocks, net);
-	svc_clear_list(serv, &serv->sv_permsocks, net);
+	while (svc_close_list(serv, &serv->sv_permsocks, net) +
+	       svc_close_list(serv, &serv->sv_tempsocks, net)) {
+
+		svc_clean_up_xprts(serv, net);
+		msleep(delay++);
+	}
 }
 
 /*
-- 
1.7.9.5

