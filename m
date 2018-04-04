Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51336 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752246AbeDDWHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:32 -0400
Subject: [PATCH 07/12] fscache: Fix hanging wait on page discarded by
 writeback
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:30 +0100
Message-ID: <152287965062.14760.14864676977070188285.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the fscache asynchronous write operation elects to discard a page that's
pending storage to the cache because the page would be over the store limit
then it needs to wake the page as someone may be waiting on completion of
the write.

The problem is that the store limit may be updated by a different
asynchronous operation - and so may miss the write - and that the store
limit may not even get updated until later by the netfs.

Fix the kernel hang by making fscache_write_op() mark as written any pages
that are over the limit.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/page.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index adc39c0c62df..b9f18bf4227d 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -778,6 +778,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 
 	_enter("{OP%x,%d}", op->op.debug_id, atomic_read(&op->op.usage));
 
+again:
 	spin_lock(&object->lock);
 	cookie = object->cookie;
 
@@ -819,10 +820,6 @@ static void fscache_write_op(struct fscache_operation *_op)
 		goto superseded;
 	page = results[0];
 	_debug("gang %d [%lx]", n, page->index);
-	if (page->index >= op->store_limit) {
-		fscache_stat(&fscache_n_store_pages_over_limit);
-		goto superseded;
-	}
 
 	radix_tree_tag_set(&cookie->stores, page->index,
 			   FSCACHE_COOKIE_STORING_TAG);
@@ -832,6 +829,9 @@ static void fscache_write_op(struct fscache_operation *_op)
 	spin_unlock(&cookie->stores_lock);
 	spin_unlock(&object->lock);
 
+	if (page->index >= op->store_limit)
+		goto discard_page;
+
 	fscache_stat(&fscache_n_store_pages);
 	fscache_stat(&fscache_n_cop_write_page);
 	ret = object->cache->ops->write_page(op, page);
@@ -847,6 +847,11 @@ static void fscache_write_op(struct fscache_operation *_op)
 	_leave("");
 	return;
 
+discard_page:
+	fscache_stat(&fscache_n_store_pages_over_limit);
+	fscache_end_page_write(object, page);
+	goto again;
+
 superseded:
 	/* this writer is going away and there aren't any more things to
 	 * write */

