Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:44086 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751041Ab0HQFTA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 01:19:00 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 17 Aug 2010 15:15:09 +1000
Subject: [PATCH 1.5/6] Fix race in new request delay code.
Cc: linux-nfs@vger.kernel.org, Anton Blanchard <anton@au1.ibm.com>
Message-ID: <20100817051509.26151.91127.stgit@localhost.localdomain>
In-Reply-To: <20100812065722.11459.18978.stgit@localhost.localdomain>
References: <20100812065722.11459.18978.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

If the 'wait_for_completion_interruptible_timeout' completes due
to interrupt or timeout, just before cache_revisit request gets around
to calling ->revisit and thus the completion, we have a race with bad
consequences.

cache_defer_req will see that sleeper.handle.hash is empty (because
cache_revisit_request has already done the list_del_init), and that
CACHE_PENDING is clear, and so will exit that function leaving any
local variables such as 'sleeper' undefined.

Meanwhile cache_revisit_request could delete sleeper.handle.recent
from the 'pending' list, and call sleeper.hande.revisit, any of which
could have new garbage values and so could trigger a BUG.

Reported-by: Anton Blanchard <anton@au1.ibm.com>
Signed-off-by: NeilBrown <neilb@suse.de>
---

Hi Bruce,

This should probably be merged into the patch 1/6 of the earlier
series.

I'm not certain this actually fixed what Anton reported (against
SLES), but there is a fair chance and I only found it because of the
report.

Thanks,
NeilBrown



 net/sunrpc/cache.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2fdd66b..ee4f799 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -577,15 +577,27 @@ static int cache_defer_req(struct cache_req *req, struct cache_head *item)
 	}
 
 	if (dreq == &sleeper.handle) {
-		wait_for_completion_interruptible_timeout(
-			&sleeper.completion, req->thread_wait);
-		spin_lock(&cache_defer_lock);
-		if (!list_empty(&sleeper.handle.hash)) {
-			list_del_init(&sleeper.handle.recent);
-			list_del_init(&sleeper.handle.hash);
-			cache_defer_cnt--;
+		if (wait_for_completion_interruptible_timeout(
+			    &sleeper.completion, req->thread_wait) <= 0) {
+			/* The completion wasn't completed, so we need
+			 * to clean up
+			 */
+			spin_lock(&cache_defer_lock);
+			if (!list_empty(&sleeper.handle.hash)) {
+				list_del_init(&sleeper.handle.recent);
+				list_del_init(&sleeper.handle.hash);
+				cache_defer_cnt--;
+				spin_unlock(&cache_defer_lock);
+			} else {
+				/* cache_revisit_request already removed
+				 * this from the hash table, but hasn't
+				 * called ->revisit yet.  It will very soon
+				 * and we need to wait for it.
+				 */
+				spin_unlock(&cache_defer_lock);
+				wait_for_completion(&sleeper.completion);
+			}
 		}
-		spin_unlock(&cache_defer_lock);
 		if (test_bit(CACHE_PENDING, &item->flags)) {
 			/* item is still pending, try request
 			 * deferral


