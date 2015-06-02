Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:33331 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbbFBK65 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jun 2015 06:58:57 -0400
Received: by qkhg32 with SMTP id g32so98545554qkh.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2015 03:58:56 -0700 (PDT)
Message-ID: <556D8C66.8080203@gmail.com>
Date: Tue, 02 Jun 2015 18:58:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, kinglongmee@gmail.com,
        Christoph Hellwig <hch@infradead.org>
Subject: [PATCH 1/2] nfs: Only update callback sequnce id when CB_SEQUENCE
 success
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When testing pnfs layout, nfsd got error NFS4ERR_SEQ_MISORDERED.
It is caused by nfs return NFS4ERR_DELAY before validate_seqid(),
don't update the sequnce id, but nfsd updates the sequnce id !!!

According to RFC5661 20.9.3,
" If CB_SEQUENCE returns an error, then the state of the slot
  (sequence ID, cached reply) MUST NOT change. "

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback_proc.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 197806f..7e9653a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -327,10 +327,8 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s slot table seqid: %u\n", __func__, slot->seq_nr);
 
 	/* Normal */
-	if (likely(args->csa_sequenceid == slot->seq_nr + 1)) {
-		slot->seq_nr++;
+	if (likely(args->csa_sequenceid == slot->seq_nr + 1))
 		goto out_ok;
-	}
 
 	/* Replay */
 	if (args->csa_sequenceid == slot->seq_nr) {
@@ -418,6 +416,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 			      struct cb_process_state *cps)
 {
 	struct nfs4_slot_table *tbl;
+	struct nfs4_slot *slot;
 	struct nfs_client *clp;
 	int i;
 	__be32 status = htonl(NFS4ERR_BADSESSION);
@@ -429,7 +428,9 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 
 	if (!(clp->cl_session->flags & SESSION4_BACK_CHAN))
 		goto out;
+
 	tbl = &clp->cl_session->bc_slot_table;
+	slot = tbl->slots + args->csa_slotid;
 
 	spin_lock(&tbl->slot_tbl_lock);
 	/* state manager is resetting the session */
@@ -444,7 +445,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 		goto out;
 	}
 
-	status = validate_seqid(&clp->cl_session->bc_slot_table, args);
+	status = validate_seqid(tbl, args);
 	spin_unlock(&tbl->slot_tbl_lock);
 	if (status)
 		goto out;
@@ -468,6 +469,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	res->csr_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 	res->csr_target_highestslotid = NFS41_BC_MAX_CALLBACKS - 1;
 
+	/*
+	 * RFC5661 20.9.3
+	 * If CB_SEQUENCE returns an error, then the state of the slot
+	 * (sequence ID, cached reply) MUST NOT change.
+	 */
+	slot->seq_nr++;
+
 out:
 	cps->clp = clp; /* put in nfs4_callback_compound */
 	for (i = 0; i < args->csa_nrclists; i++)
-- 
2.4.2

