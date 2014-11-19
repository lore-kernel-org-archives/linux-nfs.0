Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:53690 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbaKSMvm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:42 -0500
Received: by mail-qg0-f49.google.com with SMTP id a108so319654qge.22
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:42 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 08/10] sunrpc: convert sp_task_pending flag to use atomic bitops
Date: Wed, 19 Nov 2014 07:51:20 -0500
Message-Id: <1416401482-2562-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll want to be able to handle this flag without
holding the sp_lock. Change this field to an unsigned long flags
field, and declare a new flag in it that can be managed with atomic
bitops.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/linux/sunrpc/svc.h | 4 +++-
 net/sunrpc/svc_xprt.c      | 7 +++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8054a30c8a95..5f0ab39bf7c3 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -50,7 +50,9 @@ struct svc_pool {
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
-	int			sp_task_pending;/* has pending task */
+#define	SP_TASK_PENDING		(0)		/* still work to do even if no
+						 * xprt is queued. */
+	unsigned long		sp_flags;
 } ____cacheline_aligned_in_smp;
 
 /*
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 143c4c8ea2f1..37446046f4bf 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -509,7 +509,7 @@ void svc_wake_up(struct svc_serv *serv)
 			 */
 			wake_up_process(rqstp->rq_task);
 		} else
-			pool->sp_task_pending = 1;
+			set_bit(SP_TASK_PENDING, &pool->sp_flags);
 		spin_unlock_bh(&pool->sp_lock);
 	}
 }
@@ -644,10 +644,9 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 		 * long for cache updates.
 		 */
 		rqstp->rq_chandle.thread_wait = 1*HZ;
-		pool->sp_task_pending = 0;
+		clear_bit(SP_TASK_PENDING, &pool->sp_flags);
 	} else {
-		if (pool->sp_task_pending) {
-			pool->sp_task_pending = 0;
+		if (test_and_clear_bit(SP_TASK_PENDING, &pool->sp_flags)) {
 			xprt = ERR_PTR(-EAGAIN);
 			goto out;
 		}
-- 
2.1.0

