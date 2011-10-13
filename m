Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17125 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112Ab1JMVOi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Oct 2011 17:14:38 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 2/3] NFSv4.1: backchannel dynamic session slots
Date: Thu, 13 Oct 2011 17:14:29 -0400
Message-Id: <1318540470-15181-2-git-send-email-andros@netapp.com>
In-Reply-To: <1318540470-15181-1-git-send-email-andros@netapp.com>
References: <1318540470-15181-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use the new dynamic slot allocator, even though we only currently support
a single back channel slot.

Fix a bug: Slotid's start from 0 which means we check against
NFS41_BC_MAX_CALLBACKS - 1.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_proc.c |   27 +++++++++++++++++++--------
 fs/nfs/internal.h      |    2 ++
 fs/nfs/nfs4proc.c      |    2 +-
 3 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 43926ad..12bd9d0 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -339,10 +339,10 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 	dprintk("%s enter. slotid %d seqid %d\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
-	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS)
+	if (args->csa_slotid > NFS41_BC_MAX_CALLBACKS - 1)
 		return htonl(NFS4ERR_BADSLOT);
 
-	slot = tbl->slots + args->csa_slotid;
+	slot = nfs4_lookup_slot_locked(tbl, args->csa_slotid);
 	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
 
 	/* Normal */
@@ -377,6 +377,22 @@ out_ok:
 	return htonl(NFS4_OK);
 }
 
+static bool test_refer_slot(struct nfs4_slot_table *tbl,
+			    struct referring_call *ref)
+{
+	struct nfs4_slot *slot;
+	bool status = false;
+
+	spin_lock(&tbl->slot_tbl_lock);
+	if (test_bit(ref->rc_slotid, tbl->used_slots)) {
+		slot = nfs4_lookup_slot_locked(tbl, ref->rc_slotid);
+		if (slot->seq_nr == ref->rc_sequenceid)
+			status = true;
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+	return status;
+}
+
 /*
  * For each referring call triple, check the session's slot table for
  * a match.  If the slot is in use and the sequence numbers match, the
@@ -417,12 +433,7 @@ static bool referring_call_exists(struct nfs_client *clp,
 				((u32 *)&rclist->rcl_sessionid.data)[2],
 				((u32 *)&rclist->rcl_sessionid.data)[3],
 				ref->rc_sequenceid, ref->rc_slotid);
-
-			spin_lock(&tbl->slot_tbl_lock);
-			status = (test_bit(ref->rc_slotid, tbl->used_slots) &&
-				  tbl->slots[ref->rc_slotid].seq_nr ==
-					ref->rc_sequenceid);
-			spin_unlock(&tbl->slot_tbl_lock);
+			status = test_refer_slot(tbl, ref);
 			if (status)
 				goto out;
 		}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ab12913..88bd927 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -354,6 +354,8 @@ extern int _nfs4_call_sync_session(struct rpc_clnt *clnt,
 				   struct nfs4_sequence_args *args,
 				   struct nfs4_sequence_res *res,
 				   int cache_reply);
+struct nfs4_slot *nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl,
+					  u8 slotid);
 
 /*
  * Determine the device name as a string
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aacab11..7438632 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -433,7 +433,7 @@ nfs4_dynamic_alloc_slot(struct nfs4_slot_table *tbl, u8 slotid)
  * puts the request on the slot table waitq and dynamically allocates a
  * new slot.
  */
-static struct nfs4_slot *
+struct nfs4_slot *
 nfs4_lookup_slot_locked(struct nfs4_slot_table *tbl, u8 slotid)
 {
 	struct nfs4_slot *sp;
-- 
1.7.4.4

