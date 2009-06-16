From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 19/44] nfsd41: obliterate nfsd4_release_respages
Date: Tue, 16 Jun 2009 04:20:07 +0300
Message-ID: <1245115207-7427-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2586
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755742AbZFPBUH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f01badc..c975719 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -577,19 +577,12 @@ release_session(struct nfsd4_session *ses)
 	nfsd4_put_session(ses);
 }
 
-static void nfsd4_release_respages(struct page **respages, short resused);
-
 void
 free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
-	int i;
 
 	ses = container_of(kref, struct nfsd4_session, se_ref);
-	for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
-		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
-		nfsd4_release_respages(e->ce_respages, e->ce_resused);
-	}
 	spin_lock(&nfsd_drc_lock);
 	nfsd_drc_mem_used -= ses->se_fchannel.maxreqs * NFSD_SLOT_CACHE_SIZE;
 	spin_unlock(&nfsd_drc_lock);
@@ -1010,23 +1003,6 @@ nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
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
@@ -1052,7 +1028,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
 
-	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-- 
1.6.3

