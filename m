Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56799 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab1ACSbA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jan 2011 13:31:00 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, Neil Brown <neilb@suse.de>
Subject: [PATCH 2/5] nfsd4: avoid double reply caused by deferral race
Date: Mon,  3 Jan 2011 13:30:51 -0500
Message-Id: <1294079454-17891-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294079454-17891-1-git-send-email-bfields@redhat.com>
References: <1294079454-17891-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Commit d29068c431599fa "sunrpc: Simplify cache_defer_req and related
functions." asserted that cache_check() could determine success or
failure of cache_defer_req() by checking the CACHE_PENDING bit.

This isn't quite right.

We need to know whether cache_defer_req() created a deferred request,
in which case sending an rpc reply has become the responsibility of the
deferred request, and it is important that we not send our own reply,
resulting in two different replies to the same request.

And the CACHE_PENDING bit doesn't tell us that; we could have
succesfully created a deferred request at the same time as another
thread cleared the CACHE_PENDING bit.

So, partially revert that commit, to ensure that cache_check() returns
-EAGAIN if and only if a deferred request has been created.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Cc: Neil Brown <neilb@suse.de>
---
 net/sunrpc/cache.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index e433e75..0d6002f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -37,7 +37,7 @@
 
 #define	 RPCDBG_FACILITY RPCDBG_CACHE
 
-static void cache_defer_req(struct cache_req *req, struct cache_head *item);
+static bool cache_defer_req(struct cache_req *req, struct cache_head *item);
 static void cache_revisit_request(struct cache_head *item);
 
 static void cache_init(struct cache_head *h)
@@ -268,9 +268,11 @@ int cache_check(struct cache_detail *detail,
 	}
 
 	if (rv == -EAGAIN) {
-		cache_defer_req(rqstp, h);
-		if (!test_bit(CACHE_PENDING, &h->flags)) {
-			/* Request is not deferred */
+		if (!cache_defer_req(rqstp, h)) {
+			/*
+			 * Request was not deferred; handle it as best
+			 * we can ourselves:
+			 */
 			rv = cache_is_valid(detail, h);
 			if (rv == -EAGAIN)
 				rv = -ETIMEDOUT;
@@ -618,18 +620,19 @@ static void cache_limit_defers(void)
 		discard->revisit(discard, 1);
 }
 
-static void cache_defer_req(struct cache_req *req, struct cache_head *item)
+/* Return true if and only if a deferred request is queued. */
+static bool cache_defer_req(struct cache_req *req, struct cache_head *item)
 {
 	struct cache_deferred_req *dreq;
 
 	if (req->thread_wait) {
 		cache_wait_req(req, item);
 		if (!test_bit(CACHE_PENDING, &item->flags))
-			return;
+			return false;
 	}
 	dreq = req->defer(req);
 	if (dreq == NULL)
-		return;
+		return false;
 	setup_deferral(dreq, item, 1);
 	if (!test_bit(CACHE_PENDING, &item->flags))
 		/* Bit could have been cleared before we managed to
@@ -638,6 +641,7 @@ static void cache_defer_req(struct cache_req *req, struct cache_head *item)
 		cache_revisit_request(item);
 
 	cache_limit_defers();
+	return true;
 }
 
 static void cache_revisit_request(struct cache_head *item)
-- 
1.7.1

