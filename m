Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:37793 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbaHCRD2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:28 -0400
Received: by mail-qa0-f51.google.com with SMTP id k15so5886972qaq.24
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:27 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/11] SUNRPC: More optimisations of svc_xprt_enqueue()
Date: Sun,  3 Aug 2014 13:03:12 -0400
Message-Id: <1407085393-3175-11-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-10-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-10-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just move the transport locking out of the spin lock protected area
altogether.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b334cf71be3a..7eff6938f814 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -346,18 +346,6 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 	if (!svc_xprt_has_something_to_do(xprt))
 		return;
 
-	cpu = get_cpu();
-	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
-	spin_lock_bh(&pool->sp_lock);
-
-	if (!list_empty(&pool->sp_threads) &&
-	    !list_empty(&pool->sp_sockets))
-		printk(KERN_ERR
-		       "svc_xprt_enqueue: "
-		       "threads and transports both waiting??\n");
-
-	pool->sp_stats.packets++;
-
 	/* Mark transport as busy. It will remain in this state until
 	 * the provider calls svc_xprt_received. We update XPT_BUSY
 	 * atomically because it also guards against trying to enqueue
@@ -366,9 +354,15 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
 		/* Don't enqueue transport while already enqueued */
 		dprintk("svc: transport %p busy, not enqueued\n", xprt);
-		goto out_unlock;
+		return;
 	}
 
+	cpu = get_cpu();
+	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
+	spin_lock_bh(&pool->sp_lock);
+
+	pool->sp_stats.packets++;
+
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
@@ -395,7 +389,6 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 		pool->sp_stats.sockets_queued++;
 	}
 
-out_unlock:
 	spin_unlock_bh(&pool->sp_lock);
 	put_cpu();
 }
-- 
1.9.3

