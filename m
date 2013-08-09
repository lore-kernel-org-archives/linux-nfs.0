Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:44441 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968188Ab3HIQry (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Aug 2013 12:47:54 -0400
Received: by mail-yh0-f52.google.com with SMTP id f11so1526864yha.39
        for <linux-nfs@vger.kernel.org>; Fri, 09 Aug 2013 09:47:53 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id y70sm20669532yhe.15.2013.08.09.09.47.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 09 Aug 2013 09:47:52 -0700 (PDT)
Subject: [PATCH v2 01/33] NFS: When displaying session slot numbers,
 use "%u" consistently
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 09 Aug 2013 12:47:51 -0400
Message-ID: <20130809164751.5362.67183.stgit@seurat.1015granger.net>
In-Reply-To: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
References: <20130809161957.5362.90865.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up, since slot and sequence numbers are all unsigned anyway.

Among other things, squelch compiler warnings:

linux/fs/nfs/nfs4proc.c: In function ‘nfs4_setup_sequence’:
linux/fs/nfs/nfs4proc.c:703:2: warning: signed and unsigned type in
	conditional expression [-Wsign-compare]

and

linux/fs/nfs/nfs4session.c: In function ‘nfs4_alloc_slot’:
linux/fs/nfs/nfs4session.c:151:31: warning: signed and unsigned type in
	conditional expression [-Wsign-compare]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/callback_proc.c |    8 ++++----
 fs/nfs/nfs4proc.c      |    6 +++---
 fs/nfs/nfs4session.c   |   10 +++++-----
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index e6ebc4c..e6f3b8f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -301,14 +301,14 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 {
 	struct nfs4_slot *slot;
 
-	dprintk("%s enter. slotid %d seqid %d\n",
+	dprintk("%s enter. slotid %u seqid %u\n",
 		__func__, args->csa_slotid, args->csa_sequenceid);
 
 	if (args->csa_slotid >= NFS41_BC_MAX_CALLBACKS)
 		return htonl(NFS4ERR_BADSLOT);
 
 	slot = tbl->slots + args->csa_slotid;
-	dprintk("%s slot table seqid: %d\n", __func__, slot->seq_nr);
+	dprintk("%s slot table seqid: %u\n", __func__, slot->seq_nr);
 
 	/* Normal */
 	if (likely(args->csa_sequenceid == slot->seq_nr + 1)) {
@@ -318,7 +318,7 @@ validate_seqid(struct nfs4_slot_table *tbl, struct cb_sequenceargs * args)
 
 	/* Replay */
 	if (args->csa_sequenceid == slot->seq_nr) {
-		dprintk("%s seqid %d is a replay\n",
+		dprintk("%s seqid %u is a replay\n",
 			__func__, args->csa_sequenceid);
 		/* Signal process_op to set this error on next op */
 		if (args->csa_cachethis == 0)
@@ -518,7 +518,7 @@ __be32 nfs4_callback_recallslot(struct cb_recallslotargs *args, void *dummy,
 	if (!cps->clp) /* set in cb_sequence */
 		goto out;
 
-	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target highest slotid %d\n",
+	dprintk_rcu("NFS: CB_RECALL_SLOT request from %s target highest slotid %u\n",
 		rpc_peeraddr2str(cps->clp->cl_rpcclient, RPC_DISPLAY_ADDR),
 		args->crsa_target_highest_slotid);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 28ed79e..f7a8f53 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -647,7 +647,7 @@ int nfs41_setup_sequence(struct nfs4_session *session,
 
 	args->sa_slot = slot;
 
-	dprintk("<-- %s slotid=%d seqid=%d\n", __func__,
+	dprintk("<-- %s slotid=%u seqid=%u\n", __func__,
 			slot->slot_nr, slot->seq_nr);
 
 	res->sr_slot = slot;
@@ -686,9 +686,9 @@ int nfs4_setup_sequence(const struct nfs_server *server,
 		goto out;
 	}
 
-	dprintk("--> %s clp %p session %p sr_slot %d\n",
+	dprintk("--> %s clp %p session %p sr_slot %u\n",
 		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot->slot_nr : -1);
+			res->sr_slot->slot_nr : NFS4_NO_SLOT);
 
 	ret = nfs41_setup_sequence(session, args, res, task);
 out:
diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 202e363..0161ad2 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -76,7 +76,7 @@ void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot)
 			nfs4_slot_tbl_drain_complete(tbl);
 		}
 	}
-	dprintk("%s: slotid %u highest_used_slotid %d\n", __func__,
+	dprintk("%s: slotid %u highest_used_slotid %u\n", __func__,
 		slotid, tbl->highest_used_slotid);
 }
 
@@ -146,9 +146,9 @@ struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl)
 	ret->generation = tbl->generation;
 
 out:
-	dprintk("<-- %s used_slots=%04lx highest_used=%d slotid=%d \n",
+	dprintk("<-- %s used_slots=%04lx highest_used=%u slotid=%u\n",
 		__func__, tbl->used_slots[0], tbl->highest_used_slotid,
-		!IS_ERR(ret) ? ret->slot_nr : -1);
+		!IS_ERR(ret) ? ret->slot_nr : NFS4_NO_SLOT);
 	return ret;
 }
 
@@ -191,7 +191,7 @@ static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,
 {
 	int ret;
 
-	dprintk("--> %s: max_reqs=%u, tbl->max_slots %d\n", __func__,
+	dprintk("--> %s: max_reqs=%u, tbl->max_slots %u\n", __func__,
 		max_reqs, tbl->max_slots);
 
 	if (max_reqs > NFS4_MAX_SLOT_TABLE)
@@ -205,7 +205,7 @@ static int nfs4_realloc_slot_table(struct nfs4_slot_table *tbl,
 	nfs4_reset_slot_table(tbl, max_reqs - 1, ivalue);
 	spin_unlock(&tbl->slot_tbl_lock);
 
-	dprintk("%s: tbl=%p slots=%p max_slots=%d\n", __func__,
+	dprintk("%s: tbl=%p slots=%p max_slots=%u\n", __func__,
 		tbl, tbl->slots, tbl->max_slots);
 out:
 	dprintk("<-- %s: return %d\n", __func__, ret);

