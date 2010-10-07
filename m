Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52992 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0JGEaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 00:30:20 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 07 Oct 2010 15:29:46 +1100
Subject: [PATCH 1/2] sunrpc: Simplify cache_defer_req and related functions.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20101007042946.26629.7991.stgit@localhost.localdomain>
In-Reply-To: <20101007042637.26629.60300.stgit@localhost.localdomain>
References: <20101007042637.26629.60300.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The return value from cache_defer_req is somewhat confusing.
Various different error codes are returned, but the single caller is
only interested in success or failure.

In fact it can measure this success or failure itself by checking
CACHE_PENDING, which makes the point of the code more explicit.

So change cache_defer_req to return 'void' and test CACHE_PENDING
after it completes, to see if the request was actually deferred or
not.

Similarly setup_deferral and cache_wait_req don't need a return value,
so make them void and remove some code.

The call to cache_revisit_request (to guard against a race) is only
needed for the second call to setup_deferral, so move it out of
setup_deferral to after that second call.  With the first call the
race is handled differently (by explicitly calling
'wait_for_completion').

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   59 ++++++++++++++++++++--------------------------------
 1 files changed, 23 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1e72cc9..a438a9c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -38,7 +38,7 @@
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item);
+static void cache_defer_req(struct cache_req *req, struct cache_head *item);
 static void cache_revisit_request(struct cache_head *item);
 
 static void cache_init(struct cache_head *h)
@@ -269,7 +269,8 @@ int cache_check(struct cache_detail *detail,
 	}
 
 	if (rv == -EAGAIN) {
-		if (cache_defer_req(rqstp, h) < 0) {
+		cache_defer_req(rqstp, h);
+		if (!test_bit(CACHE_PENDING, &h->flags)) {
 			/* Request is not deferred */
 			rv = cache_is_valid(detail, h);
 			if (rv == -EAGAIN)
@@ -525,7 +526,7 @@ static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_he
 	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
 }
 
-static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
+static void setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
 {
 	struct cache_deferred_req *discard;
 
@@ -547,13 +548,6 @@ static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *it
 	if (discard)
 		/* there was one too many */
 		discard->revisit(discard, 1);
-
-	if (!test_bit(CACHE_PENDING, &item->flags)) {
-		/* must have just been validated... */
-		cache_revisit_request(item);
-		return -EAGAIN;
-	}
-	return 0;
 }
 
 struct thread_deferred_req {
@@ -568,18 +562,17 @@ static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
 	complete(&dr->completion);
 }
 
-static int cache_wait_req(struct cache_req *req, struct cache_head *item)
+static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 {
 	struct thread_deferred_req sleeper;
 	struct cache_deferred_req *dreq = &sleeper.handle;
-	int ret;
 
 	sleeper.completion = COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
 	dreq->revisit = cache_restart_thread;
 
-	ret = setup_deferral(dreq, item);
+	setup_deferral(dreq, item);
 
-	if (ret ||
+	if (!test_bit(CACHE_PENDING, &item->flags) ||
 	    wait_for_completion_interruptible_timeout(
 		    &sleeper.completion, req->thread_wait) <= 0) {
 		/* The completion wasn't completed, so we need
@@ -599,41 +592,35 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item)
 			wait_for_completion(&sleeper.completion);
 		}
 	}
-	if (test_bit(CACHE_PENDING, &item->flags)) {
-		/* item is still pending, try request
-		 * deferral
-		 */
-		return -ETIMEDOUT;
-	}
-	/* only return success if we actually deferred the
-	 * request.  In this case we waited until it was
-	 * answered so no deferral has happened - rather
-	 * an answer already exists.
-	 */
-	return -EEXIST;
 }
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item)
+static void cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
-	int ret;
+	int timeout;
 
-	if (cache_defer_cnt >= DFR_MAX) {
+	if (cache_defer_cnt >= DFR_MAX)
 		/* too much in the cache, randomly drop this one,
 		 * or continue and drop the oldest
 		 */
 		if (net_random()&1)
-			return -ENOMEM;
-	}
+			return;
+
+
 	if (req->thread_wait) {
-		ret = cache_wait_req(req, item);
-		if (ret != -ETIMEDOUT)
-			return ret;
+		cache_wait_req(req, item, timeout);
+		if (!test_bit(CACHE_PENDING, &item->flags))
+			return;
 	}
 	dreq = req->defer(req);
 	if (dreq == NULL)
-		return -ENOMEM;
-	return setup_deferral(dreq, item);
+		return;
+	setup_deferral(dreq, item);
+	if (!test_bit(CACHE_PENDING, &item->flags))
+		/* Bit could have been cleared before we managed to
+		 * set up the deferral, so need to revisit just in case
+		 */
+		cache_revisit_request(item);
 }
 
 static void cache_revisit_request(struct cache_head *item)


