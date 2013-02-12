Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48531 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756483Ab3BLUwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2013 15:52:19 -0500
Date: Tue, 12 Feb 2013 15:52:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@teksavvy.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        =?utf-8?B?UGF3ZcWC?= Sikora <pawel.sikora@agmk.net>,
        Tom Horsley <horsley1953@gmail.com>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921 (another one)
Message-ID: <20130212205216.GE10267@fieldses.org>
References: <50F4D800.5040703@teksavvy.com>
 <20130115205625.GH4940@fieldses.org>
 <50F63882.8000607@parallels.com>
 <50F72F03.5070806@teksavvy.com>
 <50F786AF.4070107@parallels.com>
 <20130117130335.GD6598@fieldses.org>
 <50F7FB7E.2020503@parallels.com>
 <50F88C14.7030903@teksavvy.com>
 <50F8DF7E.8080107@parallels.com>
 <50FC74E0.20305@teksavvy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50FC74E0.20305@teksavvy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 20, 2013 at 05:51:12PM -0500, Mark Lord wrote:
> Got it again, this time on a different system
> running mostly the same software.

Mark, Paweł, Tom, could any of you confirm whether this helps?

--b.

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index dbf12ac..2d34b6b 100644
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
index b8e47fa..ca71056 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -856,7 +856,6 @@ static void svc_age_temp_xprts(unsigned long closure)
 	struct svc_serv *serv = (struct svc_serv *)closure;
 	struct svc_xprt *xprt;
 	struct list_head *le, *next;
-	LIST_HEAD(to_be_aged);
 
 	dprintk("svc_age_temp_xprts\n");
 
@@ -877,25 +876,15 @@ static void svc_age_temp_xprts(unsigned long closure)
 		if (atomic_read(&xprt->xpt_ref.refcount) > 1 ||
 		    test_bit(XPT_BUSY, &xprt->xpt_flags))
 			continue;
-		svc_xprt_get(xprt);
-		list_move(le, &to_be_aged);
+		list_del_init(le);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		set_bit(XPT_DETACHED, &xprt->xpt_flags);
-	}
-	spin_unlock_bh(&serv->sv_lock);
-
-	while (!list_empty(&to_be_aged)) {
-		le = to_be_aged.next;
-		/* fiddling the xpt_list node is safe 'cos we're XPT_DETACHED */
-		list_del_init(le);
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
-
 		dprintk("queuing xprt %p for closing\n", xprt);
 
 		/* a thread will dequeue and close it soon */
 		svc_xprt_enqueue(xprt);
-		svc_xprt_put(xprt);
 	}
+	spin_unlock_bh(&serv->sv_lock);
 
 	mod_timer(&serv->sv_temptimer, jiffies + svc_conn_age_period * HZ);
 }
@@ -959,21 +948,24 @@ void svc_close_xprt(struct svc_xprt *xprt)
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
@@ -988,42 +980,46 @@ static void svc_clear_pools(struct svc_serv *serv, struct net *net)
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
