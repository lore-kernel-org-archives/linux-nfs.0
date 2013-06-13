Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35847 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758246Ab3FMCzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:55:19 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 13 Jun 2013 12:53:42 +1000
Subject: [PATCH 5/5] sunrpc: Don't schedule an upcall on a replaced cache
 entry.
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Message-ID: <20130613025342.31861.65340.stgit@notabene.brown>
In-Reply-To: <20130613025132.31861.97407.stgit@notabene.brown>
References: <20130613025132.31861.97407.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a cache entry is replaced, the "expiry_time" get set to
zero by a call to "cache_fresh_locked(..., 0)" at the end of
"sunrpc_cache_update".

This low expiry time makes cache_check() think that the 'refresh_age'
is negative, so the 'age' is comparatively large and a refresh is
triggered.
However refreshing a replaced entry it pointless, it cannot achieve
anything useful.

So teach cache_check to ignore a low refresh_age when expiry_time
is zero.

Reported-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d01eb07..13dad67 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -262,7 +262,8 @@ int cache_check(struct cache_detail *detail,
 	if (rqstp == NULL) {
 		if (rv == -EAGAIN)
 			rv = -ENOENT;
-	} else if (rv == -EAGAIN || age > refresh_age/2) {
+	} else if (rv == -EAGAIN ||
+		   (h->expiry_time != 0 && age > refresh_age/2)) {
 		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
 				refresh_age, age);
 		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {


