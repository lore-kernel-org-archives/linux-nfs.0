From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 29/44] nfsd41: fix nfsd4_store_cache_entry dprintk
Date: Tue, 16 Jun 2009 04:20:35 +0300
Message-ID: <1245115235-7758-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2661
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754811AbZFPBUf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:20:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5da7117..5866f94 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1006,7 +1006,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	struct nfsd4_compoundargs *args = rqstp->rq_argp;
 	struct nfsd4_op *op = &args->ops[resp->opcnt];
 
-	dprintk("--> %s\n", __func__);
+	dprintk("--> %s cachethis %d\n", __func__, slot->sl_cachethis);
 
 	/* Don't cache a failed OP_SEQUENCE. */
 	if (resp->opcnt == 1 && op->opnum == OP_SEQUENCE && resp->cstate.status)
@@ -1019,8 +1019,6 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	/* Don't cache the sequence operation, use the slot values on replay */
 	if (nfsd4_not_cached(resp)) {
 		slot->sl_datalen = 0;
-		dprintk("%s Just cache SEQUENCE. cachethis %d\n", __func__,
-			resp->cstate.slot->sl_cachethis);
 		return;
 	}
 	slot->sl_datalen = (char *)resp->p - (char *)resp->cstate.datap;
-- 
1.6.3

