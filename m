Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:33039 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622AbaHCRD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:26 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so7931332qgf.17
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 09/11] SUNRPC: Fix broken kthread_should_stop test in svc_get_next_xprt
Date: Sun,  3 Aug 2014 13:03:11 -0400
Message-Id: <1407085393-3175-10-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should definitely not be exiting svc_get_next_xprt() with the
thread enqueued. Fix this by ensuring that we fall through to
the dequeue.
Also move the test itself outside the spin lock protected section.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svc_xprt.c | 31 ++++++++++---------------------
 1 file changed, 10 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 438e91c12851..b334cf71be3a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -632,7 +632,7 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 {
 	struct svc_xprt *xprt;
 	struct svc_pool		*pool = rqstp->rq_pool;
-	long			time_left;
+	long			time_left = 0;
 
 	/* Normally we will wait up to 5 seconds for any required
 	 * cache information to be provided.
@@ -665,30 +665,19 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
-
-		/*
-		 * checking kthread_should_stop() here allows us to avoid
-		 * locking and signalling when stopping kthreads that call
-		 * svc_recv. If the thread has already been woken up, then
-		 * we can exit here without sleeping. If not, then it
-		 * it'll be woken up quickly during the schedule_timeout
-		 */
-		if (kthread_should_stop()) {
-			set_current_state(TASK_RUNNING);
-			xprt = ERR_PTR(-EINTR);
-			goto out;
-		}
-
 		spin_unlock_bh(&pool->sp_lock);
 
-		time_left = schedule_timeout(timeout);
-		__set_current_state(TASK_RUNNING);
+		if (!(signalled() || kthread_should_stop())) {
+			time_left = schedule_timeout(timeout);
+			__set_current_state(TASK_RUNNING);
 
-		try_to_freeze();
+			try_to_freeze();
 
-		xprt = rqstp->rq_xprt;
-		if (xprt != NULL)
-			return xprt;
+			xprt = rqstp->rq_xprt;
+			if (xprt != NULL)
+				return xprt;
+		} else
+			__set_current_state(TASK_RUNNING);
 
 		spin_lock_bh(&pool->sp_lock);
 		if (!time_left)
-- 
1.9.3

