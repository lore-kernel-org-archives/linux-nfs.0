From: andros@netapp.com
Subject: [PATCH 16/31] nfsd41: obliterate nfsd4_copy_pages
Date: Tue, 28 Apr 2009 12:59:50 -0400
Message-ID: <1240938005-23778-16-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
 <1240938005-23778-3-git-send-email-andros@netapp.com>
 <1240938005-23778-4-git-send-email-andros@netapp.com>
 <1240938005-23778-5-git-send-email-andros@netapp.com>
 <1240938005-23778-6-git-send-email-andros@netapp.com>
 <1240938005-23778-7-git-send-email-andros@netapp.com>
 <1240938005-23778-8-git-send-email-andros@netapp.com>
 <1240938005-23778-9-git-send-email-andros@netapp.com>
 <1240938005-23778-10-git-send-email-andros@netapp.com>
 <1240938005-23778-11-git-send-email-andros@netapp.com>
 <1240938005-23778-12-git-send-email-andros@netapp.com>
 <1240938005-23778-13-git-send-email-andros@netapp.com>
 <1240938005-23778-14-git-send-email-andros@netapp.com>
 <1240938005-23778-15-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760153AbZD1RAs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:48 -0400
In-Reply-To: <1240938005-23778-15-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 05083d3..3d1e33a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1040,19 +1040,6 @@ nfsd4_release_respages(struct page **respages, short resused)
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
@@ -1102,8 +1089,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
-			 entry->ce_resused);
 	entry->ce_datav.iov_base = resp->cstate.statp;
 	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
 				(char *)page_address(rqstp->rq_respages[0]));
@@ -1176,17 +1161,11 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
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

