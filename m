Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atlantic540.startdedicated.de ([188.138.9.77]:43963 "EHLO
        atlantic540.startdedicated.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753807AbcIVLy6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 07:54:58 -0400
From: Daniel Wagner <wagi@monom.org>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-kernel@vger.kernel.org,
        Daniel Wagner <daniel.wagner@bmw-carit.de>
Subject: [PATCH 2/2] NFS: cache_lib: use complete() instead of complete_all()
Date: Thu, 22 Sep 2016 13:54:29 +0200
Message-Id: <1474545269-8694-3-git-send-email-wagi@monom.org>
In-Reply-To: <1474545269-8694-1-git-send-email-wagi@monom.org>
References: <1474545269-8694-1-git-send-email-wagi@monom.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

There is only one waiter for the completion, therefore there
is no need to use complete_all(). Let's make that clear by
using complete() instead of complete_all().

The generic caching code from sunrpc is calling revisit() only once.

The usage pattern of the completion is:

waiter context                          waker context

do_cache_lookup_wait()
  nfs_cache_defer_req_alloc()
    init_completion()
  do_cache_lookup()
  nfs_cache_wait_for_upcall()
    wait_for_completion_timeout()

					nfs_dns_cache_revisit()
					  complete()

  nfs_cache_defer_req_put()

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
---
 fs/nfs/cache_lib.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 5f7b053..6de1570 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -76,7 +76,7 @@ static void nfs_dns_cache_revisit(struct cache_deferred_req *d, int toomany)
 
 	dreq = container_of(d, struct nfs_cache_defer_req, deferred_req);
 
-	complete_all(&dreq->completion);
+	complete(&dreq->completion);
 	nfs_cache_defer_req_put(dreq);
 }
 
-- 
2.7.4
