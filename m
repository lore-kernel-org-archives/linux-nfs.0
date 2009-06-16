From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 04/44] nfsd41: turn off create session caching
Date: Tue, 16 Jun 2009 04:19:23 +0300
Message-ID: <1245115163-6931-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:2597
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752928AbZFPBTX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jun 2009 21:19:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation for switching clientid cache strategies.
If cstate->slot is not set, nfsdsvc_encode_compoundres will not cache
the create session response.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c22ec9b..5fdef66 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1344,7 +1344,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_slot *slot = NULL;
 	int status = 0;
@@ -1360,11 +1359,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (status == nfserr_replay_cache) {
 			dprintk("Got a create_session replay! seqid= %d\n",
 				slot->sl_seqid);
-			cstate->slot = slot;
-			cstate->status = status;
-			/* Return the cached reply status */
-			status = nfsd4_replay_cache_entry(resp, NULL);
-			goto out;
 		} else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
 			status = nfserr_seq_misordered;
 			dprintk("Sequence misordered!\n");
@@ -1413,7 +1407,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->seqid = slot->sl_seqid;
 
 	slot->sl_inuse = true;
-	cstate->slot = slot;
 	/* Ensure a page is used for the cache */
 	slot->sl_cache_entry.ce_cachethis = 1;
 out:
-- 
1.6.3

