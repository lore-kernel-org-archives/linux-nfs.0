Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:44043 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbaKSMvo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:44 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so309139qcz.38
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:43 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/10] sunrpc: have svc_wake_up only deal with pool 0
Date: Wed, 19 Nov 2014 07:51:21 -0500
Message-Id: <1416401482-2562-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way that svc_wake_up works is a bit inefficient. It walks all of the
available pools for a service and either wakes up a task in each one or
sets the SP_TASK_PENDING flag in each one.

When svc_wake_up is called, there is no need to wake up more than one
thread to do this work. In practice, only lockd currently uses this
function and it's single threaded anyway. Thus, this just boils down to
doing a wake up of a thread in pool 0 or setting a single flag.

Eliminate the for loop in this function and change it to just operate on
pool 0. Also update the comments that sit above it and get rid of some
code that has been commented out for years now.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 37 ++++++++++++++++---------------------
 1 file changed, 16 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 37446046f4bf..b2676e597fc4 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -484,34 +484,29 @@ static void svc_xprt_release(struct svc_rqst *rqstp)
 }
 
 /*
- * External function to wake up a server waiting for data
- * This really only makes sense for services like lockd
- * which have exactly one thread anyway.
+ * Some svc_serv's will have occasional work to do, even when a xprt is not
+ * waiting to be serviced. This function is there to "kick" a task in one of
+ * those services so that it can wake up and do that work. Note that we only
+ * bother with pool 0 as we don't need to wake up more than one thread for
+ * this purpose.
  */
 void svc_wake_up(struct svc_serv *serv)
 {
 	struct svc_rqst	*rqstp;
-	unsigned int i;
 	struct svc_pool *pool;
 
-	for (i = 0; i < serv->sv_nrpools; i++) {
-		pool = &serv->sv_pools[i];
+	pool = &serv->sv_pools[0];
 
-		spin_lock_bh(&pool->sp_lock);
-		if (!list_empty(&pool->sp_threads)) {
-			rqstp = list_entry(pool->sp_threads.next,
-					   struct svc_rqst,
-					   rq_list);
-			dprintk("svc: daemon %p woken up.\n", rqstp);
-			/*
-			svc_thread_dequeue(pool, rqstp);
-			rqstp->rq_xprt = NULL;
-			 */
-			wake_up_process(rqstp->rq_task);
-		} else
-			set_bit(SP_TASK_PENDING, &pool->sp_flags);
-		spin_unlock_bh(&pool->sp_lock);
-	}
+	spin_lock_bh(&pool->sp_lock);
+	if (!list_empty(&pool->sp_threads)) {
+		rqstp = list_entry(pool->sp_threads.next,
+				   struct svc_rqst,
+				   rq_list);
+		dprintk("svc: daemon %p woken up.\n", rqstp);
+		wake_up_process(rqstp->rq_task);
+	} else
+		set_bit(SP_TASK_PENDING, &pool->sp_flags);
+	spin_unlock_bh(&pool->sp_lock);
 }
 EXPORT_SYMBOL_GPL(svc_wake_up);
 
-- 
2.1.0

