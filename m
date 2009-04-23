From: andros@netapp.com
Subject: [PATCH 14/29] nfsd41: obliterate nfsd4_copy_pages
Date: Thu, 23 Apr 2009 12:42:53 -0400
Message-ID: <1240504988-9572-15-git-send-email-andros@netapp.com>
References: <>
 <1240504988-9572-1-git-send-email-andros@netapp.com>
 <1240504988-9572-2-git-send-email-andros@netapp.com>
 <1240504988-9572-3-git-send-email-andros@netapp.com>
 <1240504988-9572-4-git-send-email-andros@netapp.com>
 <1240504988-9572-5-git-send-email-andros@netapp.com>
 <1240504988-9572-6-git-send-email-andros@netapp.com>
 <1240504988-9572-7-git-send-email-andros@netapp.com>
 <1240504988-9572-8-git-send-email-andros@netapp.com>
 <1240504988-9572-9-git-send-email-andros@netapp.com>
 <1240504988-9572-10-git-send-email-andros@netapp.com>
 <1240504988-9572-11-git-send-email-andros@netapp.com>
 <1240504988-9572-12-git-send-email-andros@netapp.com>
 <1240504988-9572-13-git-send-email-andros@netapp.com>
 <1240504988-9572-14-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756981AbZDWQnY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:24 -0400
In-Reply-To: <1240504988-9572-14-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 787cffe..334a3f3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1025,19 +1025,6 @@ nfsd4_release_respages(struct page **respages, short resused)
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
@@ -1097,8 +1084,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
-			 entry->ce_resused);
 	/* Current request rpc header length*/
 	entry->ce_rpchdrlen = (char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]);
@@ -1169,17 +1154,11 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
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
1.5.4.3

