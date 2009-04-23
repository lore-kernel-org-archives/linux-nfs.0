From: andros@netapp.com
Subject: [PATCH 16/29]  nfsd41: obliterate nfsd4_release_respages
Date: Thu, 23 Apr 2009 12:42:55 -0400
Message-ID: <1240504988-9572-17-git-send-email-andros@netapp.com>
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
 <1240504988-9572-15-git-send-email-andros@netapp.com>
 <1240504988-9572-16-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46174 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756981AbZDWQnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 12:43:25 -0400
In-Reply-To: <1240504988-9572-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com
---
 fs/nfsd/nfs4state.c |   18 ------------------
 1 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index baa0e81..1d7f2c0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1009,23 +1009,6 @@ nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
 }
 
 /*
- * Dereference the result pages.
- */
-static void
-nfsd4_release_respages(struct page **respages, short resused)
-{
-	int i;
-
-	dprintk("--> %s\n", __func__);
-	for (i = 0; i < resused; i++) {
-		if (!respages[i])
-			continue;
-		put_page(respages[i]);
-		respages[i] = NULL;
-	}
-}
-
-/*
  * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
  * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
  * length of the XDR response is less than se_fmaxresp_cached
@@ -1049,7 +1032,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return 0;
 
-	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	entry->ce_opcnt = resp->opcnt;
 	entry->ce_status = resp->cstate.status;
 
-- 
1.5.4.3

