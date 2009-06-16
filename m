From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 26/44] nfsd41: fix nfsd4_store_cache_entry comments
Date: Tue, 16 Jun 2009 04:20:27 +0300
Message-ID: <1245115227-7659-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2721
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756672AbZFPBU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   15 +++------------
 1 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 03e0c4d..5da7117 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -995,14 +995,8 @@ out_err:
 }
 
 /*
- * Cache the reply pages up to NFSD_PAGES_PER_SLOT + 1, clearing the previous
- * pages. We add a page to NFSD_PAGES_PER_SLOT for the case where the total
- * length of the XDR response is less than se_fmaxresp_cached
- * (NFSD_PAGES_PER_SLOT * PAGE_SIZE) but the xdr_buf pages is used for a
- * of the reply (e.g. readdir).
- *
- * Store the base and length of the rq_req.head[0] page
- * of the NFSv4.1 data, just past the rpc header.
+ *  Copy all encoded operation responses past the sequence response into the
+ *  slot's cache.
  */
 void
 nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
@@ -1021,11 +1015,8 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
-	/*
-	 * Don't need a page to cache just the sequence operation - the slot
-	 * does this for us!
-	 */
 
+	/* Don't cache the sequence operation, use the slot values on replay */
 	if (nfsd4_not_cached(resp)) {
 		slot->sl_datalen = 0;
 		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
-- 
1.6.3

