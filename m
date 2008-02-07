From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] SUNRPC: have svc_recv() check kthread_should_stop()
Date: Thu,  7 Feb 2008 16:34:54 -0500
Message-ID: <1202420095-5818-3-git-send-email-jlayton@redhat.com>
References: <1202420095-5818-1-git-send-email-jlayton@redhat.com>
 <1202420095-5818-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50808 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762062AbYBGVe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:34:58 -0500
In-Reply-To: <1202420095-5818-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using kthreads that call into svc_recv, we want to make sure that
they do not block there for a long time when we're trying to take down
the kthread.

This patch changes svc_recv() to check kthread_should_stop() at the same
places that it checks to see if it's signalled(). Also check just before
svc_recv() tries to schedule(). By making sure that we check it just
after setting the task state we can avoid having to use any locking or
signalling to ensure it doesn't block for a long time.

There's still a chance of a 500ms sleep if alloc_page() fails, but
that should be a rare occurrence and isn't a terribly long time in
the context of a kthread being taken down.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc_xprt.c |   24 ++++++++++++++++++++++--
 1 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index ea377e0..a3165a2 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -18,6 +18,7 @@
 #include <linux/skbuff.h>
 #include <linux/file.h>
 #include <linux/freezer.h>
+#include <linux/kthread.h>
 #include <net/sock.h>
 #include <net/checksum.h>
 #include <net/ip.h>
@@ -586,6 +587,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);
 			if (!p) {
+				if (kthread_should_stop())
+					return -EINTR;
 				int j = msecs_to_jiffies(500);
 				schedule_timeout_uninterruptible(j);
 			}
@@ -607,7 +610,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	try_to_freeze();
 	cond_resched();
-	if (signalled())
+	if (signalled() || kthread_should_stop())
 		return -EINTR;
 
 	spin_lock_bh(&pool->sp_lock);
@@ -626,6 +629,20 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		 * to bring down the daemons ...
 		 */
 		set_current_state(TASK_INTERRUPTIBLE);
+
+		/*
+		 * checking kthread_should_stop() here allows us to avoid
+		 * locking and signalling when stopping kthreads that call
+		 * svc_recv. If the thread has already been woken up, then
+		 * we can exit here without sleeping. If not, then it
+		 * it'll be woken up quickly during the schedule_timeout
+		 */
+		if (kthread_should_stop()) {
+			set_current_state(TASK_RUNNING);
+			spin_unlock_bh(&pool->sp_lock);
+			return -EINTR;
+		}
+
 		add_wait_queue(&rqstp->rq_wait, &wait);
 		spin_unlock_bh(&pool->sp_lock);
 
@@ -641,7 +658,10 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 			svc_thread_dequeue(pool, rqstp);
 			spin_unlock_bh(&pool->sp_lock);
 			dprintk("svc: server %p, no data yet\n", rqstp);
-			return signalled()? -EINTR : -EAGAIN;
+			if (signalled() || kthread_should_stop())
+				return -EINTR;
+			else
+				return -EAGAIN;
 		}
 	}
 	spin_unlock_bh(&pool->sp_lock);
-- 
1.5.3.8

