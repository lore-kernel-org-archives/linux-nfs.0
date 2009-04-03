From: andros@netapp.com
Subject: [PATCH 10/22] SQUASHME: nfsd41 rename nfsd4_move_pages
Date: Thu,  2 Apr 2009 20:19:51 -0400
Message-ID: <1238718003-8764-10-git-send-email-andros@netapp.com>
References: <1238718003-8764-1-git-send-email-andros@netapp.com>
 <1238718003-8764-2-git-send-email-andros@netapp.com>
 <1238718003-8764-3-git-send-email-andros@netapp.com>
 <1238718003-8764-4-git-send-email-andros@netapp.com>
 <1238718003-8764-5-git-send-email-andros@netapp.com>
 <1238718003-8764-6-git-send-email-andros@netapp.com>
 <1238718003-8764-7-git-send-email-andros@netapp.com>
 <1238718003-8764-8-git-send-email-andros@netapp.com>
 <1238718003-8764-9-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756361AbZDCAUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 20:20:31 -0400
In-Reply-To: <1238718003-8764-9-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

March 31 review comments.
squash into nfsd41: DRC save, restor, and clear functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1fec767..1a9f00a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1033,7 +1033,7 @@ nfsd4_release_respages(struct page **respages, short resused)
 }
 
 static void
-nfsd4_move_pages(struct page **topages, struct page **frompages, short count)
+nfsd4_copy_pages(struct page **topages, struct page **frompages, short count)
 {
 	int page_no;
 
@@ -1089,7 +1089,7 @@ nfsd4_set_cache_entry(struct nfsd4_compoundres *resp)
 	entry->ce_resused = rqstp->rq_resused;
 	if (entry->ce_resused > NFSD_PAGES_PER_SLOT + 1)
 		entry->ce_resused = NFSD_PAGES_PER_SLOT + 1;
-	nfsd4_move_pages(entry->ce_respages, rqstp->rq_respages,
+	nfsd4_copy_pages(entry->ce_respages, rqstp->rq_respages,
 			 entry->ce_resused);
 	entry->ce_datav.iov_base = resp->cstate.statp;
 	entry->ce_datav.iov_len = resv->iov_len - ((char *)resp->cstate.statp -
@@ -1161,7 +1161,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		 * cached header. Release all the allocated result pages.
 		 */
 		svc_free_res_pages(resp->rqstp);
-		nfsd4_move_pages(resp->rqstp->rq_respages, entry->ce_respages,
+		nfsd4_copy_pages(resp->rqstp->rq_respages, entry->ce_respages,
 			entry->ce_resused);
 	} else {
 		/* Release all but the first allocated result page */
@@ -1169,7 +1169,7 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 		resp->rqstp->rq_resused--;
 		svc_free_res_pages(resp->rqstp);
 
-		nfsd4_move_pages(&resp->rqstp->rq_respages[1],
+		nfsd4_copy_pages(&resp->rqstp->rq_respages[1],
 				 &entry->ce_respages[1],
 				 entry->ce_resused - 1);
 	}
-- 
1.5.4.3

