From: andros@netapp.com
Subject: [PATCH 17/31] nfsd41: obliterate nfsd41_copy_replay_data
Date: Tue, 28 Apr 2009 12:59:51 -0400
Message-ID: <1240938005-23778-17-git-send-email-andros@netapp.com>
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
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50875 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759948AbZD1RAo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:00:44 -0400
In-Reply-To: <1240938005-23778-16-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |   39 ---------------------------------------
 1 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3d1e33a..bed5944 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1098,32 +1098,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 }
 
 /*
- * We keep the rpc header, but take the nfs reply from the replycache.
- */
-static int
-nfsd41_copy_replay_data(struct nfsd4_compoundres *resp,
-			struct nfsd4_cache_entry *entry)
-{
-	struct svc_rqst *rqstp = resp->rqstp;
-	struct kvec *resv = &resp->rqstp->rq_res.head[0];
-	int len;
-
-	/* Current request rpc header length*/
-	len = (char *)resp->cstate.statp -
-			(char *)page_address(rqstp->rq_respages[0]);
-	if (entry->ce_datav.iov_len + len > PAGE_SIZE) {
-		dprintk("%s v41 cached reply too large (%Zd).\n", __func__,
-			entry->ce_datav.iov_len);
-		return 0;
-	}
-	/* copy the cached reply nfsd data past the current rpc header */
-	memcpy((char *)resv->iov_base + len, entry->ce_datav.iov_base,
-		entry->ce_datav.iov_len);
-	resv->iov_len = len + entry->ce_datav.iov_len;
-	return 1;
-}
-
-/*
  * Keep the first page of the replay. Copy the NFSv4.1 data from the first
  * cached page.  Replace any futher replay pages from the cache.
  */
@@ -1155,19 +1129,6 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	/* The sequence operation has been encoded, cstate->datap set. */
 	memcpy(resp->cstate.datap, slot->sl_data, slot->sl_datalen);
 
-	if (!nfsd41_copy_replay_data(resp, entry)) {
-		/*
-		 * Not enough room to use the replay rpc header, send the
-		 * cached header. Release all the allocated result pages.
-		 */
-		svc_free_res_pages(resp->rqstp);
-	} else {
-		/* Release all but the first allocated result page */
-
-		resp->rqstp->rq_resused--;
-		svc_free_res_pages(resp->rqstp);
-	}
-
 	resp->rqstp->rq_resused = entry->ce_resused;
 	resp->opcnt = slot->sl_opcnt;
 	resp->cstate.iovlen = entry->ce_datav.iov_len + entry->ce_rpchdrlen;
-- 
1.5.4.3

