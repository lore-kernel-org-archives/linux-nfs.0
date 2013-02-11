Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932078Ab3BKU6t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 15:58:49 -0500
Date: Mon, 11 Feb 2013 15:58:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com, linux-kernel@vger.kernel.org,
        devel@openvz.org
Subject: Re: [PATCH 0/2] NFSD: fix races in service per-net resources
 allocation
Message-ID: <20130211205845.GE30117@fieldses.org>
References: <20130201111046.24066.72836.stgit@localhost.localdomain>
 <20130211002558.GD10161@fieldses.org>
 <51188D2A.4070605@parallels.com>
 <20130211163715.GA19342@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130211163715.GA19342@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 11, 2013 at 11:37:15AM -0500, J. Bruce Fields wrote:
> On Mon, Feb 11, 2013 at 10:18:18AM +0400, Stanislav Kinsbursky wrote:
> > This one looks a bit complicated and confusing to me. Probably because
> > I'm not that familiar with service transports processing logic.  So,
> > as I can see, we now try to run over all per-net pool-assigned
> > transports, remove them from "ready" queue and delete one by one.
> > Then we try to enqueue all temporary sockets. But where in enqueueing
> > of permanent sockets? I.e. how does they be destroyed with this patch?
> > Then we once again try to run over all per-net pool-assigned
> > transports, remove them from "ready" queue and delete one by one.  Why
> > twice? I.e. why not just lose them, then enqueue them and
> > svc_clean_up_xprts()?
> 
> I think you missed the first svc_close_list?:
> 
> > >  	svc_close_list(serv, &serv->sv_permsocks, net);
> > >+	svc_clean_up_xprts(serv, net);
> > >+	svc_close_list(serv, &serv->sv_tempsocks, net);
> > >+	svc_clean_up_xprts(serv, net);
> 
> The idea is that before we'd like to close all the listeners first, so
> that they aren't busy creating more tempsocks while we're trying to
> close them.
> 
> I overlooked a race, though: if another thread was already handling an
> accept for one of the listeners then it might not get closed by that
> first svc_clean_up_xprts.
> 
> I guess we could do something like:
> 
> 	delay = 0;
> 
>     again:
> 	numclosed = svc_close_list(serv, &serv->sv_permsocks, net);
> 	numclosed += svc_close_list(serv, &serv->sv_tempsocks, net);
> 	if (numclosed) {
> 		svc_clean_up_xprts(serv, net);
> 		msleep(delay++);
> 		goto again;
> 	}
> 
> Seems a little cheesy, but if we don't care much about shutdown
> performance in a rare corner case, maybe it's the simplest way out?

That ends up looking like this.--b.

commit 8468ca5003356bbf5d6157807d4daed075fd438f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Sun Feb 10 16:08:11 2013 -0500

    svcrpc: fix rpc server shutdown races
    
    Rewrite server shutdown to remove the assumption that there are no
    longer any threads running (no longer true, for example, when shutting
    down the service in one network namespace while it's still running in
    others).
    
    Do that by doing what we'd do in normal circumstances: just CLOSE each
    socket, then enqueue it.
    
    Since there may not be threads to handle the resulting queued xprts,
    also run a simplified version of the svc_recv() loop run by a server to
    clean up any closed xprts afterwards.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

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
index 0b67409..0bd0b6f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -948,21 +948,24 @@ void svc_close_xprt(struct svc_xprt *xprt)
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
@@ -977,42 +980,49 @@ static void svc_clear_pools(struct svc_serv *serv, struct net *net)
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
-
-	svc_clear_pools(serv, net);
-	/*
-	 * At this point the sp_sockets lists will stay empty, since
-	 * svc_xprt_enqueue will not add new entries without taking the
-	 * sp_lock and checking XPT_BUSY.
-	 */
-	svc_clear_list(serv, &serv->sv_tempsocks, net);
-	svc_clear_list(serv, &serv->sv_permsocks, net);
+	int closed;
+	int delay = 0;
+
+again:
+	closed = svc_close_list(serv, &serv->sv_permsocks, net);
+	closed += svc_close_list(serv, &serv->sv_tempsocks, net);
+	if (closed) {
+		svc_clean_up_xprts(serv, net);
+		msleep(delay++);
+		goto again;
+	}
 }
 
 /*
