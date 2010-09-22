Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54453 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab0IVC6G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:58:06 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:07 +1000
Subject: [PATCH 5/7] sunrpc/cache: allow thread manager more control of
	whether threads can wait for upcalls
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025507.31745.30398.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Rather than blindly setting a timeout based on a course idea of
busy-ness, allow the 'cache' to call into the 'rqstp' manager to
request permission to wait for an upcall, and how long to wait for.

This allows the thread manager to know how many threads are waiting
and reduce the permitted timeout when there are a large number.

The same code can check if waiting makes any sense (which it doesn't
on single-threaded services) or if deferral is allowed (which it isn't
e.g. for NFSv4).

The current heuristic is to allow a long wait (30 sec) if fewer than
1/2 the threads are waiting, and to allow no wait at all if there are
more than 1/2 already waiting.

This provides better guaranties that slow responses to upcalls will
not block too many threads for too long.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 include/linux/sunrpc/cache.h |    8 ++++--
 include/linux/sunrpc/svc.h   |    1 +
 net/sunrpc/cache.c           |   30 ++++++++++++-----------
 net/sunrpc/svc_xprt.c        |   54 +++++++++++++++++++++++++++++++++---------
 4 files changed, 64 insertions(+), 29 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 0349635..e2f5e56 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -125,9 +125,11 @@ struct cache_detail {
  */
 struct cache_req {
 	struct cache_deferred_req *(*defer)(struct cache_req *req);
-	int thread_wait;  /* How long (jiffies) we can block the
-			   * current thread to wait for updates.
-			   */
+	/* See how long (jiffies) we can block the
+	 * current thread to wait for updates, and register
+	 * (or unregister) that we are waiting.
+	 */
+	int (*set_waiter)(struct cache_req *req, int set);
 };
 /* this must be embedded in a deferred_request that is being
  * delayed awaiting cache-fill
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 5a3085b..060029a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -48,6 +48,7 @@ struct svc_pool {
 	struct list_head	sp_threads;	/* idle server threads */
 	struct list_head	sp_sockets;	/* pending sockets */
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
+	unsigned int		sp_nrwaiting;	/* # of threads waiting on callbacks */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
 } ____cacheline_aligned_in_smp;
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1963e2a..b14d0ec 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -558,7 +558,7 @@ static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
 	complete(&dr->completion);
 }
 
-static int cache_wait_req(struct cache_req *req, struct cache_head *item)
+static int cache_wait_req(struct cache_req *req, struct cache_head *item, int timeout)
 {
 	struct thread_deferred_req sleeper;
 	struct cache_deferred_req *dreq = &sleeper.handle;
@@ -571,7 +571,7 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item)
 
 	if (ret ||
 	    wait_for_completion_interruptible_timeout(
-		    &sleeper.completion, req->thread_wait) <= 0) {
+		    &sleeper.completion, timeout) <= 0) {
 		/* The completion wasn't completed, so we need
 		 * to clean up
 		 */
@@ -643,20 +643,22 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
 	int ret;
+	int timeout;
 
-	if (req->thread_wait) {
-		ret = cache_wait_req(req, item);
-		if (ret != -ETIMEDOUT)
-			return ret;
+	timeout = req->set_waiter(req, 1);
+	if (timeout) {
+		ret = cache_wait_req(req, item, timeout);
+		req->set_waiter(req, 0);
+		return ret;
+	} else {
+		dreq = req->defer(req);
+		if (dreq == NULL)
+			return -ENOMEM;
+		if (setup_deferral(dreq, item) < 0)
+			return -EAGAIN;
+		cache_limit_defers(dreq);
+		return 0;
 	}
-	dreq = req->defer(req);
-	if (dreq == NULL)
-		return -ENOMEM;
-	if (setup_deferral(dreq, item) < 0)
-		return -EAGAIN;
-	
-	cache_limit_defers(dreq);
-	return 0;
 }
 
 static void cache_revisit_request(struct cache_head *item)
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 95fc3e8..4d4032c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -20,6 +20,7 @@
 static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt);
 static int svc_deferred_recv(struct svc_rqst *rqstp);
 static struct cache_deferred_req *svc_defer(struct cache_req *req);
+static int svc_set_waiter(struct cache_req *req, int add);
 static void svc_age_temp_xprts(unsigned long closure);
 
 /* apparently the "standard" is that clients close
@@ -651,11 +652,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	if (signalled() || kthread_should_stop())
 		return -EINTR;
 
-	/* Normally we will wait up to 5 seconds for any required
-	 * cache information to be provided.
-	 */
-	rqstp->rq_chandle.thread_wait = 5*HZ;
-
 	spin_lock_bh(&pool->sp_lock);
 	xprt = svc_xprt_dequeue(pool);
 	if (xprt) {
@@ -663,12 +659,6 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
-
-		/* As there is a shortage of threads and this request
-		 * had to be queued, don't allow the thread to wait so
-		 * long for cache updates.
-		 */
-		rqstp->rq_chandle.thread_wait = 1*HZ;
 	} else {
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);
@@ -772,6 +762,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
 	rqstp->rq_chandle.defer = svc_defer;
+	rqstp->rq_chandle.set_waiter = svc_set_waiter;
 
 	if (serv->sv_stats)
 		serv->sv_stats->netcnt++;
@@ -987,7 +978,7 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
 	struct svc_deferred_req *dr;
 
-	if (rqstp->rq_arg.page_len || !rqstp->rq_usedeferral)
+	if (rqstp->rq_arg.page_len)
 		return NULL; /* if more than a page, give up FIXME */
 	if (rqstp->rq_deferred) {
 		dr = rqstp->rq_deferred;
@@ -1065,6 +1056,45 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
 	return dr;
 }
 
+/*
+ * If 'add', the cache wants to wait for user-space to respond to a request.
+ *   We return the number of jiffies to wait.  0 means not to wait at all but
+ *   to try deferral instead.
+ * If not 'add', then the wait is over and we can discount this one.
+ */
+static int svc_set_waiter(struct cache_req *req, int add)
+{
+	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
+	struct svc_pool *pool = rqstp->rq_pool;
+	int rv = 0;
+
+	spin_lock_bh(&pool->sp_lock);
+	if (add) {
+		if (pool->sp_nrthreads <= 1 && rqstp->rq_usedeferral)
+			/* single threaded - never wait */
+			rv = 0;
+		else if (pool->sp_nrwaiting * 2 > pool->sp_nrthreads)
+			/* > 1/2 are waiting already, something looks wrong,
+			 * Don't defer or wait */
+			rv = 1;
+		else
+			/* Wait a reasonably long time */
+			rv = 30 * HZ;
+
+		if (!rqstp->rq_usedeferral && rv == 0)
+			/* just double-checking - we mustn't allow deferral */
+			rv = 1;
+			
+		if (rv)
+			pool->sp_nrwaiting++;
+	} else {
+		BUG_ON(pool->sp_nrwaiting == 0);
+		pool->sp_nrwaiting--;
+	}
+	spin_unlock_bh(&pool->sp_lock);
+	return rv;
+}
+
 /**
  * svc_find_xprt - find an RPC transport instance
  * @serv: pointer to svc_serv to search


