From: andros@netapp.com
Subject: [PATCH 2/4] nfsd41: use session maxreqs for sequence target and highest slotid
Date: Fri, 28 Aug 2009 08:45:02 -0400
Message-ID: <1251463504-3376-3-git-send-email-andros@netapp.com>
References: <1251463504-3376-1-git-send-email-andros@netapp.com>
 <1251463504-3376-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:33497 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752057AbZIAVCa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 17:02:30 -0400
In-Reply-To: <1251463504-3376-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This fixes a bug in the sequence operation reply.

The sequence operation returns the highest slotid it will accept in the future
in sr_highest_slotid, and the highest slotid it prefers the client to use.
Since we do not re-negotiate the session slot table yet, these should both
always be set to the session ca_maxrequests.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4state.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 02b3ddd..ec074e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1133,7 +1133,6 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
 	 * session inactivity timer fires and a solo sequence operation
 	 * is sent (lease renewal).
 	 */
-	seq->maxslots = resp->cstate.session->se_fchannel.maxreqs;
 
 	/* Either returns 0 or nfserr_retry_uncached */
 	status = nfsd4_enc_sequence_replay(resp->rqstp->rq_argp, resp);
@@ -1497,6 +1496,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	slot = &session->se_slots[seq->slotid];
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
+	/* We do not negotiate the number of slots yet, so set the
+	 * maxslots to the session maxreqs which is used to encode
+	 * sr_highest_slotid and the sr_target_slot id to maxslots */
+	seq->maxslots = session->se_fchannel.maxreqs;
+
 	status = check_slot_seqid(seq->seqid, slot->sl_seqid, slot->sl_inuse);
 	if (status == nfserr_replay_cache) {
 		cstate->slot = slot;
-- 
1.6.2.5

