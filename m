Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49318 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab3EJTd1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 May 2013 15:33:27 -0400
Subject: [PATCH 2/8] fs/fscache: remove spin_lock() from the condition in
 while() [ver #2]
To: Trond.Myklebust@netapp.com, torvalds@linux-foundation.org
From: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cachefs@redhat.com, linux-kernel@vger.kernel.org,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 10 May 2013 20:33:15 +0100
Message-ID: <20130510193315.3045.53571.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130510193257.3045.77981.stgit@warthog.procyon.org.uk>
References: <20130510193257.3045.77981.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

The spinlock() within the condition in while() will cause a compile error
if it is not a function. This is not a problem on mainline but it does not
look pretty and there is no reason to do it that way.
That patch writes it a little differently and avoids the double condition.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/page.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index ff000e5..4882c80 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -796,11 +796,16 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 
 	_enter("");
 
-	while (spin_lock(&cookie->stores_lock),
-	       n = radix_tree_gang_lookup_tag(&cookie->stores, results, 0,
-					      ARRAY_SIZE(results),
-					      FSCACHE_COOKIE_PENDING_TAG),
-	       n > 0) {
+	for (;;) {
+		spin_lock(&cookie->stores_lock);
+		n = radix_tree_gang_lookup_tag(&cookie->stores, results, 0,
+					       ARRAY_SIZE(results),
+					       FSCACHE_COOKIE_PENDING_TAG);
+		if (n == 0) {
+			spin_unlock(&cookie->stores_lock);
+			break;
+		}
+
 		for (i = n - 1; i >= 0; i--) {
 			page = results[i];
 			radix_tree_delete(&cookie->stores, page->index);
@@ -812,7 +817,6 @@ void fscache_invalidate_writes(struct fscache_cookie *cookie)
 			page_cache_release(results[i]);
 	}
 
-	spin_unlock(&cookie->stores_lock);
 	_leave("");
 }
 

