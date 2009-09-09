From: NeilBrown <neilb@suse.de>
Subject: [PATCH 3/9] sunrpc/cache: use list_del_init for the list_head entries
	in cache_deferred_req
Date: Wed, 09 Sep 2009 16:32:54 +1000
Message-ID: <20090909063254.20462.7969.stgit@notabene.brown>
References: <20090909062539.20462.67466.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37950 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbZIIGcw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 02:32:52 -0400
In-Reply-To: <20090909062539.20462.67466.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using list_del_init is generally safer than list_del, and it will
allow us, in a subsequent patch, to see if an entry has already been
processed or not.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index baddb23..9c8f0cc 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -529,8 +529,8 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	if (++cache_defer_cnt > DFR_MAX) {
 		dreq = list_entry(cache_defer_list.prev,
 				  struct cache_deferred_req, recent);
-		list_del(&dreq->recent);
-		list_del(&dreq->hash);
+		list_del_init(&dreq->recent);
+		list_del_init(&dreq->hash);
 		cache_defer_cnt--;
 	}
 	spin_unlock(&cache_defer_lock);
@@ -564,7 +564,7 @@ static void cache_revisit_request(struct cache_head *item)
 			dreq = list_entry(lp, struct cache_deferred_req, hash);
 			lp = lp->next;
 			if (dreq->item == item) {
-				list_del(&dreq->hash);
+				list_del_init(&dreq->hash);
 				list_move(&dreq->recent, &pending);
 				cache_defer_cnt--;
 			}
@@ -590,7 +590,7 @@ void cache_clean_deferred(void *owner)
 
 	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
 		if (dreq->owner == owner) {
-			list_del(&dreq->hash);
+			list_del_init(&dreq->hash);
 			list_move(&dreq->recent, &pending);
 			cache_defer_cnt--;
 		}


