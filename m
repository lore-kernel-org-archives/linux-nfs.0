From: Greg Banks <gnb@sgi.com>
Subject: [patch 13/14] sunrpc: Move struct cache_request to linux/sunrpc/cache.h
Date: Thu, 08 Jan 2009 19:25:23 +1100
Message-ID: <20090108082605.171772000@sgi.com>
References: <20090108082510.050854000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:45001 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753430AbZAHI0N (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 03:26:13 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now the definition of struct cache_request is in the same header file
that declares struct cache_detail, instead of being in a .c file.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/sunrpc/cache.h |   35 ++++++++++++++++++++++++++++++++
 net/sunrpc/cache.c           |   35 --------------------------------
 2 files changed, 35 insertions(+), 35 deletions(-)

Index: bfields/include/linux/sunrpc/cache.h
===================================================================
--- bfields.orig/include/linux/sunrpc/cache.h
+++ bfields/include/linux/sunrpc/cache.h
@@ -131,6 +131,41 @@ struct cache_deferred_req {
 					   int too_many);
 };
 
+/*
+ * Caches communicate with user-space.
+ *
+ * We have a magic /proc file - /proc/sunrpc/<cachename>/channel.
+ *
+ * On read, you get a full request.  If the length passed
+ * to read() is too short, you get nothing and the message is dropped,
+ * which is bad.  So you should use a sufficently large length,
+ * for example PAGE_SIZE.  If there are no requests queued,
+ * read() returns 0.
+ *
+ * On write, an update is processed.  This may, as a side effect,
+ * cause a previously queued request to be de-queued and removed.
+ * Userspace can also pre-emptively write updates which the kernel
+ * has not yet requested.
+ *
+ * Poll works if anything to read, and always allows write.
+ *
+ * The channel is implemented by two linked lists of cache_request
+ * objects.  cd->to_read is requests which have been generated in
+ * the kernel and are waiting for a userspace process to read them.
+ * cd->to_write is requests which have been read by userspace and
+ * are awaiting a reply to be written.
+ *
+ * Both lists are protected by cd->queue_lock.
+ */
+
+struct cache_request {
+	struct list_head	list;
+	atomic_t		count;
+	struct cache_head	*item;
+	int			len;
+	char			buf[0];
+};
+
 
 extern struct cache_head *
 sunrpc_cache_lookup(struct cache_detail *detail,
Index: bfields/net/sunrpc/cache.c
===================================================================
--- bfields.orig/net/sunrpc/cache.c
+++ bfields/net/sunrpc/cache.c
@@ -659,41 +659,6 @@ void cache_clean_deferred(void *owner)
 	}
 }
 
-/*
- * Caches communicate with user-space.
- *
- * We have a magic /proc file - /proc/sunrpc/<cachename>/channel.
- *
- * On read, you get a full request.  If the length passed
- * to read() is too short, you get nothing and the message is dropped,
- * which is bad.  So you should use a sufficently large length,
- * for example PAGE_SIZE.  If there are no requests queued,
- * read() returns 0.
- *
- * On write, an update is processed.  This may, as a side effect,
- * cause a previously queued request to be de-queued and removed.
- * Userspace can also pre-emptively write updates which the kernel
- * has not yet requested.
- *
- * Poll works if anything to read, and always allows write.
- *
- * The channel is implemented by two linked lists of cache_request
- * objects.  cd->to_read is requests which have been generated in
- * the kernel and are waiting for a userspace process to read them.
- * cd->to_write is requests which have been read by userspace and
- * are awaiting a reply to be written.
- *
- * Both lists are protected by cd->queue_lock.
- */
-
-struct cache_request {
-	struct list_head	list;
-	atomic_t		count;
-	struct cache_head	*item;
-	int			len;
-	char			buf[0];
-};
-
 static void
 cache_request_put(struct cache_request *rq, struct cache_detail *cd)
 {

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
