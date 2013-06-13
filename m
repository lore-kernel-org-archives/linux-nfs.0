Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35828 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757197Ab3FMCyv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:54:51 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 13 Jun 2013 12:53:42 +1000
Subject: [PATCH 1/5] sunrpc/cache: remove races with queuing an upcall.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Message-ID: <20130613025342.31861.1405.stgit@notabene.brown>
In-Reply-To: <20130613025132.31861.97407.stgit@notabene.brown>
References: <20130613025132.31861.97407.stgit@notabene.brown>
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

Also remove the early 'return' from cache_dequeue() to ensure that it
always removes all entries: As there is no locking between setting
CACHE_PENDING and calling sunrpc_cache_pipe_upcall it is not
inconceivable for some other thread to clear CACHE_PENDING and then
someone else to set it and call sunrpc_cache_pipe_upcall, both before
the original threads completed the call.

With this, it perfectly safe and correct to:
 - call cache_dequeue() if and only if we have just
   cleared CACHE_PENDING
 - call sunrpc_cache_pipe_upcall() (via cache_make_upcall)
   if and only if we have just set CACHE_PENDING.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
---
 net/sunrpc/cache.c |   40 +++++++++++++++++++++++++++++-----------
 1 file changed, 29 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 80fe5c8..ce47f45 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1036,23 +1036,32 @@ static int cache_release(struct inode *inode, struct file *filp,
 
 static void cache_dequeue(struct cache_detail *detail, struct cache_head *ch)
 {
-	struct cache_queue *cq;
+	struct cache_queue *cq, *tmp;
+	struct cache_request *cr;
+	struct list_head dequeued;
+
+	INIT_LIST_HEAD(&dequeued);
 	spin_lock(&queue_lock);
-	list_for_each_entry(cq, &detail->queue, list)
+	list_for_each_entry_safe(cq, tmp, &detail->queue, list)
 		if (!cq->reader) {
-			struct cache_request *cr = container_of(cq, struct cache_request, q);
+			cr = container_of(cq, struct cache_request, q);
 			if (cr->item != ch)
 				continue;
+			if (test_bit(CACHE_PENDING, &ch->flags))
+				/* Lost a race and it is pending again */
+				break;
 			if (cr->readers != 0)
 				continue;
-			list_del(&cr->q.list);
-			spin_unlock(&queue_lock);
-			cache_put(cr->item, detail);
-			kfree(cr->buf);
-			kfree(cr);
-			return;
+			list_move(&cr->q.list, &dequeued);
 		}
 	spin_unlock(&queue_lock);
+	while (!list_empty(&dequeued)) {
+		cr = list_entry(dequeued.next, struct cache_request, q.list);
+		list_del(&cr->q.list);
+		cache_put(cr->item, detail);
+		kfree(cr->buf);
+		kfree(cr);
+	}
 }
 
 /*
@@ -1166,6 +1175,7 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 
 	char *buf;
 	struct cache_request *crq;
+	int ret = 0;
 
 	if (!detail->cache_request)
 		return -EINVAL;
@@ -1191,10 +1201,18 @@ int sunrpc_cache_pipe_upcall(struct cache_detail *detail, struct cache_head *h)
 	crq->len = 0;
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
 


