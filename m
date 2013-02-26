Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55245 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab3BZGiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Feb 2013 01:38:51 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 26 Feb 2013 17:36:42 +1100
Subject: [PATCH 1/2] sunrpc/cache: remove races with queuing an upcall.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Message-ID: <20130226063641.6063.80045.stgit@notabene.brown>
In-Reply-To: <20130226063637.6063.34934.stgit@notabene.brown>
References: <20130226063637.6063.34934.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently queue an upcall after setting CACHE_PENDING,
and dequeue after clearing CACHE_PENDING.
So a request should only be present when CACHE_PENDING is set.

However we don't combine the test and the enqueue/dequeue in
a protected region, so it is possible (if unlikely) for a race
to result in a request being queued without CACHE_PENDING set,
or a request to be absent despite CACHE_PENDING.

So: include a test for CACHE_PENDING inside the regions of
enqueue and dequeue where queue_lock is held, and abort
the operation if the value is not as expected.

With this, it perfectly safe and correct to:
 - call cache_dequeue() if and only if we have just
   cleared CACHE_PENDING
 - call sunrpc_cache_pipe_upcall() (via cache_make_upcall)
   if and only if we have just set CACHE_PENDING.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..b48c8ef 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1022,6 +1022,9 @@ static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch)
 			struct cache_request *cr = container_of(cq, struct cache_request, q);
 			if (cr->item != ch)
 				continue;
+			if (test_bit(CACHE_PENDING, &ch->flags))
+				/* Lost a race and it is pending again */
+				break;
 			if (cr->readers != 0)
 				continue;
 			list_del(&cr->q.list);
@@ -1151,6 +1154,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 	struct cache_request *crq;
 	char *bp;
 	int len;
+	int ret = 0;
 
 	if (!cache_listeners_exist(detail)) {
 		warn_no_listener(detail);
@@ -1182,10 +1186,18 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h,
 	crq->len = PAGE_SIZE - len;
 	crq->readers = 0;
 	spin_lock(&queue_lock);
-	list_add_tail(&crq->q.list, &detail->queue);
+	if (test_bit(CACHE_PENDING, &h->flags))
+		list_add_tail(&crq->q.list, &detail->queue);
+	else
+		/* Lost a race, no longer PENDING, so don't enqueue */
+		ret = -EAGAIN;
 	spin_unlock(&queue_lock);
 	wake_up(&queue_wait);
-	return 0;
+	if (ret == -EAGAIN) {
+		kfree(buf);
+		kfree(crq);
+	}
+	return ret;
 }
 EXPORT_SYMBOL_GPL(sunrpc_cache_pipe_upcall);
 


