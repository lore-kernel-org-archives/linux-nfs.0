From: NeilBrown <neilb@suse.de>
Subject: [PATCH 07/12] sunrpc/cache: allow thread to block while waiting for
	cache update.
Date: Tue, 04 Aug 2009 15:22:39 +1000
Message-ID: <20090804052239.15929.42666.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41293 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753620AbZHDFY5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:24:57 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current practice of waiting for cache updates by queueing the
whole request to be retried has (at least) two problems.

1/ We NFSv4, requests can be quite complex and re-trying a whole
  request when a later part fails should only be a list-resort, not a
  normal practice.

2/ Large requests, and in particular any 'write' request, will not be
  queued by the current code and doing so would be undesirable.

In many cases only a very sort wait is needed before the cache gets
valid data.

So, providing the underlying transport permits it by setting
 ->thread_wait,
arrange to wait briefly for an upcall to be completed (as reflected in
the clearing of CACHE_PENDING).
If the short wait was not long enough and CACHE_PENDING is still set,
fall back on the old approach.

The 'thread_wait' value is set to 5 seconds when there are spare
threads, and 1 second when there are no spare threads.

These values are probably much higher than needed, but will ensure
some forward progress.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 include/linux/sunrpc/cache.h |    3 +++
 net/sunrpc/cache.c           |   44 +++++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/svc_xprt.c        |   11 +++++++++++
 3 files changed, 57 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 2d8b211..ad62e8d 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -112,6 +112,9 @@ struct cache_detail {
  */
 struct cache_req {
 	struct cache_deferred_req *(*defer)(struct cache_req *req);
+	int thread_wait;  /* How long (jiffies) we can block the
+			   * current thread to wait for updates.
+			   */
 };
 /* this must be embedded in a deferred_request that is being
  * delayed awaiting cache-fill
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 4892c5c..ba2e113 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -559,10 +559,22 @@ static LIST_HEAD(cache_defer_list);
 static struct list_head cache_defer_hash[DFR_HASHSIZE];
 static int cache_defer_cnt;
 
+struct thread_deferred_req {
+	struct cache_deferred_req handle;
+	wait_queue_head_t wait;
+};
+static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
+{
+	struct thread_deferred_req *dr =
+		container_of(dreq, struct thread_deferred_req, handle);
+	wake_up(&dr->wait);
+}
+
 static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq, *discard;
 	int hash = DFR_HASH(item);
+	struct thread_deferred_req sleeper;
 
 	if (cache_defer_cnt >= DFR_MAX) {
 		/* too much in the cache, randomly drop this one,
@@ -571,7 +583,14 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		if (net_random()&1)
 			return 0;
 	}
-	dreq = req->defer(req);
+	if (req->thread_wait) {
+		dreq = &sleeper.handle;
+		init_waitqueue_head(&sleeper.wait);
+		dreq->revisit = cache_restart_thread;
+	} else
+		dreq = req->defer(req);
+
+ retry:
 	if (dreq == NULL)
 		return 0;
 
@@ -605,6 +624,29 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		cache_revisit_request(item);
 		return 0;
 	}
+
+	if (dreq == &sleeper.handle) {
+		wait_event_interruptible_timeout(
+			sleeper.wait,
+			!test_bit(CACHE_PENDING, &item->flags)
+			|| list_empty(&sleeper.handle.hash),
+			req->thread_wait);
+		spin_lock(&cache_defer_lock);
+		if (!list_empty(&sleeper.handle.hash)) {
+			list_del_init(&sleeper.handle.recent);
+			list_del_init(&sleeper.handle.hash);
+			cache_defer_cnt--;
+		}
+		spin_unlock(&cache_defer_lock);
+		if (test_bit(CACHE_PENDING, &item->flags)) {
+			/* item is still pending, try request
+			 * deferral
+			 */
+			dreq = req->defer(req);
+			goto retry;
+		}
+		return 0;
+	}
 	return 1;
 }
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 27d4433..465443c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -655,12 +655,23 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		pool->sp_nwaking--;
 		BUG_ON(pool->sp_nwaking < 0);
 	}
+
+	/* Normally we will wait up to 5 seconds for any required
+	 * cache information to be provided.
+	 */
+	rqstp->rq_chandle.thread_wait = 5*HZ;
 	xprt = svc_xprt_dequeue(pool);
 	if (xprt) {
 		rqstp->rq_xprt = xprt;
 		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
+
+		/* As there is a shortage of threads and this request
+		 * had to be queue, don't allow the thread to wait so
+		 * long for cache updates.
+		 */
+		rqstp->rq_chandle.thread_wait = 1*HZ;
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);


