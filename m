Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:37537 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbCWUVx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 16:21:53 -0400
Received: by igcqo1 with SMTP id qo1so49459750igc.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 13:21:53 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFSv4: Cleanup - move slot_table drain functions into fs/nfs/nfs4session.c
Date: Mon, 23 Mar 2015 16:21:49 -0400
Message-Id: <1427142109-91216-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1427142109-91216-1-git-send-email-trond.myklebust@primarydata.com>
References: <CAHQdGtTn5me9ZBfv9D8qZOmp6MFc29ppn4DqD8hOuMqRgRY8Rg@mail.gmail.com>
 <1427142109-91216-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also make nfs4_shutdown_slot_table() static now that it is no longer used
outside nfs4session.c.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4session.c | 33 ++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4session.h |  4 ++--
 fs/nfs/nfs4state.c   | 31 -------------------------------
 3 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 67c002a24d8f..ee8a8ee7c27d 100644
--- a/fs/nfs/nfs4session.c
+++ b/fs/nfs/nfs4session.c
@@ -69,6 +69,37 @@ void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl)
 	}
 }
 
+static int nfs4_wait_empty_slot_tbl(struct nfs4_slot_table *tbl)
+{
+	spin_lock(&tbl->slot_tbl_lock);
+	if (tbl->highest_used_slotid != NFS4_NO_SLOT) {
+		if (!test_and_set_bit(NFS4_SLOT_TBL_WAIT_EMPTY,
+					&tbl->slot_tbl_state))
+			reinit_completion(&tbl->complete);
+		spin_unlock(&tbl->slot_tbl_lock);
+		return wait_for_completion_interruptible(&tbl->complete);
+	}
+	spin_unlock(&tbl->slot_tbl_lock);
+	return 0;
+}
+
+int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
+{
+	/* Block new RPC calls */
+	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
+	/* Wait on outstanding RPC calls to complete */
+	return nfs4_wait_empty_slot_tbl(tbl);
+}
+
+void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl)
+{
+	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
+		spin_lock(&tbl->slot_tbl_lock);
+		nfs41_wake_slot_table(tbl);
+		spin_unlock(&tbl->slot_tbl_lock);
+	}
+}
+
 /*
  * nfs4_free_slot - free a slot and efficiently update slot table.
  *
@@ -250,7 +281,7 @@ static void nfs4_release_slot_table(struct nfs4_slot_table *tbl)
  * @tbl: slot table to shut down
  *
  */
-void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl)
+static void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl)
 {
 	nfs4_release_slot_table(tbl);
 	rpc_destroy_wait_queue(&tbl->slot_tbl_waitq);
diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 1912b250fcab..9181f7e1374a 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -76,10 +76,10 @@ enum nfs4_session_state {
 
 extern int nfs4_setup_slot_table(struct nfs4_slot_table *tbl,
 		unsigned int max_reqs, const char *queue);
-extern void nfs4_shutdown_slot_table(struct nfs4_slot_table *tbl);
 extern struct nfs4_slot *nfs4_alloc_slot(struct nfs4_slot_table *tbl);
 extern void nfs4_free_slot(struct nfs4_slot_table *tbl, struct nfs4_slot *slot);
-extern int nfs4_wait_empty_slot_tbl(struct nfs4_slot_table *tbl);
+extern int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl);
+extern void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl);
 extern void nfs4_slot_tbl_drain_complete(struct nfs4_slot_table *tbl);
 bool nfs41_wake_and_assign_slot(struct nfs4_slot_table *tbl,
 		struct nfs4_slot *slot);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index bd5293db4e5b..8fbf770d27ac 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -215,15 +215,6 @@ out:
 	return cred;
 }
 
-static void nfs4_end_drain_slot_table(struct nfs4_slot_table *tbl)
-{
-	if (test_and_clear_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state)) {
-		spin_lock(&tbl->slot_tbl_lock);
-		nfs41_wake_slot_table(tbl);
-		spin_unlock(&tbl->slot_tbl_lock);
-	}
-}
-
 static void nfs4_end_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
@@ -239,28 +230,6 @@ static void nfs4_end_drain_session(struct nfs_client *clp)
 	}
 }
 
-int nfs4_wait_empty_slot_tbl(struct nfs4_slot_table *tbl)
-{
-	spin_lock(&tbl->slot_tbl_lock);
-	if (tbl->highest_used_slotid != NFS4_NO_SLOT) {
-		if (!test_and_set_bit(NFS4_SLOT_TBL_WAIT_EMPTY,
-					&tbl->slot_tbl_state))
-			reinit_completion(&tbl->complete);
-		spin_unlock(&tbl->slot_tbl_lock);
-		return wait_for_completion_interruptible(&tbl->complete);
-	}
-	spin_unlock(&tbl->slot_tbl_lock);
-	return 0;
-}
-
-int nfs4_drain_slot_tbl(struct nfs4_slot_table *tbl)
-{
-	/* Block new RPC calls */
-	set_bit(NFS4_SLOT_TBL_DRAINING, &tbl->slot_tbl_state);
-	/* Wait on outstanding RPC calls to complete */
-	return nfs4_wait_empty_slot_tbl(tbl);
-}
-
 static int nfs4_begin_drain_session(struct nfs_client *clp)
 {
 	struct nfs4_session *ses = clp->cl_session;
-- 
2.1.0

