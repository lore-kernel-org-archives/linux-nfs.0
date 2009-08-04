From: NeilBrown <neilb@suse.de>
Subject: [PATCH 02/12] sunrpc/cache: make sure deferred requests eventually
	get revisited.
Date: Tue, 04 Aug 2009 15:22:38 +1000
Message-ID: <20090804052238.15929.74402.stgit@notabene.brown>
References: <20090804051145.15929.11356.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52213 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753028AbZHDFYT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 01:24:19 -0400
In-Reply-To: <20090804051145.15929.11356.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While deferred requests normally get revisited quite quickly,
it is possible for a request to remain in the deferral queue
when the cache item is discarded.  We can easily make sure that
doesn't happen by calling cache_revisit_request just before
the final 'put'.

Also there is a small chance that a race would cause one thread to
defer a request against a cache item while another thread is failing
to queue and upcall for that item.  So when the upcall fails,
make sure to revisit all deferred requests.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 net/sunrpc/cache.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index d19c075..44f4516 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -221,6 +221,7 @@ int cache_check(struct cache_detail *detail,
 			switch (cache_make_upcall(detail, h)) {
 			case -EINVAL:
 				clear_bit(CACHE_PENDING, &h->flags);
+				cache_revisit_request(h);
 				if (rv == -EAGAIN) {
 					set_bit(CACHE_NEGATIVE, &h->flags);
 					cache_fresh_unlocked(h, detail,
@@ -473,8 +474,10 @@ static int cache_clean(void)
 		if (!ch)
 			current_index ++;
 		spin_unlock(&cache_list_lock);
-		if (ch)
+		if (ch) {
+			cache_revisit_request(ch);
 			cache_put(ch, d);
+		}
 	} else
 		spin_unlock(&cache_list_lock);
 


