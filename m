Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40490 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab0IWDAK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 23:00:10 -0400
Date: Thu, 23 Sep 2010 13:00:02 +1000
From: Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] sunrpc: fix race in new cache_wait code.
Message-ID: <20100923130002.5f2da3e9@notabene>
In-Reply-To: <20100922175027.GF15560@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
	<20100922025506.31745.67177.stgit@localhost.localdomain>
	<20100922175027.GF15560@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 22 Sep 2010 13:50:27 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Sep 22, 2010 at 12:55:06PM +1000, NeilBrown wrote:
> > If we set up to wait for a cache item to be filled in, and then find
> > that it is no longer pending, it could be that some other thread is
> > in 'cache_revisit_request' and has moved our request to its 'pending' list.
> > So when our setup_deferral calls cache_revisit_request it will find nothing to
> > put on the pending list, and do nothing.
> > 
> > We then return from cache_wait_req, thus leaving the 'sleeper'
> > on-stack structure open to being corrupted by subsequent stack usage.
> > 
> > However that 'sleeper' could still be on the 'pending' list that the
> > other thread is looking at and so any corruption could cause it to behave badly.
> > 
> > To avoid this race we simply take the same path as if the
> > 'wait_for_completion_interruptible_timeout' was interrupted and if the
> > sleeper is no longer on the list (which it won't be) we wait on the
> > completion - which will ensure that any other cache_revisit_request
> > will have let go of the sleeper.
> 
> OK, but I don't think we need that first CACHE_PENDING check in
> setup_deferral at all.  Best just to ignore it?:
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index d789dfc..82804b4 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -567,10 +567,9 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item, int ti
>  	sleeper.completion = COMPLETION_INITIALIZER_ONSTACK(sleeper.completion);
>  	dreq->revisit = cache_restart_thread;
>  
> -	ret = setup_deferral(dreq, item);
> +	setup_deferral(dreq, item);
>  
> -	if (ret ||
> -	    wait_for_completion_interruptible_timeout(
> +	if (wait_for_completion_interruptible_timeout(
>  		    &sleeper.completion, timeout) <= 0) {
>  		/* The completion wasn't completed, so we need
>  		 * to clean up
> 
> Then it's obvious that we always wait for completion, and that we fill
> the basic requirement to avoid corruption here.
> 
> (Which is, in more detail: cache_wait_req must not return while dreq is
> still reachable from anywhere else.  Since dreq is reachable from
> elsewhere only as long as it is hashed, and since anyone else that might
> unhash it will call our revisit (which unconditionally calls complete),
> then forget about it, it suffices for cache_wait_req to either wait for
> completion, or unhash dreq *itself* (before someone else does).)
> 
> Also we don't need the PENDING check to ensure we wait only when
> necessary--we only wait while dreq is hashed, and as long as we're
> hashed anyone clearing PENDING will also end up doing the complete().
> 
> In the deferral case it's maybe a useful optimization if it avoids
> an unnecessary drop sometimes.  Here it doesn't help.
> 
> --b.

I like your thinking and I agree with most of it.
After adding dreq to the hash table, we need to check CACHE_PENDING.  It is
possible that it was cleared moments before we added dreq to the hash-table so
the cache_revisit_request associated with clearing it might have missed our
dreq, so we need to do something about that....

How about this.
It gets rid of the return values (which were confusing anyway) and adds
explicit checks on CAHCE_PENDING where needed.
??

Also, I noticed there is a race with the call to cache_limit_defers.  The
'dreq' could be freed before that is called.

It looks like I need to resubmit a lot of this - do you want to just discard
it all from your -next and I'll make something new?

Thank for the review!
NeilBrown


 cache.c |   53 +++++++++++++++++------------------------------------
 1 file changed, 17 insertions(+), 36 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index c60c7f6..db0fa44 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -37,7 +37,7 @@
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item);
+static void cache_defer_req(struct cache_req *req, struct cache_head *item);
 static void cache_revisit_request(struct cache_head *item);
 
 static void cache_init(struct cache_head *h)
@@ -268,7 +268,8 @@ int cache_check(struct cache_detail *detail,
 	}
 
 	if (rv == -EAGAIN) {
-		if (cache_defer_req(rqstp, h) < 0) {
+		cache_defer_req(rqstp, h);
+		if (!test_bit(CACHE_PENDING, &h->flags)) {
 			/* Request is not deferred */
 			rv = cache_is_valid(detail, h);
 			if (rv == -EAGAIN)
@@ -527,7 +528,7 @@ static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_he
 	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
 }
 
-static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
+static void setup_deferral(struct cache_deferred_req *dreq, struct cache_head *item)
 {
 
 	dreq->item = item;
@@ -537,13 +538,6 @@ static int setup_deferral(struct cache_deferred_req *dreq, struct cache_head *it
 	__hash_deferred_req(dreq, item);
 
 	spin_unlock(&cache_defer_lock);
-
-	if (!test_bit(CACHE_PENDING, &item->flags)) {
-		/* must have just been validated... */
-		cache_revisit_request(item);
-		return -EAGAIN;
-	}
-	return 0;
 }
 
 struct thread_deferred_req {
@@ -558,18 +552,17 @@ static void cache_restart_thread(struct cache_deferred_req *dreq, int too_many)
 	complete(&dr->completion);
 }
 
-static int cache_wait_req(struct cache_req *req, struct cache_head *item, int timeout)
+static void cache_wait_req(struct cache_req *req, struct cache_head *item, int timeout)
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
 		    &sleeper.completion, timeout) <= 0) {
 		/* The completion wasn't completed, so we need
@@ -589,18 +582,6 @@ static int cache_wait_req(struct cache_req *req, struct cache_head *item, int ti
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
 
 static void cache_limit_defers(struct cache_deferred_req *dreq)
@@ -639,7 +620,7 @@ static void cache_limit_defers(struct cache_deferred_req *dreq)
 		discard->revisit(discard, 1);
 }
 
-static int cache_defer_req(struct cache_req *req, struct cache_head *item)
+static void cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
 	int ret;
@@ -647,17 +628,19 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 
 	timeout = req->set_waiter(req, 1);
 	if (timeout) {
-		ret = cache_wait_req(req, item, timeout);
+		cache_wait_req(req, item, timeout);
 		req->set_waiter(req, 0);
-		return ret;
 	} else {
 		dreq = req->defer(req);
 		if (dreq == NULL)
-			return -ENOMEM;
-		if (setup_deferral(dreq, item) < 0)
-			return -EAGAIN;
+			return;
+		setup_deferral(dreq, item);
 		cache_limit_defers(dreq);
-		return 0;
+		if (!test_bit(CACHE_PENDING, &item->flags))
+			/* Bit could have been cleared before we managed to
+			 * set up the deferral, so need to revisit just in case
+			 */
+			cache_revisit_request(item);
 	}
 }
 

