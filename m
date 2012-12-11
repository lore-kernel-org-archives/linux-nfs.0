Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:6207 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab2LKSo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 13:44:27 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/7] NFSD: Add slot table support for target_highest_slotid and highest_slotid
Date: Tue, 11 Dec 2012 13:44:15 -0500
Message-Id: <1355251459-18034-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1355251459-18034-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1355251459-18034-1-git-send-email-Trond.Myklebust@netapp.com>
 <1355251459-18034-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This commit just enables the slot table to set and maintain values for
the target_highest_slotid and highest_slotid, as used in the replies
to a SEQUENCE request from the client.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++-------
 fs/nfsd/nfs4xdr.c   |  7 +++----
 fs/nfsd/state.h     |  2 ++
 fs/nfsd/xdr4.h      |  6 ++----
 4 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9cb2450..a1208cc 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -853,11 +853,14 @@ static void nfsd4_free_slot_table(struct nfsd4_slot_table *tbl)
 	spin_unlock(&tbl->slt_lock);
 }
 
-static void nfsd4_init_slot_table(struct nfsd4_slot_table *tbl, size_t slotsize)
+static void nfsd4_init_slot_table(struct nfsd4_slot_table *tbl,
+		size_t slotsize, u32 highest_slotid)
 {
 	INIT_LIST_HEAD(&tbl->slt_head);
 	spin_lock_init(&tbl->slt_lock);
 	tbl->slt_slotsize = slotsize;
+	tbl->slt_highest_slotid = highest_slotid;
+	tbl->slt_target_highest_slotid = highest_slotid;
 }
 
 static struct nfsd4_session *__alloc_session(size_t slotsize, u32 highest_slotid)
@@ -867,7 +870,7 @@ static struct nfsd4_session *__alloc_session(size_t slotsize, u32 highest_slotid
 	new = kzalloc(sizeof(*new), GFP_KERNEL);
 	if (!new)
 		return NULL;
-	nfsd4_init_slot_table(&new->se_slots, slotsize);
+	nfsd4_init_slot_table(&new->se_slots, slotsize, highest_slotid);
 	/* allocate each struct nfsd4_slot and data cache in one piece */
 	if (nfsd4_grow_slot_table(&new->se_slots, highest_slotid, GFP_KERNEL))
 		return new;
@@ -2128,11 +2131,6 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 		goto out;
 	dprintk("%s: slotid %d\n", __func__, seq->slotid);
 
-	/* We do not negotiate the number of slots yet, so set the
-	 * maxslots to the session maxreqs which is used to encode
-	 * sr_highest_slotid and the sr_target_slot id to maxslots */
-	seq->maxslots = session->se_fchannel.maxreqs;
-
 	status = check_slot_seqid(seq->seqid, slot->sl_seqid,
 					slot->sl_flags & NFSD4_SLOT_INUSE);
 	if (status == nfserr_replay_cache) {
@@ -2161,6 +2159,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	else
 		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
 
+	/* Retrieve new target/highest slotid values */
+	spin_lock(&session->se_slots.slt_lock);
+	seq->target_highest_slotid = session->se_slots.slt_target_highest_slotid;
+	seq->highest_slotid = session->se_slots.slt_highest_slotid;
+	spin_unlock(&session->se_slots.slt_lock);
+
 	cstate->slot = slot;
 	cstate->session = session;
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fd548d1..52e2923 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1371,7 +1371,7 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
 	COPYMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	READ32(seq->seqid);
 	READ32(seq->slotid);
-	READ32(seq->maxslots);
+	READ32(seq->highest_slotid);
 	READ32(seq->cachethis);
 
 	DECODE_TAIL;
@@ -3415,9 +3415,8 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 	WRITEMEM(seq->sessionid.data, NFS4_MAX_SESSIONID_LEN);
 	WRITE32(seq->seqid);
 	WRITE32(seq->slotid);
-	/* Note slotid's are numbered from zero: */
-	WRITE32(seq->maxslots - 1); /* sr_highest_slotid */
-	WRITE32(seq->maxslots - 1); /* sr_target_highest_slotid */
+	WRITE32(seq->highest_slotid);
+	WRITE32(seq->target_highest_slotid);
 	WRITE32(seq->status_flags);
 
 	ADJUST_ARGS();
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 6bcc8a1..7a0d8e4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -146,6 +146,8 @@ struct nfsd4_slot_table {
 	spinlock_t		slt_lock;
 	size_t			slt_slotsize;
 	unsigned long		slt_memused;
+	u32			slt_target_highest_slotid;
+	u32			slt_highest_slotid;
 };
 
 struct nfsd4_channel_attrs {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index acd127d..0c5c704 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -405,11 +405,9 @@ struct nfsd4_sequence {
 	struct nfs4_sessionid	sessionid;		/* request/response */
 	u32			seqid;			/* request/response */
 	u32			slotid;			/* request/response */
-	u32			maxslots;		/* request/response */
+	u32			highest_slotid;		/* request/response */
 	u32			cachethis;		/* request */
-#if 0
-	u32			target_maxslots;	/* response */
-#endif /* not yet */
+	u32			target_highest_slotid;	/* response */
 	u32			status_flags;		/* response */
 };
 
-- 
1.7.11.7

