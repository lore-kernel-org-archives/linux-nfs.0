From: andros@netapp.com
Subject: [PATCH 03/31] nfsd41: turn off create session caching
Date: Tue, 28 Apr 2009 12:59:37 -0400
Message-ID: <1240938005-23778-3-git-send-email-andros@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
 <1240938005-23778-2-git-send-email-andros@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6692 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932891AbZD1RC4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 13:02:56 -0400
In-Reply-To: <1240938005-23778-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

In preparation for switching clientid cache strategies.
If cstate->slot is not set, nfsdsvc_encode_compoundres will not cache
the create session response.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 43c821f..e6dbf05 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1341,7 +1341,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		     struct nfsd4_create_session *cr_ses)
 {
 	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
-	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	struct nfs4_client *conf, *unconf;
 	struct nfsd4_slot *slot = NULL;
 	int status = 0;
@@ -1357,11 +1356,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -1419,7 +1413,6 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	cr_ses->seqid = slot->sl_seqid;
 
 	slot->sl_inuse = true;
-	cstate->slot = slot;
 	/* Ensure a page is used for the cache */
 	slot->sl_cache_entry.ce_cachethis = 1;
 out:
-- 
1.5.4.3

