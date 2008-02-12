From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] SUNRPC: allow svc_recv to break out of 500ms sleep when alloc_page fails
Date: Tue, 12 Feb 2008 11:47:24 -0500
Message-ID: <1202834844-7785-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759326AbYBLQr1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 11:47:27 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_recv() calls alloc_page(), and if it fails it does a 500ms
uninterruptible sleep and then reattempts. There doesn't seem to be any
real reason for this to be uninterruptible, so change it to an
interruptible sleep. Also check for kthread_stop() and signalled() after
setting the task state to avoid races that might lead to sleeping after
kthread_stop() wakes up the task.

I've done some very basic smoke testing with this, but obviously it's
hard to test the actual changes since this all depends on an
alloc_page() call failing.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc_xprt.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 53c8ea9..dee7837 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -587,10 +587,12 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		while (rqstp->rq_pages[i] == NULL) {
 			struct page *p = alloc_page(GFP_KERNEL);
 			if (!p) {
-				int j = msecs_to_jiffies(500);
-				if (kthread_should_stop())
+				set_current_state(TASK_INTERRUPTIBLE);
+				if (signalled() || kthread_should_stop()) {
+					set_current_state(TASK_RUNNING);
 					return -EINTR;
-				schedule_timeout_uninterruptible(j);
+				}
+				schedule_timeout(msecs_to_jiffies(500));
 			}
 			rqstp->rq_pages[i] = p;
 		}
-- 
1.5.3.8

