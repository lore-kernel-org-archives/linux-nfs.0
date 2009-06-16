From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 17/44] nfsd41: obliterate nfsd4_copy_pages
Date: Tue, 16 Jun 2009 04:20:01 +0300
Message-ID: <1245115201-7361-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2624
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755383AbZFPBUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 58f4308..8c1dfe2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1026,19 +1026,6 @@ nfsd4_release_respages(struct page **respages, short resused)
 	}
 }
 
-static void
-nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
-{
-	int i;
-
-	for (i = 0; i < count; i++) {
-		topages[i] = frompages[i];
-		if (!topages[i])
-			continue;
-		get_page(topages[i]);
-	}
-}
-
 /*
  * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
  * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
@@ -1088,8 +1075,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
-			 entry->ce_resused);
 	entry->ce_datav.iov_base = resp->cstate.statp;
 	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]));
@@ -1162,17 +1147,11 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		 * cached header. Release all the allocated result pages.
 		 */
 		svc_free_res_pages(resp->rqstp);
-		nfsd4_copy_pages(resp->rqstp->rq_respages, entry->ce_respages,
-			entry->ce_resused);
 	} else {
 		/* Release all but the first allocated result page */
 
 		resp->rqstp->rq_resused--;
 		svc_free_res_pages(resp->rqstp);
-
-		nfsd4_copy_pages(&resp->rqstp->rq_respages[1],
-				 &entry->ce_respages[1],
-				 entry->ce_resused - 1);
 	}
 
 	resp->rqstp->rq_resused = entry->ce_resused;
-- 
1.6.3

