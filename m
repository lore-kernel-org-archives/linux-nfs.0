From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 18/44] nfsd41: obliterate nfsd41_copy_replay_data
Date: Tue, 16 Jun 2009 04:20:04 +0300
Message-ID: <1245115204-7394-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2588
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755580AbZFPBUD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Replacing page based drc cache with buffer based drc cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   39 ---------------------------------------
 1 files changed, 0 insertions(+), 39 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8c1dfe2..f01badc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1084,32 +1084,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
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
@@ -1141,19 +1115,6 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
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
1.6.3

