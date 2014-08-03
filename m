Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36224 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaHCRDY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:24 -0400
Received: by mail-qg0-f41.google.com with SMTP id q107so7830467qgd.0
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] SUNRPC: Do not grab pool->sp_lock unnecessarily in svc_get_next_xprt
Date: Sun,  3 Aug 2014 13:03:09 -0400
Message-Id: <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b731077b6a30..2c30193c7a13 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -651,8 +651,8 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 	} else {
 		if (pool->sp_task_pending) {
 			pool->sp_task_pending = 0;
-			spin_unlock_bh(&pool->sp_lock);
-			return ERR_PTR(-EAGAIN);
+			xprt = ERR_PTR(-EAGAIN);
+			goto out;
 		}
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -672,8 +672,8 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 		 */
 		if (kthread_should_stop()) {
 			set_current_state(TASK_RUNNING);
-			spin_unlock_bh(&pool->sp_lock);
-			return ERR_PTR(-EINTR);
+			xprt = ERR_PTR(-EINTR);
+			goto out;
 		}
 
 		add_wait_queue(&rqstp->rq_wait, &wait);
@@ -683,8 +683,12 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 
 		try_to_freeze();
 
-		spin_lock_bh(&pool->sp_lock);
 		remove_wait_queue(&rqstp->rq_wait, &wait);
+		xprt = rqstp->rq_xprt;
+		if (xprt != NULL)
+			return xprt;
+
+		spin_lock_bh(&pool->sp_lock);
 		if (!time_left)
 			pool->sp_stats.threads_timedout++;
 
@@ -699,6 +703,7 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 				return ERR_PTR(-EAGAIN);
 		}
 	}
+out:
 	spin_unlock_bh(&pool->sp_lock);
 	return xprt;
 }
-- 
1.9.3

