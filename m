From: NeilBrown <neilb@suse.de>
Subject: [PATCH 06/12] sunrpc/cache: avoid variable over-loading in
	cache_defer_req
Date: Tue, 04 Aug 2009 15:22:39 +1000
Message-ID: <20090804052239.15929.87201.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41290 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753553AbZHDFYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:24:49 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cache_defer_req, 'dreq' is used for two significantly different
values that happen to be of the same type.

This is both confusing, and make it hard to extend the range of one of
the values as we will in the next patch.
So introduce 'discard' to take one of the values.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2f19463..4892c5c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -561,7 +561,7 @@ static int cache_defer_cnt;
 
 static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
-	struct cache_deferred_req *dreq;
+	struct cache_deferred_req *dreq, *discard;
 	int hash = DFR_HASH(item);
 
 	if (cache_defer_cnt >= DFR_MAX) {
@@ -586,20 +586,20 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	list_add(&dreq->hash, &cache_defer_hash[hash]);
 
 	/* it is in, now maybe clean up */
-	dreq = NULL;
+	discard = NULL;
 	if (++cache_defer_cnt > DFR_MAX) {
-		dreq = list_entry(cache_defer_list.prev,
-				  struct cache_deferred_req, recent);
+		discard = list_entry(cache_defer_list.prev,
+				     struct cache_deferred_req, recent);
 		list_del_init(&dreq->recent);
 		list_del_init(&dreq->hash);
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


