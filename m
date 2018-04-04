Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:51316 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752262AbeDDWHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Apr 2018 18:07:11 -0400
Subject: [PATCH 04/12] fscache, cachefiles: Fix checker warnings
From: David Howells <dhowells@redhat.com>
To: torvalds@linux-foundation.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Wed, 04 Apr 2018 23:07:09 +0100
Message-ID: <152287962922.14760.8383895930885499464.stgit@warthog.procyon.org.uk>
In-Reply-To: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
References: <152287959470.14760.10350886166577848180.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a couple of checker warnings in fscache and cachefiles:

 (1) fscache_n_op_requeue is never used, so get rid of it.

 (2) cachefiles_uncache_page() is passed in a lock that it releases, so
     this needs annotating.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/rdwr.c |    1 +
 fs/fscache/stats.c   |    1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 883bc7bb12c5..5082c8a49686 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -952,6 +952,7 @@ int cachefiles_write_page(struct fscache_storage *op, struct page *page)
  * - cache withdrawal is prevented by the caller
  */
 void cachefiles_uncache_page(struct fscache_object *_object, struct page *page)
+	__releases(&object->fscache.cookie->lock)
 {
 	struct cachefiles_object *object;
 	struct cachefiles_cache *cache;
diff --git a/fs/fscache/stats.c b/fs/fscache/stats.c
index 7ac6e839b065..fcc8c2f2690e 100644
--- a/fs/fscache/stats.c
+++ b/fs/fscache/stats.c
@@ -21,7 +21,6 @@
 atomic_t fscache_n_op_pend;
 atomic_t fscache_n_op_run;
 atomic_t fscache_n_op_enqueue;
-atomic_t fscache_n_op_requeue;
 atomic_t fscache_n_op_deferred_release;
 atomic_t fscache_n_op_initialised;
 atomic_t fscache_n_op_release;

