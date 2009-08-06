From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 04/12] sunrpc/cache: recheck cache validity after
	cache_defer_req
Date: Thu, 6 Aug 2009 14:57:04 +1000
Message-ID: <19066.25248.283061.383233@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
	<20090804052238.15929.56800.stgit@notabene.brown>
	<20090804204252.GA24758@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43832 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbZHFE4z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 00:56:55 -0400
In-Reply-To: message from J. Bruce Fields on Tuesday August 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday August 4, bfields@fieldses.org wrote:
> On Tue, Aug 04, 2009 at 03:22:38PM +1000, NeilBrown wrote:
> > If cache_defer_req did not leave the request on a queue, then it could
> > possibly have waited long enough that the cache became valid.  So check the
> > status after the call.
> > 
> > Signed-off-by: NeilBrown <neilb@suse.de>
> >   * Returns 0 if the cache_head can be used, or cache_puts it and returns
> > - * -EAGAIN if upcall is pending,
> > - * -ETIMEDOUT if upcall failed and should be retried,
> > + * -EAGAIN if upcall is pending and request has been queued
> > + * -ETIMEDOUT if upcall failed or request could not be queue or
> 
> s/queue/queued/
> 

:-)

> > @@ -235,10 +243,14 @@ int cache_check(struct cache_detail *detail,
> >  		}
> >  	}
> >  
> > -	if (rv == -EAGAIN)
> > -		if (cache_defer_req(rqstp, h) != 0)
> > -			rv = -ETIMEDOUT;
> > -
> > +	if (rv == -EAGAIN) {
> > +		if (cache_defer_req(rqstp, h) == 0) {
> > +			/* Request is not deferred */
> 
> The code might be more self-explanatory if we wrote:
> 
> 		if (cache_defer_req(rqstp, h) == -ETIMEDOUT) {
> 
> Well, at least it would be obvious we're handling the "failure" case?
> (Even if admittedly it's a "failure" that we may be able to handle).
> 
> It always takes me a little thought whenever I encounter a
> boolean-returning function whose name doesn't have an obvious truth
> value (list_empty, cache_is_valid).

I certainly see you point.  For consistency in the kernel, if the
function name doesn't sound like a boolean it should return 0 or
positive on success and negative for error.

But despite that I changed cache_defer_req to return 0 or 1 rather
than -ETIMEDOUT or 0...

There are three possibly results of cache_defer_req:
  a/ the request has been stored for later processing
  b/ there was a failure while trying to store the request
  c/ there was no need to store the request because the cache
     item is no longer waiting for a reply.

While 'a' is success and 'b' is an error, 'c' doesn't exactly fit in
to either.  However 'b' and 'c' are treated the same way by
cache_check.
So returning '-ETIMEDOUT' for both 'b' and 'c' seemed wrong.

The current return value is a true/false value for the assertion "the
request was successfully deferred".  But choosing a name for
cache_defer_req which makes that meaning obvious seems clumsy.

Thinks.....

Maybe 
   a -> 0 (success, we deferred the request)
   b -> -ENOMEM (failed to find somewhere to store the request)
   c -> -EAGAIN (something happened .. check again).

and in cache_check we write

   if (cache_defer_req(rqstp, h) < 0) {
         /* Request is not deferred */

which maybe a bit more self explanatory??

NeilBrown


>From c970b6abce98044de573336b3a867b7ed39642e4 Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Thu, 6 Aug 2009 14:56:13 +1000
Subject: [PATCH] sunrpc/cache: recheck cache validity after cache_defer_req

If cache_defer_req did not leave the request on a queue, then it could
possibly have waited long enough that the cache became valid.  So check the
status after the call.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   51 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 32 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index c1f897c..cec2574 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -173,6 +173,22 @@ struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
 EXPORT_SYMBOL_GPL(sunrpc_cache_update);
 
 static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
+
+static inline int cache_is_valid(struct cache_detail *detail, struct cache_head *h)
+{
+	if (!test_bit(CACHE_VALID, &h->flags) ||
+	    h->expiry_time < get_seconds())
+		return -EAGAIN;
+	else if (detail->flush_time > h->last_refresh)
+		return -EAGAIN;
+	else {
+		/* entry is valid */
+		if (test_bit(CACHE_NEGATIVE, &h->flags))
+			return -ENOENT;
+		else
+			return 0;
+	}
+}
 /*
  * This is the generic cache management routine for all
  * the authentication caches.
@@ -181,8 +197,10 @@ static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
  *
  *
  * Returns 0 if the cache_head can be used, or cache_puts it and returns
- * -EAGAIN if upcall is pending,
- * -ETIMEDOUT if upcall failed and should be retried,
+ * -EAGAIN if upcall is pending and request has been queued
+ * -ETIMEDOUT if upcall failed or request could not be queued or
+ *           upcall completed but item is still invalid (implying that
+ *           the cache item has been replaced with a newer one).
  * -ENOENT if cache entry was negative
  */
 int cache_check(struct cache_detail *detail,
@@ -192,17 +210,7 @@ int cache_check(struct cache_detail *detail,
 	long refresh_age, age;
 
 	/* First decide return status as best we can */
-	if (!test_bit(CACHE_VALID, &h->flags) ||
-	    h->expiry_time < get_seconds())
-		rv = -EAGAIN;
-	else if (detail->flush_time > h->last_refresh)
-		rv = -EAGAIN;
-	else {
-		/* entry is valid */
-		if (test_bit(CACHE_NEGATIVE, &h->flags))
-			rv = -ENOENT;
-		else rv = 0;
-	}
+	rv = cache_is_valid(detail, h);
 
 	/* now see if we want to start an upcall */
 	refresh_age = (h->expiry_time - h->last_refresh);
@@ -235,10 +243,14 @@ int cache_check(struct cache_detail *detail,
 		}
 	}
 
-	if (rv == -EAGAIN)
-		if (cache_defer_req(rqstp, h) != 0)
-			rv = -ETIMEDOUT;
-
+	if (rv == -EAGAIN) {
+		if (cache_defer_req(rqstp, h) < 0) {
+			/* Request is not deferred */
+			rv = cache_is_valid(detail, h);
+			if (rv == -EAGAIN)
+				rv = -ETIMEDOUT;
+		}
+	}
 	if (rv)
 		cache_put(h, detail);
 	return rv;
@@ -557,11 +569,11 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		 * or continue and drop the oldest below
 		 */
 		if (net_random()&1)
-			return -ETIMEDOUT;
+			return -ENOMEM;
 	}
 	dreq = req->defer(req);
 	if (dreq == NULL)
-		return -ETIMEDOUT;
+		return -ENOMEM;
 
 	dreq->item = item;
 
@@ -591,6 +603,7 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	if (!test_bit(CACHE_PENDING, &item->flags)) {
 		/* must have just been validated... */
 		cache_revisit_request(item);
+		return -EAGAIN;
 	}
 	return 0;
 }
-- 
1.6.3.3

