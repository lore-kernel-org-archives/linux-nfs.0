From: Jeff Layton <jlayton@redhat.com>
Subject: [RFC][PATCH] sunrpc: remove svc_check_conn_limits
Date: Wed, 15 Oct 2008 11:05:14 -0400
Message-ID: <1224083114-12763-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60433 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753353AbYJOPMc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 11:12:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a patch for the purposes of discussion. It compiles and seems to
work, but I haven't done any stress testing of it (not sure I have a big
enough setup to cause the code in svc_check_conn_limits to fire).

----------------[snip]------------------

svc_check_conn_limits is called whenever we get a new connection from a
client. If the number of "tmpsocks" is more than this formula, older
connections get dropped. We also spew a printk to warn the admin that
they should increase the number of threads (though that's not possible
with services like lockd):

    (serv->sv_nrthreads+3)*20

We only do this check for listening services, so we never call this
check on a UDP receive. As best I can tell, this check was intended to
prevent us from overloading the receive buffers. For TCP though, the
receive buffers are pretty much set to a size regardless of the number
of threads (3 * serv->sv_max_mesg).

Since increasing the number of threads doesn't have any affect on the
receive buffer size for TCP, and we don't call this check for UDP, it
doesn't seem to make much sense to keep this check at all.

This patch just removes it, and some other code that should no longer be
needed with it gone.

It seems to compile and work, but I've not stress-tested this at all.
I'd also appreciate some comment from someone more familiar with the
RDMA code to make sure that I'm not breaking anything there by removing
this.

Thoughts, comments and suggestions are greatly appreciated here...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |    1 -
 net/sunrpc/svc_xprt.c      |   48 --------------------------------------------
 2 files changed, 0 insertions(+), 49 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3afe7fb..9a7543a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -64,7 +64,6 @@ struct svc_serv {
 
 	struct list_head	sv_permsocks;	/* all permanent sockets */
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
-	int			sv_tmpcnt;	/* count of temporary sockets */
 	struct timer_list	sv_temptimer;	/* timer for aging temporary sockets */
 	sa_family_t		sv_family;	/* listener's address family */
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..85ad5ba 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -515,50 +515,6 @@ int svc_port_is_privileged(struct sockaddr *sin)
 }
 
 /*
- * Make sure that we don't have too many active connections.  If we
- * have, something must be dropped.
- *
- * There's no point in trying to do random drop here for DoS
- * prevention. The NFS clients does 1 reconnect in 15 seconds. An
- * attacker can easily beat that.
- *
- * The only somewhat efficient mechanism would be if drop old
- * connections from the same IP first. But right now we don't even
- * record the client IP in svc_sock.
- */
-static void svc_check_conn_limits(struct svc_serv *serv)
-{
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
-		struct svc_xprt *xprt = NULL;
-		spin_lock_bh(&serv->sv_lock);
-		if (!list_empty(&serv->sv_tempsocks)) {
-			if (net_ratelimit()) {
-				/* Try to help the admin */
-				printk(KERN_NOTICE "%s: too many open  "
-				       "connections, consider increasing the "
-				       "number of nfsd threads\n",
-				       serv->sv_name);
-			}
-			/*
-			 * Always select the oldest connection. It's not fair,
-			 * but so is life
-			 */
-			xprt = list_entry(serv->sv_tempsocks.prev,
-					  struct svc_xprt,
-					  xpt_list);
-			set_bit(XPT_CLOSE, &xprt->xpt_flags);
-			svc_xprt_get(xprt);
-		}
-		spin_unlock_bh(&serv->sv_lock);
-
-		if (xprt) {
-			svc_xprt_enqueue(xprt);
-			svc_xprt_put(xprt);
-		}
-	}
-}
-
-/*
  * Receive the next request on any transport.  This code is carefully
  * organised not to touch any cachelines in the shared svc_serv
  * structure, only cachelines in the local svc_pool.
@@ -685,11 +641,9 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			 * listener holds a reference too
 			 */
 			__module_get(newxpt->xpt_class->xcl_owner);
-			svc_check_conn_limits(xprt->xpt_server);
 			spin_lock_bh(&serv->sv_lock);
 			set_bit(XPT_TEMP, &newxpt->xpt_flags);
 			list_add(&newxpt->xpt_list, &serv->sv_tempsocks);
-			serv->sv_tmpcnt++;
 			if (serv->sv_temptimer.function == NULL) {
 				/* setup timer to age temp transports */
 				setup_timer(&serv->sv_temptimer,
@@ -853,8 +807,6 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 	 */
 	if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
 		BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
-		if (test_bit(XPT_TEMP, &xprt->xpt_flags))
-			serv->sv_tmpcnt--;
 		svc_xprt_put(xprt);
 	}
 	spin_unlock_bh(&serv->sv_lock);
-- 
1.5.5.1

