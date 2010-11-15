Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42902 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230Ab0KOA1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Nov 2010 19:27:55 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 15 Nov 2010 11:27:01 +1100
Subject: [PATCH 1/2] sunrpc: remove xpt_pool
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
Message-ID: <20101115002701.19121.46414.stgit@notabene.brown>
In-Reply-To: <20101115002634.19121.7027.stgit@notabene.brown>
References: <20101115002634.19121.7027.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The xpt_pool field is only used for reporting BUGs.
And it isn't used correctly.

In particular, when it is cleared in svc_xprt_received before
XPT_BUSY is cleared, there is no guarantee that either the
compiler or the CPU might not re-order to two assignments, just
setting xpt_pool to NULL after XPT_BUSY is cleared.

If a different cpu were running svc_xprt_enqueue at this moment,
it might see XPT_BUSY clear and then xpt_pool non-NULL, and
so BUG.

This could be fixed by calling
  smp_mb__before_clear_bit()
before the clear_bit.  However as xpt_pool isn't really used,
it seems safest to simply remove xpt_pool.

Another alternate would be to change the clear_bit to
clear_bit_unlock, and the test_and_set_bit to test_and_set_bit_lock.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 include/linux/sunrpc/svc_xprt.h |    1 -
 net/sunrpc/svc_xprt.c           |    6 ------
 2 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index bbdb680..79baf68 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -63,7 +63,6 @@ struct svc_xprt {
 #define XPT_LISTENER	11		/* listening endpoint */
 #define XPT_CACHE_AUTH	12		/* cache auth info */
 
-	struct svc_pool		*xpt_pool;	/* current pool iff queued */
 	struct svc_serv		*xpt_server;	/* service for transport */
 	atomic_t    	    	xpt_reserved;	/* space on outq that is rsvd */
 	struct mutex		xpt_mutex;	/* to serialize sending data */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index c82fe73..ec9d8ef 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -342,8 +342,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		dprintk("svc: transport %p busy, not enqueued\n", xprt);
 		goto out_unlock;
 	}
-	BUG_ON(xprt->xpt_pool != NULL);
-	xprt->xpt_pool = pool;
 
 	/* Handle pending connection */
 	if (test_bit(XPT_CONN, &xprt->xpt_flags))
@@ -358,7 +356,6 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		/* Don't enqueue while not enough space for reply */
 		dprintk("svc: no write space, transport %p  not enqueued\n",
 			xprt);
-		xprt->xpt_pool = NULL;
 		clear_bit(XPT_BUSY, &xprt->xpt_flags);
 		goto out_unlock;
 	}
@@ -380,13 +377,11 @@ void svc_xprt_enqueue(struct svc_xprt *xprt)
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		pool->sp_stats.threads_woken++;
-		BUG_ON(xprt->xpt_pool != pool);
 		wake_up(&rqstp->rq_wait);
 	} else {
 		dprintk("svc: transport %p put into queue\n", xprt);
 		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
 		pool->sp_stats.sockets_queued++;
-		BUG_ON(xprt->xpt_pool != pool);
 	}
 
 out_unlock:
@@ -425,7 +420,6 @@ static struct svc_xprt *svc_xprt_dequeue(struct svc_pool *pool)
 void svc_xprt_received(struct svc_xprt *xprt)
 {
 	BUG_ON(!test_bit(XPT_BUSY, &xprt->xpt_flags));
-	xprt->xpt_pool = NULL;
 	clear_bit(XPT_BUSY, &xprt->xpt_flags);
 	svc_xprt_enqueue(xprt);
 }


