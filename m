Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53505 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab1ADTbU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 14:31:20 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] svcrpc: ensure cache_check caller sees updated entry
Date: Tue,  4 Jan 2011 14:31:17 -0500
Message-Id: <1294169477-5920-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20110104192350.GE2308@fieldses.org>
References: <20110104192350.GE2308@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Supposes cache_check runs simultaneously with an update on a different
CPU:

	cache_check			task doing update
	^^^^^^^^^^^			^^^^^^^^^^^^^^^^^

	1. test for CACHE_VALID		1'. set entry->data
	   & !CACHE_NEGATIVE

	2. use entry->data		2'. set CACHE_VALID

If the two memory writes performed in step 1' and 2' appear misordered
with respect to the reads in step 1 and 2, then the caller could get
stale data at step 2 even though it saw CACHE_VALID set on the cache
entry.

Add memory barriers to prevent this.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/cache.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a6c5733..72ad836 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -128,6 +128,7 @@ static void cache_fresh_locked(struct cache_head *head, time_t expiry)
 {
 	head->expiry_time = expiry;
 	head->last_refresh = seconds_since_boot();
+	smp_wmb(); /* paired with smp_rmb() in cache_is_valid() */
 	set_bit(CACHE_VALID, &head->flags);
 }
 
@@ -208,8 +209,16 @@ static inline int cache_is_valid(struct cache_detail *detail, struct cache_head
 		/* entry is valid */
 		if (test_bit(CACHE_NEGATIVE, &h->flags))
 			return -ENOENT;
-		else
+		else {
+			/*
+			 * In combination with write barrier in
+			 * sunrpc_cache_update, ensures that anyone
+			 * using the cache entry after this sees the
+			 * updated contents:
+			 */
+			smp_rmb();
 			return 0;
+		}
 	}
 }
 
-- 
1.7.1

