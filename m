From: NeilBrown <neilb@suse.de>
Subject: [PATCH 4/9] sunrpc/cache: avoid variable over-loading in
	cache_defer_req
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909063254.20462.68582.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:56310 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbZIIGc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:32:59 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cache_defer_req, 'dreq' is used for two significantly different
values that happen to be of the same type.

This is both confusing, and makes it hard to extend the range of one of
the values as we will in the next patch.
So introduce 'discard' to take one of the values.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9c8f0cc..54bbd83 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -500,7 +500,7 @@ static int cache_defer_cnt;
 
 static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
-	struct cache_deferred_req *dreq;
+	struct cache_deferred_req *dreq, *discard;
 	int hash = DFR_HASH(item);
 
 	if (cache_defer_cnt >= DFR_MAX) {
@@ -525,20 +525,20 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	list_add(&dreq->hash, &cache_defer_hash[hash]);
 
 	/* it is in, now maybe clean up */
-	dreq = NULL;
+	discard = NULL;
 	if (++cache_defer_cnt > DFR_MAX) {
-		dreq = list_entry(cache_defer_list.prev,
-				  struct cache_deferred_req, recent);
-		list_del_init(&dreq->recent);
-		list_del_init(&dreq->hash);
+		discard = list_entry(cache_defer_list.prev,
+				     struct cache_deferred_req, recent);
+		list_del_init(&discard->recent);
+		list_del_init(&discard->hash);
 		cache_defer_cnt--;
 	}
 	spin_unlock(&cache_defer_lock);
 
-	if (dreq) {
+	if (discard)
 		/* there was one too many */
-		dreq->revisit(dreq, 1);
-	}
+		discard->revisit(discard, 1);
+
 	if (!test_bit(CACHE_PENDING, &item->flags)) {
 		/* must have just been validated... */
 		cache_revisit_request(item);


