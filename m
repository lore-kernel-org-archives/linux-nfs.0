Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13225 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab1I2Oru (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Sep 2011 10:47:50 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/13] FS-Cache: Check cookie is still correct in
 __fscache_read_or_alloc_pages()
To: moseleymark@gmail.com, mark@pogo.org.uk, jlayton@redhat.com,
        steved@redhat.com
Cc: linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2011 15:46:48 +0100
Message-ID: <20110929144648.5812.87254.stgit@warthog.procyon.org.uk>
In-Reply-To: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
References: <20110929144536.5812.84405.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Check the object's cookie pointer is still correct in
__fscache_read_or_alloc_pages().  This may change as a result of the cookie
being released by the netfs before we've finished reading from it.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/page.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index b8b62f4..aaed5cd 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -496,6 +496,7 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 	if (fscache_submit_op(object, &op->op) < 0)
 		goto nobufs_unlock;
 	spin_unlock(&cookie->lock);
+	ASSERTCMP(object->cookie, ==, cookie);
 
 	fscache_stat(&fscache_n_retrieval_ops);
 
@@ -513,6 +514,26 @@ int __fscache_read_or_alloc_pages(struct fscache_cookie *cookie,
 		goto error;
 
 	/* ask the cache to honour the operation */
+	if (!object->cookie) {
+		static const char prefix[] = "fs-";
+		printk(KERN_ERR "%sobject: OBJ%x\n",
+		       prefix, object->debug_id);
+		printk(KERN_ERR "%sobjstate=%s fl=%lx wbusy=%x ev=%lx[%lx]\n",
+		       prefix, fscache_object_states[object->state],
+		       object->flags, work_busy(&object->work),
+		       object->events,
+		       object->event_mask & FSCACHE_OBJECT_EVENTS_MASK);
+		printk(KERN_ERR "%sops=%u inp=%u exc=%u\n",
+		       prefix, object->n_ops, object->n_in_progress,
+		       object->n_exclusive);
+		printk(KERN_ERR "%sparent=%p\n",
+		       prefix, object->parent);
+		printk(KERN_ERR "%scookie=%p [pr=%p nd=%p fl=%lx]\n",
+		       prefix, object->cookie,
+		       cookie->parent, cookie->netfs_data, cookie->flags);
+	}
+	ASSERTCMP(object->cookie, ==, cookie);
+
 	if (test_bit(FSCACHE_COOKIE_NO_DATA_YET, &object->cookie->flags)) {
 		fscache_stat(&fscache_n_cop_allocate_pages);
 		ret = object->cache->ops->allocate_pages(

