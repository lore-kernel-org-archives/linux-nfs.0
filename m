From: NeilBrown <neilb@suse.de>
Subject: [PATCH 1/9] sunrpc/cache: change cache_defer_req to return -ve error,
	not boolean.
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909063254.20462.57204.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56283 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbZIIGcj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:32:39 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As "cache_defer_req" does not sound like a predicate, having it return
a boolean value can be confusing.  It is more consistent to return
0 for success and negative for error.

Exactly what error code to return is not important as we don't
differentiate between reasons why the request wasn't deferred,
we only care about whether it was deferred or not.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1a61401..aafb0e7 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -255,7 +255,7 @@ int cache_check(struct cache_detail *detail,
 	}
 
 	if (rv == -EAGAIN) {
-		if (cache_defer_req(rqstp, h) == 0) {
+		if (cache_defer_req(rqstp, h) < 0) {
 			/* Request is not deferred */
 			rv = cache_is_valid(detail, h);
 			if (rv == -EAGAIN)
@@ -511,11 +511,11 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 		 * or continue and drop the oldest below
 		 */
 		if (net_random()&1)
-			return 0;
+			return -ENOMEM;
 	}
 	dreq = req->defer(req);
 	if (dreq == NULL)
-		return 0;
+		return -ENOMEM;
 
 	dreq->item = item;
 
@@ -545,9 +545,9 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	if (!test_bit(CACHE_PENDING, &item->flags)) {
 		/* must have just been validated... */
 		cache_revisit_request(item);
-		return 0;
+		return -EAGAIN;
 	}
-	return 1;
+	return 0;
 }
 
 static void cache_revisit_request(struct cache_head *item)


