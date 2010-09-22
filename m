Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54900 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001Ab0IVC5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:57:48 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:06 +1000
Subject: [PATCH 2/7] sunrpc/cache: fix recent breakage of cache_clean_deferred
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025506.31745.74964.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit 6610f720e9e8103c22d1f1ccf8fbb695550a571f
broke cache_clean_deferred as entries are no longer added to the
pending list for subsequent revisiting.

So put those requests back on the pending list.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/cache.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 62078be..a9e850e 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -678,8 +678,10 @@ void cache_clean_deferred(void *owner)
 	spin_lock(&cache_defer_lock);
 
 	list_for_each_entry_safe(dreq, tmp, &cache_defer_list, recent) {
-		if (dreq->owner == owner)
+		if (dreq->owner == owner) {
 			__unhash_deferred_req(dreq);
+			list_add(&dreq->recent, &pending);
+		}
 	}
 	spin_unlock(&cache_defer_lock);
 


