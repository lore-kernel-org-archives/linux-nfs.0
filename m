Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755663Ab2BOAmu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 19:42:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] nfsd4: check for uninitialized slot
Date: Tue, 14 Feb 2012 19:42:46 -0500
Message-Id: <1329266566-8977-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1329266566-8977-1-git-send-email-bfields@redhat.com>
References: <1329266566-8977-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This fixes an oops when a buggy client tries to use an initial seqid of
0 on a new slot, which we may misinterpret as a replay.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    8 +++++++-
 fs/nfsd/state.h     |    1 +
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e0e706f..2387791 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1347,6 +1347,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 	slot->sl_opcnt = resp->opcnt;
 	slot->sl_status = resp->cstate.status;
 
+	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	if (nfsd4_not_cached(resp)) {
 		slot->sl_datalen = 0;
 		return;
@@ -1916,6 +1917,9 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 	status = check_slot_seqid(seq->seqid, slot->sl_seqid,
 					slot->sl_flags & NFSD4_SLOT_INUSE);
 	if (status == nfserr_replay_cache) {
+		status = nfserr_seq_misordered;
+		if (!(slot->sl_flags & NFSD4_SLOT_INITIALIZED))
+			goto out;
 		cstate->slot = slot;
 		cstate->session = session;
 		/* Return the cached reply status and set cstate->status
@@ -1932,9 +1936,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
 
 	/* Success! bump slot seqid */
 	slot->sl_seqid = seq->seqid;
-	slot->sl_flags = NFSD4_SLOT_INUSE;
+	slot->sl_flags |= NFSD4_SLOT_INUSE;
 	if (seq->cachethis)
 		slot->sl_flags |= NFSD4_SLOT_CACHETHIS;
+	else
+		slot->sl_flags &= ~NFSD4_SLOT_CACHETHIS;
 
 	cstate->slot = slot;
 	cstate->session = session;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 122217f..d8f52a0 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -134,6 +134,7 @@ struct nfsd4_slot {
 	u16	sl_opcnt;
 #define NFSD4_SLOT_INUSE	(1 << 0)
 #define NFSD4_SLOT_CACHETHIS	(1 << 1)
+#define NFSD4_SLOT_INITIALIZED	(1 << 2)
 	u8	sl_flags;
 	char	sl_data[];
 };
-- 
1.7.5.4

