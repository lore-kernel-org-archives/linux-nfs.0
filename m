From: NeilBrown <neilb@suse.de>
Subject: [PATCH 01/12] sunrpc/cache: rename queue_loose to cache_dequeue
Date: Tue, 04 Aug 2009 15:22:38 +1000
Message-ID: <20090804052238.15929.91015.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41280 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879AbZHDFYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:24:12 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

'loose' was a mis-spelling of 'lose', and even that wasn't a good
word choice.
So give this function a more useful name.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index ff0c230..d19c075 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -101,7 +101,7 @@ struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
 EXPORT_SYMBOL_GPL(sunrpc_cache_lookup);
 
 
-static void queue_loose(struct cache_detail *detail, struct cache_head *ch);
+static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch);
 
 static int cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
@@ -117,7 +117,7 @@ static void cache_fresh_unlocked(struct cache_head *head,
 		cache_revisit_request(head);
 	if (test_and_clear_bit(CACHE_PENDING, &head->flags)) {
 		cache_revisit_request(head);
-		queue_loose(detail, head);
+		cache_dequeue(detail, head);
 	}
 }
 
@@ -457,7 +457,7 @@ static int cache_clean(void)
 				)
 				continue;
 			if (test_and_clear_bit(CACHE_PENDING, &ch->flags))
-				queue_loose(current_detail, ch);
+				cache_dequeue(current_detail, ch);
 
 			if (atomic_read(&ch->ref.refcount) == 1)
 				break;
@@ -920,7 +920,7 @@ static const struct file_operations cache_file_operations = {
 };
 
 
-static void queue_loose(struct cache_detail *detail, struct cache_head *ch)
+static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch)
 {
 	struct cache_queue *cq;
 	spin_lock(&queue_lock);


