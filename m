Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:65363 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbaKUTTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Nov 2014 14:19:42 -0500
Received: by mail-qa0-f41.google.com with SMTP id f12so3951160qad.14
        for <linux-nfs@vger.kernel.org>; Fri, 21 Nov 2014 11:19:41 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] sunrpc: fix potential races in pool_stats collection
Date: Fri, 21 Nov 2014 14:19:29 -0500
Message-Id: <1416597571-4265-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a later patch, we'll be removing some spinlocking around the socket
and thread queueing code in order to fix some contention problems. At
that point, the stats counters will no longer be protected by the
sp_lock.

Change the counters to atomic_long_t fields, except for the
"sockets_queued" counter which will still be manipulated under a
spinlock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Tested-by: Chris Worley <chris.worley@primarydata.com>
---
 include/linux/sunrpc/svc.h |  6 +++---
 net/sunrpc/svc_xprt.c      | 12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 7f80a99c59e4..513957eba0a5 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -26,10 +26,10 @@ typedef int		(*svc_thread_fn)(void *);
 
 /* statistics for svc_pool structures */
 struct svc_pool_stats {
-	unsigned long	packets;
+	atomic_long_t	packets;
 	unsigned long	sockets_queued;
-	unsigned long	threads_woken;
-	unsigned long	threads_timedout;
+	atomic_long_t	threads_woken;
+	atomic_long_t	threads_timedout;
 };
 
 /*
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b2676e597fc4..579ff2249562 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -362,7 +362,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 	pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
 	spin_lock_bh(&pool->sp_lock);
 
-	pool->sp_stats.packets++;
+	atomic_long_inc(&pool->sp_stats.packets);
 
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
@@ -383,7 +383,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
 		svc_xprt_get(xprt);
 		wake_up_process(rqstp->rq_task);
 		rqstp->rq_xprt = xprt;
-		pool->sp_stats.threads_woken++;
+		atomic_long_inc(&pool->sp_stats.threads_woken);
 	} else {
 		dprintk("svc: transport %p put into queue\n", xprt);
 		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
@@ -669,7 +669,7 @@ static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeout)
 
 		spin_lock_bh(&pool->sp_lock);
 		if (!time_left)
-			pool->sp_stats.threads_timedout++;
+			atomic_long_inc(&pool->sp_stats.threads_timedout);
 
 		xprt = rqstp->rq_xprt;
 		if (!xprt) {
@@ -1306,10 +1306,10 @@ static int svc_pool_stats_show(struct seq_file *m, void *p)
 
 	seq_printf(m, "%u %lu %lu %lu %lu\n",
 		pool->sp_id,
-		pool->sp_stats.packets,
+		(unsigned long)atomic_long_read(&pool->sp_stats.packets),
 		pool->sp_stats.sockets_queued,
-		pool->sp_stats.threads_woken,
-		pool->sp_stats.threads_timedout);
+		(unsigned long)atomic_long_read(&pool->sp_stats.threads_woken),
+		(unsigned long)atomic_long_read(&pool->sp_stats.threads_timedout));
 
 	return 0;
 }
-- 
2.1.0

