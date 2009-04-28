From: andros@netapp.com
Subject: [PATCH 18/31] nfsd41: obliterate nfsd4_release_respages
Date: Tue, 28 Apr 2009 12:59:52 -0400
Message-ID: <1240938005-23778-18-git-send-email-andros@netapp.com>
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
 <1240938005-23778-16-git-send-email-andros@netapp.com>
 <1240938005-23778-17-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760498AbZD1RA7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:59 -0400
In-Reply-To: <1240938005-23778-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com
---
 fs/nfsd/nfs4state.c |   25 -------------------------
 1 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bed5944..9ed99f4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -579,19 +579,12 @@ release_session(struct nfsd4_session *ses)
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
@@ -1024,23 +1017,6 @@ nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp)
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
@@ -1066,7 +1042,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
 		return;
 
-	nfsd4_release_respages(entry->ce_respages, entry->ce_resused);
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-- 
1.5.4.3

