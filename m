Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36524 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbbFLBfO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 21:35:14 -0400
Received: by iebps5 with SMTP id ps5so15321586ieb.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2015 18:35:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>,
        J Bruce Fields <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] NFS: Ensure that we update the sequence id under the slot table lock
Date: Thu, 11 Jun 2015 21:35:11 -0400
Message-Id: <1434072911-74171-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <556D8C66.8080203@gmail.com>
References: <556D8C66.8080203@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a callback slot table regression.

Fixes: e937ee714b2d ("nfs: Only update callback sequnce id when CB_SEQUENCE success")
Cc: Kinglong Mee <kinglongmee@gmail.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/callback_proc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 17a5c571a006..29e3c1b011b7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -435,14 +435,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	spin_lock(&tbl->slot_tbl_lock);
 	/* state manager is resetting the session */
 	if (test_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
-		spin_unlock(&tbl->slot_tbl_lock);
 		status = htonl(NFS4ERR_DELAY);
 		/* Return NFS4ERR_BADSESSION if we're draining the session
 		 * in order to reset it.
 		 */
 		if (test_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state))
 			status = htonl(NFS4ERR_BADSESSION);
-		goto out;
+		goto out_unlock;
 	}
 
 	memcpy(&res->csr_sessionid, &args->csa_sessionid,
@@ -453,9 +452,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 
 	status = validate_seqid(tbl, args);
-	spin_unlock(&tbl->slot_tbl_lock);
 	if (status)
-		goto out;
+		goto out_unlock;
 
 	cps->slotid = args->csa_slotid;
 
@@ -466,7 +464,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	 */
 	if (referring_call_exists(clp, args->csa_nrclists, args->csa_rclists)) {
 		status = htonl(NFS4ERR_DELAY);
-		goto out;
+		goto out_unlock;
 	}
 
 	/*
@@ -475,6 +473,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	 * (sequence ID, cached reply) MUST NOT change.
 	 */
 	slot->seq_nr++;
+out_unlock:
+	spin_unlock(&tbl->slot_tbl_lock);
 
 out:
 	cps->clp = clp; /* put in nfs4_callback_compound */
-- 
2.4.2

