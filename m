Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33457 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621Ab1K3XkN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 18:40:13 -0500
Date: Wed, 30 Nov 2011 18:40:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>, Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] svcrpc: avoid memory-corruption on pool shutdown
Message-ID: <20111130234009.GB354@fieldses.org>
References: <20111130233925.GA354@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111130233925.GA354@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Socket callbacks use svc_xprt_enqueue() to add an xprt to a
pool->sp_sockets list.  In normal operation a server thread will later
come along and take the xprt off that list.  On shutdown, after all the
threads have exited, we instead manually walk the sv_tempsocks and
sv_permsocks lists to find all the xprt's and delete them.

So the sp_sockets lists don't really matter any more.  As a result,
we've mostly just ignored them and hoped they would go away.

Which has gotten us into trouble; witness for example ebc63e531cc6
"svcrpc: fix list-corrupting race on nfsd shutdown", the result of Ben
Greear noticing that a still-running svc_xprt_enqueue() could re-add an
xprt to an sp_sockets list just before it was deleted.  The fix was to
remove it from the list at the end of svc_delete_xprt().  But that only
made corruption less likely--I can see nothing that prevents a
svc_xprt_enqueue() from adding another xprt to the list at the same
moment that we're removing this xprt from the list.  In fact, despite
the earlier xpo_detach(), I don't even see what guarantees that
svc_xprt_enqueue() couldn't still be running on this xprt.

So, instead, note that svc_xprt_enqueue() essentially does:
	lock sp_lock
		if XPT_BUSY unset
			add to sp_sockets
	unlock sp_lock

So, if we do:

	set XPT_BUSY on every xprt.
	Empty every sp_sockets list, under the sp_socks locks.

Then we're left knowing that the sp_sockets lists are all empty and will
stay that way, since any svc_xprt_enqueue() will check XPT_BUSY under
the sp_lock and see it set.

And *then* we can continue deleting the xprt's.

(Thanks to Jeff Layton for being correctly suspicious of this code....)

Cc: Ben Greear <greearb@candelatech.com>
Cc: Jeff Layton <jlayton@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |   48 +++++++++++++++++++++++++++++-------------------
 1 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 099ddf9..0d80c06 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -894,14 +894,7 @@ static void svc_delete_xprt(struct svc_xprt *xprt)
 	spin_lock_bh(&serv->sv_lock);
 	if (!test_and_set_bit(XPT_DETACHED, &xprt->xpt_flags))
 		list_del_init(&xprt->xpt_list);
-	/*
-	 * The only time we're called while xpt_ready is still on a list
-	 * is while the list itself is about to be destroyed (in
-	 * svc_destroy).  BUT svc_xprt_enqueue could still be attempting
-	 * to add new entries to the sp_sockets list, so we can't leave
-	 * a freed xprt on it.
-	 */
-	list_del_init(&xprt->xpt_ready);
+	BUG_ON(!list_empty(&xprt->xpt_ready));
 	if (test_bit(XPT_TEMP, &xprt->xpt_flags))
 		serv->sv_tmpcnt--;
 	spin_unlock_bh(&serv->sv_lock);
@@ -932,28 +925,45 @@ EXPORT_SYMBOL_GPL(svc_close_xprt);
 static void svc_close_list(struct list_head *xprt_list)
 {
 	struct svc_xprt *xprt;
-	struct svc_xprt *tmp;
 
-	/*
-	 * The server is shutting down, and no more threads are running.
-	 * svc_xprt_enqueue() might still be running, but at worst it
-	 * will re-add the xprt to sp_sockets, which will soon get
-	 * freed.  So we don't bother with any more locking, and don't
-	 * leave the close to the (nonexistent) server threads:
-	 */
-	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
+	list_for_each_entry(xprt, xprt_list, xpt_list) {
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
-		svc_delete_xprt(xprt);
+		set_bit(XPT_BUSY, &xprt->xpt_flags);
 	}
 }
 
 void svc_close_all(struct svc_serv *serv)
 {
+	struct svc_pool *pool;
+	struct svc_xprt *xprt;
+	struct svc_xprt *tmp;
+	int i;
+
 	svc_close_list(&serv->sv_tempsocks);
 	svc_close_list(&serv->sv_permsocks);
+
+	for (i = 0; i < serv->sv_nrpools; i++) {
+		pool = &serv->sv_pools[i];
+
+		spin_lock_bh(&pool->sp_lock);
+		while (!list_empty(&pool->sp_sockets)) {
+			xprt = list_first_entry(&pool->sp_sockets, struct svc_xprt, xpt_ready);
+			list_del_init(&xprt->xpt_ready);
+		}
+		spin_unlock_bh(&pool->sp_lock);
+	}
+	/*
+	 * At this point the sp_sockets lists will stay empty, since
+	 * svc_enqueue will not add new entries without taking the
+	 * sp_lock and checking XPT_BUSY.
+	 */
+	list_for_each_entry_safe(xprt, tmp, &serv->sv_tempsocks, xpt_list)
+		svc_delete_xprt(xprt);
+	list_for_each_entry_safe(xprt, tmp, &serv->sv_permsocks, xpt_list)
+		svc_delete_xprt(xprt);
+
 	BUG_ON(!list_empty(&serv->sv_permsocks));
 	BUG_ON(!list_empty(&serv->sv_tempsocks));
-
 }
 
 /*
-- 
1.7.5.4

